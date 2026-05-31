//::///////////////////////////////////////////////
//:: Turn undead include
//:: prc_inc_turning
//::///////////////////////////////////////////////
/** @file
    Defines functions that seem to have something
    to do with Turn Undead (and various other
    stuff).
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

#include "prc_spell_const"

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

//gets the number of class levels that count for turning
int GetTurningClassLevel(object oCaster = OBJECT_SELF, int nTurnType = SPELL_TURN_UNDEAD);

//Returns the turning charisma modifier of OBJECT_SELF
int GetTurningCharismaMod(int nTurnType);

//this adjusts the highest HD of undead turned
int GetTurningCheckResult(int nLevel, int nTurningCheck);

//gets the equivalent HD total for turning purposes
//includes turn resistance and SR for outsiders
int GetHitDiceForTurning(object oTarget, int nTurnType, int nTargetRace);

int GetCommandedTotalHD(int nTurnType = SPELL_TURN_UNDEAD, int bUndeadMastery = FALSE);

//various sub-turning effect funcions
void DoTurn(object oTarget);
void DoDestroy(object oTarget);
void DoRebuke(object oTarget);
void DoCommand(object oTarget);

// This uses the turn type to determine whether the target should be turned or rebuked
// Return values:
// 0 - target can not be turned/rebuked
// 1 - target can be rebuked
// 2 - target can be turned
int GetIsTurnOrRebuke(object oTarget, int nTurnType, int nTargetRace);

// What this does is check to see if there is an discrete word
// That matches the input, and if there is returns TRUE
// (please use sName string in lowercase)
int CheckTargetName(object oTarget, string sName);

int GetIsAirCreature(object oCreature, int nAppearance);
int GetIsEarthCreature(object oCreature, int nAppearance);
int GetIsFireCreature(object oCreature, int nAppearance);
int GetIsWaterCreature(object oCreature, int nAppearance);
int GetIsColdCreature(object oCreature, int nAppearance);
int GetIsReptile(object oCreature, int nAppearance);
int GetIsSpider(object oCreature, int nAppearance);

// Does the cold damage for this feat
void FaithInTheFrost(object oPC, object oTarget);

// Does the fire damage for this feat
void LightOfAurifar(object oPC, object oTarget);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "prc_inc_racial"
#include "inc_utility"
#include "bnd_inc_bndfunc"
#include "prc_inc_template"					  

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

const int ACTION_REBUKE = 1;
const int ACTION_TURN   = 2;

//private function
int GetIsTurnOrRebuke(object oTarget, int nTurnType, int nTargetRace)
{
    //is not an enemy
    if(GetIsFriend(oTarget)/* || GetFactionEqual(oTarget)*/)
        return FALSE;

    //already turned
    //NOTE: At the moment this breaks down in "turning conflicts" where clerics try to
    //turn each others undead. Fix later.
    //if(GetHasSpellEffect(nTurnType, oTarget))
    //    return FALSE;
    if(PRCGetHasEffect(EFFECT_TYPE_TURNED, oTarget))
        return FALSE;

    int nTargetAppearance = GetAppearanceType(oTarget);
    int nReturn = FALSE;

    switch(nTurnType)
    {
        case SPELL_TURN_UNDEAD:
        {
            if(nTargetRace == RACIAL_TYPE_UNDEAD)
            {
                // Evil clerics rebuke undead, otherwise turn
                // Dread Necro, True Necro and Master of Shrouds always rebuke or command
                if(GetAlignmentGoodEvil(OBJECT_SELF) == ALIGNMENT_EVIL
                || GetLevelByClass(CLASS_TYPE_DREAD_NECROMANCER)
                || GetLevelByClass(CLASS_TYPE_TRUENECRO)
                || GetLevelByClass(CLASS_TYPE_MASTER_OF_SHROUDS)
                || GetLevelByClass(CLASS_TYPE_NIGHTSTALKER) > 3)
                    nReturn = ACTION_REBUKE;
                else
                    nReturn = ACTION_TURN;
            }
            else if(nTargetRace == RACIAL_TYPE_OUTSIDER && GetHasFeat(FEAT_EPIC_PLANAR_TURNING))
            {
                // Evil clerics turn non-evil outsiders, and rebuke evil outsiders
                if(GetAlignmentGoodEvil(OBJECT_SELF) == ALIGNMENT_EVIL)
                {
                    if(GetAlignmentGoodEvil(oTarget) != ALIGNMENT_EVIL)
                         nReturn = ACTION_TURN;
                    else
                         nReturn = ACTION_REBUKE;
                }
                // Good clerics turn non-good outsiders, and rebuke good outsiders
                else
                {
                    if(GetAlignmentGoodEvil(oTarget) != ALIGNMENT_GOOD)
                        nReturn = ACTION_TURN;
                    else
                        nReturn = ACTION_REBUKE;
                }
            }
            break;
        }
        case SPELL_TURN_OUTSIDER:
        {
            if(nTargetRace == RACIAL_TYPE_OUTSIDER)
            {
                // Evil clerics turn non-evil outsiders, and rebuke evil outsiders
                if(GetAlignmentGoodEvil(OBJECT_SELF) == ALIGNMENT_EVIL)
                {
                    if(GetAlignmentGoodEvil(oTarget) != ALIGNMENT_EVIL)
                         nReturn = ACTION_TURN;
                    else
                         nReturn = ACTION_REBUKE;
                }
                // Good clerics turn non-good outsiders, and rebuke good outsiders
                else
                {
                    if(GetAlignmentGoodEvil(oTarget) != ALIGNMENT_GOOD)
                        nReturn = ACTION_TURN;
                    else
                        nReturn = ACTION_REBUKE;
                }
            }
            break;
        }
        case SPELL_TURN_BLIGHTSPAWNED:
        {
            // Rebuke/Command blightspawned, either by tag from Blight touch
            // Or from having a Blightlord master
            if(GetTag(oTarget) == "prc_blightspawn" || GetLevelByClass(CLASS_TYPE_BLIGHTLORD, GetMaster(oTarget)))
            {
                nReturn = ACTION_REBUKE;
            }
            // Rebuke/Command evil animals and plants
            else if(nTargetRace == RACIAL_TYPE_ANIMAL || nTargetRace == RACIAL_TYPE_PLANT)
            {
                if(GetAlignmentGoodEvil(oTarget) == ALIGNMENT_EVIL)
                    nReturn = ACTION_REBUKE;
            }
            break;
        }
        case SPELL_TURN_OOZE:
        {
            // Slime domain rebukes or commands oozes
            if(nTargetRace == RACIAL_TYPE_OOZE)
                nReturn = ACTION_REBUKE;

            break;
        }
		case SPELL_PLANT_DEFIANCE:
		{
			if(nTargetRace == RACIAL_TYPE_PLANT)
				nReturn = ACTION_TURN;	
			
			break;
		}
		case SPELL_PLANT_CONTROL:
		{
			if(nTargetRace == RACIAL_TYPE_PLANT)
			nReturn = ACTION_REBUKE;
		
			break;	
		}		
        case SPELL_TURN_PLANT:
        {
            // Plant domain rebukes or commands plants
            if(GetPRCSwitch(PRC_BIOWARE_PLANT_DOMAIN_POWER))
            {
                if(nTargetRace == RACIAL_TYPE_VERMIN)
                    nReturn = ACTION_TURN;
            }
            else
            {
                if(nTargetRace == RACIAL_TYPE_PLANT)
                    nReturn = ACTION_REBUKE;
            }
            break;
        }
        case SPELL_TURN_AIR:
        {
            if(GetIsAirCreature(oTarget, nTargetAppearance))
                nReturn = ACTION_REBUKE;

            else if(GetIsEarthCreature(oTarget, nTargetAppearance))
                nReturn = ACTION_TURN;

            break;
        }
        case SPELL_TURN_EARTH:
        {
            if(GetIsAirCreature(oTarget, nTargetAppearance))
                nReturn = ACTION_TURN;

            else if(GetIsEarthCreature(oTarget, nTargetAppearance))
                nReturn = ACTION_REBUKE;

            break;
        }
        case SPELL_TURN_FIRE:
        {
            if(GetIsFireCreature(oTarget, nTargetAppearance))
                nReturn = ACTION_REBUKE;

            else if(GetIsWaterCreature(oTarget, nTargetAppearance))
                nReturn = ACTION_TURN;

            break;
        }
        case SPELL_TURN_WATER:
        {
            if(GetIsFireCreature(oTarget, nTargetAppearance))
                nReturn = ACTION_TURN;

            else if(GetIsWaterCreature(oTarget, nTargetAppearance))
                nReturn = ACTION_REBUKE;

            break;
        }
        case SPELL_TURN_REPTILE:
        {
            if(GetIsReptile(oTarget, nTargetAppearance))
                nReturn = ACTION_REBUKE;

            break;
        }
        case SPELL_TURN_SPIDER:
        {
            if(GetIsSpider(oTarget, nTargetAppearance))
                nReturn = ACTION_REBUKE;

            break;
        }
        case SPELL_TURN_COLD:
        {
            if(GetIsFireCreature(oTarget, nTargetAppearance))
                nReturn = ACTION_TURN;

            else if(GetIsColdCreature(oTarget, nTargetAppearance))
                nReturn = ACTION_REBUKE;

            break;
        }
        case FEAT_DOMAIN_POWER_MADNESS:
        {
            // Madness domain rebukes or commands oozes
            if(nTargetRace == RACIAL_TYPE_ABERRATION)
                nReturn = ACTION_TURN;

            break;
        }
		case FEAT_DOMAIN_POWER_MOON:  
		{  
			// Moon domain rebukes lycanthropes  
			if(nTargetRace == RACIAL_TYPE_SHAPECHANGER)  
			{  
				string sName = GetName(oTarget);  
				int nAppearance = GetAppearanceType(oTarget);  
				  
				// Check if name starts with "were" OR has lycanthrope appearance  
				if((GetStringLeft(GetStringLowerCase(sName), 4) == "were") ||  
				   nAppearance == APPEARANCE_TYPE_WEREWOLF ||  
				   nAppearance == APPEARANCE_TYPE_WERECAT ||  
				   nAppearance == APPEARANCE_TYPE_WERERAT)  
				{  
					nReturn = ACTION_TURN;  
				}  
			}  
			break;  
		}        
    }

    //always turn baelnorns & archliches
    if(GetLevelByClass(CLASS_TYPE_BAELNORN, oTarget) || GetHasFeat(FEAT_TEMPLATE_ARCHLICH_MARKER, oTarget))  //:: Archlich
        nReturn = ACTION_TURN;

    //Immunity check
    if(nReturn == ACTION_TURN && GetHasFeat(FEAT_TURNING_IMMUNITY, oTarget))
        nReturn = FALSE;

    if(nReturn == ACTION_REBUKE && GetHasFeat(FEAT_IMMUNITY_TO_REBUKING, oTarget))
        nReturn = FALSE;

    return nReturn;
}
//ok
void DoTurn(object oTarget)
{
    //create the effect
    effect eTurn = EffectLinkEffects(EffectTurned(), EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR));
           eTurn = EffectLinkEffects(eTurn, EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE));
           eTurn = SupernaturalEffect(eTurn);
    //apply the effect for 60 seconds
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTurn, oTarget, 60.0);
    FaithInTheFrost(OBJECT_SELF, oTarget);
    LightOfAurifar(OBJECT_SELF, oTarget);
}
//ok
void DoDestroy(object oTarget)
{
    //supernatural so it penetrates immunity to death
    ApplyEffectToObject(DURATION_TYPE_INSTANT, SupernaturalEffect(EffectDeath()), oTarget);//EffectDeath(TRUE)?
}

void DoRebuke(object oTarget)
{
    //rebuke effect
    //The character is frozen in fear and can take no actions.
    //A cowering character takes a -2 penalty to Armor Class and loses
    //her Dexterity bonus (if any).
    //create the effect
    effect eRebuke = EffectEntangle(); //this removes dex bonus
           eRebuke = EffectLinkEffects(eRebuke, EffectACDecrease(2));
           eRebuke = EffectLinkEffects(eRebuke, EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR));
           eRebuke = EffectLinkEffects(eRebuke, EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE));
    //apply the effect for 60 seconds
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRebuke, oTarget, 60.0);
    //handle unable to take actions
    AssignCommand(oTarget, ClearAllActions());
    AssignCommand(oTarget, DelayCommand(60.0, SetCommandable(TRUE)));
    AssignCommand(oTarget, SetCommandable(FALSE));
    FaithInTheFrost(OBJECT_SELF, oTarget);
    LightOfAurifar(OBJECT_SELF, oTarget);
}
//ok
void DoCommand(object oTarget)
{
    //create the effect
    //supernatural will last over resting
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectCutsceneDominated()), oTarget);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DOMINATE_S), oTarget);
}
//ok
int GetTurningCheckResult(int nLevel, int nTurningCheck)
{
    switch(nTurningCheck)
    {
        case  0:
            return nLevel-4;
        case  1:
        case  2:
        case  3:
            return nLevel-3;
        case  4:
        case  5:
        case  6:
            return nLevel-2;
        case  7:
        case  8:
        case  9:
            return nLevel-1;
        case 10:
        case 11:
        case 12:
            return nLevel;
        case 13:
        case 14:
        case 15:
            return nLevel+1;
        case 16:
        case 17:
        case 18:
            return nLevel+2;
        case 19:
        case 20:
        case 21:
            return nLevel+3;
        default:
            if(nTurningCheck < 0)
                return nLevel-4;
            else
                return nLevel+4;
    }
    //somethings gone wrong here
    return 0;
}

int GetTurningClassLevel(object oCaster = OBJECT_SELF, int nTurnType = SPELL_TURN_UNDEAD)
{
    int nLevel, nTemp;
    
	if (nTurnType == SPELL_OPPORTUNISTIC_PIETY_TURN)
		return GetLevelByClass(CLASS_TYPE_FACTOTUM, oCaster);
	
	if (nTurnType == SPELL_PLANT_DEFIANCE || nTurnType == SPELL_PLANT_CONTROL)
	{
		int nDivineLvl =  GetPrCAdjustedCasterLevelByType(TYPE_DIVINE, oCaster);
		
		return nDivineLvl;
	}

    //Baelnorn & Archlich adds all class levels.
    if(GetLevelByClass(CLASS_TYPE_BAELNORN, oCaster) || GetHasFeat(FEAT_TEMPLATE_ARCHLICH_MARKER, oCaster)) //:: Archlich
        nLevel = GetHitDice(oCaster);
    else
    {
        //full classes
        nLevel += GetLevelByClass(CLASS_TYPE_CLERIC, oCaster);
        nLevel += GetLevelByClass(CLASS_TYPE_DREAD_NECROMANCER, oCaster);
		nLevel += GetLevelByClass(CLASS_TYPE_TRUENECRO);
        nLevel += GetLevelByClass(CLASS_TYPE_SOLDIER_OF_LIGHT, oCaster);
        nLevel += GetLevelByClass(CLASS_TYPE_MASTER_OF_SHROUDS, oCaster);
        nLevel += GetLevelByClass(CLASS_TYPE_MORNINGLORD, oCaster);
        nLevel += GetLevelByClass(CLASS_TYPE_ELDRITCH_DISCIPLE, oCaster);
        nLevel += GetLevelByClass(CLASS_TYPE_SACREDPURIFIER, oCaster);
        nLevel += GetLevelByClass(CLASS_TYPE_UR_PRIEST, oCaster);
        if (!GetIsVestigeExploited(oCaster, VESTIGE_TENEBROUS_TURN_UNDEAD) && GetHasSpellEffect(VESTIGE_TENEBROUS, oCaster)) nLevel += GetBinderLevel(oCaster, VESTIGE_TENEBROUS);

        //Mystics with sun domain can turn undead
        if(GetHasFeat(FEAT_BONUS_DOMAIN_SUN, oCaster))
            nLevel += GetLevelByClass(CLASS_TYPE_MYSTIC, oCaster);

        //offset classes
        nTemp = GetLevelByClass(CLASS_TYPE_PALADIN, oCaster)-3;
        //Seek Eternal Rest
        if (GetHasSpellEffect(SPELL_SEEK_ETERNAL_REST, oCaster)) nTemp = GetLevelByClass(CLASS_TYPE_PALADIN, oCaster);
        if(nTemp > 0)nLevel += nTemp;     	
        nTemp = GetLevelByClass(CLASS_TYPE_SHAMAN, oCaster)-2;
        if(nTemp > 0) nLevel += nTemp;
        nTemp = GetLevelByClass(CLASS_TYPE_TEMPLAR, oCaster)-3;
        if(nTemp > 0) nLevel += nTemp;
        nTemp = GetLevelByClass(CLASS_TYPE_BLACKGUARD, oCaster)-2;
        if(nTemp > 0) nLevel += nTemp;
        nTemp = GetLevelByClass(CLASS_TYPE_HOSPITALER, oCaster)-2;
        if(nTemp > 0) nLevel += nTemp;
        nTemp = GetLevelByClass(CLASS_TYPE_NIGHTSTALKER, oCaster)-3;
        if(nTemp > 0) nLevel += nTemp;      

        //not undead turning classes
        if(nTurnType == SPELL_TURN_SPIDER)
            nLevel += GetLevelByClass(CLASS_TYPE_JUDICATOR, oCaster);
        else if(nTurnType == SPELL_TURN_BLIGHTSPAWNED)
            nLevel += GetLevelByClass(CLASS_TYPE_BLIGHTLORD, oCaster);
        else if(nTurnType == SPELL_TURN_OUTSIDER)
        {
            nTemp = GetLevelByClass(CLASS_TYPE_ANTI_PALADIN, oCaster)-3;
            if(nTemp > 0) nLevel += nTemp;
        }        
    }

    //Improved turning feat
    nLevel += GetHasFeat(FEAT_IMPROVED_TURNING, oCaster);

    //Phylactery of Undead Turning
    if(GetTag(GetItemInSlot(INVENTORY_SLOT_NECK, oCaster)) == "prc_turnphyl")
        nLevel += 4;
    //Weapon of Legacy bonuses
    nLevel += GetLocalInt(oCaster, "WOLTurning");

    return nLevel;
}
//ok
int GetTurningCharismaMod(int nTurnType)
{
    int nChaMod = GetAbilityModifier(ABILITY_CHARISMA);

    //Heartwarder adds two to cha checks
    if(GetHasFeat(FEAT_HEART_PASSION))
        nChaMod += 2;

    if(nTurnType == SPELL_TURN_UNDEAD)
    {
        //Hierophants Mastery of Energy
        if(GetHasFeat(FEAT_MASTER_OF_ENERGY))
            nChaMod += 4;

        //Consecrate spell
        if(GetHasSpellEffect(SPELL_CONSECRATE))
            nChaMod += 3;

        //Desecrate spell
        if(GetHasSpellEffect(SPELL_DES_20) || GetHasSpellEffect(SPELL_DES_100) || GetHasSpellEffect(SPELL_DESECRATE))
            nChaMod -= 3;
    }

    return nChaMod;
}
//ok
int GetHitDiceForTurning(object oTarget, int nTurnType, int nTargetRace)
{
    //Hit Dice + Turn Resistance
    int nHD = GetHitDice(oTarget) + GetTurnResistanceHD(oTarget);

    if(GetHasFeat(FEAT_TURN_SUBMISSION, oTarget))
        nHD -= 4;

    //Outsiders get SR (halved if turner has planar turning)
    if(nTargetRace == RACIAL_TYPE_OUTSIDER)
    {
        int nSR = PRCGetSpellResistance(oTarget, OBJECT_SELF);
        if(nTurnType == SPELL_TURN_OUTSIDER || GetHasFeat(FEAT_EPIC_PLANAR_TURNING))
            nSR /= 2;
        nHD += nSR;
    }

    return nHD;
}
//ok
int GetCommandedTotalHD(int nTurnType = SPELL_TURN_UNDEAD, int bUndeadMastery = FALSE)
{
    int nCommandedTotalHD;
    object oTest = GetFirstFactionMember(OBJECT_SELF, FALSE);
    while(GetIsObjectValid(oTest))
    {
        if(GetMaster(oTest) == OBJECT_SELF && GetAssociateType(oTest) == ASSOCIATE_TYPE_DOMINATED)
        {
            int nRace = MyPRCGetRacialType(oTest);
            int nTestHD = GetHitDiceForTurning(oTest, nTurnType, nRace);
            if(nRace != RACIAL_TYPE_UNDEAD && bUndeadMastery)
                nTestHD *= 10;
            nCommandedTotalHD += nTestHD;
        }
        oTest = GetNextFactionMember(OBJECT_SELF, FALSE);
    }
    return nCommandedTotalHD;
}

int CheckTargetName(object oTarget, string sName)
{
    return FindSubString(GetStringLowerCase(GetName(oTarget)), sName) > -1;
}
//ok - elemental savant/bonded summoner?
int GetIsAirCreature(object oCreature, int nAppearance)
{
    return nAppearance == APPEARANCE_TYPE_ELEMENTAL_AIR
         || nAppearance == APPEARANCE_TYPE_ELEMENTAL_AIR_ELDER
         || nAppearance == APPEARANCE_TYPE_INVISIBLE_STALKER
         || nAppearance == APPEARANCE_TYPE_MEPHIT_AIR
         || nAppearance == APPEARANCE_TYPE_MEPHIT_DUST
         || nAppearance == APPEARANCE_TYPE_MEPHIT_ICE
         || nAppearance == APPEARANCE_TYPE_WILL_O_WISP
         || nAppearance == APPEARANCE_TYPE_DRAGON_GREEN
         || nAppearance == APPEARANCE_TYPE_WYRMLING_GREEN;
       //|| CheckTargetName(oCreature, "air")) // This last one is to catch anything named with Air that doesnt use the appearances
}
//ok
int GetIsEarthCreature(object oCreature, int nAppearance)
{
    return nAppearance == APPEARANCE_TYPE_ELEMENTAL_EARTH
         || nAppearance == APPEARANCE_TYPE_ELEMENTAL_EARTH_ELDER
         || nAppearance == APPEARANCE_TYPE_GARGOYLE
         || nAppearance == APPEARANCE_TYPE_MEPHIT_EARTH
         || nAppearance == APPEARANCE_TYPE_MEPHIT_SALT
         || nAppearance == APPEARANCE_TYPE_DRAGON_BLUE
         || nAppearance == APPEARANCE_TYPE_DRAGON_COPPER
         || nAppearance == APPEARANCE_TYPE_WYRMLING_BLUE
         || nAppearance == APPEARANCE_TYPE_WYRMLING_COPPER;
       //|| CheckTargetName(oCreature, "earth")) // As above
}
//ok
int GetIsFireCreature(object oCreature, int nAppearance)
{
    return nAppearance == APPEARANCE_TYPE_ELEMENTAL_FIRE
         || nAppearance == APPEARANCE_TYPE_ELEMENTAL_FIRE_ELDER
         || nAppearance == APPEARANCE_TYPE_AZER_MALE
         || nAppearance == APPEARANCE_TYPE_AZER_FEMALE
         || nAppearance == APPEARANCE_TYPE_GIANT_FIRE
         || nAppearance == APPEARANCE_TYPE_GIANT_FIRE_FEMALE
         || nAppearance == APPEARANCE_TYPE_MEPHIT_FIRE
         || nAppearance == APPEARANCE_TYPE_MEPHIT_MAGMA
         || nAppearance == APPEARANCE_TYPE_MEPHIT_STEAM
         || nAppearance == APPEARANCE_TYPE_DRAGON_BRASS
         || nAppearance == APPEARANCE_TYPE_DRAGON_GOLD
         || nAppearance == APPEARANCE_TYPE_DRAGON_RED
         || nAppearance == APPEARANCE_TYPE_WYRMLING_BRASS
         || nAppearance == APPEARANCE_TYPE_WYRMLING_GOLD
         || nAppearance == APPEARANCE_TYPE_WYRMLING_RED
         || nAppearance == APPEARANCE_TYPE_DOG_HELL_HOUND;
       //|| CheckTargetName(oCreature, "fire")) // This last one is to catch anything named with Fire that doesnt use the appearances
}
//ok
int GetIsWaterCreature(object oCreature, int nAppearance)
{
    return nAppearance == APPEARANCE_TYPE_ELEMENTAL_WATER
         || nAppearance == APPEARANCE_TYPE_ELEMENTAL_WATER_ELDER
         || nAppearance == APPEARANCE_TYPE_MEPHIT_WATER
         || nAppearance == APPEARANCE_TYPE_MEPHIT_OOZE
         || nAppearance == APPEARANCE_TYPE_DRAGON_BLACK
         || nAppearance == APPEARANCE_TYPE_DRAGON_BRONZE
         || nAppearance == APPEARANCE_TYPE_WYRMLING_BLACK
         || nAppearance == APPEARANCE_TYPE_WYRMLING_BRONZE;
       //|| CheckTargetName(oCreature, "water")) // As above
}
//only animals in PnP
int GetIsReptile(object oCreature, int nAppearance)
{
    if(nAppearance == APPEARANCE_TYPE_KOBOLD_A
    || nAppearance == APPEARANCE_TYPE_KOBOLD_B
    || nAppearance == APPEARANCE_TYPE_KOBOLD_CHIEF_A
    || nAppearance == APPEARANCE_TYPE_KOBOLD_CHIEF_B
    || nAppearance == APPEARANCE_TYPE_KOBOLD_SHAMAN_A
    || nAppearance == APPEARANCE_TYPE_KOBOLD_SHAMAN_B
    || nAppearance == APPEARANCE_TYPE_LIZARDFOLK_A
    || nAppearance == APPEARANCE_TYPE_LIZARDFOLK_B
    || nAppearance == APPEARANCE_TYPE_LIZARDFOLK_WARRIOR_A
    || nAppearance == APPEARANCE_TYPE_LIZARDFOLK_WARRIOR_B
    || nAppearance == APPEARANCE_TYPE_LIZARDFOLK_SHAMAN_A
    || nAppearance == APPEARANCE_TYPE_LIZARDFOLK_SHAMAN_B
    || nAppearance == 451 //Trog
    || nAppearance == 452 //Trog Warrior
    || nAppearance == 453 //Trog Cleric
    || nAppearance == 178 //Black Cobra
    || nAppearance == 183 //Cobra
    || nAppearance == 194) //Gold Cobra
  //|| CheckTargetName(oCreature, "scale")
  //|| CheckTargetName(oCreature, "snake")
  //|| CheckTargetName(oCreature, "reptile")) // Reptilian names
    {
        return TRUE;
    }
    return FALSE;
}

int GetIsSpider(object oCreature, int nAppearance)
{
    return GetLevelByClass(CLASS_TYPE_VERMIN, oCreature)
        && (nAppearance == APPEARANCE_TYPE_SPIDER_DEMON
         || nAppearance == APPEARANCE_TYPE_SPIDER_DIRE
         || nAppearance == APPEARANCE_TYPE_SPIDER_GIANT
         || nAppearance == APPEARANCE_TYPE_SPIDER_SWORD
         || nAppearance == APPEARANCE_TYPE_SPIDER_PHASE
         || nAppearance == APPEARANCE_TYPE_SPIDER_WRAITH
         || nAppearance == 463); //Maggris
       //|| CheckTargetName(oCreature, "spider"); // Duh
}

int GetIsColdCreature(object oCreature, int nAppearance)
{
    return nAppearance == APPEARANCE_TYPE_DOG_WINTER_WOLF
         || nAppearance == APPEARANCE_TYPE_DRAGON_WHITE
         || nAppearance == APPEARANCE_TYPE_GIANT_FROST
         || nAppearance == APPEARANCE_TYPE_GIANT_FROST_FEMALE
         || nAppearance == APPEARANCE_TYPE_MEPHIT_ICE
         || nAppearance == APPEARANCE_TYPE_WYRMLING_WHITE
         || nAppearance == APPEARANCE_TYPE_DRAGON_SILVER
         || nAppearance == APPEARANCE_TYPE_WYRMLING_SILVER;
       //|| CheckTargetName(oCreature, "water")) // As above
}

void FaithInTheFrost(object oPC, object oTarget)
{
    if (GetHasFeat(FEAT_FAITH_IN_THE_FROST, oPC))
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(GetAbilityModifier(ABILITY_CHARISMA, oPC), DAMAGE_TYPE_COLD), oTarget);
}

void LightOfAurifar(object oPC, object oTarget)
{
    if (GetHasFeat(FEAT_LIGHT_OF_AURIFAR, oPC))
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(2), DAMAGE_TYPE_FIRE), oTarget);
}

// Test main
//void main(){}


