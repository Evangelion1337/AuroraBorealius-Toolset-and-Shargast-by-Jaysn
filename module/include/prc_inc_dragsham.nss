
// Metabreath Feats - Not implemented yet. 
/** const int FEAT_CLINGING_BREATH         = 5000;
const int FEAT_LINGERING_BREATH        = 5001;
const int FEAT_ENLARGE_BREATH          = 5002;
const int FEAT_HEIGHTEN_BREATH         = 5003;
const int FEAT_MAXIMIZE_BREATH         = 5004;
const int FEAT_QUICKEN_BREATH          = 5005;
const int FEAT_RECOVER_BREATH          = 5006;
const int FEAT_SHAPE_BREATH            = 5007;
const int FEAT_SPLIT_BREATH            = 5008;
const int FEAT_SPREADING_BREATH        = 5009;
const int FEAT_EXTEND_SPREADING_BREATH = 5010;
const int FEAT_TEMPEST_BREATH          = 5011; **/

// Dragon Shaman Aura flag
//const int DRAGON_SHAMAN_AURA_ACTIVE    = 5000;

#include "prc_inc_nwscript"

int GetIsDragonblooded(object oPC);

// returns the damage type of dragon that the PC has a totem for. Checks for the presence of the
// various feats that are present indicating such. This is necessary for determining the type
// of breath weapon and the type of damage immunity.
int GetDragonDamageType(int nTotem);

// Used to create a flag on the caster and store the Aura currently being run.
//int StartDragonShamanAura(object oCaster, int nSpellId);

// Resets the available ToV points; for use after rest or on enter.
void ResetTouchOfVitality(object oPC);

// Applies any metabreath feats that the dragon shaman may have to his breathweapon
//int ApplyMetaBreathFeatMods( int nDuration, object oCaster );

int GetIsDragonblooded(object oPC)
{
    int nRace = GetRacialType(oPC);
    if(nRace == RACIAL_TYPE_KOBOLD
    || nRace == RACIAL_TYPE_SPELLSCALE
    || nRace == RACIAL_TYPE_DRAGONBORN
    || nRace == RACIAL_TYPE_STONEHUNTER_GNOME
    || nRace == RACIAL_TYPE_SILVERBROW_HUMAN
    || nRace == RACIAL_TYPE_FORESTLORD_ELF
    || nRace == RACIAL_TYPE_FIREBLOOD_DWARF
    || nRace == RACIAL_TYPE_GLIMMERSKIN_HALFING
    || nRace == RACIAL_TYPE_FROSTBLOOD_ORC
    || nRace == RACIAL_TYPE_SUNSCORCH_HOBGOBLIN
    || nRace == RACIAL_TYPE_VILETOOTH_LIZARDFOLK)
        return TRUE;

    if(GetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE, oPC) > 9)
        return TRUE;

    if(GetHasFeat(FEAT_DRAGONTOUCHED, oPC)
    || GetHasFeat(FEAT_DRACONIC_DEVOTEE, oPC)
    || GetHasFeat(FEAT_DRAGON, oPC)
    || GetHasFeat(DRAGON_BLOODED, oPC))
        return TRUE;

    //Draconic Heritage qualifies for dragonblood
    if(GetHasFeat(FEAT_DRACONIC_HERITAGE_BK, oPC)
    || GetHasFeat(FEAT_DRACONIC_HERITAGE_BL, oPC)
    || GetHasFeat(FEAT_DRACONIC_HERITAGE_GR, oPC)
    || GetHasFeat(FEAT_DRACONIC_HERITAGE_RD, oPC)
    || GetHasFeat(FEAT_DRACONIC_HERITAGE_WH, oPC)
    || GetHasFeat(FEAT_DRACONIC_HERITAGE_AM, oPC)
    || GetHasFeat(FEAT_DRACONIC_HERITAGE_CR, oPC)
    || GetHasFeat(FEAT_DRACONIC_HERITAGE_EM, oPC)
    || GetHasFeat(FEAT_DRACONIC_HERITAGE_SA, oPC)
    || GetHasFeat(FEAT_DRACONIC_HERITAGE_TP, oPC)
    || GetHasFeat(FEAT_DRACONIC_HERITAGE_BS, oPC)
    || GetHasFeat(FEAT_DRACONIC_HERITAGE_BZ, oPC)
    || GetHasFeat(FEAT_DRACONIC_HERITAGE_CP, oPC)
    || GetHasFeat(FEAT_DRACONIC_HERITAGE_GD, oPC)
    || GetHasFeat(FEAT_DRACONIC_HERITAGE_SR, oPC))
        return TRUE;

    return FALSE;
}

int GetDragonDamageType(int nTotem)
{
    int nDamageType = nTotem == FEAT_DRAGONSHAMAN_BLACK  ? DAMAGE_TYPE_ACID:
                      nTotem == FEAT_DRAGONSHAMAN_BLUE   ? DAMAGE_TYPE_ELECTRICAL:
                      nTotem == FEAT_DRAGONSHAMAN_BRASS  ? DAMAGE_TYPE_FIRE:
                      nTotem == FEAT_DRAGONSHAMAN_BRONZE ? DAMAGE_TYPE_ELECTRICAL:
                      nTotem == FEAT_DRAGONSHAMAN_COPPER ? DAMAGE_TYPE_ACID:
                      nTotem == FEAT_DRAGONSHAMAN_GOLD   ? DAMAGE_TYPE_FIRE:
                      nTotem == FEAT_DRAGONSHAMAN_GREEN  ? DAMAGE_TYPE_ACID:
                      nTotem == FEAT_DRAGONSHAMAN_RED    ? DAMAGE_TYPE_FIRE:
                      nTotem == FEAT_DRAGONSHAMAN_SILVER ? DAMAGE_TYPE_COLD:
                      nTotem == FEAT_DRAGONSHAMAN_WHITE  ? DAMAGE_TYPE_COLD:
                      -1;

    return nDamageType;
}

void ResetTouchOfVitality(object oPC)
{
    if(GetHasFeat(FEAT_DRAGONSHAMAN_TOUCHVITALITY, oPC))
    {
        int nChaBonus = GetAbilityModifier(ABILITY_CHARISMA, oPC);
        if(nChaBonus < 0) nChaBonus = 0;
        int nVitPoints = 2 * GetLevelByClass(CLASS_TYPE_DRAGON_SHAMAN, oPC) * nChaBonus;
        SetLocalInt(oPC, "DRAGON_SHAMAN_TOUCH_REMAIN", nVitPoints);
        string sMes = "Healing power: " + IntToString(nVitPoints) + " points.";
        FloatingTextStringOnCreature(sMes, oPC, FALSE);
    }
	if(GetHasFeat(FEAT_ABERRANT_DURABLE_FORM, oPC))  
		ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectTemporaryHitpoints(GetAberrantFeatCount(oPC)), oPC);    
}

int GetMarshalAuraPower(object oPC)
{
   int iMarshalLevel = GetLevelByClass(CLASS_TYPE_MARSHAL, oPC);
   int nBonus;
    if(iMarshalLevel > 19)
        nBonus = iMarshalLevel / 5;
    else if(iMarshalLevel > 13)
        nBonus = 3;
    else if(iMarshalLevel > 6)
        nBonus = 2;
    else if(iMarshalLevel > 1)
        nBonus = 1;

    return nBonus;
}

int GetDragonShamanAuraPower(object oPC)
{
    int iDragonShamanLevel = GetLevelByClass(CLASS_TYPE_DRAGON_SHAMAN, oPC);
    int nBonus = (iDragonShamanLevel / 5) + 1;

    return nBonus;
}

int GetExtraAuraPower(object oPC)
{
    int nBonus;
    if(GetIsDragonblooded(oPC))
    {
        int nHD = GetHitDice(oPC);
        if(nHD > 19)
            nBonus = 4;
        else if(nHD > 13)
            nBonus = 3;
        else if(nHD > 6)
            nBonus = 2;
        else
            nBonus = 1;
    }

    return nBonus;
 }  

int GetAuraBonus(object oPC)
{
    int nAuraBonus = GetDragonShamanAuraPower(oPC);
    int nMarshalBonus = GetMarshalAuraPower(oPC);
    int nExtraBonus = GetExtraAuraPower(oPC);

    if(nMarshalBonus > nAuraBonus)
        nAuraBonus = nMarshalBonus;

    if(nExtraBonus > nAuraBonus)
        nAuraBonus = nExtraBonus;

    return nAuraBonus;
}

object GetAuraObject(object oShaman, string sTag)
{
    location lTarget = GetLocation(oShaman);
    object oAura = GetFirstObjectInShape(SHAPE_SPHERE, 1.0f, lTarget, FALSE, OBJECT_TYPE_AREA_OF_EFFECT);
    while(GetIsObjectValid(oAura))
    {
        if((GetAreaOfEffectCreator(oAura) == oShaman) //was cast by shaman
        && GetTag(oAura) == sTag                      //it's a draconic aura
        && !GetLocalInt(oAura, "SpellID"))          //and was not setup before
        {
            return oAura;
        }
        oAura = GetNextObjectInShape(SHAPE_SPHERE, 1.0f, lTarget, FALSE, OBJECT_TYPE_AREA_OF_EFFECT);
    }
    return OBJECT_INVALID;
}
