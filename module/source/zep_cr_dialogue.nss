void main() {
    object oPC = GetLastUsedBy();
    AssignCommand(oPC, ActionStartConversation(oPC, "x0_skill_ctrap", TRUE, FALSE));
}
