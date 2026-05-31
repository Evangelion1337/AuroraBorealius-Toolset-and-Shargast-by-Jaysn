//::///////////////////////////////////////////////
//:: Soulknife includes
//:: psi_inc_soulkn
//::///////////////////////////////////////////////
/** @file Soulknife includes
    Constants and common functions used by
    Soulknife scripts.

    @author Ornedan
    @date   Created - 06.04.2005
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

#include "prc_alterations"
#include "prc_class_const"
#include "inc_utility"


//////////////////////////////////////////////////
/* Constant declarations                        */
//////////////////////////////////////////////////

const string MBLADE_SHAPE         = "PRC_PSI_SK_MindbladeShape";
const string FREEDRAW_USED        = "PRC_PSI_SK_FreeDraw_Used";
const string THROW_MBLD_USED      = "PRC_PSI_SK_ThrowMindblade_Used";
const string PSYCHIC_STRIKE_MAINH = "PRC_PSI_SK_PsychisStrike_MainHand";
const string PSYCHIC_STRIKE_OFFH  = "PRC_PSI_SK_PsychisStrike_OffHand";
const string KTTS                 = "PRC_PSI_SK_KnifeToTheSoul";
const string BLADEWIND            = "PRC_PSI_SK_Bladewind_Active";
const string MBLADE_HAND          = "PRC_PSI_SK_MindbladeManifestationHand";

const int KTTS_TYPE_MASK    = 3; // 2 LSB
const int KTTS_TYPE_OFF     = 0;
const int KTTS_TYPE_INT     = 1;
const int KTTS_TYPE_WIS     = 2;
const int KTTS_TYPE_CHA     = 3;

const int MBLADE_SHAPE_SHORTSWORD       = 0;
const int MBLADE_SHAPE_DUAL_SHORTSWORDS = 1;
const int MBLADE_SHAPE_LONGSWORD        = 2;
const int MBLADE_SHAPE_BASTARDSWORD     = 3;
const int MBLADE_SHAPE_RANGED           = 4; // Actual shape is throwing axe


const string MBLADE_FLAGS   = "PRC_PSI_SK_MindbladeFlags";
const int MBLADE_FLAG_COUNT = 23;

const int MBLADE_FLAG_LUCKY                 = 0x1;
const int MBLADE_FLAG_DEFENDING             = 0x2;
const int MBLADE_FLAG_KEEN                  = 0x4;
const int MBLADE_FLAG_VICIOUS               = 0x8;
const int MBLADE_FLAG_PSYCHOKINETIC         = 0x10;
const int MBLADE_FLAG_MIGHTYCLEAVING        = 0x20;
const int MBLADE_FLAG_COLLISION             = 0x40;
const int MBLADE_FLAG_MINDCRUSHER           = 0x80;
const int MBLADE_FLAG_PSYCHOKINETICBURST    = 0x100;
const int MBLADE_FLAG_SUPPRESSION           = 0x200;
const int MBLADE_FLAG_WOUNDING              = 0x400;
const int MBLADE_FLAG_DISRUPTING            = 0x800;
const int MBLADE_FLAG_SOULBREAKER           = 0x1000;
const int MBLADE_FLAG_SHIELD_1              = 0x2000;
const int MBLADE_FLAG_SHIELD_2              = 0x4000;
const int MBLADE_FLAG_SHIELD_3              = 0x8000;
const int MBLADE_FLAG_SHIELD_4              = 0x10000;
const int MBLADE_FLAG_SHIELD_5              = 0x20000;
const int MBLADE_FLAG_SHIELD_6              = 0x40000;
const int MBLADE_FLAG_SHIELD_7              = 0x80000;
const int MBLADE_FLAG_SHIELD_8              = 0x100000;
const int MBLADE_FLAG_SHIELD_9              = 0x200000;
const int MBLADE_FLAG_SHIELD_10             = 0x400000;



//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

// Sums the enhancement costs of enhancements contained in the given flag set
// ==========================================================================
// nFlags   a set of mindblade flags
//
// Returns the sum of the enhancements costs of the mindblade abilities
// set in nFlags.
int GetTotalEnhancementCost(int nFlags);

// Gets the enhancement cost of the given mindblade ability
// ========================================================
// nFlag    one of the MBLADE_FLAG_* contants
int GetFlagCost(int nFlag);

// Gets the maximum mindblade enhancement usable by the given creature
// ===================================================================
// oSK  a creature to calculate the value of Soulknife class ability
//      "Mind blade enhancement" for
int GetMaxEnhancementCost(object oSK);

/**
 * Checks the given object's tag to determine whether it is a mindblade
 * or not.
 *
 * @param oWeapon Weapon to test
 * @return        TRUE if oWeapon is a mindblade, FALSE otherwise
 */
int GetIsMindblade(object oWeapon);


//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

int GetTotalEnhancementCost(int nFlags)
{
    int nCost, i;
    for(; i < MBLADE_FLAG_COUNT; i++)
        nCost += GetFlagCost(nFlags & (1 << i));
    return nCost;
}

int GetFlagCost(int nFlag)
{
    switch(nFlag)
    {
        case 0: return 0;
        case MBLADE_FLAG_LUCKY:                 return 1;
        case MBLADE_FLAG_DEFENDING:             return 1;
        case MBLADE_FLAG_KEEN:                  return 1;
        case MBLADE_FLAG_VICIOUS:               return 1;
        case MBLADE_FLAG_PSYCHOKINETIC:         return 1;
        case MBLADE_FLAG_MIGHTYCLEAVING:        return 2;
        case MBLADE_FLAG_COLLISION:             return 2;
        case MBLADE_FLAG_MINDCRUSHER:           return 2;
        case MBLADE_FLAG_PSYCHOKINETICBURST:    return 2;
        case MBLADE_FLAG_SUPPRESSION:           return 2;
        case MBLADE_FLAG_WOUNDING:              return 2;
        case MBLADE_FLAG_DISRUPTING:            return 3;
        case MBLADE_FLAG_SOULBREAKER:           return 4;
        case MBLADE_FLAG_SHIELD_1:              return 1;
        case MBLADE_FLAG_SHIELD_2:              return 2;
        case MBLADE_FLAG_SHIELD_3:              return 3;
        case MBLADE_FLAG_SHIELD_4:              return 4;
        case MBLADE_FLAG_SHIELD_5:              return 5;
        case MBLADE_FLAG_SHIELD_6:              return 6;
        case MBLADE_FLAG_SHIELD_7:              return 7;
        case MBLADE_FLAG_SHIELD_8:              return 8;
        case MBLADE_FLAG_SHIELD_9:              return 9;
        case MBLADE_FLAG_SHIELD_10:             return 10;

        default:
            WriteTimestampedLogEntry("Unknown flag passed to GetFlagCost: " + IntToString(nFlag));
    }

    return 0;
}

int GetMaxEnhancementCost(object oSK)
{
    int nEffMBldLevel = GetLevelByClass(CLASS_TYPE_SOULKNIFE, oSK);
	
    if(GetHasFeat(FEAT_SOULBLADE_WARRIOR, oSK)) nEffMBldLevel += 2;
    return (nEffMBldLevel - 2) / 4;
}

int GetIsMindblade(object oWeapon)
{
    return GetStringLeft(GetTag(oWeapon), 14) == "prc_sk_mblade_";
}






/*
/\/ Template used to generate the startingconditionals for Mindblade Enhancement convo \/\
//::///////////////////////////////////////////////
//:: Soulknife: Conversation - Show ~~~Name~~~
//:: psi_sk_conv_~~~Suffix~~~
//::///////////////////////////////////////////////
/*
    Checks whether to show ~~~Name~~~ and whether
    it is to be added or removed.
/
//:://////////////////////////////////////////////
//:: Created By: Ornedan
//:: Created On: 06.04.2005
//:://////////////////////////////////////////////

#include "psi_inc_sk_const"


int StartingConditional()
{
    int nReturn; // Implicit init to FALSE
    // Check if the flag is already present
    if(GetLocalInt(GetPCSpeaker(), MBLADE_FLAGS + "_T") & ~~~Flag~~~)
    {
        SetCustomToken(~~~TokenNum~~~, GetStringByStrRef(7654)); // Remove
        nReturn = TRUE;
    }
    // It isn't, so see if there is enough bonus left to add it
    else if(GetTotalEnhancementCost(GetLocalInt(GetPCSpeaker(), MBLADE_FLAGS + "_T")) + GetFlagCost(~~~Flag~~~) <= GetMaxEnhancementCost(GetPCSpeaker()))
    {
        SetCustomToken(~~~TokenNum~~~, GetStringByStrRef(62476)); // Add
        nReturn = TRUE;
    }

    return nReturn;
}


/\/ Template used to generate the toggles for Mindblade Enhancement convo \/\
//::///////////////////////////////////////////////
//:: Soulknife: Conversation - Toggle ~~~Name~~~
//:: psi_sk_conv_~~~Suffix~~~
//::///////////////////////////////////////////////
/*
    Adds or removes ~~~Name~~~ from the mindblade
    flags.
/
//:://////////////////////////////////////////////
//:: Created By: Ornedan
//:: Created On: 06.04.2005
//:://////////////////////////////////////////////

#include "psi_inc_sk_const"


void main()
{
    SetLocalInt(GetPCSpeaker(), MBLADE_FLAGS + "_T",
                GetLocalInt(GetPCSpeaker(), MBLADE_FLAGS + "_T") ^ ~~~Flag~~~
               );
}



/\/ 2da files used for both \/\
2DA V2.0

    Suffix  Name                    TokenNum    Flag
0   lu_s    Lucky                   102         MBLADE_FLAG_LUCKY
1   de_s    Defending               103         MBLADE_FLAG_DEFENDING
2   ke_s    Keen                    104         MBLADE_FLAG_KEEN
3   vi_s    Vicous                  105         MBLADE_FLAG_VICIOUS
4   ps_s    Psychokinetic           106         MBLADE_FLAG_PSYCHOKINETIC
5   mc_s    "Mighty Cleaving"       107         MBLADE_FLAG_MIGHTYCLEAVING
6   co_s    Collision               108         MBLADE_FLAG_COLLISION
7   mi_s    Mindcrusher             109         MBLADE_FLAG_MINDCRUSHER
8   pb_s    "Psychokinetic Burst"   110         MBLADE_FLAG_PSYCHOKINETICBURST
9   su_s    Suppression             111         MBLADE_FLAG_SUPPRESSION
10  wo_s    Wounding                112         MBLADE_FLAG_WOUNDING
11  di_s    Disrupting              113         MBLADE_FLAG_DISRUPTING
12  so_s    Soulbreaker             114         MBLADE_FLAG_SOULBREAKER
*/
