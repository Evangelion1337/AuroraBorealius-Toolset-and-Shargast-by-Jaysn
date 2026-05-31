//mm_opndr_350gfren

void main()
{

object oPC = GetPCSpeaker();

AssignCommand(oPC, TakeGoldFromCreature(350, oPC, TRUE));

object oTarget;
oTarget = GetObjectByTag("frenn_weaponsmithy");

AssignCommand(oTarget, ActionOpenDoor(oTarget));

}

