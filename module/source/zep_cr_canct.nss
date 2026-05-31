int StartingConditional() {
    object oPC = GetPCSpeaker();
    if (GetIsObjectValid(GetLocalObject(oPC, "ZEP_CR_NPC")))
        return FALSE;

    return TRUE;
}
