//::///////////////////////////////////////////////
//:: Black Blade of Disaster
//:: X2_S0_BlckBlde
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Summons a greatsword to battle for the caster
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 26, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Georg Zoeller, July 28 - 2003
/*
Patch 1.70

- enhancement bonus wasn't calculated properly
- concentration check now take in consideration also these actions:
    - recover trap
    - examine trap
    - set trap
    - open lock
    - lock
*/

#include "70_inc_spells"
#include "x2_i0_spells"

//Creates the weapon that the creature will be using.
void spellsCreateItemForSummoned(object oCaster, int nStat)
{
    object oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED,oCaster);
    if(oSummon == OBJECT_INVALID)
    {
        return;//safety check
    }
    // Make the blade require concentration
    SetLocalInt(oSummon,"X2_L_CREATURE_NEEDS_CONCENTRATION",TRUE);
    SetPlotFlag(oSummon,TRUE);
    //Create item on the creature, epuip it and add properties.
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oSummon);
    if(nStat > 0 && GetIsObjectValid(oWeapon))
    {
        IPSafeAddItemProperty(oWeapon, ItemPropertyEnhancementBonus(nStat > 20 ? 20 : nStat), 0.0, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
    }
    SetDroppableFlag(oWeapon, FALSE);
}

#include "x2_inc_spellhook"

void main()
{
/*
  Spellcast Hook Code
  Added 2003-07-07 by Georg Zoeller
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more

*/

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

// End of Spell Cast Hook

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration = spell.Level;
    effect eSummon = EffectSummonCreature("x2_s_bblade");
    effect eVis = EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_3);
    //Make metamagic check for extend
    if(spell.Meta == METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;//Duration is +100%
    }
    //Apply the VFX impact and summon effect
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eVis, spell.Loc);
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spell.Loc, RoundsToSeconds(nDuration));

    //enhancement bonus calculation
    int nStat;
    // cast from scroll or wand, we just assume +5 ability modifier
    if(spell.Item != OBJECT_INVALID)
    {
        nStat = 5;
    }
    else if(spell.Class == CLASS_TYPE_WIZARD)
    {
        nStat = GetAbilityModifier(ABILITY_INTELLIGENCE, spell.Caster);
    }
    else
    {
        nStat = GetAbilityModifier(ABILITY_CHARISMA, spell.Caster);
    }
    DelayCommand(1.5, spellsCreateItemForSummoned(spell.Caster, nStat));
}
