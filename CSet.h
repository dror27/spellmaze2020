/*
 * CSet.h
 *
 *  Created on: May 18, 2009
 *      Author: dror
 */

#ifndef CSET_H_
#define CSET_H_

#ifndef _TIME_H_
#include <time.h>
#endif

// set element type
//#define	T_ELEM	unsigned short
#define		T_ELEM	unsigned int
#define        T_ELEM    unsigned long long

// true/false
#ifndef TRUE
#define	TRUE 1
#define FALSE 0
#endif

// initial allocation
#define	ALLOC_INIT			16
#define	ALLOC_GROWTH_FACTOR	2


typedef int (*CSet_CompareFunc)(const void *, const void *) ;

// a set
typedef struct
{
	int			size;			// number of elements
	T_ELEM		*elems;			// always sorted

	int			allocated;		// number of elements allocate

	CSet_CompareFunc	compare;
	
	int			version;
	
	unsigned 	sorted:1;		// flags

} CSet;

// prototypes
CSet*	CSet_Alloc(int allocation);
void	CSet_Realloc(CSet* cs, int allocation);
CSet*	CSet_AllocCopy(CSet* cs);
void	CSet_Free(CSet* cs);
void	CSet_Clear(CSet* cs);
void	CSet_Copy(CSet* cs, CSet* dst);
void	CSet_CopyInverted(CSet* cs, CSet* dst, T_ELEM minElem, T_ELEM maxElem);
void	CSet_AddElement(CSet* cs, T_ELEM elem);
void	CSet_AddElements(CSet* cs, T_ELEM *elems, int count);
void	CSet_AddAllElements(CSet* cs, CSet* from);
void	CSet_SortElements(CSet* cs);
void	CSet_RemoveDuplicates(CSet* cs);
int		CSet_IsMember(CSet* cs, T_ELEM elem);
int 	CSet_MemberIndex(CSet* cs, T_ELEM elem, int rangeStart, int rangeSize);
CSet*	CSet_Intersect(CSet** csVector, int csCount, CSet* result);
CSet*	CSet_NegativeIntersect(CSet* cs, CSet** csVector, int csCount, CSet* result);
CSet*	CSet_Union(CSet** csVector, int csCount, CSet* result);

int		CSet__UnsignedIntCompare(const void * a, const void * b);
int		CSet__UnicharStringCompare(const void * a, const void * b);


#ifdef CSET_FILE
void	CSet_Print(CSet* cs, FILE* f);
#endif



#endif /* CSET_H_ */
