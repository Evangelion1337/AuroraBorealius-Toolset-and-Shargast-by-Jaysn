//mm_opendoor_350gp/

void main()
{

object oPC = GetPCSpeaker();

AssignCommand(oPC, TakeGoldFromCreature(350, oPC, TRUE));

object oTarget;
oTarget = GetObjectByTag("ganteriel_gmworks");

AssignCommand(oTarget, ActionOpenDoor(oTarget));

}

