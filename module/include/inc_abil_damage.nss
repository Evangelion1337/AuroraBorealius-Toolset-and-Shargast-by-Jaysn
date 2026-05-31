//::///////////////////////////////////////////////
//:: Ability Damage special effects include
//:: inc_abil_damage
//:://////////////////////////////////////////////
/** @file
    Implements the special effects of an ability
    score falling down to 0 as according to PnP.

    Strength: Lies helpless on ground (knockdown)
    Dexterity: Paralyzed
    Constitution: Death
    Intelligence: Coma (knockdown)
    Wisdom: Coma (knockdown)
    Charisma: Coma (knockdown)


    This can be turned off with a switch in
    prc_inc_switches : PRC_NO_PNP_ABILITY_DAMAGE


    NOTE: Due to BioOptimization (tm), Dex reaching
    0 from above 3 when any other stat is already
    at 0 will result in Dex being considered
    restored at the same time the other stat is.

    This might be workable around, but not
    efficiently.
*/
//:://////////////////////////////////////////////
//:: Created By: Ornedan
//:: Created On: 09.04.2005
//:: Modified On: 25.06.2005
//:://////////////////////////////////////////////

/*
[00:55] <Stratovarius> yup
[00:56] <Stratovarius> well, something to add
[00:56] <Stratovarius> if KTTS reduces target to 0 (or would, i know NWN goes to 3)
[00:56] <Stratovarius> drop a cutscene paralyze on em
[00:56] <Stratovarius> and a long duration knockdown
[01:00] <Ornedan> 'k. And spawn a pseudo-hb on them to do recovery if they ever regain the mental stat
[01:01] <Ornedan> Also, test result: You lose spellcasting if your casting stat drops below the required, even if the reduction is a magical penalty
[01:03] <Stratovarius> you do? cool
*/

//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

// Internal function. Called by a threadscript. Handles checking if any ability that has reached 0 has been restored
void AbilityDamageMonitor();

// Dex needs special handling due to the way CutsceneParalyze works (sets Dex to 3)
void DoDexCheck(object oCreature, int bFirstPart = TRUE);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

//#include "prc_inc_spells"
#include "prc_inc_damage"	//functions to apply damage

//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

void AbilityDamageMonitor()
{
    object oCreature = OBJECT_SELF;
    int nMonitoredAbilities = GetLocalInt(oCreature, ABILITY_DAMAGE_MONITOR);
    int nEffects            = GetLocalInt(oCreature, ABILITY_DAMAGE_SPECIALS);

    if (DEBUG) DoDebug("AbilityDamageMonitor running");

    // Check each of the monitored abilities
    if(nMonitoredAbilities & (1 << ABILITY_STRENGTH))
    {
        if(GetAbilityScore(oCreature, ABILITY_STRENGTH) > 3)
        {
            DeleteLocalInt(oCreature, VIRTUAL_ABILITY_SCORE + IntToString(ABILITY_STRENGTH));
            SetLocalInt(oCreature, ABILITY_DAMAGE_MONITOR, GetLocalInt(oCreature, ABILITY_DAMAGE_MONITOR) ^ (1 << ABILITY_STRENGTH));
            if (DEBUG) DoDebug("AbilityDamageMonitor Strength healed");
        }
    }
    /*if(nMonitoredAbilities & (1 << ABILITY_DEXTERITY))
    {
        if(GetAbilityScore(oCreature, ABILITY_DEXTERITY) > 3)
        {
            DeleteLocalInt(oCreature, VIRTUAL_ABILITY_SCORE + IntToString(ABILITY_DEXTERITY));
            SetLocalInt(oCreature, ABILITY_DAMAGE_MONITOR, GetLocalInt(oCreature, ABILITY_DAMAGE_MONITOR) ^ (1 << ABILITY_DEXTERITY));
        }
    }*/
    if(nMonitoredAbilities & (1 << ABILITY_INTELLIGENCE))
    {
        if(GetAbilityScore(oCreature, ABILITY_INTELLIGENCE) > 3)
        {
            DeleteLocalInt(oCreature, VIRTUAL_ABILITY_SCORE + IntToString(ABILITY_INTELLIGENCE));
            SetLocalInt(oCreature, ABILITY_DAMAGE_MONITOR, GetLocalInt(oCreature, ABILITY_DAMAGE_MONITOR) ^ (1 << ABILITY_INTELLIGENCE));
            if (DEBUG) DoDebug("AbilityDamageMonitor Int healed");
        }
    }
    if(nMonitoredAbilities & (1 << ABILITY_WISDOM))
    {
        if(GetAbilityScore(oCreature, ABILITY_WISDOM) > 3)
        {
            DeleteLocalInt(oCreature, VIRTUAL_ABILITY_SCORE + IntToString(ABILITY_WISDOM));
            SetLocalInt(oCreature, ABILITY_DAMAGE_MONITOR, GetLocalInt(oCreature, ABILITY_DAMAGE_MONITOR) ^ (1 << ABILITY_WISDOM));
            if (DEBUG) DoDebug("AbilityDamageMonitor Wis healed");
        }
    }
    if(nMonitoredAbilities & (1 << ABILITY_CHARISMA))
    {
        if(GetAbilityScore(oCreature, ABILITY_CHARISMA) > 3)
        {
            DeleteLocalInt(oCreature, VIRTUAL_ABILITY_SCORE + IntToString(ABILITY_CHARISMA));
            SetLocalInt(oCreature, ABILITY_DAMAGE_MONITOR, GetLocalInt(oCreature, ABILITY_DAMAGE_MONITOR) ^ (1 << ABILITY_CHARISMA));
            if (DEBUG) DoDebug("AbilityDamageMonitor Cha healed");
        }
    }

    // Check which effects, if any, need to be removed
    int bRemovePara, bRemoveKnock;
    nMonitoredAbilities = GetLocalInt(oCreature, ABILITY_DAMAGE_MONITOR);
    if(!(nMonitoredAbilities & (1 << ABILITY_STRENGTH)     ||
         nMonitoredAbilities & (1 << ABILITY_INTELLIGENCE) ||
         nMonitoredAbilities & (1 << ABILITY_WISDOM)       ||
         nMonitoredAbilities & (1 << ABILITY_CHARISMA)
      ) )
    {
        // Only remove effects if they are present
        if(nEffects & ABILITY_DAMAGE_EFFECT_KNOCKDOWN)
        {
            bRemoveKnock = TRUE;
            nEffects ^= ABILITY_DAMAGE_EFFECT_KNOCKDOWN;
        }
        if(!(nMonitoredAbilities & (1 << ABILITY_DEXTERITY)))
        {
            if(nEffects & ABILITY_DAMAGE_EFFECT_PARALYZE)
            {
                bRemovePara = TRUE;
                nEffects ^= ABILITY_DAMAGE_EFFECT_KNOCKDOWN;
            }
        }
        // Dex is the only remaining stat keeping CutscenePara on, so run the dexcheck
        else
            DelayCommand(0.1f, DoDexCheck(oCreature, TRUE));

        SetLocalInt(oCreature, ABILITY_DAMAGE_SPECIALS, nEffects);
    }

    if (DEBUG) DoDebug("AbilityDamageMonitor bRemovePara:" + IntToString(bRemovePara));
    if (DEBUG) DoDebug("AbilityDamageMonitor bRemoveKnock:" + IntToString(bRemoveKnock));

    // Do effect removal
    if(bRemovePara || bRemoveKnock)
    {
        effect eCheck = GetFirstEffect(oCreature);
        while(GetIsEffectValid(eCheck))
        {
            if(bRemovePara && GetEffectType(eCheck) == EFFECT_TYPE_CUTSCENE_PARALYZE){
                if (DEBUG) DoDebug("AbilityDamageMonitor Removed para");
                RemoveEffect(oCreature, eCheck);
            }
            else if(bRemoveKnock && GetEffectType(eCheck) == 0){
                RemoveEffect(oCreature, eCheck);
                if (DEBUG) DoDebug("AbilityDamageMonitor Removed knock");
            }
            eCheck = GetNextEffect(oCreature);
        }
    }
    if (DEBUG) DoDebug("AbilityDamageMonitor Monitored abilities:" + IntToString(nMonitoredAbilities));

    // Stop the thread if there is nothing to monitor anymore
    if(!nMonitoredAbilities)
        TerminateCurrentThread();
}

void DoDexCheck(object oCreature, int bFirstPart = TRUE)
{
    // Remove CutscenePara
    if(bFirstPart)
    {
        effect eCheck = GetFirstEffect(oCreature);
        while(GetIsEffectValid(eCheck))
        {
            if(GetEffectType(eCheck) == EFFECT_TYPE_CUTSCENE_PARALYZE)
                RemoveEffect(oCreature, eCheck);
            eCheck = GetNextEffect(oCreature);
        }

        DelayCommand(0.1f, DoDexCheck(oCreature, FALSE));
        if (DEBUG) DoDebug("First part ran");
    }
    // Check if Dex is over 3 when it's gone
    else
    {
        // It is, so remove Dex from the monitored list
        if(GetAbilityScore(oCreature, ABILITY_DEXTERITY) > 3)
        {
            DeleteLocalInt(oCreature, VIRTUAL_ABILITY_SCORE + IntToString(ABILITY_DEXTERITY));
            SetLocalInt(oCreature, ABILITY_DAMAGE_MONITOR, GetLocalInt(oCreature, ABILITY_DAMAGE_MONITOR) ^ (1 << ABILITY_DEXTERITY));
            if (DEBUG) DoDebug("Dex check +");
        }
        /*else
            SendMessageToPC(GetFirstPC(), "Dex check -");*/

        // Apply CutscenePara back in either case. Next monitor call will remove it if it's supposed to be gone
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneParalyze(), oCreature);
    }
}



// Test main
//void main(){}
