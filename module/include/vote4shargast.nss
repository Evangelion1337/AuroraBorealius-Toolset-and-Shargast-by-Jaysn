//Put this script OnEnter
void main()
{

object oPC = GetEnteringObject();

if (!GetIsPC(oPC)) return;

FloatingTextStringOnCreature("Please vote at http://nwvault.ign.com for Shargast v5.1 FINAL", oPC);

}
