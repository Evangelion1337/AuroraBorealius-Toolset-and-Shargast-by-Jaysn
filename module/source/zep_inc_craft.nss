//:://////////////////////////////////////////////
//:: Completely redone Armor and Weapon redesign functions
//:: Further redone by Loki Hakanin
//:: zep_inc_craft
//:://////////////////////////////////////////////
/*
    This is a complete rework of the Armor- and Weaponcrafting skill
    No existing scripts are overridden or replaced, only the conversation
    x0_skill_ctrap needs to be replaced to activate the custom crafting.

    Original scripts written by SartriX
    Modified for inclusion in the CEP by Loki Hakanin
    Note from Loki: In general, all comments I've added
    will be labeled as "Note from Loki".

    Additions to the original Bioware scripts:
    - Bugs fixed
    - Enhanced performance
    - Support for custom armor- and weaponmodels
    - Helmet and Shield crafting added

    Note from Loki: Do not have a decent server handy to
    test the below out on.  If the zep_cr_nocheat script is
    used either as an "OnEnter" script for a module/server,
    or executed therein, it should stop this exploit.  This
    function is 100% SartriX's original, as since I have not
    tested it, I do not know if it needs modification.
    - Counters the 'double item' exploit !

    Note from Loki: Optional Features: Can be enabled
    by enabling flags.  Bottom 2 use SartriX's original
    code, but just with renamed variables and the like to
    conform to CEP naming convention.
    - Reworked Cost and DC
    - Use of crafting placeables (like Forge)
    - Use of NPC crafters

    Modifications and enhancements by Loki Hakanin-
    - Fixed errors in logic of conditional statements
        causing them not to function when a PC attempts
        crafting by themselves (with the "require
        placble" flag set to FALSE).
    - Added code to next/previous cyclying segments to
        enhance robustness-functions can now handle
        irregular inputs-that is to say, custom models
        that aren't all 100% identical to Bioware
        numbering conventions (e.g. more than 3
        appearances/colors for a given shield index, more
        than 4 for weapons).
    - Fixed coding error causing shield alterations to require
        dyes.
    - Added support for new CEP weapon types.
    - Fixed error causing incorrect display of leg options
    - Fixed glitch preventing remodelling of hand axes.

    To be Added Later:
    - Built in color selection for armor and helmets (optional flag)

    Note from Loki: Note that the code for coloring and
    the like is still here, I have merely temporarily
    disabled it, by and large  For CEP R1, we wanted
    things to work just like Bioware's code where we were
    replacing/updating code to work with custom content.
    Also, as the dynamic color alteration requires
    addiitonal item blueprints (the full dyeset), there
    was concern this would make default Bioware dyes
    useless, violating the CEP's "harm no existing content"
    rule.  This code and these items will be re-worked in a
    later release to integrate with the original Bioware
    dyes.

    This crafting system  was originally made by SartriX
    His original scriptset has been posted on nwvault:
    - http://nwvault.ign.com/Files/scripts/data/1071920548260.shtml

*/
//:://////////////////////////////////////////////
//:: Created By: SartriX(original version)
//:: Modified by Loki Hakanin
//:: Created On(original version): 16-dec-2003
//:: Updated On(original version): 16-jan-2004
//:: Updated/Modified by Loki: 26-Feb-2004
//:://////////////////////////////////////////////
#include "prc_inc_racial"
#include "x2_inc_craft"
#include "zep_inc_main"

// Set to FALSE to disable the requirement of the proper placeable to be near the PC
const int    ZEP_CR_REQUIRE_PLACEABLE = FALSE;
//Tag of crafting placeable
const string ZEP_CR_PLACEABLE_TAG = "zep_cr_craftplace";
// Maximum distance to a crafting placeable
const float  ZEP_CR_REQUIRED_DISTANCE = 4.0f;

// Set to FALSE to disable the requirement and use of dyes when recolouring
const int    ZEP_CR_REQUIRE_DYES      = FALSE;

// Maximum cost in percent of the item's original valie at all times regardless of any other settings
const int    ZEP_CR_MAXCOST           = 90;
// Percentage of cost for each part of a weapon (3 parts max) or a helmet/shield (1 part max)
const int    ZEP_CR_PARTCOST          = 20;
// Added percentage of cost for dye changes by NPC
const int    ZEP_CR_NPCDYECOST        = 1;
// Percentage it costs to craft one self compared to what a NPC would ask for the same
// NPC cost is always 100% of the CraftCost in des_crft_aparts.2da
const int    ZEP_CR_SELFCRAFT         = 70;
// The DC that's added to craft magical items. This DC is added for each magical property it has
const int    ZEP_CR_DCADD             = 2;

// Tag of the backup container
// One is supplied as custom placeable (custom -> special -> custom5 -> zep_cr_backup)
// and should be placed on a preferrably inaccessible location. If the container can not be found,
// the backup item will be added to the PC's inventory, it won't break the entire script.
// Note from Loki:  I've altered this implementatoin as well.
// Following Bioware's example, I spawn and make invisible a crafting container
// if I find none in the module.  Difference being, I delete
// it at the end of crafting, for completeness's sake.
const string ZEP_CR_BACKUP_PLACEABLE  = "zep_cr_backup";

// Internal constants, do not touch!
const int    ZEP_CR_DONE_SUCCESS = 1;
const int    ZEP_CR_DONE_FAILED  = 2;
const int    ZEP_CR_DONE_NOGOLD  = 3;
const int    ZEP_CR_DONE_NODYE   = 4;

const int    ZEP_CR_PART_NEXT  = 0;
const int    ZEP_CR_PART_PREV  = 1;
const int    ZEP_CR_COLOR_NEXT = 3;
const int    ZEP_CR_COLOR_PREV = 4;

const int    ZEP_CR_TOKENBASE = 20000;

const int    ZEP_CR_HELMET = 8888;
const int    ZEP_CR_SHIELD = 8889;

//Note from Loki: Above constants were all from
//the original script.  Have simply been renamed to
//keep them consistent with CEP nomenclature.
//Constants declared below are my own additions:

//This constant controls whether SartriX's modified
//DC and costs are used.  By default, it is FALSE
//(using Bioware defaults instead).  Re-enabling it
//will use the costs in the des_crft_aparts.2da
//file instead.
const int    ZEP_USE_OPTIONAL_DC_COST = FALSE;

//Following constants added when we removed the NumParts
//alterations from the des_crafts_aparts.2da file.  This was
//done so people using the default NWN crafting system with
//the CEP would not have a very long set of armors that
//would have blank entries (all the lines in the armor
//2DA files from the last Bioware to the first CEP entry).
//These constants define the max "numparts" in place of the
//2DA files
//Note that weapons and helmets still read the baseitems
//file correctly, or have no problems with the default Bioware
//craft system.  Shields, of course, are only craftable with
//a custom script, so they are not included as the below is
//a "legacy compatibility" change.

const int ZEP_MAX_PARTS_NECK = 255;
const int ZEP_MAX_PARTS_SHOULDER = 255;
const int ZEP_MAX_PARTS_BICEP = 255;
const int ZEP_MAX_PARTS_FOREARM = 255;
const int ZEP_MAX_PARTS_HAND = 255;
const int ZEP_MAX_PARTS_TORSO = 255;
const int ZEP_MAX_PARTS_BELT = 255;
const int ZEP_MAX_PARTS_PELVIS = 255;
const int ZEP_MAX_PARTS_THIGH = 255;
const int ZEP_MAX_PARTS_SHIN = 255;
const int ZEP_MAX_PARTS_FOOT = 255;
const int ZEP_MAX_PARTS_ROBE = 255;


// - End of constants - //


// Sets up everything for oPC to start crafting on oItem
void ZEP_StartCraft(object oPC, object oItem);

// Tries to let oPC perform the crafting of his current item
// Will set the localvar ZEP_CR_DONE on success or fail with one
// of the following values to check with a conditional script:
//    ZEP_CR_DONE_SUCCESS
//    ZEP_CR_DONE_FAILED
//    ZEP_CR_DONE_NOGOLD
//    ZEP_CR_DONE_NODYE
void ZEP_AttemptCraft(object oPC);

// Stops crafting and cleans up everything set by the crafting script
// When nExecute is FALSE, it will abort the craft,
// when it's TRUE, it will replace the old item with the new one.
void ZEP_StopCraft(object oPC, int nExecute=FALSE);

// Sets the current part oPC is working on
// It accepts all 4 partseries ITEM_APPR_ARMOR_MODEL_*,
// ITEM_APPR_WEAPON_MODEL_*, ITEM_APPR_ARMOR_COLOR_*, ITEM_APPR_WEAPON_COLOR_*
// as long as the proper item has been set to craft on
// Focusses the camery on the selected part (if applicable)
void ZEP_SetPart(object oPC, int nPart, int nStrRef);

// Gets the cost to modify oItem into oNew
// Calls the default bioware routines for this, edit this function to override
int ZEP_GetModificationCost(object oItem, object oNew, int nNPC=FALSE);

// Gets the DC to modify oItem into oNew
// Calls the default bioware routines for this, edit this function to override
int ZEP_GetModificationDC(object oItem, object oNew, int nNPC=FALSE);

// Remakes and equips the item oPC is working, having the currently set part
// cycled either forward or backward
// nMode: ZEP_CR_PART_NEXT - cycle forward
// nMode: ZEP_CR_PART_PREV - cycle backward
void ZEP_RemakeItem(object oPC, int nMode);

// Remakes and equips the item oPC is working, having the currently set color
// cycled either forward or backward
// nMode: ZEP_CR_COLOR_NEXT - cycle forward
// nMode: ZEP_CR_COLOR_PREV - cycle backward
void ZEP_RecolorItem(object oPC, int nMode);

//Function Added by Loki
//Decided to do container checks dynamically and have it
//construct a work container as necessary.  This closely
//mirrors Bioware's Own implementation.
object ZEP_GetZEPWorkContainer(object oCaller);

//Function added by Loki
//Below function used as a substitution for the
//IPGetNumberOfArmorAppearances function in the CEP code.
//This is done because the max NumParts is coded as a
//constant to ensure compatibility with "vanilla' NWN.
int ZEP_GetNumberOfArmorAppearances(int nPart);


// - Implementation - //


// Sets up everything for oPC to start crafting on oItem
void ZEP_StartCraft(object oPC, object oItem) {
    // Immobilize player while crafting
    effect eImmob = EffectCutsceneImmobilize();
    eImmob = ExtraordinaryEffect(eImmob);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT,eImmob,oPC);

    // Make the camera float near the PC
    StoreCameraFacing();
    float fFacing  = GetFacing(oPC) + 180.0;
    if (fFacing >= 360.0) fFacing -=360.0;
    SetCameraFacing(fFacing, 3.5f, 75.0, CAMERA_TRANSITION_TYPE_FAST);

    // Make backup
    // Note from Loki: Changed implemenation to stash item in container ALWAYS.
    // ZEP_GetZEPWorkContainer will create container if needs be.
    object oBackup = CopyItem(oItem, ZEP_GetZEPWorkContainer(OBJECT_SELF), TRUE);
    SetLocalObject(oPC, "ZEP_CR_BACKUP", oBackup);

    // Mark temporary item
    SetStolenFlag(oItem, TRUE);
    SetLocalInt(oItem, "ZEP_CR_TEMPITEM", TRUE);
    SetLocalObject(oPC, "ZEP_CR_ITEM", oItem);

    // Preset settings
    SetLocalInt(oPC, "ZEP_CR_STARTED", 1);
    SetLocalInt(oPC, "ZEP_CR_COST", 0);
    SetLocalInt(oPC, "ZEP_CR_DC", 0);
    SetLocalInt(oPC, "ZEP_CR_DONE", 0);
    SetLocalInt(oPC, "ZEP_CR_CHANGED", FALSE);
    SetCustomToken(ZEP_CR_TOKENBASE,   "");
    SetCustomToken(ZEP_CR_TOKENBASE+1, "0");
    SetCustomToken(ZEP_CR_TOKENBASE+2, "0");
    SetCustomToken(ZEP_CR_TOKENBASE+3, "");
}

// - private -
// Checks if the color for nIndex has changed, if not returns TRUE
// if it has, checks if oPC has the new dye and returns TRUE when he has
// returns FALSE and sets CUSTOM20003 when the required dye is not present
int ZEP_ColorCheck(object oPC, object oItem, object oBackup, int nType, int nIndex) {
    // if required dyes are disabled, always return TRUE
    if (!ZEP_CR_REQUIRE_DYES) return TRUE;

    // get new color
    int nColor = GetItemAppearance(oItem, nType, nIndex);
    string sDyeTag = "Dye";

    if (nColor != GetItemAppearance(oBackup, nType, nIndex)) {
        // color has changed, build the tag for the required dye
        if (nType == ITEM_APPR_TYPE_ARMOR_COLOR) {
            switch(nIndex) {
                case ITEM_APPR_ARMOR_COLOR_CLOTH1:
                case ITEM_APPR_ARMOR_COLOR_CLOTH2:   sDyeTag+= "C"; break;
                case ITEM_APPR_ARMOR_COLOR_LEATHER1:
                case ITEM_APPR_ARMOR_COLOR_LEATHER2: sDyeTag+= "L"; break;
                case ITEM_APPR_ARMOR_COLOR_METAL1:
                case ITEM_APPR_ARMOR_COLOR_METAL2:   sDyeTag+= "M";
                    if (nColor>55 && nColor<60) nColor-=4; break; // translate missing/double metal colors
            }
            if (nColor<10) sDyeTag+= "0";
            sDyeTag+= IntToString(nColor);
        } else {
            switch (nColor) {
                case 1: sDyeTag+= "M01"; break; // Steel
                case 2: sDyeTag+= "M13"; break; // Gold
                case 3: sDyeTag+= "M21"; break; // Copper
                case 4: sDyeTag+= "M02"; break; // Dark Steel
            }
        }
        if (GetIsObjectValid(GetItemPossessedBy(oPC, sDyeTag))) {
            // oPC has the dye, so this color is alright
            SetLocalString(oPC, "ZEP_CR_DYES", GetLocalString(oPC, "ZEP_CR_DYES") + sDyeTag + ":");
            return TRUE;
        } else {
            // oPC does not have the dye, tell which dye is missing
            if (GetName(GetObjectByTag(sDyeTag))=="") SpeakString("Missing dye/name: "+sDyeTag);
            SetCustomToken(ZEP_CR_TOKENBASE+3, GetName(GetObjectByTag(sDyeTag)));
            return FALSE;
        }
    }
    return TRUE;
}

// Tries to let oPC perform the crafting of his current item
// Will set the localvar ZEP_CR_DONE on success or fail with one
// of the following values to check with a conditional script:
//    ZEP_CR_DONE_SUCCESS
//    ZEP_CR_DONE_FAILED
//    ZEP_CR_DONE_NOGOLD
//    ZEP_CR_DONE_NODYE
void ZEP_AttemptCraft(object oPC) {
    // don't reattempt a previously craftattempt
    if (GetLocalInt(oPC, "ZEP_CR_DONE")>0) return;

    // get current item and backup
    object oItem = GetLocalObject(oPC, "ZEP_CR_ITEM");
    object oBackup = GetLocalObject(oPC, "ZEP_CR_BACKUP");
    int nNPC = GetIsObjectValid(GetLocalObject(oPC, "ZEP_CR_NPC"));
    int nCost = ZEP_GetModificationCost(oBackup, oItem, nNPC);
    int nDC   = ZEP_GetModificationDC(oBackup, oItem, nNPC);
    int nSkill;

    if (GetGold(oPC)<nCost) {
        // player has insufficent gold, cancel
        SetLocalInt(oPC, "ZEP_CR_DONE", ZEP_CR_DONE_NOGOLD);
        return;
    }
    // check if all dyes are present and set the skill to be used
    if (GetBaseItemType(oItem)==BASE_ITEM_ARMOR || GetBaseItemType(oItem)==BASE_ITEM_HELMET) {
        if (!nNPC) {
          if (!(ZEP_ColorCheck(oPC, oItem, oBackup, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1)
           && ZEP_ColorCheck(oPC, oItem, oBackup, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2)
           && ZEP_ColorCheck(oPC, oItem, oBackup, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1)
           && ZEP_ColorCheck(oPC, oItem, oBackup, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2)
           && ZEP_ColorCheck(oPC, oItem, oBackup, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1)
           && ZEP_ColorCheck(oPC, oItem, oBackup, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2))) {
            SetLocalInt(oPC, "ZEP_CR_DONE", ZEP_CR_DONE_NODYE);
            return;
          }
        }
        nSkill = SKILL_CRAFT_ARMOR;
    } else
      {

 /*Next bit was part of else*/   //if ((GetBaseItemType(oItem) != BASE_ITEM_LARGESHIELD) && (GetBaseItemType(oItem) != BASE_ITEM_SMALLSHIELD) && (GetBaseItemType(oItem) != BASE_ITEM_TOWERSHIELD)) {
//        if (!nNPC) {
//          if (!(ZEP_ColorCheck(oPC, oItem, oBackup, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_TOP)
//           && ZEP_ColorCheck(oPC, oItem, oBackup, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_MIDDLE)
//           && ZEP_ColorCheck(oPC, oItem, oBackup, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_BOTTOM))) {
//            SetLocalInt(oPC, "ZEP_CR_DONE", ZEP_CR_DONE_NODYE);
//            return;
//          }
       // }
        nSkill = SKILL_CRAFT_WEAPON;
    }

    // take gold
    TakeGoldFromCreature(nCost, oPC, TRUE);
    // take dyes
    string sDyes = GetLocalString(oPC, "ZEP_CR_DYES");
    string sDyeTag;
    int nLen = GetStringLength(sDyes);
    int n;
    while (sDyes!="") {
        n = FindSubString(sDyes, ":");
        sDyeTag = GetSubString(sDyes, 0, n);
        sDyes = GetSubString(sDyes, n+1, nLen);
        DestroyObject(GetItemPossessedBy(oPC, sDyeTag));
    }
    // roll DC
    if (nNPC || GetIsSkillSuccessful(oPC, nSkill, nDC)) {
        SetLocalInt(oPC, "ZEP_CR_DONE", ZEP_CR_DONE_SUCCESS);
        return;
    }
    SetLocalInt(oPC, "ZEP_CR_DONE", ZEP_CR_DONE_FAILED);
}

// Stops crafting and cleans up everything set by the crafting script
// When nExecute is FALSE, it will abort the craft,
// when it's TRUE, it will replace the old item with the new one.
void ZEP_StopCraft(object oPC, int nExecute) {
    // Get and equip correct  item (backup when not successfull or cancelled)
    object oItem = GetLocalObject(oPC, "ZEP_CR_ITEM");
    object oBackup = GetLocalObject(oPC, "ZEP_CR_BACKUP");
    if (nExecute) {
        DestroyObject(oBackup);
        SetStolenFlag(oItem, FALSE);
        DeleteLocalInt(oItem, "ZEP_CR_TEMPITEM");
    } else {
        DestroyObject(oItem);
        oItem = CopyItem(oBackup, oPC, TRUE);
        DestroyObject(oBackup);
    }
    AssignCommand(oPC, ClearAllActions(TRUE));
    if (GetBaseItemType(oItem)==BASE_ITEM_ARMOR) {
        AssignCommand(oPC, ActionEquipItem(oItem, INVENTORY_SLOT_CHEST));
    } else if (GetBaseItemType(oItem)==BASE_ITEM_HELMET) {
        AssignCommand(oPC, ActionEquipItem(oItem, INVENTORY_SLOT_HEAD));
    } else {
        AssignCommand(oPC, ActionEquipItem(oItem, INVENTORY_SLOT_RIGHTHAND));
    }

    // Postclean settings
    DeleteLocalInt(oPC, "ZEP_CR_COST");
    DeleteLocalInt(oPC, "ZEP_CR_DC");
    DeleteLocalInt(oPC, "ZEP_CR_PART");
    DeleteLocalInt(oPC, "ZEP_CR_DONE");
    DeleteLocalInt(oPC, "ZEP_CR_CHANGED");
    DeleteLocalObject(oPC, "ZEP_CR_ITEM");
    DeleteLocalObject(oPC, "ZEP_CR_BACKUP");
    DeleteLocalObject(oPC, "ZEP_CR_NPC");
    DeleteLocalObject(oPC, "ZEP_CR_PLACEABLE");

    // Remove custscene immobilize and light from player
    //Note from Loki: Doesn't seem to be any light.  [FUTURE FIX]
    effect eEff = GetFirstEffect(oPC);
    while (GetIsEffectValid(eEff)) {
        if (GetEffectType(eEff) == EFFECT_TYPE_CUTSCENEIMMOBILIZE)
            RemoveEffect(oPC,eEff);
        eEff = GetNextEffect(oPC);
    }
    RestoreCameraFacing();

}

// - private -
void ZEP_SetColorToken(int nIndex, int nColor) {
    string sDyeTag = "Dye";
    switch(nIndex) {
        case ITEM_APPR_ARMOR_COLOR_CLOTH1:
        case ITEM_APPR_ARMOR_COLOR_CLOTH2:   sDyeTag+= "C"; break;
        case ITEM_APPR_ARMOR_COLOR_LEATHER1:
        case ITEM_APPR_ARMOR_COLOR_LEATHER2: sDyeTag+= "L"; break;
        case ITEM_APPR_ARMOR_COLOR_METAL1:
        case ITEM_APPR_ARMOR_COLOR_METAL2:   sDyeTag+= "M";
            if (nColor>55 && nColor<60) nColor-=4; break; // translate missing/double metal colors
    }
    if (nColor<10) sDyeTag+= "0";
    sDyeTag+= IntToString(nColor);
    SetCustomToken(ZEP_CR_TOKENBASE+3, GetName(GetObjectByTag(sDyeTag)));
}

// Sets the current part oPC is working on
// It accepts all 4 partseries ITEM_APPR_ARMOR_MODEL_*,
// ITEM_APPR_WEAPON_MODEL_*, ITEM_APPR_ARMOR_COLOR_*, ITEM_APPR_WEAPON_COLOR_*
// as long as the proper item has been set to craft on
// Focusses the camery on the selected part (if applicable)
void ZEP_SetPart(object oPC, int nPart, int nStrRef) {
    SetLocalInt(oPC, "ZEP_CR_PART", nPart);
    object oItem = GetLocalObject(oPC, "ZEP_CR_ITEM");

    // * Make the camera float near the PC
    float fFacing  = GetFacing(oPC) + 180.0;
    float fPitch   = 75.0;
    float fDistance= 3.5;

    if (GetBaseItemType(oItem)==BASE_ITEM_ARMOR) {
        switch (nPart) {
            case ITEM_APPR_ARMOR_MODEL_LBICEP:
            case ITEM_APPR_ARMOR_MODEL_LFOREARM:
            case ITEM_APPR_ARMOR_MODEL_LHAND:
            case ITEM_APPR_ARMOR_MODEL_LSHOULDER:
            case ITEM_APPR_ARMOR_MODEL_LTHIGH:
            case ITEM_APPR_ARMOR_MODEL_LSHIN:
            case ITEM_APPR_ARMOR_MODEL_LFOOT: fFacing += 60.0; break;
            case ITEM_APPR_ARMOR_MODEL_RBICEP:
            case ITEM_APPR_ARMOR_MODEL_RFOREARM:
            case ITEM_APPR_ARMOR_MODEL_RHAND:
            case ITEM_APPR_ARMOR_MODEL_RSHOULDER:
            case ITEM_APPR_ARMOR_MODEL_RTHIGH:
            case ITEM_APPR_ARMOR_MODEL_RSHIN:
            case ITEM_APPR_ARMOR_MODEL_RFOOT: fFacing -= 60.0; break;
        }
        switch (nPart) {
            case ITEM_APPR_ARMOR_MODEL_LBICEP:
            case ITEM_APPR_ARMOR_MODEL_RBICEP:
            case ITEM_APPR_ARMOR_MODEL_LFOOT:
            case ITEM_APPR_ARMOR_MODEL_RFOOT: fDistance = 3.5; fPitch = 47.0; break;
            case ITEM_APPR_ARMOR_MODEL_LFOREARM:
            case ITEM_APPR_ARMOR_MODEL_RFOREARM:
            case ITEM_APPR_ARMOR_MODEL_LHAND:
            case ITEM_APPR_ARMOR_MODEL_RHAND: fDistance = 2.0; fPitch = 60.0; break;
            case ITEM_APPR_ARMOR_MODEL_LSHIN:
            case ITEM_APPR_ARMOR_MODEL_RSHIN: fDistance = 3.5; fPitch = 95.0; break;
            case ITEM_APPR_ARMOR_MODEL_LSHOULDER:
            case ITEM_APPR_ARMOR_MODEL_RSHOULDER: fDistance = 3.0; fPitch = 50.0; break;
            case ITEM_APPR_ARMOR_MODEL_LTHIGH:
            case ITEM_APPR_ARMOR_MODEL_RTHIGH: fDistance = 2.5; fPitch = 65.0; break;
            case ITEM_APPR_ARMOR_MODEL_NECK: fPitch = 90.0; break;
            case ITEM_APPR_ARMOR_MODEL_BELT:
            case ITEM_APPR_ARMOR_MODEL_PELVIS: fDistance = 2.0; break;
        }
    } else if (nPart==ZEP_CR_HELMET) {
        fDistance = 2.5;
        fPitch = 85.0;
    } else if (nPart==ZEP_CR_SHIELD) {
        fFacing += 60.0;
        fDistance = 3.0;
        fPitch = 65.0;
    } else {
        fFacing -= 60.0;
        fDistance = 3.0;
        fPitch = 65.0;
    }
    if (fFacing >= 360.0) fFacing -=360.0;
    if (MyPRCGetRacialType(oPC) == RACIAL_TYPE_HALFORC) fDistance += 1.0f;
    SetCameraFacing(fFacing, fDistance, fPitch, CAMERA_TRANSITION_TYPE_VERY_FAST);

    int nCost = GetLocalInt(oPC, "ZEP_CR_COST");
    int nDC   = GetLocalInt(oPC, "ZEP_CR_DC");
    SetCustomToken(ZEP_CR_TOKENBASE, GetStringByStrRef(nStrRef));
    SetCustomToken(ZEP_CR_TOKENBASE+1, IntToString(nCost));
    SetCustomToken(ZEP_CR_TOKENBASE+2, IntToString(nDC));
    ZEP_SetColorToken(nPart, GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nPart));

}

// - private -
// Gets the cost to modify oItem into oNew
int ZEP_GetModificationCost(object oItem, object oNew, int nNPC=FALSE) {
    int nCost = 0;
    int nChanges = -1;
    int nPart;
    float fFactor;
    //Note from Loki: Below segment's logical flow modified
    //from original.  As SartriX had used differing DC and
    //cost values from Bioware, defined in  des_crft_aparts.2da,
    //this conflicted with the CEP's "play nice with Bioware"
    //policy.
    //I have left this functionality in, but you must enable
    //a flag in the constants section of this file to turn it
    //on.  Otherwise, default Bioware costs will be used.
    //Note that helmets and shields will ALWAYS default to
    //using this case, as there is no Bioware code to emulate
    //in their case.
    if ((ZEP_USE_OPTIONAL_DC_COST == TRUE) || (GetBaseItemType(oItem)==BASE_ITEM_HELMET) || (GetBaseItemType(oItem)== BASE_ITEM_LARGESHIELD) || (GetBaseItemType(oItem)== BASE_ITEM_SMALLSHIELD) || (GetBaseItemType(oItem)== BASE_ITEM_TOWERSHIELD) )
        {
        // Find and count changes
        if (GetBaseItemType(oItem)==BASE_ITEM_ARMOR) {
            for (nPart = 0; nPart<=ITEM_APPR_ARMOR_MODEL_ROBE; nPart++) {
                if (GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nPart) != GetItemAppearance(oNew, ITEM_APPR_TYPE_ARMOR_MODEL, nPart)) {
                    // Part changed, add price factor
                    nCost += StringToInt(Get2DAString("des_crft_aparts", "CraftCost", nPart));
                    nChanges++;
                }
            }
        } else {
            for (nPart = 0; nPart<3; nPart++) {
                if (GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, nPart) != GetItemAppearance(oNew, ITEM_APPR_TYPE_WEAPON_MODEL, nPart)) {
                    // Part changed, add price factor
                    nCost += ZEP_CR_PARTCOST;
                    nChanges++;
                }
            }
            nChanges *= 5;
        }
        // More as 1 part changed, give a 'discount'
        if (nChanges>0) nCost -= nChanges;
        // Reworked item may not cost more as 90% of a brand new one
        if (nCost>ZEP_CR_MAXCOST) nCost = ZEP_CR_MAXCOST;
        if (nNPC) {
            // If made by a NPC, charge for the dyes
            if (GetBaseItemType(oItem)==BASE_ITEM_ARMOR) {
                for (nPart = 0; nPart<=ITEM_APPR_ARMOR_MODEL_ROBE; nPart++) {
                    if (GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nPart) != GetItemAppearance(oNew, ITEM_APPR_TYPE_ARMOR_COLOR, nPart)) {
                        // Part changed, add price factor
                        nCost += ZEP_CR_NPCDYECOST;
                    }
                }
            } else {
                for (nPart = 0; nPart<3; nPart++) {
                    if (GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, nPart) != GetItemAppearance(oNew, ITEM_APPR_TYPE_WEAPON_COLOR, nPart)) {
                        // Part changed, add price factor
                        nCost += ZEP_CR_NPCDYECOST;
                    }
                }
            }
            fFactor = IntToFloat(nCost) / 100.0;
        } else {
            // If made by the PC himself, the price is 70% of what an NPC would ask him
            fFactor = IntToFloat(nCost * ZEP_CR_SELFCRAFT) / 10000.0;
        }
        // Calculate and return final cost
        nCost = FloatToInt(IntToFloat(GetGoldPieceValue(oItem)) * fFactor);
        if (nCost<1) nCost=1;
        }
    else  //Use base Bioware costs for armor and weapons unless told otherwise.
        {
        int nItemType=GetBaseItemType(oItem);
        if (nItemType == BASE_ITEM_ARMOR)
            {
            nPart=GetLocalInt(GetPCSpeaker(),"ZEP_CR_PART");
            if (nPart==ITEM_APPR_ARMOR_MODEL_ROBE)
                nCost=0;
            else nCost=CIGetArmorModificationCost(oItem,oNew);
            }
        else nCost=CIGetWeaponModificationCost(oItem,oNew);
        }
    return nCost;
}

// - private -
// Gets the DC to modify oItem into oNew
int ZEP_GetModificationDC(object oItem, object oNew, int nNPC=FALSE) {
    if (nNPC) return 0;
    int nDC=0;
    int nChanges = -1;
    int nPart;
    float fFactor;

    //Note from Loki: Below segment's logical flow modified
    //from original.  As SartriX had used differing DC and
    //cost values from Bioware, defined in  des_crft_aparts.2da,
    //this conflicted with the CEP's "play nice with Bioware"
    //policy.
    //I have left this functionality in, but you must enable
    //a flag in the constants section of this file to turn it
    //on.  Otherwise, default Bioware costs/DC will be used.
    //Note that helmets and shields will ALWAYS default to
    //using this case, as there is no Bioware code to emulate
    //in their case.

    if ((ZEP_USE_OPTIONAL_DC_COST == TRUE) || (GetBaseItemType(oItem)==BASE_ITEM_HELMET) || (GetBaseItemType(oItem)== BASE_ITEM_LARGESHIELD) || (GetBaseItemType(oItem)== BASE_ITEM_SMALLSHIELD) || (GetBaseItemType(oItem)== BASE_ITEM_TOWERSHIELD) )
        {
        // Find and count changes
        if (GetBaseItemType(oItem)==BASE_ITEM_ARMOR) {
            for (nPart = 0; nPart<=ITEM_APPR_ARMOR_MODEL_ROBE; nPart++) {
                if (GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nPart) != GetItemAppearance(oNew, ITEM_APPR_TYPE_ARMOR_MODEL, nPart)) {
                    // Part changed, add DC factor
                    nDC += StringToInt(Get2DAString("des_crft_aparts", "CraftDC", nPart));
                    nChanges++;
                }
            }
        } else {
            for (nPart = 0; nPart<3; nPart++) {
                if (GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, nPart) != GetItemAppearance(oNew, ITEM_APPR_TYPE_WEAPON_MODEL, nPart)) {
                    // Part changed, add DC factor
                    nDC += 6;
                    nChanges++;
                }
            }
            nChanges *= 2;
        }
        // More as 1 part changed, give a 'discount'
        if (nChanges>0) nDC -= nChanges;
        itemproperty iP = GetFirstItemProperty(oItem);
        while (GetIsItemPropertyValid(iP)) {
            nDC += ZEP_CR_DCADD;
            iP = GetNextItemProperty(oItem);
            }
        }
    else
        {
        if (GetBaseItemType(oItem)==BASE_ITEM_ARMOR)
            {
            nPart=GetLocalInt(GetPCSpeaker(),"ZEP_CR_PART");
            if (nPart==ITEM_APPR_ARMOR_MODEL_ROBE)
                nDC=0;
            else nDC=CIGetArmorModificationDC(oItem,oNew);
            }
        else nDC=15;    //This value pulled directly from Bioware scripts.
        }
    return nDC;

}

// - private -
// Reverses a : seperated stringlist
string ZEP_ListReverse(string s) {
    string sCache;
    int n;
    int l = GetStringLength(s);
    s = GetSubString(s, 1, l);
    while (s!="") {
        // take string upto next seperator and put this in front of cache
        n = FindSubString(s, ":")+1;
        sCache = GetStringLeft(s, n) + sCache;
        s = GetSubString(s, n, l);
    }
    return ":"+sCache;
}

// - private -
// Prereads the parts_chest.2da-file for sAC and puts all used ID's in a : seperated stringlist
string ZEP_PreReadArmorACList(string sAC) {
    // pick the right 2da to read the parts from
    string s2DA = "parts_chest";
    string sCache= ":";
    string sLine;
    // get the maxID used (not the amount of ID's !!!)
    //int nMax = IPGetNumberOfArmorAppearances(ITEM_APPR_ARMOR_MODEL_TORSO);
    //Note from Loki: Below line changed to make use of
    //backward compatibility function.  Was previously the
    //preceding line.
    int nMax = ZEP_GetNumberOfArmorAppearances(ITEM_APPR_ARMOR_MODEL_TORSO);
    int n=1;
    sAC = GetStringLeft(sAC, 1);
    while (n<=nMax) {
        // Verify validity of the ID and add to the list
        sLine = Get2DAString(s2DA, "ACBONUS", n);
        if (GetStringLeft(sLine, 1)==sAC) {
            sCache+= IntToString(n)+":";
        }
        n++;
    }
    // Store the list in a modulestring, once normal, once reversed, both with ID 0 added as first index for cycling
    SetLocalString(GetModule(), "ZEP_IDPreReadAC_"+GetStringLeft(sAC,1), sCache);
    SetLocalString(GetModule(), "ZEP_IDPreReadACR_"+GetStringLeft(sAC,1), ZEP_ListReverse(sCache));

    return sCache;
}

// - private -
// Prereads the 2da-file for nPart and puts all used ID's in a : seperated stringlist
string ZEP_PreReadArmorPartList(int nPart) {
    // pick the right 2da to read the parts from
    string s2DA = "parts_";
    switch (nPart) {
        case ITEM_APPR_ARMOR_MODEL_LBICEP:
        case ITEM_APPR_ARMOR_MODEL_RBICEP: s2DA+= "bicep"; break;
        case ITEM_APPR_ARMOR_MODEL_LFOOT:
        case ITEM_APPR_ARMOR_MODEL_RFOOT: s2DA+= "foot"; break;
        case ITEM_APPR_ARMOR_MODEL_LFOREARM:
        case ITEM_APPR_ARMOR_MODEL_RFOREARM: s2DA+= "forearm"; break;
        case ITEM_APPR_ARMOR_MODEL_LHAND:
        case ITEM_APPR_ARMOR_MODEL_RHAND: s2DA+= "hand"; break;
        case ITEM_APPR_ARMOR_MODEL_LSHIN:
        case ITEM_APPR_ARMOR_MODEL_RSHIN: s2DA+= "shin"; break;
        case ITEM_APPR_ARMOR_MODEL_LSHOULDER:
        case ITEM_APPR_ARMOR_MODEL_RSHOULDER: s2DA+= "shoulder"; break;
        case ITEM_APPR_ARMOR_MODEL_LTHIGH:
        case ITEM_APPR_ARMOR_MODEL_RTHIGH: s2DA+= "legs"; break;
        case ITEM_APPR_ARMOR_MODEL_NECK: s2DA+= "neck"; break;
        case ITEM_APPR_ARMOR_MODEL_BELT: s2DA+= "belt"; break;
        case ITEM_APPR_ARMOR_MODEL_PELVIS: s2DA+= "pelvis"; break;
        case ITEM_APPR_ARMOR_MODEL_ROBE: s2DA+= "robe"; break;
    }

    string sCache= ":";
    string sLine;
    // get the maxID used (not the amount of ID's !!!)
    //int nMax = StringToInt(Get2DAString("des_crft_aparts", "NumParts", nPart));
    //Note from Loki: Below line changed to make use of
    //backward compatibility function.  Was previously the
    //preceding line.
    int nMax = ZEP_GetNumberOfArmorAppearances(nPart);
    int n=1;
    while (n<=nMax) {
        // Verify validity of the ID and add to the list
        sLine = Get2DAString(s2DA, "ACBONUS", n);
        if (sLine!="") {
            sCache+= IntToString(n)+":";
        }
        n++;
    }
    // Store the list in a modulestring, once normal, once reversed, both with ID 0 added as first index for cycling
    SetLocalString(GetModule(), "ZEP_IDPreRead_"+IntToString(nPart), ":0"+sCache);
    SetLocalString(GetModule(), "ZEP_IDPreReadR_"+IntToString(nPart), ":0"+ZEP_ListReverse(sCache));
    return sCache;
}

// Remakes and equips the item oPC is working, having the currently set part
// cycled either forward or backward
// nMode: ZEP_CR_PART_NEXT - cycle forward
// nMode: ZEP_CR_PART_PREV - cycle backward
void ZEP_RemakeItem(object oPC, int nMode) {
    SetLocalInt(oPC, "ZEP_CR_CHANGED", TRUE);
    object oItem = GetLocalObject(oPC, "ZEP_CR_ITEM");
    int nPart    = GetLocalInt(oPC, "ZEP_CR_PART");
    int nCurrApp, nSlot, nCost, nDC;
    string sPreRead;
    object oNew;

    if (GetBaseItemType(oItem)==BASE_ITEM_ARMOR) {
        // Handle Armor change
        nCurrApp = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nPart);

        if (nPart == ITEM_APPR_ARMOR_MODEL_TORSO) {
            string sAC = Get2DAString("parts_chest", "ACBONUS", nCurrApp);
            // Fetch the stringlist that holds the ID's for this part
            sPreRead = GetLocalString(GetModule(), "ZEP_IDPreReadAC_"+GetStringLeft(sAC,1));
            if (sPreRead=="") // list didn't exist yet, so generate it
                sPreRead = ZEP_PreReadArmorACList(sAC);
            if (nMode==ZEP_CR_PART_PREV)
                sPreRead = GetLocalString(GetModule(), "ZEP_IDPreReadACR_"+GetStringLeft(sAC,1));
        } else {
            // Fetch the stringlist that holds the ID's for this part
            sPreRead = GetLocalString(GetModule(), "ZEP_IDPreRead_"+IntToString(nPart));
            if (sPreRead=="") // list didn't exist yet, so generate it
                sPreRead = ZEP_PreReadArmorPartList(nPart);
            if (nMode==ZEP_CR_PART_PREV) sPreRead = GetLocalString(GetModule(), "ZEP_IDPreReadR_"+IntToString(nPart));
        }

        // Find the current ID in the stringlist and pick the one coming after that
        string sID;
        string sCurrApp = IntToString(nCurrApp);
        int n = FindSubString(sPreRead, ":"+sCurrApp+":");
        sID = GetSubString(sPreRead, n+GetStringLength(sCurrApp)+2, 5);
        n = FindSubString(sID, ":");
        sID = GetStringLeft(sID, n);
        if (sID=="" && nPart == ITEM_APPR_ARMOR_MODEL_TORSO) {
            sID = GetSubString(sPreRead, 1, 5);
            n = FindSubString(sID, ":");
            sID = GetStringLeft(sID, n);
        }
        nCurrApp = StringToInt(sID);

        oNew = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nPart, nCurrApp, TRUE);
        nSlot = INVENTORY_SLOT_CHEST;

    } else if (nPart == ZEP_CR_HELMET) {
        // Handle Helmet change
        nCurrApp = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, 0);
        int nMin = 1;
        int nMax = StringToInt(Get2DAString("baseitems", "MaxRange", BASE_ITEM_HELMET));

        //Note from Loki: Below code added in Do/while loop to
        //allow for scaling of helmets within reason without
        //needing to constantly reset the baseitems.2da file
        //parameters
        do {
            if (nMode == ZEP_CR_PART_NEXT) {
                if (++nCurrApp>nMax) nCurrApp = nMin;
            } else {
                if (--nCurrApp<nMin) nCurrApp = nMax;
            }

            oNew = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, 0, nCurrApp, TRUE);
            } while (!GetIsObjectValid(oNew));
            nSlot = INVENTORY_SLOT_HEAD;

    } else if (nPart == ZEP_CR_SHIELD) {
        // Handle Shield change
        nCurrApp = GetItemAppearance(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0);
        int nBaseType = GetBaseItemType(oItem);
        int nMin = StringToInt(Get2DAString("baseitems", "MinRange", nBaseType));
        int nMax = StringToInt(Get2DAString("baseitems", "MaxRange", nBaseType));

        //Note from Loki: This code i nthe Do/While may look a
        //bit odd.  This is because it does not follow the
        //standard method in the rest of this code for
        //changing appearance with one variable and color with
        //another.  Since shields do not have colors per se,
        //and CEP shields are not all numbered as the Bioware
        //shields are (only using appearanes **1-**3, always
        //contiguous in their appearance indexes), treating
        //them as if they did seemed to be inefficient.  Hence,
        //the loop updates it's counter a single index at a time
        //and searches for the next valid model.  This allows
        //for shields with one's digits of over 3, as well as
        //those starting at odd places (not having a **1
        //appearance, for example).

        do {
              if (nMode == ZEP_CR_PART_NEXT)
                  {
                  if (++nCurrApp > nMax) nCurrApp=nMin;
                  }
              else
                  {
                  if (--nCurrApp < nMin) nCurrApp=nMax;
                  }
            oNew = CopyItemAndModify(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, nCurrApp, TRUE);
            } while (!GetIsObjectValid(oNew));

            nSlot = INVENTORY_SLOT_LEFTHAND;

    } else {
        // Handle Weapon change
        nCurrApp = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, nPart);
        int nBaseType = GetBaseItemType(oItem);
        int nMin = StringToInt(Get2DAString("baseitems", "MinRange", nBaseType)) /10;
        int nMax = StringToInt(Get2DAString("baseitems", "MaxRange", nBaseType)) /10;


        //Once again, Do/While loop added to accomodate the fact that
        //CEP models are not all contiguous with each other.  This
        //allows the code to rapidly skip over gaps in the weapon
        //models to the next valid index.

        do {
            if (nMode == ZEP_CR_PART_NEXT) {
                if (++nCurrApp>nMax) nCurrApp = nMin;
            } else {
                if (--nCurrApp<nMin) nCurrApp = nMax;
            }
            oNew = CopyItemAndModify(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, nPart, nCurrApp, TRUE);
            } while (!GetIsObjectValid(oNew));

        nSlot = INVENTORY_SLOT_RIGHTHAND;
    }

    if (GetIsObjectValid(oNew)) {
        // new object is valid
        // get cost and DC
        int nNPC = GetIsObjectValid(GetLocalObject(oPC, "ZEP_CR_NPC"));
        object oBackup = GetLocalObject(oPC, "ZEP_CR_BACKUP");
        nCost = ZEP_GetModificationCost(oBackup, oNew, nNPC);
        nDC   = ZEP_GetModificationDC(oBackup, oNew, nNPC);
        SetLocalInt(oPC, "ZEP_CR_COST", nCost);
        SetLocalInt(oPC, "ZEP_CR_DC", nDC);
        SetCustomToken(ZEP_CR_TOKENBASE+1, IntToString(nCost));
        SetCustomToken(ZEP_CR_TOKENBASE+2, IntToString(nDC));

        // replace old current object with new one
        DestroyObject(oItem);
//        DestroyObject(oBackup);
        //oItem = oNew;
        SetLocalObject(oPC, "ZEP_CR_ITEM", oNew);
        AssignCommand(oPC, ClearAllActions(TRUE));
        AssignCommand(oPC, ActionEquipItem(oNew, nSlot));
    }
}

//Note from Loki: Below function is currently not used,
//except on weapons, as we have not yet fully converted
//SartriX's implementation of preview-able dye-ing of
//armor and weapons into something compatible with
//Bioware's existing system.  This function
//subject to heavy change and gutting in future releases.
//[FUTURE FIX]

// Remakes and equips the item oPC is working, having the currently set color
// cycled either forward or backward
// nMode: ZEP_CR_COLOR_NEXT - cycle forward
// nMode: ZEP_CR_COLOR_PREV - cycle backward
void ZEP_RecolorItem(object oPC, int nMode) {
    SetLocalInt(oPC, "ZEP_CR_CHANGED", TRUE);
    object oItem = GetLocalObject(oPC, "ZEP_CR_ITEM");
    int nPart    = GetLocalInt(oPC, "ZEP_CR_PART");
    int nCurrApp, nSlot, nCost, nDC;
    object oNew;


    if (GetBaseItemType(oItem)==BASE_ITEM_ARMOR || GetBaseItemType(oItem)==BASE_ITEM_HELMET) {
        // Handle Armor change
        nCurrApp = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nPart);
        int nMin = 0;
        int nMax = 63;         //64 colors in NWN Palette-Loki

        if (nMode == ZEP_CR_COLOR_NEXT) {
            if (++nCurrApp>nMax) nCurrApp = nMin;
        } else {
            if (--nCurrApp<nMin) nCurrApp = nMax;
        }

        ZEP_SetColorToken(nPart, nCurrApp);
        oNew  = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nPart, nCurrApp, TRUE);
        nSlot = INVENTORY_SLOT_CHEST;
        if (GetBaseItemType(oItem)==BASE_ITEM_HELMET)
            nSlot = INVENTORY_SLOT_HEAD;

    } else if (nPart == ZEP_CR_SHIELD) {
        // Handle Weapon change
        nCurrApp = GetItemAppearance(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0);
        int nMod = (nCurrApp/10)*10;
        nCurrApp-= nMod;
        int nMin = 1;
        int nMax = 9; //Shield models final digit can range from 1-9 (techniclly 0 is included, but there are no index 0 models)

        do {
            if (nMode == ZEP_CR_COLOR_NEXT) {
                if (++nCurrApp>nMax) nCurrApp = nMin;
            } else {
                if (--nCurrApp<nMin) nCurrApp = nMax;
            }
            nCurrApp += nMod;
//
            oNew = CopyItemAndModify(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, nCurrApp, TRUE);
            } while (!GetIsObjectValid(oNew));
        nSlot = INVENTORY_SLOT_LEFTHAND;

    } else {
        // Handle Weapon change- Addition of Do/While and indexes over 4 not tested yet [FUTURE FIX]
        nCurrApp = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, nPart);
        int nMin = 1;
        int nMax = 3;   //Only 3 colors supported in R1 of CEP, until we get 4th colors for all weapons.

//        do {
            if (nMode == ZEP_CR_COLOR_NEXT)
                {
                if (++nCurrApp>nMax) nCurrApp = nMin;
                }
            else {
                 if (--nCurrApp<nMin) nCurrApp = nMax;
                 }

            oNew = CopyItemAndModify(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, nPart, nCurrApp, TRUE);
  //          } while (!GetIsObjectValid(oNew));

        nSlot = INVENTORY_SLOT_RIGHTHAND;
    }

    if (GetIsObjectValid(oNew)) {
        // new object is valid
        // get cost and DC
        int nNPC = GetIsObjectValid(GetLocalObject(oPC, "ZEP_CR_NPC"));
        object oBackup = GetLocalObject(oPC, "ZEP_CR_BACKUP");
        nCost = ZEP_GetModificationCost(oBackup, oNew, nNPC);
        nDC   = ZEP_GetModificationDC(oBackup, oNew, nNPC);
        SetLocalInt(oPC, "ZEP_CR_COST", nCost);
        SetLocalInt(oPC, "ZEP_CR_DC", nDC);
        SetCustomToken(ZEP_CR_TOKENBASE+1, IntToString(nCost));
        SetCustomToken(ZEP_CR_TOKENBASE+2, IntToString(nDC));

        // replace old current object with new one
        DestroyObject(oItem);
        oItem = oNew;
        SetLocalObject(oPC, "ZEP_CR_ITEM", oItem);
        AssignCommand(oPC, ClearAllActions(TRUE));
        AssignCommand(oPC, ActionEquipItem(oItem, nSlot));
    }
}

int ZEP_GetIsWeapon(object oWeapon) {
    int iType = GetBaseItemType(oWeapon);
    switch (iType) {
        case BASE_ITEM_BASTARDSWORD:
        case BASE_ITEM_BATTLEAXE:
        case BASE_ITEM_DAGGER:
        case BASE_ITEM_DIREMACE:
        case BASE_ITEM_DOUBLEAXE:
        case BASE_ITEM_DWARVENWARAXE:
        case BASE_ITEM_GREATAXE:
        case BASE_ITEM_GREATSWORD:
        case BASE_ITEM_HALBERD:
        case BASE_ITEM_HANDAXE:
        case BASE_ITEM_HEAVYFLAIL:
        case BASE_ITEM_KAMA:
        case BASE_ITEM_KATANA:
        case BASE_ITEM_KUKRI:
        case BASE_ITEM_LIGHTFLAIL:
        case BASE_ITEM_LIGHTHAMMER:
        case BASE_ITEM_LIGHTMACE:
        case BASE_ITEM_LONGSWORD:
        case BASE_ITEM_MORNINGSTAR:
        case BASE_ITEM_RAPIER:
        case BASE_ITEM_SCIMITAR:
        case BASE_ITEM_SCYTHE:
        case BASE_ITEM_SHORTSPEAR:
        case BASE_ITEM_SHORTSWORD:
        case BASE_ITEM_SICKLE:
        case BASE_ITEM_THROWINGAXE:
        case BASE_ITEM_TWOBLADEDSWORD:
        case BASE_ITEM_WARHAMMER:
        case BASE_ITEM_CLUB:
        case BASE_ITEM_HEAVYCROSSBOW:
        case BASE_ITEM_LIGHTCROSSBOW:
        case BASE_ITEM_LONGBOW:
        case BASE_ITEM_MAGICSTAFF:
        case BASE_ITEM_QUARTERSTAFF:
        case BASE_ITEM_SHORTBOW:
        case BASE_ITEM_SLING:
        case BASE_ITEM_WHIP:
//Note from Loki: Following cases are custom CEP weapon types
        case BASE_ITEM_TRIDENT:
        case BASE_ITEM_HEAVYPICK:
        case BASE_ITEM_LIGHTPICK:
        case BASE_ITEM_SAI:
        case BASE_ITEM_NUNCHAKU:
        case BASE_ITEM_FALCHION1:
        case BASE_ITEM_SAP:
        case BASE_ITEM_DAGGERASSASSIN:
        case BASE_ITEM_KATAR:
        case BASE_ITEM_LIGHTMACE2:
        case BASE_ITEM_KUKRI2:
        case BASE_ITEM_FALCHION2:
        case BASE_ITEM_HEAVYMACE:
        case BASE_ITEM_MAUL:
        case BASE_ITEM_MERCURIALLONGSWORD:
        case BASE_ITEM_MERCURIALGREATSWORD:
        case BASE_ITEM_DOUBLESCIMITAR:
        case BASE_ITEM_GOAD:
        case BASE_ITEM_WINDFIREWHEEL: return TRUE;
    }

    return FALSE;
}

int ZEP_GetIsShield(object oShield) {
    int iType = GetBaseItemType(oShield);
    if (iType==BASE_ITEM_SMALLSHIELD || iType==BASE_ITEM_LARGESHIELD || iType==BASE_ITEM_TOWERSHIELD)
        return TRUE;
    return FALSE;
}

//Below script by Loki...basically just a copy of Bioware's
//script for X2 to get the local crafting work container, if
//it exists, and if not, to create it and render it invisble
//and unselectable.
object ZEP_GetZEPWorkContainer(object oCaller)
{
//First try to get the container.
object oContainer = GetObjectByTag(ZEP_CR_BACKUP_PLACEABLE);
//If it's not valid, we make one.
if (!GetIsObjectValid(oContainer))
    {
        oContainer = CreateObject(OBJECT_TYPE_PLACEABLE,ZEP_CR_BACKUP_PLACEABLE,GetLocation(oCaller));
 //       SetLocalInt(oContainer,"DYNAMICALLY_CREATED",1);
        effect eCutsceneInvis =  EffectVisualEffect( VFX_DUR_CUTSCENE_INVISIBILITY);
        eCutsceneInvis = ExtraordinaryEffect(eCutsceneInvis);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT,eCutsceneInvis,oContainer);

    }
    return oContainer;
}

//Below function by Loki
//Below function used as a substitution for the
//IPGetNumberOfArmorAppearances function in the CEP code.
//This is done because the max NumParts is coded as a
//constant to ensure compatibility with "vanilla' NWN.
int ZEP_GetNumberOfArmorAppearances(int nPart)
{
int nReturn;
switch (nPart)
    {
    case ITEM_APPR_ARMOR_MODEL_RFOOT:
    case ITEM_APPR_ARMOR_MODEL_LFOOT: nReturn=ZEP_MAX_PARTS_FOOT;
    case ITEM_APPR_ARMOR_MODEL_RSHIN:
    case ITEM_APPR_ARMOR_MODEL_LSHIN: nReturn=ZEP_MAX_PARTS_SHIN;
    case ITEM_APPR_ARMOR_MODEL_LTHIGH:
    case ITEM_APPR_ARMOR_MODEL_RTHIGH: nReturn=ZEP_MAX_PARTS_THIGH;
    case ITEM_APPR_ARMOR_MODEL_PELVIS: nReturn=ZEP_MAX_PARTS_PELVIS;
    case ITEM_APPR_ARMOR_MODEL_TORSO: nReturn=ZEP_MAX_PARTS_TORSO;
    case ITEM_APPR_ARMOR_MODEL_BELT: nReturn=ZEP_MAX_PARTS_BELT;
    case ITEM_APPR_ARMOR_MODEL_NECK: nReturn=ZEP_MAX_PARTS_NECK;
    case ITEM_APPR_ARMOR_MODEL_RFOREARM:
    case ITEM_APPR_ARMOR_MODEL_LFOREARM: nReturn=ZEP_MAX_PARTS_FOREARM;
    case ITEM_APPR_ARMOR_MODEL_RBICEP:
    case ITEM_APPR_ARMOR_MODEL_LBICEP: nReturn=ZEP_MAX_PARTS_BICEP;
    case ITEM_APPR_ARMOR_MODEL_RSHOULDER:
    case ITEM_APPR_ARMOR_MODEL_LSHOULDER: nReturn=ZEP_MAX_PARTS_SHOULDER;
    case ITEM_APPR_ARMOR_MODEL_RHAND:
    case ITEM_APPR_ARMOR_MODEL_LHAND: nReturn=ZEP_MAX_PARTS_HAND;
    case ITEM_APPR_ARMOR_MODEL_ROBE: nReturn=ZEP_MAX_PARTS_ROBE;
    }
return nReturn;
}

//:: void main (){}