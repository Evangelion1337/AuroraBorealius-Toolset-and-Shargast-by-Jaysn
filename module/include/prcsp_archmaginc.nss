//
//  Wrapper Functions for the Archmage Class and Feats
//

//
//  Notes:  Normal use is to include prc_alterations.
//          If this file if to be included elsewhere add the following lines
//          to the target file:
//              #include "prcsp_reputation"
//              #include "prcsp_archmaginc"
//

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

/// @todo Change these to TLK reads

const string MASTERY_OF_ELEMENTS_TAG = "archmage_mastery_elements";
const string MASTERY_OF_ELEMENTS_NAME_TAG = "archmage_mastery_elements_name";
const string MASTERY_OF_SHAPE_TAG = "archmage_mastery_shaping";
const string MASTERY_OF_SHAPE_ON = "Shaping spells to protect allies.";
const string MASTERY_OF_SHAPE_OFF = "Spell shaping is disabled, allies may be effected.";
const string MASTERY_OF_ELEMENTS_ACID = "Elemental spell damage set to acid.";
const string MASTERY_OF_ELEMENTS_COLD = "Elemental spell damage set to cold.";
const string MASTERY_OF_ELEMENTS_ELECTRICAL = "Elemental spell damage set to electrical.";
const string MASTERY_OF_ELEMENTS_FIRE = "Elemental spell damage set to fire.";
const string MASTERY_OF_ELEMENTS_SONIC = "Elemental spell damage set to sonic.";
const string MASTERY_OF_ELEMENTS_OFF = "Elemental spell damage returned to normal.";

const int FEAT_INACTIVE = 0;
const int FEAT_ACTIVE = 1;

const int MASTERY_OF_SHAPE_EFFECT = 460;
const int MASTERY_OF_ELEMENTS_EFFECT_ACID = 448;
const int MASTERY_OF_ELEMENTS_EFFECT_ELECTRICAL = 463;
const int MASTERY_OF_ELEMENTS_EFFECT_OFF = 460;

const int SPELL_MASTERY_ELEMENTS_NORMAL = 2000;
const int SPELL_MASTERY_ELEMENTS_ACID = 2003;
const int SPELL_MASTERY_ELEMENTS_COLD = 2002;
const int SPELL_MASTERY_ELEMENTS_ELECTRICITY = 2004;
const int SPELL_MASTERY_ELEMENTS_FIRE = 2001;
const int SPELL_MASTERY_ELEMENTS_SONIC = 2005;

const int TIME_1_ROUND = 1;


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Determines if Master of Shapes is active and applies in regards to the
 * given target.
 *
 * @param oCaster A creature casting an area-affecting spell
 * @param oTarget A creature that is in the affected area
 * @return        TRUE if the creature should be exempt from the spell due to
 *                Mastery of Shapes. FALSE otherwise
 */
int CheckMasteryOfShapes(object oCaster, object oTarget);

void SetFeatVisualEffects(object oCaster, int nEffect, string sMessage);

void ToggleMasteryOfShapes(object oCaster);

void SetMasteryOfElements();

object GetAreaOfEffectObject(location lTarget, string sTag, object oCaster = OBJECT_SELF);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////
#include "prc_feat_const"
//#include "prc_inc_spells"
//#include "lookup_2da_spell"
#include "prcsp_reputation"
#include "prc_inc_core"



//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int CheckMasteryOfShapes(object oCaster, object oTarget)
{
    int bRetVal = FALSE;

    // This variable should not be set without the feat being available.
    // If someone wants to cheat, let them.
    if (GetLocalInt(oCaster, MASTERY_OF_SHAPE_TAG) == FEAT_ACTIVE && !GetIsReactionTypeHostile(oTarget, oCaster))
    {
         bRetVal = TRUE;
    }

    return bRetVal;
}

int ExtraordinarySpellAim(object oCaster, object oTarget)  
{  
    int bRetVal = FALSE;  
      
    if(GetHasFeat(FEAT_EXTRAORDINARY_SPELL_AIM, oCaster)  
    && GetIsFriend(oTarget, oCaster))  
    {  
        // Check if this is an AOE spell  
        object oAoE = GetAreaOfEffectObject(GetLocation(oTarget), "", oCaster);  
          
        if(GetIsObjectValid(oAoE))  
        {  
            // For persistent AOEs, store exclusion on the AOE object  
            string sTargetID = ObjectToString(oTarget);  
            if(!GetLocalInt(oAoE, "ExtraordinarySpellAim_" + sTargetID))  
            {  
                if(GetIsSkillSuccessful(oCaster, SKILL_SPELLCRAFT, 25 + PRCGetSpellLevel(oCaster, PRCGetSpellId())))  
                {  
                    SetLocalInt(oAoE, "ExtraordinarySpellAim_" + sTargetID, TRUE);  
                    bRetVal = TRUE;  
                }  
            }  
        }  
        else  
        {  
            // For instant spells, use original logic  
            if(!GetLocalInt(oCaster, "ExtraordinarySpellAim"))  
            {  
                SetLocalInt(oCaster, "ExtraordinarySpellAim", TRUE);  
                DelayCommand(1.0, DeleteLocalInt(oCaster, "ExtraordinarySpellAim"));  
                  
                if(GetIsSkillSuccessful(oCaster, SKILL_SPELLCRAFT, 25 + PRCGetSpellLevel(oCaster, PRCGetSpellId())))  
                    bRetVal = TRUE;  
            }  
        }  
    }  
    return bRetVal;  
}

/* int ExtraordinarySpellAim(object oCaster, object oTarget)
{
    int bRetVal = FALSE;

    // This variable should not be set without the feat being available.
    // If someone wants to cheat, let them.
    if(GetHasFeat(FEAT_EXTRAORDINARY_SPELL_AIM, oCaster)
    && !GetLocalInt(oCaster, "ExtraordinarySpellAim")
    && GetIsFriend(oTarget, oCaster))
    {
        // Only once per spell
        SetLocalInt(oCaster, "ExtraordinarySpellAim", TRUE);
        DelayCommand(1.0, DeleteLocalInt(oCaster, "ExtraordinarySpellAim"));
        if(GetIsSkillSuccessful(oCaster, SKILL_SPELLCRAFT, 25 + PRCGetSpellLevel(oCaster, PRCGetSpellId())))
            bRetVal = TRUE;
    }

    return bRetVal;
}
 */
//
//  Help with Visual Effects when setting feats
//
void SetFeatVisualEffects(object oCaster, int nEffect, string sMessage)
{
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(nEffect),
            oCaster, RoundsToSeconds(TIME_1_ROUND));

    FloatingTextStringOnCreature(sMessage, OBJECT_SELF, FALSE);
}

//
//  Enable/Disable Mastery of Shapes
//
void ToggleMasteryOfShapes(object oCaster)
{
    if (GetLocalInt(OBJECT_SELF, MASTERY_OF_SHAPE_TAG) == FEAT_INACTIVE) {
        SetLocalInt(OBJECT_SELF, MASTERY_OF_SHAPE_TAG, FEAT_ACTIVE);
        SetFeatVisualEffects(oCaster, MASTERY_OF_SHAPE_EFFECT, MASTERY_OF_SHAPE_ON);
    }
    else {
        SetLocalInt(OBJECT_SELF, MASTERY_OF_SHAPE_TAG, FEAT_INACTIVE);
        SetFeatVisualEffects(oCaster, MASTERY_OF_SHAPE_EFFECT, MASTERY_OF_SHAPE_OFF);
    }
}

//
//  This function sets the Mastery of Elements feat to a specific element
//
void SetMasteryOfElements()
{
    string msg = MASTERY_OF_ELEMENTS_OFF;
    string sElem = "";
    int nEffect = MASTERY_OF_ELEMENTS_EFFECT_OFF;
    int dmgType = FEAT_INACTIVE;

    switch (PRCGetSpellId()) {
        case SPELL_MASTERY_ELEMENTS_ACID:
            nEffect = MASTERY_OF_ELEMENTS_EFFECT_ACID;
            dmgType = DAMAGE_TYPE_ACID;
            msg = MASTERY_OF_ELEMENTS_ACID;
            sElem = "Acid";
            break;

        case SPELL_MASTERY_ELEMENTS_COLD:
            nEffect = VFX_IMP_AC_BONUS;
            dmgType = DAMAGE_TYPE_COLD;
            msg = MASTERY_OF_ELEMENTS_COLD;
            sElem = "Cold";
            break;

        case SPELL_MASTERY_ELEMENTS_ELECTRICITY:
            nEffect = MASTERY_OF_ELEMENTS_EFFECT_ELECTRICAL;
            dmgType = DAMAGE_TYPE_ELECTRICAL;
            msg = MASTERY_OF_ELEMENTS_ELECTRICAL;
            sElem = "Electricity";
            break;

        case SPELL_MASTERY_ELEMENTS_FIRE:
            nEffect = VFX_IMP_ELEMENTAL_PROTECTION;
            dmgType = DAMAGE_TYPE_FIRE;
            msg = MASTERY_OF_ELEMENTS_FIRE;
            sElem = "Fire";
            break;

        case SPELL_MASTERY_ELEMENTS_SONIC:
            nEffect = VFX_FNF_SOUND_BURST;
            dmgType = DAMAGE_TYPE_SONIC;
            msg = MASTERY_OF_ELEMENTS_SONIC;
            sElem = "Sonic";
            break;

        default:
            // Use the default initialized variables
            break;
    }

    SetLocalInt(OBJECT_SELF, MASTERY_OF_ELEMENTS_TAG, dmgType);
    SetLocalString(OBJECT_SELF, MASTERY_OF_ELEMENTS_NAME_TAG, sElem);
    SetFeatVisualEffects(PRCGetSpellTargetObject(), nEffect, msg);
}

// Test main
//void main(){}
