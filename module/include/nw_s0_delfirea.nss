//::///////////////////////////////////////////////
//:: Delayed Blast Fireball: On Enter
//:: NW_S0_DelFireA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The caster creates a trapped area which detects
    the entrance of enemy creatures into 3 m area
    around the spell location.  When tripped it
    causes a fiery explosion that does 1d6 per
    caster level up to a max of 20d6 damage.
*/
//:://////////////////////////////////////////////
//:: Georg: Removed Spellhook, fixed damage cap
//:: Created By: Preston Watamaniuk
//:: Created On: July 27, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //Declare major variables
    aoesDeclareMajorVariables();
    if(GetLocalInt(aoe.AOE, "NW_SPELL_DELAY_BLAST_FIREBALL"))
    {
        return;
    }
    object oTarget = GetEnteringObject();
    location lTarget = GetLocation(aoe.AOE);
    int nDamage;
    int nCasterLevel = spell.Level;
    //Limit caster level
    if(nCasterLevel > 20)
    {
        nCasterLevel = 20;
    }
    effect eDam;
    effect eExplode = EffectVisualEffect(VFX_FNF_FIREBALL);
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_M);
    //Check the faction of the entering object to make sure the entering object is not in the casters faction
    if(spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, aoe.Creator))
    {
        SetLocalInt(aoe.AOE, "NW_SPELL_DELAY_BLAST_FIREBALL", TRUE);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, lTarget);
        //Cycle through the targets in the explosion area
        oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        while(GetIsObjectValid(oTarget))
        {
            if(spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, aoe.Creator))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
                //Make SR check
                if(!MyResistSpell(aoe.Creator, oTarget))
                {
                    nDamage = MaximizeOrEmpower(6,nCasterLevel,spell.Meta);
                    //Change damage according to Reflex, Evasion and Improved Evasion
                    nDamage = GetReflexAdjustedDamage(nDamage, oTarget, spell.DC, SAVING_THROW_TYPE_FIRE, aoe.Creator);

                    if(nDamage > 0)
                    {
                        //Set up the damage effect
                        eDam = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
                        //Apply VFX impact and damage effect
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                        DelayCommand(0.01, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    }
                }
            }
            //Get next target in the sequence
            oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        }
        DestroyObject(aoe.AOE, 1.0);
    }
}
