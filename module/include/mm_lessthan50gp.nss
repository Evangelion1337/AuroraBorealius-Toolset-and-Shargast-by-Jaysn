//mm_lessthan349gp

int StartingConditional()
{
object oPC = GetPCSpeaker();

if (GetGold(oPC) >= 349) return FALSE;

return TRUE;
}
