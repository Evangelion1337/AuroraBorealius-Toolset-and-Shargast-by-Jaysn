#include "gzinc_effecttool"
void main()
{
    int nGold = GetLocalInt(GetModule(),"T1_MODULE_HEALER_CURSE");
    if (GetGold(GetPCSpeaker())>=nGold)
    {
        TakeGoldFromCreature(nGold, GetPCSpeaker());
        ActionPauseConversation();
        ActionCastFakeSpellAtObject(SPELL_HEAL,GetPCSpeaker());
        ActionDoCommand( GZRemoveCurse(GetPCSpeaker()));
        ActionResumeConversation();
    }
    else
    ActionSpeakString("Sorry, you cannot afford my services!");
}


