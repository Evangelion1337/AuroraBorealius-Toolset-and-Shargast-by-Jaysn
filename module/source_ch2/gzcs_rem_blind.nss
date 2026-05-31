#include "gzinc_effecttool"
void main()
{
    int nGold = GetLocalInt(GetModule(),"T1_MODULE_HEALER_BLIND");
    if (GetGold(GetPCSpeaker())>=nGold)
    {
        TakeGoldFromCreature(nGold, GetPCSpeaker());
        ActionPauseConversation();
        ActionCastFakeSpellAtObject(SPELL_HEAL,GetPCSpeaker());
        ActionDoCommand(GZRemoveBlindOrDeafness(GetPCSpeaker()));
        ActionResumeConversation();

    }
    else
    ActionSpeakString("Sorry, you cannot afford my services!");
}

