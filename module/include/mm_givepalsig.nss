//::///////////////////////////////////////////////
//:: FileName mm_givepalsig
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 27.05.2007 16:24:48
//:://////////////////////////////////////////////
void main()
{
    // Give the speaker some gold
    GiveGoldToCreature(GetPCSpeaker(), 500);

    // Give the speaker some XP
    GiveXPToCreature(GetPCSpeaker(), 500);

    // Give the speaker the items
    CreateItemOnObject("sig_pal", GetPCSpeaker(), 1);

object oTarget;
oTarget = GetObjectByTag("door_pal");

AssignCommand(oTarget, ActionOpenDoor(oTarget));

}
