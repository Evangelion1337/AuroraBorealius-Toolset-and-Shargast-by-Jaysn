//::///////////////////////////////////////////////
//:: Name   New Spellbooks spell learning conversation
//:: FileName   prc_s_spellgain.nss
//:://////////////////////////////////////////////
/**
New spellbooks spell learning conversation.
To be called after a level up event.
Allows to learn new spells, and to unlearn spells
Each conversation instance is tied to some class's spellbook

so far only relevant for spontaneous casters, because the prepared
caster classes provided by the PRC know all spells of their class spellbook

Author:    ?
Created:   ?
*/

//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


/**
modified on Apr 2008 by motu99
added choices to unlearn spells for spont casters, added switches for Bioware or PnP unlearning
*/

/**
PnP rules for unlearning spells:

Sorcerer:
Upon reaching 4th level, and at every even-numbered sorcerer level
after that (6th, 8th, and so on), a sorcerer can choose to learn a
new spell in place of one he already knows. In effect, the
sorcerer �loses� the old spell in exchange for the new one.
The new spell�s level must be the same as that of the spell
being exchanged, and it must be at least two levels lower than
the highest-level sorcerer spell the sorcerer can cast. A
sorcerer may swap only a single spell at any given level, and
must choose whether or not to swap the spell at the same time
that he gains new spells known for the level.

Bard:
Upon reaching 5th level, and at every third bard level after that
(8th, 11th, and so on), a bard can choose to learn a new spell in
place of one he already knows. In effect, the bard �loses� the
old spell in exchange for the new one. The new spell�s level must be
the same as that of the spell being exchanged, and it must be at least
two levels lower than the highest-level bard spell the bard can cast.
A bard may swap only a single spell at any given level, and must choose
whether or not to swap the spell at the same time that he gains new spells
known for the level.

Favored Soul:
Upon reaching 4th level, and at every even-numbered 
favored soul level after that (6th, 8th, and so on), a favored 
soul can choose to learn a new spell in place of one she 
already knows. In effect, the favored soul �loses� the old 
spell in exchange for the new one. The new spell�s level 
must be the same as that of the spell being exchanged, and 
it must be at least two levels lower than the highest-level 
favored soul spell the favored soul can cast. A favored soul 
may swap only a single spell at any given level, and must 
choose whether or not to swap the spell at the same time 
that she gains new spells known for the level.

Warmage:
When a warmage gains access to a 
new level of spells, he automatically knows all the spells for 
that level listed on the warmage�s spell list. Essentially, his 
spell list is the same as his spells known list. Warmages also 
have the option of adding to their existing spell list through 
their advanced learning ability as they increase in level (see 
below). See page 90 for the warmage�s spell list.

Advanced Learning (Ex): At 3rd, 6th, 11th, and 16th 
level, a warmage can add a new spell to his list, representing 
the result of personal study and experimentation. The spell 
must be a wizard spell of the evocation school, and of a level 
no higher than that of the highest-level spell the warmage 
already knows. Once a new spell is selected, it is forever added 
to that warmage�s spell list and can be cast just like any other 
spell on the warmage�s list.

Hexblade:
Upon reaching 12th level, and at every third hexblade level 
after that (15th and 18th), a hexblade can choose to learn a new spell in place of one he 
already knows. In effect, the hexblade �loses� the 
old spell in exchange for the new one. The new spell�s 
level must be the same as that of the spell being exchanged, 
and it must be at least two levels lower than the highest-level 
hexblade spell the hexblade can cast. For instance, upon 
reaching 12th level, a hexblade could trade in a single 1st-
level spell (two spell levels below the highest-level hexblade 
spell he can cast, which is 3rd) for a different 1st-level spell. 
At 15th level, he could trade in a single 1st-level or 2nd-level 
spell (since he now can cast 4th-level hexblade spells) for a 
different spell of the same level. A hexblade may swap only
a single spell at any given level, and must choose whether or 
not to swap the spell at the same time that he gains new spells 
known for the level.
 Through 3rd level, a hexblade has no caster level. At 4th 
level and higher, his caster level is one-half his hexblade 

Duskblade:
Upon reaching 5th level, and at every odd-numbered 
Duskblade level after that (7th, 9th, and so on), a Duskblade
 can choose to learn a new spell in place of one she 
already knows. In effect, the Duskblade �loses� the old 
spell in exchange for the new one. The new spell�s level 
must be the same as that of the spell being exchanged, and 
it must be at least two levels lower than the highest-level 
Duskblade spell the Duskblade can cast. A Duskblade
may swap only a single spell at any given level, and must 
choose whether or not to swap the spell at the same time 
that she gains new spells known for the level.

Suel Archanamach:
He has access to any spell of the 
abjuration, divination, illusion, and transmutation schools 
on the sorcerer/wizard spell list. He casts spells just as a 
sorcerer does, including the ability to replace a known Suel 
arcanamach spell with a new spell at every even-numbered 
class level beginning at 4th
*/

#include "prc_inc_function"
#include "inc_dynconv"
#include "inc_newspellbook"
#include "inc_sp_gain_mem"
#include "x3_inc_string"

int IsIntSet(object oPC, string sArray, int nValue)
{
    int nSize = persistant_array_get_size(oPC, sArray);
    int i;
    for(i = 0; i < nSize; i++)
    {
        if(persistant_array_get_int(oPC, sArray, i) == nValue)
            return i;
    }
    return -1;
}

//////////////////////////////////////////////////
/* Constant definitions                         */
//////////////////////////////////////////////////

const int STAGE_UNLEARN_CHOICE = 0;
const int STAGE_SELECT_UNLEARN_LEVEL = 1;
const int STAGE_SELECT_UNLEARN_SPELL = 2;
const int STAGE_CONFIRM_UNLEARN = 3;
const int STAGE_SELECT_LEVEL = 4;
const int STAGE_SELECT_SPELL = 5;
const int STAGE_CONFIRM      = 6;
const int STAGE_CONFIRM_ALL  = 7;
const int STAGE_ADVLEARN_LEVEL = 8;
const int STAGE_ADVLEARN_SPELL = 9;
const int STAGE_ADVLEARN_CONFIRM = 10;

const int STRREF_SELECTED_HEADER1   = 16824209; // "You have selected:"
const int STRREF_SELECTED_HEADER2   = 16824210; // "Is this correct?"
const int STRREF_END_CONVO_SELECT   = 16824212; // "Finish"
const int LEVEL_STRREF_START        = 16824809;
const int STRREF_YES                = 4752;     // "Yes"
const int STRREF_NO                 = 4753;     // "No"
const int CHOICE_RETURN_TO_PREVIOUS = 0xEFFFFFFF;

const string SPELLGAIN_CONV_CLASS = "SpellGainClass";
const string SPELLGAIN_CONV_LEVEL = "SelectedLevel";
const string SPELLGAIN_CONV_SPELL = "SelectedSpell";
const string SPELLGAIN_CONV_UNLEARN_LEVEL = "UnlrnLvl"; // maximum spell level that can be unlearned at level up
const string SPELLGAIN_CONV_UNLEARN_COUNT = "UnlrnCnt"; // max nr of spells that can be unlearned at level up
const string SPELLGAIN_CONV_LEARN_LEVELUP = "LrnLvlUp"; // prep casters: nr of new spells to be learned at level up


//////////////////////////////////////////////////
/* Aid functions                                */
//////////////////////////////////////////////////

// all spells known by a (spont) caster are stored in one single array, with no differentiation for spell level
// Here we need to determine the spells known at specific spell levels. This requires a pass over the whole array.
// For efficiency we determine the spells known for ALL spell levels and cache the result
const string SPELLS_KNOWN_CACHE = "SKCCCache";

void DeleteSKCCCache(object oPC)
{
  DeleteLocalInt(oPC, SPELLS_KNOWN_CACHE + "0");
  DeleteLocalInt(oPC, SPELLS_KNOWN_CACHE + "1");
  DeleteLocalInt(oPC, SPELLS_KNOWN_CACHE + "2");
  DeleteLocalInt(oPC, SPELLS_KNOWN_CACHE + "3");
  DeleteLocalInt(oPC, SPELLS_KNOWN_CACHE + "4");
  DeleteLocalInt(oPC, SPELLS_KNOWN_CACHE + "5");
  DeleteLocalInt(oPC, SPELLS_KNOWN_CACHE + "6");
  DeleteLocalInt(oPC, SPELLS_KNOWN_CACHE + "7");
  DeleteLocalInt(oPC, SPELLS_KNOWN_CACHE + "8");
  DeleteLocalInt(oPC, SPELLS_KNOWN_CACHE + "9");
}

// caches the nr of spells that oPC currently knows at the different spell levels
void CacheSpellsKnown(int nClass, object oPC)
{
  // Loop over all spells known and count the number of spells of each level known
  int nKnown0, nKnown1, nKnown2, nKnown3, nKnown4;
  int nKnown5, nKnown6, nKnown7, nKnown8, nKnown9;

  // persistant storage of spellbook on the hide
  //object oToken = GetHideToken(oPC);
  string sSpellbook = GetSpellsKnown_Array(nClass);
  int nSpellsKnown_AllLevels = persistant_array_get_size(oPC, sSpellbook);

  string sFile = GetNSBDefinitionFileName(nClass);

  int i;
  for(i = 0; i < nSpellsKnown_AllLevels; i++)
  {
    int nSpellbookID = persistant_array_get_int(oPC, sSpellbook, i);
    int nSpellLevel = StringToInt(Get2DACache(sFile, "Level", nSpellbookID));
    switch(nSpellLevel)
    {
      case 0: nKnown0++; break; case 1: nKnown1++; break;
      case 2: nKnown2++; break; case 3: nKnown3++; break;
      case 4: nKnown4++; break; case 5: nKnown5++; break;
      case 6: nKnown6++; break; case 7: nKnown7++; break;
      case 8: nKnown8++; break; case 9: nKnown9++; break;
    }
  }

  // Cache the values (one higher)
  SetLocalInt(oPC, SPELLS_KNOWN_CACHE + "0", ++nKnown0);
  SetLocalInt(oPC, SPELLS_KNOWN_CACHE + "1", ++nKnown1);
  SetLocalInt(oPC, SPELLS_KNOWN_CACHE + "2", ++nKnown2);
  SetLocalInt(oPC, SPELLS_KNOWN_CACHE + "3", ++nKnown3);
  SetLocalInt(oPC, SPELLS_KNOWN_CACHE + "4", ++nKnown4);
  SetLocalInt(oPC, SPELLS_KNOWN_CACHE + "5", ++nKnown5);
  SetLocalInt(oPC, SPELLS_KNOWN_CACHE + "6", ++nKnown6);
  SetLocalInt(oPC, SPELLS_KNOWN_CACHE + "7", ++nKnown7);
  SetLocalInt(oPC, SPELLS_KNOWN_CACHE + "8", ++nKnown8);
  SetLocalInt(oPC, SPELLS_KNOWN_CACHE + "9", ++nKnown9);
}

// updates the cached values of spells known for nSpellLevel
int UpdateSpellsKnown(int nClass, int nSpellLevel, object oPC)
{
  // persistant storage of spellbook on the hide
  //object oToken = GetHideToken(oPC);
  string sSpellbook = GetSpellsKnown_Array(nClass);
  int nSpellsKnown_AllLevels = persistant_array_get_size(oPC, sSpellbook);

  int nKnown;
  string sFile = GetNSBDefinitionFileName(nClass);

  int i;
  for(i = 0; i < nSpellsKnown_AllLevels; i++)
  {
    int nSpellbookID = persistant_array_get_int(oPC, sSpellbook, i);
    if (nSpellLevel == StringToInt(Get2DACache(sFile, "Level", nSpellbookID)))
    {
      nKnown++;
    }
  }

  // Cache the value (one higher)
  SetLocalInt(oPC, SPELLS_KNOWN_CACHE + IntToString(nSpellLevel), nKnown + 1);
  return nKnown;
}

// gets the nr of spells that oPC currently knows at nSpellLevel with nClass
int GetSpellsKnown(int nClass, int nSpellLevel, object oPC)
{
  // Check cache
  string sCache = SPELLS_KNOWN_CACHE + IntToString(nSpellLevel);
  int nKnown = GetLocalInt(oPC, sCache);

  // Cache not yet set up?
  if(!nKnown)
  {
    // then set the cache up and get the nr of spells known at nSpellLevel from the cache
    CacheSpellsKnown(nClass, oPC);
    nKnown = GetLocalInt(oPC, sCache);
  }

  // decrement the value retrieved from cache, because we stored one higher than the actual value to catch a legitimate count of 0
  --nKnown;

  if(DEBUG) DoDebug("GetSpellsKnown(" + GetName(oPC) + ", " +IntToString(nSpellLevel)+ ", " +IntToString(nClass)+ ") = " + IntToString(nKnown));
  return nKnown;
}

// gets the total nr of spells up to nMaxSpellLevel that oPC currently knows
// caches results for all spell levels (because all spells known are stored in one single array)
int GetTotalNrOfSpellsKnown(int nClass, int nMaxSpellLevel, object oPC)
{
  // Check cache at spell level 0
  string sCache = SPELLS_KNOWN_CACHE + "0";
  int nKnown = GetLocalInt(oPC, sCache);
  // cache not present? Then make it
  if(!nKnown)
  {
    CacheSpellsKnown(nClass, oPC);
    nKnown = GetLocalInt(oPC, sCache);
  }

  // nr of known level 0 spells (cached value minus 1)
  --nKnown;

  // get other spell levels, up to max level
  int nSpellLevel;
  for (nSpellLevel = 1; nSpellLevel <= nMaxSpellLevel; nSpellLevel++)
  {
    // cached value is one higher than the actual value, so decrement by one
    nKnown += (GetLocalInt(oPC, SPELLS_KNOWN_CACHE + IntToString(nSpellLevel)) - 1);
  }

  if(DEBUG) DoDebug("GetTotalNrOfSpellsKnown(" + GetName(oPC) + ", " + IntToString(nMaxSpellLevel) + ", " +IntToString(nClass)+ ") = " + IntToString(nKnown));
  return nKnown;
}

// gets the maximum spell level, at which nClass can unlearn a spell at nCasterLevel according to PnP rules
// if nClass cannot unlearn a spell at nCasterLevel, we return -1
int GetPnPUnlearnMaxSpellLevel(int nClass, int nCasterLevel)
{
  int nLevelModifier;
  
  if(  nClass == CLASS_TYPE_SORCERER
    || nClass == CLASS_TYPE_SUEL_ARCHANAMACH
    || nClass == CLASS_TYPE_FAVOURED_SOUL
    || nClass == CLASS_TYPE_MYSTIC
    || nClass == CLASS_TYPE_SUBLIME_CHORD)
  {
    // casterlevel must be at least four and an even nur
    if (nCasterLevel >= 4 && ((nCasterLevel & 0x1) == 0))
      nLevelModifier = 2;
  }
  else if (nClass == CLASS_TYPE_BARD)
  {
    // casterlevel must be at least five; then every three levels
    if (nCasterLevel >= 5 && ((nCasterLevel - 2) % 3 == 0))
      nLevelModifier = 2;
  }
  else if (nClass == CLASS_TYPE_DUSKBLADE)
  {
    // casterlevel must be at least five; then every odd level
    if (nCasterLevel >= 5 && (nCasterLevel & 0x1))
      nLevelModifier = 2;
  }
  else if (nClass == CLASS_TYPE_HEXBLADE)
  {
    // casterlevel must be at least twelve; then every three levels
    if (nCasterLevel >= 12 && (nCasterLevel % 3 == 0))
      nLevelModifier = 2;
  }

  if (nLevelModifier)
    return GetMaxSpellLevelForCasterLevel(nClass, nCasterLevel) - nLevelModifier;
  else
    return -1;
}

// note that this also sets the local variables SPELLGAIN_CONV_UNLEARN_LEVEL and SPELLGAIN_CONV_UNLEARN_COUNT
int DetermineNrOfSpellsToUnlearn(int nClass, object oPC)
{
  int nUnlearnCount = GetLocalInt(oPC, SPELLGAIN_CONV_UNLEARN_COUNT);
  if (!nUnlearnCount)
  {
    int nCasterLevel = GetCasterLevelByClass(nClass, oPC);
    int bBioUnlearn = GetPRCSwitch(PRC_BIO_UNLEARN);
    int nMaxSpellLevel_Unlearn;
    int nKnown_Total;

    // determine the maximum level at which we can unlearn spells
    if (bBioUnlearn)
      // Bioware rules allow to unlearn spells up to the maximum level nClass can cast
      nMaxSpellLevel_Unlearn = GetMaxSpellLevelForCasterLevel(nClass, nCasterLevel);
    else
      // in PnP we can only unlearn a limited amount of spells; at very specific casterlevels; and only some levels below our max
      // if the function returns -1, we cannot unlearn any spells at this nCasterLevel
      nMaxSpellLevel_Unlearn = GetPnPUnlearnMaxSpellLevel(nClass, nCasterLevel);

    // are we able to unlearn spells at this nCasterlevel?
    if (nMaxSpellLevel_Unlearn >= 0
      // can only unlearn spells, if we know at least one spell up to the max level we may unlearn
      && ((nKnown_Total = GetTotalNrOfSpellsKnown(nClass, nMaxSpellLevel_Unlearn, oPC)) > 0))
    {
      // set the maximum caster level we can unlearn
      SetLocalInt(oPC, SPELLGAIN_CONV_UNLEARN_LEVEL, nMaxSpellLevel_Unlearn);

      // get the max nr of spells that can be unlearned from the switch
      nUnlearnCount = GetPRCSwitch(PRC_UNLEARN_SPELL_MAXNR);

      // if switch is not set, use default rules to determine max nr of spells that can be unlearned
      if (!nUnlearnCount)
      {
        if (bBioUnlearn)
        {
          // Bioware casters can in principle unlearn all spells they know
          nUnlearnCount = nKnown_Total;
        }
        else
        {
          // in full PnP we can only unlearn one single spell
          nUnlearnCount = 1;
        }
      }

      // make sure we never unlearn more than we actually know
      if (nUnlearnCount > nKnown_Total) nUnlearnCount = nKnown_Total;
    }
    else
    {
      // if we cannot unlearn at this level, set the unlearn count to -1, so we know we cannot unlearn and that we already set up this stage
      nUnlearnCount = -1;
    }

    SetLocalInt(oPC, SPELLGAIN_CONV_UNLEARN_COUNT, nUnlearnCount);
  }
  return nUnlearnCount;
}

void LearnSpecificSpell(int nClass, int nSpellLevel, int nSpellbookID, object oPC)
{
  // get location of persistant storage on the hide
  string sSpellbook = GetSpellsKnown_Array(nClass, nSpellLevel);
  //object oPC = GetHideToken(oPC);

  // Create spells known persistant array  if it is missing
  int nSize = persistant_array_get_size(oPC, sSpellbook);
  if (nSize < 0)
  {
    persistant_array_create(oPC, sSpellbook);
    nSize = 0;
  }

  // Mark the spell as known (e.g. add it to the end of oPCs spellbook)
  persistant_array_set_int(oPC, sSpellbook, nSize, nSpellbookID);

  // increment the spells known value in the cache
  string sCache = SPELLS_KNOWN_CACHE + IntToString(nSpellLevel);
  int nKnown = GetLocalInt(oPC, sCache);
  if (nKnown) SetLocalInt(oPC, sCache, ++nKnown);

  if(GetSpellbookTypeForClass(nClass) == SPELLBOOK_TYPE_SPONTANEOUS)
  {
    // get the associated feat and IPfeat IDs
    string sFile = GetNSBDefinitionFileName(nClass);
    int nIPFeatID = StringToInt(Get2DACache(sFile, "IPFeatID", nSpellbookID));
    int nFeatID   = StringToInt(Get2DACache(sFile, "FeatID", nSpellbookID));

    // Add spell use feats (this also places the bonus feat on the hide, so we can check whether oPC knows this spell by testing for the featID on the hide)
    AddSpellUse(oPC, nSpellbookID, nClass, sFile, "NewSpellbookMem_" + IntToString(nClass), SPELLBOOK_TYPE_SPONTANEOUS, GetPCSkin(oPC), nFeatID, nIPFeatID);
  }
}


//////////////////////////////////////////////////
/* Main function                                */
//////////////////////////////////////////////////

void main()
{
  object oPC = GetPCSpeaker();
  int nValue = GetLocalInt(oPC, DYNCONV_VARIABLE);
  int nStage = GetStage(oPC);
  int nClass = GetLocalInt(oPC, SPELLGAIN_CONV_CLASS);

  // Check which of the conversation scripts called the scripts
  if(nValue == 0) // All of them set the DynConv_Var to non-zero value, so something is wrong -> abort
    return;

  // this conversation is always called for a specific class!

  if(nValue == DYNCONV_SETUP_STAGE)
  {
    // Check if this stage is marked as already set up
    // This stops list duplication when scrolling
    if(!GetIsStageSetUp(nStage, oPC))
    {
      // variable named nStage determines the current conversation node
      // Function SetHeader to set the text displayed to the PC
      // Function AddChoice to add a response option for the PC. The responses are shown in order added
      if (nStage == STAGE_UNLEARN_CHOICE)
      {
        // first determine the nr of spells that might be unlearned
        int nUnlearnCount = DetermineNrOfSpellsToUnlearn(nClass, oPC);

        // if we can unlearn spells, give oPC a choice
        if (nUnlearnCount > 0)
        {
          SetHeader("You can unlearn " +IntToString(nUnlearnCount) +" spells\nDo you want to unlearn a spell?");
          SetDefaultTokens(); // Set the next, previous, exit and wait tokens to default values
          AddChoice(GetStringByStrRef(STRREF_YES), TRUE);
          AddChoice(GetStringByStrRef(STRREF_NO), FALSE);
        }
        //check if it's Advanced Learning dialog
        else if(GetLocalInt(oPC, "AdvancedLearning"))
        {
          nStage = STAGE_ADVLEARN_LEVEL;
          SetStage(nStage, oPC);
        }
        else
        {
          // otherwise proceed directly to spell learning stage
          nStage = STAGE_SELECT_LEVEL;
          SetStage(nStage, oPC);
        }
        MarkStageSetUp(STAGE_UNLEARN_CHOICE, oPC);
      }
      
      // the second if is intentional, Dont change to else if!!
      if(nStage == STAGE_SELECT_UNLEARN_LEVEL)
      {
                int nSpellLevelMin = GetLocalInt(oPC, "SpellbookMinSpelllevel");
        // the maximum spell level at which we can unlearn spells was already set up in the previous phase, just retrieve it
                int nSpellLevelMax = GetLocalInt(oPC, SPELLGAIN_CONV_UNLEARN_LEVEL);

        int nChoiceAdded = FALSE;

        int nSpellLevel;
        // go through all spell levels, starting at the minimum level for nClass and ending at the maximum level that can be unlearned
        for(nSpellLevel = nSpellLevelMin; nSpellLevel <= nSpellLevelMax; nSpellLevel++)
        {
          // get spells known to oPC at the given level
          int nSpells_Known  = GetSpellsKnown(nClass, nSpellLevel, oPC);

          // only add a choice, if we know spells at that level
          if(nSpells_Known > 0)
          {
            AddChoice(GetStringByStrRef(7544)/*"Spell Level"*/ + " " + IntToString(nSpellLevel), nSpellLevel);
            nChoiceAdded = TRUE;
          }
        }

        // if we added at least one spell level, set the header
        if (nChoiceAdded == TRUE)
        {
          SetDefaultTokens(); // Set the next, previous, exit and wait tokens to default values
          SetHeader("Select a level from which to unlearn a spell");
        }
        else
        {
          SetHeader("You do not have any spells to unlearn");
          // if we didn't find a single spell to unlearn (shouldn't happen), set the unlearn count to -1 to indicate that cannot unlearn any spells at this point
          SetLocalInt(oPC, SPELLGAIN_CONV_UNLEARN_COUNT, -1);
        }
        MarkStageSetUp(nStage, oPC); // This prevents the setup being run for this stage again until MarkStageNotSetUp is called for it
      }
      else if(nStage == STAGE_SELECT_UNLEARN_SPELL)
      {
        // get the level at which we want to unlearn the spell
        int nSpellLevel  = GetLocalInt(oPC, SPELLGAIN_CONV_LEVEL);
        string sFile = GetNSBDefinitionFileName(nClass);

        // Determine the array where the spells known to oPC are stored (one array for all spell levels)
        string sSpellbook = GetSpellsKnown_Array(nClass);
        //object oToken = GetHideToken(oPC);

        // determine the total nr of spells known to oPC
        int nSpellsKnown_AllLevels = persistant_array_get_size(oPC, sSpellbook);

        // Set up header
        SetHeader("Select a spell to unlearn");

        // List all spells known at the given level
        int i;
        for(i = 0; i < nSpellsKnown_AllLevels; i++)
        {
          // get the spellbookID (= row nr in cls_spell_*) for the i-th spell known
          int nSpellbookID = persistant_array_get_int(oPC, sSpellbook, i);
          // get the level of that spell  and check whether it is equal to the spell level we selected
          int nLevel = StringToInt(Get2DACache(sFile, "Level", nSpellbookID));
          if (nLevel == nSpellLevel)
          {
            // get the real spellID, get the spell name from the real SpellID and add a choice
            int nSpellID = StringToInt(Get2DACache(sFile, "RealSpellID", nSpellbookID));
            string sName = GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellID)));
            AddChoice(sName, nSpellbookID, oPC);
          }
        }

        SetDefaultTokens();
        MarkStageSetUp(nStage, oPC);
      }
      else if(nStage == STAGE_CONFIRM_UNLEARN)
      {
        // get the spellbookID  (= row nr in cls_spell_*) for the spell we want to unlearn
        int nSpellbookID = GetLocalInt(oPC, SPELLGAIN_CONV_SPELL);

        // get the real spellID and the feat ID from cls_spell_*
        string sFile = GetNSBDefinitionFileName(nClass);
        int nSpellID = StringToInt(Get2DACache(sFile, "RealSpellID", nSpellbookID));
        int nFeatID = StringToInt(Get2DACache(sFile, "FeatID", nSpellbookID));

        // show the full spell description (as determined from the feat)
        string sToken  = GetStringByStrRef(16824209) + "\n\n"; // "You have selected:"
             sToken += GetStringByStrRef(StringToInt(Get2DACache("feat", "FEAT",        nFeatID))) + "\n";
             sToken += GetStringByStrRef(StringToInt(Get2DACache("feat", "DESCRIPTION", nFeatID))) + "\n\n";
             sToken += GetStringByStrRef(16824210); // "Is this correct?"
        SetHeader(sToken);

        AddChoice(GetStringByStrRef(STRREF_YES), TRUE);
        AddChoice(GetStringByStrRef(STRREF_NO), FALSE);

        MarkStageSetUp(nStage, oPC);
        SetDefaultTokens();
      }
      else if(nStage == STAGE_SELECT_LEVEL)
      {
        int nCasterLevel = GetCasterLevelByClass(nClass, oPC);
                int nSpellLevelMin = GetLocalInt(oPC, "SpellbookMinSpelllevel");
                // int nSpellLevelMax = GetLocalInt(oPC, "SpellbookMaxSpelllevel");
        int nSpellLevelMax = GetMaxSpellLevelForCasterLevel(nClass, nCasterLevel);

        int nSpellLevel;
        int nAddedASpellLevel = FALSE;

        if (GetSpellbookTypeForClass(nClass) == SPELLBOOK_TYPE_SPONTANEOUS)
        {
          // go through all spell levels that are available for nClass up to the maximum spell level that oPC can cast
          for(nSpellLevel = nSpellLevelMin; nSpellLevel <= nSpellLevelMax; nSpellLevel++)
          {
            // get the maximum nr of spells oPC is allowed to know at the given spell level
            int nSpells_Max = GetSpellsKnown_MaxCount(nCasterLevel, nClass, nSpellLevel, oPC);
            // if we cannot know any spells yet, no sense to do something
            if (nSpells_Max > 0)
            {
              // get the nr of spells oPC knows at the given nSpellLevel and nClass
                        int nSpells_Known  = GetSpellsKnown(nClass, nSpellLevel, oPC);

              // we can only learn more spells, when the spells currently known at the given nSpellLevel are less than the max
              if(nSpells_Known < nSpells_Max)
              {
                // get total nr of spells available for the given class and spell level
                int nSpells_Total  = GetSpellsInClassSpellbook_Count(nClass, nSpellLevel);
                // are there still unknown spells in the class spellbook that we can transfer?
                if(nSpells_Total > nSpells_Known)
                {
                  nAddedASpellLevel = TRUE;
                  AddChoice(GetStringByStrRef(7544)/*"Spell Level"*/ + " " + IntToString(nSpellLevel), nSpellLevel);
                }
                else
                  if(DEBUG) DoDebug("ERROR: prc_s_spellgain: Insufficient spells to fill level " + IntToString(nSpellLevel) + "; Class: " + IntToString(nClass));
              }
            }
          }
        }
        else if (GetSpellbookTypeForClass(nClass) == SPELLBOOK_TYPE_PREPARED && GetLocalInt(oPC, SPELLGAIN_CONV_LEARN_LEVELUP) > 0)
        {
          nAddedASpellLevel = TRUE;
          // go through all spell levels that are available for nClass up to the maximum spell level that oPC can cast
          // 0-level spells already added
          for(nSpellLevel = nSpellLevelMin + 1; nSpellLevel <= nSpellLevelMax; nSpellLevel++)
          {
              AddChoice(GetStringByStrRef(7544)/*"Spell Level"*/ + " " + IntToString(nSpellLevel), nSpellLevel);
          }
        }

        // if there is at least one spell level at which we can still learn spells, go to the spel level selection phase
        if(nAddedASpellLevel)
        {
          SetDefaultTokens(); // Set the next, previous, exit and wait tokens to default values
          // "<classname> spellbook.\nSelect a spell level to gain spells from."
          SetHeader(ReplaceChars(GetStringByStrRef(16828405), "<classname>", GetStringByStrRef(StringToInt(Get2DACache("classes", "Name", nClass)))));
        }
        // if we couldn't add a single level from which to learn spells, we are finished, so allow exit
        else
        {
          /*SetHeaderStrRef(16828406); // "You can select more spells when you next gain a level."
          AllowExit(DYNCONV_EXIT_ALLOWED_SHOW_CHOICE, TRUE, oPC);
          SetCustomToken(DYNCONV_TOKEN_EXIT, GetStringByStrRef(STRREF_END_CONVO_SELECT));*/
          AllowExit(DYNCONV_EXIT_FORCE_EXIT);
        }

        MarkStageSetUp(nStage, oPC); // This prevents the setup being run for this stage again until MarkStageNotSetUp is called for it
      }
      else if(nStage == STAGE_SELECT_SPELL)
      {
        int nCasterLevel = GetCasterLevelByClass(nClass, oPC);
        int nSpellLevel  = GetLocalInt(oPC, SPELLGAIN_CONV_LEVEL);

        // class spellbook (one array for each spell level)
        //object oToken_Class = GetSpellsOfClass_Token(nClass, nSpellLevel);
        string sSpellBook_Class = GetSpellsOfClass_Array();

        // get the total nr of spells in the class spellbook at the given spell level
        int nSpells_Total  = persistant_array_get_size(oPC, sSpellBook_Class);

        // now determine storage location of the spellbook of oPC (all spell levels stored in one array)
        string sSpellBook = GetSpellsKnown_Array(nClass, nSpellLevel);
        //object oToken = GetHideToken(oPC);

                // Create spells known array if it is missing
                if(!persistant_array_exists(oPC, sSpellBook)) persistant_array_create(oPC, sSpellBook);

        // Determine how many spells the character knows and how many
        // he is maximally allowed to know (at the given nClass, nCasterLevel and nSpellLevel)
        int nSpells_Max;
        int nSpells_ToSelect;
        if (GetSpellbookTypeForClass(nClass) == SPELLBOOK_TYPE_SPONTANEOUS)
        {
          int nSpells_Known  = GetSpellsKnown(nClass, nSpellLevel, oPC);
          nSpells_Max = GetSpellsKnown_MaxCount(nCasterLevel, nClass, nSpellLevel, oPC);

          // cannot learn more spells than there are in the class spellbook
          if (nSpells_Max > nSpells_Total)  nSpells_Max = nSpells_Total;

          nSpells_ToSelect = nSpells_Max - nSpells_Known;
        }
        else
        {
          nSpells_ToSelect = GetLocalInt(oPC, SPELLGAIN_CONV_LEARN_LEVELUP);
        }

        string sFile = GetNSBDefinitionFileName(nClass);

        // Set up header
        // "You have <selectcount> level <spelllevel> spells remaining to select."
        SetHeader(ReplaceChars(ReplaceChars(GetStringByStrRef(16828404),
              "<selectcount>", IntToString(nSpells_ToSelect)),
              "<spelllevel>", IntToString(nSpellLevel))
              );

        // 2009-9-20: Add a "learn all" option if he can do so. -N-S
        if (nSpells_Max >= nSpells_Total)
          // "[Learn all available spells]"
          // Use the constant -1 to indicate all spells are desired.
          AddChoice(StringToRGBString(GetStringByStrRef(16847627), STRING_COLOR_GREEN), -1, oPC);

        // List all spells not yet selected of this level
        int i;
        for(i = 0; i < nSpells_Total; i++)
        {
          // get the nSpellbookID (= row nr in the cls_spell_* file) out of the class spellbook and determine the associated feat
          int nSpellbookID = persistant_array_get_int(oPC, sSpellBook_Class, i);
          int nFeatID = StringToInt(Get2DACache(sFile, "FeatID", nSpellbookID));

          if (GetSpellbookTypeForClass(nClass) == SPELLBOOK_TYPE_SPONTANEOUS)
          {
              // only if oPC doesn't have the feat, she doesn have the spell
              if (!GetHasFeat(nFeatID, oPC))
              {
                // get the real spellID, get the spell name from the real spellID and add a choice
                int nSpellID = StringToInt(Get2DACache(sFile, "RealSpellID", nSpellbookID));
                string sName = GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellID)));
                AddChoice(sName, nSpellbookID, oPC);

                if(DEBUG) DoDebug("prc_s_spellgain: Adding spell selection choice:\n"
                        + "spell ID     = " + IntToString(nSpellID) + "\n"
                        + "spellbook ID = " + IntToString(nSpellbookID) + "\n"
                          );
              }
          }
          else
          {
              //check if oPC doesn't have the spell and can learn it
              if (IsIntSet(oPC, sSpellBook, nSpellbookID) == -1 && StringToInt(Get2DACache(sFile, "AL", nSpellbookID)) != 1)
              {
                // get the real spellID, get the spell name from the real spellID and add a choice
                int nSpellID = StringToInt(Get2DACache(sFile, "RealSpellID", nSpellbookID));
                string sName = GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellID)));
                AddChoice(sName, nSpellbookID, oPC);

                if(DEBUG) DoDebug("prc_s_spellgain: Adding spell selection choice:\n"
                        + "spell ID     = " + IntToString(nSpellID) + "\n"
                        + "spellbook ID = " + IntToString(nSpellbookID) + "\n"
                          );
              }
          }
        }
        
        if (DEBUG)
        {
            DoDebug("Spellbook nCasterLevel: "+IntToString(nCasterLevel));
            DoDebug("Spellbook nSpellLevel: "+IntToString(nSpellLevel));
            DoDebug("Spellbook nSpells_ToSelect: "+IntToString(nSpells_ToSelect));
            DoDebug("Spellbook sFile: "+sFile);
        }        

        SetDefaultTokens();
        MarkStageSetUp(nStage, oPC);
      }
      else if(nStage == STAGE_CONFIRM)
      {
        // get the spellbookID and the feat ID for the new spell to be learned
        string sFile = GetNSBDefinitionFileName(nClass);
        int nSpellbookID = GetLocalInt(oPC, SPELLGAIN_CONV_SPELL);
        int nFeatID = StringToInt(Get2DACache(sFile, "FeatID", nSpellbookID));

        // get the full description according from the feat ID
        string sToken  = GetStringByStrRef(16824209) + "\n\n"; // "You have selected:"
             sToken += GetStringByStrRef(StringToInt(Get2DACache("feat", "FEAT",        nFeatID))) + "\n";
             sToken += GetStringByStrRef(StringToInt(Get2DACache("feat", "DESCRIPTION", nFeatID))) + "\n\n";
             sToken += GetStringByStrRef(16824210); // "Is this correct?"

        SetHeader(sToken);

        AddChoice(GetStringByStrRef(STRREF_YES), TRUE);
        AddChoice(GetStringByStrRef(STRREF_NO), FALSE);

        MarkStageSetUp(nStage, oPC);
        SetDefaultTokens();
      }
      // 2009-9-20: Add a "learn all" stage. -N-S
      else if(nStage == STAGE_CONFIRM_ALL)
      {
        int nSpellLevel = GetLocalInt(oPC, SPELLGAIN_CONV_LEVEL);

        // class spellbook (one array for each spell level)
        //object oToken_Class = GetSpellsOfClass_Token(nClass, nSpellLevel);
        string sSpellBook_Class = GetSpellsOfClass_Array();

        // get the total nr of spells in the class spellbook at the given spell level
        int nSpells_Total = persistant_array_get_size(oPC, sSpellBook_Class);

        string sFile = GetNSBDefinitionFileName(nClass);

        string sToken = GetStringByStrRef(16847628) + "\n\n"; // "You have selected the following spells:"
        int i;
        for(i = 0; i < nSpells_Total; i++)
        {
          // get the nSpellbookID (= row nr in the cls_spell_* file) out of the class spellbook and determine the associated feat
          int nSpellbookID = persistant_array_get_int(oPC, sSpellBook_Class, i);
          int nFeatID = StringToInt(Get2DACache(sFile, "FeatID", nSpellbookID));

          // only if oPC doesn't have the feat, she doesn have the spell
          if (!GetHasFeat(nFeatID, oPC))
            sToken += GetStringByStrRef(StringToInt(Get2DACache("feat", "FEAT", nFeatID))) + "\n";
        }
        sToken += "\n" + GetStringByStrRef(16824210); // "Is this correct?"

        SetHeader(sToken);

        AddChoice(GetStringByStrRef(STRREF_YES), TRUE);
        AddChoice(GetStringByStrRef(STRREF_NO), FALSE);

        MarkStageSetUp(nStage, oPC);
        SetDefaultTokens();
      }
      else if(nStage == STAGE_ADVLEARN_LEVEL)
      {
        int nAL = GetLocalInt(oPC, "AdvancedLearning");

        if(nAL)
        {
          int nCasterLevel = GetCasterLevelByClass(nClass, oPC);
          int nSpellLevelMin = GetLocalInt(oPC, "SpellbookMinSpelllevel");
          int nSpellLevelMax = GetMaxSpellLevelForCasterLevel(nClass, nCasterLevel);

          int nSpellLevel;
          // go through all spell levels that are available for nClass up to the maximum spell level that oPC can cast
          for(nSpellLevel = nSpellLevelMin; nSpellLevel <= nSpellLevelMax; nSpellLevel++)
          {
              AddChoice(GetStringByStrRef(7544)/*"Spell Level"*/ + " " + IntToString(nSpellLevel), nSpellLevel);
          }

          SetDefaultTokens(); // Set the next, previous, exit and wait tokens to default values
          // "<classname> spellbook.\nSelect a spell level to gain spells from."
          SetHeader(ReplaceChars(GetStringByStrRef(16828405), "<classname>", GetStringByStrRef(StringToInt(Get2DACache("classes", "Name", nClass)))));
        }
        // if we couldn't add a single level from which to learn spells, we are finished, so allow exit
        else
        {
          /*SetHeaderStrRef(16828406); // "You can select more spells when you next gain a level."
          AllowExit(DYNCONV_EXIT_ALLOWED_SHOW_CHOICE, TRUE, oPC);
          SetCustomToken(DYNCONV_TOKEN_EXIT, GetStringByStrRef(STRREF_END_CONVO_SELECT));*/
          AllowExit(DYNCONV_EXIT_FORCE_EXIT);
        }

        MarkStageSetUp(nStage, oPC); // This prevents the setup being run for this stage again until MarkStageNotSetUp is called for it
      }
      else if(nStage == STAGE_ADVLEARN_SPELL)
      {
        int nCasterLevel = GetCasterLevelByClass(nClass, oPC);
        int nSpellLevel  = GetLocalInt(oPC, SPELLGAIN_CONV_LEVEL);

        // class spellbook (one array for each spell level)
        //object oToken_Class = GetSpellsOfClass_Token(nClass, nSpellLevel);
        string sSpellBook_Class = GetSpellsOfClass_Array();

        // get the total nr of spells in the class spellbook at the given spell level
        int nSpells_Total  = persistant_array_get_size(oPC, sSpellBook_Class);

        // now determine storage location of the spellbook of oPC (all spell levels stored in one array)
        string sSpellBook = GetSpellsKnown_Array(nClass);
        //object oToken = GetHideToken(oPC);

        // Create spells known array if it is missing
        if(!persistant_array_exists(oPC, sSpellBook)) persistant_array_create(oPC, sSpellBook);

        // Only one AL spell at a time
        int nSpells_ToSelect = 1;

        string sFile = GetNSBDefinitionFileName(nClass);

        // Set up header
        // "You have <selectcount> spells remaining to select."
        SetHeader(ReplaceChars(ReplaceChars(GetStringByStrRef(16828404),
              "<selectcount>", IntToString(nSpells_ToSelect)),
              "<spelllevel>", IntToString(nSpellLevel))
              );

        AddChoice(StringToRGBString(GetStringByStrRef(16847645), STRING_COLOR_GREEN), CHOICE_RETURN_TO_PREVIOUS);
        // List all spells not yet selected of this level
        int i;
        for(i = 0; i < nSpells_Total; i++)
        {
          // get the nSpellbookID (= row nr in the cls_spell_* file) out of the class spellbook and determine the associated feat
          int nSpellbookID = persistant_array_get_int(oPC, sSpellBook_Class, i);
          //select only spells marked for Advanced Learning
          if(Get2DACache(sFile, "AL", nSpellbookID) == "1")
          {
            int nFeatID = StringToInt(Get2DACache(sFile, "FeatID", nSpellbookID));

            // only if oPC doesn't have the feat, she doesn have the spell
            if (!GetHasFeat(nFeatID, oPC))
            {
              // get the real spellID, get the spell name from the real spellID and add a choice
              int nSpellID = StringToInt(Get2DACache(sFile, "RealSpellID", nSpellbookID));
              string sName = GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellID)));
              AddChoice(sName, nSpellbookID, oPC);

              if(DEBUG) DoDebug("prc_s_spellgain: Adding spell selection choice:\n"
                      + "spell ID     = " + IntToString(nSpellID) + "\n"
                      + "spellbook ID = " + IntToString(nSpellbookID) + "\n"
                        );
            }
          }
        }

        SetDefaultTokens();
        MarkStageSetUp(nStage, oPC);
      }
      else if(nStage == STAGE_ADVLEARN_CONFIRM)
      {
        // get the spellbookID and the feat ID for the new spell to be learned
        string sFile = GetNSBDefinitionFileName(nClass);
        int nSpellbookID = GetLocalInt(oPC, SPELLGAIN_CONV_SPELL);
        int nFeatID = StringToInt(Get2DACache(sFile, "FeatID", nSpellbookID));

        // get the full description according from the feat ID
        string sToken  = GetStringByStrRef(16824209) + "\n\n"; // "You have selected:"
             sToken += GetStringByStrRef(StringToInt(Get2DACache("feat", "FEAT",        nFeatID))) + "\n";
             sToken += GetStringByStrRef(StringToInt(Get2DACache("feat", "DESCRIPTION", nFeatID))) + "\n\n";
             sToken += GetStringByStrRef(16824210); // "Is this correct?"

        SetHeader(sToken);

        AddChoice(GetStringByStrRef(STRREF_YES), TRUE);
        AddChoice(GetStringByStrRef(STRREF_NO), FALSE);

        MarkStageSetUp(nStage, oPC);
        SetDefaultTokens();
      }
      //add more stages for more nodes with Else If clauses
    }

    // Do token setup
    SetupTokens();
  }
  // Abort or exit conversation cleanup.
  // NOTE: This section is only run when the conversation is aborted
  // while aborting is allowed. When it isn't, the dynconvo infrastructure
  // handles restoring the conversation in a transparent manner
  else if(nValue == DYNCONV_EXITED ||
      nValue == DYNCONV_ABORTED )
  {
    // Add any locals set through this conversation
    DeleteLocalInt(oPC, SPELLGAIN_CONV_LEVEL);
    DeleteLocalInt(oPC, SPELLGAIN_CONV_CLASS);
    DeleteLocalInt(oPC, SPELLGAIN_CONV_SPELL);
    DeleteLocalInt(oPC, SPELLGAIN_CONV_UNLEARN_LEVEL);
    DeleteLocalInt(oPC, SPELLGAIN_CONV_UNLEARN_COUNT);
    DeleteLocalInt(oPC, SPELLGAIN_CONV_LEARN_LEVELUP);
    DeleteLocalInt(oPC, "AdvancedLearning");

    DeleteSKCCCache(oPC);

    DelayCommand(1.0, EvalPRCFeats(oPC));
  }
  // Handle PC responses
  else
  {
    // variable named nChoice is the value of the player's choice as stored when building the choice list
    // variable named nStage determines the current conversation node
    int nChoice = GetChoice(oPC);
    if(nStage == STAGE_UNLEARN_CHOICE)
    {
      // if spells can be unlearned and oPC wants to unlearn them, proceed to node that selects the level of the spell to be unlearned
      if( GetLocalInt(oPC, SPELLGAIN_CONV_UNLEARN_COUNT) > 0
        && nChoice == TRUE)
      {
        nStage = STAGE_SELECT_UNLEARN_LEVEL;
      }
      //check if it's Advanced Learning dialog
      else if(GetLocalInt(oPC, "AdvancedLearning"))
      {
        nStage = STAGE_ADVLEARN_LEVEL;
      }
      // otherwise proceed to first node of the "learn new spells" section (= select level)
      else
      {
        nStage = STAGE_SELECT_LEVEL;
      }
    }
    else if(nStage == STAGE_SELECT_UNLEARN_LEVEL)
    {
      // if the nr of spells that can be unlearned is zero (or less), proceed to first node of the "learn new spells" section (= select level)
      if(GetLocalInt(oPC, SPELLGAIN_CONV_UNLEARN_COUNT) <= 0)
        nStage = STAGE_SELECT_LEVEL;
      else
      {
        // otherwise remember the spell level at which to unlearn the spell and proceed to unlearn spell selection stage
        SetLocalInt(oPC, SPELLGAIN_CONV_LEVEL, nChoice);
        nStage = STAGE_SELECT_UNLEARN_SPELL;
      }
    }
    else if(nStage == STAGE_SELECT_UNLEARN_SPELL)
    {
      // record the spell that oPC selected as her unlearn choice and proceed to confirmation stage
      SetLocalInt(oPC, SPELLGAIN_CONV_SPELL, nChoice);
      nStage = STAGE_CONFIRM_UNLEARN;
    }
    else if(nStage == STAGE_CONFIRM_UNLEARN)
    {
      // we really want to unlearn the spell?
      if (nChoice == TRUE)
      {
        int nSpellbookID = GetLocalInt(oPC, SPELLGAIN_CONV_SPELL);

        // extract the spell from oPCs spellbook
        string sSpellBook = GetSpellsKnown_Array(nClass);
        //object oToken = GetHideToken(oPC);
        array_extract_int(oPC, sSpellBook, nSpellbookID);

        // get the associated IPFeatID and remove it from the hide
        // we dont remove the metamagic versions here, they will be removed by the hide cleaner at next rest
        string sFile = GetNSBDefinitionFileName(nClass);
        int nIPFeatID = StringToInt(Get2DACache(sFile, "IPFeatID", nSpellbookID));
        WipeSpellFromHide(nIPFeatID, oPC);

        // decrement the spells known value in the cache
        int nSpellLevel  = GetLocalInt(oPC, SPELLGAIN_CONV_LEVEL);
        string sCache = SPELLS_KNOWN_CACHE + IntToString(nSpellLevel);
        int nKnown = GetLocalInt(oPC, sCache);
        if (nKnown) SetLocalInt(oPC, sCache, --nKnown);

        // decrement the nr of spells that can be unlearned
        int nUnlearnCount = GetLocalInt(oPC, SPELLGAIN_CONV_UNLEARN_COUNT);
        nUnlearnCount--;
        if (nUnlearnCount == 0)
        {
          // make it -1, so that no new setup occurs (with more spells unlearned, than allowed)
          nUnlearnCount--;
          nStage = STAGE_SELECT_LEVEL;
        }
        else
          nStage = STAGE_UNLEARN_CHOICE;

        // remember the new nr of spells that can (still) be unlearned
        SetLocalInt(oPC, SPELLGAIN_CONV_UNLEARN_COUNT, nUnlearnCount);
      }
      else
      {
        // this was not the spell oPC wanted to unlearn? Then give oPC  a new choice
        nStage = STAGE_UNLEARN_CHOICE;
      }
    }
    // BEGIN OF LEARN NEW SPELLS SECTION
    else if(nStage == STAGE_SELECT_LEVEL)
    {
      // remember the spell level at which to learn the new spell and proceed to the spell selection phase
      SetLocalInt(oPC, SPELLGAIN_CONV_LEVEL, nChoice);
      nStage = STAGE_SELECT_SPELL;
    }
    else if(nStage == STAGE_SELECT_SPELL)
    {
      // 2009-9-20: Add a "learn all" stage. -N-S
      if (nChoice != -1)
      {
        // remember the new spell to learn and proceed to the confirmation phase
        SetLocalInt(oPC, SPELLGAIN_CONV_SPELL, nChoice);
        nStage = STAGE_CONFIRM;
      }
      else
        nStage = STAGE_CONFIRM_ALL;
    }
    else if(nStage == STAGE_CONFIRM)
    {
      // If this really is the new spell we want to learn:
      if(nChoice == TRUE)
      {
        // get the new spell's nSpellbookID and nSpellLevel
        int nSpellbookID = GetLocalInt(oPC, SPELLGAIN_CONV_SPELL);
        int nSpellLevel  = GetLocalInt(oPC, SPELLGAIN_CONV_LEVEL);

        LearnSpecificSpell(nClass, nSpellLevel, nSpellbookID, oPC);

        if(GetSpellbookTypeForClass(nClass) == SPELLBOOK_TYPE_PREPARED)
        {
            int nSpellsToLearn = GetLocalInt(oPC, "LrnLvlUp");
            --nSpellsToLearn;
            SetLocalInt(oPC, "LrnLvlUp", nSpellsToLearn);

            if(nClass == CLASS_TYPE_ARCHIVIST)
            {
                int nLvl = GetLevelByClass(CLASS_TYPE_ARCHIVIST, oPC);
                SetPersistantLocalInt(oPC, "LastSpellGainLevel", nLvl);
            }
        }
      }

      nStage = STAGE_SELECT_LEVEL;
    }
    // 2009-9-20: Add a "learn all" stage handler. -N-S
    else if(nStage == STAGE_CONFIRM_ALL)
    {
      if (nChoice == TRUE)
      {
        int nSpellLevel = GetLocalInt(oPC, SPELLGAIN_CONV_LEVEL);

        // class spellbook (one array for each spell level)

        //object oToken_Class = GetSpellsOfClass_Token(nClass, nSpellLevel);
        string sSpellBook_Class = GetSpellsOfClass_Array();

        // get the total nr of spells in the class spellbook at the given spell level
        int nSpells_Total = persistant_array_get_size(oPC, sSpellBook_Class);

        string sFile = GetNSBDefinitionFileName(nClass);

        int i;
        for(i = 0; i < nSpells_Total; i++)
        {
          // get the nSpellbookID (= row nr in the cls_spell_* file) out of the class spellbook and determine the associated feat
          int nSpellbookID = persistant_array_get_int(oPC, sSpellBook_Class, i);
          int nFeatID = StringToInt(Get2DACache(sFile, "FeatID", nSpellbookID));

          // only if oPC doesn't have the feat, she doesn have the spell
          if (!GetHasFeat(nFeatID, oPC))
            LearnSpecificSpell(nClass, nSpellLevel, nSpellbookID, oPC);
        }
      }

      nStage = STAGE_SELECT_LEVEL;
    }
    else if(nStage == STAGE_ADVLEARN_LEVEL)
    {
      // remember the spell level at which to learn the new spell and proceed to the spell selection phase
      SetLocalInt(oPC, SPELLGAIN_CONV_LEVEL, nChoice);
      nStage = STAGE_ADVLEARN_SPELL;
    }
    else if(nStage == STAGE_ADVLEARN_SPELL)
    {
      if(nChoice == CHOICE_RETURN_TO_PREVIOUS)
           nStage = STAGE_ADVLEARN_LEVEL;
      else
      {
          SetLocalInt(oPC, SPELLGAIN_CONV_SPELL, nChoice);
          nStage = STAGE_ADVLEARN_CONFIRM;
      }
    }
    else if(nStage == STAGE_ADVLEARN_CONFIRM)
    {
      // If this really is the new spell we want to learn:
      if(nChoice == TRUE)
      {
        // get the new spell's nSpellbookID and nSpellLevel
        int nSpellbookID = GetLocalInt(oPC, SPELLGAIN_CONV_SPELL);
        int nSpellLevel  = GetLocalInt(oPC, SPELLGAIN_CONV_LEVEL);

        LearnSpecificSpell(nClass, nSpellLevel, nSpellbookID, oPC);

        DeleteLocalInt(oPC, "AdvancedLearning");
        int nAdvLearn = GetPersistantLocalInt(oPC, "AdvancedLearning_"+IntToString(nClass));
        nAdvLearn++;
        SetPersistantLocalInt(oPC, "AdvancedLearning_"+IntToString(nClass), nAdvLearn);
      }

      nStage = STAGE_ADVLEARN_LEVEL;
    }

    MarkStageNotSetUp(nStage, oPC);
    // Store the stage value. If it has been changed, this clears out the choices
    SetStage(nStage, oPC);
  }
}
