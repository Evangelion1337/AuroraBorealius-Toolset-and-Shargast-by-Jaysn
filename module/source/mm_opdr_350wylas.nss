//mm_opendoor_350gp Wylassi/

void main()
{

object oPC = GetPCSpeaker();

AssignCommand(oPC, TakeGoldFromCreature(350, oPC, TRUE));

object oTarget;
oTarget = GetObjectByTag("Wylassiarmourer");

AssignCommand(oTarget, ActionOpenDoor(oTarget));

}

