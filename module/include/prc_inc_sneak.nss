
// * Various functions to determine sneak dice.

// * Used to find the total sneak dice a character is capable of.
int GetTotalSneakAttackDice(object oPC);

// * Used to find the total rogue sneak dice a character is capable of.
// -----------------------------------------------------------------------------------------
// Future PRC's go here.  DO NOT ADD ROGUE/BLACKGUARD/ASSASSIN SNEAK ATTACKS AS CLASS FEATS.
// Placeholder feats are fine, even encouraged.  Example: "Ranged Sneak Attack +1d6".
// The feat should do nothing, just show that you have the bonus.
// -----------------------------------------------------------------------------------------
int GetRogueSneak(object oPC);

// * Used to find the total blackguard sneak dice a character is capable of.
int GetBlackguardSneak(object oPC);

// * Used to find the total assassin sneak dice a character is capable of.
int GetAssassinSneak(object oPC);

// * Used to find how much a character has taken "Improved Sneak Attack".
int GetEpicFeatSneak(object oPC);

//:://////////////////////////////////////////////
//::  Sneak Attack Functions
//:://////////////////////////////////////////////

// Checks if attacker is flanking the defender or not
int GetIsFlanked(object oDefender, object oAttacker);

// Checks if an AoE spell is flanking the defender
int GetIsAOEFlanked(object oDefender, object oAttacker);

// Determines if a creature is helpless.
// (effective dex modifier of 0, and can be Coup De Graced).
int GetIsHelpless(object oDefender);

// Returns if oDefender is denied dex bonus to AC from spells
// int nIgnoreUD - ignores Uncanny Dodge
int GetIsDeniedDexBonusToAC(object oDefender, object oAttacker, int nIgnoreUD = FALSE);

// Returns FALSE if oDefender has no concealment
// or the int amount of concealment on the defender.
int GetIsConcealed(object oDefender, object oAttacker);

// Returns true if the Attacker can Sneak Attack the target
int GetCanSneakAttack(object oDefender, object oAttacker);

// Returns Sneak Attack Damage
int GetSneakAttackDamage(int iSneakAttackDice);

//Returns applicable elemental type for Dragonfire Strike
int GetDragonfireDamageType(object oPC);

// * Used to find the total favoured enemy bonus a character is capable of.
int GetFavouredEnemyBonus(object oPC);

//:://////////////////////////////////////////////
//::  Includes
//:://////////////////////////////////////////////

//#include "prc_class_const"
//#include "prc_feat_const"
#include "tob_move_const"
#include "prc_x2_itemprop"

//:://////////////////////////////////////////////
//::  Definitions
//:://////////////////////////////////////////////

int GetTotalSneakAttackDice(object oPC)
{
     int iSneakAttackDice = GetRogueSneak(oPC) + GetBlackguardSneak(oPC) +
                            GetAssassinSneak(oPC) + GetEpicFeatSneak(oPC);
     return iSneakAttackDice;
}

int GetRogueSneak(object oPC)
{
   object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
   int nWeaponType = GetBaseItemType(oWeapon);

   int iClassLevel;
   int iRogueSneak = 0;

   // Rogue
   iClassLevel = GetLevelByClass(CLASS_TYPE_ROGUE, oPC);
   // Daring Outlaw
   if (iClassLevel && GetHasFeat(FEAT_DARING_OUTLAW, oPC))
        iClassLevel += GetLevelByClass(CLASS_TYPE_SWASHBUCKLER, oPC);
   if (iClassLevel) iRogueSneak += (iClassLevel + 1) / 2;

   // Arcane Trickster (Epic)
   iClassLevel = GetLevelByClass(CLASS_TYPE_ARCTRICK, oPC);
   if (iClassLevel >= 12) iRogueSneak += (iClassLevel - 10) / 2;

   // Black Flame Zealot
   iClassLevel = GetLevelByClass(CLASS_TYPE_BFZ, oPC);
   if (iClassLevel) iRogueSneak += iClassLevel / 3;

   // Nightshade
   iClassLevel = GetLevelByClass(CLASS_TYPE_NIGHTSHADE, oPC);
   if (iClassLevel) iRogueSneak += iClassLevel / 3;

   // Outlaw Crimson Road
   //iClassLevel = GetLevelByClass(CLASS_TYPE_OUTLAW_CRIMSON_ROAD, oPC);
   //if (iClassLevel) iRogueSneak += (iClassLevel + 1) / 2;

   // Temple Raider
   //iClassLevel = GetLevelByClass(CLASS_TYPE_TEMPLE_RAIDER, oPC);
   //if (iClassLevel>= 2) iRogueSneak += (iClassLevel + 1) / 3;

   // Ghost-Faced Killer
   iClassLevel = GetLevelByClass(CLASS_TYPE_GHOST_FACED_KILLER, oPC);
   if (iClassLevel >= 2) iRogueSneak += ((iClassLevel + 1) / 3);

   // Ninja
   iClassLevel = GetLevelByClass(CLASS_TYPE_NINJA, oPC);
   if (iClassLevel) iRogueSneak += (iClassLevel + 1) / 2;
   
   // Shadow Thief of Amn
   iClassLevel = GetLevelByClass(CLASS_TYPE_SHADOW_THIEF_AMN, oPC);
   if (iClassLevel) iRogueSneak += (iClassLevel + 1) / 2;   

   // Slayer of Domiel
   iClassLevel = GetLevelByClass(CLASS_TYPE_SLAYER_OF_DOMIEL, oPC);
   if (iClassLevel) iRogueSneak += (iClassLevel + 1) / 2;
   
   // Crinti Shadow Marauder
   iClassLevel = GetLevelByClass(CLASS_TYPE_CRINTI_SHADOW_MARAUDER, oPC);
   if (iClassLevel) iRogueSneak += iClassLevel / 2;   
   
   // Cultist of the Shattered Peak
   iClassLevel = GetLevelByClass(CLASS_TYPE_CULTIST_SHATTERED_PEAK, oPC);
   if (iClassLevel) iRogueSneak += iClassLevel / 2;      

   // Skullclan Hunter
   iClassLevel = GetLevelByClass(CLASS_TYPE_SKULLCLAN_HUNTER, oPC);
   if (iClassLevel) iRogueSneak += iClassLevel / 3;

   // Shadowmind
   iClassLevel = GetLevelByClass(CLASS_TYPE_SHADOWMIND, oPC);
   if (iClassLevel) iRogueSneak += (iClassLevel + 1) / 2;

   // Psychic Rogue
   iClassLevel = GetLevelByClass(CLASS_TYPE_PSYCHIC_ROGUE, oPC);
   if (iClassLevel) iRogueSneak += (iClassLevel + 2) / 3;
   
   // Unseen Seer
   iClassLevel = GetLevelByClass(CLASS_TYPE_UNSEEN_SEER, oPC);
   if (iClassLevel) iRogueSneak += (iClassLevel + 2) / 3;   

   // Fist of Dal Quor
   iClassLevel = GetLevelByClass(CLASS_TYPE_FIST_DAL_QUOR, oPC);
   if (iClassLevel) iRogueSneak += (iClassLevel + 1) / 2;
   
   // Umbral Disciple
   iClassLevel = GetLevelByClass(CLASS_TYPE_UMBRAL_DISCIPLE, oPC);
   if (iClassLevel) iRogueSneak += (iClassLevel + 1) / 3;   

	// Dragon Devotee and Hand of the Winged Masters
	int nBonusFeatDice = 0;
	int nCount;

	// First check for 10d6 to 6d6 (second 2DA range: 24905–24901)
	for(nCount = FEAT_SPECIAL_SNEAK_ATTACK_10D6; nCount >= FEAT_SPECIAL_SNEAK_ATTACK_6D6; nCount--)
	{
		if (GetHasFeat(nCount, oPC))
		{
			nBonusFeatDice = nCount - FEAT_SPECIAL_SNEAK_ATTACK_6D6 + 6;
			//if (DEBUG) DoDebug("prc_inc_sneak: Bonus Sneak Dice: " + IntToString(nBonusFeatDice));
			break;
		}
	}
	// If nothing found yet, check original range 5d6 to 1d6
	if (nBonusFeatDice == 0)
	{
		for(nCount = FEAT_SPECIAL_SNEAK_ATTACK_5D6; nCount >= FEAT_SPECIAL_SNEAK_ATTACK_1D6; nCount--)
		{
			if (GetHasFeat(nCount, oPC))
			{
				nBonusFeatDice = nCount - FEAT_SPECIAL_SNEAK_ATTACK_1D6 + 1;
				//if (DEBUG) DoDebug("prc_inc_sneak: Bonus Sneak Dice: " + IntToString(nBonusFeatDice));
				break;
			}
		}
	}

/*    //Dragon Devotee and Hand of the Winged Masters
   int nBonusFeatDice = 0;
   int nCount;
   for(nCount = FEAT_SPECIAL_SNEAK_ATTACK_5D6; nCount >= FEAT_SPECIAL_SNEAK_ATTACK_1D6; nCount--)
   {
      if (GetHasFeat(nCount,oPC))
      {
         nBonusFeatDice = nCount - FEAT_SPECIAL_SNEAK_ATTACK_1D6 + 1;
         //if (DEBUG) DoDebug("prc_inc_sneak: Bonus Sneak Dice: " + IntToString(nBonusFeatDice));
         break;
      }
   } */
   
	//:: Shadowbane Inquisitor
	iClassLevel = GetLevelByClass(CLASS_TYPE_SHADOWBANE_INQUISITOR, oPC);
	if (iClassLevel >= 4)
	{
		iRogueSneak += 1 + (iClassLevel - 4) / 3;
	}  

/*    // Shadowbane Inquisitor
   iClassLevel = GetLevelByClass(CLASS_TYPE_SHADOWBANE_INQUISITOR, oPC);
   if (iClassLevel >= 4) iRogueSneak++;
   if (iClassLevel >= 7) iRogueSneak++;
   if (iClassLevel >= 10) iRogueSneak++; */
   
   // Shadowbane Stalker
   iClassLevel = GetLevelByClass(CLASS_TYPE_SHADOWBANE_STALKER, oPC);
   if (iClassLevel) iRogueSneak += iClassLevel / 3;   
   
   //Naztharune Rakshasa racial sneak attack
   if(GetHasFeat(FEAT_RACIAL_SNEAK_6D6)) iRogueSneak += 6;
   
   if (GetRacialType(oPC) == RACIAL_TYPE_MARRULURK) iRogueSneak += 2;

   if(nWeaponType == BASE_ITEM_LONGBOW || nWeaponType == BASE_ITEM_SHORTBOW)
   {
      // Peerless Archer
      iClassLevel = GetLevelByClass(CLASS_TYPE_PEERLESS, oPC);
      if (iClassLevel) iRogueSneak += (iClassLevel + 2) / 3;
   }
   else if(nWeaponType == BASE_ITEM_SLING)
   {
      // Halfling Warslinger
      iClassLevel = GetLevelByClass(CLASS_TYPE_HALFLING_WARSLINGER, oPC);
      if (iClassLevel) iRogueSneak += (iClassLevel + 1) / 2;
   }
   else if(nWeaponType == BASE_ITEM_WHIP)
   {
      // Lasher
      iClassLevel = GetLevelByClass(CLASS_TYPE_LASHER, oPC);
      if (iClassLevel > 0) iRogueSneak += ((iClassLevel - 1) / 4) + 1;
   }

   //Justice of Weald and Woe
   iClassLevel = GetLevelByClass(CLASS_TYPE_JUSTICEWW, oPC);
   if(iClassLevel > 1) iRogueSneak++;
   if(iClassLevel > 6) iRogueSneak++;

   //Shadowblade
   iClassLevel = GetLevelByClass(CLASS_TYPE_SHADOWBLADE, oPC);
   if (iClassLevel) iRogueSneak += (iClassLevel + 1) / 2;


   if(GetHasSpellEffect(MOVE_SH_ASSASSINS_STANCE, oPC))
   {
       iRogueSneak += 2;
   }
   
   if(GetLocalInt(oPC, "SacredStrike"))
   {
       iRogueSneak += GetLocalInt(oPC, "SacredStrike");
   }   
   if(GetLocalInt(oPC, "PsyRogueSneak"))
   {
       iRogueSneak += GetLocalInt(oPC, "PsyRogueSneak");
   } 
   if(GetLocalInt(oPC, "CunningStrike"))
   {
       iRogueSneak += 1;
   }  
   if(GetLocalInt(oPC, "UmbralSneak"))
   {
       iRogueSneak += GetLocalInt(oPC, "UmbralSneak");
   }  
   if(GetLocalInt(oPC, "MalphasSneak"))
   {
       iRogueSneak += GetLocalInt(oPC, "MalphasSneak");
   }  
   if(GetLocalInt(oPC, "AndroSneak"))
   {
       iRogueSneak += GetLocalInt(oPC, "AndroSneak");
   }     
   if (GetLocalInt(oPC, "FactotumSneak"))
   {
   	   iRogueSneak += (GetLevelByClass(CLASS_TYPE_FACTOTUM, oPC) + 1) / 2;
   }   
   
   if(iRogueSneak > 0) //the feats only apply if you already have Sneak Attack
       iRogueSneak += nBonusFeatDice;   

   // -----------------------------------------------------------------------------------------
   // Future PRC's go here.  DO NOT ADD ROGUE/BLACKGUARD/ASSASSIN SNEAK ATTACKS AS CLASS FEATS.
   // Placeholder feats are fine, even encouraged.  Example: "Ranged Sneak Attack +1d6".
   // The feat should do nothing, just show that you have the bonus.
   // -----------------------------------------------------------------------------------------

   //if (DEBUG) DoDebug("prc_inc_sneak: Rogue Sneak Dice: " + IntToString(iRogueSneak));
   return iRogueSneak;
}

// --------------------------------------------------
// PLEASE DO NOT ADD ANY NEW CLASSES TO THIS FUNCTION
// --------------------------------------------------
int GetBlackguardSneak(object oPC)
{
   int iClassLevel;
   int iBlackguardSneak = 0;

   // Blackguard
   iClassLevel = GetLevelByClass(CLASS_TYPE_BLACKGUARD, oPC);
   if (iClassLevel) iBlackguardSneak += (iClassLevel - 1) / 3;
   if ((iClassLevel) && (GetLevelByClass(CLASS_TYPE_PALADIN) >= 5)) iBlackguardSneak++;  // bonus for pal/bg

   // Ninja Spy
   iClassLevel = GetLevelByClass(CLASS_TYPE_NINJA_SPY, oPC);
   if (iClassLevel) iBlackguardSneak += (iClassLevel + 1) / 3;

   // Arcane Trickster (Pre-Epic)
   iClassLevel = GetLevelByClass(CLASS_TYPE_ARCTRICK, oPC);
   if ((iClassLevel >= 2) && (iClassLevel < 11)) iBlackguardSneak += iClassLevel / 2;
   if (iClassLevel >= 11) iBlackguardSneak += 5;

	//:: Disciple of Baalzebul
	iClassLevel = GetLevelByClass(CLASS_TYPE_DISC_BAALZEBUL, oPC);
	if (iClassLevel >= 2)
	{
		iBlackguardSneak += 1 + (iClassLevel - 2) / 3;
	}

/* // Disciple of Baalzebul
   iClassLevel = GetLevelByClass(CLASS_TYPE_DISC_BAALZEBUL, oPC);
   if ((iClassLevel >= 2) && (iClassLevel < 5)) iBlackguardSneak++;
   if ((iClassLevel >= 5) && (iClassLevel < 8)) iBlackguardSneak += 2;
   if (iClassLevel >= 8) iBlackguardSneak += 3; */

   //if (DEBUG) DoDebug("prc_inc_sneak: Blackguard Sneak Dice: " + IntToString(iBlackguardSneak));
   return iBlackguardSneak;
}

// --------------------------------------------------
// PLEASE DO NOT ADD ANY NEW CLASSES TO THIS FUNCTION
// --------------------------------------------------
int GetAssassinSneak(object oPC)
{
   int iClassLevel;
   int iAssassinSneakDice = 0;

   // Assassin
   iClassLevel = GetLevelByClass(CLASS_TYPE_ASSASSIN, oPC);
   if (iClassLevel) iAssassinSneakDice += (iClassLevel + 1) / 2;

   // Telflammar Shadowlord
   if(GetLevelByClass(CLASS_TYPE_SHADOWLORD, oPC) > 5) iAssassinSneakDice++;

   //if (DEBUG) DoDebug("prc_inc_sneak: Assassin Sneak Dice: " + IntToString(iAssassinSneakDice));
   return iAssassinSneakDice;
}

int GetEpicFeatSneak(object oPC)
{
   int iEpicFeatDice = 0;
   int iCount;

   // Basically searches top-down for improved sneak attack feats until it finds one.
   for(iCount = FEAT_EPIC_IMPROVED_SNEAK_ATTACK_10; iCount >= FEAT_EPIC_IMPROVED_SNEAK_ATTACK_1; iCount--)
   {
      if (GetHasFeat(iCount,oPC))
      {
         iEpicFeatDice = (iCount + 1) - FEAT_EPIC_IMPROVED_SNEAK_ATTACK_1;
         break;
      }
   }

   //if (DEBUG) DoDebug("prc_inc_sneak: Epic Sneak Dice: " + IntToString(iEpicFeatDice));
   return iEpicFeatDice;
}

//:://////////////////////////////////////////////
//::  Sneak Attack Function Definitions
//:://////////////////////////////////////////////

int GetIsFlanked(object oDefender, object oAttacker)
{
    int bReturnVal = FALSE;
    //if (DEBUG) DoDebug("Starting GetIsFlanked");

    if(GetIsObjectValid(oAttacker) && GetIsObjectValid(oDefender))
    {
        // I am assuming that if the Defender is facing away from the
        // Attacker then the Defender is flanked, as NWN "turns" an
        // attacker towards the defender

        vector vDefender = AngleToVector(GetFacing(oDefender));
        vector vAttacker = AngleToVector(GetFacing(oAttacker));
        vector vResult = vDefender + vAttacker;
        //if (DEBUG) DoDebug("GetIsFlanked: End Section #1");
        float iMagDefender = VectorMagnitude(vDefender);
        float iMagResult = VectorMagnitude(vResult);

        // If the magnitude of the Defenders facing vector is greater than the
        // result of the magnitude of the vector addition of the Attackers and
        // Defenders facing then the Defender is flanked.

        if(iMagDefender < iMagResult)
        {
             bReturnVal = TRUE;
        }
    }
//if (DEBUG) DoDebug("GetIsFlanked: End Section #2");
    return bReturnVal;
}

// Checks if an AoE spell is against someone distracted in meleee combat
int GetIsAOEFlanked(object oDefender, object oAttacker)
{
    int bReturnVal = TRUE;

    // if they are not in combat then they are automatically flanked (surprise round)
    if(!PRCGetIsFighting(oDefender) || !GetIsInCombat(oDefender) )
    {
         // checks if they are attacking something other than the caster
         object oTarget = GetAttackTarget(oDefender);
         if(oTarget == oAttacker)  bReturnVal = FALSE;
    }

    return bReturnVal;
}

int GetIsHelpless(object oDefender)
{
    // Does not apply when grappled
    if (GetLocalInt(oDefender, "IsGrappled") && !GetLocalInt(oDefender, "UnconsciousGrapple")) return FALSE;

     // PnP describes a helpless defender as
     // A helpless foe - one who is bound, held, sleeping, paralyzed,
     // unconscious, or otherwise at your mercy - is an easy target.
     return ( PRCGetHasEffect(EFFECT_TYPE_PARALYZE,          oDefender)
            || PRCGetHasEffect(EFFECT_TYPE_SLEEP,             oDefender)
            || PRCGetHasEffect(EFFECT_TYPE_PETRIFY,           oDefender)
            || PRCGetHasEffect(EFFECT_TYPE_CUTSCENE_PARALYZE, oDefender) );
}

int GetIsDeniedDexBonusToAC(object oDefender, object oAttacker, int nIgnoreUD = FALSE)
{
     int bIsDeniedDex = FALSE;
     int bDefenderHasTrueSight = PRCGetHasEffect(EFFECT_TYPE_TRUESEEING, oDefender);
     int bDefenderCanSeeInvisble = PRCGetHasEffect(EFFECT_TYPE_SEEINVISIBLE, oDefender);
     int bDefenderIsKnockedDown = GetHasFeatEffect(FEAT_KNOCKDOWN, oDefender) || GetHasFeatEffect(FEAT_IMPROVED_KNOCKDOWN, oDefender);

     // if the player is helpess, they are automatically denied dex bonus.
     if( GetIsHelpless(oDefender) ) return TRUE;
     
     // Forces it
     if (GetLocalInt(oAttacker, "PRC_SB_UNEXPECTED")) return TRUE;

     // if the player is not fighting, then this is the "surprise round"
     if( !PRCGetIsFighting(oDefender) || !GetIsInCombat(oDefender) )
     {
          bIsDeniedDex = TRUE;
     }

     // In NwN, knocked down targets are counted as denied dex bonus to AC.
     if( bDefenderIsKnockedDown ) bIsDeniedDex = TRUE;

     // if defender has spell effect on them causing them to be denied dex bonus to AC.
     if( PRCGetHasEffect(EFFECT_TYPE_BLINDNESS, oDefender) )          bIsDeniedDex = TRUE;
     else if( PRCGetHasEffect(EFFECT_TYPE_ENTANGLE, oDefender) )      bIsDeniedDex = TRUE;
     else if( PRCGetHasEffect(EFFECT_TYPE_FRIGHTENED, oDefender) )    bIsDeniedDex = TRUE;
     else if( PRCGetHasEffect(EFFECT_TYPE_STUNNED, oDefender) )       bIsDeniedDex = TRUE;

     // Note: This is wrong by PnP rules... but Bioware allows auto sneaks on Dazed targets.
     //       to keep in tune with the game engine I'll leave this active.
     else if( PRCGetHasEffect(EFFECT_TYPE_DAZED, oDefender) )         bIsDeniedDex = TRUE;

     // if attacker is invisvisible/hiding/etc.
     else if( PRCGetHasEffect(EFFECT_TYPE_INVISIBILITY, oAttacker)  && !bDefenderHasTrueSight && !bDefenderCanSeeInvisble )
     {
          bIsDeniedDex = TRUE;
     }
     else if( PRCGetHasEffect(EFFECT_TYPE_IMPROVEDINVISIBILITY, oAttacker)  && !bDefenderHasTrueSight && !bDefenderCanSeeInvisble )
     {
          bIsDeniedDex = TRUE;
     }
     else if( !GetObjectSeen(oAttacker, oDefender) )
     {
          bIsDeniedDex = TRUE;
     }

     // Check for Uncanny Dodge Vs. Sneak Attack.
     if( GetHasFeat(FEAT_UNCANNY_DODGE_2, oDefender) && !nIgnoreUD )
     {
          if(GetLevelByClass(CLASS_TYPE_DWARVENDEFENDER, oDefender))
              return FALSE;

          // +4 because a rogue has to be 4 levels higher to flank
          int iUncannyDodgeLevels = GetLevelByClass(CLASS_TYPE_ASSASSIN    , oDefender)
                                  + GetLevelByClass(CLASS_TYPE_BARBARIAN   , oDefender)
                                  + GetLevelByClass(CLASS_TYPE_PSYCHIC_ROGUE    , oDefender)
                                  + GetLevelByClass(CLASS_TYPE_ROGUE       , oDefender)
                                  + GetLevelByClass(CLASS_TYPE_SHADOWDANCER, oDefender)
                                  + 4;

          int iSneakAttackLevels = GetLevelByClass(CLASS_TYPE_BOWMAN             , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_NINJA              , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_PSYCHIC_ROGUE           , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_ROGUE              , oAttacker)

                                 // add other sneak attacking PrC's here
                                 + GetLevelByClass(CLASS_TYPE_ARCTRICK           , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_ASSASSIN           , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_BFZ                , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_BLACKGUARD         , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_BLARCHER           , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_DISC_BAALZEBUL     , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_FIST_DAL_QUOR      , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_GHOST_FACED_KILLER , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_HALFLING_WARSLINGER, oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_JUSTICEWW          , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_LASHER             , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_NIGHTSHADE         , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_NINJA_SPY          , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_PEERLESS           , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_SHADOWBLADE        , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_SHADOWLORD         , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_SHADOWMIND         , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_SKULLCLAN_HUNTER   , oAttacker)
                                 + GetLevelByClass(CLASS_TYPE_SLAYER_OF_DOMIEL   , oAttacker);

          if(iUncannyDodgeLevels > iSneakAttackLevels)
          {
               bIsDeniedDex = FALSE;
          }
     }

     return bIsDeniedDex;
}

int GetIsConcealed(object oDefender, object oAttacker)
{
     int bIsConcealed = FALSE;

     int bAttackerHasTrueSight = PRCGetHasEffect(EFFECT_TYPE_TRUESEEING, oAttacker);
     int bAttackerCanSeeInvisble = PRCGetHasEffect(EFFECT_TYPE_SEEINVISIBLE, oAttacker);
     int bAttackerUltraVision = PRCGetHasEffect(EFFECT_TYPE_ULTRAVISION, oAttacker);

     if(GetHasFeat(FEAT_EPIC_SELF_CONCEALMENT_50, oDefender) )          bIsConcealed = 50;
     else if(GetHasFeat(FEAT_EPIC_SELF_CONCEALMENT_40, oDefender) )     bIsConcealed = 40;
     else if(GetHasFeat(FEAT_EPIC_SELF_CONCEALMENT_30, oDefender) )     bIsConcealed = 30;
     else if(GetHasFeat(FEAT_EPIC_SELF_CONCEALMENT_20, oDefender) )     bIsConcealed = 20;
     else if(GetHasFeat(FEAT_EPIC_SELF_CONCEALMENT_10, oDefender) )     bIsConcealed = 10;

     // darkness, invisible, imp invisible
     else if(GetStealthMode(oDefender) == STEALTH_MODE_ACTIVATED && !GetObjectSeen(oDefender, oAttacker) )  bIsConcealed = TRUE;
     else if(PRCGetHasEffect(EFFECT_TYPE_SANCTUARY, oDefender) && !bAttackerHasTrueSight )
     {
          // if they player is hidden you know enough to try attacking, give 50% miss chance
          // as that is the highest concealment normally allowed.
          // couldn't find any rules that governed this though.
          bIsConcealed = 50;
     }
     else if(PRCGetHasEffect(EFFECT_TYPE_INVISIBILITY, oDefender) && !bAttackerHasTrueSight && !bAttackerCanSeeInvisble )
     {
          bIsConcealed = 50;
     }
     else if(PRCGetHasEffect(EFFECT_TYPE_IMPROVEDINVISIBILITY, oDefender) && !bAttackerHasTrueSight && !bAttackerCanSeeInvisble  )
     {
          bIsConcealed = 50;
     }
     else if(PRCGetHasEffect(EFFECT_TYPE_DARKNESS, oDefender) && !bAttackerHasTrueSight && !bAttackerUltraVision)
     {
          bIsConcealed = 50;
     }
     else if(GetHasFeatEffect(FEAT_EMPTY_BODY, oDefender) )
     {
          bIsConcealed = 50;
     }
     //else if(PRCGetHasEffect(EFFECT_TYPE_ETHEREAL, oDefender) && !bAttackerHasTrueSight && !bAttackerCanSeeInvisble  )
     //{
     //     bIsConcealed = TRUE;
     //}

     // spell effects
     else if(GetHasSpellEffect(1764 , oDefender) && !bAttackerHasTrueSight) // blur spell
     {
          bIsConcealed = 20;
     }
     else if(GetHasSpellEffect(SPELL_DISPLACEMENT , oDefender) && !bAttackerHasTrueSight)
     {
          bIsConcealed = 50;
     }
     else if(GetHasSpellEffect(SPELL_SHADOW_EVADE , oDefender) && !bAttackerHasTrueSight)
     {
          int iSDlevel = GetLevelByClass(CLASS_TYPE_SHADOWDANCER, oDefender);
          if(iSDlevel <= 4)  bIsConcealed = 5;
          if(iSDlevel <= 6)  bIsConcealed = 10;
          if(iSDlevel <= 8)  bIsConcealed = 15;
          if(iSDlevel <= 10) bIsConcealed = 20;
     }

     // this is the catch-all effect
     else if(PRCGetHasEffect(EFFECT_TYPE_CONCEALMENT, oDefender) && !bAttackerHasTrueSight)
     {
          if(bIsConcealed == FALSE) bIsConcealed = TRUE;
     }
     
     if(GetLocalInt(oAttacker, "PRC_SB_UNERRING"))
     {
             bIsConcealed = FALSE;
             return bIsConcealed;
     }
     return bIsConcealed;
}

int GetCanSneakAttack(object oDefender, object oAttacker)
{
    //cant sneak non-creatures
     if(GetObjectType(oDefender) != OBJECT_TYPE_CREATURE)
        return FALSE;
     
     // Can't sneak attack if you're in a grapple
     if(GetLocalInt(oAttacker, "IsGrappled"))
        return FALSE;

     int bReturnVal = FALSE;
     int bIsInRange = FALSE;
     int bIsFlanked = GetIsFlanked(oDefender, oAttacker);
     int bIsDeniedDex = GetIsDeniedDexBonusToAC(oDefender, oAttacker);

     float fDistance = GetDistanceBetween(oAttacker, oDefender);
     if(fDistance <= FeetToMeters(30.0f) )     bIsInRange = TRUE;

     // Is only run if enemy is indeed flanked or denied dex bonus to AC
     // otherwise there is no reason to check further
     if(bIsFlanked || bIsDeniedDex && bIsInRange)
     {
          // so far they can be sneaked
          bReturnVal = TRUE;

          // checking for other factors that remove sneak attack
          if( GetIsImmune(oDefender, IMMUNITY_TYPE_CRITICAL_HIT, OBJECT_INVALID) )   bReturnVal = FALSE;
          if( GetIsImmune(oDefender, IMMUNITY_TYPE_SNEAK_ATTACK, OBJECT_INVALID) )   bReturnVal = FALSE;
          // Skullclan Hunters can sneak attack undead, so they return true here.
          if( GetLevelByClass(CLASS_TYPE_SKULLCLAN_HUNTER, oAttacker) && GetRacialType(oDefender) == RACIAL_TYPE_UNDEAD) bReturnVal = TRUE;

          if( GetIsConcealed(oDefender, oAttacker) )
          bReturnVal = FALSE;
     }

     return bReturnVal;
}

int GetSneakAttackDamage(int iSneakAttackDice)
{
     int iSneakAttackDamage = d6(iSneakAttackDice);
     return iSneakAttackDamage;
}

int GetDragonfireDamageType(object oPC)
{
     //Elemental Immunities for various dragon types.
    int iType = GetHasFeat(FEAT_BLACK_DRAGON, oPC)          ? DAMAGE_TYPE_ACID :
                GetHasFeat(FEAT_BROWN_DRAGON, oPC)          ? DAMAGE_TYPE_ACID :
                GetHasFeat(FEAT_COPPER_DRAGON, oPC)         ? DAMAGE_TYPE_ACID :
                GetHasFeat(FEAT_GREEN_DRAGON, oPC)          ? DAMAGE_TYPE_ACID :
                GetHasFeat(FEAT_BRASS_DRAGON, oPC)          ? DAMAGE_TYPE_FIRE :
                GetHasFeat(FEAT_GOLD_DRAGON, oPC)           ? DAMAGE_TYPE_FIRE :
                GetHasFeat(FEAT_RED_DRAGON, oPC)            ? DAMAGE_TYPE_FIRE :
                GetHasFeat(FEAT_LUNG_WANG_DRAGON, oPC)      ? DAMAGE_TYPE_FIRE :
                GetHasFeat(FEAT_BATTLE_DRAGON, oPC)         ? DAMAGE_TYPE_SONIC :
                GetHasFeat(FEAT_EMERALD_DRAGON, oPC)        ? DAMAGE_TYPE_SONIC :
                GetHasFeat(FEAT_HOWLING_DRAGON, oPC)        ? DAMAGE_TYPE_SONIC :
                GetHasFeat(FEAT_BLUE_DRAGON, oPC)           ? DAMAGE_TYPE_ELECTRICAL :
                GetHasFeat(FEAT_BRONZE_DRAGON, oPC)         ? DAMAGE_TYPE_ELECTRICAL :
                GetHasFeat(FEAT_OCEANUS_DRAGON, oPC)        ? DAMAGE_TYPE_ELECTRICAL :
                GetHasFeat(FEAT_SAPPHIRE_DRAGON, oPC)       ? DAMAGE_TYPE_ELECTRICAL :
                GetHasFeat(FEAT_SONG_DRAGON, oPC)           ? DAMAGE_TYPE_ELECTRICAL :
                GetHasFeat(FEAT_SHEN_LUNG_DRAGON, oPC)      ? DAMAGE_TYPE_ELECTRICAL :
                GetHasFeat(FEAT_CRYSTAL_DRAGON, oPC)        ? DAMAGE_TYPE_COLD :
                GetHasFeat(FEAT_TOPAZ_DRAGON, oPC)          ? DAMAGE_TYPE_COLD :
                GetHasFeat(FEAT_SILVER_DRAGON, oPC)         ? DAMAGE_TYPE_COLD :
                GetHasFeat(FEAT_WHITE_DRAGON, oPC)          ? DAMAGE_TYPE_COLD :
                GetHasFeat(FEAT_DRACONIC_HERITAGE_BK, oPC)  ? DAMAGE_TYPE_ACID :
                GetHasFeat(FEAT_DRACONIC_HERITAGE_CP, oPC)  ? DAMAGE_TYPE_ACID :
                GetHasFeat(FEAT_DRACONIC_HERITAGE_GR, oPC)  ? DAMAGE_TYPE_ACID :
                GetHasFeat(FEAT_DRACONIC_HERITAGE_BS, oPC)  ? DAMAGE_TYPE_FIRE :
                GetHasFeat(FEAT_DRACONIC_HERITAGE_GD, oPC)  ? DAMAGE_TYPE_FIRE :
                GetHasFeat(FEAT_DRACONIC_HERITAGE_RD, oPC)  ? DAMAGE_TYPE_FIRE :
                GetHasFeat(FEAT_DRACONIC_HERITAGE_EM, oPC)  ? DAMAGE_TYPE_SONIC :
                GetHasFeat(FEAT_DRACONIC_HERITAGE_BL, oPC)  ? DAMAGE_TYPE_ELECTRICAL :
                GetHasFeat(FEAT_DRACONIC_HERITAGE_BZ, oPC)  ? DAMAGE_TYPE_ELECTRICAL :
                GetHasFeat(FEAT_DRACONIC_HERITAGE_SA, oPC)  ? DAMAGE_TYPE_ELECTRICAL :
                GetHasFeat(FEAT_DRACONIC_HERITAGE_CR, oPC)  ? DAMAGE_TYPE_COLD :
                GetHasFeat(FEAT_DRACONIC_HERITAGE_TP, oPC)  ? DAMAGE_TYPE_COLD :
                GetHasFeat(FEAT_DRACONIC_HERITAGE_SR, oPC)  ? DAMAGE_TYPE_COLD :
                GetHasFeat(FEAT_DRACONIC_HERITAGE_WH, oPC)  ? DAMAGE_TYPE_COLD :
                GetHasFeat(FEAT_KOB_DRAGONWROUGHT_BK, oPC)  ? DAMAGE_TYPE_ACID :
                GetHasFeat(FEAT_KOB_DRAGONWROUGHT_CP, oPC)  ? DAMAGE_TYPE_ACID :
                GetHasFeat(FEAT_KOB_DRAGONWROUGHT_GR, oPC)  ? DAMAGE_TYPE_ACID :
                GetHasFeat(FEAT_KOB_DRAGONWROUGHT_BS, oPC)  ? DAMAGE_TYPE_FIRE :
                GetHasFeat(FEAT_KOB_DRAGONWROUGHT_GD, oPC)  ? DAMAGE_TYPE_FIRE :
                GetHasFeat(FEAT_KOB_DRAGONWROUGHT_RD, oPC)  ? DAMAGE_TYPE_FIRE :
                GetHasFeat(FEAT_KOB_DRAGONWROUGHT_EM, oPC)  ? DAMAGE_TYPE_SONIC :
                GetHasFeat(FEAT_KOB_DRAGONWROUGHT_BL, oPC)  ? DAMAGE_TYPE_ELECTRICAL :
                GetHasFeat(FEAT_KOB_DRAGONWROUGHT_BZ, oPC)  ? DAMAGE_TYPE_ELECTRICAL :
                GetHasFeat(FEAT_KOB_DRAGONWROUGHT_SA, oPC)  ? DAMAGE_TYPE_ELECTRICAL :
                GetHasFeat(FEAT_KOB_DRAGONWROUGHT_CR, oPC)  ? DAMAGE_TYPE_COLD :
                GetHasFeat(FEAT_KOB_DRAGONWROUGHT_TP, oPC)  ? DAMAGE_TYPE_COLD :
                GetHasFeat(FEAT_KOB_DRAGONWROUGHT_SR, oPC)  ? DAMAGE_TYPE_COLD :
                GetHasFeat(FEAT_KOB_DRAGONWROUGHT_WH, oPC)  ? DAMAGE_TYPE_COLD :
                DAMAGE_TYPE_FIRE; // If none match, make the itemproperty invalid

      return iType;
}

int GetFavouredEnemyBonus(object oPC)
{
   object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
   int nWeaponType = GetBaseItemType(oWeapon);

   int nClass;
   int nFE = 0;

   // Ranger
   nClass = GetLevelByClass(CLASS_TYPE_RANGER, oPC);
   if (nClass) nFE += nClass/5 + 1;

   if (DEBUG) DoDebug("prc_inc_sneak: Favoured Enemy Bonus: " + IntToString(nFE));
   return nFE;
}

//;: void main (){}