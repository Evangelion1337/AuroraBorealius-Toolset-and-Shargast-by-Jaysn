//::///////////////////////////////////////////////
//:: FileName mm_givsigvrakkas
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 27.05.2007 12:51:35
//:://////////////////////////////////////////////
void main()
{

object oPC = GetPCSpeaker();

CreateItemOnObject("sig_vrakkas", oPC);

object oTarget;
oTarget = GetObjectByTag("door_vrakkas");

AssignCommand(oTarget, ActionOpenDoor(oTarget));

}
