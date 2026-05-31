//::///////////////////////////////////////////////
//:: Associate: On Spawn In
//:: NW_CH_AC9
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

This must support the OC henchmen and all summoned/companion
creatures.

*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 19, 2001
//:://////////////////////////////////////////////
//:: Updated By: Georg Zoeller, 2003-08-20: Added variable check for spawn in animation

#include "x0_inc_henai"
#include "x2_inc_switches"
void main()
{
     //Sets up the special henchmen listening patterns
    SetAssociateListenPatterns();

    // Set additional henchman listening patterns
    bkSetListeningPatterns();

    // Default behavior for henchmen at start
    SetAssociateState(NW_ASC_POWER_CASTING);
    SetAssociateState(NW_ASC_HEAL_AT_50);
    SetAssociateState(NW_ASC_RETRY_OPEN_LOCKS);
    SetAssociateState(NW_ASC_DISARM_TRAPS);
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);
    //1.71: multisummoning feature
    if(GetModuleSwitchValue("71_UNLIMITED_SUMMONING"))
    {
        int maxSummon = GetModuleSwitchValue("71_UNLIMITED_SUMMONING");
        int numSummon,nTh = 1;
        location lTarget = GetLocation(OBJECT_SELF);
        object oSummon, oPC = GetNearestCreatureToLocation(CREATURE_TYPE_PLAYER_CHAR,PLAYER_CHAR_IS_PC,lTarget,nTh);
        while(GetIsObjectValid(oPC))
        {
            numSummon = 1;
            while(GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_SUMMONED,oPC,numSummon)))
            {
               numSummon++;
            }
            if(maxSummon == 1 || maxSummon >= numSummon)
            {
                oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED,oPC,1);
                AssignCommand(oSummon,SetIsDestroyable(FALSE,FALSE,FALSE));
                AssignCommand(oSummon,DelayCommand(0.01,SetIsDestroyable(TRUE,FALSE,FALSE)));
            }
            oPC = GetNearestCreatureToLocation(CREATURE_TYPE_PLAYER_CHAR,PLAYER_CHAR_IS_PC,lTarget,++nTh);
        }
    }

    //Use melee weapons by default
    SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE);

    // Distance: make henchmen stick closer
    SetAssociateState(NW_ASC_DISTANCE_4_METERS);
    if (GetAssociate(ASSOCIATE_TYPE_HENCHMAN, GetMaster()) == OBJECT_SELF) {
    SetAssociateState(NW_ASC_DISTANCE_2_METERS);//Shadooow: this doesn't work! master always invalid
    }

    // * If Incorporeal, apply changes
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_IS_INCORPOREAL) == TRUE)
    {
        effect eConceal = EffectConcealment(50, MISS_CHANCE_TYPE_NORMAL);
        effect eGhost = EffectCutsceneGhost();
        effect eKDImmunity = EffectImmunity(IMMUNITY_TYPE_KNOCKDOWN);
        effect eImmunity = EffectImmunity(IMMUNITY_TYPE_ENTANGLE);
        effect eLink = EffectLinkEffects(eConceal,eGhost);
        eLink = EffectLinkEffects(eLink,eKDImmunity);
        eLink = EffectLinkEffects(eLink,eImmunity);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eLink), OBJECT_SELF);
    }


    // Set starting location
    SetAssociateStartLocation();
}
