//mm_open_vrakkas

void main()
{

object oPC = GetPCSpeaker();

object oTarget;
oTarget = GetObjectByTag("door_vrakkas");

AssignCommand(oTarget, ActionOpenDoor(oTarget));

}
