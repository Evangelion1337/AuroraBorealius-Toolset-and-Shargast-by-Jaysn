#include "mk_inc_time"

const string g_varEditorOnExit = "MK_EditBox_OnExit";
const string g_varEditorOnCancel = "MK_EditBox_OnCancel";
const string g_varEditorOnInit = "MK_EditBox_OnInit";

const string g_varEditorHeadLine = "MK_Editor_HeadLine";
const string g_varEditorInit = "MK_Editor_Init";
const string g_varEditorText = "MK_Editor_Text";
const string g_varEditorMaxLength = "MK_Editor_MaxLength";
const string g_varEditorSingleLine = "MK_Editor_SingleLine";
const string g_varEditorDisableColors = "MK_Editor_DisableColors";
const string g_varEditorDisableBlock = "MK_Editor_DisableBlock";
const string g_varEditorUseOnPlayerChatEvent = "MK_Editor_UseOnPlayerChatEvent";
const string g_varEditorChatMessageString = "MK_Editor_ChatMessageString";
const string g_varEditorDisableLoadSave = "MK_Editor_DisableLoadSave";
const string g_varEditorID = "MK_Editor_ID";

const string g_varEditorBuffer = "MK_Editor_Buffer";
const string g_varEditorClipboard = "MK_Editor_Clipboard";
const string g_varEditorCursor = "MK_Editor_Cursor";
const string g_varEditorBlock = "MK_Editor_Block";
const string g_varEditorMenuMode = "MK_Editor_MenuMode";
const string g_varEditorRunning = "MK_Editor_Running";

const string g_varEditorLastAction = "MK_Editor_LastAction";
const string g_varEditorTimeStamp = "MK_Editor_TimeStamp";
const string g_varEditorCursorSpeedMode = "MK_Editor_CursorSpeedMode";

const string g_varEditorLoadSaveSlots = "MK_EditorFileSlot_";
// MK_EditorFileSlot_01, MK_EditorFileSlot_02, ...

const string g_varEditorCounter = "MK_Editor_Counter";

const string g_varEditorColor2DA = "MK_Editor_Color2DA";

void MK_Editor_ExecuteScript(object oPC, string sVarName);

string MK_Editor_GetScript(object oPC, string sVarName);

void MK_Editor_CleanUp(object oPC);


void MK_Editor_ExecuteScript(object oPC, string sVarName)
{
    string sScript = MK_Editor_GetScript(oPC, sVarName);
    if (sScript!="")
    {
        ExecuteScript(sScript, oPC);
    }
}


string MK_Editor_GetScript(object oPC, string sVarName)
{
    string sScript;
    sScript = GetLocalString(oPC, sVarName);
    if (sScript=="")
    {
        sScript = GetLocalString(GetModule(), sVarName);
    }
    return sScript;
}

void MK_Editor_CleanUp(object oPC)
{
    if (GetLocalInt(oPC, g_varEditorRunning))
    {
        DeleteLocalString(oPC, g_varEditorOnExit);
        DeleteLocalString(oPC, g_varEditorOnCancel);
        DeleteLocalString(oPC, g_varEditorOnInit);

        DeleteLocalInt(oPC, g_varEditorInit);
        DeleteLocalInt(oPC, g_varEditorID);

        DeleteLocalString(oPC, g_varEditorText);
        DeleteLocalString(oPC, g_varEditorHeadLine);

        DeleteLocalInt(oPC, g_varEditorMaxLength);
        DeleteLocalInt(oPC, g_varEditorSingleLine);
        DeleteLocalInt(oPC, g_varEditorDisableColors);
        DeleteLocalInt(oPC, g_varEditorDisableBlock);
        DeleteLocalInt(oPC, g_varEditorUseOnPlayerChatEvent);
        DeleteLocalString(oPC, g_varEditorChatMessageString);

        DeleteLocalString(oPC, g_varEditorBuffer);
        DeleteLocalString(oPC, g_varEditorClipboard);
        DeleteLocalInt(oPC, g_varEditorCursor);
        DeleteLocalInt(oPC, g_varEditorBlock);
        DeleteLocalInt(oPC, g_varEditorMenuMode);
        DeleteLocalInt(oPC, g_varEditorRunning);

        DeleteLocalInt(oPC, g_varEditorLastAction);
        DeleteLocalInt(oPC, g_varEditorCursorSpeedMode);

        mk_deleteTimeStampOnObject(oPC, g_varEditorTimeStamp);

        object oModule = GetModule();

        // number of editor instances currently running (including this one)
        int nCounter = GetLocalInt(oModule, g_varEditorCounter);
        SetLocalInt(oModule, g_varEditorCounter, --nCounter);

        if (nCounter==0)
        {
            // we're the last one so lets delete everything

            DeleteLocalInt(oModule, g_varEditorColor2DA);

            int i;
            for (i=1; i<50; i++)
            {
                SetCustomToken(19950+i, "");
            }
        }
    }
}

/*
void main()
{

}
/* */
