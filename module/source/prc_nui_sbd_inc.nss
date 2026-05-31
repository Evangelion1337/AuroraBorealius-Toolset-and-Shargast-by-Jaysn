//::///////////////////////////////////////////////
//:: PRC Spellbook Description NUI
//:: prc_nui_sbd_inc
//:://////////////////////////////////////////////
/*
    This is the view for the Spell Description NUI
*/
//:://////////////////////////////////////////////
//:: Created By: Rakiov
//:: Created On: 29.05.2005
//:://////////////////////////////////////////////
#include "nw_inc_nui"
#include "prc_nui_consts"
#include "inc_2dacache"

//
// CreateSpellDescriptionNUI
// Creates a Spell Description NUI mimicing the description GUI of NWN
//
// Arguments:
//   oPlayer:Object the player object
//   featID:int the FeatID
//   spellId:int the SpellID
//   realSpellId:int the RealSpellID
//
void CreateSpellDescriptionNUI(object oPlayer, int featID, int spellId=0, int realSpellId=0);

void CreateSpellDescriptionNUI(object oPlayer, int featID, int spellId=0, int realSpellId=0)
{
    // look for existing window and destroy
    int nPreviousToken = NuiFindWindow(oPlayer, NUI_SPELL_DESCRIPTION_WINDOW_ID);
    if(nPreviousToken != 0)
    {
        NuiDestroy(oPlayer, nPreviousToken);
    }

/* 	int nPreviousToken = NuiFindWindow(OBJECT_SELF, NUI_SPELL_DESCRIPTION_WINDOW_ID);
    if(nPreviousToken != 0)
    {
        NuiDestroy(OBJECT_SELF, nPreviousToken);
    } */

    // in order of accuracy for names it goes RealSpellID > SpellID > FeatID
    string spellName;
    if (realSpellId)
        spellName = GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", realSpellId)));
    else if (spellId)
        spellName = GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", spellId)));
    else
        spellName = GetStringByStrRef(StringToInt(Get2DACache("feat", "FEAT", featID)));
    // Descriptions and Icons are accuratly stored on the feat
    string spellDesc = GetStringByStrRef(StringToInt(Get2DACache("feat", "DESCRIPTION", featID)));
    string spellIcon = Get2DACache("feat", "ICON", featID);

    json jRoot = JsonArray();
    json jGroup = JsonArray();

    json jRow = JsonArray();

    json jImage = NuiImage(JsonString(spellIcon), JsonInt(NUI_ASPECT_EXACT), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_TOP));
    jImage = NuiWidth(jImage, 32.0f);
    jRow = JsonArrayInsert(jRow, jImage);
    jRow = NuiCol(jRow);
    jGroup = JsonArrayInsert(jGroup, jRow);

    jRow = JsonArray();
    json jText = NuiText(JsonString(spellDesc), FALSE, NUI_SCROLLBARS_AUTO);
    jRow = JsonArrayInsert(jRow, jText);
    jRow = NuiCol(jRow);
    jGroup = JsonArrayInsert(jGroup, jRow);

    jGroup = NuiRow(jGroup);
    jGroup = NuiGroup(jGroup, TRUE, NUI_SCROLLBARS_NONE);
    jRoot = JsonArrayInsert(jRoot, jGroup);

    jRow = JsonArray();
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    json jButton = NuiId(NuiButton(JsonString("OK")), NUI_SPELL_DESCRIPTION_OK_BUTTON);
    jButton = NuiWidth(jButton, 175.0f);
    jButton = NuiHeight(jButton, 48.0f);
    jRow = JsonArrayInsert(jRow, jButton);
    jRow = NuiRow(jRow);

    jRoot = JsonArrayInsert(jRoot, jRow);
    jRoot = NuiCol(jRoot);


    // This is the main window with jRoot as the main pane.  It includes titles and parameters (more on those later)
    json nui = NuiWindow(jRoot, JsonString(spellName), NuiBind("geometry"), NuiBind("resizable"), JsonBool(FALSE), NuiBind("closable"), NuiBind("transparent"), NuiBind("border"));

    // finally create it and it'll return us a non-zero token.
    int nToken = NuiCreate(oPlayer, nui, NUI_SPELL_DESCRIPTION_WINDOW_ID);

    // get the geometry of the window in case we opened this before and have a
    // preference for location
    json geometry = NuiRect(893.0f,346.0f, 426.0f, 446.0f);

    // Set the binds to their default values
    NuiSetBind(oPlayer, nToken, "geometry", geometry);
    NuiSetBind(oPlayer, nToken, "resizable", JsonBool(FALSE));
    NuiSetBind(oPlayer, nToken, "closable", JsonBool(FALSE));
    NuiSetBind(oPlayer, nToken, "transparent", JsonBool(FALSE));
    NuiSetBind(oPlayer, nToken, "border", JsonBool(TRUE));
}
