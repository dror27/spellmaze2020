/*
 * CSet.c
 *
 *  Created on: May 18, 2009
 *      Author: dror
 */

#define CSET_FILE

#ifdef CSET_FILE
#include <stdio.h>
#endif
#include <stdlib.h>
#include <memory.h>

#include "CSet.h"

#ifndef unichar
#define unichar unsigned short
#endif

#ifdef	TARGET_IPHONE_SIMULATOR	
#define	SAFTY_FILL
#endif

//#define	MEASURE
#ifdef MEASURE
static clock_t	startedAt;
#endif

CSet*
CSet_Alloc(int allocation)
{
	CSet*		cs = calloc(1, sizeof(CSet));

	cs->size = 0;
	cs->allocated = allocation > 0 ? allocation : ALLOC_INIT;
	cs->elems = malloc(cs->allocated * sizeof(T_ELEM));
	cs->compare = CSet__UnsignedIntCompare;
	cs->sorted = TRUE;

#ifdef SAFTY_FILL
	memset(cs->elems, 0xFF, cs->allocated * sizeof(T_ELEM));
#endif
	
	return cs;
}

void
CSet_Realloc(CSet* cs, int allocation)
{
	if ( cs->allocated < allocation )
	{
		cs->elems = realloc(cs->elems, (cs->allocated = allocation) * sizeof(T_ELEM));
	}
}

CSet*
CSet_AllocCopy(CSet* cs)
{
	CSet*		cs1 = calloc(1, sizeof(CSet));

	cs1->size = cs->size;
	cs1->allocated = cs->allocated;
	cs1->elems = calloc(cs1->allocated, sizeof(T_ELEM));
	cs1->compare = cs->compare;
	cs1->sorted = cs->sorted;

	memcpy(cs1->elems, cs->elems, cs->size * sizeof(T_ELEM));

	return cs1;
}

void
CSet_Copy(CSet* cs, CSet* dst)
{
	if ( dst->allocated < cs->size )
	{
		dst->elems = realloc(dst->elems, (dst->allocated = cs->size) * sizeof(T_ELEM));
	}

	dst->size = cs->size;
	dst->sorted = cs->sorted;
	dst->compare = cs->compare;

	memcpy(dst->elems, cs->elems, cs->size * sizeof(T_ELEM));
	
	dst->version++;
}

void	
CSet_CopyInverted(CSet* cs, CSet* dst, T_ELEM minElem, T_ELEM maxElem)
{
	// source must be sorted
	CSet_SortElements(cs);
	
	// calculate size of destination and allocate
	int			dstSize = maxElem - minElem + 1 - cs->size;
	if ( dst->allocated < dstSize )
		dst->elems = realloc(dst->elems, (dst->allocated = dstSize) * sizeof(T_ELEM));		
	dst->size = dstSize;
	
	// source empty?
	if ( !cs->size )
	{
		T_ELEM		*pDst = dst->elems;
		T_ELEM		elem = minElem;
		
		while ( dstSize-- )
			*pDst++ = elem++;
	}
	else
	{
		// walk on source, copy until no elems to 'copy'
		T_ELEM		*pSrc = cs->elems;
		T_ELEM		*pDst = dst->elems;
		T_ELEM		*pSrcEnd = cs->elems + cs->size;
		
		// start condition (prefill until first element)
		T_ELEM		elem = *pSrc++;
		while ( minElem != elem )
			*pDst++ = minElem++;
			
		// middle loop (fill gaps)
		for (  ; pSrc < pSrcEnd ; elem = *pSrc++ )
		{
			register T_ELEM	nextElem = *pSrc;
			
			if ( nextElem != elem + 1 )
			{
				for ( minElem = elem + 1 ; minElem < nextElem ; )
					*pDst++ = minElem++;
			}
		}
		
		// finish condition (postfill after last element)
		for ( elem = pSrc[-1] + 1 ; elem <= maxElem ; )
			*pDst++ = elem++;
	}
		
	
	// destination is sorted
	dst->sorted = TRUE;	
	dst->version++;
}

void
CSet_Free(CSet* cs)
{
	if ( cs->elems )
		free(cs->elems);
	free(cs);
}

void
CSet_Clear(CSet* cs)
{
	cs->size = 0;
	cs->sorted = TRUE;
	cs->version++;
}

void
CSet_AddElement(CSet* cs, T_ELEM elem)
{
	// space?
	if ( cs->size + 1 >= cs->allocated )
	{
		cs->elems = realloc(cs->elems, (cs->allocated *= ALLOC_GROWTH_FACTOR) * sizeof(T_ELEM));
	}

	// add add end
	// TODO: not checking for unique ... is it fine?
	cs->elems[cs->size++] = elem;

	// change sorted?
	if ( cs->sorted && cs->size >= 2 && (!cs->compare || cs->compare(&cs->elems[cs->size - 2], &elem) > 0) )
		cs->sorted = FALSE;
	
	cs->version++;
}

void	
CSet_AddElements(CSet* cs, T_ELEM *elems, int count)
{
	for ( ; count > 0 ; count--, elems++ )
		CSet_AddElement(cs, *elems);
	
	cs->version++;
}

void	
CSet_AddAllElements(CSet* cs, CSet* from)
{
	CSet_AddElements(cs, from->elems, from->size);
	
	cs->version++;
}

static int 
CSet__CompareCSetSizeAcsending(const void * a, const void * b)
{
	const CSet*		csA = *((CSet**)a);
	const CSet*		csB = *((CSet**)b);
	
	return csA->size - csB->size;
}
static int 
CSet__CompareCSetSizeDescending(const void * a, const void * b)
{
	const CSet*		csA = *((CSet**)a);
	const CSet*		csB = *((CSet**)b);
	
	return csB->size - csA->size;
}

void
CSet_SortElements(CSet* cs)
{
	if ( !cs->sorted && cs->compare)
	{
		qsort(cs->elems, cs->size, sizeof(T_ELEM), cs->compare);

		cs->sorted = TRUE;
	}
	
	cs->version++;
}

void
CSet_RemoveDuplicates(CSet* cs)
{
	if ( cs->compare && cs->size )
	{
		CSet_SortElements(cs);
		
		// walk the elements, removing duplicates
		T_ELEM*		src = cs->elems + 1;
		T_ELEM*		dst = cs->elems + 1;
		T_ELEM*		end = cs->elems + cs->size;
		int			elemsRemoved = 0;
		
		while ( src < end )
		{
			if ( cs->compare(src, dst - 1) )
			{
				// different from last
				*dst++ = *src++;
			}
			else
			{
				// same, skip
				src++;
				elemsRemoved++;
			}
		}
		
		// adjust size
		cs->size -= elemsRemoved;
	}
	
	cs->version++;
}

int	CSet_IsMember(CSet* cs, T_ELEM elem)
{
	return CSet_MemberIndex(cs, elem, 0, cs->size) >= 0;
}

int CSet_MemberIndex(CSet* cs, T_ELEM elem, int rangeStart, int rangeSize)
{
	int		fastCompare = cs->compare == CSet__UnsignedIntCompare;
	
	// must be sorted
	if ( !cs->sorted )
		CSet_SortElements(cs);

	int		middle = rangeStart + rangeSize / 2;
	while ( rangeSize > 0 )
	{
		T_ELEM		middleElem = cs->elems[middle];
		int		delta = fastCompare ? (elem - middleElem) : (cs->compare ? cs->compare(&elem, &middleElem) : 0);

		if ( delta < 0 )
		{
			rangeSize = middle - rangeStart;
		}
		else if ( delta > 0 )
		{
			rangeSize = rangeStart + rangeSize - middle - 1;
			rangeStart = middle + 1;
		}
		else
			return middle;

		middle = rangeStart + rangeSize / 2;
	}

	// if here, not member. return the negative of the last index
	// TODO: need to check that this is working correctly!
	return -middle - 1;
}

#define		GALLOP

static inline int CSet_FastCompareMemberIndex(CSet* cs, T_ELEM elem, int rangeStart, int rangeSize)
{
	T_ELEM*		elems = cs->elems;
	
#ifdef GALLOP
	int		ofs = 1;
	for ( ; ofs < rangeSize ; ofs = ((ofs + 1) << 1) - 1 )
		if ( elems[rangeStart + ofs] > elem )
			break;
	//printf("gallop: %d %d %d %d %d\n", rangeStart, rangeSize, ofs, elem, elems[rangeStart]);
	if ( ofs < rangeSize )
		rangeSize = ofs;
#endif
	
	int		middle = rangeStart + (rangeSize >> 1);

	while ( rangeSize > 0 )
	{
		int		middleElem = elems[middle];
		int		delta = elem - middleElem;
		
		if ( delta < 0 )
		{
			rangeSize = middle - rangeStart;
		}
		else if ( delta > 0 )
		{
			rangeSize = rangeStart + rangeSize - middle - 1;
			rangeStart = middle + 1;
		}
		else
		{
			return middle;
		}
		
		middle = rangeStart + (rangeSize >> 1);
	}
	
	// if here, not member. return the negative of the last index
	return -middle - 1;
}


void
CSet__SortSetsVector(CSet** csVector, int csCount, int risingOrder)
{
	return qsort(csVector, csCount, sizeof(CSet*), 
					risingOrder ? CSet__CompareCSetSizeAcsending : CSet__CompareCSetSizeDescending);
}

CSet*
CSet_Intersect(CSet** csVector, int csCount, CSet* result)
{
#ifdef MEASURE
	startedAt = clock();
#endif
	
	// shortcut
	if ( csCount == 0 )
		return CSet_Alloc(0);
	else if ( csCount == 1 )
	{
		if ( result != NULL )
			CSet_Copy(csVector[0], result);
		else
			result = CSet_AllocCopy(csVector[0]);

		return result;
	}

	// sort sets according to size
	CSet__SortSetsVector(csVector, csCount, TRUE);

	// use first (smallest) set as a the candidate answer
	CSet_SortElements(csVector[0]);
	if ( result )
		CSet_Realloc(result, csVector[0]->size);
	else
		result = CSet_Alloc(csVector[0]->size);

#ifdef MEASURE
	printf("[CSet_Intersect] %f starting loop\n", (float)(clock() - startedAt) / CLOCKS_PER_SEC);
#endif
	
	// intersect with non-first sets
	int			csIndex;
	for ( csIndex = 1 ; csIndex < csCount ; csIndex++ )
	{
		CSet*		cs = csVector[csIndex];
		int			csSize = cs != NULL ? cs->size : 0;
		CSet*		resultSrc = (csIndex > 1) ? result : csVector[0];

		// shortcut
		if ( resultSrc->size <= 0 || csSize <= 0 )
		{
			result->size = 0;
			break;
		}

		CSet_SortElements(cs);
		int					fastCompare = (cs->compare == CSet__UnsignedIntCompare);
										  
		// loop on elements in the candidate answer
		int		limit = 0;
		T_ELEM	*p1, *pend = resultSrc->elems + resultSrc->size;
		T_ELEM 	*pout = result->elems;		// will be writing back directly into result
		T_ELEM	elem;
		for ( p1 = resultSrc->elems ; p1 < pend ; p1++ )
		{
			elem = *p1;
			
			// search for element
			int		index;
			if ( fastCompare )
				index = CSet_FastCompareMemberIndex(cs, elem, limit, csSize - limit);
			else
				index = CSet_MemberIndex(cs, elem, limit, csSize - limit);
			
			if ( index >= 0 )
			{
				// found!, add to result and update limit
				*pout++ = elem;
				limit = index + 1;
			}
			else
			{
				// not found, only update limit
				limit = -(index + 1);
			}
		}

		// swap adjust result size
		result->size = pout - result->elems;
		
#ifdef MEASURE
		printf("[CSet_Intersect] %f loop iteration %d ended, result size %d\n", 
						(float)(clock() - startedAt) / CLOCKS_PER_SEC, 
						csIndex, result->size);
#endif
		
	}

#ifdef MEASURE
	printf("[CSet_Intersect] %f DONE\n", (float)(clock() - startedAt) / CLOCKS_PER_SEC);
#endif
	
	// return result
	result->version++;
	return result;
}

CSet*
CSet_NegativeIntersect(CSet* cs, CSet** csVector, int csCount, CSet* result)
{
	// use argument set as a the candidate answer
	if ( result == NULL )
		result = CSet_AllocCopy(cs);
	else if ( cs != result )
		CSet_Copy(cs, result);
	
	// shortcut
	if ( csCount == 0 )
		return result;
	
	// sort sets according to size
	CSet__SortSetsVector(csVector, csCount, FALSE);
	
	// use argument set as a the candidate answer
	CSet_SortElements(cs);
	
	// intersect with non-first sets
	int			csIndex;
	for ( csIndex = 0 ; csIndex < csCount ; csIndex++ )
	{
		CSet*		cs = csVector[csIndex];
		int			csSize = cs != NULL ? cs->size : 0;
		
		// shortcut
		if ( result->size <= 0)
			break;
		if ( csSize <= 0 )
			continue;
		
		CSet_SortElements(cs);
		
		// loop on elements in the candidate answer
		int		limit = 0;
		T_ELEM	*p1, *pend = result->elems + result->size;
		T_ELEM 	*pout = result->elems;		// will be writing back directly into result
		T_ELEM	elem;
		for ( elem = *(p1 = result->elems) ; p1 < pend ; elem = *++p1 )
		{
			// search for element
			int		index = CSet_MemberIndex(cs, elem, limit, csSize - limit);
			if ( index >= 0 )
			{
				// found!, only update limit
				limit = index + 1;
			}
			else
			{
				// not found, add to result and update limit
				*pout++ = elem;
				limit = -(index + 1);
			}
		}
		
		// swap adjust result size
		result->size = pout - result->elems;
	}
	
	// return result
	result->version++;
	return result;
}

CSet*
CSet_Union(CSet** csVector, int csCount, CSet* result)
{
	// shortcut
	if ( csCount == 0 )
		return CSet_Alloc(0);
	else if ( csCount == 1 )
	{
		if ( result != NULL )
			CSet_Copy(csVector[0], result);
		else
			result = CSet_AllocCopy(csVector[0]);
		
		return result;
	}
	
	// sort sets according to size
	CSet__SortSetsVector(csVector, csCount, FALSE);
	
	// use first (largest) set as a the candidate answer
	CSet_SortElements(csVector[0]);
	if ( result )
		CSet_Copy(csVector[0], result);
	else
		result = CSet_AllocCopy(csVector[0]);
	
	// union with non-first sets
	int			csIndex;
	CSet*		tmp = CSet_Alloc(0);
	for ( csIndex = 1 ; csIndex < csCount ; csIndex++ )
	{
		CSet*		cs = csVector[csIndex];
		int			csSize = cs != NULL ? cs->size : 0;
		
		// shortcut
		if ( result->size <= 0)
		{
			CSet_Copy(cs, result);
			continue;
		}
		if ( csSize <= 0 )
		{
			continue;
		}
		
		CSet_SortElements(cs);
		CSet_SortElements(result);
		
		// loop on elements in the cs
		int		limit = 0;
		T_ELEM	*p1, *pend = cs->elems + cs->size;
		T_ELEM	elem;
		for ( elem = *(p1 = cs->elems) ; p1 < pend ; elem = *++p1 )
		{
			// search for element
			int		index = CSet_MemberIndex(result, elem, limit, result->size - limit);
			if ( index >= 0 )
			{
				// found!, just update limit
				limit = index + 1;
			}
			else
			{
				// not found, add to tmp and only update limit
				CSet_AddElement(tmp, elem);
				limit = -(index + 1);
			}
		}
		
		// add collected elems (in tmp) back to result
		CSet_AddAllElements(result, tmp);
		CSet_Clear(tmp);
	}
	CSet_Free(tmp);
	
	// return result
	result->version++;
	return result;
}

int		
CSet__UnsignedIntCompare(const void* a, const void* b)
{
	return ( *(T_ELEM*)a - *(T_ELEM*)b );
}

int		
CSet__UnicharStringCompare(const void * a, const void * b)
{
	unichar		*s1 = *((unichar**)a);
	unichar		*s2 = *((unichar**)b);
	unichar		ch1 = *s1++;
	unichar		ch2 = *s2++;
	unsigned int delta;
	
	while ( ch1 && ch2 )
	{
		delta = ch1 - ch2;
		if ( delta )
			return delta;
		ch1 = *s1++;
		ch2 = *s2++;
	}
	if ( ch1 )
		return 1;
	else if ( ch2 )
		return -1;
	else
		return 0;
}

#ifdef CSET_FILE
void
CSet_Print(CSet* cs, FILE* f)
{
	fprintf(f,"{");
	T_ELEM		*p1, *pend = cs->elems + cs->size;
	int			index = 0;
	for ( p1 = cs->elems ; p1 < pend ; p1++, index++ )
	{
		if ( index >= 20 )
		{
			fprintf(f, "...");
			break;
		}

		if ( index )
			fprintf(f, ",");

		fprintf(f, "%d", *p1);
	}
	fprintf(f, "}");
}

#endif

