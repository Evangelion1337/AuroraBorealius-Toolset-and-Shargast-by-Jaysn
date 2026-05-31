//::///////////////////////////////////////////////
//:: FileName ls_mediumlore
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 27-12-2002 00:25:41
//:://////////////////////////////////////////////
#include "nw_i0_tool"

int StartingConditional()
{
//This caused a division by zero when executed, probably
//because there's no NPC hitdice (I'm guessing here.)
//Instead, I just check if the lore is 12 or more.
    // Perform skill checks
//    if(!(AutoDC(DC_MEDIUM, SKILL_LORE, GetPCSpeaker())))
  //      return FALSE;
int nLore=GetSkillRank(SKILL_LORE, GetPCSpeaker());

if (nLore>=12) return TRUE;

return FALSE;
}
