//::///////////////////////////////////////////////
//:: 2da cache creation include
//:: inc_cache_setup
//::///////////////////////////////////////////////

/** @file
 *  Creation and setting up of 2da caching databases
 *  Functions moved from inc_2dacache
 *  Removed SQL caching using the module, removed
 *  ability to use bioDB or nwnDB as cache (this is
 *  slow for single gets).
 *
 * @author Primogenitor
 *  moved by fluffyamoeba 2008-4-23
 * @todo Document the constants and functions
 */
 
//////////////////////////////////////////////////
/* Include section                              */
//////////////////////////////////////////////////

#include "inc_2dacache"

//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

void Cache_Done()
{
    WriteTimestampedLogEntry("2da caching complete");
}

void Cache_Class_Feat(int nClass, int nRow = 0)
{
    string sFile = Get2DACache("classes", "FeatsTable", nClass);
    if(sFile != ""
        && sFile != "****"
        && nRow < GetPRCSwitch(FILE_END_CLASS_FEAT))
    {
        Get2DACache(sFile, "FeatLabel", nRow);
        Get2DACache(sFile, "FeatIndex", nRow);
        Get2DACache(sFile, "List", nRow);
        Get2DACache(sFile, "GrantedOnLevel", nRow);
        Get2DACache(sFile, "OnMenu", nRow);
        nRow++;
        DelayCommand(0.1, Cache_Class_Feat(nClass, nRow));
    }
    else
    {
        if(nClass == 254)
            Cache_Done();
        else
        {
            DelayCommand(0.1, Cache_Class_Feat(nClass+1)); //need to delay to prevent TMI
        }
    }
}

void Cache_Classes(int nRow = 0)
{
    if(nRow < GetPRCSwitch(FILE_END_CLASSES))
    {
        Get2DACache("classes", "Label", nRow);
        Get2DACache("classes", "Name", nRow);
        Get2DACache("classes", "Plural", nRow);
        Get2DACache("classes", "Lower", nRow);
        Get2DACache("classes", "Description", nRow);
        Get2DACache("classes", "Icon", nRow);
        Get2DACache("classes", "HitDie", nRow);
        Get2DACache("classes", "AttackBonusTable", nRow);
        Get2DACache("classes", "FeatsTable", nRow);
        Get2DACache("classes", "SavingThrowTable", nRow);
        Get2DACache("classes", "SkillsTable", nRow);
        Get2DACache("classes", "BonusFeatsTable", nRow);
        Get2DACache("classes", "SkillPointBase", nRow);
        Get2DACache("classes", "SpellGainTable", nRow);
        Get2DACache("classes", "SpellKnownTable", nRow);
        Get2DACache("classes", "PlayerClass", nRow);
        Get2DACache("classes", "SpellCaster", nRow);
        Get2DACache("classes", "Str", nRow);
        Get2DACache("classes", "Dex", nRow);
        Get2DACache("classes", "Con", nRow);
        Get2DACache("classes", "Wis", nRow);
        Get2DACache("classes", "Int", nRow);
        Get2DACache("classes", "Cha", nRow);
        Get2DACache("classes", "PrimaryAbil", nRow);
        Get2DACache("classes", "AlignRestrict", nRow);
        Get2DACache("classes", "AlignRstrctType", nRow);
        Get2DACache("classes", "InvertRestrict", nRow);
        Get2DACache("classes", "Constant", nRow);
        Get2DACache("classes", "EffCRLvl01", nRow);
        Get2DACache("classes", "EffCRLvl02", nRow);
        Get2DACache("classes", "EffCRLvl03", nRow);
        Get2DACache("classes", "EffCRLvl04", nRow);
        Get2DACache("classes", "EffCRLvl05", nRow);
        Get2DACache("classes", "EffCRLvl06", nRow);
        Get2DACache("classes", "EffCRLvl07", nRow);
        Get2DACache("classes", "EffCRLvl08", nRow);
        Get2DACache("classes", "EffCRLvl09", nRow);
        Get2DACache("classes", "EffCRLvl10", nRow);
        Get2DACache("classes", "EffCRLvl12", nRow);
        Get2DACache("classes", "EffCRLvl13", nRow);
        Get2DACache("classes", "EffCRLvl14", nRow);
        Get2DACache("classes", "EffCRLvl15", nRow);
        Get2DACache("classes", "EffCRLvl16", nRow);
        Get2DACache("classes", "EffCRLvl17", nRow);
        Get2DACache("classes", "EffCRLvl18", nRow);
        Get2DACache("classes", "EffCRLvl19", nRow);
        Get2DACache("classes", "EffCRLvl20", nRow);
        Get2DACache("classes", "PreReqTable", nRow);
        Get2DACache("classes", "MaxLevel", nRow);
        Get2DACache("classes", "XPPenalty", nRow);
        Get2DACache("classes", "ArcSpellLvlMod", nRow);
        Get2DACache("classes", "DivSpellLvlMod", nRow);
        Get2DACache("classes", "EpicLevel", nRow);
        Get2DACache("classes", "Package", nRow);
        nRow++;
        DelayCommand(0.1, Cache_Classes(nRow));
    }
    else
        DelayCommand(1.0, Cache_Class_Feat(0));
}

void Cache_RacialTypes(int nRow = 0)
{
    if(nRow < GetPRCSwitch(FILE_END_RACIALTYPES))
    {
        Get2DACache("racialtypes", "Label", nRow);
        Get2DACache("racialtypes", "Abrev", nRow);
        Get2DACache("racialtypes", "Name", nRow);
        Get2DACache("racialtypes", "ConverName", nRow);
        Get2DACache("racialtypes", "ConverNameLower", nRow);
        Get2DACache("racialtypes", "NamePlural", nRow);
        Get2DACache("racialtypes", "Description", nRow);
        Get2DACache("racialtypes", "Appearance", nRow);
        Get2DACache("racialtypes", "StrAdjust", nRow);
        Get2DACache("racialtypes", "DexAdjust", nRow);
        Get2DACache("racialtypes", "IntAdjust", nRow);
        Get2DACache("racialtypes", "ChaAdjust", nRow);
        Get2DACache("racialtypes", "WisAdjust", nRow);
        Get2DACache("racialtypes", "ConAdjust", nRow);
        Get2DACache("racialtypes", "Endurance", nRow);
        Get2DACache("racialtypes", "Favored", nRow);
        Get2DACache("racialtypes", "FeatsTable", nRow);
        Get2DACache("racialtypes", "Biography", nRow);
        Get2DACache("racialtypes", "PlayerRace", nRow);
        Get2DACache("racialtypes", "Constant", nRow);
        Get2DACache("racialtypes", "AGE", nRow);
        Get2DACache("racialtypes", "ToolsetDefaultClass", nRow);
        Get2DACache("racialtypes", "CRModifier", nRow);

        nRow++;
        DelayCommand(0.1, Cache_RacialTypes(nRow));
    }
    else
        DelayCommand(1.0, Cache_Classes(0));
}


void Cache_Feat(int nRow = 0)
{
    if(nRow < GetPRCSwitch(FILE_END_FEAT))
    {
        Get2DACache("feat", "LABEL", nRow);
        Get2DACache("feat", "FEAT", nRow);
        Get2DACache("feat", "DESCRIPTION", nRow);
        Get2DACache("feat", "MINATTACKBONUS", nRow);
        Get2DACache("feat", "MINSTR", nRow);
        Get2DACache("feat", "MINDEX", nRow);
        Get2DACache("feat", "MININT", nRow);
        Get2DACache("feat", "MINWIS", nRow);
        Get2DACache("feat", "MINCON", nRow);
        Get2DACache("feat", "MINCHA", nRow);
        Get2DACache("feat", "MINSPELLLVL", nRow);
        Get2DACache("feat", "PREREQFEAT1", nRow);
        Get2DACache("feat", "PREREQFEAT2", nRow);
        Get2DACache("feat", "GAINMULTIPLE", nRow);
        Get2DACache("feat", "EFFECTSSTACK", nRow);
        Get2DACache("feat", "ALLCLASSESCANUSE", nRow);
        Get2DACache("feat", "CATEGORY", nRow);
        Get2DACache("feat", "MAXCR", nRow);
        Get2DACache("feat", "SPELLID", nRow);
        Get2DACache("feat", "SUCCESSOR", nRow);
        Get2DACache("feat", "CRValue", nRow);
        Get2DACache("feat", "USESPERDAY", nRow);
        Get2DACache("feat", "MASTERFEAT", nRow);
        Get2DACache("feat", "TARGETSELF", nRow);
        Get2DACache("feat", "OrReqFeat0", nRow);
        Get2DACache("feat", "OrReqFeat1", nRow);
        Get2DACache("feat", "OrReqFeat2", nRow);
        Get2DACache("feat", "OrReqFeat3", nRow);
        Get2DACache("feat", "OrReqFeat4", nRow);
        Get2DACache("feat", "REQSKILL", nRow);
        Get2DACache("feat", "ReqSkillMinRanks", nRow);
        Get2DACache("feat", "REQSKILL2", nRow);
        Get2DACache("feat", "ReqSkillMinRanks2", nRow);
        Get2DACache("feat", "Constant", nRow);
        Get2DACache("feat", "TOOLSCATEGORIES", nRow);
        Get2DACache("feat", "HostileFeat", nRow);
        Get2DACache("feat", "MinLevel", nRow);
        Get2DACache("feat", "MinLevelClass", nRow);
        Get2DACache("feat", "MaxLevel", nRow);
        Get2DACache("feat", "MinFortSave", nRow);
        Get2DACache("feat", "PreReqEpic", nRow);
        Get2DACache("feat", "ReqAction", nRow);
        nRow++;
        DelayCommand(0.01, Cache_Feat(nRow));
    }
    else
        DelayCommand(1.0, Cache_RacialTypes());
}

void Cache_Spells(int nRow = 0)
{
    if(nRow < GetPRCSwitch(FILE_END_SPELLS))
    {
        Get2DACache("spells", "Label", nRow);
        Get2DACache("spells", "Name", nRow);
        Get2DACache("spells", "IconResRef", nRow);
        Get2DACache("spells", "School", nRow);
        Get2DACache("spells", "Range", nRow);
        Get2DACache("spells", "VS", nRow);
        Get2DACache("spells", "MetaMagic", nRow);
        Get2DACache("spells", "TargetType", nRow);
        Get2DACache("spells", "ImpactScript", nRow);
        Get2DACache("spells", "Bard", nRow);
        Get2DACache("spells", "Cleric", nRow);
        Get2DACache("spells", "Druid", nRow);
        Get2DACache("spells", "Paladin", nRow);
        Get2DACache("spells", "Ranger", nRow);
        Get2DACache("spells", "Wiz_Sorc", nRow);
        Get2DACache("spells", "Innate", nRow);
        Get2DACache("spells", "ConjTime", nRow);
        Get2DACache("spells", "ConjAnim", nRow);
        Get2DACache("spells", "ConjHeadVisual", nRow);
        Get2DACache("spells", "ConjHandVisual", nRow);
        Get2DACache("spells", "ConjGrndVisual", nRow);
        Get2DACache("spells", "ConjSoundVFX", nRow);
        Get2DACache("spells", "ConjSoundMale", nRow);
        Get2DACache("spells", "ConjSoundFemale", nRow);
        Get2DACache("spells", "CastAnim", nRow);
        Get2DACache("spells", "CastTime", nRow);
        Get2DACache("spells", "CastHeadVisual", nRow);
        Get2DACache("spells", "CastHandVisual", nRow);
        Get2DACache("spells", "CastGrndVisual", nRow);
        Get2DACache("spells", "CastSound", nRow);
        Get2DACache("spells", "Proj", nRow);
        Get2DACache("spells", "ProjModel", nRow);
        Get2DACache("spells", "ProjType", nRow);
        Get2DACache("spells", "ProjSpwnPoint", nRow);
        Get2DACache("spells", "ProjSound", nRow);
        Get2DACache("spells", "ProjOrientation", nRow);
        Get2DACache("spells", "ImmunityType", nRow);
        Get2DACache("spells", "ItemImmunity", nRow);
        Get2DACache("spells", "SubRadSpell1", nRow);
        Get2DACache("spells", "SubRadSpell2", nRow);
        Get2DACache("spells", "SubRadSpell3", nRow);
        Get2DACache("spells", "SubRadSpell4", nRow);
        Get2DACache("spells", "SubRadSpell5", nRow);
        Get2DACache("spells", "Category", nRow);
        Get2DACache("spells", "Master", nRow);
        Get2DACache("spells", "UserType", nRow);
        Get2DACache("spells", "SpellDesc", nRow);
        Get2DACache("spells", "UseConcentration", nRow);
        Get2DACache("spells", "SpontaneouslyCast", nRow);
        Get2DACache("spells", "AltMessage", nRow);
        Get2DACache("spells", "HostileSetting", nRow);
        Get2DACache("spells", "FeatID", nRow);
        Get2DACache("spells", "Counter1", nRow);
        Get2DACache("spells", "Counter2", nRow);
        Get2DACache("spells", "HasProjectile", nRow);
        nRow++;
        DelayCommand(0.01, Cache_Spells(nRow));
    }
    else
        DelayCommand(0.1, Cache_Feat());
}

void Cache_Portraits(int nRow = 0)
{
    if(nRow < GetPRCSwitch(FILE_END_PORTRAITS))
    {
        Get2DACache("portraits", "BaseResRef", nRow);
        Get2DACache("portraits", "Sex", nRow);
        Get2DACache("portraits", "Race", nRow);
        Get2DACache("portraits", "InanimateType", nRow);
        Get2DACache("portraits", "Plot", nRow);
        Get2DACache("portraits", "LowGore", nRow);
        nRow++;
        DelayCommand(0.1, Cache_Portraits(nRow));
    }
    else
        DelayCommand(1.0, Cache_Spells());
}

void Cache_Soundset(int nRow = 0)
{
    if(nRow < GetPRCSwitch(FILE_END_SOUNDSET))
    {
        Get2DACache("soundset", "LABEL", nRow);
        Get2DACache("soundset", "RESREF", nRow);
        Get2DACache("soundset", "STRREF", nRow);
        Get2DACache("soundset", "GENDER", nRow);
        Get2DACache("soundset", "TYPE", nRow);
        nRow++;
        DelayCommand(0.1, Cache_Soundset(nRow));
    }
    else
        DelayCommand(1.0, Cache_Portraits());
}

void Cache_Appearance(int nRow = 0)
{
    if(nRow < GetPRCSwitch(FILE_END_APPEARANCE))
    {
        Get2DACache("appearance", "LABEL", nRow);
        Get2DACache("appearance", "STRING_REF", nRow);
        Get2DACache("appearance", "NAME", nRow);
        Get2DACache("appearance", "RACE", nRow);
        Get2DACache("appearance", "ENVMAP", nRow);
        Get2DACache("appearance", "BLOODCOLR", nRow);
        Get2DACache("appearance", "MODELTYPE", nRow);
        Get2DACache("appearance", "WEAPONSCALE", nRow);
        Get2DACache("appearance", "WING_TAIL_SCALE", nRow);
        Get2DACache("appearance", "HELMET_SCALE_M", nRow);
        Get2DACache("appearance", "HELMET_SCALE_F", nRow);
        Get2DACache("appearance", "MOVERATE", nRow);
        Get2DACache("appearance", "WALKDIST", nRow);
        Get2DACache("appearance", "RUNDIST", nRow);
        Get2DACache("appearance", "PERSPACE", nRow);
        Get2DACache("appearance", "CREPERSPACE", nRow);
        Get2DACache("appearance", "HEIGHT", nRow);
        Get2DACache("appearance", "HITDIST", nRow);
        Get2DACache("appearance", "PREFATCKDIST", nRow);
        Get2DACache("appearance", "TARGETHEIGHT", nRow);
        Get2DACache("appearance", "ABORTONPARRY", nRow);
        Get2DACache("appearance", "RACIALTYPE", nRow);
        Get2DACache("appearance", "HASLEGS", nRow);
        Get2DACache("appearance", "HASARMS", nRow);
        Get2DACache("appearance", "PORTRAIT", nRow);
        Get2DACache("appearance", "SIZECATEGORY", nRow);
        Get2DACache("appearance", "PERCEPTIONDIST", nRow);
        Get2DACache("appearance", "FOOTSTEPTYPE", nRow);
        Get2DACache("appearance", "SOUNDAPPTYPE", nRow);
        Get2DACache("appearance", "HEADTRACK", nRow);
        Get2DACache("appearance", "HEAD_ARC_H", nRow);
        Get2DACache("appearance", "HEAD_ARC_V", nRow);
        Get2DACache("appearance", "HEAD_NAME", nRow);
        Get2DACache("appearance", "BODY_BAG", nRow);
        Get2DACache("appearance", "TARGETABLE", nRow);
        nRow++;
        DelayCommand(0.1, Cache_Appearance(nRow));
    }
    else
        DelayCommand(1.0, Cache_Soundset());
}

void Cache_RacialAppear(int nRow = 0)  
{  
    if(nRow < GetPRCSwitch(FILE_END_RACIALAPPEAR))  
    {  
        Get2DACache("racialappear", "Label", nRow);  
        Get2DACache("racialappear", "Male1", nRow);  
        Get2DACache("racialappear", "Male2", nRow);  
        Get2DACache("racialappear", "Male3", nRow);  
        Get2DACache("racialappear", "Male4", nRow);  
        Get2DACache("racialappear", "Male5", nRow);  
        Get2DACache("racialappear", "Female1", nRow);  
        Get2DACache("racialappear", "Female2", nRow);  
        Get2DACache("racialappear", "Female3", nRow);  
        Get2DACache("racialappear", "Female4", nRow);  
        Get2DACache("racialappear", "Female5", nRow);  
        Get2DACache("racialappear", "Wing1", nRow);  
        Get2DACache("racialappear", "Wing2", nRow);  
        Get2DACache("racialappear", "Wing3", nRow);  
        Get2DACache("racialappear", "Tail1", nRow);  
        Get2DACache("racialappear", "Tail2", nRow);  
        Get2DACache("racialappear", "Tail3", nRow);  
          
        nRow++;  
        DelayCommand(0.1, Cache_RacialAppear(nRow));  
    }  
    else  
        DelayCommand(1.0, Cache_Appearance());  
}

void Cache_2da_data()
{
    Cache_Appearance();
	Cache_RacialAppear();
}

