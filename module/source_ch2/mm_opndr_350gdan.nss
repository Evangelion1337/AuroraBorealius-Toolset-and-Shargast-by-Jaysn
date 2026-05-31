//mm_opndr_350gDan

void main()
{

object oPC = GetPCSpeaker();

AssignCommand(oPC, TakeGoldFromCreature(350, oPC, TRUE));

object oTarget;
oTarget = GetObjectByTag("danodil_danodilforge");

AssignCommand(oTarget, ActionOpenDoor(oTarget));

}

