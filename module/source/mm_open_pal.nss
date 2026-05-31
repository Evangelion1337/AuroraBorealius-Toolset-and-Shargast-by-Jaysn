void main()
{

object oPC = GetPCSpeaker();

object oTarget;
oTarget = GetObjectByTag("door_pal");

AssignCommand(oTarget, ActionOpenDoor(oTarget));

}
