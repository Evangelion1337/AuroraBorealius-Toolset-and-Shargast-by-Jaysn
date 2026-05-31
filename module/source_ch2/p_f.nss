#include "id_const"
#include "sql_campaign"

// * Applies an XP and GP penalty
// * to the player respawning
void ApplyPenalty(object oDead)
{
    int nXP = GetXP(oDead);
    int nLEVEL = GetHitDice( oDead);

    int nPenalty = 0;

    switch (nLEVEL)
    {
      case 1:
        nPenalty = 0;
        break;
      case 2:
        nPenalty = 0;
        break;
      case 3:
        nPenalty = 0;
        break;
      case 4:
        nPenalty = 0;
        break;
      case 5:
        nPenalty = 0;
        break;
      case 6:
        nPenalty = 50;
        break;
      case 7:
        nPenalty = 50;
        break;
      case 8:
        nPenalty = 50;
        break;
      case 9:
        nPenalty = 50;
        break;
      case 10:
        nPenalty = 50;
        break;
      case 11:
        nPenalty = 100;
        break;
      case 12:
        nPenalty = 100;
        break;
      case 13:
        nPenalty = 100;
        break;
      case 14:
        nPenalty = 100;
        break;
      case 15:
        nPenalty = 100;
        break;
     case 16:
        nPenalty = 200;
        break;
     case 17:
        nPenalty = 200;
        break;
     case 18:
        nPenalty = 200;
        break;
     case 19:
        nPenalty = 200;
        break;
     case 20:
        nPenalty = 200;
        break;
      default:
        nPenalty = 0;
        break;
    }

    int nNewXP = nXP - (nPenalty * nLEVEL);

    SetXP(oDead, nNewXP);

    int nGoldToTake =  FloatToInt(0.10 * GetGold(oDead));

    WriteTimestampedLogEntry( GetName( oDead) + " has properly respawned.");
    AssignCommand(oDead, TakeGoldFromCreature(nGoldToTake, oDead, TRUE));
    DelayCommand(4.0, FloatingTextStrRefOnCreature(58299, oDead, FALSE));
    DelayCommand(4.8, FloatingTextStrRefOnCreature(58300, oDead, FALSE));

}

void GiveXP( object oKiller, object oDead)
{
    //10 - [(level of the killer) - (level of the target)] * X
    float iPartyCount = 0.9;

    object oTemp = GetFirstFactionMember( oKiller, FALSE);
    while( oTemp != OBJECT_INVALID)
    {
      iPartyCount += 0.1;
      oTemp = GetNextFactionMember(oKiller, FALSE);
    }

    int KLevel = 0;
    KLevel += GetLevelByPosition( 1, oKiller);
    KLevel += GetLevelByPosition( 2, oKiller);
    KLevel += GetLevelByPosition( 3, oKiller);

    float DCR = GetChallengeRating( oDead);

    int xp = FloatToInt(((10 - ( KLevel - DCR)) * 5 ) / iPartyCount );

    if( xp < 0)
      xp = 0;

    GiveXPToCreature( oKiller, xp);
}

void Trip( object oTarget)
{
  if( GetIsDM( oTarget))
    return;

  object oItem = GetFirstItemInInventory( oTarget);

  while( GetIsObjectValid( oItem))
  {
    ActionTakeItem( oItem, oTarget);
    oItem = GetNextItemInInventory( oTarget);
  }

  effect eInvis = EffectInvisibility( INVISIBILITY_TYPE_NORMAL);
  RemoveEffect( oTarget, eInvis);
  eInvis = EffectInvisibility( INVISIBILITY_TYPE_IMPROVED);
  RemoveEffect( oTarget, eInvis);
  eInvis = EffectInvisibility( INVISIBILITY_TYPE_DARKNESS);
  RemoveEffect( oTarget, eInvis);

  FloatingTextStringOnCreature( "Trips on a stone because they were not looking where they were side stepping", oTarget, TRUE);

  effect eFall = EffectKnockdown();
  ApplyEffectToObject( DURATION_TYPE_TEMPORARY, eFall, oTarget, 10.0);
}

int GetItemID( object oItem)
{
  if ( oItem != OBJECT_INVALID)
  {
    string oTag = GetTag( oItem);

    int Length = GetStringLength( oTag);
    oTag = GetSubString( oTag, Length - 4, 4);

    return StringToInt( oTag);
  }
  else return 0;
}

void CloseDoor( object oDoor)
{
  if( oDoor != OBJECT_INVALID)
  {
    AssignCommand( oDoor, DelayCommand( 7.0, ActionCloseDoor( oDoor)));
  }
}

void LockDoor( object oDoor)
{
  if( oDoor != OBJECT_INVALID)
  {
    AssignCommand( oDoor, DelayCommand( 7.5, SetLocked( oDoor, TRUE)));
  }
}

void UsePortal( object oTarget)
{
  if( GetIsInCombat( oTarget))
  {
    FloatingTextStringOnCreature( "You can not leave while fighting.", oTarget);
    return;
  }

  if( oTarget != OBJECT_INVALID)
  {
    string oDestTag = GetLocalString( oTarget, "Destination");
    object oDest = GetObjectByTag( oDestTag);

    if( oDest != OBJECT_INVALID)
    {
      AssignCommand( oTarget, ActionJumpToObject( oDest));
    }
    DeleteLocalString( oTarget, "Destination");
  }
}

int PCInArea(object oArea, object oPCExclude=OBJECT_INVALID)
{
    if(GetIsObjectValid(oArea)==FALSE)
        return FALSE;

    object oPC = GetFirstPC();
    int iPCFound = FALSE;

    while(GetIsObjectValid(oPC)&&iPCFound==FALSE)
    {
        if(GetArea(oPC)==oArea&&oPCExclude!=oPC)
            iPCFound=TRUE;
        oPC = GetNextPC();
    }
   return iPCFound;
}

void ResetArea( object oArea)
{
    // Search for PCs in the area
    int iPCFound = PCInArea(OBJECT_SELF);

    // If there is no PCs in Area
    if(iPCFound==FALSE)
    {
        object oThing = GetFirstObjectInArea(OBJECT_SELF);
        int iType ;

        while(GetIsObjectValid(oThing))
        {
            iType = GetObjectType(oThing);

            switch(iType)
            {
                case OBJECT_TYPE_ITEM:
                    // Of you ever want an exception to items left on the ground tell me so
                    DestroyObject(oThing);
                    break;
                case OBJECT_TYPE_PLACEABLE:
                    if(GetTag(oThing)=="BodyBag")
                    {
                        object oItem = GetFirstItemInInventory(oThing);
                        while(GetIsObjectValid(oItem))
                        {
                            DestroyObject(oItem);
                            oItem = GetNextItemInInventory(oThing);
                        }
                        DestroyObject(oThing);
                    }
                    break;
                default:
            }

            oThing = GetNextObjectInArea(OBJECT_SELF);
        }
    }
}

void ResetCharacter( object oTarget)
{
  int i;
  for( i = 0; i < 20; i++)
  {
    DecrementRemainingSpellUses( oTarget, SPELL_ACID_FOG );
    DecrementRemainingSpellUses( oTarget, SPELL_ACID_SPLASH );
    DecrementRemainingSpellUses( oTarget, SPELL_ACTIVATE_ITEM_PORTAL );
    DecrementRemainingSpellUses( oTarget, SPELL_ACTIVATE_ITEM_SELF2 );
    DecrementRemainingSpellUses( oTarget, SPELL_AID );
    DecrementRemainingSpellUses( oTarget, SPELL_AMPLIFY );
    DecrementRemainingSpellUses( oTarget, SPELL_ANIMATE_DEAD);
    DecrementRemainingSpellUses( oTarget, SPELL_AURA_OF_VITALITY );
    DecrementRemainingSpellUses( oTarget, SPELL_AURAOFGLORY );
    DecrementRemainingSpellUses( oTarget, SPELL_AWAKEN);
    DecrementRemainingSpellUses( oTarget, SPELL_BALAGARNSIRONHORN );
    DecrementRemainingSpellUses( oTarget, SPELL_BANE );
    DecrementRemainingSpellUses( oTarget, SPELL_BANISHMENT );
    DecrementRemainingSpellUses( oTarget, SPELL_BARKSKIN);
    DecrementRemainingSpellUses( oTarget, SPELL_BESTOW_CURSE );
    DecrementRemainingSpellUses( oTarget, SPELL_BIGBYS_CLENCHED_FIST );
    DecrementRemainingSpellUses( oTarget, SPELL_BIGBYS_CRUSHING_HAND );
    DecrementRemainingSpellUses( oTarget, SPELL_BIGBYS_FORCEFUL_HAND );
    DecrementRemainingSpellUses( oTarget, SPELL_BIGBYS_GRASPING_HAND );
    DecrementRemainingSpellUses( oTarget, SPELL_BIGBYS_INTERPOSING_HAND );
    DecrementRemainingSpellUses( oTarget, SPELL_BLADE_BARRIER );
    DecrementRemainingSpellUses( oTarget, SPELL_BLESS   );
    DecrementRemainingSpellUses( oTarget, SPELL_BLESS_WEAPON );
    DecrementRemainingSpellUses( oTarget, SPELL_BLINDNESS_AND_DEAFNESS );
    DecrementRemainingSpellUses( oTarget, SPELL_BLOOD_FRENZY );
    DecrementRemainingSpellUses( oTarget, SPELL_BOMBARDMENT );
    DecrementRemainingSpellUses( oTarget, SPELL_BULLS_STRENGTH );
    DecrementRemainingSpellUses( oTarget, SPELL_BURNING_HANDS);
    DecrementRemainingSpellUses( oTarget, SPELL_CALL_LIGHTNING);
    DecrementRemainingSpellUses( oTarget, SPELL_CAMOFLAGE );
    DecrementRemainingSpellUses( oTarget, SPELL_CATS_GRACE );
    DecrementRemainingSpellUses( oTarget, SPELL_CHAIN_LIGHTNING  );
    DecrementRemainingSpellUses( oTarget, SPELL_CHARM_MONSTER );
    DecrementRemainingSpellUses( oTarget, SPELL_CHARM_PERSON);
    DecrementRemainingSpellUses( oTarget, SPELL_CHARM_PERSON_OR_ANIMAL );
    DecrementRemainingSpellUses( oTarget, SPELL_CIRCLE_OF_DEATH );
    DecrementRemainingSpellUses( oTarget, SPELL_CIRCLE_OF_DOOM  );
    DecrementRemainingSpellUses( oTarget, SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE);
    DecrementRemainingSpellUses( oTarget, SPELL_CLARITY );
    DecrementRemainingSpellUses( oTarget, SPELL_CLOAK_OF_CHAOS );
    DecrementRemainingSpellUses( oTarget, SPELL_CLOUDKILL  );
    DecrementRemainingSpellUses( oTarget, SPELL_COLOR_SPRAY);
    DecrementRemainingSpellUses( oTarget, SPELL_CONE_OF_COLD);
    DecrementRemainingSpellUses( oTarget, SPELL_CONFUSION  );
    DecrementRemainingSpellUses( oTarget, SPELL_CONTAGION  );
    DecrementRemainingSpellUses( oTarget, SPELL_CONTINUAL_FLAME );
    DecrementRemainingSpellUses( oTarget, SPELL_CONTROL_UNDEAD );
    DecrementRemainingSpellUses( oTarget, SPELL_CRAFT_HARPER_ITEM );
    DecrementRemainingSpellUses( oTarget, SPELL_CREATE_GREATER_UNDEAD );
    DecrementRemainingSpellUses( oTarget, SPELL_CREATE_UNDEAD );
    DecrementRemainingSpellUses( oTarget, SPELL_CREEPING_DOOM);
    DecrementRemainingSpellUses( oTarget, SPELL_CURE_CRITICAL_WOUNDS );
    DecrementRemainingSpellUses( oTarget, SPELL_CURE_LIGHT_WOUNDS );
    DecrementRemainingSpellUses( oTarget, SPELL_CURE_MINOR_WOUNDS );
    DecrementRemainingSpellUses( oTarget, SPELL_CURE_MODERATE_WOUNDS );
    DecrementRemainingSpellUses( oTarget, SPELL_CURE_SERIOUS_WOUNDS );
    DecrementRemainingSpellUses( oTarget, SPELL_DARKNESS );
    DecrementRemainingSpellUses( oTarget, SPELL_DARKVISION );
    DecrementRemainingSpellUses( oTarget, SPELL_DAZE );
    DecrementRemainingSpellUses( oTarget, SPELL_DEATH_WARD );
    DecrementRemainingSpellUses( oTarget, SPELL_DELAYED_BLAST_FIREBALL);
    DecrementRemainingSpellUses( oTarget, SPELL_DESTRUCTION );
    DecrementRemainingSpellUses( oTarget, SPELL_DIRGE );
    DecrementRemainingSpellUses( oTarget, SPELL_DISMISSAL);
    DecrementRemainingSpellUses( oTarget, SPELL_DISPEL_MAGIC );
    DecrementRemainingSpellUses( oTarget, SPELL_DISPLACEMENT );
    DecrementRemainingSpellUses( oTarget, SPELL_DIVINE_FAVOR );
    DecrementRemainingSpellUses( oTarget, SPELL_DIVINE_MIGHT );
    DecrementRemainingSpellUses( oTarget, SPELL_DIVINE_POWER );
    DecrementRemainingSpellUses( oTarget, SPELL_DIVINE_SHIELD );
    DecrementRemainingSpellUses( oTarget, SPELL_DOMINATE_ANIMAL);
    DecrementRemainingSpellUses( oTarget, SPELL_DOMINATE_MONSTER );
    DecrementRemainingSpellUses( oTarget, SPELL_DOMINATE_PERSON  );
    DecrementRemainingSpellUses( oTarget, SPELL_DOOM );
    DecrementRemainingSpellUses( oTarget, SPELL_DROWN );
    DecrementRemainingSpellUses( oTarget, SPELL_EAGLE_SPLEDOR);
    DecrementRemainingSpellUses( oTarget, SPELL_EARTHQUAKE );
    DecrementRemainingSpellUses( oTarget, SPELL_ELECTRIC_JOLT );
    DecrementRemainingSpellUses( oTarget, SPELL_ELEMENTAL_SHIELD);
    DecrementRemainingSpellUses( oTarget, SPELL_ELEMENTAL_SWARM );
    DecrementRemainingSpellUses( oTarget, SPELL_ENDURANCE);
    DecrementRemainingSpellUses( oTarget, SPELL_ENDURE_ELEMENTS );
    DecrementRemainingSpellUses( oTarget, SPELL_ENERGY_BUFFER );
    DecrementRemainingSpellUses( oTarget, SPELL_ENERGY_DRAIN );
    DecrementRemainingSpellUses( oTarget, SPELL_ENERVATION);
    DecrementRemainingSpellUses( oTarget, SPELL_ENTANGLE);
    DecrementRemainingSpellUses( oTarget, SPELL_ENTROPIC_SHIELD );
    DecrementRemainingSpellUses( oTarget, SPELL_ETHEREAL_VISAGE );
    DecrementRemainingSpellUses( oTarget, SPELL_ETHEREALNESS );
    DecrementRemainingSpellUses( oTarget, SPELL_EVARDS_BLACK_TENTACLES );
    DecrementRemainingSpellUses( oTarget, SPELL_EXPEDITIOUS_RETREAT );
    DecrementRemainingSpellUses( oTarget, SPELL_FEAR );
    DecrementRemainingSpellUses( oTarget, SPELL_FEEBLEMIND);
    DecrementRemainingSpellUses( oTarget, SPELL_FIND_TRAPS);
    DecrementRemainingSpellUses( oTarget, SPELL_FINGER_OF_DEATH );
    DecrementRemainingSpellUses( oTarget, SPELL_FIRE_STORM );
    DecrementRemainingSpellUses( oTarget, SPELL_FIREBALL );
    DecrementRemainingSpellUses( oTarget, SPELL_FIREBRAND );
    DecrementRemainingSpellUses( oTarget, SPELL_FLAME_ARROW  );
    DecrementRemainingSpellUses( oTarget, SPELL_FLAME_LASH );
    DecrementRemainingSpellUses( oTarget, SPELL_FLAME_STRIKE );
    DecrementRemainingSpellUses( oTarget, SPELL_FLARE );
    DecrementRemainingSpellUses( oTarget, SPELL_FLESH_TO_STONE );
    DecrementRemainingSpellUses( oTarget, SPELL_FOXS_CUNNING );
    DecrementRemainingSpellUses( oTarget, SPELL_FREEDOM_OF_MOVEMENT);
    DecrementRemainingSpellUses( oTarget, SPELL_GATE );
    DecrementRemainingSpellUses( oTarget, SPELL_GHOSTLY_VISAGE );
    DecrementRemainingSpellUses( oTarget, SPELL_GHOUL_TOUCH );
    DecrementRemainingSpellUses( oTarget, SPELL_GLOBE_OF_INVULNERABILITY);
    DecrementRemainingSpellUses( oTarget, SPELL_GREASE );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_BULLS_STRENGTH );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_CATS_GRACE );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_DISPELLING );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_EAGLE_SPLENDOR );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_ENDURANCE );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_FOXS_CUNNING );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_MAGIC_FANG );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_MAGIC_WEAPON );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_OWLS_WISDOM );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_PLANAR_BINDING );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_RESTORATION );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_SHADOW_CONJURATION_ACID_ARROW );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_SHADOW_CONJURATION_SUMMON_SHADOW );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_SHADOW_CONJURATION_WEB );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_SPELL_BREACH );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_SPELL_MANTLE );
    DecrementRemainingSpellUses( oTarget, SPELL_GREATER_STONESKIN );
    DecrementRemainingSpellUses( oTarget, SPELL_GRENADE_ACID );
    DecrementRemainingSpellUses( oTarget, SPELL_GRENADE_CALTROPS );
    DecrementRemainingSpellUses( oTarget, SPELL_GRENADE_CHICKEN );
    DecrementRemainingSpellUses( oTarget, SPELL_GRENADE_CHOKING );
    DecrementRemainingSpellUses( oTarget, SPELL_GRENADE_FIRE );
    DecrementRemainingSpellUses( oTarget, SPELL_GRENADE_HOLY );
    DecrementRemainingSpellUses( oTarget, SPELL_GRENADE_TANGLE );
    DecrementRemainingSpellUses( oTarget, SPELL_GRENADE_THUNDERSTONE );
    DecrementRemainingSpellUses( oTarget, SPELL_GUST_OF_WIND );
    DecrementRemainingSpellUses( oTarget, SPELL_HAMMER_OF_THE_GODS );
    DecrementRemainingSpellUses( oTarget, SPELL_HARM );
    DecrementRemainingSpellUses( oTarget, SPELL_HASTE );
    DecrementRemainingSpellUses( oTarget, SPELL_HEAL );
    DecrementRemainingSpellUses( oTarget, SPELL_HEALING_CIRCLE);
    DecrementRemainingSpellUses( oTarget, SPELL_HOLD_ANIMAL);
    DecrementRemainingSpellUses( oTarget, SPELL_HOLD_MONSTER);
    DecrementRemainingSpellUses( oTarget, SPELL_HOLD_PERSON);
    DecrementRemainingSpellUses( oTarget, SPELL_HOLY_AURA );
    DecrementRemainingSpellUses( oTarget, SPELL_HOLY_SWORD );
    DecrementRemainingSpellUses( oTarget, SPELL_HORRID_WILTING );
    DecrementRemainingSpellUses( oTarget, SPELL_ICE_STORM );
    DecrementRemainingSpellUses( oTarget, SPELL_IDENTIFY );
    DecrementRemainingSpellUses( oTarget, SPELL_IMPLOSION );
    DecrementRemainingSpellUses( oTarget, SPELL_IMPROVED_INVISIBILITY );
    DecrementRemainingSpellUses( oTarget, SPELL_INCENDIARY_CLOUD);
    DecrementRemainingSpellUses( oTarget, SPELL_INFERNO );
    DecrementRemainingSpellUses( oTarget, SPELL_INFLICT_CRITICAL_WOUNDS );
    DecrementRemainingSpellUses( oTarget, SPELL_INFLICT_LIGHT_WOUNDS );
    DecrementRemainingSpellUses( oTarget, SPELL_INFLICT_MINOR_WOUNDS );
    DecrementRemainingSpellUses( oTarget, SPELL_INFLICT_MODERATE_WOUNDS );
    DecrementRemainingSpellUses( oTarget, SPELL_INFLICT_SERIOUS_WOUNDS );
    DecrementRemainingSpellUses( oTarget, SPELL_INVISIBILITY);
    DecrementRemainingSpellUses( oTarget, SPELL_INVISIBILITY_PURGE );
    DecrementRemainingSpellUses( oTarget, SPELL_INVISIBILITY_SPHERE  );
    DecrementRemainingSpellUses( oTarget, SPELL_ISAACS_GREATER_MISSILE_STORM );
    DecrementRemainingSpellUses( oTarget, SPELL_ISAACS_LESSER_MISSILE_STORM );
    DecrementRemainingSpellUses( oTarget, SPELL_KNOCK );
    DecrementRemainingSpellUses( oTarget, SPELL_LEGEND_LORE);
    DecrementRemainingSpellUses( oTarget, SPELL_LESSER_DISPEL );
    DecrementRemainingSpellUses( oTarget, SPELL_LESSER_MIND_BLANK );
    DecrementRemainingSpellUses( oTarget, SPELL_LESSER_PLANAR_BINDING );
    DecrementRemainingSpellUses( oTarget, SPELL_LESSER_RESTORATION );
    DecrementRemainingSpellUses( oTarget, SPELL_LESSER_SPELL_BREACH);
    DecrementRemainingSpellUses( oTarget, SPELL_LESSER_SPELL_MANTLE  );
    DecrementRemainingSpellUses( oTarget, SPELL_LIGHT);
    DecrementRemainingSpellUses( oTarget, SPELL_LIGHTNING_BOLT );
    DecrementRemainingSpellUses( oTarget, SPELL_MAGE_ARMOR );
    DecrementRemainingSpellUses( oTarget, SPELL_MAGIC_CIRCLE_AGAINST_CHAOS );
    DecrementRemainingSpellUses( oTarget, SPELL_MAGIC_CIRCLE_AGAINST_EVIL);
    DecrementRemainingSpellUses( oTarget, SPELL_MAGIC_CIRCLE_AGAINST_GOOD);
    DecrementRemainingSpellUses( oTarget, SPELL_MAGIC_CIRCLE_AGAINST_LAW );
    DecrementRemainingSpellUses( oTarget, SPELL_MAGIC_FANG );
    DecrementRemainingSpellUses( oTarget, SPELL_MAGIC_MISSILE );
    DecrementRemainingSpellUses( oTarget, SPELL_MAGIC_VESTMENT );
    DecrementRemainingSpellUses( oTarget, SPELL_MAGIC_WEAPON );
    DecrementRemainingSpellUses( oTarget, SPELL_MASS_BLINDNESS_AND_DEAFNESS );
    DecrementRemainingSpellUses( oTarget, SPELL_MASS_CAMOFLAGE );
    DecrementRemainingSpellUses( oTarget, SPELL_MASS_CHARM );
    DecrementRemainingSpellUses( oTarget, SPELL_MASS_HASTE );
    DecrementRemainingSpellUses( oTarget, SPELL_MASS_HEAL );
    DecrementRemainingSpellUses( oTarget, SPELL_MELFS_ACID_ARROW );
    DecrementRemainingSpellUses( oTarget, SPELL_METEOR_SWARM  );
    DecrementRemainingSpellUses( oTarget, SPELL_MIND_BLANK);
    DecrementRemainingSpellUses( oTarget, SPELL_MIND_FOG );
    DecrementRemainingSpellUses( oTarget, SPELL_MINOR_GLOBE_OF_INVULNERABILITY );
    DecrementRemainingSpellUses( oTarget, SPELL_MORDENKAINENS_DISJUNCTION );
    DecrementRemainingSpellUses( oTarget, SPELL_MORDENKAINENS_SWORD );
    DecrementRemainingSpellUses( oTarget, SPELL_NATURES_BALANCE);
    DecrementRemainingSpellUses( oTarget, SPELL_NEGATIVE_ENERGY_BURST );
    DecrementRemainingSpellUses( oTarget, SPELL_NEGATIVE_ENERGY_PROTECTION);
    DecrementRemainingSpellUses( oTarget, SPELL_NEGATIVE_ENERGY_RAY);
    DecrementRemainingSpellUses( oTarget, SPELL_NEUTRALIZE_POISON );
    DecrementRemainingSpellUses( oTarget, SPELL_ONE_WITH_THE_LAND );
    DecrementRemainingSpellUses( oTarget, SPELL_OWLS_WISDOM);
    DecrementRemainingSpellUses( oTarget, SPELL_PHANTASMAL_KILLER );
    DecrementRemainingSpellUses( oTarget, SPELL_PLANAR_ALLY );
    DecrementRemainingSpellUses( oTarget, SPELL_PLANAR_BINDING );
    DecrementRemainingSpellUses( oTarget, SPELL_POISON );
    DecrementRemainingSpellUses( oTarget, SPELL_POLYMORPH_SELF );
    DecrementRemainingSpellUses( oTarget, SPELL_POWER_WORD_KILL );
    DecrementRemainingSpellUses( oTarget, SPELL_POWER_WORD_STUN );
    DecrementRemainingSpellUses( oTarget, SPELL_PRAYER );
    DecrementRemainingSpellUses( oTarget, SPELL_PREMONITION );
    DecrementRemainingSpellUses( oTarget, SPELL_PRISMATIC_SPRAY );
    DecrementRemainingSpellUses( oTarget, SPELL_PROTECTION__FROM_CHAOS );
    DecrementRemainingSpellUses( oTarget, SPELL_PROTECTION_FROM_ELEMENTS);
    DecrementRemainingSpellUses( oTarget, SPELL_PROTECTION_FROM_EVIL);
    DecrementRemainingSpellUses( oTarget, SPELL_PROTECTION_FROM_GOOD);
    DecrementRemainingSpellUses( oTarget, SPELL_PROTECTION_FROM_LAW );
    DecrementRemainingSpellUses( oTarget, SPELL_PROTECTION_FROM_SPELLS );
    DecrementRemainingSpellUses( oTarget, SPELL_QUILLFIRE );
    DecrementRemainingSpellUses( oTarget, SPELL_RAISE_DEAD );
    DecrementRemainingSpellUses( oTarget, SPELL_RAY_OF_ENFEEBLEMENT );
    DecrementRemainingSpellUses( oTarget, SPELL_RAY_OF_FROST);
    DecrementRemainingSpellUses( oTarget, SPELL_REGENERATE );
    DecrementRemainingSpellUses( oTarget, SPELL_REMOVE_BLINDNESS_AND_DEAFNESS);
    DecrementRemainingSpellUses( oTarget, SPELL_REMOVE_CURSE );
    DecrementRemainingSpellUses( oTarget, SPELL_REMOVE_DISEASE );
    DecrementRemainingSpellUses( oTarget, SPELL_REMOVE_FEAR );
    DecrementRemainingSpellUses( oTarget, SPELL_REMOVE_PARALYSIS);
    DecrementRemainingSpellUses( oTarget, SPELL_RESIST_ELEMENTS );
    DecrementRemainingSpellUses( oTarget, SPELL_RESISTANCE );
    DecrementRemainingSpellUses( oTarget, SPELL_RESTORATION);
    DecrementRemainingSpellUses( oTarget, SPELL_RESURRECTION );
    DecrementRemainingSpellUses( oTarget, SPELL_SANCTUARY );
    DecrementRemainingSpellUses( oTarget, SPELL_SCARE );
    DecrementRemainingSpellUses( oTarget, SPELL_SEARING_LIGHT);
    DecrementRemainingSpellUses( oTarget, SPELL_SEE_INVISIBILITY);
    DecrementRemainingSpellUses( oTarget, SPELL_SHADES_CONE_OF_COLD);
    DecrementRemainingSpellUses( oTarget, SPELL_SHADES_FIREBALL);
    DecrementRemainingSpellUses( oTarget, SPELL_SHADES_STONESKIN );
    DecrementRemainingSpellUses( oTarget, SPELL_SHADES_SUMMON_SHADOW );
    DecrementRemainingSpellUses( oTarget, SPELL_SHADES_WALL_OF_FIRE );
    DecrementRemainingSpellUses( oTarget, SPELL_SHADOW_CONJURATION_DARKNESS);
    DecrementRemainingSpellUses( oTarget, SPELL_SHADOW_CONJURATION_INIVSIBILITY );
    DecrementRemainingSpellUses( oTarget, SPELL_SHADOW_CONJURATION_MAGE_ARMOR);
    DecrementRemainingSpellUses( oTarget, SPELL_SHADOW_CONJURATION_MAGIC_MISSILE);
    DecrementRemainingSpellUses( oTarget, SPELL_SHADOW_CONJURATION_SUMMON_SHADOW);
    DecrementRemainingSpellUses( oTarget, SPELL_SHADOW_DAZE );
    DecrementRemainingSpellUses( oTarget, SPELL_SHADOW_EVADE );
    DecrementRemainingSpellUses( oTarget, SPELL_SHADOW_SHIELD );
    DecrementRemainingSpellUses( oTarget, SPELL_SHAPECHANGE);
    DecrementRemainingSpellUses( oTarget, SPELL_SHIELD_OF_FAITH );
    DecrementRemainingSpellUses( oTarget, SPELL_SHIELD_OF_LAW );
    DecrementRemainingSpellUses( oTarget, SPELL_SILENCE);
    DecrementRemainingSpellUses( oTarget, SPELL_SLAY_LIVING);
    DecrementRemainingSpellUses( oTarget, SPELL_SLEEP);
    DecrementRemainingSpellUses( oTarget, SPELL_SLOW);
    DecrementRemainingSpellUses( oTarget, SPELL_SOUND_BURST);
    DecrementRemainingSpellUses( oTarget, SPELL_SPELL_MANTLE);
    DecrementRemainingSpellUses( oTarget, SPELL_SPELL_RESISTANCE);
    DecrementRemainingSpellUses( oTarget, SPELL_SPHERE_OF_CHAOS );
    DecrementRemainingSpellUses( oTarget, SPELL_SPIKE_GROWTH );
    DecrementRemainingSpellUses( oTarget, SPELL_STINKING_CLOUD);
    DecrementRemainingSpellUses( oTarget, SPELL_STONE_TO_FLESH );
    DecrementRemainingSpellUses( oTarget, SPELL_STONESKIN);
    DecrementRemainingSpellUses( oTarget, SPELL_STORM_OF_VENGEANCE);
    DecrementRemainingSpellUses( oTarget, SPELL_SUMMON_CREATURE_I);
    DecrementRemainingSpellUses( oTarget, SPELL_SUMMON_CREATURE_II);
    DecrementRemainingSpellUses( oTarget, SPELL_SUMMON_CREATURE_III);
    DecrementRemainingSpellUses( oTarget, SPELL_SUMMON_CREATURE_IV);
    DecrementRemainingSpellUses( oTarget, SPELL_SUMMON_CREATURE_IX );
    DecrementRemainingSpellUses( oTarget, SPELL_SUMMON_CREATURE_V);
    DecrementRemainingSpellUses( oTarget, SPELL_SUMMON_CREATURE_VI);
    DecrementRemainingSpellUses( oTarget, SPELL_SUMMON_CREATURE_VII);
    DecrementRemainingSpellUses( oTarget, SPELL_SUMMON_CREATURE_VIII);
    DecrementRemainingSpellUses( oTarget, SPELL_SUMMON_SHADOW );
    DecrementRemainingSpellUses( oTarget, SPELL_SUNBEAM);
    DecrementRemainingSpellUses( oTarget, SPELL_SUNBURST );
    DecrementRemainingSpellUses( oTarget, SPELL_TASHAS_HIDEOUS_LAUGHTER );
    DecrementRemainingSpellUses( oTarget, SPELL_TENSERS_TRANSFORMATION);
    DecrementRemainingSpellUses( oTarget, SPELL_TIME_STOP);
    DecrementRemainingSpellUses( oTarget, SPELL_TRAP_ARROW );
    DecrementRemainingSpellUses( oTarget, SPELL_TRAP_BOLT );
    DecrementRemainingSpellUses( oTarget, SPELL_TRAP_DART );
    DecrementRemainingSpellUses( oTarget, SPELL_TRAP_SHURIKEN );
    DecrementRemainingSpellUses( oTarget, SPELL_TRUE_SEEING);
    DecrementRemainingSpellUses( oTarget, SPELL_TRUE_STRIKE );
    DecrementRemainingSpellUses( oTarget, SPELL_TYMORAS_SMILE );
    DecrementRemainingSpellUses( oTarget, SPELL_UNDEATHS_ETERNAL_FOE );
    DecrementRemainingSpellUses( oTarget, SPELL_UNHOLY_AURA);
    DecrementRemainingSpellUses( oTarget, SPELL_VAMPIRIC_TOUCH);
    DecrementRemainingSpellUses( oTarget, SPELL_VIRTUE);
    DecrementRemainingSpellUses( oTarget, SPELL_WAIL_OF_THE_BANSHEE);
    DecrementRemainingSpellUses( oTarget, SPELL_WALL_OF_FIRE);
    DecrementRemainingSpellUses( oTarget, SPELL_WAR_CRY);
    DecrementRemainingSpellUses( oTarget, SPELL_WEB);
    DecrementRemainingSpellUses( oTarget, SPELL_WEIRD);
    DecrementRemainingSpellUses( oTarget, SPELL_WORD_OF_FAITH);
    DecrementRemainingSpellUses( oTarget, SPELL_WOUNDING_WHISPERS );

    DecrementRemainingFeatUses( oTarget, FEAT_ANIMAL_COMPANION);
    DecrementRemainingFeatUses( oTarget, FEAT_AURA_OF_COURAGE);
    DecrementRemainingFeatUses( oTarget, FEAT_BARBARIAN_RAGE);
    DecrementRemainingFeatUses( oTarget, FEAT_BARD_SONGS);
    DecrementRemainingFeatUses( oTarget, FEAT_BLOODED);
    DecrementRemainingFeatUses( oTarget, FEAT_BULLHEADED);
    DecrementRemainingFeatUses( oTarget, FEAT_CIRCLE_KICK);
    DecrementRemainingFeatUses( oTarget, FEAT_COURTLY_MAGOCRACY);
    DecrementRemainingFeatUses( oTarget, FEAT_CRAFT_HARPER_ITEM);
    DecrementRemainingFeatUses( oTarget, FEAT_CRIPPLING_STRIKE);
    DecrementRemainingFeatUses( oTarget, FEAT_DEATH_DOMAIN_POWER);
    DecrementRemainingFeatUses( oTarget, FEAT_DENEIRS_EYE);
    DecrementRemainingFeatUses( oTarget, FEAT_DIVINE_GRACE);
    DecrementRemainingFeatUses( oTarget, FEAT_DIVINE_HEALTH);
    DecrementRemainingFeatUses( oTarget, FEAT_DIVINE_MIGHT);
    DecrementRemainingFeatUses( oTarget, FEAT_DIVINE_SHIELD);
    DecrementRemainingFeatUses( oTarget, FEAT_ELEMENTAL_SHAPE);
    DecrementRemainingFeatUses( oTarget, FEAT_EXPERTISE);
    DecrementRemainingFeatUses( oTarget, FEAT_EXTRA_STUNNING_ATTACK);
    DecrementRemainingFeatUses( oTarget, FEAT_FLURRY_OF_BLOWS);
    DecrementRemainingFeatUses( oTarget, FEAT_HARPER_CATS_GRACE);
    DecrementRemainingFeatUses( oTarget, FEAT_HARPER_EAGLES_SPLENDOR);
    DecrementRemainingFeatUses( oTarget, FEAT_HARPER_INVISIBILITY);
    DecrementRemainingFeatUses( oTarget, FEAT_HARPER_SLEEP);
    DecrementRemainingFeatUses( oTarget, FEAT_HIDE_IN_PLAIN_SIGHT);
    DecrementRemainingFeatUses( oTarget, FEAT_KI_STRIKE);
    DecrementRemainingFeatUses( oTarget, FEAT_LAY_ON_HANDS);
    DecrementRemainingFeatUses( oTarget, FEAT_LLIIRAS_HEART);
    DecrementRemainingFeatUses( oTarget, FEAT_LUCK_OF_HEROES);
    DecrementRemainingFeatUses( oTarget, FEAT_PURITY_OF_BODY);
    DecrementRemainingFeatUses( oTarget, FEAT_QUIVERING_PALM);
    DecrementRemainingFeatUses( oTarget, FEAT_REMOVE_DISEASE);
    DecrementRemainingFeatUses( oTarget, FEAT_SHADOW_DAZE);
    DecrementRemainingFeatUses( oTarget, FEAT_SHADOW_EVADE);
    DecrementRemainingFeatUses( oTarget, FEAT_SILVER_PALM);
    DecrementRemainingFeatUses( oTarget, FEAT_SMITE_EVIL);
    DecrementRemainingFeatUses( oTarget, FEAT_SNAKEBLOOD);
    DecrementRemainingFeatUses( oTarget, FEAT_SPRING_ATTACK);
    DecrementRemainingFeatUses( oTarget, FEAT_STRENGTH_DOMAIN_POWER);
    DecrementRemainingFeatUses( oTarget, FEAT_STRONGSOUL);
    DecrementRemainingFeatUses( oTarget, FEAT_STUNNING_FIST);
    DecrementRemainingFeatUses( oTarget, FEAT_SUMMON_FAMILIAR);
    DecrementRemainingFeatUses( oTarget, FEAT_SUMMON_SHADOW);
    DecrementRemainingFeatUses( oTarget, FEAT_THUG);
    DecrementRemainingFeatUses( oTarget, FEAT_TURN_UNDEAD);
    DecrementRemainingFeatUses( oTarget, FEAT_TRICKERY_DOMAIN_POWER);
    DecrementRemainingFeatUses( oTarget, FEAT_TYMORAS_SMILE);
    DecrementRemainingFeatUses( oTarget, FEAT_WAR_DOMAIN_POWER);
    DecrementRemainingFeatUses( oTarget, FEAT_WHOLENESS_OF_BODY);
    DecrementRemainingFeatUses( oTarget, FEAT_WILD_SHAPE);
    DecrementRemainingFeatUses( oTarget, FEAT_WOODLAND_STRIDE);
    DecrementRemainingFeatUses( oTarget, FEAT_ZEN_ARCHERY);
  }

/*  //reset hitpoints
  int iCheck = SQL_GetCampaignInt( sCamName, "LogChecked", oTarget);
  if( iCheck = 10)
  {
    int dHP = 0;
    dHP = GetCurrentHitPoints( oTarget) - iHP;

    effect eDam = EffectDamage( dHP, DAMAGE_TYPE_MAGICAL);
    ApplyEffectToObject( DURATION_TYPE_PERMANENT, eDam, oTarget);
  } */
}

int GetColourMax()
{
  return 55;
}
