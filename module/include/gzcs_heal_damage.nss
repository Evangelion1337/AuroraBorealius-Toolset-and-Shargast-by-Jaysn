#include "gzinc_effecttool"

void main()
{
    int nGold = GetLocalInt(GetModule(),"T1_MODULE_HEALER_HEAL");
    if (GetGold(GetPCSpeaker())>=nGold)
    {
        TakeGoldFromCreature(nGold, GetPCSpeaker());
        ActionPauseConversation();
        ActionCastFakeSpellAtObject(SPELL_HEAL,GetPCSpeaker());
        ActionDoCommand(GZRemovePhysicalDamage(GetPCSpeaker()));
        ActionResumeConversation();
    }
    else
    ActionSpeakString("Sorry, you cannot afford my services!");

}
