//mm_has50gp

int StartingConditional()
{
object oPC = GetPCSpeaker();

if (GetGold(oPC) < 50) return FALSE;

return TRUE;
}
