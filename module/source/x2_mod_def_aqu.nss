//::///////////////////////////////////////////////
//:: Example XP2 OnItemAcquireScript
//:: x2_mod_def_aqu
//:: (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Put into: OnItemAcquire Event

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-07-16
//:://////////////////////////////////////////////

#include "x2_inc_switches"
#include "nw_i0_plotwizard"

void main()
{
    // PLOT WIZARD MANAGED CODE BEGINS
    PWSetMinLocalIntAndJournalForItemAcquired("p015state", "p015", 2, "EssenceofHernathiusBloodclaw", 3500);
    PWSetMinLocalIntAndJournalForItemAcquired("p012state", "p012", 2, "SkullofanUrMensch", 1400);
    PWSetMinLocalIntAndJournalForItemAcquired("p010state", "p010", 2, "SymbolofShipper", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p002state", "p002", 2, "VillainHead", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p005state", "p005", 2, "Mithral", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p014state", "p014", 2, "AVillianess", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p013state", "p013", 2, "Kingeethestolenchild", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p008state", "p008", 10, "GessachersBrightness", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p008state", "p008", 6, "SchillingersTear", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p008state", "p008", 2, "BranchfromtheTreeofLifesEssence", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p004state", "p004", 11, "EssenceofAlendor", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p004state", "p004", 8, "RawGemofPower", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p004state", "p004", 5, "MithralStar", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p004state", "p004", 2, "Earthwood", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p001state", "p001", 2, "HiltoftheEarthSword", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p006state", "p006", 3, "BladeofEarthsSword", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p007state", "p007", 2, "BloodofKakorn", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p000state", "p000", 2, "VillainHead", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p003state", "p003", 2, "GatewayGem", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p011state", "p011", 2, "TheheartofDarkness", 0);
    PWSetMinLocalIntAndJournalForItemAcquired("p009state", "p009", 2, "BareschFamilyHierloom", 650);
    // PLOT WIZARD MANAGED CODE ENDS

     object oItem = GetModuleItemAcquired();
     // * Generic Item Script Execution Code
     // * If MODULE_SWITCH_EXECUTE_TAGBASED_SCRIPTS is set to TRUE on the module,
     // * it will execute a script that has the same name as the item's tag
     // * inside this script you can manage scripts for all events by checking against
     // * GetUserDefinedItemEventNumber(). See x2_it_example.nss
     if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS) == TRUE)
     {
        SetUserDefinedItemEventNumber(X2_ITEM_EVENT_ACQUIRE);
        int nRet =   ExecuteScriptAndReturnInt(GetUserDefinedItemEventScriptName(oItem),OBJECT_SELF);
        if (nRet == X2_EXECUTE_SCRIPT_END)
        {
           return;
        }
     }
}

