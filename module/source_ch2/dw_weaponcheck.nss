//::///////////////////////////////////////////////
//:: dw_weaponcheck
//:://////////////////////////////////////////////
/*
Guard will warn player with weapon in hand to put it away.
After a few warnings the guard will attack the offending player.
Adapted from a script by David Corrales. This script will not cause the
guards to be bothered by magic staves.
*/
//:://////////////////////////////////////////////
//:: Created By: Dreamwarder
//:: Created On: 3 May 2004
//:://////////////////////////////////////////////
#include "inc_utility"
#include "NW_I0_GENERIC"
object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, OBJECT_SELF);
object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oPC);
//VARIABLES START HERE
//The first warning a guard will give - edit the text between "" as desired.
string WARNING1 = "Sheath your weapon immediately";
//The second warning - edit as above
string WARNING2 = "Sheath your weapon infidel or feel my sword!";
//The third warning
string WARNING3 = "No more will I speak! Prepare for battle!";//Move to Player
//The Battlecry
string ATTACK_MSG = "Your pride will be your death!";//Attack here
//What the guard says when the PC puts their weapon away.
string COMPLY_REPLY = "Carry on!";
float  WARN_DISTANCE = 20.0;//Distance in which to spot player
float  ANGER_DUR = 120.0; //Length of time (sec) that will remain angry at the pc
int    WEAPON_CHECK_FREQUENCY = 3; // number of rounds between warnings.
//END OF VARIABLES
void main()
{
    object oPC;
        object item;
        int iCheckForWeapons = GetLocalInt( OBJECT_SELF, "WeaponCheckFrequency") -1;
        if( iCheckForWeapons > 0) SetLocalInt( OBJECT_SELF, "WeaponCheckFrequency", iCheckForWeapons);
        else
        {   SetLocalInt( OBJECT_SELF, "WeaponCheckFrequency", WEAPON_CHECK_FREQUENCY);

            oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, OBJECT_SELF);
            if(oPC != OBJECT_INVALID && (GetDistanceBetween(OBJECT_SELF,oPC) < WARN_DISTANCE) && GetObjectSeen(oPC) && !GetIsEnemy(oPC))
            {
             //If the pc is holding anyhting other than a Wizard's staff in his right hand then the guard will shout at him to put his weapon away.
             if(((item = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oPC))!=OBJECT_INVALID) && (GetBaseItemType(oWeapon)!=BASE_ITEM_MAGICSTAFF))
             {
                int iOffenseCount = GetLocalInt( OBJECT_SELF, "OffenseCount");
                if(GetLocalObject(OBJECT_SELF,"LastOffender")==oPC)
                {
                    if(iOffenseCount ==2)
                    {
                         SpeakString(ATTACK_MSG);
                         SetIsTemporaryEnemy(oPC,OBJECT_SELF,TRUE,ANGER_DUR);
                         ActionAttack(oPC);
                    }
                    else if(iOffenseCount ==1)
                    {
                        ActionMoveToObject(oPC,TRUE);
                        SetLocalInt(OBJECT_SELF,"OffenseCount",2);
                        SpeakString(WARNING3);
                    }
                    else
                    {
                        SetLocalInt(OBJECT_SELF,"OffenseCount",1);
                        SpeakString(WARNING2);
                    }
                }
                else
                {
                      iOffenseCount = 0;
                      SetLocalInt(OBJECT_SELF,"OffenseCount",0);
                      SpeakString(WARNING1);
                      SetLocalObject(OBJECT_SELF,"LastOffender",oPC);
                }

                if( iOffenseCount < 2) AssignCommand( oPC, PlaySound( "as_cv_gongring2"));
             }
             else
             {
                    if( GetLocalObject(OBJECT_SELF,"LastOffender")!= OBJECT_INVALID)
                        SpeakString(COMPLY_REPLY);
                    DeleteLocalObject(OBJECT_SELF,"LastOffender");
                    SetLocalInt(OBJECT_SELF,"OffenseCount",0);
             }
           }
        }
    if(GetSpawnInCondition(NW_FLAG_FAST_BUFF_ENEMY))
    {
        if(TalentAdvancedBuff(40.0))
        {
            SetSpawnInCondition(NW_FLAG_FAST_BUFF_ENEMY, FALSE);
            return;
        }
    }
    if(GetSpawnInCondition(NW_FLAG_DAY_NIGHT_POSTING))
    {
        int nDay = FALSE;
        if(GetIsDay() || GetIsDawn())
        {
            nDay = TRUE;
        }
        if(GetLocalInt(OBJECT_SELF, "NW_GENERIC_DAY_NIGHT") != nDay)
        {
            if(nDay == TRUE)
            {
                SetLocalInt(OBJECT_SELF, "NW_GENERIC_DAY_NIGHT", TRUE);
            }
            else
            {
                SetLocalInt(OBJECT_SELF, "NW_GENERIC_DAY_NIGHT", FALSE);
            }
            WalkWayPoints();
        }
    }
    if(!PRCGetHasEffect(EFFECT_TYPE_SLEEP))
    {
        if(!GetIsPostOrWalking())
        {
            if(!GetIsObjectValid(GetAttemptedAttackTarget()) && !GetIsObjectValid(GetAttemptedSpellTarget()))
            {
                if(!GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN)))
                {
                    if(!GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL) && !IsInConversation(OBJECT_SELF))
                    {
                        if(GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS) || GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN))
                        {
                            PlayMobileAmbientAnimations();
                        }
                        else if(GetIsEncounterCreature() &&
                        !GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN)))
                        {
                            PlayMobileAmbientAnimations();
                        }
                        else if(GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS) &&
                           !GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN)))
                        {
                            PlayImmobileAmbientAnimations();
                        }
                    }
                    else
                    {
                        DetermineSpecialBehavior();
                    }
                }
                else
                {
                    //DetermineCombatRound();
                }
            }
        }
    }
    else
    {
        if(GetSpawnInCondition(NW_FLAG_SLEEPING_AT_NIGHT))
        {
            effect eVis = EffectVisualEffect(VFX_IMP_SLEEP);
            if(d10() > 6)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
            }
        }
    }
    if(GetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1001));
    }
}

