/** @file
 *
 * Include file for various constants that don't really belong in any of the other files,
 * but aren't numerous enough to warrant their own.
 */

//:://////////////////////////////////////////////
//:: New effect icons (effecticons.2da)
//:://////////////////////////////////////////////
const int EFFECT_ICON_DARKVISION 	= 130;
const int EFFECT_ICON_ULTRAVISION	= 131;

//:://////////////////////////////////////////////
//:: New damage types (damagetypes.2da)
//:://////////////////////////////////////////////
const int DAMAGE_TYPE_POISON	= 16384;	// CUSTOM2
const int DAMAGE_TYPE_PSYCHIC	= 32768;	// CUSTOM4
const int DAMAGE_TYPE_RADIANT	= 65536;	// CUSTOM6
const int DAMAGE_TYPE_FORCE		= 524288;	// CUSTOM7
const int DAMAGE_TYPE_UNTYPED	= 1048576;	// CUSTOM8
const int DAMAGE_TYPE_VILE		= 2097152; 	// CUSTOM9


//:://////////////////////////////////////////////
//:: New base item types
//:://////////////////////////////////////////////

const int BASE_ITEM_GOLEM          		= 23;	//:: not actually used for anything else 
const int BASE_ITEM_LIGHT_LANCE     	= 92;       
const int BASE_ITEM_ALCHEMY				= 99;	//:: not actually used for anything else
const int BASE_ITEM_POISON          	= 100;	//:: not actually used for anything else
const int BASE_ITEM_HEAVY_PICK      	= 115;
const int BASE_ITEM_LIGHT_PICK      	= 116;
const int BASE_ITEM_SAI             	= 117;
const int BASE_ITEM_NUNCHAKU        	= 118;
const int BASE_ITEM_FALCHION        	= 119;
const int BASE_ITEM_SAP             	= 120;
const int BASE_ITEM_KATAR           	= 121;
const int BASE_ITEM_HEAVY_MACE      	= 122;
const int BASE_ITEM_MAUL            	= 123;
const int BASE_ITEM_DOUBLE_SCIMITAR 	= 124;
const int BASE_ITEM_GOAD            	= 125;
const int BASE_ITEM_EAGLE_CLAW      	= 126;
const int BASE_ITEM_CRAFTED_ROD     	= 199;
const int BASE_ITEM_CRAFTED_STAFF   	= 201;
const int BASE_ITEM_ELVEN_LIGHTBLADE  	= 202;
const int BASE_ITEM_ELVEN_THINBLADE   	= 203;
const int BASE_ITEM_ELVEN_COURTBLADE  	= 204;
const int BASE_ITEM_CRAFTED_SCEPTER		= 249;
const int BASE_ITEM_CRAFTED_VIAL		= 250;
const int BASE_ITEM_MUNDANE_HERB		= 252;
const int BASE_ITEM_INFUSED_HERB		= 253;

//:://////////////////////////////////////////////
//:: Player Health Const
//:://////////////////////////////////////////////
 
const int ALIVE         = 0;
const int BLEEDING      = 1;
const int STABLE        = 2;
const int DISABLED      = 3;
const int DEAD          = 4;
const int ALTERED_STATE = 5;

//:://////////////////////////////////////////////
//:: Area of Effect Const
//:://////////////////////////////////////////////

const int AOE_MOB_PESTILENCE                    = 150;
const int AOE_PER_TELEPORTATIONCIRCLE           = 151;
const int AOE_PER_DEEPER_DARKNESS               = 213;
const int AOE_PER_OBSCURING_MIST                = 141;
const int AOE_PER_ACHAIERAI                     = 206;
const int AOE_PER_UTTERDARK                     = 205;
const int AOE_PER_DAMNDARK                      = 203;
const int VFX_MOB_BRILLIANT_EMANATION           = 204;
const int AOE_PER_BLNDGLORY                     = 183;
const int VFX_AOE_RAIN_OF_BLACK_TULIPS          = 182;
const int VFX_AOE_RAIN_OF_ROSES                 = 181;
const int AOE_PER_REPEL_VERMIN                  = 180;
const int AOE_PER_SOLID_FOG                     = 179;
const int AOE_PER_REPULSION                     = 178;
const int AOE_PER_CALM_EMOTIONS                 = 177;
const int VFX_PER_AVASMASS                      = 141;
const int VFX_PER_SICKEN_EVIL                   = 176;
const int VFX_PER_SLEET_STORM                   = 175;
const int VFX_PER_OTILUKES_RESILIENT_SPHERE     = 174;
const int VFX_PER_PRISMATIC_SPHERE              = 173;
const int VFX_MOB_RING_OF_BLADES                = 172;
const int VFX_PER_PRISMATIC_WALL                = 171;
const int AOE_PER_FIRE_TRAP                     = 170;
const int AOE_PER_PYROTECHNICS_SMOKE            = 169;
const int VFX_PER_SNARE                         = 168;
const int AOE_MOB_MOUNTAIN_AVALANCHE            = 167;
const int VFX_MOB_DAYLIGHT                      = 109;
const int VFX_MOB_CLOUDY_CONJURATION            = 99;
const int AOE_PER_CRACKLEPOWDER                 = 98;
const int AOE_MOB_LUMINOUS_ARMOR                = 97;
const int VFX_PER_GREEN_FOG                     = 96;
const int VFX_PER_RAIN_OF_BLOOD                 = 95;
const int VFX_PER_RAIN_OF_FROGS                 = 94;
const int VFX_PER_VIOLET_RAIN                   = 93;
const int AOE_PER_WALLFROST                     = 207;
const int AOE_PER_CONSECRATE                    = 115;
const int AOE_PER_DESECRATE                     = 111;
const int AOE_PER_WALLDISPEL                    = 116;

// Psionic Area of Effects
const int AOE_PER_PSIGREASE                     = 131;
const int AOE_PER_ESHAMBLER                     = 132;
const int AOE_PER_ENERGYWALL                    = 133;
const int AOE_MOB_CATAPSI                       = 134;
const int AOE_PER_NULL_PSIONICS_FIELD           = 135;
const int AOE_MOB_FORM_DOOM                     = 136;
const int AOE_PER_ENERGYWALL_WIDENED            = 137;
const int AOE_PER_ESHAMBLER_WIDENED             = 138;
const int AOE_PER_NULL_PSIONICS_FIELD_WIDENED   = 139;
const int VFX_PER_NEW_TIMESTOP                  = 140;


// Invisible Area of Effects
const int VFX_PER_5_FT_INVIS                    = 184;
const int VFX_PER_10_FT_INVIS                   = 185;
const int VFX_PER_15_FT_INVIS                   = 186;
const int VFX_PER_20_FT_INVIS                   = 187;
const int VFX_PER_25_FT_INVIS                   = 188;
const int VFX_PER_30_FT_INVIS                   = 189;
const int VFX_PER_5M_INVIS                      = 190;
const int VFX_PER_10M_INVIS                     = 191;
const int VFX_PER_15M_INVIS                     = 192;
const int VFX_PER_20M_INVIS                     = 193;
const int VFX_PER_25M_INVIS                     = 194;
const int VFX_PER_30M_INVIS                     = 195;
const int VFX_PER_35M_INVIS                     = 196;
const int VFX_PER_40M_INVIS                     = 197;
const int VFX_PER_45M_INVIS                     = 198;
const int VFX_PER_50M_INVIS                     = 199;

// Knight Area of Effects
const int AOE_MOB_BULWARK_DEFENSE               = 162;
const int AOE_MOB_VIGILANT_DEFENDER             = 163;

//Exhaled Barrier Area of Effect
const int AOE_PER_WALLBREATH                    = 152;

//Racial AOEs
const int AOE_PER_NYMPH_BLINDING                = 225;

// DNecro Area of Effects
const int AOE_MOB_DN_FEAR_AURA                  = 254;

// DragonShaman/Marshal Auras
const int AOE_MOB_DRACONIC_AURA_1               = 153;
const int AOE_MOB_DRACONIC_AURA_2               = 154;
const int AOE_MOB_MARSHAL_MINOR_AURA            = 155;
const int AOE_MOB_MARSHAL_MAJOR_AURA            = 156;

//:://////////////////////////////////////////////
//:: Disease Const
//:://////////////////////////////////////////////

const int DISEASE_CONTAGION_BLINDING_SICKNESS   = 20;
const int DISEASE_CONTAGION_CACKLE_FEVER        = 21;
const int DISEASE_CONTAGION_FILTH_FEVER         = 22;
const int DISEASE_CONTAGION_MINDFIRE            = 23;
const int DISEASE_CONTAGION_RED_ACHE            = 24;
const int DISEASE_CONTAGION_SHAKES              = 25;
const int DISEASE_CONTAGION_SLIMY_DOOM          = 26;
const int DISEASE_PESTILENCE                    = 51;
const int DISEASE_BLUE_GUTS                     = 53;
const int DISEASE_SOUL_ROT                      = 54;
const int DISEASE_AGONY_ADDICTION               = 55;
const int DISEASE_BACCARAN_ADDICTION            = 56;
const int DISEASE_DEVILWEED_ADDICTION           = 57;
const int DISEASE_LUHIX_ADDICTION               = 58;
const int DISEASE_MUSHROOM_POWDER_ADDICTION     = 59;
const int DISEASE_SANNISH_ADDICTION             = 60;
const int DISEASE_TERRAN_BRANDY_ADDICTION       = 61;
const int DISEASE_VODARE_ADDICTION              = 62;

//:://////////////////////////////////////////////
//:: Poison Const
//:://////////////////////////////////////////////

const int POISON_TINY_CENTIPEDE_POISON          = 122;
const int POISON_MEDIUM_CENTIPEDE_POISON        = 123;
const int POISON_LARGE_CENTIPEDE_POISON         = 124;
const int POISON_HUGE_CENTIPEDE_POISON          = 125;
const int POISON_GARGANTUAN_CENTIPEDE_POISON    = 126;
const int POISON_COLOSSAL_CENTIPEDE_POISON      = 127;

const int POISON_TINY_SCORPION_VENOM            = 128;
const int POISON_SMALL_SCORPION_VENOM           = 129;
const int POISON_MEDIUM_SCORPION_VENOM          = 130;
const int POISON_HUGE_SCORPION_VENOM            = 131;
const int POISON_GARGANTUAN_SCORPION_VENOM      = 132;
const int POISON_COLOSSAL_SCOPRION_VENOM        = 133;

const int POISON_EYEBLAST                       = 134;
const int POISON_BALOR_BILE                     = 135;
const int POISON_VILESTAR                       = 136;
const int POISON_SASSON_JUICE                   = 137;

const int POISON_SUFFERFUME                     = 138;
const int POISON_URTHANYK                       = 139;
const int POISON_MIST_OF_NOURN                  = 140;
const int POISON_ISHENTAV                       = 141;
const int POISON_BURNING_ANGEL_WING_FUMES       = 142;

const int POISON_RAVAGE_GOLDEN_ICE              = 100;
const int POISON_RAVAGE_CELESTIAL_LIGHTSBLOOD   = 143;
const int POISON_RAVAGE_JADE_WATER              = 144;
const int POISON_RAVAGE_PURIFIED_COUATL_VENOM   = 145;
const int POISON_RAVAGE_UNICORN_BLOOD           = 146;

//:://////////////////////////////////////////////
//:: Skill Const
//:://////////////////////////////////////////////

const int SKILL_JUMP            = 28;
const int SKILL_TRUESPEAK       = 29;
const int SKILL_SENSE_MOTIVE    = 30;
const int SKILL_MARTIAL_LORE    = 31;
const int SKILL_BALANCE         = 32;
const int SKILL_IAIJUTSU_FOCUS  = 33; // moved for ride
const int SKILL_CRAFT_ALCHEMY   = 34;
const int SKILL_CRAFT_POISON    = 35;
const int SKILL_PSICRAFT        = 36;
const int SKILL_CLIMB           = 37;
const int SKILL_CRAFT_GENERAL   = 38;

//:://////////////////////////////////////////////
//:: Size Const
//:://////////////////////////////////////////////

const int CREATURE_SIZE_FINE            = -1;
/**
 * Yes, this is the same as CREATURE_SIZE_INVALID, live with it.
 * If it weren't, the constants wouldn't be straight series any longer.
 */
const int CREATURE_SIZE_DIMINUTIVE      =  0;
const int CREATURE_SIZE_GARGANTUAN      =  6;
const int CREATURE_SIZE_COLOSSAL        =  7;


//:://////////////////////////////////////////////
//:: Psionic Discipline Const
//:://////////////////////////////////////////////

// Psionic Disciplines
const int DISCIPLINE_NONE             = 0;
const int DISCIPLINE_PSYCHOMETABOLISM = 1;
const int DISCIPLINE_PSYCHOKINESIS    = 2;
const int DISCIPLINE_PSYCHOPORTATION  = 3;
const int DISCIPLINE_CLAIRSENTIENCE   = 4;
const int DISCIPLINE_METACREATIVITY   = 5;
const int DISCIPLINE_TELEPATHY        = 6;


//:://////////////////////////////////////////////
//:: Polymorph Const
//:://////////////////////////////////////////////

const int POLYMORPH_TYPE_BAT					   = 47;	
const int POLYMORPH_TYPE_WOLF_0                    = 133;
const int POLYMORPH_TYPE_WOLF_1                    = 134;
const int POLYMORPH_TYPE_WOLF_2                    = 135;
const int POLYMORPH_TYPE_WEREWOLF_0                = 136;
const int POLYMORPH_TYPE_WEREWOLF_1                = 137;
const int POLYMORPH_TYPE_WEREWOLF_2                = 138;

const int POLYMORPH_TYPE_WOLF_0s                   = 139;
const int POLYMORPH_TYPE_WOLF_1s                   = 140;
const int POLYMORPH_TYPE_WOLF_2s                   = 141;
const int POLYMORPH_TYPE_WEREWOLF_0s               = 142;
const int POLYMORPH_TYPE_WEREWOLF_1s               = 143;
const int POLYMORPH_TYPE_WEREWOLF_2s               = 144;

const int POLYMORPH_TYPE_WOLF_0l                   = 145;
const int POLYMORPH_TYPE_WOLF_1l                   = 146;
const int POLYMORPH_TYPE_WOLF_2l                   = 147;
const int POLYMORPH_TYPE_WEREWOLF_0l               = 148;
const int POLYMORPH_TYPE_WEREWOLF_1l               = 149;
const int POLYMORPH_TYPE_WEREWOLF_2l               = 150;

//:: Wild Shape: Plant
const int POLYMORPH_TYPE_TREANT				= 160;
const int POLYMORPH_TYPE_SHAMBLING_MOUND	= 161;
const int POLYMORPH_TYPE_TWIG_BLIGHT		= 162;
const int POLYMORPH_TYPE_MYCONID			= 163;
const int POLYMORPH_TYPE_ALGOID				= 164;

//::///////////////////
//:: DOMAIN CONSTANTS
//:: These constants are off by 1 to allow 0 to be the FALSE return value.
//::///////////////////

const int PRC_DOMAIN_AIR           	= 1;
const int PRC_DOMAIN_ANIMAL        	= 2;
const int PRC_DOMAIN_CHAOS			= 3;
const int PRC_DOMAIN_DEATH         	= 4;
const int PRC_DOMAIN_DESTRUCTION	= 5;
const int PRC_DOMAIN_EARTH         	= 6;
const int PRC_DOMAIN_EVIL          	= 7;
const int PRC_DOMAIN_FIRE          	= 8;
const int PRC_DOMAIN_GOOD          	= 9;
const int PRC_DOMAIN_HEALING       	= 10;
const int PRC_DOMAIN_KNOWLEDGE     	= 11;
const int PRC_DOMAIN_LAW			= 12;
const int PRC_DOMAIN_LUCK			= 13;
const int PRC_DOMAIN_MAGIC         	= 14;
const int PRC_DOMAIN_PLANT         	= 15;
const int PRC_DOMAIN_PROTECTION    	= 16;
const int PRC_DOMAIN_STRENGTH      	= 17;
const int PRC_DOMAIN_SUN           	= 18;
const int PRC_DOMAIN_TRAVEL        	= 19;
const int PRC_DOMAIN_TRICKERY      	= 20;
const int PRC_DOMAIN_WAR           	= 21;
const int PRC_DOMAIN_WATER         	= 22;
const int PRC_DOMAIN_GLORY         	= 26;
const int PRC_DOMAIN_MADNESS		= 27;
const int PRC_DOMAIN_MIND         	= 28;
const int PRC_DOMAIN_MOON         	= 29;
const int PRC_DOMAIN_DARKNESS      	= 31;
const int PRC_DOMAIN_STORM         	= 32;
const int PRC_DOMAIN_METAL         	= 33;
const int PRC_DOMAIN_PORTAL        	= 34;
const int PRC_DOMAIN_FORCE        	= 35;
const int PRC_DOMAIN_SLIME         	= 36;
const int PRC_DOMAIN_TYRANNY       	= 37;
const int PRC_DOMAIN_DOMINATION    	= 38;
const int PRC_DOMAIN_SPIDER        	= 39;
const int PRC_DOMAIN_UNDEATH       	= 40;
const int PRC_DOMAIN_TIME          	= 41;
const int PRC_DOMAIN_DWARF         	= 42;
const int PRC_DOMAIN_CHARM         	= 43;
const int PRC_DOMAIN_ELF           	= 44;
const int PRC_DOMAIN_FAMILY        	= 45;
const int PRC_DOMAIN_FATE          	= 46;
const int PRC_DOMAIN_GNOME         	= 47;
const int PRC_DOMAIN_ILLUSION      	= 48;
const int PRC_DOMAIN_HATRED        	= 49;
const int PRC_DOMAIN_HALFLING      	= 50;
const int PRC_DOMAIN_NOBILITY      	= 51;
const int PRC_DOMAIN_OCEAN         	= 52;
const int PRC_DOMAIN_ORC           	= 53;
const int PRC_DOMAIN_RENEWAL       	= 54;
const int PRC_DOMAIN_RETRIBUTION   	= 55;
const int PRC_DOMAIN_RUNE          	= 56;
const int PRC_DOMAIN_SPELLS        	= 57;
const int PRC_DOMAIN_SCALEYKIND    	= 58;
const int PRC_DOMAIN_BLIGHTBRINGER 	= 59;
const int PRC_DOMAIN_DRAGON        	= 60;
const int PRC_DOMAIN_COLD          	= 61;
const int PRC_DOMAIN_WINTER        	= 62;

//:://////////////////////////////////////////////
//:: Trap Const
//:://////////////////////////////////////////////

const int TRAP_BASE_TYPE_PRGT       = 100;
const int TRAP_BASE_TYPE_TELECIRCLE = 101;
const int TRAP_BASE_TYPE_SYMBOL     = 102;

//:://////////////////////////////////////////////
//:: Breath Const
//:://////////////////////////////////////////////

const int BREATH_NORMAL      = 0;
const int BREATH_PYROCLASTIC = 1;
const int BREATH_SHADOW      = 2;
const int BREATH_SWIFT_WING  = 3;
const int BREATH_TOPAZ       = 4;
const int BREATH_PARALYZE    = 5;
const int BREATH_SLEEP       = 6;
const int BREATH_SLOW        = 7;
const int BREATH_WEAKENING   = 8;
const int BREATH_SICKENING   = 9;

// ONHIT Spells
const int IP_CONST_ONHIT_CASTSPELL_DRAGONFIRE = 203;
const int IP_CONST_ONHIT_KAPAK_POISON         = 204;


//:://////////////////////////////////////////////
//:: Wing Const
//:://////////////////////////////////////////////

const int PRC_WING_TYPE_DRAGON_BRASS    = 59;
const int PRC_WING_TYPE_DRAGON_BRONZE   = 60;
const int PRC_WING_TYPE_DRAGON_COPPER   = 61;
const int PRC_WING_TYPE_DRAGON_SILVER   = 62;
const int PRC_WING_TYPE_DRAGON_GOLD     = 63;
const int PRC_WING_TYPE_DRAGON_WHITE    = 64;
const int PRC_WING_TYPE_DRAGON_BLACK    = 65;
const int PRC_WING_TYPE_DRAGON_GREEN    = 66;
const int PRC_WING_TYPE_DRAGON_BLUE     = 67;
const int PRC_WING_TYPE_DRAGON_RED      = 68;
const int PRC_WING_TYPE_DRAGON_BRASS2   = 69;
const int PRC_WING_TYPE_DRAGON_BRONZE2  = 70;
const int PRC_WING_TYPE_DRAGON_COPPER2  = 71;
const int PRC_WING_TYPE_DRAGON_SILVER2  = 72;
const int PRC_WING_TYPE_DRAGON_GOLD2    = 73;
const int PRC_WING_TYPE_DRAGON_WHITE2   = 74;
const int PRC_WING_TYPE_DRAGON_BLACK2   = 75;
const int PRC_WING_TYPE_DRAGON_GREEN2   = 76;
const int PRC_WING_TYPE_DRAGON_BLUE2    = 77;
const int PRC_WING_TYPE_DRAGON_RED2     = 78;

//:://////////////////////////////////////////////
//:: Tail Const
//:://////////////////////////////////////////////

const int PRC_TAIL_TYPE_DRAGON_BRASS    = 4;
const int PRC_TAIL_TYPE_DRAGON_BRONZE   = 5;
const int PRC_TAIL_TYPE_DRAGON_COPPER   = 6;
const int PRC_TAIL_TYPE_DRAGON_SILVER   = 7;
const int PRC_TAIL_TYPE_DRAGON_GOLD     = 8;
const int PRC_TAIL_TYPE_DRAGON_BLACK    = 9;
const int PRC_TAIL_TYPE_DRAGON_BLUE     = 10;
const int PRC_TAIL_TYPE_DRAGON_GREEN    = 11;
const int PRC_TAIL_TYPE_DRAGON_RED      = 12;
const int PRC_TAIL_TYPE_DRAGON_WHITE    = 13;

//Morninglord
const int MOD_DAWN_START_HOUR           = 6;
const float INTERVAL_BLESSING_OF_DAWN   = 15.0;

//Healer
const int ASSOCIATE_TYPE_CELESTIALCOMPANION = 9;

//:://////////////////////////////////////////////
//:: Fortification Constants
//:://////////////////////////////////////////////

const int FORTIFICATION_LIGHT			= 25;
const int FORTIFICATION_MEDIUM			= 50;
const int FORTIFICATION_MODERATE		= 75;
const int FORTIFICATION_HEAVY			= 100;


//:: void main (){}