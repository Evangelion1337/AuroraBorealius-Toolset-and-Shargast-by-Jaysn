//mm_opdr_350kraar

void main()
{

object oPC = GetPCSpeaker();

AssignCommand(oPC, TakeGoldFromCreature(350, oPC, TRUE));

object oTarget;
oTarget = GetObjectByTag("kreallingerarmourer");

AssignCommand(oTarget, ActionOpenDoor(oTarget));

}

