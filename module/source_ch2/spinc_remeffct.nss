///////////////////////////////////////////////////////////////////////////
//@file
//Include for spell removal checks
//
//
//void SpellRemovalCheck
//
//This function is used for the removal of effects and ending of spells that
//cannot be ended in a normal fashion.
//
///////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

void SpellRemovalCheck(object oCaster, object oTarget);


//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "prc_inc_spells"


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

void SpellRemovalCheck(object oCaster, object oTarget)
{
    //Get Spell being cast
    int nSpellID = PRCGetSpellId();

    //Set up spell removals for individual spells
    //Remove Curse
    if(nSpellID == SPELL_REMOVE_CURSE)
    {
        //Ghoul Gauntlet
        if(GetHasSpellEffect(SPELL_GHOUL_GAUNTLET, oTarget))
            PRCRemoveSpellEffects(SPELL_GHOUL_GAUNTLET, oCaster, oTarget);

        //Touch of Juiblex
        if(GetHasSpellEffect(SPELL_TOUCH_OF_JUIBLEX, oTarget))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(3), DAMAGE_TYPE_MAGICAL), oTarget);
            PRCRemoveSpellEffects(SPELL_TOUCH_OF_JUIBLEX, oCaster, oTarget);
        }

        //Evil Eye
        if(GetHasSpellEffect(SPELL_EVIL_EYE, oTarget))
            PRCRemoveSpellEffects(SPELL_EVIL_EYE, oCaster, oTarget);
    }

    //Remove Disease
    if(nSpellID == SPELL_REMOVE_DISEASE)
    {
        //Ghoul Gauntlet
        if(GetHasSpellEffect(SPELL_GHOUL_GAUNTLET, oTarget))
            PRCRemoveSpellEffects(SPELL_GHOUL_GAUNTLET, oCaster, oTarget);
    }

    //Heal
    if(nSpellID == SPELL_HEAL
    || nSpellID == SPELL_MASS_HEAL)
    {
        //Ghoul Gauntlet
        if(GetHasSpellEffect(SPELL_GHOUL_GAUNTLET, oTarget))
            PRCRemoveSpellEffects(SPELL_GHOUL_GAUNTLET, oCaster, oTarget);

        //Energy Ebb
        if(GetHasSpellEffect(SPELL_ENERGY_EBB, oTarget))
            PRCRemoveSpellEffects(SPELL_ENERGY_EBB, oCaster, oTarget);

        //Touch of Juiblex
        if(GetHasSpellEffect(SPELL_TOUCH_OF_JUIBLEX, oTarget))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(3), DAMAGE_TYPE_MAGICAL), oTarget);
            PRCRemoveSpellEffects(SPELL_TOUCH_OF_JUIBLEX, oCaster, oTarget);
        }
    }

    //Restoration
    if(nSpellID == SPELL_RESTORATION)
    {
        //Ghoul Gauntlet
        if(GetHasSpellEffect(SPELL_GHOUL_GAUNTLET, oTarget))
            PRCRemoveSpellEffects(SPELL_GHOUL_GAUNTLET, oCaster, oTarget);

        //Energy Ebb
        if(GetHasSpellEffect(SPELL_ENERGY_EBB, oTarget))
            PRCRemoveSpellEffects(SPELL_ENERGY_EBB, oCaster, oTarget);
    }

    //Greater Restoration
    if(nSpellID == SPELL_GREATER_RESTORATION)
    {
        //Ghoul Gauntlet
        if(GetHasSpellEffect(SPELL_GHOUL_GAUNTLET, oTarget))
            PRCRemoveSpellEffects(SPELL_GHOUL_GAUNTLET, oCaster, oTarget);

        //Energy Ebb
        if(GetHasSpellEffect(SPELL_ENERGY_EBB, oTarget))
            PRCRemoveSpellEffects(SPELL_ENERGY_EBB, oCaster, oTarget);

        //Touch of Juiblex
        if(GetHasSpellEffect(SPELL_TOUCH_OF_JUIBLEX, oTarget))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(3), DAMAGE_TYPE_MAGICAL), oTarget);
            PRCRemoveSpellEffects(SPELL_TOUCH_OF_JUIBLEX, oCaster, oTarget);
        }
    }

    //Dispel Magic
    //Greater Dispelling
    //Mordenkainen's Disjunction
    if(nSpellID == SPELL_DISPEL_MAGIC
    || nSpellID == SPELL_GREATER_DISPELLING
    || nSpellID == SPELL_MORDENKAINENS_DISJUNCTION)
    {
        //Ghoul Gauntlet
        if(GetHasSpellEffect(SPELL_GHOUL_GAUNTLET, oTarget))
            PRCRemoveSpellEffects(SPELL_GHOUL_GAUNTLET, oCaster, oTarget);

        //Eternity of Torture
        if(GetHasSpellEffect(SPELL_ETERNITY_OF_TORTURE, oTarget))
        {
            AssignCommand(oTarget, SetCommandable(TRUE, oTarget));
            PRCRemoveSpellEffects(SPELL_ETERNITY_OF_TORTURE, oCaster, oTarget);
        }
    }

    //Limited Wish
    //Wish
    //Miracle
}

// Checks if the effect is specific to a plot and should not be removed normally
int GetShouldNotBeRemoved(effect eEff)
{
    object oCreator = GetEffectCreator(eEff);
    if(GetTag(oCreator) == "q6e_ShaorisFellTemple")
        return TRUE;
        
	if(GetEffectSpellId(eEff) >= VESTIGE_AMON && VESTIGE_ABYSM >= GetEffectSpellId(eEff))
		return TRUE;
		
	if(GetEffectSpellId(eEff) >= MELD_ACROBAT_BOOTS && MELD_ELDER_SPIRIT >= GetEffectSpellId(eEff))
		return TRUE;		
        
    return FALSE;
}

// Test main
//void main(){}
