#include "prc_nui_consts"
#include "inc_newspellbook"
#include "psi_inc_psifunc"
#include "inc_lookups"
#include "nw_inc_nui"
#include "tob_inc_tobfunc"

//
// GetCurrentSpellLevel
// Gets the current spell level the class can achieve at the current
// caster level (ranging from 0-9)
//
// Arguments:
//   nClass:int the ClassID
//   nLevel:int the caster level
//
// Returns:
//   int the circle the class can achieve currently
//
int GetCurrentSpellLevel(int nClass, int nLevel);

//
// GetMaxSpellLevel
// Gets the highest possible circle the class can achieve (from 0-9)
//
// Arguments:
//   nClass:int the ClassID
//
// Returns:
//   int the highest circle that can be achieved
//
int GetMaxSpellLevel(int nClass);

//
// GetMinSpellLevel
// Gets the lowest possible circle the class can achieve (from 0-9)
//
// Arguments:
//   nClass:int the ClassID
//
// Returns:
//   int the lowest circle that can be achieved
//
int GetMinSpellLevel(int nClass);

//
// GetHighestLevelPossibleInClass
// Given a class Id this will determine what the max level of a class can be
// achieved
//
// Arguments:
//   nClass:int the ClassID
//
// Returns:
//   int the highest possible level the class can achieve
//
int GetHighestLevelPossibleInClass(int nClass);

//
// GetClassSpellbookFile
// Gets the class 2da spellbook/ability for the given class Id
//
// Arguments:
//   nClass:int the classID
//
// Returns:
//   string the 2da file name for the spell/abilities of the ClassID
//
string GetClassSpellbookFile(int nClass);

//
// GetBinderSpellToFeatDictionary
// Sets up the Binder Spell Dictionary that is used to match a binder's vestige
// to their feat. This is constructed based off the binder's known location of
// their feat and spell ranges in the base 2das respectivly. After constructing
// this it will be saved to the player locally as a cached result since we do
// not need to call this again.
//
// Argument:
//   oPlayer:object the player
//
// Returns:
//   json:Dictionary<String,Int> a dictionary of mapping between the SpellID
//     and the FeatID of a vestige ability
//
json GetBinderSpellToFeatDictionary(object oPlayer=OBJECT_SELF);

//
// GetSpellLevelIcon
// Takes the spell circle int and gets the icon appropriate for it (i.e. 0 turns
// into "ir_cantrips"
//
// Arguments:
//   spellLevel:int the spell level we want the icon for
//
// Returns:
//   string the spell level icon
//
string GetSpellLevelIcon(int spellLevel);

//
// GetSpellLevelToolTip
// Gets the spell level tool tip text based on the int spell level provided (i.e.
// 0 turns into "Cantrips")
//
// Arguments:
//   spellLevel:int the spell level we want the tooltip for
//
// Returns:
//   string the spell level toop tip
//
string GetSpellLevelToolTip(int spellLevel);

//
// GetSpellIcon
// Gets the spell icon based off the spellId, or featId supplied
//
// Arguments:
//   nClass:int the class Id
//   featId:int the featId we can use the icon for
//   spellId:int the spell Id we want the icon for
//
// Returns:
//   json:String the string of the icon we want.
//
json GetSpellIcon(int spellId, int featId=0, int nClass=0);
string GetSpellName(int spellId, int realSpellID=0, int featId=0, int nClass=0);

//
// GreyOutButton
// Takes NUI Button along with it's width and height and greys it out it with a drawn
// colored rectangle to represent it's not been selected or not valid.
//
// Arguments:
//   jButton:json the NUI Button
//   w:float the width of the button
//   h:float the height of the button
//
// Returns:
//   json the NUI button greyed out
//
json GreyOutButton(json jButton, float w, float h);

//
// CreateGreyOutRectangle
// Creates a grey out rectangle for buttons
//
// Arguments:
//   w:float the width of the button
//   h:float the height of the button
//
// Returns:
//   json the transparant black rectangle
//
json CreateGreyOutRectangle(float w, float h);

//
// GetTrueClassType
// Gets the true class Id for a provided class Id, mostly for RHD and for
// ToB prestige classes
//
// Arguments:
//   nClass:int classId
//
// Returns:
//   int the true classId based off nClass
//
int GetTrueClassType(int nClass, object oPC=OBJECT_SELF);

void CreateSpellDescriptionNUI(object oPlayer, int featID, int spellId=0, int realSpellId=0, int nClass=0);

void CallSpellUnlevelScript(object oPC, int nClass, int nLevel);
void ClearSpellDescriptionNUI(object oPlayer=OBJECT_SELF);
void RemoveIPFeat(object oPC, int ipFeatID);

void CallSpellUnlevelScript(object oPC, int nClass, int nLevel)
{
	SetScriptParam("UnLevel_ClassChoice", IntToString(nClass));
	SetScriptParam("UnLevel_LevelChoice", IntToString(nLevel));
    ExecuteScript("prc_unlvl_script", oPC);
}

void RemoveIPFeat(object oPC, int ipFeatID)
{
	   object oSkin = GetPCSkin(oPC);
	   itemproperty ipTest = GetFirstItemProperty(oSkin);
	   while(GetIsItemPropertyValid(ipTest))
    	{
    		// Check if the itemproperty is a bonus feat that has been marked for removal
        if(GetItemPropertyType(ipTest) == ITEM_PROPERTY_BONUS_FEAT)
        		{
    			     if (GetItemPropertySubType(ipTest) == ipFeatID)
            			{
    				        if(DEBUG) DoDebug("_ManeuverRecurseRemoveArray(): Removing bonus feat itemproperty:\n" + DebugIProp2Str(ipTest));
    				        // If so, remove it
    				        RemoveItemProperty(oSkin, ipTest);
            			}

        		}

    		ipTest = GetNextItemProperty(oSkin);
    	}
}

int GetCurrentSpellLevel(int nClass, int nLevel)
{
    int currentLevel = nLevel;

    // ToB doesn't have a concept of spell levels, but still match up to it
    if(nClass == CLASS_TYPE_WARBLADE
        || nClass == CLASS_TYPE_SWORDSAGE
        || nClass == CLASS_TYPE_CRUSADER
        || nClass == CLASS_TYPE_SHADOWCASTER)
    {
        return 9;
    }


    // Binders don't really have a concept of spell level
    if (nClass == CLASS_TYPE_BINDER
        || nClass == CLASS_TYPE_DRAGON_SHAMAN) // they can only reach 1st circle
        return 1;

    //Shadowsmith has no concept of spell levels
    if (nClass == CLASS_TYPE_SHADOWSMITH)
        return 2;

    if (nClass == CLASS_TYPE_WARLOCK
        || nClass == CLASS_TYPE_DRAGONFIRE_ADEPT)
        return 4;

    // Spont casters have their own function
    if(GetSpellbookTypeForClass(nClass) == SPELLBOOK_TYPE_SPONTANEOUS
        || nClass == CLASS_TYPE_ARCHIVIST)
    {

        int maxLevel = GetMaxSpellLevelForCasterLevel(nClass, currentLevel);
        return maxLevel;
    }
    else
    {
        // everyone else uses this
        string spellLevel2da = GetAMSKnownFileName(nClass);

        currentLevel = nLevel - 1; // Level is 1 off of the row in the 2da

        if  (nClass == CLASS_TYPE_FIST_OF_ZUOKEN
            || nClass == CLASS_TYPE_PSION
            || nClass == CLASS_TYPE_PSYWAR
            || nClass == CLASS_TYPE_WILDER
            || nClass == CLASS_TYPE_PSYCHIC_ROGUE
            || nClass == CLASS_TYPE_WARMIND)
            currentLevel = GetManifesterLevel(OBJECT_SELF, nClass, TRUE) - 1;

        int totalLevel = Get2DARowCount(spellLevel2da);

        // in case we somehow go over bounds just don't :)
        if (currentLevel >= totalLevel)
            currentLevel = totalLevel - 1;

        //Psionics have MaxPowerLevel as their column name
        string columnName = "MaxPowerLevel";

        //Invokers have MaxInvocationLevel
        if (nClass == CLASS_TYPE_WARLOCK
            || nClass == CLASS_TYPE_DRAGON_SHAMAN
            || nClass == CLASS_TYPE_DRAGONFIRE_ADEPT)
            columnName = "MaxInvocationLevel";

         // Truenamers have 3 sets of utterances, ranging from 1-6, EvolvingMind covers the entire range
        if (nClass == CLASS_TYPE_TRUENAMER)
        {
            columnName = "EvolvingMind";
            spellLevel2da = "cls_true_maxlvl"; //has a different 2da we want to look at
        }

        if (nClass == CLASS_TYPE_BINDER)
        {
            columnName = "VestigeLvl";
            spellLevel2da = "cls_bind_binder";
        }

        // ToB doesn't have a concept of this, but we don't care.

        int maxLevel = StringToInt(Get2DACache(spellLevel2da, columnName, currentLevel));
        return maxLevel;
    }
}

int GetMinSpellLevel(int nClass)
{
    // again sponts have their own function
    if(GetSpellbookTypeForClass(nClass) == SPELLBOOK_TYPE_SPONTANEOUS
        || nClass == CLASS_TYPE_ARCHIVIST)
    {
        return GetMinSpellLevelForCasterLevel(nClass, GetHighestLevelPossibleInClass(nClass));
    }
    else
    {
        if  (nClass == CLASS_TYPE_FIST_OF_ZUOKEN
            || nClass == CLASS_TYPE_PSION
            || nClass == CLASS_TYPE_PSYWAR
            || nClass == CLASS_TYPE_WILDER
            || nClass == CLASS_TYPE_PSYCHIC_ROGUE
            || nClass == CLASS_TYPE_WARMIND
            || nClass == CLASS_TYPE_WARBLADE
            || nClass == CLASS_TYPE_SWORDSAGE
            || nClass == CLASS_TYPE_CRUSADER
            || nClass == CLASS_TYPE_WARLOCK
            || nClass == CLASS_TYPE_DRAGONFIRE_ADEPT
            || nClass == CLASS_TYPE_DRAGON_SHAMAN
            || nClass == CLASS_TYPE_SHADOWCASTER
            || nClass == CLASS_TYPE_SHADOWSMITH
            || nClass == CLASS_TYPE_BINDER)
            return 1;

        return GetCurrentSpellLevel(nClass, 1);
    }

}

int GetMaxSpellLevel(int nClass)
{
    if (nClass == CLASS_TYPE_WILDER
        || nClass == CLASS_TYPE_PSION)
        return 9;
    if (nClass == CLASS_TYPE_PSYCHIC_ROGUE
        || nClass == CLASS_TYPE_FIST_OF_ZUOKEN
        || nClass == CLASS_TYPE_WARMIND)
        return 5;
    if (nClass == CLASS_TYPE_PSYWAR)
        return 6;

    return GetCurrentSpellLevel(nClass, GetHighestLevelPossibleInClass(nClass));
}

int GetHighestLevelPossibleInClass(int nClass)
{
    string sFile;

    //sponts have their spells in the classes.2da
    if(GetSpellbookTypeForClass(nClass) == SPELLBOOK_TYPE_SPONTANEOUS
        || nClass == CLASS_TYPE_ARCHIVIST)
    {
        sFile = Get2DACache("classes", "SpellGainTable", nClass);
    }
    else
    {
        // everyone else uses this
        sFile = GetAMSKnownFileName(nClass);

        if (nClass == CLASS_TYPE_TRUENAMER)
        {
            sFile = "cls_true_maxlvl"; //has a different 2da we want to look at
        }

        if (nClass == CLASS_TYPE_BINDER)
        {
            sFile = "cls_bind_binder";
        }
    }

    return Get2DARowCount(sFile);
}

string GetClassSpellbookFile(int nClass)
{
    string sFile;
    // Spontaneous casters use a specific file name structure
    if(GetSpellbookTypeForClass(nClass) == SPELLBOOK_TYPE_SPONTANEOUS
        || nClass == CLASS_TYPE_ARCHIVIST)
    {
        sFile = GetFileForClass(nClass);
    }
    // everyone else uses this structure
    else
    {
        sFile = GetAMSDefinitionFileName(nClass);

        if (nClass == CLASS_TYPE_BINDER)
        {
            sFile = "vestiges";
        }
    }

    return sFile;
}

string GetSpellLevelIcon(int spellLevel)
{
    switch (spellLevel)
    {
        case 0: return "ir_cantrips";
        case 1: return "ir_level1";
        case 2: return "ir_level2";
        case 3: return "ir_level3";
        case 4: return "ir_level4";
        case 5: return "ir_level5";
        case 6: return "ir_level6";
        case 7: return "ir_level789";
        case 8: return "ir_level789";
        case 9: return "ir_level789";
    }

    return "";
}

string GetSpellLevelToolTip(int spellLevel)
{
    switch (spellLevel)
    {
        case 0: return "Cantrips";
        case 1: return "Level 1";
        case 2: return "Level 2";
        case 3: return "Level 3";
        case 4: return "Level 4";
        case 5: return "Level 5";
        case 6: return "Level 6";
        case 7: return "Level 7";
        case 8: return "Level 8";
        case 9: return "Level 9";
    }

    return "";
}


json GetSpellIcon(int spellId,int featId=0,int nClass=0)
{
    // Binder's spells don't have the FeatID on the spells.2da, so we have to use
    // the mapping we constructed to get it.
    if (nClass == CLASS_TYPE_BINDER)
    {
        json binderDict = GetBinderSpellToFeatDictionary();
        int nFeatID = JsonGetInt(JsonObjectGet(binderDict, IntToString(spellId)));
        return JsonString(Get2DACache("feat", "Icon", featId));
    }

    if (featId)
        return JsonString(Get2DACache("feat", "Icon", featId));

    int masterSpellID = StringToInt(Get2DACache("spells", "Master", spellId));

    // if this is a sub radial spell, then we use spell's icon instead
    if (masterSpellID)
        return JsonString(Get2DACache("spells", "IconResRef", spellId));

    // the FeatID holds the accurate spell icon, not the SpellID
    int nFeatID = StringToInt(Get2DACache("spells", "FeatID", spellId));
	// however if no featId was found use the spell's icon instead
	if (!nFeatID)
		return JsonString(Get2DACache("spells", "IconResRef", spellId));

    return JsonString(Get2DACache("feat", "Icon", nFeatID));
}

string GetSpellName(int spellId, int realSpellID=0, int featId=0, int nClass=0)
{
    if ((nClass == CLASS_TYPE_SHADOWSMITH
        || nClass == CLASS_TYPE_SHADOWCASTER) && spellId)
        return GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", spellId)));
    if (nClass == CLASS_TYPE_TRUENAMER && featId)
        return GetStringByStrRef(StringToInt(Get2DACache("feat", "FEAT", featId)));
    if (realSpellID)
        return GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", realSpellID)));
    if (spellId)
        return GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", spellId)));
    if (featId)
        return GetStringByStrRef(StringToInt(Get2DACache("feat", "FEAT", featId)));

    return GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", spellId)));
}

json GetBinderSpellToFeatDictionary(object oPlayer=OBJECT_SELF)
{
    // a dictionary of <SpellID, FeatID>
    json binderDict = GetLocalJson(oPlayer, NUI_SPELLBOOK_BINDER_DICTIONARY_CACHE_VAR);
    // if this hasn't been created, create it now.
    if (binderDict == JsonNull())
        binderDict = JsonObject();
    else
        return binderDict;

    // the starting row for binder spells
    int spellIndex = 19070;
    // the starting row for binder feats
    int featIndex = 9030;
    //the end of the binder spells/feats
    while  (spellIndex <= 19156 && featIndex <= 9104)
    {
        // get the SpellID tied to the feat
        int spellID = StringToInt(Get2DACache("feat", "SPELLID", featIndex));
        // if the spellID matches the current index, then this is the spell
        // attached to the feat
        if (spellID == spellIndex)
        {
            binderDict = JsonObjectSet(binderDict, IntToString(spellID), JsonInt(featIndex));

            // move to next spell/feat
            featIndex++;
            spellIndex++;
        }
        // else we have reached a subdial spell
        else
        {
            // loop through until we reach back at spellID
            while (spellIndex < spellID)
            {
                int masterSpell = StringToInt(Get2DACache("spells", "Master", spellIndex));

                // add the sub radial to the dict, tied to the master's FeatID
                int featId = JsonGetInt(JsonObjectGet(binderDict, IntToString(masterSpell)));
                binderDict = JsonObjectSet(binderDict, IntToString(spellIndex), JsonInt(featId));

                spellIndex++;
            }


            // some feats overlap the same FeatID, can cause this to get stuck.
            // if it happens then move on
            if (spellIndex > spellID)
                featIndex++;
        }
    }

    // cache the result
    SetLocalJson(oPlayer, NUI_SPELLBOOK_BINDER_DICTIONARY_CACHE_VAR, binderDict);
    return binderDict;
}

json GreyOutButton(json jButton, float w, float h)
{
    json retValue = jButton;

    json jBorders = JsonArray();
    jBorders = JsonArrayInsert(jBorders, CreateGreyOutRectangle(w, h));

    return NuiDrawList(jButton, JsonBool(FALSE), jBorders);
}

json CreateGreyOutRectangle(float w, float h)
{
    // set the points of the button shape
    json jPoints = JsonArray();
    jPoints = JsonArrayInsert(jPoints, JsonFloat(0.0));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(0.0));

    jPoints = JsonArrayInsert(jPoints, JsonFloat(0.0));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(h));

    jPoints = JsonArrayInsert(jPoints, JsonFloat(w));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(h));

    jPoints = JsonArrayInsert(jPoints, JsonFloat(w));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(0.0));

    jPoints = JsonArrayInsert(jPoints, JsonFloat(0.0));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(0.0));

    return NuiDrawListPolyLine(JsonBool(TRUE), NuiColor(0, 0, 0, 127), JsonBool(TRUE), JsonFloat(2.0), jPoints);
}

void CreateSpellDescriptionNUI(object oPlayer, int featID, int spellId=0, int realSpellId=0, int nClass=0)
{
    SetLocalInt(oPlayer, NUI_SPELL_DESCRIPTION_FEATID_VAR, featID);
    SetLocalInt(oPlayer, NUI_SPELL_DESCRIPTION_SPELLID_VAR, spellId);
    SetLocalInt(oPlayer, NUI_SPELL_DESCRIPTION_REAL_SPELLID_VAR, realSpellId);
    SetLocalInt(oPlayer, NUI_SPELL_DESCRIPTION_CLASSID_VAR, nClass);
    ExecuteScript("prc_nui_dsc_view", oPlayer);
}

void ClearSpellDescriptionNUI(object oPlayer=OBJECT_SELF)
{
    DeleteLocalInt(oPlayer, NUI_SPELL_DESCRIPTION_FEATID_VAR);
    DeleteLocalInt(oPlayer, NUI_SPELL_DESCRIPTION_SPELLID_VAR);
    DeleteLocalInt(oPlayer, NUI_SPELL_DESCRIPTION_REAL_SPELLID_VAR);
    DeleteLocalInt(oPlayer, NUI_SPELL_DESCRIPTION_CLASSID_VAR);
}

int GetTrueClassType(int nClass, object oPC=OBJECT_SELF)
{
    if (nClass == CLASS_TYPE_JADE_PHOENIX_MAGE
        || nClass == CLASS_TYPE_MASTER_OF_NINE
        || nClass == CLASS_TYPE_DEEPSTONE_SENTINEL
        || nClass == CLASS_TYPE_BLOODCLAW_MASTER
        || nClass == CLASS_TYPE_RUBY_VINDICATOR
        || nClass == CLASS_TYPE_ETERNAL_BLADE
        || nClass == CLASS_TYPE_SHADOW_SUN_NINJA)
    {
        int trueClass = GetPrimaryBladeMagicClass(oPC);
        return trueClass;
    }

    if ((nClass == CLASS_TYPE_SHAPECHANGER
            && GetRacialType(oPC) == RACIAL_TYPE_ARANEA)
     || (nClass == CLASS_TYPE_OUTSIDER
            && GetRacialType(oPC) == RACIAL_TYPE_RAKSHASA)
     || (nClass == CLASS_TYPE_ABERRATION
            && GetRacialType(oPC) == RACIAL_TYPE_DRIDER)
     || (nClass == CLASS_TYPE_MONSTROUS
            && GetRacialType(oPC) == RACIAL_TYPE_ARKAMOI)
     || (nClass == CLASS_TYPE_MONSTROUS
            && GetRacialType(oPC) == RACIAL_TYPE_HOBGOBLIN_WARSOUL)
     || (nClass == CLASS_TYPE_MONSTROUS
            && GetRacialType(oPC) == RACIAL_TYPE_REDSPAWN_ARCANISS)
     || (nClass == CLASS_TYPE_MONSTROUS
            && GetRacialType(oPC) == RACIAL_TYPE_MARRUTACT))
            return CLASS_TYPE_SORCERER;
     if (nClass == CLASS_TYPE_FEY
            && GetRacialType(oPC) == RACIAL_TYPE_GLOURA)
         return CLASS_TYPE_BARD;

    return nClass;
}

