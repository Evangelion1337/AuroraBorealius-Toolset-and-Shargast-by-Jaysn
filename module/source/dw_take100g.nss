void main()
{
object oPC = GetPCSpeaker();
AssignCommand(oPC, TakeGoldFromCreature(100, oPC, TRUE));
}
