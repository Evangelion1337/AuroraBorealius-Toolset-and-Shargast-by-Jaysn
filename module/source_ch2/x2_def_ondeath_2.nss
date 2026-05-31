//::///////////////////////////////////////////////
//:: Default: On Death
//:: OnDeath Event for Creatures
//:: Modified By: Brian J. Kittrell
//:://////////////////////////////////////////////
#include "NW_I0_GENERIC"

//:: MAXHP represents the maximum number of
//:: hit points your strongest monster has.
//:: Set it high to make sure monsters with
//:: a lower hit point value than what is defined
//:: here are killed by the script.

int MAXHP = 90000;

//:: End Variable Declaration

void main()
{
    int nClass = GetLevelByClass(CLASS_TYPE_COMMONER);
    int nAlign = GetAlignmentGoodEvil(OBJECT_SELF);
    object oKiller = GetLastKiller();
    // If we're a good/neutral commoner,
    // adjust the killer's alignment evil
    /* commented out...       decomment if you really want it...
    if(nClass > 0 && (nAlign == ALIGNMENT_GOOD || nAlign == ALIGNMENT_NEUTRAL))
    {

        AdjustAlignment(oKiller, ALIGNMENT_EVIL, 5);
    }
    */
    // Call to allies to let them know we're dead
    SpeakString("NW_I_AM_DEAD", TALKVOLUME_SILENT_TALK);

    //Shout Attack my target, only works with the On Spawn In setup
    SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);

    // NOTE: the OnDeath user-defined event does not
    // trigger reliably and should probably be removed
    if(GetSpawnInCondition(NW_FLAG_DEATH_EVENT))
    {
         SignalEvent(OBJECT_SELF, EventUserDefined(1007));
    }
    //:://////////////////////////////////////////
    //:: the start of the experience portion
    //:://////////////////////////////////////////
    if (GetIsPC(oKiller) || GetIsPC(GetMaster(oKiller)))
    {
    nClass = GetLevelByClass(CLASS_TYPE_COMMONER);
    int nAlign = GetAlignmentGoodEvil(OBJECT_SELF);
    if(nClass > 0 && (nAlign == ALIGNMENT_GOOD || nAlign == ALIGNMENT_NEUTRAL))
    {
        AdjustAlignment(oKiller, ALIGNMENT_EVIL, 5);
    }
    SpeakString("NW_I_AM_DEAD", TALKVOLUME_SILENT_TALK);
    //Shout Attack my target, only works with the On Spawn In setup
    SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);
    if(GetSpawnInCondition(NW_FLAG_DEATH_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1007));
    }

    //:: The experience base on CR vs. Levels of Party
    //:: Current value is 25, which is considered slow.
    //:: The DMG dictates a value of 300, but that will
    //:: most likely provide extremely fast level progression
    //:: because there is more fighting in a CRPG.
    float BaseEXP = 25.0;
    //:: The bonus experience based on difference of CR of monster vs.
    //:: Levels of Party.
    float BonusEXP = 15.0;
    float BaseMonEXP = GetChallengeRating(OBJECT_SELF) * BaseEXP;
    // First get all the members of the party & make sure only party members
    // in the area of the kill will get experience.
    int NumOfParty = 0;
    float PartyLevelSum = 0.0;
    object oPartyMember = GetFirstFactionMember(oKiller, TRUE);
    while(GetIsObjectValid(oPartyMember) && GetArea(OBJECT_SELF) == GetArea(oPartyMember)) {
        NumOfParty++;
        PartyLevelSum += GetCharacterLevel(oPartyMember);
        oPartyMember = GetNextFactionMember(oKiller, TRUE);
    }
    float PartyAvgLvl = PartyLevelSum / NumOfParty;
    //Calculate Adjustment Value
    float AdjustValue = GetChallengeRating(OBJECT_SELF) / PartyAvgLvl;
    float FinalMonValue;
    //Determine Final Experience Value
    if (AdjustValue == 0.0) {
        FinalMonValue = BaseMonEXP;
     } else {
        if (AdjustValue < 1.0) {
            FinalMonValue = BaseMonEXP * AdjustValue;
        } else {
            FinalMonValue = BaseMonEXP + (GetChallengeRating(OBJECT_SELF) - PartyAvgLvl) * BonusEXP;
        }
     }
     //Determine the value of the Split EXP
     float SplitFinalEXP = FinalMonValue / NumOfParty;
     int SFEint = FloatToInt(SplitFinalEXP);
     //Distribute EXP to all PCs in the Party
     oPartyMember = GetFirstFactionMember(oKiller, TRUE);
     while (GetIsObjectValid(oPartyMember) && GetArea(OBJECT_SELF) == GetArea(oPartyMember)) {
        GiveXPToCreature(oPartyMember, SFEint);
        oPartyMember = GetNextFactionMember(oKiller, TRUE);
     }
    //:: This section is designed to remove
    //:: the double experience messages
    //:: sent to players when a monster dies.
    //:: If the killer is a PC, assign the
    //:: experience from the script above, but
    //:: do not assign a double-line for modules
    //:: with the experience slider set to 0.
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), OBJECT_SELF);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(MAXHP), OBJECT_SELF);
    return;
    }
	
	ExecuteScript("prc_npc_death", OBJECT_SELF);
	ExecuteScript("prc_pwondeath", OBJECT_SELF);
}
