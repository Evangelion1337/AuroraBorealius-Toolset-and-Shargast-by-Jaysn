//::///////////////////////////////////////////////
//:: patchnoattack
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Derrick's script to make combat dummies not attack
    you.

*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////
void main()
{
    object oPC = GetLastAttacker();
    SetIsTemporaryFriend(oPC,OBJECT_SELF,FALSE,0.001);
    DelayCommand(0.001,SetIsTemporaryEnemy(oPC));
    //Shout Attack my target, only works with the On Spawn In setup
    SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_SHOUT);
    //Shout that I was attacked
    SpeakString("NW_I_WAS_ATTACKED", TALKVOLUME_SILENT_SHOUT);
}
