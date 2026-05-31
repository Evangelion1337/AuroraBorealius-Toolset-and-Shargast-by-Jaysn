//mm_opendoor_350gp/ Joefnhrif Mines

void main()
{

object oPC = GetPCSpeaker();

AssignCommand(oPC, TakeGoldFromCreature(350, oPC, TRUE));

object oTarget;
oTarget = GetObjectByTag("JoefnhrifMines");

AssignCommand(oTarget, ActionOpenDoor(oTarget));

}

