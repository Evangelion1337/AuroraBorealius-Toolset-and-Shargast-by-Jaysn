void main()
{
object oPC = GetPCSpeaker();
int iHeard = GetLocalInt(oPC,"iheard");

SetCreatureAppearanceType(oPC,iHeard);

SendMessageToPC(oPC,"Appearance set to " + IntToString(iHeard));
}
