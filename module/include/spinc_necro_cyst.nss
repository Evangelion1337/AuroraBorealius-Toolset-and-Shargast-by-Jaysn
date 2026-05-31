//::///////////////////////////////////////////////
//:: Necrotic Cyst spell includes
//:: spinc_necro_cyst
//:://////////////////////////////////////////////
/** @file
    This file contains functions and constants
    related to the Necrotic Cyst spell line.


    @author Ornedan
    @date   Created - 2005.09.21
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

///////////////////////////////////////
/* Function prototypes               */
///////////////////////////////////////

/**
 * Checks if the given creature may cast Necrotic Cyst spells.
 *
 * @param oPC  The creature whose eligibility to test.
 * @return     TRUE if the creature is allowed to cast
 *             Necrotic Cyst spells, FALSE otherwise.
 */
int GetCanCastNecroticSpells(object oPC);

/**
 * Checks if the given creature has a necrotic cyst.
 *
 * @param oCreature Creature to check.
 * @return          TRUE if the creature has a necrotic cyst,
 *                  FALSE otherwise.
 */
int GetHasNecroticCyst(object oCreature);



///////////////////////////////////////
/* Constant declarations             */
///////////////////////////////////////

const string NECROTIC_EMPOWERMENT_MARKER = "HAS_NECROTIC_EMPOWER";
const string NECROTIC_CYST_MARKER        = "HAS_NECROTIC_CYST";
const int nNoNecCyst = 16829317;
const int nNoMotherCyst = 16829318;
const int nNecEmpower = 16829319;
const int nGaveCyst = 16829316;

///////////////////////////////////////
/* Function declarations             */
///////////////////////////////////////
//#include "prc_alterations" // No point in including prc_alteractions
//#include "inc_utility"
#include "prc_x2_itemprop" // required for - SetPersistantLocalInt
//#include "prc_spell_const"

int GetCanCastNecroticSpells(object oPC)
{
    int bReturn = TRUE;

    // check for Necrotic Empowerment on caster
    if(GetHasSpellEffect(SPELL_NECROTIC_EMPOWERMENT, oPC))
    {
        // "You cannot cast spells utilizing your Mother Cyst while under the effect of Necrotic Empowerment."
        FloatingTextStrRefOnCreature(nNecEmpower, oPC);
        bReturn = FALSE;
    }
    // check for Mother Cyst
    if(!GetHasFeat(FEAT_MOTHER_CYST, oPC) && (!GetIsObjectValid(GetSpellCastItem())))
    {
        // "You must have a Mother Cyst to cast this spell."
        FloatingTextStrRefOnCreature(nNoMotherCyst, oPC);
        bReturn = FALSE;
    }

    if(DEBUG) DoDebug("spinc_necrocyst: GetCanCastNecroticSpells():\n"
                        + "oPC = '" + GetName(oPC) + "'");

    return bReturn;
}

int GetHasNecroticCyst(object oCreature)
{
    return GetPersistantLocalInt(oCreature, NECROTIC_CYST_MARKER);
    //if(DEBUG) DoDebug("spinc_necrocyst: GetHasNecroticCyst():\n"
    //                    + "oCreature = '" + GetName(oCreature) + "'");
}

void GiveNecroticCyst(object oCreature)
{

    SetPersistantLocalInt(oCreature, NECROTIC_CYST_MARKER, 1);
    FloatingTextStrRefOnCreature(nGaveCyst, OBJECT_SELF);
    itemproperty iCystDam = (ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, 1));
    object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oCreature);
    if (GetIsObjectValid(oArmor))
    {
        //add item prop with DURATION_TYPE_PERMANENT
        IPSafeAddItemProperty(oArmor, iCystDam, 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, FALSE);
    }

    else
    {
        object oSkin = GetPCSkin(oCreature);
        IPSafeAddItemProperty(oSkin, iCystDam, 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, FALSE);
    }

    //Keep property on armor or hide
    ExecuteScript ("prc_keep_onhit_a", oCreature);

    if(DEBUG) DoDebug("spinc_necrocyst: GiveNecroticCyst():\n"
                            + "oCreature = '" + GetName(oCreature) + "'");

}

void RemoveCyst(object oCreature)
{
    SetPersistantLocalInt(oCreature, NECROTIC_CYST_MARKER, 0);
}

// Test main
//void main(){}
