void main() {
    object oPC = GetPCSpeaker();
    object oNPC = OBJECT_SELF;
    SetLocalObject(oPC, "ZEP_CR_NPC", oNPC);
    AssignCommand(oPC, ActionStartConversation(oNPC, "x0_skill_ctrap", TRUE, FALSE));
}
