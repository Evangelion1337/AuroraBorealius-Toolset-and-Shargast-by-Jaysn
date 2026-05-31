//::///////////////////////////////////////////////
//:: Astral Construct spawn include
//:: psi_inc_ac_spawn
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Ornedan
//:: Created On: 21.01.2005
//:://////////////////////////////////////////////

#include "psi_inc_ac_const"
#include "prc_ipfeat_const"
#include "prc_feat_const"
#include "inc_vfx_const"
#include "prc_inc_nwscript"


//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////
void HandleAstralConstructSpawn(object oConstruct);
void DoEffect(object oConstruct, effect eEffect);
void DoFeat(object oHide, int nIPFeatID);
void DoDeflect(object oConstruct, int nACVal);
void DoResistance(object oHide, int nElementFlags);
void DoEnergyTouch(object oWeapon, int nElementFlags, object oCreator);
int GetConstructSizeFromTag(object oConstruct);
int GetBaseDamageFromSize(int nSize);
int GetNextBaseDamage(int nDamVal);
int GetDamageReduction(object oConstruct);
int GetDamageReductionConstantFromAmount(int nDamRed);


//void ActionUseInstantPower( invalid );

//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

// Applies the chosen Astral Construct options to the creature.
//
// Note! Buff series is handled separately
void HandleAstralConstructSpawn(object oConstruct)
{
    // Get the flag set
    int nFlags = GetLocalInt(oConstruct, ASTRAL_CONSTRUCT_OPTION_FLAGS);
    // Get the construct's size and use it to determine the base attack damage
    int nSize  = GetConstructSizeFromTag(oConstruct);

    if (nSize < CREATURE_SIZE_SMALL)
    {
        WriteTimestampedLogEntry("Invalid construct size: " + IntToString(nSize) + " for appearance " + IntToString(GetAppearanceType(oConstruct)));
    }

    if (DEBUG) WriteTimestampedLogEntry("Creating construct " + GetTag(oConstruct) + " of size " + IntToString(nSize));

    string sWeaponResRef = ASTRAL_CONSTRUCT_SLAM;
    object oHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oConstruct);

    /* Check through the flags and take appropriate action */

    /// The Deflect series
    int nDeflect = 0;
    // Add +1 deflection AC
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_DEFLECTION)      { nDeflect += 1; }
    // Add +4 deflection AC
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_HEAVY_DEFLECT)   { nDeflect += 4; }
    // Add +8 deflection AC
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_EXTREME_DEFLECT) { nDeflect += 8; }

    if(nDeflect) DoDeflect(oConstruct, nDeflect);

    if (DEBUG) WriteTimestampedLogEntry("  Construct deflection AC: " + IntToString(nDeflect));

    /// The Damage reductions
    // First, get the base damage reduction
    int nDamRed = GetDamageReduction(oConstruct);
    // Increases the damage reduction variable by 3
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_IMP_DAM_RED)     { nDamRed += 3; }
    // Increases the damage reduction variable by 6
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_EXTREME_DAM_RED) { nDamRed += 6; }

    if (DEBUG) WriteTimestampedLogEntry("  Construct damage reduction: " + IntToString(nDamRed));

    if(nDamRed)
    {
        nDamRed = GetDamageReductionConstantFromAmount(nDamRed);
        itemproperty ipDamRed = ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_1, nDamRed);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipDamRed, oHide);
    }

    /// Add various feats to the hide
    // Add the Cleave feat to slam
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_CLEAVE)       
    { 
        if (DEBUG) WriteTimestampedLogEntry("  Added feat: Cleave");
        DoFeat(oHide, IP_CONST_FEAT_CLEAVE); 
    }
    // Add the Mobility feat to hide
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_MOBILITY)     
    { 
        if (DEBUG) WriteTimestampedLogEntry("  Added feat: Mobility");
        DoFeat(oHide, IP_CONST_FEAT_MOBILITY); 
    }
    // Add the Power Attack feat to hide
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_POWER_ATTACK) 
    { 
        if (DEBUG) WriteTimestampedLogEntry("  Added feat: Power Attack");
        DoFeat(oHide, IP_CONST_FEAT_POWERATTACK); 
    }
    // Add the Knockdown feat to hide
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_KNOCKDOWN)    
    { 
        if (DEBUG) WriteTimestampedLogEntry("  Added feat: Knockdown");
        DoFeat(oHide, IP_CONST_FEAT_KNOCKDOWN); 
    }
    // Add the Improved Critical (Creature) feat to hide
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_IMP_CRIT)     
    { 
        if (DEBUG) WriteTimestampedLogEntry("  Added feat: Improved Critical");
        DoFeat(oHide, IP_CONST_FEAT_ImpCritCreature); 
    }
    // Add the Blindsight feat to hide
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_BLINDFIGHT)   
    { 
        if (DEBUG) WriteTimestampedLogEntry("  Added feat: Blind Fight");
        DoFeat(oHide, IP_CONST_FEAT_BLINDFIGHT); 
    }
    // Add feat for spell/power resistance 10+HD to hide
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_POWER_RESIST) 
    { 
        if (DEBUG) WriteTimestampedLogEntry("  Added feat: Power Resistance");
        DoFeat(oHide, IP_CONST_FEAT_SPELL10); 
    }
    // Add the Rend feat to hide
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_REND)         
    { 
        if (DEBUG) WriteTimestampedLogEntry("  Added feat: Rend");
        DoFeat(oHide, IP_CONST_FEAT_REND); 
        sWeaponResRef = ASTRAL_CONSTRUCT_CLAW; 
    }
    // Add the Spring Attack feat to hide
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_SPRING_ATTACK) 
    { 
        if (DEBUG) WriteTimestampedLogEntry("  Added feat: Spring Attack");
        DoFeat(oHide, IP_CONST_FEAT_SPRINGATTACK); 
    }
    // Add the Whirlwind feat to hide
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_WHIRLWIND)    
    { 
        if (DEBUG) WriteTimestampedLogEntry("  Added feat: Whirlwind");
        DoFeat(oHide, IP_CONST_FEAT_WHIRLWIND); 
    }


    /// Add various itemproperties to the hide
    // Adds regeneration 2 to hide
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_FAST_HEALING)
    {
        itemproperty ipRegen = ItemPropertyRegeneration(2);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipRegen, oHide);
        if (DEBUG) WriteTimestampedLogEntry("  Added fast healing 2");
    }
    // Give a +4 STR bonus to hide
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_MUSCLE)
    {
        itemproperty ipSTR = ItemPropertyAbilityBonus(IP_CONST_ABILITY_STR, 4);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipSTR, oHide);
        if (DEBUG) WriteTimestampedLogEntry("  Added muscle (+4 STR)");
    }
    // Add energy resistance 5 to chosen elements
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_RESISTANCE)
    {
        DoResistance(oHide, GetLocalInt(oConstruct, ASTRAL_CONSTRUCT_RESISTANCE_FLAGS));
        if (DEBUG) WriteTimestampedLogEntry("  Added energy resistance 5");
    }

    /// Handle effects

    // Add the transparency effect
    effect eVis =  EffectVisualEffect(VFX_DUR_GHOSTLY_PULSE_QUICK);//VFX_DUR_GHOST_TRANSPARENT);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eVis, oConstruct);

    // Increase speed by 10 feet per round
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_CELERITY)
    {
        int nSpeedIncrease;
        switch(nSize)
        {
            case CREATURE_SIZE_SMALL:
                nSpeedIncrease = 33;
                break;
            case CREATURE_SIZE_MEDIUM:
            case CREATURE_SIZE_LARGE:
                nSpeedIncrease = 25;
                break;
            case CREATURE_SIZE_HUGE:
                nSpeedIncrease = 20;
                break;
            default:
                if (DEBUG) WriteTimestampedLogEntry("Invalid size value for an Astral Construct encountered when processing Celerity");
                nSpeedIncrease = 0;
                break;
        }

        effect eSpeed = EffectMovementSpeedIncrease(nSpeedIncrease);
        DoEffect(oConstruct, eSpeed);
        if (DEBUG) WriteTimestampedLogEntry("  Added celerity (" + IntToString(nSpeedIncrease) + "% increase)");
    }
    // Add one attack
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_EXTRA_ATTACK)
    {
        effect eAttack = EffectModifyAttacks(1);
        DoEffect(oConstruct, eAttack);
        if (DEBUG) WriteTimestampedLogEntry("  Added extra attack");
    }
    // Applies 50% concealement and a normal invisibility effect to the construct to
    // simulate permanent invisibility
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_NATURAL_INVIS)
    {
        effect eConceal = EffectConcealment(50);
        effect eInvis   = EffectInvisibility(INVISIBILITY_TYPE_NORMAL);
        DoEffect(oConstruct, eConceal);
        DoEffect(oConstruct, eInvis);
        if (DEBUG) WriteTimestampedLogEntry("  Added natural invisibility");
    }




    /* Start handling the creature weapon stuff */

    // First, actually create the weapon and equip it
    object oWeapon = CreateItemOnObject(sWeaponResRef, oConstruct);
    AssignCommand(oConstruct, ActionEquipItem(oWeapon, INVENTORY_SLOT_CWEAPON_B));

    /// Handle the damage that it will deal

    // Get the base damage
    int nAttackBaseDamage = GetBaseDamageFromSize(nSize);

    if (DEBUG) WriteTimestampedLogEntry("  Set base damage to " + IntToString(nAttackBaseDamage));
    // Check if the damage needs to be increased
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_IMPROVED_SLAM) 
    { 
        nAttackBaseDamage = GetNextBaseDamage(nAttackBaseDamage); 
        if (DEBUG) WriteTimestampedLogEntry("  Added feat: Improved Slam");
    }

    // Apply the monster damage iprop to the weapon
    itemproperty ipDam = ItemPropertyMonsterDamage(nAttackBaseDamage);
    AddItemProperty(DURATION_TYPE_PERMANENT, ipDam, oWeapon);

    // Add damage bonus equal to 0.5 times the creature's strength modifier.
    // The Astral Constructs should have it since they only have one natural attack (and no other attacks)
    int nStrBon = GetAbilityModifier(ABILITY_STRENGTH, oConstruct) / 2;
        nStrBon = nStrBon < 0  ? 0 : nStrBon;
        nStrBon = nStrBon > 10 ? 10: nStrBon;

    // The Extra Attacks modifier cancels 1.5x STR bonus, so check for it's presence
    if(nStrBon && !(nFlags & ASTRAL_CONSTRUCT_OPTION_EXTRA_ATTACK) && nSize < CREATURE_SIZE_LARGE)
    {
        // The following is a *wrong* way of doing this and will break the moment BW decides to modify
        // the actual values of the IP_CONST_DAMAGEBONUS_* constants, but I'm lazy :p
        int nDamBon = nStrBon > 5 ? nStrBon + 10 : nStrBon;
        int nDamageType = sWeaponResRef == ASTRAL_CONSTRUCT_SLAM ?
                                             IP_CONST_DAMAGETYPE_BLUDGEONING :
                                             IP_CONST_DAMAGETYPE_SLASHING;
        itemproperty ipDamBon = ItemPropertyDamageBonus(nDamageType, nDamBon);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipDamBon, oWeapon);
    }


    // Apply OnHitCast power if necessary
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_POISON_TOUCH ||
       nFlags & ASTRAL_CONSTRUCT_OPTION_REND)
    {
        itemproperty ipOnHitCast = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, 1);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipOnHitCast, oWeapon);
    }

    // Handle Energy Touch option
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_ENERGY_TOUCH)
    {
        DoEnergyTouch(oWeapon, GetLocalInt(oConstruct, ASTRAL_CONSTRUCT_ENERGY_TOUCH_FLAGS), GetMaster(oConstruct));
    }


    /// Handle options that set local ints

    // Add OnHit: CastSpell - Unique Power to the slam
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_POISON_TOUCH) { SetLocalInt(oConstruct, ASTRAL_CONSTRUCT_POISON_TOUCH, TRUE); }
    // Make the construct capable of using Concussion Blast power as a free action every round
    // Will probably be implemented via heartbeat
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_CONCUSSION)   { SetLocalInt(oConstruct, ASTRAL_CONSTRUCT_CONCUSSION, TRUE); }



    /********************* UNFINISHED POWERS *********************/

    // Allow the construct to use Dimension Slide as a move action every round
    // COMPLETELY UNIMPLEMENTED AS OF YET
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_DIMENSION_SLIDE)
    {
        WriteTimestampedLogEntry("Astral Construct created with flag ASTRAL_CONSTRUCT_OPTION_DIMENSION_SLIDE. This option shouldn't be available yet.");
    }
    // Allow the construct to use Energy Bolt as a standard action every round
    // COMPLETELY UNIMPLEMENTED AS OF YET
    if(nFlags & ASTRAL_CONSTRUCT_OPTION_ENERGY_BOLT)
    {
        WriteTimestampedLogEntry("Astral Construct created with flag ASTRAL_CONSTRUCT_OPTION_ENERGY_BOLT. This option shouldn't be available yet.");
    }
}



// Extraordinaries and applies the given effect
void DoEffect(object oConstruct, effect eEffect)
{
    eEffect = ExtraordinaryEffect(eEffect);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oConstruct);
}


// Adds the given feat to the AC's hide. Nothing special, just
// a convenience so I needn't typ(e/o) it several times
void DoFeat(object oHide, int nIPFeatID)
{
    itemproperty ipFeat = PRCItemPropertyBonusFeat(nIPFeatID);
    AddItemProperty(DURATION_TYPE_PERMANENT, ipFeat, oHide);
}


// Does the work of the Deflect series of effects
void DoDeflect(object oConstruct, int nACVal)
{
    effect eAC = EffectACIncrease(nACVal, AC_DEFLECTION_BONUS);
    DoEffect(oConstruct, eAC);
}


// Adds the given resistances to the construct's hide
void DoResistance(object oHide, int nElementFlags)
{
    itemproperty ipResist;

    if(nElementFlags & ELEMENT_ACID)
    {
        ipResist = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_ACID, IP_CONST_DAMAGERESIST_5);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipResist, oHide);
    }
    if(nElementFlags & ELEMENT_COLD)
    {
        ipResist = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_COLD, IP_CONST_DAMAGERESIST_5);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipResist, oHide);
    }
    if(nElementFlags & ELEMENT_ELECTRICITY)
    {
        ipResist = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_ELECTRICAL, IP_CONST_DAMAGERESIST_5);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipResist, oHide);
    }
    if(nElementFlags & ELEMENT_FIRE)
    {
        ipResist = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_FIRE, IP_CONST_DAMAGERESIST_5);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipResist, oHide);
    }
    if(nElementFlags & ELEMENT_SONIC)
    {
        ipResist = ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_SONIC, IP_CONST_DAMAGERESIST_5);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipResist, oHide);
    }
}


// Adds 1d4 (or 1d6 if oCreator is a kineticist) of the chosen types of elemental damage
// to the construct's weapon
void DoEnergyTouch(object oWeapon, int nElementFlags, object oCreator)
{
    itemproperty ipDamage;
    int nDamage = GetHasFeat(FEAT_PSION_DIS_KINETICIST, oCreator) ? IP_CONST_DAMAGEBONUS_1d6 : IP_CONST_DAMAGEBONUS_1d4;

    if(nElementFlags & ELEMENT_ACID)
    {
        ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_ACID, nDamage);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipDamage, oWeapon);
    }
    if(nElementFlags & ELEMENT_COLD)
    {
        ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_COLD, nDamage);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipDamage, oWeapon);
    }
    if(nElementFlags & ELEMENT_ELECTRICITY)
    {
        ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_ELECTRICAL, nDamage);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipDamage, oWeapon);
    }
    if(nElementFlags & ELEMENT_FIRE)
    {
        ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_FIRE, nDamage);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipDamage, oWeapon);
    }
    if(nElementFlags & ELEMENT_SONIC)
    {
        ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_SONIC, nDamage);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipDamage, oWeapon);
    }
}


/* Returns the base damage an AC's attacks should deal based on it's size
 *  Small   - 1d4
 *  Medium  - 1d6
 *  Large   - 1d8
 *  Huge    - 2d6
 */
int GetBaseDamageFromSize(int nSize)
{
    switch(nSize)
    {
        case CREATURE_SIZE_SMALL:
            return IP_CONST_MONSTERDAMAGE_1d4;
        case CREATURE_SIZE_MEDIUM:
            return IP_CONST_MONSTERDAMAGE_1d6;
        case CREATURE_SIZE_LARGE:
            return IP_CONST_MONSTERDAMAGE_1d8;
        case CREATURE_SIZE_HUGE:
            return IP_CONST_MONSTERDAMAGE_2d6;
        default:
            WriteTimestampedLogEntry("Invalid size value for an Astral Construct passed to GetBaseDamageFromSize: " + IntToString(nSize));
    }

    return IP_CONST_MONSTERDAMAGE_1d4;
}

// Returns the next bigger damage value
int GetNextBaseDamage(int nDamVal)
{
    switch(nDamVal)
    {
        case IP_CONST_MONSTERDAMAGE_1d4: return IP_CONST_MONSTERDAMAGE_1d6;
        case IP_CONST_MONSTERDAMAGE_1d6: return IP_CONST_MONSTERDAMAGE_1d8;
        case IP_CONST_MONSTERDAMAGE_1d8: return IP_CONST_MONSTERDAMAGE_2d6;
        case IP_CONST_MONSTERDAMAGE_2d6: return IP_CONST_MONSTERDAMAGE_3d6;
        default:
            WriteTimestampedLogEntry("Invalid monster damage value passed to GetNextBaseDamage: " + IntToString(nDamVal));
    }

    return IP_CONST_MONSTERDAMAGE_1d4;
}


// Returns the size of the construct based on its level
int GetConstructSizeFromTag(object oConstruct)
{
    string sTag = GetTag(oConstruct);
    int nLevel = StringToInt(GetSubString(sTag, 14, 1));

    switch(nLevel)
    {
        case 1: return CREATURE_SIZE_SMALL;
        case 2:
        case 3:
        case 4: return CREATURE_SIZE_MEDIUM;
        case 5: 
        case 6:
        case 7: 
        case 8: return CREATURE_SIZE_LARGE;
        case 9: return CREATURE_SIZE_HUGE;

        default:
            WriteTimestampedLogEntry("Erroneous value for nLevel in GetDamageReduction: " + IntToString(nLevel) + ", tag: " + sTag);
    }

    return 0;
}

// Returns the damage reduction that the level of the construct entitles it to
int GetDamageReduction(object oConstruct)
{
    string sTag = GetTag(oConstruct);
    int nLevel = StringToInt(GetSubString(sTag, 14, 1));

    switch(nLevel)
    {
        case 1:
        case 2:
        case 3:
        case 4: return 0;
        case 5: return 5;
        case 6:
        case 7: return 10;
        case 8:
        case 9: return 15;

        default:
            WriteTimestampedLogEntry("Erroneous value for nLevel in GetDamageReduction: " + IntToString(nLevel) + ", tag: " + sTag);
    }

    return 0;
}


// Returns the IP_CONST_DAMAGESOAK_*_HP constant that does the given
// amount of damage reduction
int GetDamageReductionConstantFromAmount(int nDamRed)
{
    switch(nDamRed)
    {
        case 3:  return IP_CONST_DAMAGESOAK_3_HP;
        case 5:  return IP_CONST_DAMAGESOAK_5_HP;
        case 6:  return IP_CONST_DAMAGESOAK_6_HP;
        case 8:  return IP_CONST_DAMAGESOAK_8_HP;
        case 9:  return IP_CONST_DAMAGESOAK_9_HP;
        case 10: return IP_CONST_DAMAGESOAK_10_HP;
        case 11: return IP_CONST_DAMAGESOAK_11_HP;
        case 13: return IP_CONST_DAMAGESOAK_13_HP;
        case 14: return IP_CONST_DAMAGESOAK_14_HP;
        case 15: return IP_CONST_DAMAGESOAK_15_HP;
        case 16: return IP_CONST_DAMAGESOAK_16_HP;
        case 19: return IP_CONST_DAMAGESOAK_19_HP;
        case 18: return IP_CONST_DAMAGESOAK_18_HP;
        case 21: return IP_CONST_DAMAGESOAK_21_HP;
        case 24: return IP_CONST_DAMAGESOAK_24_HP;

        default:
            WriteTimestampedLogEntry("Erroneous value for nDamRed in GetDamageReductionAmountToConstant: " + IntToString(nDamRed));
    }

    return -1;
}