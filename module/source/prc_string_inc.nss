//::///////////////////////////////////////////////
//:: String Util
//:: prc_string_inc
//:://////////////////////////////////////////////
/*
    A util class for providing useful string functions.
*/
//:://////////////////////////////////////////////
//:: Created By: Rakiov
//:: Created On: 22.05.2005
//:://////////////////////////////////////////////

#include "inc_utility"

//
// StringSplit
// Takes a string and splits it by " " into a json list of strings
// i.e. "this   is a test" returns
// {
//   "this",
//   "is",
//   "a",
//   "test"
// }
//
// Parameters:
//   string input the string input
//
// Returns:
//   json the json list of words
//
json StringSplit(string input);

json StringSplit(string input)
{
    json retValue = JsonArray();

    string subString = "";
    //trim any whitespace characters first
    string currString = PRCTrimString(input);

    // loop until we process the whole string
    while(currString != "")
    {
        string currChar = GetStringLeft(currString, 1);
        if (currChar != "" && currChar != " ")
        {
            // if the current character isn't nothing or whitespace, then add it
            // to the current sub string.
            subString += currChar;
        }
        else
        {
            // otherwise if the substring is not empty, then add it to the list
            // of words to return
            if(subString != "")
            {
                retValue = JsonArrayInsert(retValue, JsonString(subString));
                subString = "";
            }
        }

        // pop and move to next character
        currString = GetStringRight(currString, GetStringLength(currString)-1);
    }

    // if there is any sub string left at the end of the loop, add it to the list
    if(subString != "")
    {
        retValue = JsonArrayInsert(retValue, JsonString(subString));
    }

    return retValue;
}
