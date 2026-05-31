
//::///////////////////////////////////////////////
//:: Example XP2 OnActivate Script Script
//:: x2_mod_def_act
//:: (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Put into: OnItemActivate Event

*/
#include "nw_i0_plot"
#include "x2_inc_switches"
#include "se_inc_pc_loc"
void main()
{{

//IsRecall is defined in nw_i0_plot
    IsRecall();
}
//CNR addon
     ExecuteScript("cnr_module_onact",OBJECT_SELF);
//End CNR addon

     object oItem = GetItemActivated();


     // * Generic Item Script Execution Code
     // * If MODULE_SWITCH_EXECUTE_TAGBASED_SCRIPTS is set to TRUE on the module,
     // * it will execute a script that has the same name as the item's tag
     // * inside this script you can manage scripts for all events by checking against
     // * GetUserDefinedItemEventNumber(). See x2_it_example.nss
     if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS) == TRUE)
     {
        SetUserDefinedItemEventNumber(X2_ITEM_EVENT_ACTIVATE);
        int nRet =   ExecuteScriptAndReturnInt(GetUserDefinedItemEventScriptName(oItem),OBJECT_SELF);
        if (nRet == X2_EXECUTE_SCRIPT_END)

//Sir Elrics Persistent Player Location addon
        SE_SaveLocation(GetItemActivator());
        {
           return;
//End Sir Elrics Persistent Player Location addon
        }

     }

{
//Dye Kit addon
    object oItem        = GetItemActivated();
    object oPC          = GetItemActivator();
    string sItemTag     = GetTag(oItem);

    if (sItemTag == "DyeKit") AssignCommand(oPC, ActionStartConversation(oPC, "dye_dyekit", TRUE));
//End Dye Kit addon
}
}
