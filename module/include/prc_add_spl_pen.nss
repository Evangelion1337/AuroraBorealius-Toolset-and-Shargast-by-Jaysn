//::///////////////////////////////////////////////
//:: Spells include: Spell Penetration
//:: prc_add_spl_pen
//::///////////////////////////////////////////////
/** @file
    Defines functions that may have something to do
    with modifying a spell's caster level in regards
    to Spell Resistance penetration.
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

int GetHeartWarderPene(int spell_id, object oCaster = OBJECT_SELF);

int ElementalSavantSP(int spell_id, object oCaster = OBJECT_SELF);

int RedWizardSP(int spell_id, int nSchool, object oCaster = OBJECT_SELF);

int GetSpellPenetreFocusSchool(int nSchool, object oCaster = OBJECT_SELF);

int GetSpellPowerBonus(object oCaster = OBJECT_SELF);

int ShadowWeavePen(int spell_id, int nSchool, object oCaster = OBJECT_SELF);

int KOTCSpellPenVsDemons(object oCaster, object oTarget);

int RunecasterRunePowerSP(object oCaster);

int MarshalDeterminedCaster(object oCaster);

int DuskbladeSpellPower(object oCaster, object oTarget);

int DraconicMagicPower(object oCaster);

int TrueCastingSpell(object oCaster);

string ChangedElementalType(int spell_id, object oCaster = OBJECT_SELF);

// Use this function to get the adjustments to a spell or SLAs spell penetration
// from the various class effects
// Update this function if any new classes change spell pentration
int add_spl_pen(object oCaster = OBJECT_SELF);

int SPGetPenetr(object oCaster = OBJECT_SELF);

int SPGetPenetrAOE(object oCaster = OBJECT_SELF, int nCasterLvl = 0);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "prc_inc_spells"
//#include "prc_alterations"
//#include "prcsp_archmaginc"
//#include "prc_inc_racial"
#include "inc_2dacache"

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

//
//  Determine if a spell type is elemental
//
int IsSpellTypeElemental(string type)
{
    return type == "Acid"
        || type == "Cold"
        || type == "Electricity"
        || type == "Fire"
        || type == "Sonic";
}

int GetHeartWarderPene(int spell_id, object oCaster = OBJECT_SELF)
{
    // Guard Expensive Calculations
    if(!GetHasFeat(FEAT_VOICE_SIREN, oCaster))
        return 0;

    // Bonus Requires Verbal Spells
    string VS = GetStringLowerCase(Get2DACache("spells", "VS", spell_id));
    if(FindSubString(VS, "v") == -1)
        return 0;

    // These feats provide greater bonuses or remove the Verbal requirement
    if(PRCGetMetaMagicFeat(oCaster, FALSE) & METAMAGIC_SILENT
    || GetHasFeat(FEAT_SPELL_PENETRATION, oCaster)
    || GetHasFeat(FEAT_GREATER_SPELL_PENETRATION, oCaster)
    || GetHasFeat(FEAT_EPIC_SPELL_PENETRATION, oCaster))
        return 0;

    return 2;
}

//
//  Calculate Elemental Savant Contributions
//
int ElementalSavantSP(int spell_id, object oCaster = OBJECT_SELF)
{
    // get spell elemental type
    int element = GetIsElementalSpell(spell_id);

    //not an elemental spell
    if(!element)
        return 0;

    int nSP = 0;

    // All Elemental Savants will have this feat
    // when they first gain a penetration bonus.
    // Otherwise this would require checking ~4 items (class or specific feats)
    if(GetHasFeat(FEAT_ES_PEN_1, oCaster))
    {
        int feat, nES;
        nES = GetLevelByClass(CLASS_TYPE_ELEMENTAL_SAVANT, oCaster);

        // Specify the elemental type rather than lookup by class?
        if(element & DESCRIPTOR_FIRE)
        {
            feat = FEAT_ES_FIRE;           
        }
        else if(element & DESCRIPTOR_COLD)
        {
            feat = FEAT_ES_COLD;
        }
        else if(element & DESCRIPTOR_ELECTRICITY)
        {
            feat = FEAT_ES_ELEC;
        }
        else if(element & DESCRIPTOR_ACID)
        {
            feat = FEAT_ES_ACID;
        }

        // Now determine the bonus
        if(feat && GetHasFeat(feat, oCaster))
            nSP = nES / 3;
    }
//  SendMessageToPC(GetFirstPC(), "Your Elemental Penetration modifier is " + IntToString(nSP));
    return nSP;
}

//Red Wizard SP boost based on spell school specialization
int RedWizardSP(int spell_id, int nSchool, object oCaster = OBJECT_SELF)
{
    int iRedWizard = GetLevelByClass(CLASS_TYPE_RED_WIZARD, oCaster);
    int nSP;

    if(iRedWizard)
    {
        int iRWSpec;
        switch(nSchool)
        {
            case SPELL_SCHOOL_ABJURATION:    iRWSpec = FEAT_RW_TF_ABJ; break;
            case SPELL_SCHOOL_CONJURATION:   iRWSpec = FEAT_RW_TF_CON; break;
            case SPELL_SCHOOL_DIVINATION:    iRWSpec = FEAT_RW_TF_DIV; break;
            case SPELL_SCHOOL_ENCHANTMENT:   iRWSpec = FEAT_RW_TF_ENC; break;
            case SPELL_SCHOOL_EVOCATION:     iRWSpec = FEAT_RW_TF_EVO; break;
            case SPELL_SCHOOL_ILLUSION:      iRWSpec = FEAT_RW_TF_ILL; break;
            case SPELL_SCHOOL_NECROMANCY:    iRWSpec = FEAT_RW_TF_NEC; break;
            case SPELL_SCHOOL_TRANSMUTATION: iRWSpec = FEAT_RW_TF_TRS; break;
        }

        if(iRWSpec && GetHasFeat(iRWSpec, oCaster))
            nSP = (iRedWizard / 2) + 1;
    }
//  SendMessageToPC(GetFirstPC(), "Your Spell Power modifier is " + IntToString(nSP));
    return nSP;
}

int GetSpellPenetreFocusSchool(int nSchool, object oCaster = OBJECT_SELF)
{
    if(nSchool)
    {
        if(GetHasFeat(FEAT_FOCUSED_SPELL_PENETRATION_ABJURATION+nSchool-1, oCaster))
            return 4;
    }

    return 0;
}

int GetSpellPowerBonus(object oCaster = OBJECT_SELF)
{
    if(GetHasFeat(FEAT_SPELLPOWER_10, oCaster))
        return 10;
    else if(GetHasFeat(FEAT_SPELLPOWER_8, oCaster))
        return 8;
    else if(GetHasFeat(FEAT_SPELLPOWER_6, oCaster))
        return 6;
    else if(GetHasFeat(FEAT_SPELLPOWER_4, oCaster))
        return 4;
    else if(GetHasFeat(FEAT_SPELLPOWER_2, oCaster))
        return 2;

    return 0;
}

// Shadow Weave Feat
// +1 caster level vs SR (school Ench,Illu,Necro)
int ShadowWeavePen(int spell_id, int nSchool, object oCaster = OBJECT_SELF)
{
    int iShadow = GetLevelByClass(CLASS_TYPE_SHADOW_ADEPT, oCaster);
    int nSP;

    // Apply changes if the caster has level in Shadow Adept class
    // and this spell is eligible for the spell penetration check increase
    if (iShadow > 0 && ShadowWeave(oCaster, spell_id, nSchool) == 1)
        // Shadow Spell Power
        nSP = iShadow / 3;

    return nSP;
}

int KOTCSpellPenVsDemons(object oCaster, object oTarget)
{
    if(GetLevelByClass(CLASS_TYPE_KNIGHT_CHALICE, oCaster) >= 1)
    {
        if(MyPRCGetRacialType(oTarget) == RACIAL_TYPE_OUTSIDER)
        {
            if(GetAlignmentGoodEvil(oTarget) == ALIGNMENT_EVIL)
            {
                return 2;
            }
        }
    }
    return 0;
}

int RunecasterRunePowerSP(object oCaster)
{
    int nSP = 0;

    // casting from a rune
    if(GetResRef(GetSpellCastItem()) == "prc_rune_1")
    {
        nSP = StringToInt(GetTag(GetSpellCastItem()));
    }
    // caster is runechanting
    else if(GetHasSpellEffect(SPELL_RUNE_CHANT))
    {
        int nClass = GetLevelByClass(CLASS_TYPE_RUNECASTER, oCaster);

        if (nClass >= 30)        nSP = 10;
        else if (nClass >= 27)   nSP = 9;
        else if (nClass >= 24)   nSP = 8;
        else if (nClass >= 21)   nSP = 7;
        else if (nClass >= 18)   nSP = 6;
        else if (nClass >= 15)   nSP = 5;
        else if (nClass >= 12)   nSP = 4;
        else if (nClass >= 9)    nSP = 3;
        else if (nClass >= 5)    nSP = 2;
        else if (nClass >= 2)    nSP = 1;
    }

    return nSP;
}

int MarshalDeterminedCaster(object oCaster)
{
    return GetLocalInt(oCaster,"Marshal_DetCast");
}

int DuskbladeSpellPower(object oCaster, object oTarget)
{
    int nSP = 0;
    if(GetLocalInt(oTarget, "DuskbladeSpellPower"))
    {
        int nClass = GetLevelByClass(CLASS_TYPE_DUSKBLADE, oCaster);

        if(nClass >= 38)      nSP = 10;
        else if(nClass >= 36) nSP = 9;
        else if(nClass >= 31) nSP = 8;
        else if(nClass >= 26) nSP = 7;
        else if(nClass >= 21) nSP = 6;
        else if(nClass >= 18) nSP = 5;
        else if(nClass >= 16) nSP = 4;
        else if(nClass >= 11) nSP = 3;
        else if(nClass >= 6)  nSP = 2;
    }

    return nSP;
}

int DraconicMagicPower(object oCaster)
{
    return GetLocalInt(oCaster,"MagicPowerAura");
}

int TrueCastingSpell(object oCaster)
{
    if(GetHasSpellEffect(SPELL_TRUE_CASTING, oCaster))
        return 10;

    return 0;
}

// Beguilers of level 8+ gain +2 bonus to SR agianst enemis that are denided DEX bonus to AC
int CloakedCastingSR(object oCaster, object oTarget)
{
    if(GetLevelByClass(CLASS_TYPE_BEGUILER, oCaster) >= 8)
    {
        if(GetIsDeniedDexBonusToAC(oTarget, oCaster, TRUE))
            return 2;
    }

    return 0;
}

int PenetratingBlast(object oCaster, object oTarget)
{
    if(oTarget == GetLocalObject(oCaster, "SPELLWEAVE_TARGET"))
    {
        if(GetLocalInt(oCaster, "BlastEssence") == INVOKE_PENETRATING_BLAST)
            return 4;
    }
    return 0;
}

int add_spl_pen(object oCaster = OBJECT_SELF)
{
    object oTarget = PRCGetSpellTargetObject();
    int spell_id = PRCGetSpellId();
    int nSchool = GetSpellSchool(spell_id);

    int nSP = ElementalSavantSP(spell_id, oCaster);
    nSP += GetHeartWarderPene(spell_id, oCaster);
    nSP += RedWizardSP(spell_id, nSchool, oCaster);
    nSP += GetSpellPowerBonus(oCaster);
    nSP += GetSpellPenetreFocusSchool(nSchool, oCaster);
    nSP += ShadowWeavePen(spell_id, nSchool, oCaster);
    nSP += RunecasterRunePowerSP(oCaster);
    nSP += MarshalDeterminedCaster(oCaster);
    nSP += DraconicMagicPower(oCaster);
    nSP += TrueCastingSpell(oCaster);
    nSP += GetEssentiaInvestedFeat(oCaster, FEAT_SOULTOUCHED_SPELLCASTING);
    if(GetIsObjectValid(oTarget))
    {
        nSP += CloakedCastingSR(oCaster, oTarget);
        nSP += PenetratingBlast(oCaster, oTarget);
        nSP += KOTCSpellPenVsDemons(oCaster, oTarget);
        nSP += DuskbladeSpellPower(oCaster, oTarget);
    }

    return nSP;
}

//
//  This function converts elemental types as needed
//
string ChangedElementalType(int spell_id, object oCaster = OBJECT_SELF)
{
    // Lookup the spell type
    string spellType = Get2DACache("spells", "ImmunityType", spell_id);//lookup_spell_type(spell_id);

    // Check if an override is set
    string sType = GetLocalString(oCaster, "archmage_mastery_elements_name");

    // If so, check if the spell qualifies for a change
    if (sType == "" || !IsSpellTypeElemental(spellType))
        sType = spellType;

    return sType;
}

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

//
//  Get the Spell Penetration Bonuses
//
int SPGetPenetr(object oCaster = OBJECT_SELF)
{
    int nPenetr = 0;

    // This is a deliberate optimization attempt.
    // The first feat determines if the others even need
    // to be referenced.
    if(GetHasFeat(FEAT_SPELL_PENETRATION, oCaster))
    {
        nPenetr += 2;
        if(GetHasFeat(FEAT_EPIC_SPELL_PENETRATION, oCaster))
            nPenetr += 4;
        else if (GetHasFeat(FEAT_GREATER_SPELL_PENETRATION, oCaster))
            nPenetr += 2;
    }

    // Check for additional improvements
    nPenetr += add_spl_pen(oCaster);

    return nPenetr;
}

//
//  Interface for specific AOE requirements
//  TODO: Determine who or what removes the cached local var (bug?)
//  TODO: Try and remove this function completely? It does 2 things the
//  above function doesnt: Effective Caster Level and Cache
//
int SPGetPenetrAOE(object oCaster = OBJECT_SELF, int nCasterLvl = 0)
{
    // Check the cache
    int nPenetr = GetLocalInt(OBJECT_SELF, "nPenetre");

    // Compute the result
    if (!nPenetr) {
        nPenetr = (nCasterLvl) ? nCasterLvl : PRCGetCasterLevel(oCaster);

        // Factor in Penetration Bonuses
        nPenetr += SPGetPenetr(oCaster);

        // Who removed this?
        SetLocalInt(OBJECT_SELF,"nPenetre",nPenetr);
    }

    return nPenetr;
}

// Test main
//void main(){}
