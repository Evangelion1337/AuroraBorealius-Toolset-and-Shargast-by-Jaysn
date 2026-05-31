//::///////////////////////////////////////////////
//:: Creeping Doom: Heartbeat
//:: NW_S0_CrpDoomC.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature caught in the swarm take an initial
    damage of 1d20, but there after they take
    1d6 per swarm counter on the AOE.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 17, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- did no damage last round where AOE reached 1k dmg
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //Declare major variables
    aoesDeclareMajorVariables();
    int nDamCount = GetLocalInt(aoe.AOE, "NW_SPELL_CONSTANT_CREEPING_DOOM2");
    if(nDamCount >= 1000 || !GetIsObjectValid(aoe.Creator))
    {
        DestroyObject(aoe.AOE, 1.0);
        return;
    }
    int nSwarm = GetLocalInt(aoe.AOE, "NW_SPELL_CONSTANT_CREEPING_DOOM1")+1;
    int nDamage;
    effect eDam;
    effect eVis = EffectVisualEffect(VFX_COM_BLOOD_REG_RED);
    float fDelay;

    //Get first target in spell area
    object oTarget = GetFirstInPersistentObject(aoe.AOE);
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, aoe.Creator))
        {
            fDelay = GetRandomDelay(1.0, 2.2);
            //------------------------------------------------------------------
            // According to the book, SR Does not count against creeping doom
            //------------------------------------------------------------------
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
            //Roll Damage
            nDamage = d6(nSwarm);
            //Set Damage Effect with the modified damage
            eDam = EffectDamage(nDamage, DAMAGE_TYPE_PIERCING);
            //Apply damage and visuals
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
            nDamCount = nDamCount + nDamage;
        }
        //Get next target in spell area
        oTarget = GetNextInPersistentObject(aoe.AOE);
    }
    SetLocalInt(aoe.AOE, "NW_SPELL_CONSTANT_CREEPING_DOOM1", nSwarm);
    SetLocalInt(aoe.AOE, "NW_SPELL_CONSTANT_CREEPING_DOOM2", nDamCount);
}
