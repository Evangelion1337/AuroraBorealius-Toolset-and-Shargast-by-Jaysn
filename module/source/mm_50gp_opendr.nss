/*  Open Door Script for 50gps
mm_50gp_opendr*/

void main()
{

object oPC = GetPCSpeaker();

AssignCommand(oPC, TakeGoldFromCreature(50, oPC, TRUE));

object oTarget;
oTarget = GetObjectByTag("ganteriel_gmworks");

AssignCommand(oTarget, ActionOpenDoor(oTarget));

}

