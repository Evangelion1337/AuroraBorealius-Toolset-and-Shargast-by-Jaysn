int StartingConditional()
{
object oPC = GetPCSpeaker();

if (!(GetGold(oPC) >= 100)) return FALSE;

return TRUE;
}

