//::///////////////////////////////////////////////
//:: Astral Construct manifestation include
//:: psi_inc_ac_manif
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Ornedan
//:: Created On: 23.01.2005
//:://////////////////////////////////////////////

#include "prc_inc_spells"
#include "psi_inc_psifunc"
#include "psi_inc_ac_const"
#include "inc_utility"


//////////////////////////////////////////////////
/* Constant defintions                          */
//////////////////////////////////////////////////

const int TEMP_HENCH_COUNT = 150;


//////////////////////////////////////////////////
/* Structure definitions                        */
//////////////////////////////////////////////////

// A structure containing appearance references
struct ac_forms{
        int Appearance1, Appearance1Alt;
        int Appearance2, Appearance2Alt;
        int Appearance3, Appearance3Alt;
        int Appearance4, Appearance4Alt;
};

//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

void DoAstralConstructCreation(struct manifestation manif, location locTarget, int nACLevel,
                               int nOptionFlags, int nResElemFlags, int nETchElemFlags, int nEBltElemFlags);

void DoDespawn(object oConstruct, int bDoVFX = TRUE);
void DoDespawnAux(object oManifester, float fDur);
void DoSummonVFX(location locTarget, int nACLevel);
void DoUnsummonVFX(location locTarget, int nACLevel);

struct ac_forms GetAppearancessForLevel(int nLevel);
int GetAppearanceForConstruct(int nACLevel, int nOptionFlags, int nCheck);
int GetUseAltAppearances(int nOptionFlags);
string GetResRefForConstruct(int nACLevel, int nOptionFlags);
int GetHighestCraftSkillValue(object oCreature);


//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

// Summons the specified Astral Construct at the given location
// Handling of the flags (other than the Buff series) is done
// in the creature's OnSpawn eventscript
void DoAstralConstructCreation(struct manifestation manif, location locTarget, int nACLevel,
                               int nOptionFlags, int nResElemFlags, int nETchElemFlags, int nEBltElemFlags)
{
    // Get the resref for the AC
    string sResRef = GetResRefForConstruct(nACLevel, nOptionFlags);

    // Get the constructs duration. 1 round / level. Metapsionic Extend can be applied.
    float fDur = 6.0 * GetManifesterLevel(manif.oManifester);
    if(GetPRCSwitch(PRC_PSI_ASTRAL_CONSTRUCT_DUR_MOD) > 0)
        fDur *= GetPRCSwitch(PRC_PSI_ASTRAL_CONSTRUCT_DUR_MOD);
    if(manif.bExtend)
        fDur *= 2;

    // Add in 1 round of duration to account for AI disorientation in the beginning
    fDur += 6.0f;

    /* Until Bioware "fixes" Jasperre's multisummon trick, AC are added as genuine summons instead of henchies
    // We need to make sure that we can add the new construct as henchman
    int nMaxHenchmen = GetMaxHenchmen();
    SetMaxHenchmen(TEMP_HENCH_COUNT);

    // Add the AC as henchman
    object oConstruct = CreateObject(OBJECT_TYPE_CREATURE, sResRef, locTarget);
    AddHenchman(oManifester, oConstruct);

    // And set the max henchmen count back to original, so we won't mess up the module
    SetMaxHenchmen(nMaxHenchmen);

    */


    // Do multisummon trick
    int bMultisummon = GetPRCSwitch(PRC_MULTISUMMON);
    int i = 1;
    object oCheck = GetAssociate(ASSOCIATE_TYPE_SUMMONED, manif.oManifester, i);
    while(GetIsObjectValid(oCheck))
    {
        //DoDebug("DoAstralConstructCreation: Handling associate " + DebugObject2Str(oCheck));
        // If multisummon is active, make all summons indestructible. If not, only make astral constructs
        if(bMultisummon || GetStringLeft(GetTag(oCheck), 14) == "psi_astral_con")
        {
            AssignCommand(oCheck, SetIsDestroyable(FALSE, FALSE, FALSE));
            AssignCommand(oCheck, DelayCommand(1.0, SetIsDestroyable(TRUE, FALSE, FALSE)));
            oCheck = GetAssociate(ASSOCIATE_TYPE_SUMMONED, manif.oManifester, ++i);
        }
    }

    // Do actual summon effect
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectSummonCreature(sResRef), locTarget, fDur + 0.5);

    /* For use if need to return to henchman setup

    // Add the locals to the construct
    SetLocalInt(oConstruct, ASTRAL_CONSTRUCT_LEVEL,              nACLevel);
    SetLocalInt(oConstruct, ASTRAL_CONSTRUCT_OPTION_FLAGS,       nOptionFlags);
    SetLocalInt(oConstruct, ASTRAL_CONSTRUCT_RESISTANCE_FLAGS,   nResElemFlags);
    SetLocalInt(oConstruct, ASTRAL_CONSTRUCT_ENERGY_TOUCH_FLAGS, nETchElemFlags);
    SetLocalInt(oConstruct, ASTRAL_CONSTRUCT_ENERGY_BOLT_FLAGS,  nEBltElemFlags);


    // Do appearance switching
    int nCraft = GetHighestCraftSkillValue(oManifester);
    int nCheck = d20() + nCraft;

    int nAppearance = GetAppearanceForConstruct(nACLevel, nOptionFlags, nCheck);
    SetCreatureAppearanceType(oConstruct, nAppearance);
    */

    // Do VFX
    DoSummonVFX(locTarget, nACLevel);

    // Schedule unsummoning. No need to hurry this one, so give it a larger delay
    // in order to avoid hogging too much resources over a short span of time.
    DelayCommand(2.0, DoDespawnAux(manif.oManifester, fDur));
}


// A function to handle the AC's duration running out
// Some paranoia present to make sure nothing could accidentally
// make it permanent
void DoDespawn(object oConstruct, int bDoVFX = TRUE)
{
    if(GetIsObjectValid(oConstruct)){
        DestroyObject(oConstruct);
        DelayCommand(0.15f, MyDestroyObject(oConstruct)); // The paranoia bit :D
        if(bDoVFX) DoUnsummonVFX(GetLocation(oConstruct), GetLocalInt(oConstruct, ASTRAL_CONSTRUCT_LEVEL));
    }
}

// An auxiliary to be delayed so that a reference to the just created AC can be found
void DoDespawnAux(object oManifester, float fDur){
    // Find the newly added construct
    object oConstruct = OBJECT_INVALID;
    int i = 1;
    object oCheck = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oManifester, i);
    while(GetIsObjectValid(oCheck))
    {
        if(!GetLocalInt(oCheck, "UnsummonScheduled") && GetStringLeft(GetTag(oCheck), 14) == "psi_astral_con")
        {
            oConstruct = oCheck;
            break;
        }
        i++;
        oCheck = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oManifester, i);
    }
    SetLocalInt(oConstruct, "UnsummonScheduled", TRUE);

    if(DEBUG) DoDebug("Found the just added astral construct: " + (GetIsObjectValid(oConstruct) ? "true":"false") + "\nSummon name: " + GetName(oConstruct) + "\nTotal summons: " + IntToString(i), oManifester);

    // Schedule unsummoning. Done this way to skip the default unsummoning VFX.
    DelayCommand(fDur - 2.0, DoDespawn(oConstruct));
}

// Does a visual choreography that depends on the level of the construct being created.
// Higher level constructs get neater VFX :D
void DoSummonVFX(location locTarget, int nACLevel){
    DrawSpiral(0, 263, locTarget, IntToFloat(nACLevel) * 0.75 + 0.5, 0.4, 1.0, 60, 16.899999619, 3.0, 4.0);
}

void DoUnsummonVFX(location locTarget, int nACLevel){
    DrawSpiral(0, 263, locTarget, 0.4, IntToFloat(nACLevel) * 0.75 + 0.5, 1.0, 60, 16.899999619, 3.0, 4.0);
}


struct ac_forms GetAppearancesForLevel(int nLevel)
{
    struct ac_forms toReturn;

    switch(nLevel)
    {
        case 1:
            toReturn.Appearance1     = APPEARANCE_TYPE_RAT;
            toReturn.Appearance1Alt  = 387; //Dire Rat

            toReturn.Appearance2     = APPEARANCE_TYPE_INTELLECT_DEVOURER;
            toReturn.Appearance2Alt  = APPEARANCE_TYPE_WAR_DEVOURER;

            toReturn.Appearance3     = APPEARANCE_TYPE_PSEUDODRAGON;
            toReturn.Appearance3Alt  = APPEARANCE_TYPE_PSEUDODRAGON;

            toReturn.Appearance4     = APPEARANCE_TYPE_FAERIE_DRAGON;
            toReturn.Appearance4Alt  = APPEARANCE_TYPE_FAERIE_DRAGON;

            return toReturn;
        case 2:
            toReturn.Appearance1     = APPEARANCE_TYPE_GARGOYLE;
            toReturn.Appearance1Alt  = APPEARANCE_TYPE_GARGOYLE;

            toReturn.Appearance2     = APPEARANCE_TYPE_BAT_HORROR;
            toReturn.Appearance2Alt  = APPEARANCE_TYPE_HELMED_HORROR;

            toReturn.Appearance3     = APPEARANCE_TYPE_ASABI_WARRIOR;
            toReturn.Appearance3Alt  = APPEARANCE_TYPE_LIZARDFOLK_WARRIOR_B;

            toReturn.Appearance4     = APPEARANCE_TYPE_WERECAT;
            toReturn.Appearance4Alt  = APPEARANCE_TYPE_WERECAT;

            return toReturn;
        case 3:
            toReturn.Appearance1     = APPEARANCE_TYPE_FORMIAN_WORKER;
            toReturn.Appearance1Alt  = APPEARANCE_TYPE_FORMIAN_WORKER;

            toReturn.Appearance2     = APPEARANCE_TYPE_FORMIAN_WARRIOR;
            toReturn.Appearance2Alt  = APPEARANCE_TYPE_FORMIAN_WARRIOR;

            toReturn.Appearance3     = APPEARANCE_TYPE_FORMIAN_MYRMARCH;
            toReturn.Appearance3Alt  = APPEARANCE_TYPE_FORMIAN_MYRMARCH;

            toReturn.Appearance4     = APPEARANCE_TYPE_FORMIAN_QUEEN;
            toReturn.Appearance4Alt  = APPEARANCE_TYPE_FORMIAN_QUEEN;

            return toReturn;
        case 4:
            toReturn.Appearance1     = 416; // Deep Rothe
            toReturn.Appearance1Alt  = 416;

            toReturn.Appearance2     = APPEARANCE_TYPE_MANTICORE;
            toReturn.Appearance2Alt  = APPEARANCE_TYPE_MANTICORE;

            toReturn.Appearance3     = APPEARANCE_TYPE_BASILISK;
            toReturn.Appearance3Alt  = APPEARANCE_TYPE_GORGON;

            toReturn.Appearance4     = APPEARANCE_TYPE_DEVIL;
            toReturn.Appearance4Alt  = 468; // Golem, Demonflesh

            return toReturn;
        case 5:
            toReturn.Appearance1     = APPEARANCE_TYPE_GOLEM_FLESH;
            toReturn.Appearance1Alt  = APPEARANCE_TYPE_GOLEM_FLESH;

            toReturn.Appearance2     = APPEARANCE_TYPE_GOLEM_STONE;
            toReturn.Appearance2Alt  = APPEARANCE_TYPE_GOLEM_STONE;

            toReturn.Appearance3     = APPEARANCE_TYPE_GOLEM_CLAY;
            toReturn.Appearance3Alt  = APPEARANCE_TYPE_GOLEM_CLAY;

            toReturn.Appearance4     = 420; // Golem, Mithril
            toReturn.Appearance4Alt  = 420;

            return toReturn;
        case 6:
            toReturn.Appearance1     = APPEARANCE_TYPE_TROLL;
            toReturn.Appearance1Alt  = APPEARANCE_TYPE_TROLL;

            toReturn.Appearance2     = APPEARANCE_TYPE_ETTERCAP;
            toReturn.Appearance2Alt  = APPEARANCE_TYPE_ETTERCAP;

            toReturn.Appearance3     = APPEARANCE_TYPE_UMBERHULK;
            toReturn.Appearance3Alt  = APPEARANCE_TYPE_UMBERHULK;

            toReturn.Appearance4     = APPEARANCE_TYPE_MINOTAUR_SHAMAN;
            toReturn.Appearance4Alt  = APPEARANCE_TYPE_MINOGON;

            return toReturn;
        case 7:
            toReturn.Appearance1     = APPEARANCE_TYPE_SPIDER_DIRE;
            toReturn.Appearance1Alt  = APPEARANCE_TYPE_SPIDER_DIRE;

            toReturn.Appearance2     = APPEARANCE_TYPE_SPIDER_SWORD;
            toReturn.Appearance2Alt  = APPEARANCE_TYPE_SPIDER_SWORD;

            toReturn.Appearance3     = 446; // Drider, Female
            toReturn.Appearance3Alt  = 446;

            toReturn.Appearance4     = 407; // Drider, Chief
            toReturn.Appearance4Alt  = 407;

            return toReturn;
        case 8:
            toReturn.Appearance1     = APPEARANCE_TYPE_HOOK_HORROR;
            toReturn.Appearance1Alt  = APPEARANCE_TYPE_VROCK;

            toReturn.Appearance2     = 427; // Slaad, White
            toReturn.Appearance2Alt  = 427;

            toReturn.Appearance3     = APPEARANCE_TYPE_GREY_RENDER;
            toReturn.Appearance3Alt  = APPEARANCE_TYPE_GREY_RENDER;

            toReturn.Appearance4     = APPEARANCE_TYPE_GREY_RENDER;
            toReturn.Appearance4Alt  = APPEARANCE_TYPE_GREY_RENDER;

            return toReturn;
        case 9:
            toReturn.Appearance1     = APPEARANCE_TYPE_ELEMENTAL_AIR_ELDER;
            toReturn.Appearance1Alt  = APPEARANCE_TYPE_ELEMENTAL_AIR_ELDER;

            toReturn.Appearance2     = APPEARANCE_TYPE_GIANT_FROST_FEMALE;
            toReturn.Appearance2Alt  = APPEARANCE_TYPE_GIANT_FROST_FEMALE;

            toReturn.Appearance3     = 418; // Dragon, Shadow
            toReturn.Appearance3Alt  = 418;

            toReturn.Appearance4     = 471; // Mephisto, Normal
            toReturn.Appearance4Alt  = 471;

            return toReturn;

        default:{
            string sErr = "psi_inc_ac_manif: GetAppearancesForLevel(): ERROR: Erroneous value for nLevel: " + IntToString(nLevel);
            if(DEBUG) DoDebug(sErr);
            else      WriteTimestampedLogEntry(sErr);
        }
    }

    return toReturn;
}


int GetAppearanceForConstruct(int nACLevel, int nOptionFlags, int nCheck)
{
    int bUse2da = GetPRCSwitch(PRC_PSI_ASTRAL_CONSTRUCT_USE_2DA);
    int bUseAlt = GetUseAltAppearances(nOptionFlags);
    int nNum = nCheck < AC_APPEARANCE_CHECK_HIGH ?
                 nCheck < AC_APPEARANCE_CHECK_MEDIUM ?
                   nCheck < AC_APPEARANCE_CHECK_LOW ? 1
                   : 2
                 : 3
               : 4;
    // If we use 2da, get the data from there
    if(bUse2da)
    {
        nNum += (nACLevel - 1) * 4 - 1;

        return StringToInt(Get2DACache("ac_appearances", bUseAlt ? "AltAppearance" : "NormalAppearance", nNum));
    }

    // We don't so get it from GetAppearancesForLevel

    struct ac_forms appearancelist = GetAppearancesForLevel(nACLevel);

    switch(nNum)
    {
        case 1: return bUseAlt ? appearancelist.Appearance1Alt : appearancelist.Appearance1;
        case 2: return bUseAlt ? appearancelist.Appearance2Alt : appearancelist.Appearance2;
        case 3: return bUseAlt ? appearancelist.Appearance3Alt : appearancelist.Appearance3;
        case 4: return bUseAlt ? appearancelist.Appearance4Alt : appearancelist.Appearance4;

        default:{
            string sErr = "psi_inc_ac_manif: GetAppearanceForConstruct(): ERROR: Erroneous value for nNum: " + IntToString(nNum);
            if(DEBUG) DoDebug(sErr);
            else      WriteTimestampedLogEntry(sErr);
        }
    }

    return -1;
}


int GetUseAltAppearances(int nOptionFlags)
{          // Buff series
    return nOptionFlags & ASTRAL_CONSTRUCT_OPTION_BUFF            ||
           nOptionFlags & ASTRAL_CONSTRUCT_OPTION_IMP_BUFF        ||
           nOptionFlags & ASTRAL_CONSTRUCT_OPTION_EXTRA_BUFF      ||
           // Deflection series
           nOptionFlags & ASTRAL_CONSTRUCT_OPTION_DEFLECTION      ||
           nOptionFlags & ASTRAL_CONSTRUCT_OPTION_HEAVY_DEFLECT   ||
           nOptionFlags & ASTRAL_CONSTRUCT_OPTION_EXTREME_DEFLECT ||
           // Damage Reduction Series
           nOptionFlags & ASTRAL_CONSTRUCT_OPTION_IMP_DAM_RED     ||
           nOptionFlags & ASTRAL_CONSTRUCT_OPTION_EXTREME_DAM_RED;
}


string GetResRefForConstruct(int nACLevel, int nOptionFlags)
{
    string sResRef = "psi_astral_con" + IntToString(nACLevel);
    string sSuffix;

    // Check whether we need a resref with buff applied
    if(nOptionFlags & ASTRAL_CONSTRUCT_OPTION_BUFF)
        sSuffix += "a";
    else if(nOptionFlags & ASTRAL_CONSTRUCT_OPTION_IMP_BUFF)
        sSuffix += "b";
    else if(nOptionFlags & ASTRAL_CONSTRUCT_OPTION_EXTRA_BUFF)
        sSuffix += "c";

    return sResRef + sSuffix;
}


int GetHighestCraftSkillValue(object oCreature)
{
    int nArmor  = GetSkillRank(SKILL_CRAFT_ARMOR, oCreature);
    int nTrap   = GetSkillRank(SKILL_CRAFT_TRAP, oCreature);
    int nWeapon = GetSkillRank(SKILL_CRAFT_WEAPON, oCreature);

    return nArmor > nTrap ?
            nArmor > nWeapon ? nArmor : nWeapon
            : nTrap > nWeapon ? nTrap : nWeapon;
}
