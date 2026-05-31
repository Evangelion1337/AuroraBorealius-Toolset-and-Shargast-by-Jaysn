// OnPlayerChat script for horse commands

// Author : Proleric

// Modified : 20-Feb-2008

void main()
{
  object oPC   = GetPCChatSpeaker();
  string sChat = GetPCChatMessage();

  if (GetStringLowerCase(sChat) == "horse")
    {
      AssignCommand(oPC, ActionStartConversation(oPC, "bhh_horse_menu", FALSE, FALSE));
      SetPCChatMessage();
    }
}
