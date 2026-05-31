//::///////////////////////////////////////////////
//:: Gatestones 1.6
//:: bpm_inc
//:: Copyright (c) 2006 CarfaxAbbey.net
//:://////////////////////////////////////////////
/*
    Include File and Function Library
*/
//:://////////////////////////////////////////////
//:: Created By: Diavlen <diavlen@carfaxabbey.net>
//:: Created On: 3/24/2004
//:: Updated on: 8/11/2006
//:://////////////////////////////////////////////
#include "prc_class_const"

// bpDEBUG - Generic function for universal debugging
void bpDEBUG(string sMessage);

// UMDCheck - Use Magic Device Returns True if player can use item with
//   suggested DC.
//   object oPC - The player doing the check
//   int nLevel - The appropriate caster level of the spell.
int UMDCheck(object oPC, int nSpellLevel, int nDCMod);

// Return a string value when given a location
string BPLocationToString(location lLocation);

// Return a location value when given the string form of the location
location BPStringToLocation(string sLocation);


void bpDEBUG(string sMessage) {
    // LogLevel 1   =   Timestamped log
    // LogLevel 2   =   DM Message
    int nLogLevel   =   1;
    SendMessageToAllDMs(sMessage);
    WriteTimestampedLogEntry("MTRX: " + sMessage);
}

int UMDCheck(object oPC, int nSpellLevel, int nDCMod)   
{
	  int iAllArcane	= GetLevelByClass(CLASS_TYPE_WIZARD, oPC)
						+ GetLevelByClass(CLASS_TYPE_SORCERER, oPC)
						+ GetLevelByClass(CLASS_TYPE_BARD, oPC)
						+ GetLevelByClass(CLASS_TYPE_DRAGONFIRE_ADEPT, oPC)
						+ GetLevelByClass(CLASS_TYPE_DRAGON_SHAMAN, oPC)			
						+ GetLevelByClass(CLASS_TYPE_DREAD_NECROMANCER, oPC)
						+ GetLevelByClass(CLASS_TYPE_BEGUILER, oPC)
						+ GetLevelByClass(CLASS_TYPE_SHADOWCASTER, oPC)
						+ GetLevelByClass(CLASS_TYPE_WARMAGE, oPC)
						+ GetLevelByClass(CLASS_TYPE_ASSASSIN, oPC)
						+ GetLevelByClass(CLASS_TYPE_CELEBRANT_SHARESS, oPC)
						+ GetLevelByClass(CLASS_TYPE_CULTIST_SHATTERED_PEAK, oPC)
						+ GetLevelByClass(CLASS_TYPE_DUSKBLADE, oPC)			
						+ GetLevelByClass(CLASS_TYPE_HARPER, oPC)
						+ GetLevelByClass(CLASS_TYPE_HEXBLADE, oPC)
						+ GetLevelByClass(CLASS_TYPE_KNIGHT_WEAVE, oPC)
						+ GetLevelByClass(CLASS_TYPE_SHADOWLORD, oPC)
						+ GetLevelByClass(CLASS_TYPE_SUBLIME_CHORD, oPC)
						+ GetLevelByClass(CLASS_TYPE_SUEL_ARCHANAMACH, oPC)				
						+ GetLevelByClass(CLASS_TYPE_WARLOCK, oPC);	
					
    int nIsWizard           =   iAllArcane;
    int nIsSorceror         =   iAllArcane;
    int nApproved           =   FALSE;

    // Spell DC is determined by:  SpellLevel + 10 * 1.5
    //int nDC                 =   FloatToInt((nSpellLevel + 10)*1.5)+nDCMod;
    int nMinCasterLevel     =   (nSpellLevel * 2)-1;
    int nDC                 =   20 + nMinCasterLevel;

    if (nIsWizard >= nMinCasterLevel) {
        nApproved   =   TRUE;
    }
    if ( (nIsSorceror >= nMinCasterLevel) && !nApproved )    {
        nApproved   =   TRUE;
    }

    if (GetHasSkill(SKILL_USE_MAGIC_DEVICE,oPC) && !nApproved)    {
        if(GetIsInCombat(oPC))
            nApproved   =   GetIsSkillSuccessful(oPC,SKILL_USE_MAGIC_DEVICE,nDC);
        else    {
            if( 20 + GetSkillRank(SKILL_USE_MAGIC_DEVICE,oPC) >= nDC )  {
                SendMessageToPC(oPC,"UMD: Success");
                nApproved   =   TRUE;
            }else{
                SendMessageToPC(oPC,"UMD: Failure");
                nApproved   =   FALSE;
            }
        }
    }
    // Debugging - 3/23/2004
    /*
    WriteTimestampedLogEntry("UMDCheck Debug");
    WriteTimestampedLogEntry("--------------------------------");
    WriteTimestampedLogEntry("   Script Name: bp_inc_lib");
    WriteTimestampedLogEntry("   PlayerName  : " + GetName(oPC) );
    WriteTimestampedLogEntry("   nMinCast    : " + IntToString(nMinCasterLevel) );
    WriteTimestampedLogEntry("   nDC         : " + IntToString(nDC) );
    WriteTimestampedLogEntry("   nDCMod      : " + IntToString(nDCMod) );
    WriteTimestampedLogEntry("   nIsWizard   : " + IntToString(nIsWizard) );
    WriteTimestampedLogEntry("   nIsSorceror : " + IntToString(nIsSorceror) );
    WriteTimestampedLogEntry("   nLevel      : " + IntToString(nSpellLevel) );
    WriteTimestampedLogEntry("   nApproved   : " + IntToString(nApproved) );
    WriteTimestampedLogEntry("--------------------------------");
    */
    return nApproved;
}



string BPLocationToString(location lLocation)   {
    object oArea        =   GetAreaFromLocation(lLocation);
    vector vPosition    =   GetPositionFromLocation(lLocation);
    float fOrientation  =   GetFacingFromLocation(lLocation);
    string sReturnValue;

    if (GetIsObjectValid(oArea))
        sReturnValue =
            "#AREA#" + GetTag(oArea) + "#POSITION_X#" + FloatToString(vPosition.x) +
            "#POSITION_Y#" + FloatToString(vPosition.y) + "#POSITION_Z#" +
            FloatToString(vPosition.z) + "#ORIENTATION#" + FloatToString(fOrientation) + "#END#";

    return sReturnValue;
}

location BPStringToLocation(string sLocation)   {
    location lReturnValue;
    object oArea;
    vector vPosition;
    float fOrientation, fX, fY, fZ;

    int iPos, iCount;
    int iLen = GetStringLength(sLocation);

    if (iLen > 0)   {
        iPos = FindSubString(sLocation, "#AREA#") + 6;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        oArea = GetObjectByTag(GetSubString(sLocation, iPos, iCount));

        iPos = FindSubString(sLocation, "#POSITION_X#") + 12;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        fX = StringToFloat(GetSubString(sLocation, iPos, iCount));

        iPos = FindSubString(sLocation, "#POSITION_Y#") + 12;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        fY = StringToFloat(GetSubString(sLocation, iPos, iCount));

        iPos = FindSubString(sLocation, "#POSITION_Z#") + 12;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        fZ = StringToFloat(GetSubString(sLocation, iPos, iCount));

        vPosition = Vector(fX, fY, fZ);

        iPos = FindSubString(sLocation, "#ORIENTATION#") + 13;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        fOrientation = StringToFloat(GetSubString(sLocation, iPos, iCount));

        lReturnValue = Location(oArea, vPosition, fOrientation);
    }

    return lReturnValue;
}

//:: void main (){}

