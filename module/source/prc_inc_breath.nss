//::///////////////////////////////////////////////
//:: Breath Weapon Include
//:: prc_inc_breath
//::///////////////////////////////////////////////
/** @file
    Centralizes handling for most breath weapons for
    implementing Metabreath and the like.

    @author Fox
    @date   Created - 2008.1.19
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/*                 Structures                   */
//////////////////////////////////////////////////

/**
 * A structure that contains common data used during power manifestation.
 */
struct breath{
    /* Generic stuff */
    /// The creature breathing
    object oDragon;
    
    /* Basic info */
    /// The shape of the breath
    int bLine;
    /// The size of the breath in feet
    float fRange;
    /// The element of the breath
    int nDamageType;
    /// Type of dice
    int nDiceType;
    /// Number of dice
    int nDiceNumber;
    /// The stat relavant for DC calculating
    int nDCStat;
    /// Any other DC mods, like class levels for DragDis
    int nOtherDCMod;
    /// Save type - needed in case of Fort Save
    int nSaveUsed;
    /// Rounds until next use
    int nRoundsUntilRecharge;

    /* Metabreath */
    /// Number of rounds Clinging Breaths last
    int nClinging;
    /// Number of rounds Lingering Breaths last
    int nLingering;
    /// Whether Enlarge Breath was used
    int bEnlarge;
    /// How much the DC is increased by Heighten Breath - max of Con
    int nHeighten;
    /// Whether Maximize Breath was used
    int bMaximize;
    /// Whether Spreading Breath was used
    int bSpread;
    /// Whether Tempest Breath was used
    int bTempest;
    
    /* Breath Channeling */
    /// Whether Entangling Exhalation was used
    int bEntangling;
    /// Whether Exhaled Barrier was used
    int bBarrier;
    /// Whether Exhaled Immunity was used
    int bExhaleImmune;
    
    
    /* Special Cases */
    /// Special case referance number - used for things like Pyroclastic
    int nOverrideSpecial;
    
};


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Creates the breath struct, taking metabreath and breath channeling into account.
 *
 * @param oDragon          The creature breathing the breath weapon
 * @param bLine            True if breath is a line breath, false if a cone breath
 * @param fRange           The range of the breath weapon in feet.
 * @param nDamageType      The element of the breath weapon, if it has one.
 * @param nDiceType        The type of damage dice for the breath weapon.
 * @param nDiceNumber      The number of damage dice for the breath weapon.
 * @param nDCStat          The constant for the stat the breath weapon uses for DC 
 *                         calculation.
 * @param nOtherDCMod      Any other applicable modifications to the DC. 
 *                         e.g. Dragon Disciple levels.
 * @param nOverrideSpecial Indicates any special case breath weapons, like the Pyroclastic's
 *                         split damage or Shadow's negative level breath. Defaults to 0.
 * @param nBaseRecharge    The die size of the recharge "lock."  Defaults to d4.
 * @param nSaveUsed        The constant to determine the save used.  Defaults to Reflex.
 *                         Diamond Dragon uses Fort saves for cold breath for example.
 *
 * @return                 Returns a struct that describes the breath being used, including
 *                         applicable metabreath and breath channeling feats.
 */
struct breath CreateBreath(object oDragon, int bLine, float fRange, int nDamageType, int nDiceType, int nDiceNumber, int nDCStat, int nOtherDCMod, int nOverrideSpecial = 0, int nBaseRecharge = 4, int nSaveUsed = SAVING_THROW_REFLEX);

/**
 * Applies the breath effect on the targeted location.  Brought into the include since 
 * there is so much common code.
 *
 * @param BreathUsed    A struct describing the details of the breath weapon
 * @param lTargetArea   The targeted location for the breath.
 * @param bLinger       Determines if this breath was applied by Lingering Breath metabreath.
 *                      Defaults to FALSE.
 * @param vSource       The source of a Lingering breath.  This does not matter except when 
 *                      bLinger is set to TRUE.
 *
 */
void ApplyBreath(struct breath BreathUsed, location lTargetArea, int bLinger = FALSE, float vSourceX = 0.0, float vSourceY = 0.0, float vSourceZ = 0.0);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "prc_alterations"
#include "prcsp_archmaginc"
#include "prc_inc_spells"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

// Exhaled Immunity is different enough to break off on it's own, as it only
// applies to one creature, and nothing else happens.
void ExhaleImmunity(object oDragon, int nDamageType, location lTargetArea)
{
	//since there's no "GetObjectAtLocation," grab a tiny AoE to find the creature
	object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 1.0, lTargetArea, TRUE,
                          OBJECT_TYPE_CREATURE, GetPosition(oDragon));
        
        //make sure damage type is valid, default to fire for non-energy-damage-based breaths  
        int nImmuneType = DAMAGE_TYPE_FIRE;
        
        if (nDamageType == DAMAGE_TYPE_ACID) nImmuneType = DAMAGE_TYPE_ACID;
        else if (nDamageType == DAMAGE_TYPE_COLD) nImmuneType = DAMAGE_TYPE_COLD;
        else if (nDamageType == DAMAGE_TYPE_SONIC) nImmuneType = DAMAGE_TYPE_SONIC;
        else if (nDamageType == DAMAGE_TYPE_ELECTRICAL) nImmuneType = DAMAGE_TYPE_ELECTRICAL;
                                    
        if((oTarget == OBJECT_INVALID) || (oTarget == oDragon))
        {
             SendMessageToPC(oDragon, "You must target another creature for Exhaled Immunity to work.");
             return;
        }
        
        else
        {
             //Fire cast spell at event for the specified target
             SignalEvent(oTarget, EventSpellCastAt(oDragon, GetSpellId(), FALSE));
             //Determine effect delay
             float fDelay = GetDistanceBetween(oDragon, oTarget)/20;
             float fDuration = RoundsToSeconds(d4());
             
             //set effects
             effect eImmune = EffectDamageImmunityIncrease(nDamageType, 100); 
             effect eVis = EffectVisualEffect(VFX_IMP_ELEMENTAL_PROTECTION);
             effect eVis2 = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
             effect eLink = EffectLinkEffects(eImmune, eVis2);
             
             //apply effects
             DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
             DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, eImmune, oTarget, fDuration));
        }
}

//fucntion to check for Adept breath
int IsAdeptBreath()
{
	int nBreath = GetSpellId();
	if(nBreath == BREATH_FIRE_CONE 
            || nBreath == BREATH_FIRE_LINE
            || nBreath == BREATH_FROST_CONE
            || nBreath == BREATH_ELECTRIC_LINE
            || nBreath == BREATH_SICKENING_CONE
            || nBreath == BREATH_ACID_CONE
            || nBreath == BREATH_ACID_LINE
            || nBreath == BREATH_SLOW_CONE
            || nBreath == BREATH_WEAKENING_CONE
            || nBreath == BREATH_SLEEP_CONE
            || nBreath == BREATH_THUNDER_CONE
            || nBreath == BREATH_BAHAMUT_LINE
            || nBreath == BREATH_FORCE_LINE
            || nBreath == BREATH_PARALYZE_CONE
            || nBreath == BREATH_FIVEFOLD_TIAMAT)
            return TRUE;
            
        return FALSE;
}

int IsBreathProtected(object oDragon, object oTarget)
{
    int nBPIndex = 0;
    while(array_get_object(oTarget, "BreathProtected", nBPIndex) != OBJECT_INVALID)
    {
    	if(array_get_object(oTarget, "BreathProtected", nBPIndex) == oDragon)
    	{
              return TRUE;
        }
        else
              nBPIndex++;
    }
    
    return FALSE;
}

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

struct breath CreateBreath(object oDragon, int bLine, float fRange, int nDamageType, int nDiceType, int nDiceNumber, int nDCStat, int nOtherDCMod, int nOverrideSpecial = 0, int nBaseRecharge = 4, int nSaveUsed = SAVING_THROW_REFLEX)
{
	struct breath BreathUsed;
	
	//gather base data
	BreathUsed.oDragon = oDragon;
	BreathUsed.bLine = bLine;
	BreathUsed.fRange = fRange;
	BreathUsed.nDamageType = nDamageType;
	BreathUsed.nDiceType = nDiceType;
	BreathUsed.nDiceNumber = nDiceNumber;
	BreathUsed.nDCStat = nDCStat;
	BreathUsed.nOtherDCMod = nOtherDCMod;
	int nFinalRecharge;
	switch(nBaseRecharge)
	{
	     case 4: 
	          nFinalRecharge = d4(); break;
	     case 1: 
	          nFinalRecharge = 1; break;	          
	     default: 
	          nFinalRecharge = 0; break;
	}
	BreathUsed.nRoundsUntilRecharge = nFinalRecharge;
	BreathUsed.nSaveUsed = nSaveUsed;
	BreathUsed.nOverrideSpecial = nOverrideSpecial;
	
	//Energy Aura bonus checking
	switch(nDamageType)
	{
	    case DAMAGE_TYPE_ACID:
	        if(GetLocalInt(oDragon,"AcidEnergyAura"))
	            BreathUsed.nOtherDCMod += GetLocalInt(oDragon,"AcidEnergyAura");
	        break;
	    case DAMAGE_TYPE_COLD:
	        if(GetLocalInt(oDragon,"ColdEnergyAura"))
	            BreathUsed.nOtherDCMod += GetLocalInt(oDragon,"ColdEnergyAura");
	        break;
	    case DAMAGE_TYPE_ELECTRICAL:
	        if(GetLocalInt(oDragon,"ElecEnergyAura"))
	            BreathUsed.nOtherDCMod += GetLocalInt(oDragon,"ElecEnergyAura");
	        break;
	    case DAMAGE_TYPE_FIRE:
	        if(GetLocalInt(oDragon,"FireEnergyAura"))
	            BreathUsed.nOtherDCMod += GetLocalInt(oDragon,"FireEnergyAura");
	}
	
	/* Initialize metabreath/channeling tracking */
	BreathUsed.nClinging = 0;
        BreathUsed.nLingering = 0;
        BreathUsed.bEnlarge = FALSE;
        BreathUsed.nHeighten = 0;
        BreathUsed.bMaximize = FALSE;
        BreathUsed.bSpread = FALSE;
        BreathUsed.bTempest = FALSE;
        BreathUsed.bEntangling = FALSE;
        BreathUsed.bBarrier = FALSE;
        BreathUsed.bExhaleImmune = FALSE;
    
	/* breath channeling */
	
	// Whether Entangling Exhalation was used
	if(GetLocalInt(oDragon, "EntangleBreath"))
	   BreathUsed.bEntangling = TRUE;
        // Whether Exhaled Barrier was used
	if(GetLocalInt(oDragon, "ExhaleBarrier"))
	   BreathUsed.bBarrier = TRUE;
        // Whether Exhaled Immunity was used
	if(GetLocalInt(oDragon, "ExhaleImmunity"))
	   BreathUsed.bExhaleImmune = TRUE;
	   
        //breath effect checks
        
        //Cloud only works with 1 other effect applied
        //this one handles combination with damage effects and enduring
        if(GetLocalInt(oDragon, "AdeptCloudBreath") 
           && !GetLocalInt(oDragon, "AdeptShapedBreath")
           && (GetSpellId() == BREATH_FIRE_CONE 
               || GetSpellId() == BREATH_FROST_CONE
               || GetSpellId() == BREATH_SICKENING_CONE
               || GetSpellId() == BREATH_ACID_CONE
               || GetSpellId() == BREATH_SLOW_CONE
               || GetSpellId() == BREATH_WEAKENING_CONE
               || GetSpellId() == BREATH_SLEEP_CONE
               || GetSpellId() == BREATH_THUNDER_CONE
               || GetSpellId() == BREATH_PARALYZE_CONE))
        {
           BreathUsed.bSpread = TRUE;
        }
        //this one is Cloud + Shaped
        if(GetLocalInt(oDragon, "AdeptCloudBreath") 
           && GetLocalInt(oDragon, "AdeptShapedBreath")
           && !GetLocalInt(oDragon, "AdeptEnduringBreath")
           && GetSpellId() == BREATH_FIRE_CONE)
        {
           BreathUsed.bSpread = TRUE;
        }
        if(GetLocalInt(oDragon, "AdeptEnduringBreath")
           && !(GetLocalInt(oDragon, "AdeptCloudBreath") && GetLocalInt(oDragon, "AdeptShapedBreath")) 
           && (GetSpellId() == BREATH_FIRE_CONE || GetSpellId() == BREATH_FIRE_LINE))
        {
           BreathUsed.nLingering = 1;
        }

        //breaths without recharge times can't use metabreath
        if(BreathUsed.nRoundsUntilRecharge == 0)
           return BreathUsed;
	
	/* metabreath calculation*/
	
	//Clinging breath - Main feat increments uses, secondary feat cancels.
	if(GetLocalInt(oDragon, "ClingingBreath") > 0)
	{
	   BreathUsed.nClinging = GetLocalInt(oDragon, "ClingingBreath");
	   BreathUsed.nRoundsUntilRecharge += BreathUsed.nClinging;
	}
	//Lingering breath - Main feat increments uses, secondary feat cancels.
	if(GetLocalInt(oDragon, "LingeringBreath") > 0)
	{
	   BreathUsed.nLingering = GetLocalInt(oDragon, "LingeringBreath");
	   BreathUsed.nRoundsUntilRecharge += (BreathUsed.nLingering * 2);
	}
	//Enlarge breath
	if(GetLocalInt(oDragon, "EnlargeBreath"))
	{
	   BreathUsed.bEnlarge = TRUE;
	   BreathUsed.nRoundsUntilRecharge += 1;
	}
	//Heighten breath - Feat increments uses, resets if incremented at max.
	if(GetLocalInt(oDragon, "HeightenBreath") > 0)
	{
	   BreathUsed.nHeighten = GetLocalInt(oDragon, "HeightenBreath");
	   BreathUsed.nRoundsUntilRecharge += BreathUsed.nHeighten;
	}
	//Maximize breath
	if(GetLocalInt(oDragon, "MaximizeBreath"))
	{
	   BreathUsed.bMaximize = TRUE;
	   BreathUsed.nRoundsUntilRecharge += 3;
	}
	//Shape breath
	if(GetLocalInt(oDragon, "ShapeBreath"))
	{
       if(bLine) BreathUsed.bLine = FALSE;
       else BreathUsed.bLine = TRUE;
	   BreathUsed.nRoundsUntilRecharge += 1;
	}
	//Spreading breath
	if(GetLocalInt(oDragon, "SpreadingBreath"))
	{
	   BreathUsed.bSpread = TRUE;
	   BreathUsed.nRoundsUntilRecharge += 2;
	}
	//Tempest breath
	if(GetLocalInt(oDragon, "TempestBreath"))
	{
	   BreathUsed.bTempest = TRUE;
	   BreathUsed.nRoundsUntilRecharge += 1;
	}
	//Recover Breath
	if(GetHasFeat(FEAT_RECOVER_BREATH, oDragon) 
	  && (BreathUsed.nRoundsUntilRecharge > 1))
	   BreathUsed.nRoundsUntilRecharge += -1;
	   
	
        // Exhaled Barrier and Immunity don't apply Metabreath feats, so recharge time should be unaffected
	if(BreathUsed.bBarrier || BreathUsed.bExhaleImmune)
	   BreathUsed.nRoundsUntilRecharge = nFinalRecharge;
	
	return BreathUsed;
}

void ApplyBreath(struct breath BreathUsed, location lTargetArea, int bLinger = FALSE, float vSourceX = 0.0, float vSourceY = 0.0, float vSourceZ = 0.0)
{
    //if using Exhaled Immunity, jump straight to it and ignore the rest
    if(BreathUsed.bExhaleImmune)
    {
        ExhaleImmunity(BreathUsed.oDragon, BreathUsed.nDamageType, lTargetArea);
        return;
    }
	
    //init variables
    effect eBreath;
    effect eVis;
    float fDelay;
    int nDamage = 0;
    int nAdjustedDamage;
    int nSaveDamageType = -1;
    int nVisualType = -1;
    int nEnergyAura = 0;
    int bCanCling;
    int nSaveDC;
    int nShapedSpotsUsed = GetLocalInt(BreathUsed.oDragon, "AdeptShapedBreath") ? 0 : 4;
    int nBreathShape = BreathUsed.bLine ? SHAPE_SPELLCYLINDER : SHAPE_SPELLCONE;
    float fRange = FeetToMeters(BreathUsed.fRange);
    int nKnockdownDC = 0;
    vector vSource = Vector(vSourceX, vSourceY, vSourceZ);
    vector vSourceOfBreath = bLinger ? vSource : GetPosition(BreathUsed.oDragon);
    
    //Saving Throw setup
    if (BreathUsed.nDCStat >= 10)
    	nSaveDC = BreathUsed.nDCStat;
    else
    	nSaveDC = 10 + PRCMax(GetAbilityModifier(BreathUsed.nDCStat), 0) + BreathUsed.nOtherDCMod;
    
    //Set up variables that depend on damage type
    switch (BreathUsed.nDamageType)
    {
    	case DAMAGE_TYPE_ACID:
    	     nSaveDamageType = SAVING_THROW_TYPE_ACID;
    	     nVisualType = VFX_IMP_ACID_S; 
    	     nEnergyAura = GetLocalInt(BreathUsed.oDragon, "AcidEnergyAura"); break;
    	
    	case DAMAGE_TYPE_COLD:
    	     nSaveDamageType = SAVING_THROW_TYPE_COLD;
    	     nVisualType = VFX_IMP_FROST_S; 
    	     nEnergyAura = GetLocalInt(BreathUsed.oDragon, "ColdEnergyAura"); break;
    	
    	case DAMAGE_TYPE_ELECTRICAL:
    	     nSaveDamageType = SAVING_THROW_TYPE_ELECTRICITY;
    	     nVisualType = VFX_IMP_LIGHTNING_S; 
    	     nEnergyAura = GetLocalInt(BreathUsed.oDragon, "ElecEnergyAura"); break;
    	
    	case DAMAGE_TYPE_FIRE:
    	     nSaveDamageType = SAVING_THROW_TYPE_FIRE;
    	     nVisualType = VFX_IMP_FLAME_M; 
    	     nEnergyAura = GetLocalInt(BreathUsed.oDragon, "FireEnergyAura"); break;
    	
    	case DAMAGE_TYPE_MAGICAL:
    	     nSaveDamageType = SAVING_THROW_TYPE_NONE;
    	     nVisualType = VFX_IMP_KNOCK; break;
    	
    	case DAMAGE_TYPE_NEGATIVE:
    	     nSaveDamageType = SAVING_THROW_TYPE_NEGATIVE;
    	     nVisualType = VFX_IMP_NEGATIVE_ENERGY; break;
    	     
    	case DAMAGE_TYPE_POSITIVE:
    	     nSaveDamageType = SAVING_THROW_TYPE_POSITIVE;
    	     nVisualType = VFX_IMP_HOLY_AID; break;
    	
    	case DAMAGE_TYPE_SONIC:
    	     nSaveDamageType = SAVING_THROW_TYPE_SONIC;
    	     nVisualType = VFX_IMP_SILENCE; break;
    }
    
    //apply Energy Draconic Aura bonus
    if(nEnergyAura < 0) nEnergyAura = 0;
    nSaveDC += nEnergyAura;
    
    if(BreathUsed.nOverrideSpecial == BREATH_TOPAZ)
        nVisualType = VFX_IMP_POISON_L;
        
    if(BreathUsed.bBarrier)
    {   
    	//2d6 fire damage if the breath doesn't do damage
    	if(BreathUsed.nOverrideSpecial == BREATH_SHADOW
    	   || BreathUsed.nOverrideSpecial == BREATH_SLEEP
    	   || BreathUsed.nOverrideSpecial == BREATH_SLOW
    	   || BreathUsed.nOverrideSpecial == BREATH_PARALYZE
    	   || BreathUsed.nOverrideSpecial == BREATH_WEAKENING)
        {
    	    BreathUsed.nDiceType = 6;
    	    BreathUsed.nDiceNumber = 2;
    	    BreathUsed.nDamageType = DAMAGE_TYPE_FIRE;
    	}
    	
    	//fire damage if damage isn't energy damage
        if(BreathUsed.nDamageType == DAMAGE_TYPE_MAGICAL || BreathUsed.nDamageType == DAMAGE_TYPE_BLUDGEONING)
    	    BreathUsed.nDamageType = DAMAGE_TYPE_FIRE;
    	
    	//get the breath parameters and pass to the wall's scripts
    	SetLocalInt(BreathUsed.oDragon, "BarrierDiceType", BreathUsed.nDiceType);
    	SetLocalInt(BreathUsed.oDragon, "BarrierDiceNumber", BreathUsed.nDiceNumber);
    	SetLocalInt(BreathUsed.oDragon, "BarrierDamageType", BreathUsed.nDamageType);
    	
    	//create the wall
    	effect eAOE = EffectAreaOfEffect(AOE_PER_WALLBREATH);
    	ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, lTargetArea, RoundsToSeconds(d4()));
    	
    	//this overrides all other breath effects, so exit
    	return;
    }
        
    
    //roll damage
    switch(BreathUsed.nDiceType)
    {
    	case 4: 
    	    nDamage = d4(BreathUsed.nDiceNumber); break;
    	case 6: 
    	    nDamage = d6(BreathUsed.nDiceNumber); break;
    	case 8: 
    	    nDamage = d8(BreathUsed.nDiceNumber); break;
    	case 10: 
    	    nDamage = d10(BreathUsed.nDiceNumber); break;
    }
    if(DEBUG) DoDebug("prc_inc_breath: Rolling damage: " + IntToString(BreathUsed.nDiceNumber) 
                      + "d" + IntToString(BreathUsed.nDiceType) + "= " + IntToString(nDamage));
    
    //Shadow breath does 1 neg level instead of damage
    if(BreathUsed.nOverrideSpecial == BREATH_SHADOW)
        nDamage = 1;
    
    //adjust for metabreaths
    if(BreathUsed.bEnlarge)
        fRange = fRange * 1.5;
    if(BreathUsed.nHeighten > 0)
        nSaveDC += BreathUsed.nHeighten;
    if(BreathUsed.bMaximize)
        nDamage = BreathUsed.nDiceType * BreathUsed.nDiceNumber;
    if(BreathUsed.bSpread)
    {
    	fRange = PRCGetCreatureSize(BreathUsed.oDragon) * 5.0;
    	if(fRange < 1.0) fRange = 5.0;
    	fRange = FeetToMeters(fRange);
        nBreathShape = SHAPE_SPHERE;
        lTargetArea = GetLocation(BreathUsed.oDragon);
        eVis = EffectVisualEffect(VFX_FNF_DRAGBREATHGROUND);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lTargetArea);
    }
    
    //Lingering Breath's effects are 1/2 of normal when lingering
    if(bLinger)
    {
    	nDamage /= 2;
    	BreathUsed.nDiceNumber /= 2;
    }
    
    //DCs for Tempest Breath  
    switch(PRCGetCreatureSize(BreathUsed.oDragon))
    {
    	case CREATURE_SIZE_LARGE:
    	    nKnockdownDC = 15; break;
    	    
    	case CREATURE_SIZE_HUGE:
    	    nKnockdownDC = 18; break;
    	    
    	case CREATURE_SIZE_GARGANTUAN:
    	    nKnockdownDC = 20; break;
    	    
    	case CREATURE_SIZE_COLOSSAL:
    	    nKnockdownDC = 30; break;
    	
    }
        
    //adjust for breath channeling
    if(BreathUsed.bEntangling)
        nDamage = nDamage / 2;
        
    /* Begin application */
    int nObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR  | OBJECT_TYPE_PLACEABLE;
    //Adept's Breath of Bahamut does not affect objects
    if(GetSpellId() == BREATH_BAHAMUT_LINE) nObjectFilter = OBJECT_TYPE_CREATURE;
    
    //Get first target in spell area
    object oTarget = GetFirstObjectInShape(nBreathShape, fRange, lTargetArea, TRUE, nObjectFilter, vSourceOfBreath);
    if(DEBUG) DoDebug("prc_inc_breath: Target Name:  " + GetName(oTarget));
    while(GetIsObjectValid(oTarget))
    {
        if(DEBUG) DoDebug("prc_inc_breath: Valid Target:  " + GetName(oTarget));
        if(oTarget != BreathUsed.oDragon && !IsBreathProtected(BreathUsed.oDragon, oTarget) && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, BreathUsed.oDragon))
        {
            if(DEBUG) DoDebug("prc_inc_breath: Not Self, Not Protected");
            //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
            //Determine effect delay
            fDelay = GetDistanceBetween(BreathUsed.oDragon, oTarget)/20;
            
            //check for Shaped Breath effect
            if(IsAdeptBreath() && (nShapedSpotsUsed < 4) && !GetIsReactionTypeHostile(oTarget) && GetLocalInt(BreathUsed.oDragon, "AdeptShapedBreath"))
            {
            	if(DEBUG) DoDebug("prc_inc_breath: Entering Shaped Breath.  Slots used: " + IntToString(nShapedSpotsUsed));
                nShapedSpotsUsed++;
            }
                
            //Adept's Sickening Breath breath effect
            else if(BreathUsed.nOverrideSpecial == BREATH_SICKENING)
            {
                if(DEBUG) DoDebug("prc_inc_breath: sickening breath attack");
            	
            	//Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(BreathUsed.oDragon, GetSpellId()));
	        
	            //2 rounds on a failed save
	            if(!PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nSaveDC, SAVING_THROW_TYPE_NONE))
                {
                    //Apply the VFX impact and effects
                    DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_POISON_L), oTarget));
                    DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSickened(), oTarget, 12.0));
                }
                //1 round otherwise
                else
                {
                    //Apply the VFX impact and effects
                    DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_POISON_L), oTarget));
                    DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSickened(), oTarget, 6.0));
                }
            }
            
            //Brass alternate breath - sleep
            else if(BreathUsed.nOverrideSpecial == BREATH_SLEEP)
            {
                if(DEBUG) DoDebug("prc_inc_breath: sleep breath attack");
            	//prepare effects
               effect eBreath = EffectSleep();
               effect eVis = EffectVisualEffect(VFX_IMP_SLEEP);
               effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
               effect eLink = EffectLinkEffects(eBreath, eDur);
                
                //get duration
                int nSleepDuration = BreathUsed.nDiceNumber;
            	
            	//Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(BreathUsed.oDragon, GetSpellId()));
	        
	            if(!PRCMySavingThrow(SAVING_THROW_WILL, oTarget, nSaveDC, SAVING_THROW_TYPE_NONE))
                {
                    //Apply the VFX impact and effects
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nSleepDuration)));
                    SetLocalInt(oTarget, "AffectedByBreath", TRUE);
                }
            }
            
            //Copper alternate breath - slow
            else if(BreathUsed.nOverrideSpecial == BREATH_SLOW)
            {
                if(DEBUG) DoDebug("prc_inc_breath: slowing breath attack");
            	//prepare effects
                effect eBreath = EffectSlow();
                effect eVis = EffectVisualEffect(VFX_IMP_SLOW);
                effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
                effect eLink = EffectLinkEffects(eBreath, eDur);
                
                //get duration
                int nSlowDuration = BreathUsed.nDiceNumber;
            	
            	//Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(BreathUsed.oDragon, GetSpellId()));
	        
	            if(!PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nSaveDC, SAVING_THROW_TYPE_NONE))
                {
                    //Apply the VFX impact and effects
                    DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nSlowDuration)));
                    SetLocalInt(oTarget, "AffectedByBreath", TRUE);
                }
                //Adept breath effect still lasts for one round if save is made
                else if(IsAdeptBreath())
                {
                    //Apply the VFX impact and effects
                    DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(1)));
                    SetLocalInt(oTarget, "AffectedByBreath", TRUE);
                }
            }
            
            //Gold alternate breath - drains strength
            else if(BreathUsed.nOverrideSpecial == BREATH_WEAKENING)
            {
                if(DEBUG) DoDebug("prc_inc_breath: weakening breath attack");
            	//Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(BreathUsed.oDragon, GetSpellId()));
	        
	            if(!PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nSaveDC, SAVING_THROW_TYPE_NONE))
                {
                    //Set Damage and VFX - Bioware Gold used VFX_IMP_REDUCE_ABILITY_SCORE originally
                    eVis = EffectVisualEffect(VFX_IMP_POISON_L);
                    //Apply the VFX impact and effects
                    DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    //adept breath penalty only last 4 rounds on failure, gold breath has no duration
                    if(IsAdeptBreath())
                        DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectAbilityDecrease(ABILITY_STRENGTH, BreathUsed.nDiceNumber), oTarget, 24.0));
                    else
                        DelayCommand(fDelay, ApplyAbilityDamage(oTarget, ABILITY_STRENGTH, BreathUsed.nDiceNumber, DURATION_TYPE_PERMANENT, TRUE));
                    SetLocalInt(oTarget, "AffectedByBreath", TRUE);
                }
                //Adept breath still happens for 2 rounds on successful save
                else if(IsAdeptBreath())
                {
                    //Set Damage and VFX - Bioware Gold used VFX_IMP_REDUCE_ABILITY_SCORE originally
                    eVis = EffectVisualEffect(VFX_IMP_POISON_L);
                    //Apply the VFX impact and effects
                    DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectAbilityDecrease(ABILITY_STRENGTH, BreathUsed.nDiceNumber), oTarget, 12.0));
                    SetLocalInt(oTarget, "AffectedByBreath", TRUE);
                }
                bCanCling = TRUE;
            }
            
            //Silver alternate breath - paralyze
            else if(BreathUsed.nOverrideSpecial == BREATH_PARALYZE)
            {
                if(DEBUG) DoDebug("prc_inc_breath: paralyzing breath attack");
            	//prepare effects
                effect eBreath = EffectParalyze();
                effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
                effect eDur2 = EffectVisualEffect(VFX_DUR_PARALYZE_HOLD);
                effect eParal = EffectVisualEffect(VFX_DUR_PARALYZED);
    
                effect eLink = EffectLinkEffects(eBreath, eDur);
                eLink = EffectLinkEffects(eLink, eDur2);
                eLink = EffectLinkEffects(eLink, eParal);
                
                //get duration
                int nParalDuration = BreathUsed.nDiceNumber;
            	
            	//Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(BreathUsed.oDragon, GetSpellId()));
	        
	            if(!PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nSaveDC, SAVING_THROW_TYPE_NONE))
                {
                    //Apply the VFX impact and effects
                    DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nParalDuration)));
                    SetLocalInt(oTarget, "AffectedByBreath", TRUE);
                }
            }
            
            //Shadow Dragon breath - drains levels
            else if(BreathUsed.nOverrideSpecial == BREATH_SHADOW)
            {
                if(DEBUG) DoDebug("prc_inc_breath: shadow breath attack");
            	//Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(BreathUsed.oDragon, GetSpellId()));
	        
	            int nLevelDrain = PRCGetReflexAdjustedDamage(nDamage, oTarget, nSaveDC, SAVING_THROW_TYPE_NEGATIVE);
	         
                if (nLevelDrain > 0)
                {
                    //Set Damage and VFX
                    eBreath = EffectNegativeLevel(nLevelDrain);
                    eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
                    //Apply the VFX impact and effects
                    DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eBreath, oTarget));
                    SetLocalInt(oTarget, "AffectedByBreath", TRUE);
                }
            }
            
            //Swift Wing Breath of Life - Positive to Undead only, heals living creatures
            else if(BreathUsed.nOverrideSpecial == BREATH_SWIFT_WING)
            {
                if(DEBUG) DoDebug("prc_inc_breath: swift wing breath attack");
                if(MyPRCGetRacialType(oTarget) == RACIAL_TYPE_UNDEAD || (GetHasFeat(FEAT_TOMB_TAINTED_SOUL, oTarget) && GetAlignmentGoodEvil(oTarget) != ALIGNMENT_GOOD))
                {
                    //Fire cast spell at event for the specified target
                    SignalEvent(oTarget, EventSpellCastAt(BreathUsed.oDragon, GetSpellId()));
                    
    		        nAdjustedDamage = PRCGetReflexAdjustedDamage(nDamage, oTarget, nSaveDC, SAVING_THROW_TYPE_POSITIVE);
		         
	                if (nAdjustedDamage > 0)
	                {
	                    //Set Damage and VFX
	                    eBreath = PRCEffectDamage(oTarget, nAdjustedDamage, BreathUsed.nDamageType);
		 	            eVis = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
	                    //Apply the VFX impact and effects
	                    DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
	                    DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eBreath, oTarget));
                        SetLocalInt(oTarget, "AffectedByBreath", TRUE);
                        bCanCling = TRUE;
	                }
                }
            }

    	    //normal damaging-type breath
	        else
	        {
                 //Fire cast spell at event for the specified target
                 SignalEvent(oTarget, EventSpellCastAt(BreathUsed.oDragon, GetSpellId()));
                 if(DEBUG) DoDebug("prc_inc_breath: normal breath attack");
                     
	        	 if(BreathUsed.nSaveUsed == SAVING_THROW_FORT)
	        	 {
	        	     nAdjustedDamage = nDamage;
	        	     //make a fort save
	        	     if(PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nSaveDC, nSaveDamageType))
                     {
                        //Mettle is Evasion for Fort saves
		                if (GetHasMettle(oTarget, SAVING_THROW_FORT))
		    		        nAdjustedDamage = 0;                              
                            
                        nAdjustedDamage /= 2;
                     }
                 }
	        	 else
	                 nAdjustedDamage = PRCGetReflexAdjustedDamage(nDamage, oTarget, nSaveDC, nSaveDamageType);
	    
	             if (nAdjustedDamage > 0)
	             {
                    if(DEBUG) DoDebug("prc_inc_breath: Damage > 0");
	  	            //Set Damage and VFX
                    if(BreathUsed.nOverrideSpecial == BREATH_PYROCLASTIC)
                    {
            		    int chSaveth;
                		int chVisual;
                		int eleRoll;
                		
                		int nNumDice = d2();
                		//Sets the random Element factor of the Chaos Dragons Breath Weapon.
                		//Affects damage, saving throw, and impact visual.
                		if (nNumDice==1)
                		{
                		    chSaveth = SAVING_THROW_TYPE_SONIC;
                		    chVisual = VFX_IMP_SILENCE;
                		}
                		else if (nNumDice==2)
                		{
                		    chSaveth = SAVING_THROW_TYPE_FIRE;
                		    chVisual = VFX_IMP_FLAME_M;
                		}
                        
                		if(GetLocalInt(oTarget, "DragonWard"))
                            nAdjustedDamage -= 40;
        		    
                        effect eBreath1 = PRCEffectDamage(oTarget, nAdjustedDamage/2, DAMAGE_TYPE_FIRE);
            		    effect eBreath2 = PRCEffectDamage(oTarget, nAdjustedDamage/2, DAMAGE_TYPE_SONIC);
            		    eBreath = EffectLinkEffects(eBreath1, eBreath2);
            		    eVis = EffectVisualEffect(chVisual);
                    }
                    else
                    {
                        if(GetLocalInt(oTarget, "DragonWard"))
                            nAdjustedDamage -= 20;
            		    eBreath = PRCEffectDamage(oTarget, nAdjustedDamage, BreathUsed.nDamageType);
            		    eVis = EffectVisualEffect(nVisualType);
		            }
            		//Apply the VFX impact and effects
            		DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            		DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eBreath, oTarget));
                    SetLocalInt(oTarget, "AffectedByBreath", TRUE);
                    bCanCling = TRUE;
	             }  
	         }
	     
	        //Knockdown check for Tempest Breath
            if(BreathUsed.bTempest && (PRCGetCreatureSize(BreathUsed.oDragon) > CREATURE_SIZE_MEDIUM))
	        {
                if(DEBUG) DoDebug("prc_inc_breath: tempest breath attack");
	        	 if(PRCGetCreatureSize(BreathUsed.oDragon) - PRCGetCreatureSize(oTarget) > 1)
                {
	        	     if(!PRCMySavingThrow(SAVING_THROW_FORT, oTarget, nKnockdownDC, SAVING_THROW_TYPE_NONE))
                    {
                     	 effect eWindblown = EffectKnockdown();
                      	 DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, eWindblown, oTarget, 6.0));
                    }
                }     
	        }
	
    	    //Breath of Life healing
    	    if(oTarget != BreathUsed.oDragon && BreathUsed.nOverrideSpecial == BREATH_SWIFT_WING && MyPRCGetRacialType(oTarget) != RACIAL_TYPE_UNDEAD && MyPRCGetRacialType(oTarget) != RACIAL_TYPE_CONSTRUCT
	           && !(GetHasFeat(FEAT_TOMB_TAINTED_SOUL, oTarget) && GetAlignmentGoodEvil(oTarget) != ALIGNMENT_GOOD))
	        {
                if(DEBUG) DoDebug("prc_inc_breath: breath of life");
	            //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(BreathUsed.oDragon, GetSpellId(), FALSE));
                //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
                //Determine effect delay
                fDelay = GetDistanceBetween(BreathUsed.oDragon, oTarget)/20;
                int nHeal = BreathUsed.nDiceNumber;
                
                //Warforged are only healed for half
                if(GetIsWarforged(oTarget)) nHeal /= 2;
                
                eBreath = PRCEffectHeal(nHeal, oTarget);
                effect eHealVis = EffectVisualEffect(VFX_IMP_HEALING_S);
                DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eBreath, oTarget));
                DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eHealVis, oTarget));
	        }
	
	        //Entangling Exhalation
	        if(GetLocalInt(oTarget, "AffectedByBreath") && BreathUsed.bEntangling)
	        {
                if(DEBUG) DoDebug("prc_inc_breath: entangling breath attack");
	            effect eEntangled = EffectEntangle();
	            effect eEntangleVis = EffectVisualEffect(VFX_DUR_ENTANGLE);
	            eEntangled = EffectLinkEffects(eEntangled, eEntangleVis);
	            int nEntangleRounds = d4();
	            //only does damage if the original breath did damage
	            if(BreathUsed.nDamageType > 0)
	            {
	                effect eDamage = PRCEffectDamage(oTarget, d6(), BreathUsed.nDamageType);
	                switch(nEntangleRounds)
	                {
	            	    case 4:
	            	        DelayCommand(fDelay + RoundsToSeconds(4), SPApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget));
	            	    case 3:
	            	        DelayCommand(fDelay + RoundsToSeconds(3), SPApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget));
	            	    case 2:
	            	        DelayCommand(fDelay + RoundsToSeconds(2), SPApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget));
	            	    case 1:
	            	        DelayCommand(fDelay + RoundsToSeconds(1), SPApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget)); break;
	                }
	            }
	    
	            //but always entangles if the breath affects the target
	            DelayCommand(fDelay, SPApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEntangled, oTarget, RoundsToSeconds(nEntangleRounds)));
	        }
	
	        DeleteLocalInt(oTarget, "AffectedByBreath");
	
	        //Clinging Breath check
	        if(BreathUsed.nClinging > 0 && bCanCling)
	        {
                if(DEBUG) DoDebug("prc_inc_breath: clinging breath attack");
	            int nCount;
	            int AdjustedAbilityDamage = BreathUsed.nDiceNumber;
        
                for(nCount = 0; nCount < BreathUsed.nClinging; nCount++)
	            {
	                float fNewDelay = RoundsToSeconds(nCount + 1);
	                if(BreathUsed.nOverrideSpecial == BREATH_WEAKENING)
	                {
	                    AdjustedAbilityDamage /= 2;
	                    DelayCommand(fNewDelay, ApplyAbilityDamage(oTarget, ABILITY_STRENGTH, BreathUsed.nDiceNumber, DURATION_TYPE_PERMANENT, TRUE));
	                    if(AdjustedAbilityDamage = 1) nCount = BreathUsed.nClinging;
	                }
	                nAdjustedDamage /= 2;
	                if(BreathUsed.nOverrideSpecial == BREATH_PYROCLASTIC)
	                {
	                    if(nAdjustedDamage < 3) nCount = BreathUsed.nClinging;
	    
                        effect eBreath1 = PRCEffectDamage(oTarget, nAdjustedDamage/2, DAMAGE_TYPE_FIRE);
	            	    effect eBreath2 = PRCEffectDamage(oTarget, nAdjustedDamage/2, DAMAGE_TYPE_SONIC);
	            	    effect eAfterBreath = EffectLinkEffects(eBreath1, eBreath2);
	                    DelayCommand(fNewDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eAfterBreath, oTarget));
	                }
	                else
	                {
	                    if(nAdjustedDamage < 2) nCount = BreathUsed.nClinging;
	                    effect eAfterBreath = PRCEffectDamage(oTarget, nAdjustedDamage, BreathUsed.nDamageType);
	                    DelayCommand(fNewDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eAfterBreath, oTarget));
	                }
	                DelayCommand(fNewDelay, SPApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
	            }
	        }   
        }    
	
    //Get next target in spell area
    if(DEBUG) DoDebug("prc_inc_breath: Next target");
    oTarget = GetNextObjectInShape(nBreathShape, fRange, lTargetArea, TRUE, nObjectFilter, vSourceOfBreath);
    }
    
    //Lingering Breath check
    if(BreathUsed.nLingering > 0)
    {
        int nCount;
    	int nLingerDuration = BreathUsed.nLingering;
    	BreathUsed.nLingering = 0;
    	BreathUsed.nClinging = 0;
    	vector vOrigin = GetPosition(BreathUsed.oDragon);
    	effect eGroundVis = EffectVisualEffect(VFX_FNF_DRAGBREATHGROUND);
    
    	for(nCount = 0; nCount < nLingerDuration; nCount++)
	    {
	        float fNewDelay = RoundsToSeconds(nCount + 1);
	        DelayCommand(fNewDelay, ApplyBreath(BreathUsed, lTargetArea, TRUE, vOrigin.x, vOrigin.y, vOrigin.z));
	        DelayCommand(fNewDelay, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eGroundVis, lTargetArea));
	    }
    }
}

void PRCPlayDragonBattleCry()
{
    if(d100() > 50)
    {
        PlayVoiceChat(VOICE_CHAT_BATTLECRY1);
    }
    else
    {
        PlayVoiceChat(VOICE_CHAT_BATTLECRY2);
    }
}

//:: void main() {}