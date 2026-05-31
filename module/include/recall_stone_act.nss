#include "nw_i0_plot"
void main()
{
    //IsRecall is defined in nw_i0_plot
    IsRecall();
	
	object oItem        = GetItemActivated();
    object oPC          = GetItemActivator();
    string sItemTag     = GetTag(oItem);

	ExecuteScript(GetTag(GetItemActivated()), OBJECT_SELF);

	if (GetTag(GetItemActivated()) == "ModuleReloader")
	{
		StartNewModule("Shargast - Ch 1 [PRC8-CEP2]");
		return;
	}

	if (sItemTag == "DyeKit") AssignCommand(oPC, ActionStartConversation(oPC, "dye_dyekit", TRUE));
}