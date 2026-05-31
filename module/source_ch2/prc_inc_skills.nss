//:://////////////////////////////////////////////
/*
    This file is for the code/const for any custom skills.
*/
//:://////////////////////////////////////////////

/** 
 * Returns the height differential between the two locations.
 * Return value is in feet.
 */
float GetHeight(location lPC, location lTarget);

// * Returns true or false depending on whether the creature is flying
// * or not
int PRCIsFlying(object oCreature);

// * Returns true or false depending on whether the creature has flying
// * mount or not
int PRCHasFlyingMount(object oCreature);

#include "prc_inc_clsfunc"
#include "moi_inc_moifunc"
#include "x3_inc_horse"

//:://////////////////////////////////////////////
//:: Skill Functions
//:://////////////////////////////////////////////

// returns true if they pass the jump check
// also handles animations and knockdown
int PerformJump(object oPC, location lLoc, int bDoKnockDown = TRUE)
{
    object oArea = GetArea(oPC);
    int bCanFly = FALSE;
    // if jumping is disabled in this place.
    if( GetLocalInt(oArea, "AreaJumpOff") == TRUE )
    {
        SendMessageToPC(oPC, "Jumping is not allowed in this area.");
        return FALSE;
    }

    // Simulate "leap of the clouds", or RDD's having wings can "fly"
    if((GetLevelByClass(CLASS_TYPE_MONK, oPC) >= 7
       || GetLevelByClass(CLASS_TYPE_NINJA_SPY, oPC) >= 3
       || PRCIsFlying(oPC))
       && GetLocalInt(oArea, "AreaFlyOff") == FALSE)
           bCanFly = TRUE;
           
    // This meld allows someone to fly when bound to a chakra
    if (GetIsMeldBound(oPC, MELD_ACROBAT_BOOTS))
    	bCanFly = TRUE;
    	
    // This meld allows someone to fly when bound to a chakra
    if (GetIsMeldBound(oPC, MELD_MANTICORE_BELT) == CHAKRA_WAIST)
    	bCanFly = TRUE;    	

    //ebonfowl: Can fly temporarily when using Borne Aloft
    if (GetLocalInt(oPC, "BorneAloft"))
        bCanFly = TRUE;

    // can't fly while mounted
    if (HorseGetIsMounted(oPC) && !PRCHasFlyingMount(oPC))
        bCanFly = FALSE;

    // Height restriction on jumping
    if (GetHeight(GetLocation(oPC), lLoc) > 8.0 && !bCanFly)
    {
        SendMessageToPC(oPC, "The target location is too high to jump to. Please pick a lower target.");
        return FALSE;
    }

    // Immobilized creatures can't jump
    effect eCheck = GetFirstEffect(oPC);
    int nCheck;
    while(GetIsEffectValid(eCheck)){
        nCheck = GetEffectType(eCheck);
        if(nCheck == EFFECT_TYPE_CUTSCENEIMMOBILIZE ||
           nCheck == EFFECT_TYPE_ENTANGLE)
        {
            SendMessageToPC(oPC, "You cannot move.");
            return FALSE;
        }

        eCheck = GetNextEffect(oPC);
    }

     int bIsRunningJump = FALSE;
     int bPassedJumpCheck = FALSE;
     int iMinJumpDistance = 0;
     int iMaxJumpDistance = 6;
     int iDivisor = 1;
     int iJumpDistance = 0;
     int bIsInHeavyArmor = FALSE;
     
     // Goliaths and Garguns treat all jumps as running
     if(GetRacialType(oPC) == RACIAL_TYPE_GOLIATH || GetRacialType(oPC) == RACIAL_TYPE_FERAL_GARGUN)
        bIsRunningJump = TRUE;

     int iDistance = FloatToInt(MetersToFeet(GetDistanceBetweenLocations(GetLocation(oPC), lLoc ) ) );

     object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
     int AC = GetBaseAC(oArmor);
     if(AC >= 6) bIsInHeavyArmor = TRUE;

     // Jump check rules depend on a running jump or standing jump
     // running jumps require at least 20 feet run length
     if (iDistance >= 18 && !bIsInHeavyArmor)  bIsRunningJump = TRUE;

     int iBonus = 0;
     if (GetHasFeat(FEAT_GREAT_LEAP, oPC))
     {
        if (Ninja_AbilitiesEnabled(oPC))
        {
            bIsRunningJump = TRUE;
            iBonus += 4;
        }
     }
     if (GetHasSpellEffect(MOVE_TC_LEAPING_DRAGON, oPC))
     {
            bIsRunningJump = TRUE;
            //iBonus += 10; //:: This is handled in the stance now.
     }    
     // PnP rules are height * 6 for run and height * 2 for jump.
     // I can't get height so that is assumed to be 6.
     // Changed maxed jump distance because the NwN distance is rather short
     // at least compared to height it is.
     if(bIsRunningJump)
     {
          iMinJumpDistance = 5;
          iDivisor = 1;
          iMaxJumpDistance *= 6;
     }
     else
     {
          iMinJumpDistance = 3;
          iDivisor = 2;
          iMaxJumpDistance *= 3;
     }

     // skill 28 = jump
     int iJumpRoll = d20() + GetSkillRank(SKILL_JUMP, oPC) + iBonus + GetAbilityModifier(ABILITY_STRENGTH, oPC);
     
     if(bCanFly)
     {
            iMaxJumpDistance *= 100;
            iJumpRoll *= 100;
     }

     // Use Dex instead of Strength
     if (GetHasFeat(FEAT_AGILE_ATHLETE, oPC))
     {
         iJumpRoll -= GetAbilityModifier(ABILITY_STRENGTH, oPC);
         iJumpRoll += GetAbilityModifier(ABILITY_DEXTERITY, oPC);
     }

     if(GetSkillRank(SKILL_TUMBLE, oPC, TRUE) >= 5) iJumpRoll += 2;

     // Jump distance is determined by the number exceeding 10
     // divided based on running or standing jump.
     iJumpRoll -= 10;
     if(iJumpRoll < 1) iJumpRoll = 1;
     iJumpRoll /= iDivisor;
     iJumpDistance = iMinJumpDistance + iJumpRoll;
     
     // Hadozee gliding doubles jump distance
     if(GetRacialType(oPC) == RACIAL_TYPE_HADOZEE)
     {
        iMaxJumpDistance *= 2; 
        iJumpDistance *= 2;
    }    

     if(iJumpDistance >= iDistance && iDistance <= iMaxJumpDistance)
     {
          // they passed jump check
          bPassedJumpCheck = TRUE;

          effect eJump = EffectDisappearAppear(lLoc);
          ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eJump, oPC, 3.1);
     }
     else
     {
          // they failed jump check
          FloatingTextStringOnCreature("Jump check failed.", oPC);
          bPassedJumpCheck = FALSE;

          if(bDoKnockDown)
          {
               effect eKnockDown = EffectKnockdown();
               ApplyEffectToObject(DURATION_TYPE_INSTANT, eKnockDown, oPC);
          }
     }

     return bPassedJumpCheck;
}

float GetHeight(location lPC, location lTarget)
{
    vector vPC = GetPositionFromLocation(lPC);
    vector vTarget = GetPositionFromLocation(lTarget);

    return MetersToFeet(vTarget.z - vPC.z);
}

float GetDistanceForClimbing(object oPC, location lLoc)
{
    object oArea = GetAreaFromLocation(lLoc);
    vector vTest1 = GetPositionFromLocation(GetLocation(oPC));
    vector vTest2 = GetPositionFromLocation(lLoc);
    float fDistance = GetDistanceBetweenLocations(Location(oArea, Vector(vTest1.x, vTest1.y, 0.0), 0.0),
                                                   Location(oArea, Vector(vTest2.x, vTest2.y, 0.0), 0.0));

    return MetersToFeet(fDistance);
}

int DoClimb(object oPC, location lLoc, int bDoKnockDown = TRUE)
{
    // check to see if abort due to being mounted
    if(HorseGetIsMounted(oPC))
        return FALSE; // abort

    // if Climbing is disabled in this place.
    if(GetLocalInt(GetArea(oPC), "AreaClimbOff") == TRUE)
    {
        SendMessageToPC(oPC, "Climbing is not allowed in this area.");
        return FALSE;
    }

    // Immobilized creatures can't Climb
    effect eCheck = GetFirstEffect(oPC);
    int nCheck;
    while(GetIsEffectValid(eCheck))
    {
        nCheck = GetEffectType(eCheck);
        if(nCheck == EFFECT_TYPE_CUTSCENEIMMOBILIZE ||
           nCheck == EFFECT_TYPE_ENTANGLE)
        {
            SendMessageToPC(oPC, "You cannot move.");
            return FALSE;
        }

        eCheck = GetNextEffect(oPC);
    }

    if(GetDistanceForClimbing(oPC, lLoc) > 10.0)
    {
        SendMessageToPC(oPC, "The target location is too far away to climb to. Please pick a closer target.");
        return FALSE;
    }
    // Height restriction on climbing. Has to be at least 5 up or 5 down.
    if(5.0 > GetHeight(GetLocation(oPC), lLoc) && GetHeight(GetLocation(oPC), lLoc) > -5.0)
    {
        SendMessageToPC(oPC, "The target location is too low to climb to. Please pick a higher target.");
        return FALSE;
    }
    int bPassedClimbCheck = FALSE;

    int iClimbRoll = d20() + GetSkillRank(SKILL_CLIMB, oPC) + GetAbilityModifier(ABILITY_STRENGTH, oPC);

    // Flat DC, one of the hardest
    if(iClimbRoll >= 25)
    {
        // they passed Climb check
        bPassedClimbCheck = TRUE;

        effect eClimb = EffectDisappearAppear(lLoc);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eClimb, oPC, 3.1);
    }
    else
    {
        // they failed Climb check
        FloatingTextStringOnCreature("Climb check failed.", oPC);

        if(bDoKnockDown)
        {
            effect eKnockDown = EffectKnockdown();
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockDown, oPC, 5.0);
        }
    }

    return bPassedClimbCheck;
}

// * Returns true or false depending on whether the creature is flying
// * or not
int PRCIsFlying(object oCreature)
{
    int nAppearance = GetAppearanceType(oCreature);
    int nWings = GetCreatureWingType(oCreature);
    int bFlying = FALSE;
    switch(nAppearance)
    {
        case APPEARANCE_TYPE_PARROT:
        case APPEARANCE_TYPE_BAT:
        case APPEARANCE_TYPE_BAT_HORROR:
        case APPEARANCE_TYPE_DRAGON_BLACK:
        case APPEARANCE_TYPE_DRAGON_BLUE:
        case APPEARANCE_TYPE_DRAGON_BRASS:
        case APPEARANCE_TYPE_DRAGON_BRONZE:
        case APPEARANCE_TYPE_DRAGON_COPPER:
        case APPEARANCE_TYPE_DRAGON_GOLD:
        case APPEARANCE_TYPE_DRAGON_GREEN:
        case APPEARANCE_TYPE_DRAGON_PRIS:
        case APPEARANCE_TYPE_DRAGON_RED:
        case APPEARANCE_TYPE_DRAGON_SHADOW:
        case APPEARANCE_TYPE_DRAGON_SILVER:
        case APPEARANCE_TYPE_DRAGON_WHITE:
        case APPEARANCE_TYPE_ELEMENTAL_AIR:
        case APPEARANCE_TYPE_ELEMENTAL_AIR_ELDER:
        case APPEARANCE_TYPE_FAIRY:
        case APPEARANCE_TYPE_GARGOYLE:
        case APPEARANCE_TYPE_HELMED_HORROR:
        case APPEARANCE_TYPE_LANTERN_ARCHON:
        case APPEARANCE_TYPE_QUASIT:
        case APPEARANCE_TYPE_IMP:
        case APPEARANCE_TYPE_MEPHIT_AIR:
        case APPEARANCE_TYPE_MEPHIT_DUST:
        case APPEARANCE_TYPE_MEPHIT_EARTH:
        case APPEARANCE_TYPE_MEPHIT_FIRE:
        case APPEARANCE_TYPE_MEPHIT_ICE:
        case APPEARANCE_TYPE_MEPHIT_MAGMA:
        case APPEARANCE_TYPE_MEPHIT_OOZE:
        case APPEARANCE_TYPE_MEPHIT_SALT:
        case APPEARANCE_TYPE_MEPHIT_STEAM:
        case APPEARANCE_TYPE_MEPHIT_WATER:
        case APPEARANCE_TYPE_WILL_O_WISP:
        case APPEARANCE_TYPE_FALCON:
        case APPEARANCE_TYPE_RAVEN:
        case APPEARANCE_TYPE_SHADOW:
        case APPEARANCE_TYPE_SHADOW_FIEND:
        case APPEARANCE_TYPE_SPECTRE:
        case APPEARANCE_TYPE_SUCCUBUS:
        case APPEARANCE_TYPE_ALLIP:
        case APPEARANCE_TYPE_WRAITH:
        case APPEARANCE_TYPE_SEAGULL_FLYING:
        case APPEARANCE_TYPE_SPHINX:
        case APPEARANCE_TYPE_GYNOSPHINX:
        case APPEARANCE_TYPE_MANTICORE:
        case APPEARANCE_TYPE_COCKATRICE:
        case APPEARANCE_TYPE_FAERIE_DRAGON:
        case APPEARANCE_TYPE_PSEUDODRAGON:
        case APPEARANCE_TYPE_WYRMLING_BLACK:
        case APPEARANCE_TYPE_WYRMLING_BLUE:
        case APPEARANCE_TYPE_WYRMLING_BRASS:
        case APPEARANCE_TYPE_WYRMLING_BRONZE:
        case APPEARANCE_TYPE_WYRMLING_COPPER:
        case APPEARANCE_TYPE_WYRMLING_GOLD:
        case APPEARANCE_TYPE_WYRMLING_GREEN:
        case APPEARANCE_TYPE_WYRMLING_RED:
        case APPEARANCE_TYPE_WYRMLING_SILVER:
        case APPEARANCE_TYPE_WYRMLING_WHITE:
        case APPEARANCE_TYPE_DEVIL:
        case APPEARANCE_TYPE_BEHOLDER:
        case APPEARANCE_TYPE_BEHOLDER_MAGE:
        case APPEARANCE_TYPE_BEHOLDER_EYEBALL:
        case APPEARANCE_TYPE_DRACOLICH:
        case APPEARANCE_TYPE_HARPY:
        case APPEARANCE_TYPE_DEMI_LICH:
        case 455: // Wyvern: Adult
        case 456: // Wyvern: Great
        case 457: // Wyvern: Juvenile
        case 458: // Wyvern: Young
        case APPEARANCE_TYPE_BEHOLDER_MOTHER:
        bFlying = TRUE;
    }
    if(!bFlying
        && ((nWings > 0 && nWings < 79) 
		|| (nWings > 1959 && nWings < 1962) 
		|| (nWings > 1962 && nWings < 1966) 
		|| nWings == 90))//CEP and Project Q wing models
        	bFlying = TRUE;
        
    if (GetHasSpellEffect(MOVE_SH_BALANCE_SKY, oCreature))
        bFlying = TRUE;
        
    if (GetLocalInt(oCreature, "GeryonFlight"))    
        bFlying = TRUE;
        
    if(GetRacialType(oCreature) == RACIAL_TYPE_GLOURA)
    	bFlying = TRUE;

    if(GetRacialType(oCreature) == RACIAL_TYPE_AVARIEL)
    	bFlying = TRUE;
	
	if(GetRacialType(oCreature) == RACIAL_TYPE_FEYRI)
    bFlying = TRUE;
	
	if(GetRacialType(oCreature) == RACIAL_TYPE_SPIRETOPDRAGON)
    	bFlying = TRUE;
        
    return bFlying;
}

int PRCHasFlyingMount(object oCreature)
{
    int nMount = GetCreatureTailType(oCreature);
    int bFlying = FALSE;
    //no flying mounts in original NWN - TODO: add check for CEP mounts
    return bFlying;
}