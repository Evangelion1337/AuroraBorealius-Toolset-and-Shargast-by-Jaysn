// Returns the best available-for-casting n-th Level spell from oTarget.
int GetBestL0Spell(object oTarget, int nSpell);
int GetBestL1Spell(object oTarget, int nSpell);
int GetBestL2Spell(object oTarget, int nSpell);
int GetBestL3Spell(object oTarget, int nSpell);
int GetBestL4Spell(object oTarget, int nSpell);
int GetBestL5Spell(object oTarget, int nSpell);
int GetBestL6Spell(object oTarget, int nSpell);
int GetBestL7Spell(object oTarget, int nSpell);
int GetBestL8Spell(object oTarget, int nSpell);
int GetBestL9Spell(object oTarget, int nSpell);

// Returns the best available-for-casting spell from oTarget's repertoire.
int GetBestAvailableSpell(object oTarget);

#include "prc_inc_core"

int GetBestL0Spell(object oTarget, int nFallbackSpell)
{
    int nRow = 0;
    string s2DA = "spells";
    string sInnate, sStrRef;
    int nSpellID;

    while (TRUE)
    {
        sInnate = Get2DACache(s2DA, "Innate", nRow);
        if (sInnate == "") break; // End of 2DA

        if (StringToInt(sInnate) == 0)
        {
            nSpellID = nRow;

            if (PRCGetHasSpell(nSpellID, oTarget))
            {
                return nSpellID;
            }
        }

        nRow++;
    }

    return nFallbackSpell;
}

/* int GetBestL0Spell(object oTarget, int nSpell)
{
    if(PRCGetHasSpell(SPELL_ACID_SPLASH, oTarget))                    return SPELL_ACID_SPLASH;
    if(PRCGetHasSpell(SPELL_RAY_OF_FROST, oTarget))                   return SPELL_RAY_OF_FROST;
    if(PRCGetHasSpell(SPELL_DAZE, oTarget))                           return SPELL_DAZE;
    if(PRCGetHasSpell(SPELL_ELECTRIC_JOLT, oTarget))                  return SPELL_ELECTRIC_JOLT;
    if(PRCGetHasSpell(SPELL_FLARE, oTarget))                          return SPELL_FLARE;
    if(PRCGetHasSpell(SPELL_RESISTANCE, oTarget))                     return SPELL_RESISTANCE;
    if(PRCGetHasSpell(SPELL_LIGHT, oTarget))                          return SPELL_LIGHT;
    if(PRCGetHasSpell(SPELL_VIRTUE, oTarget))                         return SPELL_VIRTUE;
    if(PRCGetHasSpell(SPELL_CURE_MINOR_WOUNDS, oTarget))              return SPELL_CURE_MINOR_WOUNDS; 
    if(PRCGetHasSpell(SPELL_INFLICT_MINOR_WOUNDS, oTarget))           return SPELL_INFLICT_MINOR_WOUNDS;
    return nSpell;
} */

/* 

bscureObject

 */

int GetBestL1Spell(object oTarget, int nSpell)
{
    if(PRCGetHasSpell(SPELL_MAGIC_MISSILE, oTarget))                  return SPELL_MAGIC_MISSILE;
    if(PRCGetHasSpell(SPELL_SUMMON_CREATURE_I, oTarget))              return SPELL_SUMMON_CREATURE_I;
    if(PRCGetHasSpell(SPELL_DOOM, oTarget))                           return SPELL_DOOM;
    if(PRCGetHasSpell(SPELL_BANE, oTarget))                           return SPELL_BANE;
    if(PRCGetHasSpell(SPELL_BLESS, oTarget))                          return SPELL_BLESS;
    if(PRCGetHasSpell(SPELL_MAGIC_FANG, oTarget))                     return SPELL_MAGIC_FANG;
    if(PRCGetHasSpell(SPELL_MAGE_ARMOR, oTarget))                     return SPELL_MAGE_ARMOR;
    if(PRCGetHasSpell(SPELL_ENDURE_ELEMENTS, oTarget))                return SPELL_ENDURE_ELEMENTS;
    if(PRCGetHasSpell(SPELL_LESSER_DISPEL, oTarget))                  return SPELL_LESSER_DISPEL;
    if(PRCGetHasSpell(SPELL_SANCTUARY, oTarget))                      return SPELL_SANCTUARY;
    if(PRCGetHasSpell(SPELL_SHIELD, oTarget))                         return SPELL_SHIELD;
    if(PRCGetHasSpell(SPELL_CHARM_PERSON, oTarget))                   return SPELL_CHARM_PERSON;
    if(PRCGetHasSpell(SPELL_DEAFENING_CLANG, oTarget))                return SPELL_DEAFENING_CLANG;
    if(PRCGetHasSpell(SPELL_BALAGARNSIRONHORN, oTarget))              return SPELL_BALAGARNSIRONHORN;
    if(PRCGetHasSpell(SPELL_BLESS_WEAPON, oTarget))                   return SPELL_BLESS_WEAPON;
    if(PRCGetHasSpell(SPELL_SHELGARNS_PERSISTENT_BLADE, oTarget))     return SPELL_SHELGARNS_PERSISTENT_BLADE;
    if(PRCGetHasSpell(SPELL_NEGATIVE_ENERGY_RAY, oTarget))            return SPELL_NEGATIVE_ENERGY_RAY;
    if(PRCGetHasSpell(SPELL_BURNING_HANDS, oTarget))                  return SPELL_BURNING_HANDS;
    if(PRCGetHasSpell(SPELL_HORIZIKAULS_BOOM, oTarget))               return SPELL_HORIZIKAULS_BOOM;
    if(PRCGetHasSpell(SPELL_SHIELD_OF_FAITH, oTarget))                return SPELL_SHIELD_OF_FAITH;
    if(PRCGetHasSpell(SPELL_AMPLIFY, oTarget))                        return SPELL_AMPLIFY;
    if(PRCGetHasSpell(SPELL_TRUE_STRIKE, oTarget))                    return SPELL_TRUE_STRIKE;
    if(PRCGetHasSpell(SPELL_RAY_OF_ENFEEBLEMENT, oTarget))            return SPELL_RAY_OF_ENFEEBLEMENT;
    if(PRCGetHasSpell(SPELL_EXPEDITIOUS_RETREAT, oTarget))            return SPELL_EXPEDITIOUS_RETREAT;
    if(PRCGetHasSpell(SPELL_ICE_DAGGER, oTarget))                     return SPELL_ICE_DAGGER;
    if(PRCGetHasSpell(SPELL_ENTROPIC_SHIELD, oTarget))                return SPELL_ENTROPIC_SHIELD;
    if(PRCGetHasSpell(SPELL_ENTANGLE, oTarget))                       return SPELL_ENTANGLE;
    if(PRCGetHasSpell(SPELL_DIVINE_FAVOR, oTarget))                   return SPELL_DIVINE_FAVOR;
	if(PRCGetHasSpell(SPELL_FEAR, oTarget))                     		return SPELL_FEAR;
    if(PRCGetHasSpell(SPELL_SLEEP, oTarget))                          return SPELL_SLEEP;
    if(PRCGetHasSpell(SPELL_SORROW, oTarget))                          return SPELL_SORROW;	
    if(PRCGetHasSpell(SPELL_MAGIC_WEAPON, oTarget))                   return SPELL_MAGIC_WEAPON;
    if(PRCGetHasSpell(SPELL_SCARE, oTarget))                          return SPELL_SCARE;
    if(PRCGetHasSpell(SPELL_GREASE, oTarget))                         return SPELL_GREASE;
    if(PRCGetHasSpell(SPELL_CAMOFLAGE, oTarget))                      return SPELL_CAMOFLAGE;
    if(PRCGetHasSpell(SPELL_COLOR_SPRAY, oTarget))                    return SPELL_COLOR_SPRAY;
	if(PRCGetHasSpell(SPELL_RAY_OF_HOPE, oTarget))                      return SPELL_RAY_OF_HOPE;
    if(PRCGetHasSpell(SPELL_RESIST_ELEMENTS, oTarget))                return SPELL_RESIST_ELEMENTS;
    if(PRCGetHasSpell(SPELL_REMOVE_FEAR, oTarget))                    return SPELL_REMOVE_FEAR;
    if(PRCGetHasSpell(SPELL_IRONGUTS, oTarget))                       return SPELL_IRONGUTS;
    if(PRCGetHasSpell(SPELL_PROTECTION_FROM_LAW, oTarget))            return SPELL_PROTECTION_FROM_LAW;
    if(PRCGetHasSpell(SPELL_PROTECTION_FROM_GOOD, oTarget))           return SPELL_PROTECTION_FROM_GOOD;
    if(PRCGetHasSpell(SPELL_PROTECTION__FROM_CHAOS, oTarget))         return SPELL_PROTECTION__FROM_CHAOS;
    if(PRCGetHasSpell(SPELL_PROTECTION_FROM_EVIL, oTarget))           return SPELL_PROTECTION_FROM_EVIL;
    if(PRCGetHasSpell(SPELL_IDENTIFY, oTarget))                       return SPELL_IDENTIFY;
    if(PRCGetHasSpell(SPELL_CURE_LIGHT_WOUNDS, oTarget))              return SPELL_CURE_LIGHT_WOUNDS;    
    if(PRCGetHasSpell(SPELL_INFLICT_LIGHT_WOUNDS, oTarget))           return SPELL_INFLICT_LIGHT_WOUNDS; 
	if(PRCGetHasSpell(SPELL_EXTRACT_DRUG, oTarget))           		return SPELL_EXTRACT_DRUG;
	if(PRCGetHasSpell(SPELL_OBSCURE_OBJECT, oTarget))           		return SPELL_OBSCURE_OBJECT;	
	if(PRCGetHasSpell(2839, oTarget))           					return 2839; //:: Disguise Self
    return nSpell;
}

int GetBestL2Spell(object oTarget, int nSpell)
{
    if(PRCGetHasSpell(SPELL_MELFS_ACID_ARROW, oTarget))               return SPELL_MELFS_ACID_ARROW;
    if(PRCGetHasSpell(SPELL_BULLS_STRENGTH, oTarget))                 return SPELL_BULLS_STRENGTH;
    if(PRCGetHasSpell(SPELL_CATS_GRACE, oTarget))                     return SPELL_CATS_GRACE;
    if(PRCGetHasSpell(SPELL_ENDURANCE, oTarget))                      return SPELL_ENDURANCE;
    if(PRCGetHasSpell(SPELL_FOXS_CUNNING, oTarget))                   return SPELL_FOXS_CUNNING;
    if(PRCGetHasSpell(SPELL_EAGLE_SPLEDOR, oTarget))                  return SPELL_EAGLE_SPLEDOR;
    if(PRCGetHasSpell(SPELL_OWLS_WISDOM, oTarget))                    return SPELL_OWLS_WISDOM;
    if(PRCGetHasSpell(SPELL_PROTECTION_FROM_ELEMENTS, oTarget))       return SPELL_PROTECTION_FROM_ELEMENTS;
    if(PRCGetHasSpell(SPELL_SUMMON_CREATURE_II, oTarget))             return SPELL_SUMMON_CREATURE_II;
    if(PRCGetHasSpell(SPELL_ONE_WITH_THE_LAND, oTarget))              return SPELL_ONE_WITH_THE_LAND;
    if(PRCGetHasSpell(SPELL_INVISIBILITY, oTarget))                   return SPELL_INVISIBILITY;
    if(PRCGetHasSpell(SPELL_CLARITY, oTarget))                        return SPELL_CLARITY;
    if(PRCGetHasSpell(SPELL_FIND_TRAPS, oTarget))                     return SPELL_FIND_TRAPS;
    if(PRCGetHasSpell(SPELL_LESSER_RESTORATION, oTarget))             return SPELL_LESSER_RESTORATION;
    if(PRCGetHasSpell(SPELL_FLAME_LASH, oTarget))                     return SPELL_FLAME_LASH;
    if(PRCGetHasSpell(SPELL_FLAME_WEAPON, oTarget))                   return SPELL_FLAME_WEAPON;
    if(PRCGetHasSpell(SPELL_WEB, oTarget))                            return SPELL_WEB;
    if(PRCGetHasSpell(SPELL_COMBUST, oTarget))                        return SPELL_COMBUST;
    if(PRCGetHasSpell(SPELL_GHOUL_TOUCH, oTarget))                    return SPELL_GHOUL_TOUCH;
    if(PRCGetHasSpell(SPELL_KNOCK, oTarget))                          return SPELL_KNOCK;
    if(PRCGetHasSpell(SPELL_GHOSTLY_VISAGE, oTarget))                 return SPELL_GHOSTLY_VISAGE;
    if(PRCGetHasSpell(SPELL_SOUND_BURST, oTarget))                    return SPELL_SOUND_BURST;
    if(PRCGetHasSpell(SPELL_SILENCE, oTarget))                        return SPELL_SILENCE;
    if(PRCGetHasSpell(SPELL_SEE_INVISIBILITY, oTarget))               return SPELL_SEE_INVISIBILITY;
    if(PRCGetHasSpell(SPELL_HOLD_PERSON, oTarget))                    return SPELL_HOLD_PERSON;
    if(PRCGetHasSpell(SPELL_GEDLEES_ELECTRIC_LOOP, oTarget))          return SPELL_GEDLEES_ELECTRIC_LOOP;
    if(PRCGetHasSpell(SPELL_REMOVE_PARALYSIS, oTarget))               return SPELL_REMOVE_PARALYSIS;
    if(PRCGetHasSpell(SPELL_CLOUD_OF_BEWILDERMENT, oTarget))          return SPELL_CLOUD_OF_BEWILDERMENT;
    if(PRCGetHasSpell(SPELL_TASHAS_HIDEOUS_LAUGHTER, oTarget))        return SPELL_TASHAS_HIDEOUS_LAUGHTER;
    if(PRCGetHasSpell(SPELL_BLOOD_FRENZY, oTarget))                   return SPELL_BLOOD_FRENZY;
    if(PRCGetHasSpell(SPELL_BLINDNESS_AND_DEAFNESS, oTarget))         return SPELL_BLINDNESS_AND_DEAFNESS;
    if(PRCGetHasSpell(SPELL_STONE_BONES, oTarget))                    return SPELL_STONE_BONES;
    if(PRCGetHasSpell(SPELL_BARKSKIN, oTarget))                       return SPELL_BARKSKIN;
    if(PRCGetHasSpell(SPELL_DARKVISION, oTarget))                     return SPELL_DARKVISION;
    if(PRCGetHasSpell(SPELL_DEATH_ARMOR, oTarget))                    return SPELL_DEATH_ARMOR;
    if(PRCGetHasSpell(SPELL_DARKNESS, oTarget))                       return SPELL_DARKNESS;
    if(PRCGetHasSpell(SPELL_CHARM_PERSON_OR_ANIMAL, oTarget))         return SPELL_CHARM_PERSON_OR_ANIMAL;
    if(PRCGetHasSpell(SPELL_AURAOFGLORY, oTarget))                    return SPELL_AURAOFGLORY;
    if(PRCGetHasSpell(SPELL_HOLD_ANIMAL, oTarget))                    return SPELL_HOLD_ANIMAL;
    if(PRCGetHasSpell(SPELL_AID, oTarget))                            return SPELL_AID;
    if(PRCGetHasSpell(SPELL_CONTINUAL_FLAME, oTarget))                return SPELL_CONTINUAL_FLAME;
    if(PRCGetHasSpell(SPELL_CURE_MODERATE_WOUNDS, oTarget))           return SPELL_CURE_MODERATE_WOUNDS;
    if(PRCGetHasSpell(SPELL_INFLICT_MODERATE_WOUNDS, oTarget))        return SPELL_INFLICT_MODERATE_WOUNDS;    
    return nSpell;
}

int GetBestL3Spell(object oTarget, int nSpell)
{
    if(PRCGetHasSpell(SPELL_FLAME_ARROW, oTarget))                    return SPELL_FLAME_ARROW;
    if(PRCGetHasSpell(SPELL_CALL_LIGHTNING, oTarget))                 return SPELL_CALL_LIGHTNING;
    if(PRCGetHasSpell(SPELL_FIREBALL, oTarget))                       return SPELL_FIREBALL;
    if(PRCGetHasSpell(SPELL_DISPLACEMENT, oTarget))                   return SPELL_DISPLACEMENT;
    if(PRCGetHasSpell(SPELL_DISPEL_MAGIC, oTarget))                   return SPELL_DISPEL_MAGIC;
    if(PRCGetHasSpell(SPELL_HASTE, oTarget))                          return SPELL_HASTE;
    if(PRCGetHasSpell(SPELL_SLOW, oTarget))                           return SPELL_SLOW;
    if(PRCGetHasSpell(SPELL_VAMPIRIC_TOUCH, oTarget))                 return SPELL_VAMPIRIC_TOUCH;
    if(PRCGetHasSpell(SPELL_SEARING_LIGHT, oTarget))                  return SPELL_SEARING_LIGHT;
    if(PRCGetHasSpell(SPELL_SCINTILLATING_SPHERE, oTarget))           return SPELL_SCINTILLATING_SPHERE;
    if(PRCGetHasSpell(SPELL_MESTILS_ACID_BREATH, oTarget))            return SPELL_MESTILS_ACID_BREATH;
    if(PRCGetHasSpell(SPELL_MAGIC_CIRCLE_AGAINST_LAW, oTarget))       return SPELL_MAGIC_CIRCLE_AGAINST_LAW;
    if(PRCGetHasSpell(SPELL_MAGIC_CIRCLE_AGAINST_GOOD, oTarget))      return SPELL_MAGIC_CIRCLE_AGAINST_GOOD;
    if(PRCGetHasSpell(SPELL_MAGIC_CIRCLE_AGAINST_EVIL, oTarget))      return SPELL_MAGIC_CIRCLE_AGAINST_EVIL;
    if(PRCGetHasSpell(SPELL_MAGIC_CIRCLE_AGAINST_CHAOS, oTarget))     return SPELL_MAGIC_CIRCLE_AGAINST_CHAOS;
    if(PRCGetHasSpell(SPELL_LIGHTNING_BOLT, oTarget))                 return SPELL_LIGHTNING_BOLT;
    if(PRCGetHasSpell(SPELL_NEGATIVE_ENERGY_BURST, oTarget))          return SPELL_NEGATIVE_ENERGY_BURST;
    if(PRCGetHasSpell(SPELL_SUMMON_CREATURE_III, oTarget))            return SPELL_SUMMON_CREATURE_III;
    if(PRCGetHasSpell(SPELL_KEEN_EDGE, oTarget))                      return SPELL_KEEN_EDGE;
    if(PRCGetHasSpell(SPELL_MAGIC_VESTMENT, oTarget))                 return SPELL_MAGIC_VESTMENT;
    if(PRCGetHasSpell(SPELL_DOMINATE_ANIMAL, oTarget))                return SPELL_DOMINATE_ANIMAL;
    if(PRCGetHasSpell(SPELL_GLYPH_OF_WARDING, oTarget))               return SPELL_GLYPH_OF_WARDING;
    if(PRCGetHasSpell(SPELL_INVISIBILITY_SPHERE, oTarget))            return SPELL_INVISIBILITY_SPHERE;
    if(PRCGetHasSpell(SPELL_INVISIBILITY_PURGE, oTarget))             return SPELL_INVISIBILITY_PURGE;
    if(PRCGetHasSpell(SPELL_FEAR, oTarget))                           return SPELL_FEAR;
    if(PRCGetHasSpell(SPELL_BLADE_THIRST, oTarget))                   return SPELL_BLADE_THIRST;
    if(PRCGetHasSpell(SPELL_GREATER_MAGIC_WEAPON, oTarget))           return SPELL_GREATER_MAGIC_WEAPON;
    if(PRCGetHasSpell(SPELL_POISON, oTarget))                         return SPELL_POISON;
    if(PRCGetHasSpell(SPELL_STINKING_CLOUD, oTarget))                 return SPELL_STINKING_CLOUD;
    if(PRCGetHasSpell(SPELL_SPIKE_GROWTH, oTarget))                   return SPELL_SPIKE_GROWTH;
    if(PRCGetHasSpell(SPELL_WOUNDING_WHISPERS, oTarget))              return SPELL_WOUNDING_WHISPERS;
    if(PRCGetHasSpell(SPELL_QUILLFIRE, oTarget))                      return SPELL_QUILLFIRE;
    if(PRCGetHasSpell(SPELL_GREATER_MAGIC_FANG, oTarget))             return SPELL_GREATER_MAGIC_FANG;
    if(PRCGetHasSpell(SPELL_GUST_OF_WIND, oTarget))                   return SPELL_GUST_OF_WIND;
    if(PRCGetHasSpell(SPELL_INFESTATION_OF_MAGGOTS, oTarget))         return SPELL_INFESTATION_OF_MAGGOTS;
    if(PRCGetHasSpell(SPELL_ANIMATE_DEAD, oTarget))                   return SPELL_ANIMATE_DEAD;
    if(PRCGetHasSpell(SPELL_NEUTRALIZE_POISON, oTarget))              return SPELL_NEUTRALIZE_POISON;
    if(PRCGetHasSpell(SPELL_NEGATIVE_ENERGY_PROTECTION, oTarget))     return SPELL_NEGATIVE_ENERGY_PROTECTION;
    if(PRCGetHasSpell(SPELL_CONTAGION, oTarget))                      return SPELL_CONTAGION;
    if(PRCGetHasSpell(SPELL_HEALING_STING, oTarget))                  return SPELL_HEALING_STING;
    if(PRCGetHasSpell(SPELL_REMOVE_DISEASE, oTarget))                 return SPELL_REMOVE_DISEASE;
    if(PRCGetHasSpell(SPELL_REMOVE_CURSE, oTarget))                   return SPELL_REMOVE_CURSE;
    if(PRCGetHasSpell(SPELL_REMOVE_BLINDNESS_AND_DEAFNESS, oTarget))  return SPELL_REMOVE_BLINDNESS_AND_DEAFNESS;
    if(PRCGetHasSpell(SPELL_CONFUSION, oTarget))                      return SPELL_CONFUSION;
    if(PRCGetHasSpell(SPELL_PRAYER, oTarget))                         return SPELL_PRAYER;
    if(PRCGetHasSpell(SPELL_DARKFIRE, oTarget))                       return SPELL_DARKFIRE;
    if(PRCGetHasSpell(SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE, oTarget)) return SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE;
    if(PRCGetHasSpell(SPELL_CHARM_MONSTER, oTarget))                  return SPELL_CHARM_MONSTER;
    if(PRCGetHasSpell(SPELL_BESTOW_CURSE, oTarget))                   return SPELL_BESTOW_CURSE;
    if(PRCGetHasSpell(SPELL_CURE_SERIOUS_WOUNDS, oTarget))            return SPELL_CURE_SERIOUS_WOUNDS;    
    if(PRCGetHasSpell(SPELL_INFLICT_SERIOUS_WOUNDS, oTarget))         return SPELL_INFLICT_SERIOUS_WOUNDS;    
    return nSpell;
}

int GetBestL4Spell(object oTarget, int nSpell)
{
    if(PRCGetHasSpell(SPELL_ISAACS_LESSER_MISSILE_STORM, oTarget))    return SPELL_ISAACS_LESSER_MISSILE_STORM;
    if(PRCGetHasSpell(SPELL_STONESKIN, oTarget))                      return SPELL_STONESKIN;
    if(PRCGetHasSpell(SPELL_DOMINATE_PERSON, oTarget))                return SPELL_DOMINATE_PERSON;
    if(PRCGetHasSpell(SPELL_LESSER_SPELL_BREACH, oTarget))            return SPELL_LESSER_SPELL_BREACH;
    if(PRCGetHasSpell(SPELL_ELEMENTAL_SHIELD, oTarget))               return SPELL_ELEMENTAL_SHIELD;
    if(PRCGetHasSpell(SPELL_IMPROVED_INVISIBILITY, oTarget))          return SPELL_IMPROVED_INVISIBILITY;
    if(PRCGetHasSpell(SPELL_ICE_STORM, oTarget))                      return SPELL_ICE_STORM;
    if(PRCGetHasSpell(SPELL_HAMMER_OF_THE_GODS, oTarget))             return SPELL_HAMMER_OF_THE_GODS;
    if(PRCGetHasSpell(SPELL_SUMMON_CREATURE_IV, oTarget))             return SPELL_SUMMON_CREATURE_IV;
    if(PRCGetHasSpell(SPELL_EVARDS_BLACK_TENTACLES, oTarget))         return SPELL_EVARDS_BLACK_TENTACLES;
    if(PRCGetHasSpell(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, oTarget)) return SPELL_MINOR_GLOBE_OF_INVULNERABILITY;
    if(PRCGetHasSpell(SPELL_LEGEND_LORE, oTarget))                    return SPELL_LEGEND_LORE;
    if(PRCGetHasSpell(SPELL_POLYMORPH_SELF, oTarget))                 return SPELL_POLYMORPH_SELF;
    if(PRCGetHasSpell(SPELL_PHANTASMAL_KILLER, oTarget))              return SPELL_PHANTASMAL_KILLER;
    if(PRCGetHasSpell(SPELL_DIVINE_POWER, oTarget))                   return SPELL_DIVINE_POWER;
    if(PRCGetHasSpell(SPELL_DEATH_WARD, oTarget))                     return SPELL_DEATH_WARD;
    if(PRCGetHasSpell(SPELL_FREEDOM_OF_MOVEMENT, oTarget))            return SPELL_FREEDOM_OF_MOVEMENT;
    if(PRCGetHasSpell(SPELL_WAR_CRY, oTarget))                        return SPELL_WAR_CRY;
    if(PRCGetHasSpell(SPELL_WALL_OF_FIRE, oTarget))                   return SPELL_WALL_OF_FIRE;
    if(PRCGetHasSpell(SPELL_RESTORATION, oTarget))                    return SPELL_RESTORATION;
    if(PRCGetHasSpell(SPELL_MASS_CAMOFLAGE, oTarget))                 return SPELL_MASS_CAMOFLAGE;
    if(PRCGetHasSpell(SPELL_ENERVATION, oTarget))                     return SPELL_ENERVATION;
    if(PRCGetHasSpell(SPELL_HOLY_SWORD, oTarget))                     return SPELL_HOLY_SWORD;
    if(PRCGetHasSpell(SPELL_HOLD_MONSTER, oTarget))                   return SPELL_HOLD_MONSTER;
    if(PRCGetHasSpell(SPELL_DISMISSAL, oTarget))                      return SPELL_DISMISSAL;
    if(PRCGetHasSpell(SPELL_INFLICT_CRITICAL_WOUNDS, oTarget))        return SPELL_INFLICT_CRITICAL_WOUNDS;    
    if(PRCGetHasSpell(SPELL_CURE_CRITICAL_WOUNDS, oTarget))           return SPELL_CURE_CRITICAL_WOUNDS;
    return nSpell;
}

int GetBestL5Spell(object oTarget, int nSpell)
{
    if(PRCGetHasSpell(SPELL_TRUE_SEEING, oTarget))                    return SPELL_TRUE_SEEING;
    if(PRCGetHasSpell(SPELL_BIGBYS_INTERPOSING_HAND, oTarget))        return SPELL_BIGBYS_INTERPOSING_HAND;
    if(PRCGetHasSpell(SPELL_GREATER_DISPELLING, oTarget))             return SPELL_GREATER_DISPELLING;
    if(PRCGetHasSpell(SPELL_LESSER_SPELL_MANTLE, oTarget))            return SPELL_LESSER_SPELL_MANTLE;
    if(PRCGetHasSpell(SPELL_SPELL_RESISTANCE, oTarget))               return SPELL_SPELL_RESISTANCE;
    if(PRCGetHasSpell(SPELL_MONSTROUS_REGENERATION, oTarget))         return SPELL_MONSTROUS_REGENERATION;
    if(PRCGetHasSpell(SPELL_RAISE_DEAD, oTarget))                     return SPELL_RAISE_DEAD;
    if(PRCGetHasSpell(SPELL_MIND_FOG, oTarget))                       return SPELL_MIND_FOG;
    if(PRCGetHasSpell(SPELL_SLAY_LIVING, oTarget))                    return SPELL_SLAY_LIVING;
    if(PRCGetHasSpell(SPELL_LESSER_PLANAR_BINDING, oTarget))          return SPELL_LESSER_PLANAR_BINDING;
    if(PRCGetHasSpell(SPELL_LESSER_MIND_BLANK, oTarget))              return SPELL_LESSER_MIND_BLANK;
    if(PRCGetHasSpell(SPELL_FLAME_STRIKE, oTarget))                   return SPELL_FLAME_STRIKE;
    if(PRCGetHasSpell(SPELL_FIREBRAND, oTarget))                      return SPELL_FIREBRAND;
    if(PRCGetHasSpell(SPELL_INFERNO, oTarget))                        return SPELL_INFERNO;
    if(PRCGetHasSpell(SPELL_CONE_OF_COLD, oTarget))                   return SPELL_CONE_OF_COLD;
    if(PRCGetHasSpell(SPELL_BALL_LIGHTNING, oTarget))                 return SPELL_BALL_LIGHTNING;
    if(PRCGetHasSpell(SPELL_ENERGY_BUFFER, oTarget))                  return SPELL_ENERGY_BUFFER;
    if(PRCGetHasSpell(SPELL_SUMMON_CREATURE_V, oTarget))              return SPELL_SUMMON_CREATURE_V;
    if(PRCGetHasSpell(SPELL_MESTILS_ACID_SHEATH, oTarget))            return SPELL_MESTILS_ACID_SHEATH;
    if(PRCGetHasSpell(SPELL_FEEBLEMIND, oTarget))                     return SPELL_FEEBLEMIND;
    if(PRCGetHasSpell(SPELL_ETHEREAL_VISAGE, oTarget))                return SPELL_ETHEREAL_VISAGE;
    if(PRCGetHasSpell(SPELL_VINE_MINE, oTarget))                      return SPELL_VINE_MINE;
    if(PRCGetHasSpell(SPELL_BATTLETIDE, oTarget))                     return SPELL_BATTLETIDE;
    if(PRCGetHasSpell(SPELL_CLOUDKILL, oTarget))                      return SPELL_CLOUDKILL;
    if(PRCGetHasSpell(SPELL_AWAKEN, oTarget))                         return SPELL_AWAKEN;
    if(PRCGetHasSpell(SPELL_HEALING_CIRCLE, oTarget))                 return SPELL_HEALING_CIRCLE;    
    if(PRCGetHasSpell(SPELL_CIRCLE_OF_DOOM, oTarget))                 return SPELL_CIRCLE_OF_DOOM;    
    return nSpell;
}

int GetBestL6Spell(object oTarget, int nSpell)
{
    if(PRCGetHasSpell(SPELL_ISAACS_GREATER_MISSILE_STORM, oTarget))   return SPELL_ISAACS_GREATER_MISSILE_STORM;
    if(PRCGetHasSpell(SPELL_BIGBYS_FORCEFUL_HAND, oTarget))           return SPELL_BIGBYS_FORCEFUL_HAND;
    if(PRCGetHasSpell(SPELL_CHAIN_LIGHTNING, oTarget))                return SPELL_CHAIN_LIGHTNING;
    if(PRCGetHasSpell(SPELL_MASS_HASTE, oTarget))                     return SPELL_MASS_HASTE;
    if(PRCGetHasSpell(SPELL_DROWN, oTarget))                          return SPELL_DROWN;
    if(PRCGetHasSpell(SPELL_GREATER_STONESKIN, oTarget))              return SPELL_GREATER_STONESKIN;
    if(PRCGetHasSpell(SPELL_GREATER_SPELL_BREACH, oTarget))           return SPELL_GREATER_SPELL_BREACH;
    if(PRCGetHasSpell(SPELL_CIRCLE_OF_DEATH, oTarget))                return SPELL_CIRCLE_OF_DEATH;
    if(PRCGetHasSpell(SPELL_GLOBE_OF_INVULNERABILITY, oTarget))       return SPELL_GLOBE_OF_INVULNERABILITY;
    if(PRCGetHasSpell(SPELL_UNDEATH_TO_DEATH, oTarget))               return SPELL_UNDEATH_TO_DEATH;
    if(PRCGetHasSpell(SPELL_CRUMBLE, oTarget))                        return SPELL_CRUMBLE;
    if(PRCGetHasSpell(SPELL_REGENERATE, oTarget))                     return SPELL_REGENERATE;
    if(PRCGetHasSpell(SPELL_SUMMON_CREATURE_VI, oTarget))             return SPELL_SUMMON_CREATURE_VI;
    if(PRCGetHasSpell(SPELL_STONEHOLD, oTarget))                      return SPELL_STONEHOLD;
    if(PRCGetHasSpell(SPELL_FLESH_TO_STONE, oTarget))                 return SPELL_FLESH_TO_STONE;
    if(PRCGetHasSpell(SPELL_STONE_TO_FLESH, oTarget))                 return SPELL_STONE_TO_FLESH;
    if(PRCGetHasSpell(SPELL_TENSERS_TRANSFORMATION, oTarget))         return SPELL_TENSERS_TRANSFORMATION;
    if(PRCGetHasSpell(SPELL_CREATE_UNDEAD, oTarget))                  return SPELL_CREATE_UNDEAD;
    if(PRCGetHasSpell(SPELL_CONTROL_UNDEAD, oTarget))                 return SPELL_CONTROL_UNDEAD;
    if(PRCGetHasSpell(SPELL_PLANAR_BINDING, oTarget))                 return SPELL_PLANAR_BINDING;
    if(PRCGetHasSpell(SPELL_PLANAR_ALLY, oTarget))                    return SPELL_PLANAR_ALLY;
    if(PRCGetHasSpell(SPELL_DIRGE, oTarget))                          return SPELL_DIRGE;
    if(PRCGetHasSpell(SPELL_BLADE_BARRIER, oTarget))                  return SPELL_BLADE_BARRIER;
    if(PRCGetHasSpell(SPELL_BANISHMENT, oTarget))                     return SPELL_BANISHMENT;
    if(PRCGetHasSpell(SPELL_ACID_FOG, oTarget))                       return SPELL_ACID_FOG;
    if(PRCGetHasSpell(SPELL_HEAL, oTarget))                           return SPELL_HEAL;
    if(PRCGetHasSpell(SPELL_HARM, oTarget))                           return SPELL_HARM;    
    return nSpell;
}

int GetBestL7Spell(object oTarget, int nSpell)
{
    if(PRCGetHasSpell(SPELL_SPELL_MANTLE, oTarget))                   return SPELL_SPELL_MANTLE;
    if(PRCGetHasSpell(SPELL_BIGBYS_GRASPING_HAND, oTarget))           return SPELL_BIGBYS_GRASPING_HAND;
    if(PRCGetHasSpell(SPELL_FIRE_STORM, oTarget))                     return SPELL_FIRE_STORM;
    if(PRCGetHasSpell(SPELL_FINGER_OF_DEATH, oTarget))                return SPELL_FINGER_OF_DEATH;
    if(PRCGetHasSpell(SPELL_PROTECTION_FROM_SPELLS, oTarget))         return SPELL_PROTECTION_FROM_SPELLS;
    if(PRCGetHasSpell(SPELL_WORD_OF_FAITH, oTarget))                  return SPELL_WORD_OF_FAITH;
    if(PRCGetHasSpell(SPELL_SHADOW_SHIELD, oTarget))                  return SPELL_SHADOW_SHIELD;
    if(PRCGetHasSpell(SPELL_CREEPING_DOOM, oTarget))                  return SPELL_CREEPING_DOOM;
    if(PRCGetHasSpell(SPELL_DESTRUCTION, oTarget))                    return SPELL_DESTRUCTION;
    if(PRCGetHasSpell(SPELL_PRISMATIC_SPRAY, oTarget))                return SPELL_PRISMATIC_SPRAY;
    if(PRCGetHasSpell(SPELL_DELAYED_BLAST_FIREBALL, oTarget))         return SPELL_DELAYED_BLAST_FIREBALL;
    if(PRCGetHasSpell(SPELL_GREAT_THUNDERCLAP, oTarget))              return SPELL_GREAT_THUNDERCLAP;
    if(PRCGetHasSpell(SPELL_POWER_WORD_STUN, oTarget))                return SPELL_POWER_WORD_STUN;
    if(PRCGetHasSpell(SPELL_MORDENKAINENS_SWORD, oTarget))            return SPELL_MORDENKAINENS_SWORD;
    if(PRCGetHasSpell(SPELL_RESURRECTION, oTarget))                   return SPELL_RESURRECTION;
    if(PRCGetHasSpell(SPELL_SUMMON_CREATURE_VII, oTarget))            return SPELL_SUMMON_CREATURE_VII;
    if(PRCGetHasSpell(SPELL_AURA_OF_VITALITY, oTarget))               return SPELL_AURA_OF_VITALITY;
    if(PRCGetHasSpell(SPELL_GREATER_RESTORATION, oTarget))            return SPELL_GREATER_RESTORATION;    
    return nSpell;
}

int GetBestL8Spell(object oTarget, int nSpell)
{
    if(PRCGetHasSpell(SPELL_BIGBYS_CLENCHED_FIST, oTarget))           return SPELL_BIGBYS_CLENCHED_FIST;
    if(PRCGetHasSpell(SPELL_HORRID_WILTING, oTarget))                 return SPELL_HORRID_WILTING;
    if(PRCGetHasSpell(SPELL_EARTHQUAKE, oTarget))                     return SPELL_EARTHQUAKE;
    if(PRCGetHasSpell(SPELL_NATURES_BALANCE, oTarget))                return SPELL_NATURES_BALANCE;
    if(PRCGetHasSpell(SPELL_INCENDIARY_CLOUD, oTarget))               return SPELL_INCENDIARY_CLOUD;
    if(PRCGetHasSpell(SPELL_MIND_BLANK, oTarget))                     return SPELL_MIND_BLANK;
    if(PRCGetHasSpell(SPELL_PREMONITION, oTarget))                    return SPELL_PREMONITION;
    if(PRCGetHasSpell(SPELL_SUNBURST, oTarget))                       return SPELL_SUNBURST;
    if(PRCGetHasSpell(SPELL_SUNBEAM, oTarget))                        return SPELL_SUNBEAM;
    if(PRCGetHasSpell(SPELL_MASS_CHARM, oTarget))                     return SPELL_MASS_CHARM;
    if(PRCGetHasSpell(SPELL_MASS_BLINDNESS_AND_DEAFNESS, oTarget))    return SPELL_MASS_BLINDNESS_AND_DEAFNESS;
    if(PRCGetHasSpell(SPELL_BOMBARDMENT, oTarget))                    return SPELL_BOMBARDMENT;
    if(PRCGetHasSpell(SPELL_GREATER_PLANAR_BINDING, oTarget))         return SPELL_GREATER_PLANAR_BINDING;
    if(PRCGetHasSpell(SPELL_SUMMON_CREATURE_VIII, oTarget))           return SPELL_SUMMON_CREATURE_VIII;
    if(PRCGetHasSpell(SPELL_CREATE_GREATER_UNDEAD, oTarget))          return SPELL_CREATE_GREATER_UNDEAD;
    if(PRCGetHasSpell(SPELL_BLACKSTAFF, oTarget))                     return SPELL_BLACKSTAFF;
    if(PRCGetHasSpell(SPELL_MASS_HEAL, oTarget))                      return SPELL_MASS_HEAL;    
    return nSpell;
}

int GetBestL9Spell(object oTarget, int nSpell)
{
    if(PRCGetHasSpell(SPELL_TIME_STOP, oTarget))                      return SPELL_TIME_STOP;
    if(PRCGetHasSpell(SPELL_BLACK_BLADE_OF_DISASTER, oTarget))        return SPELL_BLACK_BLADE_OF_DISASTER;
    if(PRCGetHasSpell(SPELL_MORDENKAINENS_DISJUNCTION, oTarget))      return SPELL_MORDENKAINENS_DISJUNCTION;
    if(PRCGetHasSpell(SPELL_GREATER_SPELL_MANTLE, oTarget))           return SPELL_GREATER_SPELL_MANTLE;
    if(PRCGetHasSpell(SPELL_BIGBYS_CRUSHING_HAND, oTarget))           return SPELL_BIGBYS_CRUSHING_HAND;
    if(PRCGetHasSpell(SPELL_WAIL_OF_THE_BANSHEE, oTarget))            return SPELL_WAIL_OF_THE_BANSHEE;
    if(PRCGetHasSpell(SPELL_WEIRD, oTarget))                          return SPELL_WEIRD;
    if(PRCGetHasSpell(SPELL_METEOR_SWARM, oTarget))                   return SPELL_METEOR_SWARM;
    if(PRCGetHasSpell(SPELL_IMPLOSION, oTarget))                      return SPELL_IMPLOSION;
    if(PRCGetHasSpell(SPELL_POWER_WORD_KILL, oTarget))                return SPELL_POWER_WORD_KILL;
    if(PRCGetHasSpell(SPELL_STORM_OF_VENGEANCE, oTarget))             return SPELL_STORM_OF_VENGEANCE;
    if(PRCGetHasSpell(SPELL_SHAPECHANGE, oTarget))                    return SPELL_SHAPECHANGE;
    if(PRCGetHasSpell(SPELL_DOMINATE_MONSTER, oTarget))               return SPELL_DOMINATE_MONSTER;
    if(PRCGetHasSpell(SPELL_ELEMENTAL_SWARM, oTarget))                return SPELL_ELEMENTAL_SWARM;
    if(PRCGetHasSpell(SPELL_SUMMON_CREATURE_IX, oTarget))             return SPELL_SUMMON_CREATURE_IX;
    if(PRCGetHasSpell(SPELL_GATE, oTarget))                           return SPELL_GATE;
    if(PRCGetHasSpell(SPELL_ENERGY_DRAIN, oTarget))                   return SPELL_ENERGY_DRAIN;
    if(PRCGetHasSpell(SPELL_UNDEATHS_ETERNAL_FOE, oTarget))           return SPELL_UNDEATHS_ETERNAL_FOE;
    return nSpell;
}

int GetBestAvailableSpell(object oTarget)
{
    int nBestSpell = GetBestL9Spell(oTarget, 99999);
    if(nBestSpell == 99999) nBestSpell = GetBestL8Spell(oTarget, nBestSpell);
    if(nBestSpell == 99999) nBestSpell = GetBestL7Spell(oTarget, nBestSpell);
    if(nBestSpell == 99999) nBestSpell = GetBestL6Spell(oTarget, nBestSpell);
    if(nBestSpell == 99999) nBestSpell = GetBestL5Spell(oTarget, nBestSpell);
    if(nBestSpell == 99999) nBestSpell = GetBestL4Spell(oTarget, nBestSpell);
    if(nBestSpell == 99999) nBestSpell = GetBestL3Spell(oTarget, nBestSpell);
    if(nBestSpell == 99999) nBestSpell = GetBestL2Spell(oTarget, nBestSpell);
    if(nBestSpell == 99999) nBestSpell = GetBestL1Spell(oTarget, nBestSpell);
    if(nBestSpell == 99999) nBestSpell = GetBestL0Spell(oTarget, nBestSpell);
    return nBestSpell;
}