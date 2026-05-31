// the henchman casts their spell

void main()
{
    int nSpell = GetLocalInt(OBJECT_SELF, "Deekin_Spell_Cast");
    object oTarget = GetLocalObject(OBJECT_SELF, "Henchman_Spell_Target");

    if ((nSpell > 0) && (GetIsObjectValid(oTarget)))
    {
        ClearAllActions();
        ActionCastSpellAtObject(nSpell, oTarget);
        ActionDoCommand(SetLocalInt(OBJECT_SELF, "Deekin_Spell_Cast", 0));
        ActionDoCommand(SetLocalObject(OBJECT_SELF, "Henchman_Spell_Target", OBJECT_INVALID));
    }
    else PlayVoiceChat(VOICE_CHAT_CUSS);
}
