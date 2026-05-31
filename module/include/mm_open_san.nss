void main()
{

object oPC = GetPCSpeaker();

object oTarget;
oTarget = GetObjectByTag("door_san");

AssignCommand(oTarget, ActionOpenDoor(oTarget));

}
