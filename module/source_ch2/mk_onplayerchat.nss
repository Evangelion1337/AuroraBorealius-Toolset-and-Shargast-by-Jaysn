#include "mk_inc_editor"

void main()
{
    object oPC = GetPCChatSpeaker();
    string sChatMessage = GetPCChatMessage();

    int bEditorRunning = GetLocalInt(oPC, g_varEditorRunning);
    if (bEditorRunning) // the editor is running
    {
        int bUseOnPlayerChatEvent =
            GetLocalInt(oPC, g_varEditorUseOnPlayerChatEvent);

        if (bUseOnPlayerChatEvent)
        {
            SetLocalString(oPC, g_varEditorChatMessageString, sChatMessage);

            // the following line is not required but will make everything
            // look much better.
            SetPCChatMessage(""); // delete the message so it does not
                                  // appear above the player's head
        }
        return;
    }
}
