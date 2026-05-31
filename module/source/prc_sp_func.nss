/*
    prc_sp_func

    Additional spell functions for holding the
        charge (also works for psionics)

    By: Flaming_Sword
    Created: January 31, 2006   *complete rewrite
    Modified: May 27, 2006

    From Player's Handbook 3.5ed p141:

    Holding the Charge: If you don't discharge the
        spell in the round when you cast the sepll,
        you can hold the discharge of the spell
        (hold the charge) indefinitely. You can
        continue to make touch attacks round after
        round. You can touch one friend as a standard
        action or up to six friends as a full-round
        action. If you touch anything or anyone while
        holding a charge, even unintentionally, the
        spell discharges. If you cast another spell,
        the touch spell dissipates. Alternatively, you
        may make a normal unarmed attack (or an attack
        with a natural weapon) while holding a charge.
        In this case you aren't considered armed and you
        provoke attacks of opportunity as normal for
        the attack. (If your unarmed attacks or natural
        weapon attack doesn't provoke attacks of
        opportunity, neither dies this attack. If the
        attack hits, you deal normal damage for your
        unarmed attack or natural weapon and the spell
        discharges. If the attack misses, you are still
        holding the charge.

    Conclusion:
        Holy crap! Charges stay if your touch attacks miss!

*/

// need declaration for this here
int IsTouchSpell(int nSpellID);
void CleanSpellVariables(object oPC);
void SetLocalSpellVariables(object oCaster, int nCharges = 1, int nSpellIDOverride = -1);
void DecrementSpellCharges(object oPC);
void RunSpellScript(object oPC, int nSpellID, int nEventType);
void RunImpactScript(object oPC, int nSpellID, int nEventType);
int IsCure(int nSpellID);
int IsMassCure(int nSpellID);
int IsMassInflict(int nSpellID);
int IsHeal(int nSpellID);
int IsMassHealHarm(int nSpellID);
int CheckRemoveEffects(int nSpellID, int nEffectType);
int IsRaySpell(int nSpell);

//constant declarations in case they change
const string PRC_SPELL_CHARGE_COUNT             = "PRC_SPELL_CHARGE_COUNT";
const string PRC_SPELL_CHARGE_SPELLID           = "PRC_SPELL_CHARGE_SPELLID";
const string PRC_SPELL_CHARGE_LEVEL             = "PRC_SPELL_CHARGE_LEVEL";
const string PRC_SPELL_CONC_TARGET              = "PRC_SPELL_CONC_TARGET";
const string PRC_SPELL_METAMAGIC                = "PRC_SPELL_METAMAGIC";

const string PRC_POWER_HOLD_MANIFESTATION       = "PRC_POWER_HOLD_MANIFESTATION";

const string PRC_SPELL_EVENT                    = "PRC_SPELL_EVENT";

const string PRC_SPELL_HOLD                     = "PRC_SPELL_HOLD";

const int PRC_SPELL_EVENT_NONE                  = 0;
const int PRC_SPELL_EVENT_ATTACK                = 1;
const int PRC_SPELL_EVENT_CONCENTRATION         = 2;

const int FEAT_SPELLS_TOUCH_ATTACK              = 4092;
const int FEAT_SPELLS_RANGED_ATTACK             = 4093;
const int FEAT_SPELLS_CONCENTRATION_TARGET      = 4094;
const int FEAT_SPELLS_HOLD_CHARGE_TOGGLE        = 4095;

const int SPELLS_SPELLS_TOUCH_ATTACK            = 3042;
const int SPELLS_SPELLS_RANGED_ATTACK           = 3043;
const int SPELLS_SPELLS_CONCENTRATION_TARGET    = 3044;
const int SPELLS_SPELLS_HOLD_CHARGE_TOGGLE      = 3045;

#include "prc_alterations"
#include "prc_inc_unarmed"
//#include "psi_inc_manifest"
//#include "spinc_common"
//#include "prc_spell_const"
//#include "prc_inc_combat"

//Deletes local variables used for spell functions
//  To be called (or copied) on rest, from spellhook
void CleanSpellVariables(object oPC)
{
    DeleteLocalInt(oPC, PRC_SPELL_CHARGE_COUNT);
    DeleteLocalInt(oPC, PRC_SPELL_CHARGE_SPELLID);
    DeleteLocalInt(oPC, PRC_SPELL_CHARGE_LEVEL);
    DeleteLocalObject(oPC, PRC_SPELL_CONC_TARGET);
    DeleteLocalInt(oPC, PRC_SPELL_HOLD);
    DeleteLocalInt(oPC, PRC_SPELL_METAMAGIC);
    DeleteLocalManifestation(oPC, PRC_POWER_HOLD_MANIFESTATION);
    DeleteLocalMystery(oPC, "MYST_HOLD_MYST");
}

//Returns whether a spell is a touch spell
//  nSpellID, the spell id (row in spells.2da) of the spell
int IsTouchSpell(int nSpellID)
{
    return (Get2DACache("spells", "Range", nSpellID) == "T");
}

//Sets local variables for the new spell functions
//  object oCaster, the caster of the spell
//  int nCharges, the number of charges for a spell
//  int nSpellIDOverride, for overriding a SpellID
void SetLocalSpellVariables(object oCaster, int nCharges = 1, int nSpellIDOverride = -1)
{
    int nTemp = (nSpellIDOverride == -1) ? PRCGetSpellId() : nSpellIDOverride;
    SetLocalInt(oCaster, PRC_SPELL_CHARGE_SPELLID, nTemp);
    SetLocalInt(oCaster, PRC_SPELL_CHARGE_COUNT, nCharges);
    SetLocalInt(oCaster, PRC_SPELL_CHARGE_LEVEL, PRCGetCasterLevel(oCaster));
    SetLocalInt(oCaster, PRC_SPELL_METAMAGIC, PRCGetMetaMagicFeat());
    FloatingTextStringOnCreature("*Holding the Charge*", oCaster);

    object oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oCaster);
    if (GetIsPRCCreatureWeapon(oItem)) {
        RemoveEventScript(oItem, EVENT_ITEM_ONHIT, "prc_sp_event", TRUE, FALSE);
        // Add eventhook to the item
        AddEventScript(oItem, EVENT_ITEM_ONHIT, "prc_sp_event", TRUE, FALSE);

        // Add the OnHitCastSpell: Unique needed to trigger the event
        IPSafeAddItemProperty(oItem, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, 1), 91234.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
    }
}

//Decrements the number of spell charges
//  object oPC, the subject losing a charge
void DecrementSpellCharges(object oPC)
{
    int nCharges= GetLocalInt(oPC, PRC_SPELL_CHARGE_COUNT);
    SetLocalInt(oPC, PRC_SPELL_CHARGE_COUNT, nCharges - 1);
    FloatingTextStringOnCreature("Charges Remaining: " + IntToString(nCharges - 1), oPC);
}

//Called from scripts, will run a spell script with local int for flags
//  NOTE: Flags must be interpreted by the spell script
//  This lets spell scripts handle events the way they want
//
//  object oPC, the subject running the script
//  int nSpellID, the spellid of the spell to run
//  int nEventType, an integer containing flags defining events to use
void RunSpellScript(object oPC, int nSpellID, int nEventType)
{
    ClearAllActions();  //clears queue to prevent exploits
    SetLocalInt(oPC, PRC_SPELL_EVENT, nEventType);
    ActionCastSpell(nSpellID, 0, 0, 0, GetLocalInt(oPC, PRC_SPELL_METAMAGIC));
    DelayCommand(3.0, DeleteLocalInt(oPC, PRC_SPELL_EVENT));
}

//Called from scripts, will run a spell script with local int for flags
//  NOTE: This directly executes the impactscript of the spell, which mean
//        the spellid of any effect that get applied will be wrong.
//        Only use this when you are sure no effect will be apllied,
//        or if you really need to bypass the action queue.
void RunImpactScript(object oPC, int nSpellID, int nEventType)
{
    // we dont want to be running a 'fake' spellscript, as that will
    // use ActionCastSpell, which is exactly what we are trying to avoid
    int nRealSpell = GetPowerFromSpellID(nSpellID);
    if (nRealSpell == -1)
        nRealSpell = nSpellID;

    SetLocalInt(oPC, PRC_SPELL_EVENT, nEventType);
    SetLocalInt(oPC, PRC_SPELLID_OVERRIDE, nRealSpell);

    string sScript = Get2DACache("spells", "ImpactScript", nRealSpell);

    ExecuteScript(sScript, oPC);

    DeleteLocalInt(oPC, PRC_SPELL_EVENT);
    DeleteLocalInt(oPC, PRC_SPELLID_OVERRIDE);
}

//Returns true if the spell is one of the repair spells
int IsRepair(int nSpellID)
{
    return ((nSpellID >= SPELL_REPAIR_MINOR_DAMAGE) && (nSpellID <= SPELL_REPAIR_CRITICAL_DAMAGE));
}

//Returns true if the spell is one of the mass repair spells
int IsMassRepair(int nSpellID)
{
    return ((nSpellID >= SPELL_MASS_REPAIR_LIGHT_DAMAGE) && (nSpellID <= SPELL_MASS_REPAIR_CRITICAL_DAMAGE));
}

//Returns true if the spell is one of the mass inflict damage spells
int IsMassInflictDamage(int nSpellID)
{
    return ((nSpellID >= SPELL_MASS_INFLICT_LIGHT_DAMAGE) && (nSpellID <= SPELL_MASS_INFLICT_CRITICAL_DAMAGE));
}

//Returns true if the spell is one of the cure spells
int IsCure(int nSpellID)
{
    return ((nSpellID >= SPELL_CURE_CRITICAL_WOUNDS) && (nSpellID <= SPELL_CURE_SERIOUS_WOUNDS));
}

//Returns true if the spell is one of the mass cure spells
int IsMassCure(int nSpellID)
{
    return ((nSpellID >= SPELL_MASS_CURE_LIGHT) && (nSpellID <= SPELL_MASS_CURE_CRITICAL));
}

//Returns true if the spell is one of the mass inflict spells
int IsMassInflict(int nSpellID)
{
    return ((nSpellID >= SPELL_MASS_INFLICT_LIGHT) && (nSpellID <= SPELL_MASS_INFLICT_CRITICAL));
}

//Returns true for the spell Heal
int IsHeal(int nSpellID)
{
    return nSpellID == SPELL_HEAL
         || nSpellID == SPELL_MASS_HEAL;
}

//Returns true for the Mass Heal spell (Mass Harm if it ever gets made)
int IsMassHealHarm(int nSpellID)
{
    return nSpellID == SPELL_MASS_HEAL
         || nSpellID == SPELL_MASS_HARM;
}

//Returns whether an effect should be removed
int CheckRemoveEffects(int nSpellID, int nEffectType)
{
    switch(nSpellID)
    {
        case SPELL_GREATER_RESTORATION:
        {
            return(nEffectType == EFFECT_TYPE_ABILITY_DECREASE ||
                nEffectType == EFFECT_TYPE_AC_DECREASE ||
                nEffectType == EFFECT_TYPE_ATTACK_DECREASE ||
                nEffectType == EFFECT_TYPE_DAMAGE_DECREASE ||
                nEffectType == EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE ||
                nEffectType == EFFECT_TYPE_SAVING_THROW_DECREASE ||
                nEffectType == EFFECT_TYPE_SPELL_RESISTANCE_DECREASE ||
                nEffectType == EFFECT_TYPE_SKILL_DECREASE ||
                nEffectType == EFFECT_TYPE_BLINDNESS ||
                nEffectType == EFFECT_TYPE_DEAF ||
                nEffectType == EFFECT_TYPE_CURSE ||
                nEffectType == EFFECT_TYPE_DISEASE ||
                nEffectType == EFFECT_TYPE_POISON ||
                nEffectType == EFFECT_TYPE_PARALYZE ||
                nEffectType == EFFECT_TYPE_CHARMED ||
                nEffectType == EFFECT_TYPE_DOMINATED ||
                nEffectType == EFFECT_TYPE_DAZED ||
                nEffectType == EFFECT_TYPE_CONFUSED ||
                nEffectType == EFFECT_TYPE_FRIGHTENED ||
                nEffectType == EFFECT_TYPE_NEGATIVELEVEL ||
                nEffectType == EFFECT_TYPE_SLOW ||
                nEffectType == EFFECT_TYPE_STUNNED);
        }
        case SPELL_RESTORATION:
        {
            return(nEffectType == EFFECT_TYPE_ABILITY_DECREASE ||
                nEffectType == EFFECT_TYPE_AC_DECREASE ||
                nEffectType == EFFECT_TYPE_ATTACK_DECREASE ||
                nEffectType == EFFECT_TYPE_DAMAGE_DECREASE ||
                nEffectType == EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE ||
                nEffectType == EFFECT_TYPE_SAVING_THROW_DECREASE ||
                nEffectType == EFFECT_TYPE_SPELL_RESISTANCE_DECREASE ||
                nEffectType == EFFECT_TYPE_SKILL_DECREASE ||
                nEffectType == EFFECT_TYPE_BLINDNESS ||
                nEffectType == EFFECT_TYPE_DEAF ||
                nEffectType == EFFECT_TYPE_PARALYZE ||
                nEffectType == EFFECT_TYPE_NEGATIVELEVEL);
            break;
        }
        case SPELL_LESSER_RESTORATION:
        {
            return(nEffectType == EFFECT_TYPE_ABILITY_DECREASE ||
                nEffectType == EFFECT_TYPE_AC_DECREASE ||
                nEffectType == EFFECT_TYPE_ATTACK_DECREASE ||
                nEffectType == EFFECT_TYPE_DAMAGE_DECREASE ||
                nEffectType == EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE ||
                nEffectType == EFFECT_TYPE_SAVING_THROW_DECREASE ||
                nEffectType == EFFECT_TYPE_SPELL_RESISTANCE_DECREASE ||
                nEffectType == EFFECT_TYPE_SKILL_DECREASE);
            break;
        }
        case SPELL_REMOVE_BLINDNESS_AND_DEAFNESS:
        {
            return nEffectType == EFFECT_TYPE_BLINDNESS
                 || nEffectType == EFFECT_TYPE_DEAF;
        }
        case SPELL_REMOVE_CURSE:
        {
            return nEffectType == EFFECT_TYPE_CURSE;
        }
        case SPELL_CALM_EMOTIONS:
        {
            return nEffectType == EFFECT_TYPE_FRIGHTENED
                 || nEffectType == EFFECT_TYPE_CONFUSED;
        }
        case SPELLABILITY_REMOVE_DISEASE:
        case SPELL_REMOVE_DISEASE:
        {
            return (nEffectType == EFFECT_TYPE_DISEASE ||
                (GetPRCSwitch(PRC_BIOWARE_REMOVE_DISEASE) &&
                    nEffectType == EFFECT_TYPE_ABILITY_DECREASE));
        }
        case SPELL_NEUTRALIZE_POISON:
        {
            return (nEffectType == EFFECT_TYPE_POISON ||
                nEffectType == EFFECT_TYPE_DISEASE ||
                (GetPRCSwitch(PRC_BIOWARE_NEUTRALIZE_POISON) &&
                    nEffectType == EFFECT_TYPE_ABILITY_DECREASE));
        }
        case SPELL_PANACEA:
        {
            return (EFFECT_TYPE_BLINDNESS == nEffectType ||
                EFFECT_TYPE_CONFUSED == nEffectType ||
                EFFECT_TYPE_DAZED == nEffectType ||
                EFFECT_TYPE_DEAF == nEffectType ||
                EFFECT_TYPE_DISEASE == nEffectType ||
                EFFECT_TYPE_FRIGHTENED == nEffectType ||
                EFFECT_TYPE_PARALYZE == nEffectType ||
                EFFECT_TYPE_POISON == nEffectType ||
                EFFECT_TYPE_SLEEP == nEffectType ||
                EFFECT_TYPE_STUNNED == nEffectType);
        }
    }
    return FALSE;
}

int IsRaySpell(int nSpell)
{
    int nRealSpell = GetPowerFromSpellID(nSpell);
    if (nRealSpell != -1)
        nSpell = nRealSpell;
    return nSpell == SPELL_AVASCULAR_MASS     // avascular mass
    ||     nSpell == SPELL_AVASCULATE         // avasculate
    ||     nSpell == SPELL_DIMENSIONAL_ANCHOR // dimensional anchor
    ||     nSpell == SPELL_DISINTEGRATE       // disintegrate
    ||     nSpell == SPELL_POLAR_RAY          // polar ray
    ||     nSpell == SPELL_SLASHING_DARKNESS  // slashing darkness
    ||     nSpell == SPELL_RAY_OF_FROST       // ray of frost
    ||     nSpell == SPELL_ENERGY_DRAIN       // energy drain
    ||     nSpell == SPELL_ENERVATION         // enervate
    ||     nSpell == SPELL_RAY_OF_ENFEEBLEMENT    // ray of enfeeblement
    ||     nSpell == SPELL_NEGATIVE_ENERGY_RAY    // negative energy ray
    ||     nSpell == SPELL_SEARING_LIGHT      // searing light
    ||     nSpell == SPELL_SEEKING_RAY        // seeking ray
    ||     nSpell == SPELL_SCORCHING_RAY      // scorching ray
    ||     nSpell == SPELL_PRISMATIC_RAY      // prismatic ray
    ||     nSpell == SPELL_ELECTRIC_JOLT      // Electric Jolt
//  ||     nSpell ==    0) //
    ;
}
