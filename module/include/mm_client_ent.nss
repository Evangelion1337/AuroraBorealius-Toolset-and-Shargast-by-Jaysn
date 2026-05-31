//mm_client_ent
#include "se_new_player"
#include "pqj_inc"
#include "se_inc_pc_loc"

void main()
{
ExecuteScript("bpm_mod_onact",OBJECT_SELF);

//CNR addon
     ExecuteScript("cnr_module_oce",OBJECT_SELF);

//End CNR addon


//Persistent Quest Joural Entry's addon
ExecuteScript("bpm_mod_enter",GetEnteringObject());
RebuildJournalQuestEntries(GetEnteringObject());
//End Persistent Quest Joural Entry's addon

//Sir Elrics Persistent Player Location addon
    object oPC = GetEnteringObject();
    if(GetLocalInt(oPC, "ENTERED") == FALSE)
    SE_PersistantPCLocation(oPC);
    SirElrics_SimplePlayerSetUp(oPC);
//End Sir Elrics Persistent Player Location addon

ExecuteScript("sd_soc_install",oPC);
}
