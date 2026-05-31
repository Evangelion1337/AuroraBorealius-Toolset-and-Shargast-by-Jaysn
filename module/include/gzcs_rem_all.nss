#include "gzinc_effecttool"
void main()
{
    int nGold = GetLocalInt(GetModule(),"T1_MODULE_HEALER_FULLCHECK");
    if (GetGold(GetPCSpeaker())>=nGold)
    {
        TakeGoldFromCreature(nGold, GetPCSpeaker());
        ActionPauseConversation();
        ActionCastFakeSpellAtObject(SPELL_HEAL,GetPCSpeaker());
        ActionDoCommand( GZRemoveAllNegativeEffects(GetPCSpeaker()));
        ActionResumeConversation();
    }
    else
    ActionSpeakString("Sorry, you cannot afford my services!");
}


