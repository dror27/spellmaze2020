#if SCRIPTING
//
//  JIMInterp.m
//  Board3
//
//  Created by Dror Kessler on 5/22/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import <objc/runtime.h>
#import <stdlib.h>
#import <Foundation/NSMethodSignature.h>
#import "JIMInterp.h"
#import "JIMHelper.h"
#import <math.h>

#define				MAX_ARGS 128
#define				CHAR_TO_INT_BOOL_FIX

typedef float 		(*IMP_FLOAT)(id, SEL, ...); 
typedef double 		(*IMP_DOUBLE)(id, SEL, ...); 


static int cmd_ObjcClass(Jim_Interp *interp, int argc, Jim_Obj *const *argv);
static int cmd_ObjcInstance(Jim_Interp *interp, int argc, Jim_Obj *const *argv);
static int invokeMethod(Jim_Interp *interp, int argc, Jim_Obj *const *argv, id obj, SEL sel, Method method);
static int cmd_Unknown(Jim_Interp *interp, int argc, Jim_Obj *const *argv);

static int cmd_sin(Jim_Interp *interp, int argc, Jim_Obj *const *argv);
static int cmd_cos(Jim_Interp *interp, int argc, Jim_Obj *const *argv);

static void logMethods(Class clazz, SEL missingSel);


@implementation JIMInterp

+(JIMInterp*)interp
{
	return [[[JIMInterp alloc] init] autorelease];
}

-(id)init
{
	if ( self = [super init] )
	{
		// create interpreter
		m_interp = Jim_CreateInterp();
				
		// register commands
		Jim_RegisterCoreCommands(m_interp);
		Jim_CreateCommand(m_interp, "objc", cmd_ObjcInstance, self, NULL);
		Jim_CreateCommand(m_interp, "unknown", cmd_Unknown, self, NULL);
		
		Jim_CreateCommand(m_interp, "sin", cmd_sin, self, NULL);
		Jim_CreateCommand(m_interp, "cos", cmd_cos, self, NULL);
	}
	return self;
}

-(void)dealloc
{
	if ( m_interp )
		Jim_FreeInterp(m_interp);
	
	[super dealloc];
}

-(id)eval:(NSString*)expr
{
	int		code = Jim_Eval(m_interp, [expr UTF8String]);

	if ( code )
	{
		NSString*		reason;
		
		if ( m_interp->errorFileName )
			reason = [NSString stringWithFormat:@"%s(%d): %@", m_interp->errorFileName, m_interp->errorLine, [self result]];
		else 
			reason = [self result];
		
		NSLog(@"Jim_Eval Failed: %@", reason);
		@throw [NSException exceptionWithName:@"Jim_Eval Failed" reason:reason userInfo:NULL];
	}
	return [self getTypedJimObj:m_interp->result withType:_C_ID];
}

-(id)eval:(NSString*)expr withPath:(NSString*)path
{
	if ( !expr )
	{
		NSLog(@"WARN: evaluating NULL");
		return NULL;
	}
	
	int		code = Jim_Eval_Named(m_interp, [expr UTF8String], [path UTF8String], 1);
	
	if ( code )
	{
		NSLog(@"Jim_Eval Failed: %@", [self result]);
		@throw [NSException exceptionWithName:@"Jim_Eval Failed" reason:[self result] userInfo:NULL];
	}
	
	return [self getTypedJimObj:m_interp->result withType:_C_ID];	
}

-(int)evalInt:(NSString*)expr
{
	int		code = Jim_Eval(m_interp, [expr UTF8String]);
	
	if ( code )
	{
		NSLog(@"Jim_Eval Failed: %@", [self result]);
		@throw [NSException exceptionWithName:@"Jim_Eval Failed" reason:[self result] userInfo:NULL];
	}
	
	return (int)[self getTypedJimObj:m_interp->result withType:_C_INT];	
}

-(float)evalFloat:(NSString*)expr
{
	int		code = Jim_Eval(m_interp, [expr UTF8String]);
	
	if ( code )
	{
		NSLog(@"Jim_Eval Failed: %@", [self result]);
		@throw [NSException exceptionWithName:@"Jim_Eval Failed" reason:[self result] userInfo:NULL];
	}
	
	id	result = [self getTypedJimObj:m_interp->result withType:_C_FLT];		
	float value = *(float*)&result;
	
	return value;
}

-(double)evalDouble:(NSString*)expr
{
	int		code = Jim_Eval(m_interp, [expr UTF8String]);
	
	if ( code )
	{
		NSLog(@"Jim_Eval Failed: %@", [self result]);
		@throw [NSException exceptionWithName:@"Jim_Eval Failed" reason:[self result] userInfo:NULL];
	}
	
	double value = [self getDoubleTypedJimObj:m_interp->result];		 
	
	return value;
}

-(NSString*)result
{
	return [NSString stringWithUTF8String:Jim_GetString(m_interp->result, NULL)];	
}

-(void)addClassCommand:(NSString*)className
{
	NSLog(@"AddClassCommand: className=%@", className);
	
	Jim_CreateCommand(m_interp, [className UTF8String], cmd_ObjcClass, self, NULL);
}

+(NSString*)objectAsCommand:(id)obj
{
	if ( obj )
		return [NSString stringWithFormat:@"objc_%x", obj];
	else
		return @"objc_NULL";
}

-(void)setInterpResult:(id)value withType:(char)type
{
	char			buf[128];
	
	switch (type) 
	{
		case _C_ID :
		{
			const char*		valueClassName = class_getName([value class]);
			if ( !strcmp(valueClassName, "NSString") || !strcmp(valueClassName, "NSCFString") 
				|| [value isKindOfClass:[NSString class]] )
				Jim_SetResultString(m_interp, [(NSString*)value UTF8String], -1);				
			else if ( !strcmp(valueClassName, "nil") )
				Jim_SetResultString(m_interp, "objc_NULL", -1);
			else
				Jim_SetResultString(m_interp, [[JIMInterp objectAsCommand:value] UTF8String], -1);
			break;
		}	
		case _C_INT :
			Jim_SetResultInt(m_interp, (int)value);
			break;
			
		case _C_UINT :
			Jim_SetResultInt(m_interp, (unsigned int)value);
			break;

		case _C_CHR :
		{
			char			ch = (char)(unsigned int)value;
#ifdef	CHAR_TO_INT_BOOL_FIX
			if ( ch == '\x00' )
			{
				Jim_SetResultInt(m_interp, 0);
				break;
			}
			else if ( ch == '\x01' )
			{
				Jim_SetResultInt(m_interp, 1);
				break;
			}
			
#endif
			
			Jim_SetResultString(m_interp, &ch, 1);
			break;
		}
		case _C_FLT :
		{
			float	*flt = (float*)&value;
			
			sprintf(buf, "%f", *flt);
			Jim_SetResultString(m_interp, buf, -1);
			break;
		}
			
		case _C_DBL :
		{
			double	*flt = (double*)&value;
			
			sprintf(buf, "%f", *flt);
			Jim_SetResultString(m_interp, buf, -1);
			break;
		}
			
		case _C_VOID :
		{
			Jim_SetResultString(m_interp, "", -1);
			break;
		}
			
		default :
		{
			NSLog(@"Unhandled Type: %@", [NSString stringWithFormat:@"%c", type]);
			@throw [NSException exceptionWithName:@"Unhandled Type" reason:[NSString stringWithFormat:@"%c", type] userInfo:NULL];				
		}
	}
}

-(double)getDoubleTypedJimObj:(Jim_Obj*)jimObj
{
	double				value;
	
	//NSLog(@"sizeof(id) = %d", sizeof(id));
	//NSLog(@"sizeof(double) = %d", sizeof(double));
	
	if ( Jim_GetDouble(m_interp, jimObj, &value) != JIM_OK )
		return 0.0;
	
	return value;
}

-(id)getTypedJimObj:(Jim_Obj*)jimObj withType:(char)type
{
	id			result;
	
	switch (type) 
	{
		case _C_ID :
		{
			const char*		value = Jim_GetString(jimObj, NULL);
			if ( !strncmp(value, "objc_", 5) )
			{
				const char*	tail = value + 5;
				
				if ( !strcmp(tail, "NULL") )
					return NULL;
				else if ( !strcmp(tail, "FALSE") )
					return (id)FALSE;
				else if ( !strcmp(tail, "TRUE") )
					return (id)TRUE;
				else
					sscanf(tail, "%x", &result);
			}
			else
				result = [NSString stringWithCString:value];
			break;
		}	

		case _C_INT :
		{
			long				value;
			if ( Jim_GetLong(m_interp, jimObj, &value) != JIM_OK )
			{
				// could it be a float/double?
				double		dValue;
				if ( Jim_GetDouble(m_interp, jimObj, &dValue) == JIM_OK )
					value = dValue;
				else
					return NULL;
			}
			result = (id)(int)value;
			break;
		}
			
		case _C_UINT :
		{
			long				value;
			if ( Jim_GetLong(m_interp, jimObj, &value) != JIM_OK )
				return NULL;
			result = (id)(unsigned int)value;
			break;
		}
			
			
		case _C_CHR :
		{
			const char*		value = Jim_GetString(jimObj, NULL);
			char			ch;
			
			if ( !strncmp(value, "objc_", 5) )
			{
				const char*	tail = value + 5;
				
				if ( !strcmp(tail, "NULL") )
					ch = 0;
				else if ( !strcmp(tail, "FALSE") )
					ch = FALSE;
				else if ( !strcmp(tail, "TRUE") )
					ch = TRUE;
			}
#ifdef	CHAR_TO_INT_BOOL_FIX
			else if ( !strncmp(value, "0", 1) )
				return (id)FALSE;
			else if ( !strncmp(value, "1", 1) )
				return (id)TRUE;
#endif
			else
				ch = value[0];
			
			result = (id)(unsigned int)ch;
			break;
		}
		case _C_FLT :
		{
			double				value;
			if ( Jim_GetDouble(m_interp, jimObj, &value) != JIM_OK )
				return NULL;
			*((float*)&result) = (float)value;
			break;
		}
		case _C_DBL :
		{
			if ( sizeof(id) != sizeof(double) )
			{
				NSLog(@"sizeof(id) != sizeof(double) - can not use getTypedJimObj");
				@throw [NSException exceptionWithName:@"sizeof(id) != sizeof(double) - can not use getTypedJimObj" reason:NULL userInfo:NULL];				
	
			}
			double				value;
			if ( Jim_GetDouble(m_interp, jimObj, &value) != JIM_OK )
				return NULL;
			*((double*)&result) = (double)value;
			break;
		}
			
			
		case _C_SEL :
		{
			const char*		value = Jim_GetString(jimObj, NULL);
			
			SEL				sel = sel_getUid(value);
			if ( !sel )
			{
				NSLog(@"No Such Selector: %s", value);
				@throw [NSException exceptionWithName:@"No Such Selector" reason:[NSString stringWithCString:value] userInfo:NULL];				
			}
			
			result = (id)sel;
			break;
		}
			
		default :
		{
			NSLog(@"Unhandled Type: %@", [NSString stringWithFormat:@"%c", type]);
			@throw [NSException exceptionWithName:@"Unhandled Type" reason:[NSString stringWithFormat:@"%c", type] userInfo:NULL];				
		}
	}
	
	return result;
	
}

static int cmd_ObjcClass(Jim_Interp *interp, int argc, Jim_Obj *const *argv)
{
	Class			clazz = objc_getClass(Jim_GetString(argv[0], NULL));

	SEL				sel = sel_getUid(Jim_GetString(argv[1], NULL)); 
	if ( !sel )
	{
		NSLog(@"No Such Selector: %@", [NSString stringWithCString:Jim_GetString(argv[1], NULL)]);
		@throw [NSException exceptionWithName:@"No Such Selector" reason:[NSString stringWithCString:Jim_GetString(argv[1], NULL)] userInfo:NULL];				
	}
	
	Method			method = class_getClassMethod(clazz, sel);
	if ( !method )
	{
		NSLog(@"No Such Class Method: %@", [NSString stringWithCString:Jim_GetString(argv[1], NULL)]);
		@throw [NSException exceptionWithName:@"No Such Class Method" reason:[NSString stringWithCString:Jim_GetString(argv[1], NULL)] userInfo:NULL];				
	}
	
	return invokeMethod(interp, argc, argv, clazz, sel, method);
}

static int cmd_ObjcInstance(Jim_Interp *interp, int argc, Jim_Obj *const *argv)
{
	id				obj;
	sscanf(Jim_GetString(argv[0], NULL), "objc_%x", &obj);
	Class			clazz = [obj class];

	SEL				sel = sel_getUid(Jim_GetString(argv[1], NULL)); 
	if ( !sel )
	{
		NSLog(@"No Such Selector: %@", [NSString stringWithCString:Jim_GetString(argv[1], NULL)]);
		@throw [NSException exceptionWithName:@"No Such Selector" reason:[NSString stringWithCString:Jim_GetString(argv[1], NULL)] userInfo:NULL];				
	}

	Method			method = NULL;
	for ( Class c = clazz ; c != NULL && method == NULL ; c = class_getSuperclass(c) )
		method = class_getInstanceMethod(c, sel);
	if ( !method )
	{
#if LOG_ALL_METHODS
		NSLog(@"Failed to find instance method: %s, listing methods for %@:", sel_getName(sel), clazz);
		logMethods(clazz, sel);
#else
		NSLog(@"Failed to find instance method: %s for %@:", sel_getName(sel), clazz);
#endif
		
		NSLog(@"No Such Class Method: %@", [NSString stringWithCString:Jim_GetString(argv[1], NULL)]);
		@throw [NSException exceptionWithName:@"No Such Instance Method" reason:[NSString stringWithCString:Jim_GetString(argv[1], NULL)] userInfo:NULL];				
	}
	
	return invokeMethod(interp, argc, argv, obj, sel, method);
}

static void logMethods(Class clazz, SEL missingSel)
{
	unsigned int	methodCount;
	Method*			methods = class_copyMethodList(clazz, &methodCount);
	
	if ( methods )
	{
		for ( int n = 0 ; n < methodCount ; n++ )
		{
			NSLog(@"%@ Method: %s", clazz, sel_getName(method_getName(methods[n])));
			if ( !strcmp(sel_getName(method_getName(methods[n])), sel_getName(missingSel)) )
				NSLog(@"-- last one seems of the same name as missing selector...");
		}
		
		free(methods);
	}
	
	if ( class_getSuperclass(clazz) )
		logMethods(class_getSuperclass(clazz), missingSel);
	
}

static int invokeMethod(Jim_Interp *interp, int argc, Jim_Obj *const *argv, id obj, SEL sel, Method method)
{
	// setup stuff
	JIMInterp*		jimInterp = interp->cmdPrivData;
	
	// process arguments
	int				argOfs = 2;
	int				argCount = MIN(method_getNumberOfArguments(method) - argOfs, MAX_ARGS);
	int				argExtra = 0;
	id				args[MAX_ARGS];
	char			argType[128] = {_C_ID, 0};
	for ( int argIndex = 0 ; argIndex < argCount ; argIndex++ )
	{
		method_getArgumentType(method, argIndex + argOfs, argType, sizeof(argType));
		if ( argIndex + 2 < argc )
		{
			if ( argType[0] != _C_DBL || sizeof(id) == sizeof(double) )
				args[argIndex+argExtra] = [jimInterp getTypedJimObj:argv[argIndex + 2] withType:argType[0]];
			else
			{
				double		value = [jimInterp getDoubleTypedJimObj:argv[argIndex + 2]];
				
				args[argIndex+argExtra] = ((id*)(&value))[0];
				args[argIndex+argExtra+1] = ((id*)(&value))[1];
				argExtra++;
			}
		}
		else
			args[argIndex+argExtra] = NULL;
	}
	for ( int argIndex = argCount ; argIndex < argc - 2 && argIndex < MAX_ARGS ; argIndex++ )
	{
		if ( argType[0] != _C_DBL || sizeof(id) == sizeof(double) )
			args[argIndex+argExtra] = [jimInterp getTypedJimObj:argv[argIndex + 2] withType:argType[0]];
		{
			double		value = [jimInterp getDoubleTypedJimObj:argv[argIndex + 2]];
			
			args[argIndex+argExtra] = ((id*)(&value))[0];
			args[argIndex+argExtra+1] = ((id*)(&value))[1];
			argExtra++;			
		}
		argCount++;
	}
	
	// establish return type
	char			returnType;
	method_getReturnType(method, &returnType, sizeof(returnType));
	
	// invoke (0,1,2, ... for now) - as a temp (for ...) solution, append a NULL 
	
	// different handling for float returns ... ('cause value is retuned from imp through floating point registers ...)
	if ( returnType != _C_FLT && returnType != _C_DBL )
	{
		id				result;
		IMP				imp = method_getImplementation(method);
		switch (argCount + argExtra) 
		{
			case 0 :
				result = (*imp)(obj, sel, NULL);
				break;
				
			case 1 :
				result = (*imp)(obj, sel, args[0], NULL);
				break;
				
			case 2 :
				result = (*imp)(obj, sel, args[0], args[1], NULL);
				break;
				
			case 3 :
				result = (*imp)(obj, sel, args[0], args[1], args[2], NULL);
				break;
				
			case 4 :
				result = (*imp)(obj, sel, args[0], args[1], args[2], args[3], NULL);
				break;
				
			case 5 :
				result = (*imp)(obj, sel, args[0], args[1], args[2], args[3], args[4], NULL);
				break;
				
			case 6 :
				result = (*imp)(obj, sel, args[0], args[1], args[2], args[3], args[4], args[5], NULL);
				break;
				
			default:
			{
				NSLog(@"Unsupported Number of Arguments: %@", [NSString stringWithFormat:@"%d", argCount]);
				@throw [NSException exceptionWithName:@"Unsupported Number of Arguments" reason:[NSString stringWithFormat:@"%d", argCount] userInfo:NULL];				
			}
		}
		
		// convert return type
		[jimInterp setInterpResult:result withType:returnType];		
	}
	else if ( returnType == _C_FLT )
	{
		float				result;
		IMP_FLOAT			imp = (IMP_FLOAT)method_getImplementation(method);
		switch (argCount + argExtra) 
		{
			case 0 :
				result = (*imp)(obj, sel, NULL);
				break;
				
			case 1 :
				result = (*imp)(obj, sel, args[0], NULL);
				break;
				
			case 2 :
				result = (*imp)(obj, sel, args[0], args[1], NULL);
				break;
				
			case 3 :
				result = (*imp)(obj, sel, args[0], args[1], args[2], NULL);
				break;
				
			case 4 :
				result = (*imp)(obj, sel, args[0], args[1], args[2], args[3], NULL);
				break;
				
			case 5 :
				result = (*imp)(obj, sel, args[0], args[1], args[2], args[3], args[4], NULL);
				break;
				
			case 6 :
				result = (*imp)(obj, sel, args[0], args[1], args[2], args[3], args[4], args[5], NULL);
				break;
				
			default:
			{
				NSLog(@"Unsupported Number of Arguments: %@", [NSString stringWithFormat:@"%d", argCount]);
				@throw [NSException exceptionWithName:@"Unsupported Number of Arguments" reason:[NSString stringWithFormat:@"%d", argCount] userInfo:NULL];				
			}
		}
		
		char	buf[128];
		sprintf(buf, "%f", result);
		Jim_SetResultString(jimInterp->m_interp, buf, -1);
	}
	else if ( returnType == _C_DBL )
	{
		double				result;
		IMP_DOUBLE			imp = (IMP_DOUBLE)method_getImplementation(method);
		switch (argCount + argExtra) 
		{
			case 0 :
				result = (*imp)(obj, sel, NULL);
				break;
				
			case 1 :
				result = (*imp)(obj, sel, args[0], NULL);
				break;
				
			case 2 :
				result = (*imp)(obj, sel, args[0], args[1], NULL);
				break;
				
			case 3 :
				result = (*imp)(obj, sel, args[0], args[1], args[2], NULL);
				break;
				
			case 4 :
				result = (*imp)(obj, sel, args[0], args[1], args[2], args[3], NULL);
				break;
				
			case 5 :
				result = (*imp)(obj, sel, args[0], args[1], args[2], args[3], args[4], NULL);
				break;
				
			case 6 :
				result = (*imp)(obj, sel, args[0], args[1], args[2], args[3], args[4], args[5], NULL);
				break;
				
			default:
			{
				NSLog(@"Unsupported Number of Arguments: %@", [NSString stringWithFormat:@"%d", argCount]);
				@throw [NSException exceptionWithName:@"Unsupported Number of Arguments" reason:[NSString stringWithFormat:@"%d", argCount] userInfo:NULL];				
			}
		}
		
		char	buf[128];
		sprintf(buf, "%f", result);
		Jim_SetResultString(jimInterp->m_interp, buf, -1);
	}
	
	
    return JIM_OK;
}

static int cmd_Unknown(Jim_Interp *interp, int argc, Jim_Obj *const *argv)
{
	// setup stuff
	JIMInterp*		jimInterp = interp->cmdPrivData;

	// is there a class by the name of the unknown command?
	const char		*cmdName = Jim_GetString(argv[1], NULL);
	Class			clazz = objc_getClass(cmdName);
	if ( !clazz )
		return JIM_ERR;
	
	// register the class command
	// NSLog(@"cmd_Unknown: adding class command: %s", cmdName);
	Jim_CreateCommand(interp, cmdName, cmd_ObjcClass, jimInterp, NULL);	
	
	// re-eval
	return Jim_EvalObjVector(interp, argc - 1, argv + 1);
}

static int cmd_sin(Jim_Interp *interp, int argc, Jim_Obj *const *argv)
{
    if (argc != 2) 
	{
        Jim_WrongNumArgs(interp, 1, argv, "arg");
        return JIM_ERR;
    }
	
	double		arg;
	Jim_GetDouble(interp, argv[1], &arg);
	
	Jim_SetResult(interp, Jim_NewDoubleObj(interp, sin(arg)));
	
	return JIM_OK;
}

static int cmd_cos(Jim_Interp *interp, int argc, Jim_Obj *const *argv)
{
    if (argc != 2) 
	{
        Jim_WrongNumArgs(interp, 1, argv, "arg");
        return JIM_ERR;
    }
	
	double		arg;
	Jim_GetDouble(interp, argv[1], &arg);
	
	Jim_SetResult(interp, Jim_NewDoubleObj(interp, cos(arg)));
	
	return JIM_OK;
}
@end
#endif
