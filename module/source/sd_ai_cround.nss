// sd_ai_combatround.nss
// Universal AI Framework - OnCombatRound Dispatcher

#include "sd_ai_inc_const"
#include "nw_i0_generic"

void main()
{
    int nType = GetLocalInt(OBJECT_SELF, SD_AI_VAR_TYPE);
    string sLegacy = GetLocalString(OBJECT_SELF, SD_AI_VAR_LEGACY);

    // Placeholder for future item-usage AI hook
    // Future: check creature type and run appropriate combat round logic

    // Default: run standard DetermineCombatRound
    DetermineCombatRound();
}
