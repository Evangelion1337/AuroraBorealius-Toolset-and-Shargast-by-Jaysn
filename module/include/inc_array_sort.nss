//:://////////////////////////////////////////////
//:: Array sorting functions
//:: inc_array_sort
//:://////////////////////////////////////////////
/** @file
    A bunch of sorting functions for different
    data types.

    TMI may occur if attempting to sort too
    large arrays.
    For the quicksorts, 100 elements should always
    be safe. TMI becomes almost certain past 150 elements.
    The counting sort can handle 200 elements, with
    250 being near upper limit.
    It is not recommended that one directly use the
    insertion sort, but 50 elements are probably safe.

    Array implementation is assumed to follow
    certain constraints:
     - Array elements begin at index 0
     - The value returned by the function to get
       array size returns the number of elements
       in the array.
     - The index of the last element in the array
       is the number of elements - 1.
     - Array reads change no stored data
     - Array writes are allowed to write over
       existing entries.

    @author Ornedan
    @data   Created 2006.05.27
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

/// At a certain point when the sort range is small enough, the overhead of quicksort exceeds
/// the higher order of efficiency in comparison to insertion sort, which has minimal overhead,
/// but still decent performance. At that point, switch to insertion sort.
const int QUICKSORT_TO_INSERTIONSORT_TRESHOLD = 6; // Anything betweem 4 - 10 seems to work. 6 was best in testing with randomly created arrays


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Implements a quicksort for integers. The array given for sorting should only contain
 * integer elements. Sane results not guaranteed otherwise.
 *
 * @param oStore     The object the array to sort is stored on
 * @param sArrayName The name of the array to sort
 *
 * @param nLower The lower sort bound. Set by the function itself to 0 for recursive calls if
 *               left to default value (-1).
 * @param nUpper The upper sort bound. Set by the function itself to array size - 1 for recursive
 *               calls if left to default value (-1).
 */
void QuickSortInt(object oStore, string sArrayName, int nLower = -1, int nUpper = -1);

/**
 * Implements a quicksort for floating point numbers. The array given for sorting should only contain
 * float elements. Sane results not guaranteed otherwise.
 *
 * @param oStore     The object the array to sort is stored on
 * @param sArrayName The name of the array to sort
 *
 * @param nLower The lower sort bound. Set by the function itself to 0 for recursive calls if
 *               left to default value (-1).
 * @param nUpper The upper sort bound. Set by the function itself to array size - 1 for recursive
 *               calls if left to default value (-1).
 */
void QuickSortFloat(object oStore, string sArrayName, int nLower = -1, int nUpper = -1);

/**
 * Implements an insertion sort for integers. The array given for sorting should only contain
 * integer elements. Sane results not guaranteed otherwise.
 *
 * @param oStore     The object the array to sort is stored on
 * @param sArrayName The name of the array to sort
 *
 * @param nLower The lower sort bound. Set by the function itself to 0 for recursive calls if
 *               left to default value (-1).
 * @param nUpper The upper sort bound. Set by the function itself to array size - 1 for recursive
 *               calls if left to default value (-1).
 */
void InsertionSortInt(object oStore, string sArrayName, int nLower = -1, int nUpper = -1);

/**
 * Implements an insertion sort for floating point numbers. The array given for sorting should only contain
 * float elements. Sane results not guaranteed otherwise.
 *
 * @param oStore     The object the array to sort is stored on
 * @param sArrayName The name of the array to sort
 *
 * @param nLower The lower sort bound. Set by the function itself to 0 for recursive calls if
 *               left to default value (-1).
 * @param nUpper The upper sort bound. Set by the function itself to array size - 1 for recursive
 *               calls if left to default value (-1).
 */
void InsertionSortFloat(object oStore, string sArrayName, int nLower = -1, int nUpper = -1);

/**
 * Implements counting sort for integers. The array given for sorting should only contain
 * integer elements. Sane results not guaranteed otherwise.
 *
 * @param oStore     The object the array to sort is stored on
 * @param sArrayName The name of the array to sort
 */
void CountingSortInt(object oStore, string sArrayName);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "prc_inc_array"
#include "inc_debug"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

/** Internal function.
 * Shuffles elements around until they are a bit more in order.
 *
 * @param oStore     The object the array to sort is stored on
 * @param sArrayName The name of the array to sort
 * @param nLower     The lower sort bound of the range to sort.
 * @param nUpper     The upper sort bound of the range to sort.
 * @return           The array index around which the array has been "sorted".
 */
int _inc_array_sort_PartitionInt(object oStore, string sArrayName, int nLower, int nUpper)
{
	int nDivider, nSwap;

	// Attempt to determine the median of the values in the array positions nLower, nMid and nUpper
	int nLowerVal = array_get_int(oStore, sArrayName, nLower),
	    nMidVal   = array_get_int(oStore, sArrayName, (nLower + nUpper) / 2),
	    nUpperVal = array_get_int(oStore, sArrayName, nUpper);
	if(nLowerVal < nMidVal)
	{
		if(nLowerVal < nUpperVal)  nDivider = (nMidVal < nUpperVal) ? nMidVal : nUpperVal;
		else                       nDivider = nLowerVal;
	}
	else if(nLowerVal < nUpperVal) nDivider = nLowerVal;
	else                           nDivider = (nMidVal > nUpperVal) ? nMidVal : nUpperVal;

	// Loop to sort the array around the median value
	nLower -= 1; nUpper += 1; // Hack - The loops below need to be pre-increment, so we need to move the index variables to make the first elements examined be the ones at the original values
	while(TRUE)
	{
		while(array_get_int(oStore, sArrayName, ++nLower) < nDivider) {} // Seek an element in the lower range of the array that is lesser than the divider
		while(array_get_int(oStore, sArrayName, --nUpper) > nDivider) {} // Seek an element in the upper range of the array that is greater than the divider
		// If the indexes haven't passed each other yet, swap the elements
		if(nLower < nUpper)
		{
			nSwap = array_get_int(oStore, sArrayName, nLower);
			array_set_int(oStore, sArrayName, nLower, array_get_int(oStore, sArrayName, nUpper));
			array_set_int(oStore, sArrayName, nUpper, nSwap);
		}
		// Otherwise, the array is now arranged so that all elements at positions nUpper and higher are greater than or equal to the
		// elements lower in the array
		else
			return nUpper;
	}

	// Never going to reach here, but compiler can't figure that out :P
	Assert(FALSE, "FALSE", "Execution reached code that shouldn't be reachable", "inc_array_sort", "_inc_arrays_sort_PartitionInt");
	return -1;
}

/** Internal function.
 * Shuffles elements around until they are a bit more in order.
 *
 * @param oStore     The object the array to sort is stored on
 * @param sArrayName The name of the array to sort
 * @param nLower     The lower sort bound of the range to sort.
 * @param nUpper     The upper sort bound of the range to sort.
 * @return           The array index around which the array has been "sorted".
 */
int _inc_array_sort_PartitionFloat(object oStore, string sArrayName, int nLower, int nUpper)
{
	float fDivider, fSwap;

	// Attempt to determine the median of the values in the array positions nLower, nMid and nUpper
	float fLowerVal = array_get_float(oStore, sArrayName, nLower),
	      fMidVal   = array_get_float(oStore, sArrayName, (nLower + nUpper) / 2),
	      fUpperVal = array_get_float(oStore, sArrayName, nUpper);
	if(fLowerVal < fMidVal)
	{
		if(fLowerVal < fUpperVal)  fDivider = (fMidVal < fUpperVal) ? fMidVal : fUpperVal;
		else                       fDivider = fLowerVal;
	}
	else if(fLowerVal < fUpperVal) fDivider = fLowerVal;
	else                           fDivider = (fMidVal > fUpperVal) ? fMidVal : fUpperVal;

	// Loop to sort the array around the median value
	nLower -= 1; nUpper += 1; // Hack - The loops below need to be pre-increment, so we need to move the index variables to make the first elements examined be the ones at the original values
	while(TRUE)
	{
		while(array_get_float(oStore, sArrayName, ++nLower) < fDivider) {} // Seek an element in the lower range of the array that is lesser than the divider
		while(array_get_float(oStore, sArrayName, --nUpper) > fDivider) {} // Seek an element in the upper range of the array that is greater than the divider
		// If the indexes haven't passed each other yet, swap the elements
		if(nLower < nUpper)
		{
			fSwap = array_get_float(oStore, sArrayName, nLower);
			array_set_float(oStore, sArrayName, nLower, array_get_float(oStore, sArrayName, nUpper));
			array_set_float(oStore, sArrayName, nUpper, fSwap);
		}
		// Otherwise, the array is now arranged so that all elements at positions nUpper and higher are greater than or equal to the
		// elements lower in the array
		else
			return nUpper;
	}

	// Never going to reach here, but compiler can't figure that out :P
	Assert(FALSE, "FALSE", "Execution reached code that shouldn't be reachable", "inc_array_sort", "_inc_array_sort_PartitionFloat");
	return -1;
}


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

void QuickSortInt(object oStore, string sArrayName, int nLower = -1, int nUpper = -1)
{
	// If range limits are not given, initialise them to defaults
	if(nLower == -1) nLower = 0;
	if(nUpper == -1) nUpper = array_get_size(oStore, sArrayName) - 1;

	// See if we have reached the point when quicksort becomes less efficient than insertion sort.
	if((nUpper - nLower) <= QUICKSORT_TO_INSERTIONSORT_TRESHOLD)
		InsertionSortInt(oStore, sArrayName, nLower, nUpper);
	else
	{
		// Move entries into a slightly more sorted order by arranging them around a median value
		// nDivider is the position of the beginning of the range where all the elements are
		// greater or equal to the median used
		int nDivider = _inc_array_sort_PartitionInt(oStore, sArrayName, nLower, nUpper);

		// Recurse into the halves of the array generated by the above sorting
		QuickSortInt(oStore, sArrayName, nLower, nDivider);
		QuickSortInt(oStore, sArrayName, nDivider + 1, nUpper);
	}
}

void QuickSortFloat(object oStore, string sArrayName, int nLower = -1, int nUpper = -1)
{
	// If range limits are not given, initialise them to defaults
	if(nLower == -1) nLower = 0;
	if(nUpper == -1) nUpper = array_get_size(oStore, sArrayName) - 1;

	// See if we have reached the point when quicksort becomes less efficient than insertion sort.
	if((nUpper - nLower) <= QUICKSORT_TO_INSERTIONSORT_TRESHOLD)
		InsertionSortFloat(oStore, sArrayName, nLower, nUpper);
	else
	{
		// Move entries into a slightly more sorted order by arranging them around a median value
		// nDivider is the position of the beginning of the range where all the elements are
		// greater or equal to the median used
		int nDivider = _inc_array_sort_PartitionFloat(oStore, sArrayName, nLower, nUpper);

		// Recurse into the halves of the array generated by the above sorting
		QuickSortFloat(oStore, sArrayName, nLower, nDivider);
		QuickSortFloat(oStore, sArrayName, nDivider + 1, nUpper);
	}
}

void InsertionSortInt(object oStore, string sArrayName, int nLower = -1, int nUpper = -1)
{
	// If range limits are not given, initialise them to defaults
	if(nLower == -1) nLower = 0;
	if(nUpper == -1) nUpper = array_get_size(oStore, sArrayName) - 1;

	// Some variables
	int i, nSwap;

	// Run the insertion sort loop
	for(nLower += 1; nLower <= nUpper; nLower++)
	{
		// Store current entry in temporary variable
		nSwap = array_get_int(oStore, sArrayName, nLower);

		// Move preceding elements forward by one until we encounter index 0 or an element <= nSwap,
		// whereupon we insert the swapped out element
		i = nLower;
		while(i > 0 && array_get_int(oStore, sArrayName, i - 1) > nSwap)
		{
			array_set_int(oStore, sArrayName, i,
			              array_get_int(oStore, sArrayName, i - 1)
			              );
			i--;
		}

		// Insert the swapped out element at the position where all elements with index less than it's are lesser than or equal to it
		array_set_int(oStore, sArrayName, i, nSwap);
	}
}

void InsertionSortFloat(object oStore, string sArrayName, int nLower = -1, int nUpper = -1)
{
	// If range limits are not given, initialise them to defaults
	if(nLower == -1) nLower = 0;
	if(nUpper == -1) nUpper = array_get_size(oStore, sArrayName) - 1;

	// Some variables
	int i;
	float fSwap;

	// Run the insertion sort loop
	for(nLower += 1; nLower <= nUpper; nLower++)
	{
		// Store current entry in temporary variable
		fSwap = array_get_float(oStore, sArrayName, nLower);

		// Move preceding elements forward by one until we encounter index 0 or an element <= nSwap,
		// whereupon we insert the swapped out element
		i = nLower;
		while(i > 0 && array_get_float(oStore, sArrayName, i - 1) > fSwap)
		{
			array_set_float(oStore, sArrayName, i,
			                array_get_float(oStore, sArrayName, i - 1)
			                );
			i--;
		}

		// Insert the swapped out element at the position where all elements with index less than it's are lesser than or equal to it
		array_set_float(oStore, sArrayName, i, fSwap);
	}
}

void CountingSortInt(object oStore, string sArrayName)
{
    int nMin = 0, nMax = 0,
        nCount = 0,
        i, size = array_get_size(oStore, sArrayName),
        nTemp;

    /* Find the least and greatest elements of the array */
    for(i = 0; i < size; i++)
    {
        nTemp = array_get_int(oStore, sArrayName, i);
        if(nTemp < nMin) nMin = nTemp;
        if(nTemp > nMax) nMax = nTemp;
    }

    // Create temporary array
    string sTempArray = "_CSort";
    while(array_exists(oStore, sTempArray)) sTempArray += "_";
    array_create(oStore, sTempArray);

    // Get the amount of each number in the array
    for(i = 0; i < size; i++)
    {
        nTemp = array_get_int(oStore, sArrayName, i) - nMin;
        array_set_int(oStore, sTempArray, nTemp, array_get_int(oStore, sTempArray, nTemp) + 1);
    }

    // Set the values in the sortable array
    size = array_get_size(oStore, sTempArray);
    for(i = 0; i < size; i++)
    {
        while(array_get_int(oStore, sTempArray, i) > 0)
        {
            array_set_int(oStore, sArrayName, nCount++, i + nMin);
            array_set_int(oStore, sTempArray, i, array_get_int(oStore, sTempArray, i) - 1);
        }
    }

    // Delete the temporary array
    array_delete(oStore, sTempArray);
}


// Test main
//void main(){}
