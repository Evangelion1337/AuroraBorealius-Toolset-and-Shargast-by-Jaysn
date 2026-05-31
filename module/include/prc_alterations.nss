//::///////////////////////////////////////////////
//:: Include nexus
//:: prc_alterations
//::///////////////////////////////////////////////
/*
    This is the original include file for the PRC Spell Engine.

    Various spells, components and designs within this system have
    been contributed by many individuals within and without the PRC.


    These days, it serves to gather links to almost all the PRC
    includes to one file. Should probably get sorted out someday,
    since this slows compilation. On the other hand, it may be
    necessary, since the custom compiler can't seem to handle
    the most twisted include loops.
    Related TODO to any C++ experts: Add #DEFINE support to nwnnsscomp

    Also, this file contains misceallenous functions that haven't
    got a better home.
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//return a location that PCs will never be able to access
location PRC_GetLimbo();

//int GetSkill(object oObject, int nSkill, int bSynergy = FALSE, int bSize = FALSE, int bAbilityMod = TRUE, int bEffect = TRUE, int bArmor = TRUE, int bShield = TRUE, int bFeat = TRUE);

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

// const int ERROR_CODE_5_FIX_YET_ANOTHER_TIME = 1;

//////////////////////////////////////////////////
/* Include section                              */
//////////////////////////////////////////////////

// Generic includes

#include "inc_abil_damage"

//////////////////////////////////////////////////
/* Function Definitions                         */
//////////////////////////////////////////////////

//return a location that PCs will never be able to access
location PRC_GetLimbo()
{
    int i = 0;
    location lLimbo;

    while (1)
    {
        object oLimbo = GetObjectByTag("Limbo", i++);

        if (oLimbo == OBJECT_INVALID) {
            PrintString("PRC ERROR: no Limbo area! (did you import the latest PRC .ERF file?)");
            return lLimbo;
        }

        if (GetName(oLimbo) == "Limbo" && GetArea(oLimbo) == OBJECT_INVALID)
        {
            vector vLimbo = Vector(0.0f, 0.0f, 0.0f);
            lLimbo = Location(oLimbo, vLimbo, 0.0f);
        }
    }
    return lLimbo;      //never reached
}

//Also serves as a store of all item creation feats
int GetItemCreationFeatCount()
{
    return(GetHasFeat(FEAT_CRAFT_WONDROUS)
          + GetHasFeat(FEAT_CRAFT_STAFF)
          + GetHasFeat(FEAT_CRAFT_ARMS_ARMOR)
          + GetHasFeat(FEAT_FORGE_RING)
          + GetHasFeat(FEAT_CRAFT_ROD)
          + GetHasFeat(FEAT_CRAFT_CONSTRUCT)
          + GetHasFeat(FEAT_SCRIBE_SCROLL)
          + GetHasFeat(FEAT_BREW_POTION)
          + GetHasFeat(FEAT_CRAFT_WAND)
          + GetHasFeat(FEAT_ATTUNE_GEM)
          + GetHasFeat(FEAT_CRAFT_SKULL_TALISMAN)
          + GetHasFeat(FEAT_INSCRIBE_RUNE)
        //+ GetHasFeat(?)
            );
}

// Returns the IP_CONST_DAMAGESOAK_*_HP constant that does the given
// amount of damage reduction
int GetDamageSoakConstant(int nDamRed)
{
    switch(nDamRed)
    {
		case 1: return IP_CONST_DAMAGESOAK_1_HP;
		case 2: return IP_CONST_DAMAGESOAK_2_HP;
		case 3: return IP_CONST_DAMAGESOAK_3_HP;
		case 4: return IP_CONST_DAMAGESOAK_4_HP;
		case 5: return IP_CONST_DAMAGESOAK_5_HP;
		case 6: return IP_CONST_DAMAGESOAK_6_HP;
		case 7: return IP_CONST_DAMAGESOAK_7_HP;
		case 8: return IP_CONST_DAMAGESOAK_8_HP;
		case 9: return IP_CONST_DAMAGESOAK_9_HP;
		case 10: return IP_CONST_DAMAGESOAK_10_HP;
		case 11: return IP_CONST_DAMAGESOAK_11_HP;
		case 12: return IP_CONST_DAMAGESOAK_12_HP;
		case 13: return IP_CONST_DAMAGESOAK_13_HP;
		case 14: return IP_CONST_DAMAGESOAK_14_HP;
		case 15: return IP_CONST_DAMAGESOAK_15_HP;
		case 16: return IP_CONST_DAMAGESOAK_16_HP;
		case 17: return IP_CONST_DAMAGESOAK_17_HP;
		case 18: return IP_CONST_DAMAGESOAK_18_HP;
		case 19: return IP_CONST_DAMAGESOAK_19_HP;
		case 20: return IP_CONST_DAMAGESOAK_20_HP;
		case 21: return IP_CONST_DAMAGESOAK_21_HP;
		case 22: return IP_CONST_DAMAGESOAK_22_HP;
		case 23: return IP_CONST_DAMAGESOAK_23_HP;
		case 24: return IP_CONST_DAMAGESOAK_24_HP;
		case 25: return IP_CONST_DAMAGESOAK_25_HP;
		case 26: return IP_CONST_DAMAGESOAK_26_HP;
		case 27: return IP_CONST_DAMAGESOAK_27_HP;
		case 28: return IP_CONST_DAMAGESOAK_28_HP;
		case 29: return IP_CONST_DAMAGESOAK_29_HP;
		case 30: return IP_CONST_DAMAGESOAK_30_HP;
		case 31: return IP_CONST_DAMAGESOAK_31_HP;
		case 32: return IP_CONST_DAMAGESOAK_32_HP;
		case 33: return IP_CONST_DAMAGESOAK_33_HP;
		case 34: return IP_CONST_DAMAGESOAK_34_HP;
		case 35: return IP_CONST_DAMAGESOAK_35_HP;
		case 36: return IP_CONST_DAMAGESOAK_36_HP;
		case 37: return IP_CONST_DAMAGESOAK_37_HP;
		case 38: return IP_CONST_DAMAGESOAK_38_HP;
		case 39: return IP_CONST_DAMAGESOAK_39_HP;
		case 40: return IP_CONST_DAMAGESOAK_40_HP;
		case 41: return IP_CONST_DAMAGESOAK_41_HP;
		case 42: return IP_CONST_DAMAGESOAK_42_HP;
		case 43: return IP_CONST_DAMAGESOAK_43_HP;
		case 44: return IP_CONST_DAMAGESOAK_44_HP;
		case 45: return IP_CONST_DAMAGESOAK_45_HP;
		case 46: return IP_CONST_DAMAGESOAK_46_HP;
		case 47: return IP_CONST_DAMAGESOAK_47_HP;
		case 48: return IP_CONST_DAMAGESOAK_48_HP;
		case 49: return IP_CONST_DAMAGESOAK_49_HP;
		case 50: return IP_CONST_DAMAGESOAK_50_HP;



        default:
            WriteTimestampedLogEntry("Erroneous value for nDamRed in GetDamageReductionConstant: " + IntToString(nDamRed));
    }

    return -1;
}

//:: void main(){}