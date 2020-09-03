//
//  PrefImageItem.m
//  Board3
//
//  Created by Dror Kessler on 8/4/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "PrefImageItem.h"
#import "Constants.h"
#import "UIImage_ResizeImageAllocator.h"
#import "UIImage_TextRepresentation.h"
#import "PrefViewController.h"
#import	<QuartzCore/QuartzCore.h>

@interface PrefImageItem (Privates)
-(void)fetchImage;
-(void)saveImage:(UIImage*)image;
@end

@implementation PrefImageItem
@synthesize image = _image;
@synthesize imageUrl = _imageUrl;
@synthesize defaultImage = _defaultImage;
@synthesize forcedSize = _forcedSize;
@synthesize nextPage = _nextPage;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andImage:(UIImage*)image
{
	if ( self = [super initWithLabel:label andKey:key] )
	{
		self.image = image;
	}
	return self;
}

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andImageURL:(NSURL*)imageUrl
{
	if ( self = [super initWithLabel:label andKey:key] )
	{
		self.imageUrl = imageUrl;
	}
	return self;
}

-(void)dealloc
{
	[_image release];
	[_imageUrl release];
	[_defaultImage release];
	[_nextPage release];
	
	[super dealloc];
}


-(UIView*)control
{
	if ( !_control )
	{
		[self fetchImage];
		
		if ( self.image )
		{
			CGRect		frame = CGRectMake(0.0, 0.0, self.image.size.width, self.image.size.height);
			UIImageView* imageControl = [[[UIImageView alloc] initWithFrame:frame] autorelease];
			
			imageControl.layer.cornerRadius = 5.0;
			imageControl.layer.masksToBounds = YES;
			
			imageControl.image = self.image;
			
			self.control = imageControl;
		}
		else
		{
			CGRect		frame = CGRectMake(0.0, 0.0, self.forcedSize.width, self.forcedSize.height);
			UIImageView* imageControl = [[[UIImageView alloc] initWithFrame:frame] autorelease];

			imageControl.layer.cornerRadius = 10.0;
			imageControl.layer.masksToBounds = YES;

			self.control = imageControl;
		}
		
	}
	
	return _control;
}

-(float)rowHeight
{
	[self fetchImage];

	if ( self.image )
		return self.image.size.height + 10;
	else
		return [super rowHeight];
}

-(BOOL)nests
{
	return _key || _nextPage;
}

-(void)wasSelected:(UIViewController*)inController
{
	if ( _nextPage )
	{
		UIViewController*			next = [[PrefViewController alloc] initWithPrefPage:_nextPage];
		
		[inController.navigationController pushViewController:next animated:TRUE];		
	}
	else if ( _key )
	{
		UIImagePickerController*	next = [[UIImagePickerController alloc] init];
		next.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		next.allowsImageEditing = TRUE;
		next.delegate = self;
		
		[inController presentModalViewController:next animated:YES];
	}
}

-(void)refresh
{
	[self fetchImage];

	((UIImageView*)_control).image = self.image;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	// OS 2.2.1
	NSLog(@"didFinishPickingImage");
	
	[self saveImage:image];
	
	// dismiss
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	// OS 3.0
	NSLog(@"didFinishPickingMediaWithInfo");	

	// extract image
	UIImage*	image = [info objectForKey:UIImagePickerControllerOriginalImage];
	CGRect		rect = CGRectMake(0, 0, image.size.width, image.size.height);
	NSValue*	rectValue = [info objectForKey:UIImagePickerControllerCropRect];
	if ( rectValue )
		[rectValue getValue:&rect];
	
	// crop?
	if ( rect.origin.x != 0 || rect.origin.y != 0 || rect.size.width != image.size.width || rect.size.height != image.size.height )
	{
		CGImageRef	imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
		image = [UIImage imageWithCGImage:imageRef];
		CGImageRelease(imageRef);
	}
	
	[self saveImage:image];
	
	// dismiss
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
}

-(void)fetchImage
{
	// fetch from key?
	if ( self.key )
		self.image = [UIImage imageFromTextRepresentation:[UserPrefs getString:self.key withDefault:NULL]];
	
	// fetch from url?
	if ( !self.image && self.imageUrl )
		self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageUrl]];
	
	// default?
	if ( !self.image )
		self.image = self.defaultImage;
}

-(void)saveImage:(UIImage*)image
{
	// force image into new dimensions?
	if ( self.forcedSize.width > 0.0 && self.forcedSize.height > 0.0 
		&& (self.forcedSize.width != image.size.width || self.forcedSize.height != image.size.height) )
	{
		image = [image scaleImageToSize:self.forcedSize];
	}
	
	// store into key
	if ( self.key )
		[UserPrefs setString:self.key withValue:[image textRepresentation]];
	[self wasChanged];
}
@end
