//::///////////////////////////////////////////////
//:: Name
//:: FileName mk_inc_editor_c
//:: Copyright (c) 2008
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By: Kamiryn
//:: Created On: 2008-03-03
//:://////////////////////////////////////////////

// Cursor used by the editor
const string sCursor = "|";

// Name of a color 2DA file
const string sColor2DA = "mk_colors";

// Name of column of the color name
const string sColor2DAName = "Color";

// Name of column of the color tag
const string sColor2DATag = "Code";

// the text color, used for the text
const string sText1ColorTag = "<cþþþ>";

// the editor color, used for top and bottom lines
const string sText2ColorTag = "<c¥¥¥>";

// the color of the cursor
const string sCursorColorTag = "<c þ >";

// if a block is marked this color gets used
const string sBlockColorTag = "<c þþ>";

// the color used to highlight the 'keys'
const string sKeyColorTag = "<cþ¥ >";

// the color used for the 'OK' button
const string sExitColorTag = "<c  þ>";

// the color used for the 'Cancel' button
const string sCancelColorTag = "<cþ  >";

// the color used to highlight the 'Insert' option
const string sInsertColorTag = "<cþþ >";

// the color of 'Back to main menu'
const string sBackToMainMenuColor = "<c¡¡±>";

// the color used for the 'Help' button.
const string sHelpColorTag = "<cþþþ>";

// the color used for the Load/Save button
const string sLoadSaveColorTag = "<c þ >";

const string sLoadFromSlotColorTag = "<c þ >";
const string sSaveToSlotColorTag = "<cþ þ>";

// the color used for text 'Color Off'
const string sColorOffColorTag = "<cþþþ>";

// the close color tag. Don't change it.
const string sCloseTag = "</c>";

const string sColorNameRed     = "red";
const string sColorTagRed      = "<cþ  >";
const string sColorNameGreen   = "green";
const string sColorTagGreen    = "<c þ >";
const string sColorNameBlue    = "blue";
const string sColorTagBlue     = "<c  þ>";
const string sColorNameCyan    = "cyan";
const string sColorTagCyan     = "<c þþ>";
const string sColorNameMagenta = "magenta";
const string sColorTagMagenta  = "<cþ þ>";
const string sColorNameYellow  = "yellow";
const string sColorTagYellow   = "<cþþ >";

const float fSpeedUpCursorMovementTime = 250.0f; // Milliseconds

/*
void main()
{

}
/* */
