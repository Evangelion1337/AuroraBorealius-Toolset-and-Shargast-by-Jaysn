#include "mk_inc_generic"
#include "mk_inc_time"
#include "mk_inc_tools"
#include "mk_inc_pixel"
#include "mk_inc_editor"
#include "mk_inc_editor_c"

////////////////////////////////////////////////////////////////////////////
// used custom tokens:
//  - 19999: text
//  - 19998: cursor position
//  - 19997: length of text
//  - 19996: block on
//  - 19995: headline
//  - 19992: -------...--------
//  - 19991: colors (colored text 'colors')
//
//  - 19990: </c>
//  - 19989: color of 'OK' button
//  - 19988: color of 'Color Off'
//  - 19987: editor window: color head lines, foot lines
//  - 19986: color of button 'Color Off'
//  - 19985: color of 'Cancel' button
//  - 19984: key color
//  - 19983: insert color
//  - 19982: color of 'Back to main menu' button
//  - 19981: color of 'Help' button
//  - 19980: color of 'Load/Save' button
//
//  - 19951,...
//  - 19970: color names


// return a if a<b or b==-1 otherwise it returns b
int _min(int a, int b);

// return a if a>b or b==-1 otherwise it returns b
int _max(int a, int b);

// deletes the text between nStart and nEnd and returns the result
string DeleteBlock(string sText, int nStart, int nEnd);

// returns the text between nStart and nEnd
string CopyBlock(string sText, int nStart, int nEnd);

// inserts sInsert at position nPos into sText and returns the result
string InsertText(string sText, int nPos, string sInsert, int nMaxLength);

// returns sColorTag + sText + </c>
string AddColorTag(string sText, string sColorTag);

// creates the editor 'screen'
void CreateDisplay(object oPC, string sText, int nCursor, int nBlock);

// returns true if block mode is on,
// block mode is on if (nBlock!=-1) and (nBlock!=nCursor)
int IsBlockMarked(int nCursor, int nBlock);

// initializes the custom tokens
void InitCustomTokens();

// sets the custom tokens for the color names used by the color sub menu
void SetColorMenuStrings();


string GetFileSlotVarName(int nSlot);

// LineFeedMode: 0=ignore, 1=cut, 2=remove
string LoadTextFromSlot(object oObject, int nSlot, int nMaxLength=-1, int nLineFeedMode=0);

void SaveTextToSlot(object oObject, int nSlot, string sText);

// creates a line of the file menu
string CreateFileMenuText(object oObject, int bSave, int nSlot);

// sets the custom tokens for load/save slots used by the load/save sub menu
void SetFileMenuStrings(object oObject);

// moves the cursor one character to the right,
// basically a simple 'nCursor++' unless the character right to the cursor
// is a tag (color tag or </c>). Then the cursor jumps over the tag.
int IncCursor(string sText, int nCursor, int nDelta=1);

// moves the cursor one character to the left,
// basically a simple 'nCursor--' unless the character left to the cursor
// is a tag (color tag or </c>). Then the cursor jumps over the tag.
int DecCursor(string sText, int nCursor, int nDelta=1);

// reads a color name from a 2DA file (default = mk_colors.2da).
string GetColorName(int iColor);

// reads a color tag from a 2DA file (default = mk_colors.2da).
string GetColorTag(int iColor);

// if bUsePlayerChatEvent is FALSE (single player mode) it returns
// GetPCChatMessage().
// if bUsePlayerChatEvent is TRUE (multi player mode) it returns
// GetLocalString(oPC, g_varEditorChatMessageString).
// The variable should be set inside OnPlayerChatEvent.
string GetPCChatMessageEx(object oPC, int bUsePlayerChatEvent);

void IncLocalInt(object oObject, string sVarName, int n=1);

/*
// returns true if sText starts with  a 'color tag'
// (something like <cXXX>).
int IsColorTag(string sText);

// returns true if sText starts with the 'close color tag' (</c>).
int IsCloseTag(string sText);
*/

struct mk_lastAction
{
    int nAction;
    float fTimeStamp;
};

// stores nAction and the current time on the oObject
void StoreAction(object oObject, int nAction);

// reads nAction and time passed as time stamp from oObject
struct mk_lastAction GetLastAction(object oObject);

// calculates the cursor speed
int CalculateCursorSpeed(object oObject, int nAction);


// the 'menus'...
const int nMainMenu = 0;
const int nColorMenu = 1;
const int nFileMenu = 2;

// the 'keys'...
const int nKeyPos1 = 1;
const int nKeyCursorLeft = 2;
const int nKeyCursorRight = 3;
const int nKeyEnd = 4;

const int nKeyShiftPos1 = 5;
const int nKeyShiftCursorLeft = 6;
const int nKeyShiftCursorRight = 7;
const int nKeyShiftEnd = 8;

const int nKeyInsert = 9;

const int nKeyDelete = 10;
const int nKeyBackspace = 11;

const int nKeyCtrlInsert = 12;

const int nKeyShiftInsert = 13;
const int nKeyShiftDelete = 14;

const int nKeyReturn = 15;

const int nKeyColorMenu = 16;
const int nKeyFileMenu = 17;

const int nNumberOfLoadSaveSlots = 5;

const int nMaxTextDisplayLength = 25;

const string sLineOnScreen = "-------------------------------------------";
const string sColoredColor = "<cþ  >C</c><cþþ >o</c><c þ >l</c><c þþ>o</c><c  þ>r</c><cþ þ>s</c>";
const string sEmptyLine    = "                                           ";
const string sEditorHeadLine = "IGTE 1.02 - Text:";


int StartingConditional()
{
    object oPC = GetPCSpeaker();

    // read the current text
    string sText = GetLocalString(oPC, g_varEditorBuffer);
    // read the clipboard
    string sClipboard = GetLocalString(oPC, g_varEditorClipboard);
    // read the cursor position
    int nCursor = GetLocalInt(oPC, g_varEditorCursor);
    // read the block position
    int nBlock = GetLocalInt(oPC, g_varEditorBlock);
    // read the menu mode
    int nMenuMode = GetLocalInt(oPC, g_varEditorMenuMode);

    // read the editor settings, these setings should be set in the
    // script that starts the editor
    int nMaxLength = GetLocalInt(oPC, g_varEditorMaxLength);
    int bSingleLine = GetLocalInt(oPC, g_varEditorSingleLine);
    int bDisableColors = GetLocalInt(oPC, g_varEditorDisableColors);
    int bDisableBlock = GetLocalInt(oPC, g_varEditorDisableBlock);
    int bUsePlayerChatEvent = GetLocalInt(oPC, g_varEditorUseOnPlayerChatEvent);
    int bDisableLoadSave = GetLocalInt(oPC, g_varEditorDisableLoadSave);

    int nAction;

    int bInitialize = GetLocalInt(oPC, g_varEditorInit);
    // if bInitialize is TRUE we have to initialize the editor
    if (bInitialize)
    {
        SetLocalInt(oPC, g_varEditorInit, 0);

        // initialize the custom tokens
        InitCustomTokens();

        // indicate that the editor is running
        // the variable g_varEditorRunning can/should be used in the
        // OnPlayerChatEvent.

        // if it is already set then the last time the editor was
        // closed using the 'escape' key
        if (GetLocalInt(oPC, g_varEditorRunning)==0)
        {
            SetLocalInt(oPC, g_varEditorRunning, 1);
            // inc the number of editor instances currently running
            IncLocalInt(GetModule(), g_varEditorCounter);
        }

        // execute an OnInit script (optional)
        MK_Editor_ExecuteScript(oPC, g_varEditorOnInit);

        // read the starting text from a variable stored on the user
        sText=GetLocalString(oPC, g_varEditorText);

        // block mode is off
        nBlock = -1;

        // move the cursor behind the last character
        nCursor = GetStringLength(sText);

        // the main menu is shown
        nMenuMode = 0;

        nAction = -1;
    }
    else
    {
        // we're not in the init mode so lets read the key pressed by the
        // user (that is the dialog option selected by the user).
        nAction = MK_GenericDialog_GetAction(TRUE);
    }

//    SendMessageToPC(oPC, "ColorMode = "+IntToString(nColorMode)
//        +", Action = "+IntToString(nAction));

    string sInsert;
    int nCursorSpeed;

    switch (nMenuMode)
    {
    case nMainMenu:

        // we don't have cursor up/down so moving the cursor in a
        // larger text can become quite tedious. That's why we move
        // the cursor by more than one character if time passed between
        // two cursor left/right is very small
        nCursorSpeed = CalculateCursorSpeed(oPC, nAction);

        switch (nAction)
        {
        case nKeyPos1: // pos 1
            // move cursor in front of first character, block mode off
            nCursor = 0;
            nBlock = -1;
            break;
        case nKeyCursorLeft: // cursor left
            // move cursor on character to the left, block mode off
            nCursor = DecCursor(sText, nCursor, nCursorSpeed);
            nBlock = -1;
            break;
        case nKeyCursorRight: // cursor right
            // move cursor on character to the right, block mode off
            nCursor = IncCursor(sText, nCursor, nCursorSpeed);
            nBlock = -1;
            break;
        case nKeyEnd: // end
            // move cursor behind the last character, block mode off
            nCursor = GetStringLength(sText);
            nBlock = -1;
            break;
        case nKeyShiftPos1:
            // turn block mode on and move cursor in front of first character
            if (nBlock==-1) nBlock = nCursor;
            nCursor = 0;
            break;
        case nKeyShiftCursorLeft: // shift cursor left
            // turn block mode on and move cursor one character to the left
            if (nBlock==-1) nBlock = nCursor;
            nCursor = DecCursor(sText, nCursor, nCursorSpeed);
            break;
        case nKeyShiftCursorRight: // shift cursor right
            // turn block mode on and move cursor one character to the right
            if (nBlock==-1) nBlock = nCursor;
            nCursor = IncCursor(sText, nCursor, nCursorSpeed);
            break;
        case nKeyShiftEnd:
            // turn block mode on and move cursor behind the last character
            if (nBlock==-1) nBlock = nCursor;
            nCursor = GetStringLength(sText);
            break;
        case nKeyDelete: // delete
            if (IsBlockMarked(nCursor, nBlock))
            {
                // delete the marked block and get the new cursor
                // position
                sText = DeleteBlock(sText, nBlock, nCursor);
                nCursor = _min(nBlock, nCursor);
            }
            else
            {
                // calculate the position right to the cursor position
                // and delete the text between the cursor and this position.
                // Looks complicated but is necessary because we don't
                // want to delete just leading '<' of a (color) tag.
                // We want to delete the whole tag of course.
                int nCursorQ = IncCursor(sText, nCursor);
                sText = DeleteBlock(sText,nCursor,nCursorQ);
            }
            nBlock = -1;
            break;
        case nKeyBackspace: // backspace
            if (IsBlockMarked(nCursor, nBlock))
            {
                // delete the marked block and get the new cursor
                // position
                sText = DeleteBlock(sText, nBlock, nCursor);
                nCursor = _min(nBlock, nCursor);
            }
            else
            {
                // calculate the position left to the cursor position
                // and delete the text between the cursor and this position.
                // This is also the new cursor position.
                // Looks complicated but is necessary because we don't
                // want to delete just closing '>' of a (color) tag.
                // We want to delete the whole tag of course.
                int nCursorQ = DecCursor(sText, nCursor);
                sText = DeleteBlock(sText,nCursorQ,nCursor);
                nCursor = nCursorQ;
            }
            nBlock = -1;
            break;
        case nKeyShiftDelete: // shift delete
            if (IsBlockMarked(nCursor, nBlock))
            {
                // If a block is marked we copy that block to the
                // clibboard and then we delete the block.
                sClipboard = CopyBlock(sText, nBlock, nCursor);
                sText = DeleteBlock(sText, nBlock, nCursor);
                nCursor = _min(nBlock, nCursor);
            }
            else
            {
                // If no block is marked this is the same as 'backspace'
                int nCursorQ = DecCursor(sText, nCursor);
                sText = DeleteBlock(sText,nCursorQ,nCursor);
                nCursor = nCursorQ;
            }
            nBlock = -1;
            break;
        case nKeyCtrlInsert:
            if (IsBlockMarked(nCursor, nBlock))
            {
                // If a block is marked we copy that block to the clipboard.
                sClipboard = CopyBlock(sText, nBlock, nCursor);
            }
            break;
        case nKeyShiftInsert:
            // If a block is marked we delete that block.
            if (IsBlockMarked(nCursor, nBlock))
            {
                sText = DeleteBlock(sText, nBlock, nCursor);
                nCursor = _min(nBlock, nCursor);
            }
            // Turn block mode off
            nBlock=-1;
            // Insert the clipboard into the text at the cursor position.
            // The new cursor position is behind the just inserted text.
            {
                // we don't know how many characters get added so
                // nCursor += GetStringLength(sClipboard)
                // might be wrong.
                int nLenOld = GetStringLength(sText);
                sText = InsertText(sText, nCursor, sClipboard, nMaxLength);
                int nLenNew = GetStringLength(sText);

                nCursor += (nLenNew - nLenOld);
            }
            break;
        case nKeyInsert: // insert text
            // If a block is marked we delete that block.
            if (IsBlockMarked(nCursor, nBlock))
            {
                sText = DeleteBlock(sText, nBlock, nCursor);
                nCursor = _min(nBlock, nCursor);
            }
            nBlock=-1;
            // If the user has entered some text into the chat line
            // and has pressed the enter key we can read that text
            // and insert it into the editor.
            sInsert = GetPCChatMessageEx(oPC, bUsePlayerChatEvent);
            {
                // we don't know how many characters get added so
                // nCursor += GetStringLength(sInsert)
                // might be wrong.
                int nLenOld = GetStringLength(sText);
                sText = InsertText(sText, nCursor, sInsert, nMaxLength);
                int nLenNew = GetStringLength(sText);

                nCursor += (nLenNew - nLenOld);
            }
            break;
        case nKeyReturn: // return
            // If a block is marked we delete that block.
            if (IsBlockMarked(nCursor, nBlock))
            {
                sText = DeleteBlock(sText, nBlock, nCursor);
                nCursor = _min(nBlock, nCursor);
            }
            nBlock=-1;
            // We insert line feed at cursor position
            sInsert = "\n";
            {
                // we don't know how many characters get added so
                // nCursor += GetStringLength(sInsert)
                // might be wrong.
                int nLenOld = GetStringLength(sText);
                sText = InsertText(sText, nCursor, sInsert, nMaxLength);
                int nLenNew = GetStringLength(sText);

                if (nLenNew>nLenOld)
                {
                    nCursor = IncCursor(sText, nCursor);
                }
            }
            break;
        case nKeyColorMenu: // color
            // Activate the color menu
            nMenuMode = nColorMenu;
            break;
        case nKeyFileMenu:
            nMenuMode = nFileMenu;
            break;
        }

        // write key pressed and time on player
        StoreAction(oPC, nAction);

        break;
    case nColorMenu:
        nMenuMode = nMainMenu;
        if ((nAction>=1) && (nAction<=20))
        {
            // The user has selected a color. Lets get the color tag.
            sInsert = GetColorTag(nAction-1);
        }
        else if (nAction==21)
        {
            // The user has selected the close color tag.
            sInsert = "</c>";
        }
        else
        {
            // The user has probably selected 'Back to main menu'
            sInsert = "";
        }

        if (sInsert!="")
        {
            if (IsBlockMarked(nCursor, nBlock) && (nAction!=21))
            {
                // If a block is marked (and a color tag is choosen) we add
                // a close color tag behind the block and the color tag in
                // front of the block. That will make sure that only the
                // marked block gets colored.
                sText = InsertText(sText, _max(nCursor, nBlock), "</c>", nMaxLength);
                sText = InsertText(sText, _min(nCursor, nBlock), sInsert, nMaxLength);
                if (nBlock<nCursor)
                {
                    // make sure the (visible) cursor position does not
                    // change (6+4=10)
                    nCursor+=10;
                }
            }
            else
            {
                // No block is marked, we only insert the desired tag at
                // cursor position.
                sText = InsertText(sText, nCursor, sInsert, nMaxLength);
                // Move the cursor behind the tag.
                nCursor = IncCursor(sText, nCursor);
            }
            nBlock = -1;
        }
        break;
    case nFileMenu:
        nMenuMode = nMainMenu;
        if ((nAction>=1) && (nAction<=nNumberOfLoadSaveSlots))
        {
            SaveTextToSlot(oPC, nAction, sText);
        }
        else if ((nAction>nNumberOfLoadSaveSlots) && (nAction<2*nNumberOfLoadSaveSlots))
        {
            sText = LoadTextFromSlot(oPC, nAction-nNumberOfLoadSaveSlots,
                nMaxLength, (bSingleLine ? 1 : 0));
            nBlock = -1;
            nCursor = GetStringLength(sText);
        }
        break;
    }

    switch (nMenuMode)
    {
    case nMainMenu:
        // If the block operations are disabled the appropriate dialog options
        // are disabled as well.
        // Also if the clipboard is empty the 'Shift Insert' option is
        // disabled.
        MK_GenericDialog_SetCondition(nKeyShiftPos1, (!bDisableBlock));
        MK_GenericDialog_SetCondition(nKeyShiftCursorLeft, (!bDisableBlock));
        MK_GenericDialog_SetCondition(nKeyShiftCursorRight, (!bDisableBlock));
        MK_GenericDialog_SetCondition(nKeyShiftEnd, (!bDisableBlock));
        MK_GenericDialog_SetCondition(nKeyShiftInsert, (sClipboard!="") && (!bDisableBlock));
        MK_GenericDialog_SetCondition(nKeyShiftDelete, (!bDisableBlock));
        MK_GenericDialog_SetCondition(nKeyCtrlInsert, (!bDisableBlock));
        MK_GenericDialog_SetCondition(nKeyReturn, !bSingleLine);
        // If colors are disabled the color menu is disabled.
        MK_GenericDialog_SetCondition(nKeyColorMenu, !bDisableColors);
        MK_GenericDialog_SetCondition(nKeyFileMenu, !bDisableLoadSave);

        break;
    case nColorMenu:
        // Create the color menu.
        SetColorMenuStrings();
        break;
    case nFileMenu:
        // Create the file menu.
        SetFileMenuStrings(oPC);
        break;
    }

    // Generate the editor screen.
    CreateDisplay(oPC, sText, nCursor, nBlock);

    // Store the editor variables on the player.
    SetLocalString(oPC, g_varEditorBuffer, sText);
    SetLocalString(oPC, g_varEditorClipboard, sClipboard);
    SetLocalInt(oPC, g_varEditorCursor, nCursor);
    SetLocalInt(oPC, g_varEditorBlock, nBlock);
    SetLocalInt(oPC, g_varEditorMenuMode, nMenuMode);

    return TRUE;
}

int _min(int a, int b)
{
    if (a==-1) return b;
    if (b==-1) return a;
    if (a<b) return a;
    return b;
}

int _max(int a, int b)
{
    if (a==-1) return b;
    if (b==-1) return a;
    if (a<b) return b;
    return a;
}

string CopyBlock(string sText, int nStart, int nEnd)
{
/*    SendMessageToPC(GetPCSpeaker(), "CopyBlock: "+
        "sText="+sText+", "+
        "nStart="+IntToString(nStart)+", "+
        "nEnd="+IntToString(nEnd));
*/

    int nStart0 = _min(nStart, nEnd);
    int nEnd0 = _max(nStart, nEnd);
    int nLength = GetStringLength(sText);

    string sCopy = GetSubString(sText, nStart0, nEnd0-nStart0);

/*    SendMessageToPC(GetPCSpeaker(), "CopyBlock: "+
        "sCopy="+sCopy);
*/

    return sCopy;
}

string DeleteBlock(string sText, int nStart, int nEnd)
{
/*    SendMessageToPC(GetPCSpeaker(), "DeleteBlock: "+
        "sText="+sText+", "+
        "nStart="+IntToString(nStart)+", "+
        "nEnd="+IntToString(nEnd));
*/

    int nStart0 = _min(nStart, nEnd);
    int nEnd0 = _max(nStart, nEnd);
    int nLength = GetStringLength(sText);

    string sLeft = GetStringLeft(sText,nStart0);
    string sRight = GetStringRight(sText,nLength-nEnd0);

/*    SendMessageToPC(GetPCSpeaker(), "DeleteBlock: "+
        "sLeft="+sLeft+", "+
        "sRight="+sRight);
*/
    return sLeft+sRight;
}

string InsertText(string sText, int nPos, string sInsert, int nMaxLength)
{
/*    SendMessageToPC(GetPCSpeaker(), "InsertText: "+
        "sText="+sText+", "+
        "nPos="+IntToString(nPos)+", "+
        "sInsert="+sInsert);
*/

    int nLength = GetStringLength(sText);
    string sLeft = GetStringLeft(sText,nPos);
    string sRight = GetStringRight(sText,nLength-nPos);

    if (nMaxLength>0)
    {
        nLength = MK_GetStringLength(sLeft, TRUE)
            + MK_GetStringLength(sRight, TRUE);

        if ((nLength + MK_GetStringLength(sInsert, TRUE)) > nMaxLength)
        {
            sInsert = MK_GetStringLeft(sInsert, nMaxLength-nLength, TRUE);
        }
    }

/*    SendMessageToPC(GetPCSpeaker(), "InsertText: "+
        "sLeft="+sLeft+", "+
        "sRight="+sRight);
*/

    return sLeft+sInsert+sRight;
}

string AddColorTag(string sText, string sColorTag)
{
    return sColorTag+sText+sCloseTag;
}

void CreateDisplay(object oPC, string sText, int nCursor, int nBlock)
{
/*    SendMessageToPC(GetPCSpeaker(), "CreateDisplay(1): "+
        "sText="+sText+", "+
        "nCursor="+IntToString(nCursor)+", "+
        "nBlock="+IntToString(nBlock));
*/
    int nLength = GetStringLength(sText);

    string s1 = IntToString(nCursor+1);
    string s2 = IntToString(nLength);
    string s3 = "";

    string sBlockColorTagQ;

    if (IsBlockMarked(nCursor, nBlock))
    {
/*
    The following would work great (well, sort of) if there were only
    one font. Unfortunately there's the 'normal' font and the high resolution
    font and usually characters in the normal font have a smaller size and
    there's no way to get the used font size in nwscript.

        // We want the text 'Block' to be right aligned.
        // So lets calculate the required number of spaces.
        // The '---...---' line is 258 pixel
        // The 'Cursor pos: ' is 79 pixel
        // The '/' is 6 pixel
        // The 'Block' is 35 pixel
        // A ' ' is 4 pixel
        int nPixelToFill = 258 - (79 + MK_GetStringSize(s1) + 6
                                     + MK_GetStringSize(s2) + 35);

        int nNumberOfSpaces = nPixelToFill / 4;

        s3 = GetStringLeft(sEmptyLine, nNumberOfSpaces) + "Block";

    So let's drop the idea of having right aligned text in the status line.
*/
        s3 = "Block On";
        sBlockColorTagQ = sBlockColorTag;
    }
    else
    {
        s3 = "Block Off";
        sBlockColorTagQ = sText2ColorTag;
    }
    int nSpaces = (100 - (MK_GetStringSize(s1) + MK_GetStringSize(s2))) / 4;
    s3 = GetStringLeft(sEmptyLine,nSpaces) + s3;

    int nMin = _min(nCursor, nBlock);
    int nMax = _max(nCursor, nBlock);

    string sLeft  = GetStringLeft(sText, nMin);
    string sRight = GetStringRight(sText, nLength - nMax);
    string sMid;

    if ((nBlock==-1) || (nBlock==nCursor))
    {
        sMid = AddColorTag(sCursor, sCursorColorTag);
    }
    else
    {
        sMid = AddColorTag(GetSubString(sText, nMin, nMax-nMin), sBlockColorTag);
    }

/*    SendMessageToPC(GetPCSpeaker(), "CreateDisplay(2): "+
        "sLeft="+sLeft+", "+
        "sMid="+sMid+", "+
        "sRight="+sRight);
*/
    string s4 = GetLocalString(oPC, g_varEditorHeadLine);
    if (s4=="")
    {
        s4 = sEditorHeadLine;
    }

    SetCustomToken(19995, s4);
    SetCustomToken(19996, AddColorTag(s3, sBlockColorTagQ));
    SetCustomToken(19997, AddColorTag(s2, sCursorColorTag));
    SetCustomToken(19998, AddColorTag(s1, sCursorColorTag));
    SetCustomToken(19999, sLeft+sMid+sRight);
}

int IsBlockMarked(int nCursor, int nBlock)
{
    if ((nBlock==-1) || (nCursor==nBlock))
    {
        return FALSE;
    }
    return TRUE;
}

void InitCustomTokens()
{
    SetCustomToken(19992, sLineOnScreen);
    SetCustomToken(19991, sColoredColor);

    SetCustomToken(19990, sCloseTag);

    SetCustomToken(19989, sExitColorTag);    // color of 'OK'
    SetCustomToken(19988, sText1ColorTag);   // color text
    SetCustomToken(19987, sText2ColorTag);   // color head line, foot line
    SetCustomToken(19986, sColorOffColorTag);// color of 'Color Off'
    SetCustomToken(19985, sCancelColorTag);  // color of 'Cancel'
    SetCustomToken(19984, sKeyColorTag);     // color keys
    SetCustomToken(19983, sInsertColorTag);  // color insert
    SetCustomToken(19982, sBackToMainMenuColor); // color 'back to main menu
    SetCustomToken(19981, sHelpColorTag);    // color 'Help'
    SetCustomToken(19980, sLoadSaveColorTag);
}

int IncCursor(string sText, int nCursor, int nDelta)
{
    int nLen = GetStringLength(sText);

    while ((nCursor<nLen) && (nDelta>0))
    {
        if (MK_IsColorTag(sText,nCursor))
        {
            nCursor+=6;
        }
        else if (MK_IsCloseTag(sText,nCursor))
        {
            nCursor+=4;
        }
        else if (nCursor<nLen)
        {
            nCursor++;
        }
        nDelta--;
    }
    return nCursor;
}

int DecCursor(string sText, int nCursor, int nDelta)
{
    while ((nCursor>0) && (nDelta>0))
    {
        if ((nCursor>5) && (MK_IsColorTag(sText,nCursor-6)))
        {
            nCursor-=6;
        }
        else if ((nCursor>3) && (MK_IsCloseTag(sText,nCursor-4)))
        {
            nCursor-=4;
        }
        else if (nCursor>0)
        {
            nCursor--;
        }
        nDelta--;
    }
    return nCursor;
}

int GetColor2DAMode()
{
    object oModule = GetModule();
    if (!GetIsObjectValid(oModule)) return 2;

    int nColor2DAMode = GetLocalInt(oModule, g_varEditorColor2DA);
    if (nColor2DAMode==0)
    {
        if (Get2DAString(sColor2DA, sColor2DAName, 0)!="")
        {
            nColor2DAMode=1;
        }
        else
        {
            nColor2DAMode=2;
        }
        SetLocalInt(oModule, g_varEditorColor2DA, nColor2DAMode);
    }
    return nColor2DAMode;
}

string GetColorName(int iColor)
{
    string sColor;
    if (GetColor2DAMode()==1)
    {
        sColor = Get2DAString(sColor2DA, sColor2DAName, iColor);
    }
    else
    {
        switch (iColor)
        {
        case 0: sColor = sColorNameRed; break;
        case 1: sColor = sColorNameGreen; break;
        case 2: sColor = sColorNameBlue; break;
        case 3: sColor = sColorNameCyan; break;
        case 4: sColor = sColorNameMagenta; break;
        case 5: sColor = sColorNameYellow; break;
        default: sColor = "";
        }
    }
    return sColor;
}

string GetColorTag(int iColor)
{
    string sTag;
    if (GetColor2DAMode()==1)
    {
        sTag = Get2DAString(sColor2DA, sColor2DATag, iColor);
    }
    else
    {
        switch (iColor)
        {
        case 0: sTag = sColorTagRed; break;
        case 1: sTag = sColorTagGreen; break;
        case 2: sTag = sColorTagBlue; break;
        case 3: sTag = sColorTagCyan; break;
        case 4: sTag = sColorTagMagenta; break;
        case 5: sTag = sColorTagYellow; break;
        default: sTag = "";
        }
    }
    return sTag;
}

void SetColorMenuStrings()
{
    int iColor=0;
    int bOk = TRUE;
    string sColor, sTag;
    string sLine;
    while (bOk)
    {
        bOk = FALSE;
        sColor = GetColorName(iColor);
        if (sColor!="")
        {
            sTag = GetColorTag(iColor);
            if (MK_IsColorTag(sTag))
            {
                sLine = sTag+sColor+"</c>";

                SetCustomToken(19951+iColor, sLine);

                MK_GenericDialog_SetCondition(iColor+1, TRUE);
                bOk = TRUE;
                iColor++;
            }
        }
        else
        {
        }
    }
    while (iColor<20)
    {
        MK_GenericDialog_SetCondition(iColor+1, FALSE);
        iColor++;
    }
    MK_GenericDialog_SetCondition(21, TRUE); // Color off
}

string GetFileSlotVarName(int nSlot)
{
    return g_varEditorLoadSaveSlots +
        MK_IntToString(nSlot, 2, "0");
}

string LoadTextFromSlot(object oObject, int nSlot, int nMaxLength, int nLineFeedMode)
{
    string sSlotVarName = GetFileSlotVarName(nSlot);
    string sText = GetLocalString(oObject, sSlotVarName);
    if ((nMaxLength>0) && (MK_GetStringLength(sText, TRUE)>nMaxLength))
    {
        sText = MK_GetStringLeft(sText, nMaxLength, TRUE);
    }
    switch (nLineFeedMode)
    {
    case 0: // ignore
        break;
    case 1: // cut
        {
            int nNewLinePos = FindSubString(sText, "\n");
            if (nNewLinePos!=-1)
            {
                sText = GetStringLeft(sText, nNewLinePos);
            }
        }
        break;
    case 2: // remove
        sText = MK_RemoveFromString(sText, "\n");
        break;
    }
    return sText;
}

void SaveTextToSlot(object oObject, int nSlot, string sText)
{
    string sSlotVarName = GetFileSlotVarName(nSlot);
    SetLocalString(oObject, sSlotVarName, sText);
}

string CreateFileMenuText(object oObject, int bSave, int nSlot)
{
    string sLine="";

    string sText = LoadTextFromSlot(oObject, nSlot, -1, 2);
    if ((!bSave) && (sText==""))
    {
        // we don't want to load empty text;
        return sLine;
    }

    // if the text is too long we display only the first characters
    if (MK_GetStringLength(sText,TRUE)>nMaxTextDisplayLength)
    {
        sText = MK_GetStringLeft(sText, nMaxTextDisplayLength-2, TRUE) + "...";
    }

    if (sText=="")
    {
        sText = "empty";
    }
    else
    {
        sText = "'"+sText+"'";
    }

    sLine = (bSave ? sSaveToSlotColorTag + "Save to" :
                     sLoadFromSlotColorTag + "Load from") +
        " slot " + MK_IntToString(nSlot, 2, "0") + sCloseTag +
        " (" + sText + ")";
    return sLine;
}

void SetFileMenuStrings(object oObject)
{
    int nStartToken = 19951;
    int i=0;
    string sLine;
    while (++i<=2*nNumberOfLoadSaveSlots)
    {
        sLine = CreateFileMenuText(oObject,
            i<=nNumberOfLoadSaveSlots,
            ((i-1) % nNumberOfLoadSaveSlots) +1);

        SetCustomToken(nStartToken+i-1, sLine);
        MK_GenericDialog_SetCondition(i,sLine!="");
    }
    do
    {
        MK_GenericDialog_SetCondition(i, FALSE);
    }
    while (++i<=21);
}

string GetPCChatMessageEx(object oPC, int bUsePlayerChatEvent)
{
    string sMessage;
    if (bUsePlayerChatEvent)
    {
        sMessage = GetLocalString(oPC, g_varEditorChatMessageString);
    }
    else
    {
        sMessage = GetPCChatMessage();
    }
    return sMessage;
}

void IncLocalInt(object oObject, string sVarName, int n)
{
    if (!GetIsObjectValid(oObject)) return;
    int nValue = GetLocalInt(oObject, sVarName);
    nValue+=n;
    SetLocalInt(oObject, sVarName, nValue);
}

struct mk_lastaction
{
    int nAction;
    float fTimeStamp;
};

// stores nAction and the current time on the oObject
void StoreAction(object oObject, int nAction)
{
    SetLocalInt(oObject, g_varEditorLastAction, nAction);
    mk_writeTimeStampToObject(oObject, g_varEditorTimeStamp);
}

// reads nAction and time stamp from oObject
struct mk_lastAction GetLastAction(object oObject)
{
    struct mk_lastAction lastAction;
    lastAction.nAction = GetLocalInt(oObject, g_varEditorLastAction);
    lastAction.fTimeStamp = mk_getTimeSinceTimeStamp(oObject, g_varEditorTimeStamp);
    return lastAction;
}

int CalculateCursorSpeed(object oObject, int nAction)
{
    int nCursorSpeed=1;
    struct mk_lastAction lastAction = GetLastAction(oObject);
    int nCursorSpeedMode;

    if (nAction==lastAction.nAction)
    {
        nCursorSpeedMode = GetLocalInt(oObject, g_varEditorCursorSpeedMode);

        // Time passed in milliseconds
        float fTimeSpan = lastAction.fTimeStamp * 2.0f * 60.0f * 1000.0f;

        struct mk_datetime dateTimeSpan =
            mk_timeStampToDateTimeSpan(lastAction.fTimeStamp);
        string sOutput = mk_formatDateTimeSpan(dateTimeSpan);
/*
        SendMessageToPC(oObject, "Delta="+sOutput+" ("+FloatToString(lastAction.fTimeStamp)+") ,"
            +IntToString(FloatToInt(fTimeSpan))+" milliseconds.");
*/
        if (fTimeSpan < fSpeedUpCursorMovementTime)
        {
            nCursorSpeedMode++;
        }
        else if (fTimeSpan < 2.0 * fSpeedUpCursorMovementTime)
        {
        }
        else if (fTimeSpan < 3.0 * fSpeedUpCursorMovementTime)
        {
            nCursorSpeedMode--;
        }
        else
        {
            nCursorSpeedMode=1;
        }
        if (nCursorSpeedMode< 1) nCursorSpeedMode= 1;
        if (nCursorSpeedMode>10) nCursorSpeedMode=10;
    }
    else
    {
        nCursorSpeedMode = 1;
    }

    SetLocalInt(oObject, g_varEditorCursorSpeedMode, nCursorSpeedMode);

    switch (nCursorSpeedMode)
    {
    case 1:
    case 2:
        nCursorSpeed=1;
        break;
    case 3:
    case 4:
        nCursorSpeed=2;
        break;
    case 5:
    case 6:
        nCursorSpeed=3;
        break;
    case 7:
    case 8:
        nCursorSpeed=4;
        break;
    case 9:
    case 10:
        nCursorSpeed=5;
        break;
    }
/*
    SendMessageToPC(oObject,
        "CursorSpeedMode=" + IntToString(nCursorSpeedMode)+", "+
        "CursorSpeed="     + IntToString(nCursorSpeed));
*/
    return nCursorSpeed;
}


