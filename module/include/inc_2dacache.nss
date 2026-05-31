/** @file
 * Caching 2da read function and related.
 *
 * SQL/NWNx functions now in inc_sql
 * @author Primogenitor
 *
 * @todo Document the constants and functions
 */

const int DEBUG_GET2DACACHE = FALSE;

string Get2DACache(string s2DA, string sColumn, int nRow);

string GetBiowareDBName();

//////////////////////////////////////////////////
/* Include section                              */
//////////////////////////////////////////////////

#include "inc_debug"
//#include "prc_inc_switch"

//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

/*
This is fugly and long. Should maybe be refactored to multiple functions. But everything inline does give
a few less instructions used.

Caching behaviour: Tokens in creature inventory
*/
string Get2DACache(string s2DA, string sColumn, int nRow)
{
    //lower case the 2da and column
    s2DA = GetStringLowerCase(s2DA);
    sColumn = GetStringLowerCase(sColumn);

    /*//get the chest that contains the cache
    object oCacheWP = GetObjectByTag("Bioware2DACache");
    //if no chest, use HEARTOFCHAOS in limbo as a location to make a new one
    if (!GetIsObjectValid(oCacheWP))
    {
        if(DEBUG_GET2DACACHE) DoDebug("Get2DACache: Cache container creature does not exist, creating new one");
        //oCacheWP = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_chest2",
        //    GetLocation(GetObjectByTag("HEARTOFCHAOS")), FALSE, "Bioware2DACache");
        //has to be a creature, placeables cant go through the DB
        oCacheWP = CreateObject(OBJECT_TYPE_CREATURE, "prc_2da_cache",
                                GetLocation(GetObjectByTag("HEARTOFCHAOS")), FALSE, "Bioware2DACache");
    }

    //get the token for this file
    string sFileWPName = s2DA + "_" + sColumn + "_" + IntToString(nRow / 1000);
    //if(DEBUG_GET2DACACHE) DoDebug("Get2DACache: Token tag is " + sFileWPName);
    object oFileWP = GetObjectByTag(sFileWPName);
    //token doesnt exist make it
    if(!GetIsObjectValid(oFileWP))
    {
        if(DEBUG_GET2DACACHE) DoDebug("Get2DACache: Token does not exist, creating new one");

        // Use containers to avoid running out of inventory space
        int nContainer = 0;
        string sContainerName = "Bio2DACacheTokenContainer_" + GetSubString(s2DA, 0, 1) + "_";
        object oContainer     = GetObjectByTag(sContainerName + IntToString(nContainer));

        // Find last existing container
        if(GetIsObjectValid(oContainer))
        {
            if(DEBUG_GET2DACACHE) DoDebug("Get2DACache: Seeking last container in series: " + sContainerName);
            // find the last container
            nContainer = GetLocalInt(oContainer, "ContainerCount");
            oContainer = GetObjectByTag(sContainerName + IntToString(nContainer));

            if(DEBUG_GET2DACACHE) DoDebug("Get2DACache: Found: " + DebugObject2Str(oContainer));

            // Make sure it's not full
            if(GetLocalInt(oContainer, "NumTokensInside") >= 34) // Container has 35 slots. Attempt to not use them all, just in case
            {
                if(DEBUG_GET2DACACHE) DoDebug("Get2DACache: Container full: " + DebugObject2Str(oContainer));
                oContainer = OBJECT_INVALID;
                ++nContainer; // new container is 1 higher than last one
            }
        }
        // We need to create a container
        if(!GetIsObjectValid(oContainer))
        {
            if(DEBUG_GET2DACACHE) DoDebug("Get2DACache: Creating new container");

            oContainer = CreateObject(OBJECT_TYPE_ITEM, "nw_it_contain001", GetLocation(oCacheWP), FALSE, sContainerName + IntToString(nContainer));
            DestroyObject(oContainer);
            oContainer = CopyObject(oContainer, GetLocation(oCacheWP), oCacheWP, sContainerName + IntToString(nContainer));
            // store the new number of containers in this series
            if (nContainer)
                SetLocalInt( GetObjectByTag(sContainerName + "0"), "ContainerCount", nContainer);
            // else this is the first container - do nothing as this is the same as storing 0 on it.
            // Also here we still have 2 objects with the same tag so above code may get
            // the object destroyed at the end of the function if this is the first container.
        }

        if(DEBUG_GET2DACACHE) DoDebug("Get2DACache: Using container: " + DebugObject2Str(oContainer));

        // Create the new token
        //oFileWP = CreateObject(OBJECT_TYPE_ITEM, "hidetoken", GetLocation(oCacheWP), FALSE, sFileWPName);
        //DestroyObject(oFileWP);
        //oFileWP = CopyObject(oFileWP, GetLocation(oCacheWP), oCacheWP, sFileWPName);
        oFileWP = CreateItemOnObject("hidetoken", oContainer, 1, sFileWPName);

        //SetName(oFileWP, "2da Cache - " + sFileWPName);

        // Increment token count tracking variable
        SetLocalInt(oContainer, "NumTokensInside", GetLocalInt(oContainer, "NumTokensInside") + 1);
    }

    // get the value from the cache
    string s = GetLocalString(oFileWP, s2DA+"|"+sColumn+"|"+IntToString(nRow));
    //entry didnt exist in the cache
    if(s == "")
    {
        //fetch from the 2da file
        s = Get2DAString(s2DA, sColumn, nRow);

        // store it on the waypoint
        SetLocalString(oFileWP, s2DA+"|"+sColumn+"|"+IntToString(nRow),
                       (s == "" ? "****" : s) ); // this sets the stored string to "****" if s is an empty string (else stores s)
        if(DEBUG_GET2DACACHE) DoDebug("Get2DACache: Missing from cache: " + s2DA + "|" + sColumn + "|" + IntToString(nRow));
    }
    //if(DEBUG_GET2DACACHE) PrintString("Get2DACache: Returned value is '" + s + "'");*/
    string s = Get2DAString(s2DA, sColumn, nRow);
    return s == "****" ? "" : s;
}

string GetBiowareDBName()
{
    string sReturn;
    sReturn = "prc_data";
    //if(GetPRCSwitch(MARKER_PRC_COMPANION))
    //    sReturn += "cp";
    if(GetPRCSwitch(MARKER_CEP1))
        sReturn += "c1";
    if(GetPRCSwitch(MARKER_CEP2))
        sReturn += "c2";
    if(GetPRCSwitch(MARKER_Q))
        sReturn += "q";
    return sReturn;
}

/**
 * Gets the file end for the given 2da.
 *
 * @param sTable    The 2da to get the file end for
 * @return          The file end value of the 2da.
 */
int PRCGetFileEnd(string sTable)
{
    sTable = GetStringLowerCase(sTable);
    return GetPRCSwitch("PRC_FILE_END_" + sTable);
/*   //check fileends.2da first
    int nEnd = StringToInt(Get2DACache("fileends", sTable, 0));

    //still nothing - check 
    if(!nEnd) nEnd = StringToInt(Get2DACache("fileends", GetStringLeft(sTable, 8)+"*", 0));

    return nEnd;*/
}

/**
 * Gets the file end for special PRC files - used in new spellbook system.
 *
 * cls_psipw_*
 * cls_move_*
 * cls_true_*
 * cls_inv_*
 * cls_spell_*
 *
 * @param sTable    The 2da to get the file end for
 * @return          The file end value of the 2da.
 */
int PRCGetDynamicFileEnd(string sTable)
{
    int nRet = StringToInt(Get2DACache(sTable, "label", 0));
    if(!nRet)
    {
        if (DEBUG) DoDebug("FileEnd for "+sTable+" not found! Using default value.");
        nRet = 2720;
    }
    return nRet;
}

//Cache setup functions moved to inc_cache_setup
