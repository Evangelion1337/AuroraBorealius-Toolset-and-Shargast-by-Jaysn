// requires
#include "mk_inc_generic"
#include "x2_inc_craft"
#include "mk_inc_tools"
#include "mk_inc_editor"
#include "prc_inc_racial"

const int MK_IP_ITEMTYPE_NEXT = 0;
const int MK_IP_ITEMTYPE_PREV = 1;
const int MK_IP_ITEMTYPE_OPPOSITE = 2;
const int MK_IP_ITEMCOLOR_NEXT = 3;
const int MK_IP_ITEMCOLOR_PREV = 4;

/* Defined in x2_inc_craft
const int X2_CI_MODMODE_INVALID = 0;
const int X2_CI_MODMODE_ARMOR = 1;
const int X2_CI_MODMODE_WEAPON = 2;
*/
const int MK_CI_MODMODE_CLOAK = 3;
const int MK_CI_MODMODE_HELMET = 4;
const int MK_CI_MODMODE_SHIELD = 5;
const int MK_CI_MODMODE_BODY = 127;      // modify body (used only for proper
                                         // abort dialog)
const int MK_CI_MODMODE_CHARACTER = 255; // character description

const int MK_TOKEN_PARTSTRING = 14422;
const int MK_TOKEN_PARTNUMBER = 14423;
const int MK_TOKEN_OPP_PART   = 14430;

const int MK_TOKEN_COLOR1 = 14424;
const int MK_TOKEN_COLOR2 = 14425;
const int MK_TOKEN_COLOR3 = 14426;
const int MK_TOKEN_COLOR4 = 14427;
const int MK_TOKEN_COLOR5 = 14428;
const int MK_TOKEN_COLOR6 = 14429;

const int MK_TOKEN_COPYFROM = 14431;
const int MK_TOKEN_DYEFROM = 14432;
const int MK_TOKEN_SOURCEITEM = 14433;
const int MK_TOKEN_MATERIAL = 14434;

const int MK_TOKEN_COLOR_CLOSE = 14435;
const int MK_TOKEN_COLOR_COLOR1 = 14436;
const int MK_TOKEN_COLOR_COLOR2 = 14437;
const int MK_TOKEN_COLOR_COLOR3 = 14438;
const int MK_TOKEN_COLOR_COLOR4 = 14439;
const int MK_TOKEN_COLOR_COLOR5 = 14480;

const int MK_STATE_INVALID = 0;
const int MK_STATE_COPY = 1;
const int MK_STATE_MATERIAL = 2;
const int MK_STATE_CGROUP = 3;
const int MK_STATE_COLOR = 4;

const int MK_TOKEN_ITEMLIST = 14440;

// Token 14440-14461 for up to 22 color groups (176/8 = 22)
const int MK_TOKEN_COLORGROUP = 14440;

// Token 14462-14477 for up to 16 color names
const int MK_TOKEN_COLORNAME = 14462;

const int MK_TOKEN_NEWNAME = 14478;
const int MK_TOKEN_ORIGINALNAME = 14479;

// int MK_NUMBER_OF_COLOR_GROUPS = 22;

const string MK_VAR_CHARACTER_DESCRIPTION = "MK_CHARACTER_DESCRIPTION";

// Colors per group
// int MK_NUMBER_OF_COLORS_PER_GROUP = (176 / MK_NUMBER_OF_COLOR_GROUPS);

// ----------------------------------------------------------------------------
// Reads a string from a 2DA file, if it does not exist it reads from DefaultColumn
// ----------------------------------------------------------------------------
string MK_Get2DAStringEx(string s2DA, string sColumn, int nRow, string sDefaultColumn="");

// ----------------------------------------------------------------------------
// Returns the color name for cloth/leather color iColor
// - iColor (0..63)
// Taken from Mandragon's Dye Kit
// ----------------------------------------------------------------------------
string MK_ClothColor(int iColor);

// ----------------------------------------------------------------------------
// Returns the color name (if iColor between 0 and 63) for cloth/leather color
// iColor plus the color number in brackets
// Example 'Light Blue (24)'
// - iColor (0..176)
// ----------------------------------------------------------------------------
string MK_ClothColorEx(int iColor, int bDisplayNumber = TRUE);

// ----------------------------------------------------------------------------
// Returns the color name for metal color iColor
// - iColor (0..63)
// Taken from Mandragon's Dye Kit
// ----------------------------------------------------------------------------
string MK_MetalColor(int iColor);

// ----------------------------------------------------------------------------
// Returns the color name (if iColor between 0 and 63) for metal color
// iColor plus the color number in brackets
// Example 'Lightest Gold (8)'
// - iColor (0..176)
// ----------------------------------------------------------------------------
string MK_MetalColorEx(int iColor, int bDisplayNumber = TRUE);

// ----------------------------------------------------------------------------
// Uses 'CIGetCurrentModItem' to get the current item to be dyed.
// Then the script changes the color of layer iMaterialToDye to iColor.
// Finally the item is equipped again.
// ----------------------------------------------------------------------------
void MK_DyeItem(object oPC, int iMaterialToDye, int iColor);

// ----------------------------------------------------------------------------
// Prints the colors of oItem.
// ----------------------------------------------------------------------------
void MK_DisplayColors(object oPC, object oItem);

// ----------------------------------------------------------------------------
// Gets the new armor appearance type of oArmor
// - nPart
//      ITEM_APPR_ARMOR_MODEL_*
//   nMode
//      X2_IP_ARMORTYPE_PREV
//      X2_IP_ARMORTYPE_NEXT
// ----------------------------------------------------------------------------
int MK_GetArmorAppearanceType(object oArmor, int nPart, int nMode);

// ----------------------------------------------------------------------------
// Returns the new armor with nPart modified
// - nPart
//      ITEM_APPR_ARMOR_MODEL_*
//   nMode
//      X2_IP_ARMORTYPE_PREV
//      X2_IP_ARMORTYPE_NEXT
// ----------------------------------------------------------------------------
object MK_GetModifiedArmor(object oArmor, int nPart, int nMode, int bDestroyOldOnSuccess);


// ----------------------------------------------------------------------------
// Returns the new weapon with nPart modified
// - nPart
//      ITEM_APPR_WEAPON_MODEL_*
//      ITEM_APPR_WEAPON_COLOR_*
//   nMode
//      MK_IP_ITEMTYPE_NEXT
//      MK_IP_ITEMTYPE_PREV
//      MK_IP_ITEMCOLOR_NEXT
//      MK_IP_ITEMCOLOR_PREV
// ----------------------------------------------------------------------------
object MK_GetModifiedWeapon(object oWeapon, int nPart, int nMode, int bDestroyOldOnSuccess);

// ----------------------------------------------------------------------------
// Returns the inventory slot of the current item
// ----------------------------------------------------------------------------
int MK_GetCurrentInventorySlot(object oPC);

// ----------------------------------------------------------------------------
// Gets the new cloak appearance type of oCloak
// - nMode
//      MK_IP_CLOAKTYPE_PREV
//      MK_IP_CLOAKTYPE_NEXT
// ----------------------------------------------------------------------------
int MK_GetCloakAppearanceType(object oCloak, int nPart, int nMode);

// ----------------------------------------------------------------------------
// Returns a new cloak based of oCloak with the model modified
// nMode -
//          MK_IP_CLOAKTYPE_NEXT    - next valid appearance
//          MK_IP_CLOAKTYPE_PREV    - previous valid apperance;
// bDestroyOldOnSuccess - Destroy oArmor in process?
// ----------------------------------------------------------------------------
object MK_GetModifiedCloak(object oCloak, int nPart, int nMode, int bDestroyOldOnSuccess);

// ----------------------------------------------------------------------------
// Returns a new helm based of oHelmet with the model modified
// nMode -
//          MK_IP_HELMTYPE_NEXT    - next valid appearance
//          MK_IP_HELMTYPE_PREV    - previous valid apperance;
// bDestroyOldOnSuccess - Destroy oArmor in process?
// ----------------------------------------------------------------------------
object MK_GetModifiedHelmet(object oHelmet, int nMode, int bDestroyOldOnSuccess);

// ----------------------------------------------------------------------------
// Copies the appearance of item oSource to item oDest
//
// iType                            iIndex
// ITEM_APPR_TYPE_SIMPLE_MODEL      [Ignored]
// ITEM_APPR_TYPE_WEAPON_COLOR      ITEM_APPR_WEAPON_COLOR_*
// ITEM_APPR_TYPE_WEAPON_MODEL      ITEM_APPR_WEAPON_MODEL_*
// ITEM_APPR_TYPE_ARMOR_MODEL       ITEM_APPR_ARMOR_MODEL_*
// ITEM_APPR_TYPE_ARMOR_COLOR       ITEM_APPR_ARMOR_COLOR_*
//
// Script (idea) taken from a script posted by John Bye
// ----------------------------------------------------------------------------
object MK_MatchItem(object oDest, object oSource, int nType, int nIndex);


// ----------------------------------------------------------------------------
// Script (idea) taken from a script posted by John Bye
// ----------------------------------------------------------------------------
object MK_ModifyCloakModel(object oPC, object oItem, int nNewValue);

// ----------------------------------------------------------------------------
// returns TRUE if the item is modified
// ----------------------------------------------------------------------------
int MK_GetIsModified(object oItem, object oBackup);

// ----------------------------------------------------------------------------
// returns TRUE if the item is a weapon and if it can be modified
// Slings and whips are 1 part items and can't be modified.
// ----------------------------------------------------------------------------
int MK_GetIsModifiableWeapon(object oItem);

// ----------------------------------------------------------------------------
// returns TRUE if the item is a shield
// ----------------------------------------------------------------------------
int MK_GetIsShield(object oItem);

// ----------------------------------------------------------------------------
// returns TRUE if it is allowed to modify the item
// ----------------------------------------------------------------------------
int MK_GetIsAllowedToModifyItem(object oPC, object oItem);

// ----------------------------------------------------------------------------
// initializes the RenameItem dialog
// ----------------------------------------------------------------------------
void MK_InitializeRenameItem(object oPC, object oItem);

// ----------------------------------------------------------------------------
// initializes the EditDescription dialog
// ----------------------------------------------------------------------------
void MK_InitializeEditDescription(object oPC, object oObject);

// ----------------------------------------------------------------------------
// prepares the editor
// ----------------------------------------------------------------------------
void MK_PrepareEditor(object oPC, int nEditorID, string sHeadLine="",
    int nMaxLength=-1, int bSingleLine=FALSE, int bDisableColors=FALSE,
    int bUseChatEvent=FALSE);

// ----------------------------------------------------------------------------
// sets custom token MK_TOKEN_COPYFROM to the current item type name
// (armor, weapon, cloak, helmet or shield)
// used in the crafting dialog
// ----------------------------------------------------------------------------
void MK_SetCustomTokenByItemTypeName(object oPC);


// ----------------------------------------------------------------------------
// special version of CopyItem that also copies a modified description
// ----------------------------------------------------------------------------
object MK_CopyItem(object oItem, object oTargetInventory=OBJECT_INVALID, int bCopyVars=FALSE);

// ----------------------------------------------------------------------------
// special version of CopyItemAndModify that also copies a modified description
// ----------------------------------------------------------------------------
object MK_CopyItemAndModify(object oItem, int nType, int nIndex, int nNewValue, int bCopyVars=FALSE);


object MK_CopyItem(object oItem, object oTargetInventory, int bCopyVars)
{
    object oCopy = CopyItem(oItem, oTargetInventory, bCopyVars);

    string sDescription = GetDescription(oItem);
    if (GetDescription(oCopy)!=sDescription)
    {
        SetDescription(oCopy, sDescription);
    }

    return oCopy;
}

object MK_CopyItemAndModify(object oItem, int nType, int nIndex, int nNewValue, int bCopyVars)
{
    object oCopy = CopyItemAndModify(oItem, nType, nIndex, nNewValue, bCopyVars);

    string sDescription = GetDescription(oItem);
    if (GetDescription(oCopy)!=sDescription)
    {
        SetDescription(oCopy, sDescription);
    }

    return oCopy;
}

void MK_SetCustomTokenByItemTypeName(object oPC)
{
    int nModMode = CIGetCurrentModMode(oPC);
    string sToken="";

    switch (nModMode)
    {
    case MK_CI_MODMODE_CHARACTER:
        sToken = "character";
        break;
    case X2_CI_MODMODE_ARMOR:
        sToken = "armor";
        break;
    case X2_CI_MODMODE_WEAPON:
        sToken = "weapon";
        break;
    case MK_CI_MODMODE_CLOAK:
        sToken = "cloak";
        break;
    case MK_CI_MODMODE_HELMET:
        sToken = "helmet";
        break;
    case MK_CI_MODMODE_SHIELD:
        sToken = "shield";
        break;
    }
    SetCustomToken(MK_TOKEN_COPYFROM, sToken);
}

int MK_GetIsAllowedToModifyItem(object oPC, object oItem)
{
    if (!GetIsObjectValid(oPC))
    {
        return FALSE;
    }
    if (!GetIsObjectValid(oItem))
    {
        return FALSE;
    }
    if (GetLocalInt(GetModule(),"X2_L_DO_NOT_ALLOW_MODIFY_ARMOR"))
    {
        return FALSE;
    }
    if (GetPlotFlag(oItem) && (GetLocalInt(oPC,"MK_ENABLE_MODIFY_PLOT_ITEMS")==0))
    {
        return FALSE;
    }
    return TRUE;
}

int MK_GetIsSameArmorAppearance(object oItem, object oBackup)
{
    int bIsSameApp=TRUE;
    int iPart;
    for (iPart=0; (bIsSameApp)&&(iPart<ITEM_APPR_ARMOR_NUM_MODELS); iPart++)
    {
        bIsSameApp =
            (GetItemAppearance(oItem,ITEM_APPR_TYPE_ARMOR_MODEL,iPart) ==
                GetItemAppearance(oBackup,ITEM_APPR_TYPE_ARMOR_MODEL,iPart));
    }
    return bIsSameApp;
}

int MK_GetIsSameWeaponAppearance(object oItem, object oBackup)
{
    int bIsSameApp=TRUE;
    int iPart;
    for (iPart=ITEM_APPR_WEAPON_MODEL_BOTTOM; (bIsSameApp) && (iPart<=ITEM_APPR_WEAPON_MODEL_TOP); iPart++)
    {
        bIsSameApp =
            (GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, iPart) ==
                GetItemAppearance(oBackup, ITEM_APPR_TYPE_WEAPON_MODEL, iPart));
    }
    for (iPart=ITEM_APPR_WEAPON_COLOR_BOTTOM; (bIsSameApp) && (iPart<=ITEM_APPR_WEAPON_COLOR_TOP); iPart++)
    {
        bIsSameApp =
            (GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, iPart) ==
                GetItemAppearance(oBackup, ITEM_APPR_TYPE_WEAPON_COLOR, iPart));
    }
    return bIsSameApp;
}

int MK_GetIsSameSimpleAppearance(object oItem, object oBackup)
{
    int bIsSameAppearance =
        (GetItemAppearance(oItem,ITEM_APPR_TYPE_SIMPLE_MODEL,0) ==
            GetItemAppearance(oBackup,ITEM_APPR_TYPE_SIMPLE_MODEL,0));
    return bIsSameAppearance;
}

int MK_GetIsSameColor(object oItem, object oBackup)
{
    int bIsSameColor=TRUE;
    int iMaterial;
    for (iMaterial=0; (bIsSameColor)&&(iMaterial<ITEM_APPR_ARMOR_NUM_COLORS); iMaterial++)
    {
        bIsSameColor =
            (GetItemAppearance(oItem,ITEM_APPR_TYPE_ARMOR_COLOR,iMaterial) ==
                GetItemAppearance(oBackup,ITEM_APPR_TYPE_ARMOR_COLOR,iMaterial));
    }
    return bIsSameColor;
}

int MK_GetIsModified(object oItem, object oBackup)
{
    int bIsModified = FALSE;
    int nBaseType = GetBaseItemType(oItem);
    int i;
    switch (nBaseType)
    {
    case BASE_ITEM_ARMOR:
        bIsModified =
            !(MK_GetIsSameColor(oItem, oBackup) &&
                MK_GetIsSameArmorAppearance(oItem, oBackup));
        break;
    case BASE_ITEM_CLOAK:
    case BASE_ITEM_HELMET:
        bIsModified =
            !(MK_GetIsSameColor(oItem, oBackup) &&
                MK_GetIsSameSimpleAppearance(oItem, oBackup));
        break;
    case BASE_ITEM_SMALLSHIELD:
    case BASE_ITEM_LARGESHIELD:
    case BASE_ITEM_TOWERSHIELD:
        bIsModified = (!MK_GetIsSameSimpleAppearance(oItem, oBackup));
        break;
    default:
        bIsModified = (!MK_GetIsSameWeaponAppearance(oItem, oBackup));
        break;
    }

    if (!bIsModified)
    {
        bIsModified = (GetName(oItem)!=GetName(oBackup));
    }
    if (!bIsModified)
    {
        bIsModified = (GetDescription(oItem)!=GetDescription(oBackup));
    }
    return bIsModified;
}

/*
void MK_InitColorTokens()
{
    SetCustomToken(14435, "</c>"); // CLOSE tag
    SetCustomToken(14436, "<cþ¥ >"); // orange (highlight)
    SetCustomToken(14437, "<cþ þ>"); // magenta (back)
    SetCustomToken(14438, "<c ¿þ>"); // deepskyblue (model name/number)
    SetCustomToken(14439, "<cþþ >"); // yellow (make changes)
}
*/

int MK_GetCurrentInventorySlot(object oPC)
{
    int nInventorySlot=0;

    switch (CIGetCurrentModMode(oPC))
    {
    case X2_CI_MODMODE_ARMOR:
        nInventorySlot = INVENTORY_SLOT_CHEST;
        break;
    case X2_CI_MODMODE_WEAPON:
        nInventorySlot = INVENTORY_SLOT_RIGHTHAND;
        break;
    case MK_CI_MODMODE_CLOAK:
        nInventorySlot = INVENTORY_SLOT_CLOAK;
        break;
    case MK_CI_MODMODE_HELMET:
        nInventorySlot = INVENTORY_SLOT_HEAD;
        break;
    case MK_CI_MODMODE_SHIELD:
        nInventorySlot = INVENTORY_SLOT_LEFTHAND;
        break;
    default:
        nInventorySlot = -1;
    }
    return nInventorySlot;
}

// copied from 'string ZEP_ListReverse(string s)'
string MK_ListReverse(string s) {
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

int MK_GetOppositePart(int nPart)
{
    int nOppositePart=0;
    switch (nPart)
    {
    case ITEM_APPR_ARMOR_MODEL_LSHOULDER:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_RSHOULDER;
        break;
    case ITEM_APPR_ARMOR_MODEL_RSHOULDER:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_LSHOULDER;
        break;
    case ITEM_APPR_ARMOR_MODEL_LBICEP:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_RBICEP;
        break;
    case ITEM_APPR_ARMOR_MODEL_RBICEP:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_LBICEP;
        break;
    case ITEM_APPR_ARMOR_MODEL_LFOREARM:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_RFOREARM;
        break;
    case ITEM_APPR_ARMOR_MODEL_RFOREARM:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_LFOREARM;
        break;
    case ITEM_APPR_ARMOR_MODEL_LHAND:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_RHAND;
        break;
    case ITEM_APPR_ARMOR_MODEL_RHAND:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_LHAND;
        break;
    case ITEM_APPR_ARMOR_MODEL_LTHIGH:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_RTHIGH;
        break;
    case ITEM_APPR_ARMOR_MODEL_RTHIGH:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_LTHIGH;
        break;
    case ITEM_APPR_ARMOR_MODEL_LSHIN:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_RSHIN;
        break;
    case ITEM_APPR_ARMOR_MODEL_RSHIN:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_LSHIN;
        break;
    case ITEM_APPR_ARMOR_MODEL_LFOOT:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_RFOOT;
        break;
    case ITEM_APPR_ARMOR_MODEL_RFOOT:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_LFOOT;
        break;
    }
    return nOppositePart;
}

int MK_HasOppositePart(int nPart)
{
    int nStrRef=0;
    switch (nPart)
    {
    case ITEM_APPR_ARMOR_MODEL_LSHOULDER:
        nStrRef=7146;
        break;
    case ITEM_APPR_ARMOR_MODEL_RSHOULDER:
        nStrRef=7150;
        break;
    case ITEM_APPR_ARMOR_MODEL_LBICEP:
        nStrRef=7147;
        break;
    case ITEM_APPR_ARMOR_MODEL_RBICEP:
        nStrRef=7151;
        break;
    case ITEM_APPR_ARMOR_MODEL_LFOREARM:
        nStrRef=7148;
        break;
    case ITEM_APPR_ARMOR_MODEL_RFOREARM:
        nStrRef=7152;
        break;
    case ITEM_APPR_ARMOR_MODEL_LHAND:
        nStrRef=7149;
        break;
    case ITEM_APPR_ARMOR_MODEL_RHAND:
        nStrRef=7153;
        break;
    case ITEM_APPR_ARMOR_MODEL_LTHIGH:
        nStrRef=83351;
        break;
    case ITEM_APPR_ARMOR_MODEL_RTHIGH:
        nStrRef=83350;
        break;
    case ITEM_APPR_ARMOR_MODEL_LSHIN:
        nStrRef=83349;
        break;
    case ITEM_APPR_ARMOR_MODEL_RSHIN:
        nStrRef=83348;
        break;
    case ITEM_APPR_ARMOR_MODEL_LFOOT:
        nStrRef=83346;
        break;
    case ITEM_APPR_ARMOR_MODEL_RFOOT:
        nStrRef=83345;
        break;
    }

    int nResult = FALSE;
    string s = "";

    if (nStrRef>0)
    {
        s = GetStringByStrRef(nStrRef);
        nResult = TRUE;
    }
    SetCustomToken(MK_TOKEN_OPP_PART, s);

    return nResult;
}

//copied from 'string ZEP_PreReadArmorACList(string sAC)'
string MK_PreReadArmorACList(string sAC)
{
    // pick the right 2da to read the parts from
    string s2DA = "parts_chest";
    string sCache= ":";
    string sLine;

    int nMax = 255;
    int n=1;
    sAC = GetStringLeft(sAC, 1);
    while (n<=nMax) {
        // Verify validity of the ID and add to the list
        sLine = Get2DAString(s2DA, "ACBONUS", n);
        if (GetStringLeft(sLine, 1)==sAC)
        {
            sCache+= IntToString(n)+":";
        }
        n++;
    }
    // Store the list in a modulestring, once normal, once reversed, both with ID 0 added as first index for cycling
    SetLocalString(GetModule(), "MK_IDPreReadAC_"+GetStringLeft(sAC,1), sCache);
    SetLocalString(GetModule(), "MK_IDPreReadACR_"+GetStringLeft(sAC,1), MK_ListReverse(sCache));

    return sCache;
}

// copied from 'string ZEP_PreReadArmorPartList(int nPart)' and modified
string MK_GetParts2DAfile(int nPart)
{
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
    return s2DA;
}

// - private -
// Prereads the 2da-file for nPart and puts all used ID's in a : seperated stringlist
string MK_PreReadArmorPartList(int nPart) {
    // pick the right 2da to read the parts from
    string s2DA = MK_GetParts2DAfile(nPart);

    string sCache= ":";
    string sLine;
    int nMax = 255;
    int n=1;
    while (n<=nMax) {
        // Verify validity of the ID and add to the list
        sLine = Get2DAString(s2DA, "ACBONUS", n);
        if (sLine!="")
        {
            sCache+= IntToString(n)+":";
        }
        n++;
    }
    // Store the list in a modulestring, once normal, once reversed, both with ID 0 added as first index for cycling
    SetLocalString(GetModule(), "MK_IDPreRead_"+IntToString(nPart), ":0"+sCache);
    SetLocalString(GetModule(), "MK_IDPreReadR_"+IntToString(nPart), ":0"+MK_ListReverse(sCache));
    return sCache;
}

// copied from 'void ZEP_RemakeItem(object oPC, int nMode)' and modified
int MK_GetArmorAppearanceType(object oArmor, int nPart, int nMode)
{
    int nCurrApp  = GetItemAppearance(oArmor,ITEM_APPR_TYPE_ARMOR_MODEL,nPart);

    if (nMode == MK_IP_ITEMTYPE_OPPOSITE)
    {
        int nOppositePart = MK_GetOppositePart(nPart);
        if (nOppositePart!=0)
        {
            nCurrApp = GetItemAppearance(oArmor, ITEM_APPR_TYPE_ARMOR_MODEL, nOppositePart);
        }
    }
    else
    {
        string sPreRead;

        if (nPart == ITEM_APPR_ARMOR_MODEL_TORSO)
        {
            string sAC = Get2DAString("parts_chest", "ACBONUS", nCurrApp);
            // Fetch the stringlist that holds the ID's for this part
            sPreRead = GetLocalString(GetModule(), "MK_IDPreReadAC_"+GetStringLeft(sAC,1));
            if (sPreRead=="") // list didn't exist yet, so generate it
                sPreRead = MK_PreReadArmorACList(sAC);
            if (nMode==X2_IP_ARMORTYPE_PREV)
                sPreRead = GetLocalString(GetModule(), "MK_IDPreReadACR_"+GetStringLeft(sAC,1));
        }
        else
        {
            // Fetch the stringlist that holds the ID's for this part
            sPreRead = GetLocalString(GetModule(), "MK_IDPreRead_"+IntToString(nPart));
            if (sPreRead=="") // list didn't exist yet, so generate it
                sPreRead = MK_PreReadArmorPartList(nPart);
            if (nMode==X2_IP_ARMORTYPE_PREV)
                sPreRead = GetLocalString(GetModule(), "MK_IDPreReadR_"+IntToString(nPart));
        }

        // Find the current ID in the stringlist and pick the one coming after that
        string sID;
        string sCurrApp = IntToString(nCurrApp);
        int n = FindSubString(sPreRead, ":"+sCurrApp+":");
        sID = GetSubString(sPreRead, n+GetStringLength(sCurrApp)+2, 5);
        n = FindSubString(sID, ":");
        sID = GetStringLeft(sID, n);
        if (sID=="" && nPart == ITEM_APPR_ARMOR_MODEL_TORSO)
        {
           sID = GetSubString(sPreRead, 1, 5);
           n = FindSubString(sID, ":");
           sID = GetStringLeft(sID, n);
        }
        nCurrApp = StringToInt(sID);
    }

    return nCurrApp;
}


// ----------------------------------------------------------------------------
// Returns a new armor based of oArmor with nPartModified
// nPart - ITEM_APPR_ARMOR_MODEL_* constant of the part to be changed
// nMode -
//          X2_IP_ARMORTYPE_NEXT    - next valid appearance
//          X2_IP_ARMORTYPE_PREV    - previous valid apperance;
//          X2_IP_ARMORTYPE_RANDOM  - random valid appearance (torso is never changed);
// bDestroyOldOnSuccess - Destroy oArmor in process?
// Uses Get2DAstring, so do not use in loops
// ----------------------------------------------------------------------------
object MK_GetModifiedArmor(object oArmor, int nPart, int nMode, int bDestroyOldOnSuccess)
{
    int nNewApp = MK_GetArmorAppearanceType(oArmor, nPart,  nMode );
//    SpeakString("old: " + IntToString(GetItemAppearance(oArmor,ITEM_APPR_TYPE_ARMOR_MODEL,nPart)));
//    SpeakString("new: " + IntToString(nNewApp));

    object oNew = MK_CopyItemAndModify(oArmor,ITEM_APPR_TYPE_ARMOR_MODEL, nPart, nNewApp,TRUE);

    if (oNew != OBJECT_INVALID)
    {
        SetCustomToken(MK_TOKEN_PARTNUMBER, IntToString(nNewApp));
        if( bDestroyOldOnSuccess )
        {
            DestroyObject(oArmor);
        }
        return oNew;
    }

    // Safety fallback, return old armor on failures
    return oArmor;
}


// - private -
// Prereads the 2da-file for nPart and puts all used ID's in a : seperated stringlist
string MK_PreReadCloakModelList()
{
    // pick the right 2da to read the parts from
    string s2DA = "CloakModel";

    string sCache= ":";
    string sLine;
    int nMax = 255;
    int n=1;
    while (n<=nMax) {
        // Verify validity of the ID and add to the list
        sLine = Get2DAString(s2DA, "LABEL", n);
        if (sLine!="")
        {
            sCache+= IntToString(n)+":";
        }
        n++;
    }
    // Store the list in a modulestring, once normal, once reversed, both with ID 0 added as first index for cycling
    SetLocalString(GetModule(), "MK_IDPreRead_Cloak", ":0"+sCache);
    SetLocalString(GetModule(), "MK_IDPreReadR_Cloak", ":0"+MK_ListReverse(sCache));

//    SpeakString(GetLocalString(GetModule(),"MK_IDPreRead_Cloak"));
//    SpeakString(GetLocalString(GetModule(),"MK_IDPreReadR_Cloak"));

    return sCache;
}


int MK_GetCloakAppearanceType(object oCloak, int nPart, int nMode)
{
    int nCurrApp  = GetItemAppearance(oCloak, 0, nPart);

    string sPreRead;

    // Fetch the stringlist that holds the ID's for this part
    sPreRead = GetLocalString(GetModule(), "MK_IDPreRead_Cloak");
    if (sPreRead=="") // list didn't exist yet, so generate it
        sPreRead = MK_PreReadCloakModelList();
    if (nMode==MK_IP_ITEMTYPE_PREV)
        sPreRead = GetLocalString(GetModule(), "MK_IDPreReadR_Cloak");

    // Find the current ID in the stringlist and pick the one coming after that
    string sID;
    string sCurrApp = IntToString(nCurrApp);
    int n = FindSubString(sPreRead, ":"+sCurrApp+":");
    sID = GetSubString(sPreRead, n+GetStringLength(sCurrApp)+2, 5);
    n = FindSubString(sID, ":");
    sID = GetStringLeft(sID, n);
    nCurrApp = StringToInt(sID);

    return nCurrApp;
}

// ----------------------------------------------------------------------------
// Returns a new armor based of oArmor with nPartModified
// nPart - ITEM_APPR_ARMOR_MODEL_* constant of the part to be changed
// nMode -
//          MK_IP_CLOAKTYPE_NEXT    - next valid appearance
//          MK_IP_CLOAKTYPE_PREV    - previous valid apperance;
// bDestroyOldOnSuccess - Destroy oArmor in process?
// Uses Get2DAstring, so do not use in loops
// ----------------------------------------------------------------------------
object MK_GetModifiedCloak(object oCloak, int nPart, int nMode, int bDestroyOldOnSuccess)
{
    int nNewApp = MK_GetCloakAppearanceType(oCloak, nPart,  nMode );

    object oNew = MK_CopyItemAndModify(oCloak, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, nNewApp, TRUE);
//    object oNew = MK_ModifyCloakModel(GetPCSpeaker(), oCloak, nNewApp);

    if (oNew != OBJECT_INVALID)
    {
        SetCustomToken(MK_TOKEN_PARTNUMBER, IntToString(nNewApp));
        if( bDestroyOldOnSuccess )
        {
            DestroyObject(oCloak);
        }
        return oNew;
    }
//        SpeakString("failed");

    // Safety fallback, return old armor on failures
    return oCloak;
}

object MK_GetModifiedHelmet(object oHelmet, int nMode, int bDestroyOldOnSuccess)
{
    int nMin = StringToInt(Get2DAString("baseitems", "MinRange", BASE_ITEM_HELMET));
    int nMax = StringToInt(Get2DAString("baseitems", "MaxRange", BASE_ITEM_HELMET));
    int nCurrApp = GetItemAppearance(oHelmet, ITEM_APPR_TYPE_ARMOR_MODEL, 0);

    object oNew;

    do
    {
        switch (nMode)
        {
        case MK_IP_ITEMTYPE_NEXT:
            if (++nCurrApp>nMax) nCurrApp = nMin;
            break;

        case MK_IP_ITEMTYPE_PREV:
            if (--nCurrApp<nMin) nCurrApp = nMax;
            break;
        }
        oNew = MK_CopyItemAndModify(oHelmet, ITEM_APPR_TYPE_ARMOR_MODEL, 0, nCurrApp, TRUE);
    }
    while (!GetIsObjectValid(oNew));

    SetCustomToken(MK_TOKEN_PARTNUMBER, IntToString(nCurrApp));

    if( bDestroyOldOnSuccess )
    {
        DestroyObject(oHelmet);
    }
    return oNew;
}


/*
int MK_GetShieldAppearanceType(object oShield, int nMode)
{
    int nCurrApp  = GetItemAppearance(oShield, ITEM_APPR_TYPE_SIMPLE_MODEL, 0);

    int nBaseItemType = GetBaseItemType(oShield);

    int nMinApp = StringToInt(Get2DAString("baseitems", "MinRange", nBaseItemType));
    int nMaxApp = StringToInt(Get2DAString("baseitems", "MaxRange", nBaseItemType));

    switch (nMode)
    {
    case MK_IP_ITEMTYPE_NEXT:
        if (++nCurrApp > nMaxApp) nCurrApp = nMinApp;
        break;
    case MK_IP_ITEMTYPE_PREV:
        if (--nCurrApp < nMinApp) nCurrApp = nMaxApp;
        break;
    }
    return nCurrApp;
}
*/

object MK_GetModifiedWeapon(object oWeapon, int nPart, int nMode, int bDestroyOldOnSuccess)
{
    int nBaseItemType = GetBaseItemType(oWeapon);
    int nMin, nMax, nCurrApp;
    int nType;
    switch (nMode)
    {
    case MK_IP_ITEMTYPE_NEXT:
    case MK_IP_ITEMTYPE_PREV:
        nMin = StringToInt(Get2DAString("baseitems", "MinRange", nBaseItemType))/10;
        nMax = StringToInt(Get2DAString("baseitems", "MaxRange", nBaseItemType))/10;
        nType = ITEM_APPR_TYPE_WEAPON_MODEL;
        break;
    case MK_IP_ITEMCOLOR_NEXT:
    case MK_IP_ITEMCOLOR_PREV:
        nMin = 1;
        nMax = 4;
        nType = ITEM_APPR_TYPE_WEAPON_COLOR;
        break;
    }
    nCurrApp = GetItemAppearance(oWeapon, nType, nPart);

    object oNew;

    do
    {
        switch (nMode)
        {
        case MK_IP_ITEMTYPE_NEXT:
        case MK_IP_ITEMCOLOR_NEXT:
            if (++nCurrApp>nMax) nCurrApp = nMin;
            break;

        case MK_IP_ITEMTYPE_PREV:
        case MK_IP_ITEMCOLOR_PREV:
            if (--nCurrApp<nMin) nCurrApp = nMax;
            break;
        }
        oNew = MK_CopyItemAndModify(oWeapon, nType, nPart, nCurrApp, TRUE);
    }
    while (!GetIsObjectValid(oNew));

    SetCustomToken(MK_TOKEN_PARTNUMBER,
        IntToString(GetItemAppearance(oWeapon, ITEM_APPR_TYPE_WEAPON_MODEL, nPart)*10+
                    GetItemAppearance(oWeapon, ITEM_APPR_TYPE_WEAPON_COLOR, nPart)));

    if( bDestroyOldOnSuccess )
    {
        DestroyObject(oWeapon);
    }
    return oNew;
}

object MK_GetModifiedShield(object oShield, int nMode, int bDestroyOldOnSuccess)
{
    int nBaseItemType = GetBaseItemType(oShield);
    int nMinApp = StringToInt(Get2DAString("baseitems", "MinRange", nBaseItemType));
    int nMaxApp = StringToInt(Get2DAString("baseitems", "MaxRange", nBaseItemType));

    int nCurrApp  = GetItemAppearance(oShield, ITEM_APPR_TYPE_SIMPLE_MODEL, 0);

    object oNew;

    do
    {
        switch (nMode)
        {
        case MK_IP_ITEMTYPE_NEXT:
            if (++nCurrApp > nMaxApp) nCurrApp = nMinApp;
            break;
        case MK_IP_ITEMTYPE_PREV:
            if (--nCurrApp < nMinApp) nCurrApp = nMaxApp;
            break;
        }
        oNew = MK_CopyItemAndModify(oShield, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, nCurrApp, TRUE);
    }
    while (!GetIsObjectValid(oNew));

    SetCustomToken(MK_TOKEN_PARTNUMBER, IntToString(nCurrApp));
    if( bDestroyOldOnSuccess )
    {
        DestroyObject(oShield);
    }
    return oNew;
}

object MK_GetDyedItem(object oArmor, int iMaterialToDye, int iColor, int bDestroyOldOnSuccess)
{
    object oNew = MK_CopyItemAndModify(oArmor, ITEM_APPR_TYPE_ARMOR_COLOR, iMaterialToDye, iColor, TRUE);

    if (oNew != OBJECT_INVALID)
    {
        if( bDestroyOldOnSuccess )
        {
            DestroyObject(oArmor);
        }
        return oNew;
    }

    // Safety fallback, return old armor on failures
    return oArmor;
}


object MK_MatchItem(object oDest, object oSource, int nType, int nIndex)
{
    int nValue = GetItemAppearance(oSource, nType, nIndex);
    object oNew = MK_CopyItemAndModify(oDest, nType, nIndex, nValue);
    DestroyObject(oDest);
    return oNew;
}

string MK_GetCloakModelResRef(int nModel)
{
    string sNr = "mk_clk_";
    if (nModel<100) sNr+="0";
    if (nModel<10) sNr+="0";
    sNr+=IntToString(nModel);
    return sNr;
}

object MK_CopyAppearance(object oDest, object oSource)
{
    if ((GetBaseItemType(oDest)!=BASE_ITEM_ARMOR) ||
        (GetBaseItemType(oSource)!=BASE_ITEM_ARMOR))
    {
        return oDest;
    }

    int bCopyTorso=FALSE;

    int nDestTorso = GetItemAppearance(oDest,ITEM_APPR_TYPE_ARMOR_MODEL,ITEM_APPR_ARMOR_MODEL_TORSO);
    int nSourceTorso = GetItemAppearance(oSource,ITEM_APPR_TYPE_ARMOR_MODEL,ITEM_APPR_ARMOR_MODEL_TORSO);
    if (nDestTorso!=nSourceTorso)
    {
        int nDestACBonus = StringToInt(Get2DAString("parts_chest","ACBONUS",nDestTorso));
        int nSourceACBonus = StringToInt(Get2DAString("parts_chest","ACBONUS",nSourceTorso));
        bCopyTorso = (nDestACBonus==nSourceACBonus);
    }

    object oNewItem = oDest;
    int iModelType;
    for (iModelType=0; iModelType<ITEM_APPR_ARMOR_NUM_MODELS; iModelType++)
    {
        if ((iModelType!=ITEM_APPR_ARMOR_MODEL_TORSO) || bCopyTorso)
        {
            oNewItem = MK_MatchItem(oNewItem, oSource, ITEM_APPR_TYPE_ARMOR_MODEL,iModelType);
        }
    }
    return oNewItem;
}

object MK_CopyColor(object oDest, object oSource)
{
    object oNewItem = oDest;
    oNewItem = MK_MatchItem(oNewItem, oSource, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1);
    oNewItem = MK_MatchItem(oNewItem, oSource, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2);
    oNewItem = MK_MatchItem(oNewItem, oSource, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1);
    oNewItem = MK_MatchItem(oNewItem, oSource, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2);
    oNewItem = MK_MatchItem(oNewItem, oSource, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1);
    oNewItem = MK_MatchItem(oNewItem, oSource, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2);
    return oNewItem;
}

/*
object MK_ModifyCloakModel(object oPC, object oItem, int nNewValue)
{
    // Bodge for CopyItemAndModify not working on cloak appearance in NWN v1.68
    // Create a new cloak with the correct model
    object oContainer = IPGetIPWorkContainer(oPC);

    object oNewItem = CreateItemOnObject(MK_GetCloakModelResRef(nNewValue), oContainer, 1, GetTag(oItem));

    // Copy across all the colors for it
    oNewItem = MK_MatchItem(oNewItem, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1);
    oNewItem = MK_MatchItem(oNewItem, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2);
    oNewItem = MK_MatchItem(oNewItem, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1);
    oNewItem = MK_MatchItem(oNewItem, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2);
    oNewItem = MK_MatchItem(oNewItem, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1);
    oNewItem = MK_MatchItem(oNewItem, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2);

    // Copy the item properties
    itemproperty iProp = GetFirstItemProperty(oItem);
    while (GetIsItemPropertyValid(iProp))
    {
        if (GetItemPropertyDurationType(iProp) == DURATION_TYPE_PERMANENT)
        {
            AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oNewItem);
        }
        iProp = GetNextItemProperty(oItem);
    }

    // Copy the name
    SetName(oNewItem,GetName(oItem));

    // Copy the stolen flag
    SetStolenFlag(oNewItem, GetStolenFlag(oItem));

    // Copy the plot flag
    SetPlotFlag(oNewItem, GetPlotFlag(oItem));

    // Copy the curse flag
    SetItemCursedFlag(oNewItem, GetItemCursedFlag(oItem));

    object oNew = CopyItem(oNewItem, oPC, FALSE);
    DestroyObject(oNewItem);

    return oNew;
}
*/

int MK_IsBodyPartVisible(int nRobe, int nPart)
{
    string sColumn="";

    switch (nPart)
    {
    case ITEM_APPR_ARMOR_MODEL_LBICEP:
        sColumn = "HIDEBICEPR";
        break;
    case ITEM_APPR_ARMOR_MODEL_RBICEP:
        sColumn = "HIDEBICEPL";
        break;
    case ITEM_APPR_ARMOR_MODEL_LFOREARM:
        sColumn = "HIDEFOREL";
        break;
    case ITEM_APPR_ARMOR_MODEL_RFOREARM:
        sColumn = "HIDEFORER";
        break;
    case ITEM_APPR_ARMOR_MODEL_LFOOT:
        sColumn = "HIDEFOOTL";
        break;
    case ITEM_APPR_ARMOR_MODEL_RFOOT:
        sColumn = "HIDEFOOTR";
        break;
    case ITEM_APPR_ARMOR_MODEL_LHAND:
        sColumn = "HIDEHANDL";
        break;
    case ITEM_APPR_ARMOR_MODEL_RHAND:
        sColumn = "HIDEHANDR";
        break;
    case ITEM_APPR_ARMOR_MODEL_LSHIN:
        sColumn = "HIDESHINR";
        break;
    case ITEM_APPR_ARMOR_MODEL_RSHIN:
        sColumn = "HIDESHINL";
        break;
    case ITEM_APPR_ARMOR_MODEL_LSHOULDER:
        sColumn = "HIDESHOL";
        break;
    case ITEM_APPR_ARMOR_MODEL_RSHOULDER:
        sColumn = "HIDESHOR";
        break;
    case ITEM_APPR_ARMOR_MODEL_LTHIGH:
        sColumn = "HIDELEGL";
        break;
    case ITEM_APPR_ARMOR_MODEL_RTHIGH:
        sColumn = "HIDELEGR";
        break;
    case ITEM_APPR_ARMOR_MODEL_NECK:
        sColumn = "HIDENECK";
        break;
    case ITEM_APPR_ARMOR_MODEL_BELT:
        sColumn = "HIDEBELT";
        break;
    case ITEM_APPR_ARMOR_MODEL_PELVIS:
        sColumn = "HIDEPELVIS";
        break;
    case ITEM_APPR_ARMOR_MODEL_TORSO:
        sColumn = "HIDECHEST";
        break;
    }

    int nHide = StringToInt(Get2DAString("parts_robe", sColumn, nRobe));

    return (nHide==0);
}

void MK_DyeItem(object oPC, int iMaterialToDye, int iColor)
{
    if (!GetIsObjectValid(oPC))
    {
        return;
    }
    object oItem = CIGetCurrentModItem(oPC);
    if (!GetIsObjectValid(oItem))
    {
        return;
    }
    object oNew = MK_GetDyedItem(oItem, iMaterialToDye, iColor, TRUE);
    CISetCurrentModItem(oPC,oNew);

    int nInventorySlot = MK_GetCurrentInventorySlot(oPC);

    AssignCommand(oPC, ActionEquipItem(oNew, nInventorySlot));
}

void MK_SetColorToken(object oItem, int nMaterialToDye)
{
    if (GetIsObjectValid(oItem))
    {
        string sColor1 = GetLocalString(OBJECT_SELF, "MK_TOKEN_COLOR1");
        string sColor2 = GetLocalString(OBJECT_SELF, "MK_TOKEN_COLOR2");
        string sColor="";
        int nColor, iMaterial;
        for (iMaterial = 0; iMaterial<ITEM_APPR_ARMOR_NUM_COLORS; iMaterial++)
        {
            if (iMaterial==nMaterialToDye)
            {
                sColor = sColor1;
            }
            else
            {
                sColor = sColor2;
            }
            nColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, iMaterial);
            switch (iMaterial)
            {
            case ITEM_APPR_ARMOR_COLOR_LEATHER1:
            case ITEM_APPR_ARMOR_COLOR_LEATHER2:
            case ITEM_APPR_ARMOR_COLOR_CLOTH1:
            case ITEM_APPR_ARMOR_COLOR_CLOTH2:
                sColor+=MK_ClothColorEx(nColor);
                break;
            case ITEM_APPR_ARMOR_COLOR_METAL1:
            case ITEM_APPR_ARMOR_COLOR_METAL2:
                sColor+=MK_MetalColorEx(nColor);
                break;
            }
            sColor+="</c>";
            SetCustomToken(MK_TOKEN_COLOR1+iMaterial, sColor);
        }
    }
}

void MK_DisplayColors(object oPC, object oItem)
{
    if (GetIsObjectValid(oItem)) {
        int iLeather1 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1);
        int iLeather2 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2);
        int iCloth1 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1);
        int iCloth2 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2);
        int iMetal1 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1);
        int iMetal2 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2);

        string sOutput = "\n" + "Leather 1: " + MK_ClothColorEx(iLeather1);
        sOutput += "\n" + "Leather 2: " + MK_ClothColorEx(iLeather2);
        sOutput += "\n" + "Cloth 1: " + MK_ClothColorEx(iCloth1);
        sOutput += "\n" + "Cloth 2: " + MK_ClothColorEx(iCloth2);
        sOutput += "\n" + "Metal 1: " + MK_MetalColorEx(iMetal1);
        sOutput += "\n" + "Metal 2: " + MK_MetalColorEx(iMetal2);

        SendMessageToPC(oPC, sOutput);
    }
}

string MK_ClothColorEx(int iColor, int bDisplayNumber)
{
    string sColor = MK_ClothColor(iColor);
    if (bDisplayNumber)
    {
        sColor = sColor + (sColor=="" ? " " : "") + "(" + IntToString(iColor) + ")";
    }
    return sColor;
}

string MK_MetalColorEx(int iColor, int bDisplayNumber)
{
    string sColor = MK_MetalColor(iColor);
    if (bDisplayNumber)
    {
        sColor = sColor + (sColor=="" ? " " : "") + "(" + IntToString(iColor) + ")";
    }
    return sColor;
}

string MK_Get2DAStringEx(string s2DA, string sColumn, int nRow, string sDefaultColumn)
{
    string sString = Get2DAString(s2DA, sColumn, nRow);
    if ((sString=="") && (sDefaultColumn!="") && (sDefaultColumn!=sColumn))
    {
        sString = Get2DAString(s2DA, sDefaultColumn, nRow);
    }
    return sString;
}

string MK_ClothColor(int iColor)
{
    return Get2DAString("MK_colornames", "Cloth", iColor);
}

string MK_MetalColor(int iColor)
{
    return MK_Get2DAStringEx("MK_colornames", "Metal", iColor, "Cloth");
}

string MK_Get2DAColumnFromMaterial(int iMaterial)
{
    string sColumn="";
    switch (iMaterial)
    {
    case ITEM_APPR_ARMOR_COLOR_LEATHER1:
    case ITEM_APPR_ARMOR_COLOR_LEATHER2:
    case ITEM_APPR_ARMOR_COLOR_CLOTH1:
    case ITEM_APPR_ARMOR_COLOR_CLOTH2:
        sColumn = "Cloth";
        break;
    case ITEM_APPR_ARMOR_COLOR_METAL1:
    case ITEM_APPR_ARMOR_COLOR_METAL2:
        sColumn = "Metal";
        break;
    }
    return sColumn;
}

void MK_SetTokenColorName(int iMaterialToDye, int iColorGroup)
{
    string sColumn = MK_Get2DAColumnFromMaterial(iMaterialToDye);
    int iColor,i;
    string sColorName;
    int nNumberOfColorsPerGroup = GetLocalInt(OBJECT_SELF, "MK_NUMBER_OF_COLORS_PER_GROUP");
    for (i = 0; i<nNumberOfColorsPerGroup; i++)
    {
        iColor = (iColorGroup*nNumberOfColorsPerGroup) + i;

        sColorName = MK_Get2DAStringEx("mk_colornames", sColumn, iColor, "Cloth");

        MK_GenericDialog_SetCondition(i,1);
//        SetLocalInt(OBJECT_SELF, "MK_CONDITION_"+IntToString(i), 1);
        SetCustomToken(MK_TOKEN_COLORNAME + i, sColorName);
    }
    for (i = nNumberOfColorsPerGroup; i<16; i++)
    {
        MK_GenericDialog_SetCondition(i,0);
//        SetLocalInt(OBJECT_SELF, "MK_CONDITION_"+IntToString(i), 0);
    }
}

void MK_SetTokenColorGroup(int iMaterialToDye)
{
    string sColumn = MK_Get2DAColumnFromMaterial(iMaterialToDye);

    int iGroup;
    string sGroupName;
    int nNumberOfColorGroups = GetLocalInt(OBJECT_SELF, "MK_NUMBER_OF_COLOR_GROUPS");
    for (iGroup=0; iGroup<nNumberOfColorGroups; iGroup++)
    {
        sGroupName = MK_Get2DAStringEx("mk_colorgroups", sColumn, iGroup, "Cloth");

        MK_GenericDialog_SetCondition(iGroup, (sGroupName==""? 0 : 1));
//        SetLocalInt(OBJECT_SELF, "MK_CONDITION_"+IntToString(iGroup), (sGroupName==""? 0 : 1));
        SetCustomToken(MK_TOKEN_COLORGROUP + iGroup, sGroupName);
    }
    for (iGroup=nNumberOfColorGroups; iGroup<22; iGroup++)
    {
        MK_GenericDialog_SetCondition(iGroup, 0);
//        SetLocalInt(OBJECT_SELF, "MK_CONDITION_"+IntToString(iGroup), 0);
    }
}

void MK_SetCurrentModParts(object oPC, int nPart1, int nPart2, int nStrRef1, int nStrRef2)
{
    SetLocalInt(oPC,"X2_TAILOR_CURRENT_PART",nPart1);
    SetLocalInt(oPC,"MK_TAILOR_CURRENT_PART2",nPart2);

    if ((nPart1>0) && (nPart2>0))
    {
        // * Make the camera float near the PC
        float fFacing  = GetFacing(oPC) + 180.0;
        if (fFacing > 359.0)
        {
            fFacing -=359.0;
        }

        float fPitch = 75.0;
        float  fDistance = 3.5f;

        if (nPart1 == ITEM_APPR_ARMOR_MODEL_RFOOT || nPart1 == ITEM_APPR_ARMOR_MODEL_LFOOT  )
        {
            fDistance = 3.5f;
            fPitch = 47.0f;
        }
        else if (nPart1 == ITEM_APPR_ARMOR_MODEL_LTHIGH || nPart1 == ITEM_APPR_ARMOR_MODEL_RTHIGH )
        {
            fDistance = 2.5f;
            fPitch = 65.0f;
        }
        else if (nPart1 == ITEM_APPR_ARMOR_MODEL_RSHIN || nPart1 == ITEM_APPR_ARMOR_MODEL_LSHIN    )
        {
            fDistance = 3.5f;
            fPitch = 95.0f;
        }

        if (MyPRCGetRacialType(oPC)  == RACIAL_TYPE_HALFORC)
        {
            fDistance += 1.0f;
        }

        SetCameraFacing(fFacing, fDistance, fPitch,CAMERA_TRANSITION_TYPE_VERY_FAST) ;
    }

    SetCustomToken(X2_CI_MODIFYARMOR_GP_CTOKENBASE,"0");
    SetCustomToken(X2_CI_MODIFYARMOR_GP_CTOKENBASE+1,"0");

    string sToken = GetStringByStrRef(nStrRef1);
    if (nStrRef2>0)
    {
        sToken+="/";
        sToken+=GetStringByStrRef(nStrRef2);
    }
    SetCustomToken(XP_IP_ITEMMODCONVERSATION_CTOKENBASE,sToken);
}

int MK_GetIsModifiableWeapon(object oItem)
{
    int nBaseType = GetBaseItemType(oItem);

    // Modifiable Weapons are ModelType 2 (?)
    int nModelType = StringToInt(Get2DAString("baseitems","ModelType",nBaseType));
    if (nModelType!=2)
    {
        return FALSE;
    }
    // Weapons should have a Weapon Size (?)
    int nWeaponSize = StringToInt(Get2DAString("baseitems","WeaponSize",nBaseType));
    if (nWeaponSize==0)
    {
        return FALSE;
    }
    return TRUE;
}

int MK_GetIsShield(object oItem)
{
    int bShield;

    switch (GetBaseItemType(oItem))
    {
    case BASE_ITEM_LARGESHIELD:
    case BASE_ITEM_SMALLSHIELD:
    case BASE_ITEM_TOWERSHIELD:
        bShield=TRUE;
        break;
    default:
        bShield=FALSE;
        break;
    }
    return bShield;
}

void MK_InitializeEditDescription(object oPC, object oObject)
{
    string sDescription = GetDescription(oObject, FALSE);
    string sOriginalDescription = GetDescription(oObject, TRUE);

    MK_GenericDialog_SetCondition(22, sDescription!=sOriginalDescription);

    SetLocalString(oPC, g_varEditorText, sDescription);

    if (MK_GetStringLength(sDescription, TRUE)>200)
    {
        sDescription = MK_CloseColorTags(MK_GetStringLeft(sDescription,200, TRUE)+"...");
    }
    SetCustomToken(MK_TOKEN_PARTSTRING, sDescription);
}

void MK_InitializeRenameItem(object oPC, object oItem)
{
    string sName = GetName(oItem, FALSE);
    string sNewName = GetLocalString(oPC, "MK_NEWNAME");
    string sOriginalName = GetName(oItem, TRUE);

    SetCustomToken(MK_TOKEN_PARTSTRING, sName);

    int i;
    int bOk;

    for (i=21; i<=22; i++)
    {
        bOk = FALSE;

        switch (i)
        {
        case 21:
            if ((sNewName!="") && (sNewName!=sName))
            {
                SetCustomToken(MK_TOKEN_NEWNAME , "'"+sNewName+"'");
                bOk = TRUE;
            }
            break;
        case 22:
            if (sName!=sOriginalName)
            {
                SetCustomToken(MK_TOKEN_ORIGINALNAME , "'"+sOriginalName+"'");
                bOk = TRUE;
            }
            break;
        }
        MK_GenericDialog_SetCondition(i, bOk);
    }

    //
    SetLocalString(oPC, g_varEditorText, (sNewName=="" ? sName : sNewName));
}

void MK_PrepareEditor(object oPC, int nEditorID, string sHeadLine,
    int nMaxLength, int bSingleLine, int bDisableColors,
    int bUseChatEvent)
{
    SetLocalInt(oPC, g_varEditorID, nEditorID);
    SetLocalInt(oPC, g_varEditorInit, 1);
    // to make sure the editor gets initialized.
    // Without this the editor doesn't get initialized and everything
    // will most likely look very strange.
    // So this is REQUIRED !!!

    SetLocalString(oPC, g_varEditorHeadLine, sHeadLine);
    // text displayed as 'headline'. Set it something different than ""
    // Otherwise the default headline 'IGTE vsersion - Text:' will be
    // displayed.

    // Allready done in MK_InitializeRenameItem() so we don't have to it here:
    //
    // SetLocalString(oPC, g_varEditorText, sText);
    // the text that gets edited. Withou this the text editor will start
    // empty (or containing something strange in case there are some remains
    // from a previous call.

    // We don't need it:
    //
    SetLocalString(oPC, g_varEditorOnInit, "");
    // the OnInit script gets called after the editor is initialized.
    // if you don't need it set it to "".

    // We don't need it:
    //
    SetLocalString(oPC, g_varEditorOnExit, "");
    // the OnExit script, gets called when the user exits the editor
    // using the 'Exit' (= OK) option.
    // that's the place where you should process the edited text.
    // replace 'mk_editor_onexit' with your script name.
    // Not required but without it the whole thing doesn't make much
    // sense because everything the user has done is lost.

    // We don't need it:
    //
    SetLocalString(oPC, g_varEditorOnCancel, "");
    // the name of the 'OnCancel' script, gets called when the user
    // exits the editor by choosing the 'Cancel' option.
    // Warning: the script does not get called if the user uses 'escape'
    // to exit the dialog.
    // replace 'mk_editor_oncncl' with your script name or set it to an
    // empty string if you don't have/need an 'OnCancel' script.

    SetLocalInt(oPC, g_varEditorMaxLength, nMaxLength);
    // You can limit the length of the text by setting the variable
    // g_varEditorMaxLength to value greater 0

    SetLocalInt(oPC, g_varEditorSingleLine, bSingleLine);
    // Setting 'g_varEditorSingleLine' to TRUE will disable the
    // 'Return (insert new line)' dialog option.

    SetLocalInt(oPC, g_varEditorDisableColors, bDisableColors);
    // Setting 'g_varEditorDisableColors' to TRUE will disable the
    // 'Colors (insert color codes)' dialog option.
    // Warning: the user still can use the chat line to insert color tags.

    SetLocalInt(oPC, g_varEditorDisableBlock, FALSE);
    // Setting 'g_varEditorDisableBlock' to TRUE will disable the following
    // dialog options: 'Shift Pos 1', 'Shift Left', 'Shift Right', 'Shift
    // End', 'Shift Delete', 'Shift Insert' and 'Ctrl Insert'. This will
    // perhaps make the editor less confusing but also you lose a lot of
    // functionality (you can't use the block operations anymore).

    SetLocalInt(oPC, g_varEditorDisableLoadSave, FALSE);
    // If g_varEditorDisableLoadSave is set to TRUE the player cannot load
    // or save text. Of course still the text gets saved to
    // g_varEditorText (if the player exits the editor using the OK button)

    SetLocalInt(oPC, g_varEditorUseOnPlayerChatEvent, bUseChatEvent);
    // if you use the editor in a single player game you don't have to use
    // the OnPlayerChatEvent because there are no other players and their
    // chat messages can't interfere with the users chat messages.
    // In a multiplayer game however you should use the OnPlayerChat event
    // to store the chat message as a variable on the player. The editor then
    // will use that variable instead of using the GetPCChatMessage command to
    // get the text entered by the user.
    // The OnPlayerChat event script should look like:
    //
    // #include "mk_inc_editor"
    // void main()
    // {
    //    object oPC = GetPCChatSpeaker();
    //    string sChatMessage = GetPCChatMessage();
    //
    //    int bEditorRunning = GetLocalInt(oPC, g_varEditorRunning);
    //    if (bEditorRunning) // the editor is running
    //    {
    //        int bUseOnPlayerChatEvent =
    //        GetLocalInt(oPC, g_varEditorUseOnPlayerChatEvent);
    //        if (bUseOnPlayerChatEvent)
    //        {
    //            SetLocalString(oPC, g_varEditorChatMessageString, sChatMessage);
    //
    //            // the following line is not required but will make everything
    //            // look much better.
    //            SetPCChatMessage(""); // delete the message so it does not
    //                                  // appear above the player's head
    //        }
    //        return;
    //    }
    //
    //    /*
    //    ...
    //    */
    // }
}

string MK_GetDescription(object oObject)
{
    string sDescription = GetDescription(oObject);
    if (GetDescription(oObject, TRUE)==sDescription)
    {
        sDescription = "";
    }
    return sDescription;
}

void MK_SaveCharacterDescription(object oPC)
{
    SetLocalString(oPC, MK_VAR_CHARACTER_DESCRIPTION,
        MK_GetDescription(oPC));
}

void MK_RestoreCharacterDescription(object oPC)
{
    SetDescription(oPC, GetLocalString(oPC, MK_VAR_CHARACTER_DESCRIPTION));
    DeleteLocalString(oPC, MK_VAR_CHARACTER_DESCRIPTION);
}

int MK_GetIsDescriptionModified(object oPC)
{
    return MK_GetDescription(oPC)!=GetLocalString(oPC, MK_VAR_CHARACTER_DESCRIPTION);
}

/*
void main()
{

}
/**/
