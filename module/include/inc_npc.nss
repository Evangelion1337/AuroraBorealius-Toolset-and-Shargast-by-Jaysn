//::///////////////////////////////////////////////
//:: NPC associate include
//:: inc_npc
//:://////////////////////////////////////////////
/*
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//:: Levels up an NPC according to variables set on NPC.
void LevelUpSummon(object oSummon, int iTargetLvl);
 
// Get the master of oAssociate.
object GetMasterNPC(object oAssociate0 = OBJECT_SELF);

// Returns the associate type of the specified creature.
// - Returns ASSOCIATE_TYPE_NONE if the creature is not the associate of anyone.
int GetAssociateTypeNPC( object oAssociate );

// Get the henchman belonging to oMaster.
// * Return OBJECT_INVALID if oMaster does not have a henchman.
// -nNth: Which henchman to return.
object GetHenchmanNPC(object oMaster=OBJECT_SELF,int nNth=1);

// Get the associate of type nAssociateType belonging to oMaster.
// - nAssociateType: ASSOCIATE_TYPE_*
// - nMaster
// - nTh: Which associate of the specified type to return
// * Returns OBJECT_INVALID if no such associate exists.
object GetAssociateNPC(int nAssociateType, object oMaster=OBJECT_SELF, int nTh=1);

// Returns TRUE if the specified condition flag is set on
// the associate.
int GetAssociateStateNPC(int nCondition, object oAssoc=OBJECT_SELF);

// Determine if this henchman is currently dying
int GetIsHenchmanDyingNPC(object oHench=OBJECT_SELF);

// Determine if Should I Heal My Master
int GetAssociateHealMasterNPC();

// Create the next AssociateType creature
object CreateLocalNextNPC(object oMaster,int nAssociateType,string sTemplate,location loc,string sTag="");

// Create a AssociateType creature
object CreateLocalNPC(object oMaster,int nAssociateType,string sTemplate,location loc,int Nth=1,string sTag="");


#include "prc_inc_function"
#include "x0_i0_assoc"

void SetLocalNPC(object oMaster,object oAssociate,int nAssociateType ,int nNth=1)
{
  SetLocalObject(oAssociate, "oMaster", oMaster);
  SetLocalInt(oAssociate, "iAssocType", nAssociateType);
  SetLocalObject(oMaster, IntToString(nAssociateType)+"oHench"+IntToString(nNth), oAssociate);
  SetLocalInt(oAssociate, "iAssocNth", nNth);

}

void DeleteLocalNPC(object oAssociate=OBJECT_SELF)
{
   int nType = GetLocalInt(oAssociate, "iAssocType");
   object oMaster = GetMasterNPC(oAssociate);
   int Nth = GetLocalInt(oAssociate, "iAssocNth");

   DeleteLocalInt(oMaster, IntToString(nType)+"oHench"+IntToString(Nth));
   DeleteLocalInt(oAssociate, "iAssocNth");
   DeleteLocalObject(oAssociate, "oMaster");
   DeleteLocalInt(oAssociate, "iAssocType");
}

void DestroySummon(object oSummon)
{
   effect eVis = EffectVisualEffect(VFX_IMP_UNSUMMON);
   ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eVis, GetLocation(oSummon));
   DeleteLocalNPC(oSummon);
   DestroyObject(oSummon);
}

object CreateLocalNPC(object oMaster,int nAssociateType,string sTemplate,location loc,int Nth=1,string sTag="")
{
     object oSummon=CreateObject(OBJECT_TYPE_CREATURE,sTemplate,loc,FALSE,sTag);

     SetLocalNPC(oMaster,oSummon,nAssociateType ,Nth);
     SetAssociateState(NW_ASC_HAVE_MASTER,TRUE,oSummon);
     SetAssociateState(NW_ASC_DISTANCE_2_METERS);
     SetAssociateState(NW_ASC_DISTANCE_4_METERS, FALSE);
     SetAssociateState(NW_ASC_DISTANCE_6_METERS, FALSE);

     if (nAssociateType == ASSOCIATE_TYPE_FAMILIAR) SetLocalInt(oMaster, "FamiliarToTheDeath", 100);
     if (nAssociateType == ASSOCIATE_TYPE_ANIMALCOMPANION) SetLocalInt(oMaster, "AniCompToTheDeath", 100);

     effect eVis = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD);
     ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetLocation(oSummon));

     return oSummon;
}

object CreateLocalNextNPC(object oMaster,int nAssociateType,string sTemplate,location loc,string sTag="")
{
  object oSummon=CreateObject(OBJECT_TYPE_CREATURE,sTemplate,loc,FALSE,sTag);
  int nCount=1;

  while (GetIsObjectValid(GetAssociateNPC(ASSOCIATE_TYPE_SUMMONED,OBJECT_SELF,nCount)))
  {
    nCount++;
    SendMessageToPC(OBJECT_SELF," nCount:"+IntToString(nCount));
  }

  SetLocalObject(oSummon, "oMaster", oMaster);
  SetLocalInt(oSummon, "iAssocType", nAssociateType);
  SetLocalObject(oMaster, IntToString(nAssociateType)+"oHench"+IntToString(nCount), oSummon);
  SetLocalInt(oSummon, "iAssocNth", nCount);

  SetAssociateState(NW_ASC_HAVE_MASTER, TRUE, oSummon);
  SetAssociateState(NW_ASC_DISTANCE_2_METERS);
  SetAssociateState(NW_ASC_DISTANCE_4_METERS, FALSE);
  SetAssociateState(NW_ASC_DISTANCE_6_METERS, FALSE);

  if (nAssociateType ==ASSOCIATE_TYPE_FAMILIAR) SetLocalInt(oMaster, "FamiliarToTheDeath", 100);
  if (nAssociateType ==ASSOCIATE_TYPE_ANIMALCOMPANION) SetLocalInt(oMaster, "AniCompToTheDeath", 100);

  return oSummon;

}

object GetMasterNPC(object oAssociate=OBJECT_SELF)
{
   object oMaster = GetLocalObject(oAssociate, "oMaster");

   if (GetIsObjectValid(oMaster))
     return oMaster;
   else
     return GetMaster(oAssociate);
}

int GetAssociateTypeNPC( object oAssociate )
{
    int iType = GetLocalInt(oAssociate, "iAssocType");
    if (iType)
      return iType;
    else
      return GetAssociateType(oAssociate);
}

object GetHenchmanNPC(object oMaster=OBJECT_SELF,int nNth=1)
{
   object oAssociate = GetLocalObject(oMaster,IntToString(ASSOCIATE_TYPE_HENCHMAN)+"oHench"+IntToString(nNth));

   if (GetIsObjectValid(oAssociate))
     return oAssociate;
   else
     return GetHenchman(oMaster,nNth);
}

object GetAssociateNPC(int nAssociateType, object oMaster=OBJECT_SELF, int nTh=1)
{
   object oAssociate = GetLocalObject(oMaster,IntToString(nAssociateType)+"oHench"+IntToString(nTh));

   if (GetIsObjectValid(oAssociate))
     return oAssociate;
   else
     return GetAssociate(nAssociateType,oMaster,nTh);
}

int GetAssociateStateNPC(int nCondition, object oAssoc=OBJECT_SELF)
{
    //SpawnScriptDebugger();

    if(nCondition == NW_ASC_HAVE_MASTER)
    {
        if(GetIsObjectValid(GetMasterNPC(oAssoc)))
            return TRUE;
    }
    else
    {
        int nPlot = GetLocalInt(oAssoc, sAssociateMasterConditionVarname);

        if(nPlot & nCondition)
            return TRUE;
    }
    return FALSE;
}

int GetIsHenchmanDyingNPC(object oHench=OBJECT_SELF)
{
    int bHenchmanDying = GetAssociateStateNPC(NW_ASC_MODE_DYING, oHench);

    if (bHenchmanDying == TRUE)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

int GetAssociateHealMasterNPC()
{
    if(GetAssociateStateNPC(NW_ASC_HAVE_MASTER))
    {
        object oMaster = GetMasterNPC();
        int nLoss = GetPercentageHPLoss(oMaster);

        if(!GetIsDead(oMaster))
        {
            if(GetAssociateStateNPC(NW_ASC_HEAL_AT_75) && nLoss <= 75)
            {
                return TRUE;
            }
            else if(GetAssociateStateNPC(NW_ASC_HEAL_AT_50) && nLoss <= 50)
            {
                return TRUE;
            }
            else if(GetAssociateStateNPC(NW_ASC_HEAL_AT_25) && nLoss <= 25)
            {
                return TRUE;
            }
        }
    }
    return FALSE;
}

/**
 * @brief Levels up a summoned creature based on its master's total casting level,
 *        while respecting configured HD limits and multiclass transition rules.
 *		  Should only be called on the NPC onSpawn event.
 *
 * This function:
 *  - Retrieves the master’s total casting level and clamps it to the creature’s
 *    minimum and maximum HD (iMinHD, iMaxHD).
 *  - Repeatedly calls LevelUpHenchman() until the creature reaches that level,
 *    switching classes when the creature's stored "ClassXStart" thresholds are met.
 *
 * Local variables recognized on the summoned creature:
 *
 * | Variable Name   | Purpose                                                     |
 * |-----------------|-------------------------------------------------------------|
 * | iMinHD          | Minimum HD allowed                                          |
 * | iMaxHD          | Maximum HD allowed                                          |
 * | Class2Start     | Level to begin second class progression                     |
 * | Class2          | Class type for second progression                           |
 * | Class2Package   | Package for second progression                              |
 * | Class3Start     | Level to begin third class progression                      |
 * | Class3          | Class type for third progression                            |
 * | Class3Package   | Package for third progression                               |
 * | Class4Start     | Level to begin fourth class progression                     |
 * | Class4          | Class type for fourth progression                           |
 * | Class4Package   | Package for fourth progression                              |
 *
 * Behavior notes:
 *  - Leveling continues until the creature reaches the master’s effective
 *    casting level (bounded by iMinHD/iMaxHD).
 *  - If LevelUpHenchman() returns 0, the creature shouts a failure message.
 *  - CLASS_TYPE_INVALID causes the creature to level in its current class.
 *
 * @param oCreature The summoned creature being leveled. Defaults to OBJECT_SELF.
 *
 * @see LevelUpHenchman
 * @see GetLocalInt
 * @see GetHitDice
 */
void LevelUpSummon(object oSummon, int iTargetLvl)
{
    int nCurrentHD = GetHitDice(oSummon);
    int iNewHD = nCurrentHD;

    // Read multiclassing info from locals
    int iClass2Start   = GetLocalInt(oSummon, "Class2Start");
    int iClass2        = GetLocalInt(oSummon, "Class2");
    int iClass2Package = GetLocalInt(oSummon, "Class2Package");

    int iClass3Start   = GetLocalInt(oSummon, "Class3Start");
    int iClass3        = GetLocalInt(oSummon, "Class3");
    int iClass3Package = GetLocalInt(oSummon, "Class3Package");

    int iClass4Start   = GetLocalInt(oSummon, "Class4Start");
    int iClass4        = GetLocalInt(oSummon, "Class4");
    int iClass4Package = GetLocalInt(oSummon, "Class4Package");

    int iClass;      // current class to level
    int iPackage;    // package to use

    // Main leveling loop
    while (nCurrentHD < iTargetLvl && nCurrentHD > 0)
    {
        // Determine which class and package to use
        if (iClass4Start != 0 && nCurrentHD >= iClass4Start)
        {
            iClass = iClass4;
            iPackage = iClass4Package;
        }
        else if (iClass3Start != 0 && nCurrentHD >= iClass3Start)
        {
            iClass = iClass3;
            iPackage = iClass3Package;
        }
        else if (iClass2Start != 0 && nCurrentHD >= iClass2Start)
        {
            iClass = iClass2;
            iPackage = iClass2Package;
        }
        else
        {
            // Base class (first class in the sheet)
            iClass = CLASS_TYPE_INVALID;  // keeps current
            iPackage = PACKAGE_INVALID;
        }

        // Level up one HD
        iNewHD = LevelUpHenchman(oSummon, iClass, TRUE, iPackage);

        if (iNewHD == 0)
        {
            SpeakString(GetName(oSummon) + " failed to level properly!", TALKVOLUME_SHOUT);
            break;
        }

        nCurrentHD = iNewHD;
    }

    // Force the creature to rest to memorize spells
    // PRCForceRest(oSummon);

}


 
 
 
/*  void LevelUpSummon(object oSummon, int iTargetLvl)
{
	//get the default hit dice of the summon
	int nDefaultHD = GetHitDice(oSummon);
	
	if (DEBUG) DoDebug("inc_npc >> LevelUpSummon: nDefaultHD = " +IntToString(nDefaultHD)+".");
	
	if (DEBUG) DoDebug("inc_npc >> LevelUpSummon: iTargetLvl = " +IntToString(iTargetLvl)+".");

	//get the multiclassing variables to see if we need to change classes from its base class
	int iClass2Start 	= GetLocalInt(oSummon, "Class2Start");
	int iClass2			= GetLocalInt(oSummon, "Class2");
	int iClass2Package 	= GetLocalInt(oSummon, "Class2Package");

	int iClass3Start 	= GetLocalInt(oSummon, "Class3Start");
	int iClass3 		= GetLocalInt(oSummon, "Class3");
	int iClass3Package 	= GetLocalInt(oSummon, "Class3Package");
	
	int iClass4Start 	= GetLocalInt(oSummon, "Class4Start");
	int iClass4 		= GetLocalInt(oSummon, "Class4");
	int iClass4Package 	= GetLocalInt(oSummon, "Class4Package");	

	//check for zero cause thats an error
	//if creatures are not leveling then best bet is they are not legal creatures
	while( (nDefaultHD < iTargetLvl) && (nDefaultHD > 0) )
	{
		//check the multiclassing numbers to change classes
		if( (iClass4Start != 0) && (nDefaultHD >= iClass4Start) )
		{
			//level up using the new class and Packageage
			nDefaultHD = LevelUpHenchman(oSummon, iClass4 ,TRUE, iClass4Package);
			
			if(nDefaultHD == 0)
				SpeakString(GetName(oSummon) + " Failed on fourth class", TALKVOLUME_SHOUT);
		}		
		else if( (iClass3Start != 0) && (nDefaultHD >= iClass3Start) )
		{
			//level up using the new class and Packageage
			nDefaultHD = LevelUpHenchman(oSummon, iClass3 ,TRUE, iClass3Package);
			
			if(nDefaultHD == 0)
				SpeakString(GetName(oSummon) + " Failed on third class", TALKVOLUME_SHOUT);
		}
		else if( (iClass2Start != 0) && (nDefaultHD >= iClass2Start) )
		{
			//level up using the new class and Packageage
			nDefaultHD = LevelUpHenchman(oSummon, iClass2 ,TRUE, iClass2Package);
			
			if(nDefaultHD == 0)
				SpeakString(GetName(oSummon) + " Failed on second class", TALKVOLUME_SHOUT);
		}
		else
		{
			//just level up using the class it already has
			nDefaultHD = LevelUpHenchman(oSummon, CLASS_TYPE_INVALID ,TRUE);
			
			if(nDefaultHD == 0)
				SpeakString(GetName(oSummon) + " Failed to level properly", TALKVOLUME_SHOUT);
		}	
	}
}
 */
//:: void main() {}