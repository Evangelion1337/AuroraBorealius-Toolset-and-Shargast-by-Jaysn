// Name     : Avlis Persistence System OnModuleLoad
// Purpose  : Initialize APS on module load event
// Authors  : Ingmar Stieger
// Modified : January 27, 2003

// This file is licensed under the terms of the
// GNU GENERAL PUBLIC LICENSE (GPL) Version 2

#include "aps_include"

void main()
{
    // Init placeholders for ODBC gateway
    SQLInit();

//CNR addon
     ExecuteScript("cnr_module_oml",OBJECT_SELF);
//End CNR addon

	ExecuteScript( "x3_mod_def_load", OBJECT_SELF);


    //sets up the save every 20 minutes
 DelayCommand(2400.0, SignalEvent(OBJECT_SELF, EventUserDefined(200)));


//Custom Colour Tokens addon

    SetCustomToken(100, "</c>"); // CLOSE tag
    SetCustomToken(101, "<cþ  >"); // red
    SetCustomToken(102, "<c þ >"); // green
    SetCustomToken(103, "<c  þ>"); // blue
    SetCustomToken(104, "<c þþ>"); // cyan
    SetCustomToken(105, "<cþ þ>"); // magenta
    SetCustomToken(106, "<cþþ >"); // yellow
    SetCustomToken(107, "<c   >"); // black
    SetCustomToken(108, "<c¥  >"); // dark red
    SetCustomToken(109, "<c ¥ >"); // dark green
    SetCustomToken(110, "<c  ¥>"); // dark blue
    SetCustomToken(111, "<c ¥¥>"); // dark cyan
    SetCustomToken(112, "<c¥ ¥>"); // dark magenta
    SetCustomToken(113, "<c¥¥ >"); // dark yellow
    SetCustomToken(114, "<c¥¥¥>"); // grey
    SetCustomToken(117, "<cŒŒŒ>"); // dark grey
    SetCustomToken(115, "<cþ¥ >"); // orange
    SetCustomToken(116, "<cþŒ >"); // dark orange
    SetCustomToken(117, "<cÚ¥#>"); // brown
    SetCustomToken(118, "<cÂ† >"); // dark brown
//End Custom Colour Tokens addon

}
