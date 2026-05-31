
int GetFeatForSeed(int nSeedID);
int GetIPForSeed(int nSeedID);
int GetDCForSeed(int nSeedID);
int GetClassForSeed(int nSeedID);
int GetCanLearnSeed(object oPC, int nSeedID);
int GetSeedFromAbrev(string sAbrev);
string GetNameForSeed(int nSeedID);

int GetDCForSpell(int nSpellID);
int GetFeatForSpell(int nSpellID);
int GetResearchFeatForSpell(int nSpellID);
int GetIPForSpell(int nSpellID);
int GetResearchIPForSpell(int nSpellID);
int GetCastXPForSpell(int nSpellID);
string GetSchoolForSpell(int nSpellID);
int GetR1ForSpell(int nSpellID);
int GetR2ForSpell(int nSpellID);
int GetR3ForSpell(int nSpellID);
int GetR4ForSpell(int nSpellID);
string GetNameForSpell(int nSpellID);
int GetSpellFromAbrev(string sAbrev);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "inc_utility"
#include "inc_epicspells"

// SEED FUNCTIONS

int GetFeatForSeed(int nSeedID)
{
    return StringToInt(Get2DACache("epicspellseeds", "FeatID", nSeedID));
}

int GetIPForSeed(int nSeedID)
{
    return StringToInt(Get2DACache("epicspellseeds", "FeatIPID", nSeedID));
}

int GetDCForSeed(int nSeedID)
{
    return StringToInt(Get2DACache("epicspellseeds", "DC", nSeedID));
}

int GetClassForSeed(int nSeedID)
{
    return StringToInt(Get2DACache("epicspellseeds", "Class", nSeedID));
}

int GetSeedFromAbrev(string sAbrev)
{
    sAbrev = GetStringLowerCase(sAbrev);
    if(GetStringLeft(sAbrev, 8) == "epic_sd_")
        sAbrev = GetStringRight(sAbrev, GetStringLength(sAbrev)-8);
    int i = 0;
    string sLabel = GetStringLowerCase(Get2DACache("epicspellseeds", "LABEL", i));
    while(sLabel != "")
    {
        if(sAbrev == sLabel)
            return i;
        i++;
        sLabel = GetStringLowerCase(Get2DACache("epicspellseeds", "LABEL", i));
    }
    return -1;
}

string GetNameForSeed(int nSeedID)
{
    int nFeat = GetFeatForSeed(nSeedID);
    string sName = GetStringByStrRef(StringToInt(Get2DACache("feat", "FEAT", nFeat)));
    return sName;
}

/*
Bit-flags set in epicspellseeds.2da in Class column
used to restrict access to epic spell seeds for some classes
ie: 13 means that only clerics, sorcerers and wizards can learn that seed (1 + 4 + 8),
all classes can use == 32767
*/
int _Class2BitFlag(int nClass)
{
    switch(nClass)
    {
        case CLASS_TYPE_CLERIC:            return     1;
        case CLASS_TYPE_DRUID:             return     2;
        case CLASS_TYPE_SORCERER:          return     4;
        case CLASS_TYPE_WIZARD:            return     8;
        case CLASS_TYPE_HEALER:            return    16;
        case CLASS_TYPE_BEGUILER:          return    32;
        case CLASS_TYPE_SUBLIME_CHORD:     return    64;
        case CLASS_TYPE_DREAD_NECROMANCER: return   128;
        case CLASS_TYPE_MYSTIC:            return   256;
        case CLASS_TYPE_ARCHIVIST:         return   512;
        case CLASS_TYPE_SHAMAN:            return  4096;
        case CLASS_TYPE_FAVOURED_SOUL:     return  8192;
        case CLASS_TYPE_WARMAGE:           return 16384;
        case CLASS_TYPE_UR_PRIEST:         return     1;
        case CLASS_TYPE_BLIGHTER:          return     2;
    }
    return -1;
}

int _CheckEpicSpellcastingForClass(object oPC, int nClass)
{
    if(GetHitDice(oPC) < 21)
        return FALSE;

    switch(nClass)
    {
        case CLASS_TYPE_CLERIC:            return GetIsEpicCleric(oPC);
        case CLASS_TYPE_DRUID:             return GetIsEpicDruid(oPC);
        case CLASS_TYPE_SORCERER:          return GetIsEpicSorcerer(oPC);
        case CLASS_TYPE_WIZARD:            return GetIsEpicWizard(oPC);
        case CLASS_TYPE_HEALER:            return GetIsEpicHealer(oPC);
        case CLASS_TYPE_BEGUILER:          return GetIsEpicBeguiler(oPC);
        case CLASS_TYPE_SUBLIME_CHORD:     return GetIsEpicSublimeChord(oPC);
        case CLASS_TYPE_DREAD_NECROMANCER: return GetIsEpicDreadNecromancer(oPC);
        case CLASS_TYPE_ARCHIVIST:         return GetIsEpicArchivist(oPC);
        case CLASS_TYPE_SHAMAN:            return GetIsEpicShaman(oPC);
        case CLASS_TYPE_FAVOURED_SOUL:     return GetIsEpicFavSoul(oPC);
        case CLASS_TYPE_WARMAGE:           return GetIsEpicWarmage(oPC);
        case CLASS_TYPE_BLIGHTER:          return GetIsEpicBlighter(oPC);
        case CLASS_TYPE_UR_PRIEST:         return GetIsEpicUrPriest(oPC);
    }
    return FALSE;
}

int GetCanLearnSeed(object oPC, int nSeedID)
{
    int nRestr = GetClassForSeed(nSeedID);
    int i, nClass;
    for(i = 1; i <= 8; i++)
    {
        nClass = GetClassByPosition(i, oPC);
        if(_CheckEpicSpellcastingForClass(oPC, nClass)//this class has epic spellcasting
        && (nRestr & _Class2BitFlag(nClass)))//and was added to class column in epicspellseeds.2da
        {
            return TRUE;
        }
    }
    return FALSE;
}

// SPELL FUNCTIONS

int GetDCForSpell(int nSpellID)
{
    return StringToInt(Get2DACache("epicspells", "DC", nSpellID));
}

int GetFeatForSpell(int nSpellID)
{
    return StringToInt(Get2DACache("epicspells", "SpellFeatID", nSpellID));
}

int GetResearchFeatForSpell(int nSpellID)
{
    return StringToInt(Get2DACache("epicspells", "ResFeatID", nSpellID));
}

int GetIPForSpell(int nSpellID)
{
    return StringToInt(Get2DACache("epicspells", "SpellFeatIPID", nSpellID));
}

int GetResearchIPForSpell(int nSpellID)
{
    return StringToInt(Get2DACache("epicspells", "ResFeatIPID", nSpellID));
}

int GetCastXPForSpell(int nSpellID)
{
    return StringToInt(Get2DACache("epicspells", "CastingXP", nSpellID));
}

string GetSchoolForSpell(int nSpellID)
{
    return Get2DACache("epicspells", "School", nSpellID);
}

int GetR1ForSpell(int nSpellID)
{
    return StringToInt(Get2DACache("epicspells", "Prereq1", nSpellID));
}

int GetR2ForSpell(int nSpellID)
{
    return StringToInt(Get2DACache("epicspells", "Prereq2", nSpellID));
}

int GetR3ForSpell(int nSpellID)
{
    return StringToInt(Get2DACache("epicspells", "Prereq3", nSpellID));
}

int GetR4ForSpell(int nSpellID)
{
    return StringToInt(Get2DACache("epicspells", "Prereq4", nSpellID));
}

int GetS1ForSpell(int nSpellID)
{
    string sSeed = Get2DACache("epicspells", "PrereqSeed1", nSpellID);
    if(sSeed == "")
        return -1;
    return StringToInt(sSeed);
}

int GetS2ForSpell(int nSpellID)
{
    string sSeed = Get2DACache("epicspells", "PrereqSeed2", nSpellID);
    if(sSeed == "")
        return -1;
    return StringToInt(sSeed);
}

int GetS3ForSpell(int nSpellID)
{
    string sSeed = Get2DACache("epicspells", "PrereqSeed3", nSpellID);
    if(sSeed == "")
        return -1;
    return StringToInt(sSeed);
}

int GetS4ForSpell(int nSpellID)
{
    string sSeed = Get2DACache("epicspells", "PrereqSeed4", nSpellID);
    if(sSeed == "")
        return -1;
    return StringToInt(sSeed);
}

int GetS5ForSpell(int nSpellID)
{
    string sSeed = Get2DACache("epicspells", "PrereqSeed5", nSpellID);
    if(sSeed == "")
        return -1;
    return StringToInt(sSeed);
}

int GetSpellFromAbrev(string sAbrev)
{
    sAbrev = GetStringLowerCase(sAbrev);
    if(GetStringLeft(sAbrev, 8) == "epic_sp_")
        sAbrev = GetStringRight(sAbrev, GetStringLength(sAbrev)-8);
    if(DEBUG) DoDebug("sAbrev to check vs: " + sAbrev);
    int i = 0;
    string sLabel = GetStringLowerCase(Get2DACache("epicspells", "LABEL", i));
    while(sLabel != "")
    {
        if(DEBUG) DoDebug("sLabel to check vs: " + sLabel);
        if(sAbrev == sLabel)
        {
            if(DEBUG) DoDebug("SpellID: " + IntToString(i));
            return i;
        }
        i++;
        sLabel = GetStringLowerCase(Get2DACache("epicspells", "LABEL", i));
    }
    return -1;
}

string GetNameForSpell(int nSpellID)
{
    int nFeat = GetFeatForSpell(nSpellID);
    string sName = GetStringByStrRef(StringToInt(Get2DACache("feat", "FEAT", nFeat)));
    return sName;
}

//:: void main (){}