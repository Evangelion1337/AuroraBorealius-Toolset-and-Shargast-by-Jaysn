//:: // Material ItemProperty library //
//::////////////////////////////////////////////////////////////////////////////
//::	prc_inc_material
//::	
//:: 	Contains constants and functions for use with material itemproperties
//::	
//::	Original by Axe Murderer
//::
//::////////////////////////////////////////////////////////////////////////////
#include "prc_x2_itemprop"
  
//:: Material Type Constants
//::////////////////////////////////////////////////////////////////////////////
const int	MATERIAL_TYPE_INVALID			= -1;
const int	MATERIAL_TYPE_UNKNOWN			= 0;
const int	MATERIAL_TYPE_BONE				= 1;
const int	MATERIAL_TYPE_CERAMIC			= 2;
const int	MATERIAL_TYPE_CRYSTAL			= 3;
const int	MATERIAL_TYPE_FIBER				= 4;
const int	MATERIAL_TYPE_LEATHER			= 5;
const int	MATERIAL_TYPE_METAL				= 6;
const int	MATERIAL_TYPE_PAPER				= 7;
const int	MATERIAL_TYPE_ROPE				= 8;
const int	MATERIAL_TYPE_STONE				= 9;
const int	MATERIAL_TYPE_WOOD				= 10;
const int 	MATERIAL_TYPE_BOTANICAL			= 11;

const string MATERIAL_TYPE_NAME_INVALID		= "";
const string MATERIAL_TYPE_NAME_UNKNOWN		= "Unknown";
const string MATERIAL_TYPE_NAME_BONE		= "Bone";
const string MATERIAL_TYPE_NAME_CERAMIC		= "Ceramic";
const string MATERIAL_TYPE_NAME_CRYSTAL		= "Crystal";
const string MATERIAL_TYPE_NAME_FIBER		= "Fiber";
const string MATERIAL_TYPE_NAME_LEATHER		= "Leather";
const string MATERIAL_TYPE_NAME_METAL		= "Metal";
const string MATERIAL_TYPE_NAME_PAPER		= "Paper";
const string MATERIAL_TYPE_NAME_ROPE		= "Rope";
const string MATERIAL_TYPE_NAME_STONE		= "Stone";
const string MATERIAL_TYPE_NAME_WOOD		= "Wood";
const string MATERIAL_TYPE_NAME_BOTANICAL	= "Bontanical";
  
//:: Material Itemproperty Constants
//::////////////////////////////////////////////////////////////////////////////////
//:: Bioware Materials
const int	IP_MATERIAL_INVALID                     = -1;
const int	IP_MATERIAL_UNKNOWN                     = 0;
const int	IP_MATERIAL_ADAMANTINE                  = 1;
const int	IP_MATERIAL_BRASS                       = 2;
const int	IP_MATERIAL_BRONZE                      = 3;
const int	IP_MATERIAL_CARBON                      = 4;
const int	IP_MATERIAL_COLD_IRON                   = 5;
const int	IP_MATERIAL_COPPER                      = 6;
const int	IP_MATERIAL_DARKSTEEL                   = 7;
const int	IP_MATERIAL_GOLD                        = 8;
const int	IP_MATERIAL_IRON                        = 9;
const int	IP_MATERIAL_LEAD                        = 10;
const int	IP_MATERIAL_MITHRAL                     = 11;
const int	IP_MATERIAL_PLATINUM                    = 12;
const int	IP_MATERIAL_SILVER                      = 13;
const int	IP_MATERIAL_SILVER_ALCHEMICAL           = 14;
const int	IP_MATERIAL_STEEL                       = 15;
const int	IP_MATERIAL_BONE                        = 16;
const int	IP_MATERIAL_HIDE                        = 17;
const int	IP_MATERIAL_HIDE_SALAMANDER             = 18;
const int	IP_MATERIAL_HIDE_UMBER_HULK             = 19;
const int	IP_MATERIAL_HIDE_WYVERN                 = 20;
const int	IP_MATERIAL_HIDE_DRAGON_BLACK           = 21;
const int	IP_MATERIAL_HIDE_DRAGON_BLUE            = 22;
const int	IP_MATERIAL_HIDE_DRAGON_BRASS           = 23;
const int	IP_MATERIAL_HIDE_DRAGON_BRONZE          = 24;
const int	IP_MATERIAL_HIDE_DRAGON_COPPER          = 25;
const int	IP_MATERIAL_HIDE_DRAGON_GOLD            = 26;
const int	IP_MATERIAL_HIDE_DRAGON_GREEN           = 27;
const int	IP_MATERIAL_HIDE_DRAGON_RED             = 28;
const int	IP_MATERIAL_HIDE_DRAGON_SILVER          = 29;
const int	IP_MATERIAL_HIDE_DRAGON_WHITE           = 30;
const int	IP_MATERIAL_LEATHER                     = 31;
const int	IP_MATERIAL_SCALE                       = 32;
const int	IP_MATERIAL_CLOTH                       = 33;
const int	IP_MATERIAL_COTTON                      = 34;
const int	IP_MATERIAL_SILK                        = 35;
const int	IP_MATERIAL_WOOL                        = 36;
const int	IP_MATERIAL_WOOD                        = 37;
const int	IP_MATERIAL_WOOD_IRONWOOD               = 38;
const int	IP_MATERIAL_WOOD_DUSKWOOD               = 39;
const int	IP_MATERIAL_WOOD_DARKWOOD_ZALANTAR      = 40;
const int	IP_MATERIAL_WOOD_ASH                    = 41;
const int	IP_MATERIAL_WOOD_YEW                    = 42;
const int	IP_MATERIAL_WOOD_OAK                    = 43;
const int	IP_MATERIAL_WOOD_PINE                   = 44;
const int	IP_MATERIAL_WOOD_CEDAR                  = 45;
const int	IP_MATERIAL_ELEMENTAL                   = 46;
const int	IP_MATERIAL_ELEMENTAL_AIR               = 47;
const int	IP_MATERIAL_ELEMENTAL_EARTH             = 48;
const int	IP_MATERIAL_ELEMENTAL_FIRE              = 49;
const int	IP_MATERIAL_ELEMENTAL_WATER             = 50;
const int	IP_MATERIAL_GEM                         = 51;
const int	IP_MATERIAL_GEM_ALEXANDRITE             = 52;
const int	IP_MATERIAL_GEM_AMETHYST                = 53;
const int	IP_MATERIAL_GEM_AVENTURINE              = 54;
const int	IP_MATERIAL_GEM_BELJURIL                = 55;
const int	IP_MATERIAL_GEM_BLOODSTONE              = 56;
const int	IP_MATERIAL_GEM_BLUE_DIAMOND            = 57;
const int	IP_MATERIAL_GEM_CANARY_DIAMOND          = 58;
const int	IP_MATERIAL_GEM_DIAMOND                 = 59;
const int	IP_MATERIAL_GEM_EMERALD                 = 60;
const int	IP_MATERIAL_GEM_FIRE_AGATE              = 61;
const int	IP_MATERIAL_GEM_FIRE_OPAL               = 62;
const int	IP_MATERIAL_GEM_FLUORSPAR               = 63;
const int	IP_MATERIAL_GEM_GARNET                  = 64;
const int	IP_MATERIAL_GEM_GREENSTONE              = 65;
const int	IP_MATERIAL_GEM_JACINTH                 = 66;
const int	IP_MATERIAL_GEM_KINGS_TEAR              = 67;
const int	IP_MATERIAL_GEM_MALACHITE               = 68;
const int	IP_MATERIAL_GEM_OBSIDIAN                = 69;
const int	IP_MATERIAL_GEM_PHENALOPE               = 70;
const int	IP_MATERIAL_GEM_ROGUE_STONE             = 71;
const int	IP_MATERIAL_GEM_RUBY                    = 72;
const int	IP_MATERIAL_GEM_SAPPHIRE                = 73;
const int	IP_MATERIAL_GEM_STAR_SAPPHIRE           = 74;
const int	IP_MATERIAL_GEM_TOPAZ                   = 75;
const int	IP_MATERIAL_GEM_CRYSTAL_DEEP            = 76;
const int	IP_MATERIAL_GEM_CRYSTAL_MUNDANE         = 77;
const int	IP_MATERIAL_PAPER 						= 100;
const int	IP_MATERIAL_GLASS 						= 101;
const int	IP_MATERIAL_ICE 						= 102;
const int	IP_MATERIAL_ROPE_HEMP					= 103;
const int	IP_MATERIAL_STONE						= 104;
const int	IP_MATERIAL_DEEP_CORAL					= 105;
const int	IP_MATERIAL_WOOD_LIVING					= 106;
const int	IP_MATERIAL_OBDURIUM					= 107;
const int	IP_MATERIAL_WOOD_BRONZE 				= 108;
const int	IP_MATERIAL_BYESHK 						= 109;
const int	IP_MATERIAL_CALOMEL 					= 110;
const int	IP_MATERIAL_CRYSTEEL_RIEDRAN 			= 111;
const int	IP_MATERIAL_DENSEWOOD 					= 112;
const int	IP_MATERIAL_DRAGONSHARD 				= 113;
const int	IP_MATERIAL_IRON_FLAMETOUCHED 			= 114;
const int	IP_MATERIAL_LIVEWOOD 					= 115;
const int	IP_MATERIAL_MOURNLODE_PURPLE 			= 116;
const int	IP_MATERIAL_SOARWOOD 					= 117;
const int	IP_MATERIAL_TARGATH 					= 118;
const int	IP_MATERIAL_ASTRAL_DRIFTMETAL 			= 119;
const int	IP_MATERIAL_ATANDUR 					= 120;
const int	IP_MATERIAL_BLENDED_QUARTZ 				= 121;
const int	IP_MATERIAL_CHITIN 						= 122;
const int	IP_MATERIAL_DARKLEAF_ELVEN 				= 123;
const int	IP_MATERIAL_DLARUN 						= 124;
const int	IP_MATERIAL_DUSTWOOD 					= 125;
const int	IP_MATERIAL_ELUKIAN_CLAY 				= 126;
const int	IP_MATERIAL_ENTROPIUM 					= 127;
const int	IP_MATERIAL_GREENSTEEL_BAATORIAN 		= 128;
const int	IP_MATERIAL_HIZAGKUUR 					= 129;
const int	IP_MATERIAL_IRON_FEVER 					= 130;
const int	IP_MATERIAL_IRON_GEHENNAN_MORGHUTH 		= 131;
const int	IP_MATERIAL_LEAFWEAVE 					= 132;
const int	IP_MATERIAL_LIVING_METAL 				= 133;
const int	IP_MATERIAL_MINDSTEEL_URDRUKAR 			= 134;
const int	IP_MATERIAL_TRUESTEEL_SOLANIAN 			= 135;
const int	IP_MATERIAL_WOOD_AGAFARI 				= 136;
const int	IP_MATERIAL_CRYSTAL_DASL 				= 137;
const int	IP_MATERIAL_DRAKE_IVORY 				= 138;
const int	IP_MATERIAL_ROPE_GIANT_HAIR 			= 139;
const int	IP_MATERIAL_OBSIDIAN 					= 140;
const int	IP_MATERIAL_BAMBOO 						= 141;
const int	IP_MATERIAL_POTTERY						= 142;
const int	IP_MATERIAL_GLASSTEEL					= 143;
const int 	IP_MATERIAL_HERB 						= 144;
const int	IP_NUM_MATERIALS						= 144;
  
const string IP_MATERIAL_NAME_INVALID                	= "";
const string IP_MATERIAL_NAME_UNKNOWN                	= "Unknown";
const string IP_MATERIAL_NAME_ADAMANTINE             	= "Adamantine";
const string IP_MATERIAL_NAME_BRASS                  	= "Brass";
const string IP_MATERIAL_NAME_BRONZE                 	= "Bronze";
const string IP_MATERIAL_NAME_CARBON                 	= "Carbon";
const string IP_MATERIAL_NAME_COLD_IRON              	= "Cold Iron";
const string IP_MATERIAL_NAME_COPPER                 	= "Copper";
const string IP_MATERIAL_NAME_DARKSTEEL              	= "Darksteel";
const string IP_MATERIAL_NAME_GOLD                   	= "Gold";
const string IP_MATERIAL_NAME_IRON                   	= "Iron";
const string IP_MATERIAL_NAME_LEAD                   	= "Lead";
const string IP_MATERIAL_NAME_MITHRAL                	= "Mithral";
const string IP_MATERIAL_NAME_PLATINUM               	= "Platinum";
const string IP_MATERIAL_NAME_SILVER                 	= "Silver";
const string IP_MATERIAL_NAME_SILVER_ALCHEMICAL      	= "Alchemical Silver";
const string IP_MATERIAL_NAME_STEEL                  	= "Steel";
const string IP_MATERIAL_NAME_BONE                   	= "Bone";
const string IP_MATERIAL_NAME_HIDE                   	= "Hide";
const string IP_MATERIAL_NAME_HIDE_SALAMANDER        	= "Salamander Hide";
const string IP_MATERIAL_NAME_HIDE_UMBER_HULK        	= "Umber Hulk Hide";
const string IP_MATERIAL_NAME_HIDE_WYVERN            	= "Wyvern Hide";
const string IP_MATERIAL_NAME_HIDE_DRAGON_BLACK      	= "Black Dragon Hide";
const string IP_MATERIAL_NAME_HIDE_DRAGON_BLUE       	= "Blue Dragon Hide";
const string IP_MATERIAL_NAME_HIDE_DRAGON_BRASS      	= "Brass Dragon Hide";
const string IP_MATERIAL_NAME_HIDE_DRAGON_BRONZE     	= "Bronze Dragon Hide";
const string IP_MATERIAL_NAME_HIDE_DRAGON_COPPER     	= "Copper Dragon Hide";
const string IP_MATERIAL_NAME_HIDE_DRAGON_GOLD       	= "Gold Dragon Hide";
const string IP_MATERIAL_NAME_HIDE_DRAGON_GREEN      	= "Green Dragon Hide";
const string IP_MATERIAL_NAME_HIDE_DRAGON_RED        	= "Red Dragon Hide";
const string IP_MATERIAL_NAME_HIDE_DRAGON_SILVER     	= "Silver Dragon Hide";
const string IP_MATERIAL_NAME_HIDE_DRAGON_WHITE      	= "White Dragon Hide";
const string IP_MATERIAL_NAME_LEATHER                	= "Leather Hide";
const string IP_MATERIAL_NAME_SCALE                  	= "Scale";
const string IP_MATERIAL_NAME_CLOTH                  	= "Cloth";
const string IP_MATERIAL_NAME_COTTON                 	= "Cotton";
const string IP_MATERIAL_NAME_SILK                   	= "Silk";
const string IP_MATERIAL_NAME_WOOL                   	= "Wool";
const string IP_MATERIAL_NAME_WOOD                   	= "Wood";
const string IP_MATERIAL_NAME_WOOD_IRONWOOD          	= "Ironwood";
const string IP_MATERIAL_NAME_WOOD_DUSKWOOD          	= "Duskwood";
const string IP_MATERIAL_NAME_WOOD_DARKWOOD_ZALANTAR	= "Zalantar Darkwood";
const string IP_MATERIAL_NAME_WOOD_ASH               	= "Ash";
const string IP_MATERIAL_NAME_WOOD_YEW               	= "Yew";
const string IP_MATERIAL_NAME_WOOD_OAK               	= "Oak";
const string IP_MATERIAL_NAME_WOOD_PINE              	= "Pine";
const string IP_MATERIAL_NAME_WOOD_CEDAR             	= "Cedar";
const string IP_MATERIAL_NAME_ELEMENTAL              	= "Elemental";
const string IP_MATERIAL_NAME_ELEMENTAL_AIR          	= "Air Elemental";
const string IP_MATERIAL_NAME_ELEMENTAL_EARTH        	= "Earth Elemental";
const string IP_MATERIAL_NAME_ELEMENTAL_FIRE         	= "Fire Elemental";
const string IP_MATERIAL_NAME_ELEMENTAL_WATER        	= "Water Elemental";
const string IP_MATERIAL_NAME_GEM						= "Gem";
const string IP_MATERIAL_NAME_GEM_ALEXANDRITE        	= "Alexandrite";
const string IP_MATERIAL_NAME_GEM_AMETHYST           	= "Amethyst";
const string IP_MATERIAL_NAME_GEM_AVENTURINE         	= "Aventurine";
const string IP_MATERIAL_NAME_GEM_BELJURIL           	= "Beljuril";
const string IP_MATERIAL_NAME_GEM_BLOODSTONE         	= "Bloodstone";
const string IP_MATERIAL_NAME_GEM_BLUE_DIAMOND       	= "Blue Diamond";
const string IP_MATERIAL_NAME_GEM_CANARY_DIAMOND     	= "Carary Diamond";
const string IP_MATERIAL_NAME_GEM_DIAMOND            	= "Diamond";
const string IP_MATERIAL_NAME_GEM_EMERALD            	= "Emerald";
const string IP_MATERIAL_NAME_GEM_FIRE_AGATE         	= "Agate";
const string IP_MATERIAL_NAME_GEM_FIRE_OPAL          	= "Opal";
const string IP_MATERIAL_NAME_GEM_FLUORSPAR          	= "Fluorspar";
const string IP_MATERIAL_NAME_GEM_GARNET             	= "Garnet";
const string IP_MATERIAL_NAME_GEM_GREENSTONE         	= "Greenstone";
const string IP_MATERIAL_NAME_GEM_JACINTH            	= "Jacinth";
const string IP_MATERIAL_NAME_GEM_KINGS_TEAR         	= "King's Tear";
const string IP_MATERIAL_NAME_GEM_MALACHITE          	= "Malachite";
const string IP_MATERIAL_NAME_GEM_OBSIDIAN           	= "Obsidian";
const string IP_MATERIAL_NAME_GEM_PHENALOPE          	= "Phenalope";
const string IP_MATERIAL_NAME_GEM_ROGUE_STONE        	= "Rogue Stone";
const string IP_MATERIAL_NAME_GEM_RUBY               	= "Ruby";
const string IP_MATERIAL_NAME_GEM_SAPPHIRE           	= "Sapphire";
const string IP_MATERIAL_NAME_GEM_STAR_SAPPHIRE      	= "Star Sapphire";
const string IP_MATERIAL_NAME_GEM_TOPAZ              	= "Topaz";
const string IP_MATERIAL_NAME_GEM_CRYSTAL_DEEP       	= "Deep Crystal";
const string IP_MATERIAL_NAME_GEM_CRYSTAL_MUNDANE		= "Mundane Crystal";
const string IP_MATERIAL_NAME_PAPER 					= "Paper";
const string IP_MATERIAL_NAME_GLASS 					= "Glass";
const string IP_MATERIAL_NAME_ICE 						= "Ice";
const string IP_MATERIAL_NAME_ROPE_HEMP 				= "Hemp Rope";
const string IP_MATERIAL_NAME_STONE 					= "Stone";
const string IP_MATERIAL_NAME_DEEP_CORAL 				= "Deep Coral";
const string IP_MATERIAL_NAME_WOOD_LIVING 				= "Living Wood";
const string IP_MATERIAL_NAME_OBDURIUM 					= "Obdurium";
const string IP_MATERIAL_NAME_WOOD_BRONZE 				= "Bronze Wood";
const string IP_MATERIAL_NAME_BYESHK 					= "Byeshk";
const string IP_MATERIAL_NAME_CALOMEL 					= "Calomel";
const string IP_MATERIAL_NAME_CRYSTEEL_RIEDRAN 			= "Riedran Crysteel";
const string IP_MATERIAL_NAME_DENSEWOOD 				= "Densewood";
const string IP_MATERIAL_NAME_DRAGONSHARD 				= "Dragonshard";
const string IP_MATERIAL_NAME_IRON_FLAMETOUCHED 		= "Flametouched Iron";
const string IP_MATERIAL_NAME_LIVEWOOD 					= "Livewood";
const string IP_MATERIAL_NAME_MOURNLODE_PURPLE 			= "Purple Mournlode";
const string IP_MATERIAL_NAME_SOARWOOD 					= "Soarwood";
const string IP_MATERIAL_NAME_TARGATH 					= "Targath";
const string IP_MATERIAL_NAME_ASTRAL_DRIFTMETAL 		= "Astral Driftmetal";
const string IP_MATERIAL_NAME_ATANDUR 					= "Atandur";
const string IP_MATERIAL_NAME_BLENDED_QUARTZ 			= "Blended Quartz";
const string IP_MATERIAL_NAME_CHITIN 					= "Chitin";
const string IP_MATERIAL_NAME_DARKLEAF_ELVEN 			= "Elven Darkleaf";
const string IP_MATERIAL_NAME_DLARUN 					= "Dlarun";
const string IP_MATERIAL_NAME_DUSTWOOD 					= "Dustwood";
const string IP_MATERIAL_NAME_ELUKIAN_CLAY 				= "Elukian Clay";
const string IP_MATERIAL_NAME_ENTROPIUM 				= "Entropium";
const string IP_MATERIAL_NAME_GREENSTEEL_BAATORIAN 		= "Baatorian Greensteel";
const string IP_MATERIAL_NAME_HIZAGKUUR 				= "Hizagkuur";
const string IP_MATERIAL_NAME_IRON_FEVER 				= "Fever Iron";
const string IP_MATERIAL_NAME_IRON_GEHENNAN_MORGHUTH 	= "Gehennan Morghuth Iron";
const string IP_MATERIAL_NAME_LEAFWEAVE 				= "Leafweave";
const string IP_MATERIAL_NAME_LIVING_METAL 				= "Living Metal";
const string IP_MATERIAL_NAME_MINDSTEEL_URDRUKAR 		= "Urdrukar Mindsteel";
const string IP_MATERIAL_NAME_TRUESTEEL_SOLANIAN 		= "Solanian Truesteel";
const string IP_MATERIAL_NAME_WOOD_AGAFARI 				= "Agafari";
const string IP_MATERIAL_NAME_CRYSTAL_DASL 				= "Dasl";
const string IP_MATERIAL_NAME_DRAKE_IVORY 				= "Drake Ivory";
const string IP_MATERIAL_NAME_ROPE_GIANT_HAIR 			= "Giant Hair Rope";
const string IP_MATERIAL_NAME_OBSIDIAN 					= "Obsidian";
const string IP_MATERIAL_NAME_BAMBOO 					= "Bamboo";
const string IP_MATERIAL_NAME_POTTERY 					= "Pottery";
const string IP_MATERIAL_NAME_GLASSTEEL					= "Glassteel";
const string IP_MATERIAL_NAME_HERB						= "Herbs";
  
//::///////////////////////////////////////////////////////////////
//  GetMaterialName( int iMaterialType, int bLowerCase = FALSE)
//      Given a material type this function returns its name as a string.
//::///////////////////////////////////////////////////////////////
// Parameters:  int iMaterialType - the material type number IP_MATERIAL_*
//              int bLowerCase    - if TRUE the returned string is all lower case
//                                  if FALSE the returned string is first letter cap.
//
// Returns: the name of the material type as a string IP_MATERIAL_NAME_*.
//          Returns IP_MATERIAL_NAME_INVALID if the material type is invalid.
//::///////////////////////////////////////////////////////////////
string GetMaterialName( int iMaterialType, int bLowerCase = FALSE);
string GetMaterialName( int iMaterialType, int bLowerCase = FALSE)
{ if( iMaterialType == IP_MATERIAL_INVALID) return IP_MATERIAL_NAME_INVALID;
  
  string sName = "";
  switch( iMaterialType)
  { case IP_MATERIAL_UNKNOWN:                	sName = IP_MATERIAL_NAME_UNKNOWN;                  	break;
    case IP_MATERIAL_ADAMANTINE:             	sName = IP_MATERIAL_NAME_ADAMANTINE;               	break;
    case IP_MATERIAL_BRASS:                  	sName = IP_MATERIAL_NAME_BRASS;						break;
    case IP_MATERIAL_BRONZE:                 	sName = IP_MATERIAL_NAME_BRONZE;                   	break;
    case IP_MATERIAL_CARBON:                 	sName = IP_MATERIAL_NAME_CARBON;                   	break;
    case IP_MATERIAL_COLD_IRON:              	sName = IP_MATERIAL_NAME_COLD_IRON;                	break;
    case IP_MATERIAL_COPPER:                 	sName = IP_MATERIAL_NAME_COPPER;                   	break;
    case IP_MATERIAL_DARKSTEEL:              	sName = IP_MATERIAL_NAME_DARKSTEEL;                	break;
    case IP_MATERIAL_GOLD:                   	sName = IP_MATERIAL_NAME_GOLD;                     	break;
    case IP_MATERIAL_IRON:                   	sName = IP_MATERIAL_NAME_IRON;                     	break;
    case IP_MATERIAL_LEAD:                   	sName = IP_MATERIAL_NAME_LEAD;                     	break;
    case IP_MATERIAL_MITHRAL:                	sName = IP_MATERIAL_NAME_MITHRAL;                  	break;
    case IP_MATERIAL_PLATINUM:               	sName = IP_MATERIAL_NAME_PLATINUM;                 	break;
    case IP_MATERIAL_SILVER:                 	sName = IP_MATERIAL_NAME_SILVER;                   	break;
    case IP_MATERIAL_SILVER_ALCHEMICAL:      	sName = IP_MATERIAL_NAME_SILVER_ALCHEMICAL;        	break;
    case IP_MATERIAL_STEEL:                  	sName = IP_MATERIAL_NAME_STEEL;                    	break;
    case IP_MATERIAL_BONE:                   	sName = IP_MATERIAL_NAME_BONE;                     	break;
    case IP_MATERIAL_HIDE:                   	sName = IP_MATERIAL_NAME_HIDE;						break;
    case IP_MATERIAL_HIDE_SALAMANDER:        	sName = IP_MATERIAL_NAME_HIDE_SALAMANDER;          	break;
    case IP_MATERIAL_HIDE_UMBER_HULK:        	sName = IP_MATERIAL_NAME_HIDE_UMBER_HULK;          	break;
    case IP_MATERIAL_HIDE_WYVERN:            	sName = IP_MATERIAL_NAME_HIDE_WYVERN;              	break;
    case IP_MATERIAL_HIDE_DRAGON_BLACK:      	sName = IP_MATERIAL_NAME_HIDE_DRAGON_BLACK;        	break;
    case IP_MATERIAL_HIDE_DRAGON_BLUE:       	sName = IP_MATERIAL_NAME_HIDE_DRAGON_BLUE;         	break;
    case IP_MATERIAL_HIDE_DRAGON_BRASS:      	sName = IP_MATERIAL_NAME_HIDE_DRAGON_BRASS;        	break;
    case IP_MATERIAL_HIDE_DRAGON_BRONZE:     	sName = IP_MATERIAL_NAME_HIDE_DRAGON_BRONZE;       	break;
    case IP_MATERIAL_HIDE_DRAGON_COPPER:     	sName = IP_MATERIAL_NAME_HIDE_DRAGON_COPPER;       	break;
    case IP_MATERIAL_HIDE_DRAGON_GOLD:       	sName = IP_MATERIAL_NAME_HIDE_DRAGON_GOLD;         	break;
    case IP_MATERIAL_HIDE_DRAGON_GREEN:      	sName = IP_MATERIAL_NAME_HIDE_DRAGON_GREEN;        	break;
    case IP_MATERIAL_HIDE_DRAGON_RED:        	sName = IP_MATERIAL_NAME_HIDE_DRAGON_RED;          	break;
    case IP_MATERIAL_HIDE_DRAGON_SILVER:     	sName = IP_MATERIAL_NAME_HIDE_DRAGON_SILVER;       	break;
    case IP_MATERIAL_HIDE_DRAGON_WHITE:      	sName = IP_MATERIAL_NAME_HIDE_DRAGON_WHITE;			break;
    case IP_MATERIAL_LEATHER:                	sName = IP_MATERIAL_NAME_LEATHER;					break;
    case IP_MATERIAL_SCALE:                  	sName = IP_MATERIAL_NAME_SCALE;                    	break;
    case IP_MATERIAL_COTTON:                 	sName = IP_MATERIAL_NAME_COTTON;                   	break;
    case IP_MATERIAL_CLOTH:                  	sName = IP_MATERIAL_NAME_CLOTH;                    	break;
    case IP_MATERIAL_SILK:                   	sName = IP_MATERIAL_NAME_SILK;                     	break;
    case IP_MATERIAL_WOOL:                   	sName = IP_MATERIAL_NAME_WOOL;                     	break;
    case IP_MATERIAL_WOOD:                   	sName = IP_MATERIAL_NAME_WOOD;                     	break;
    case IP_MATERIAL_WOOD_IRONWOOD:          	sName = IP_MATERIAL_NAME_WOOD_IRONWOOD;				break;
    case IP_MATERIAL_WOOD_DUSKWOOD:          	sName = IP_MATERIAL_NAME_WOOD_DUSKWOOD;            	break;
    case IP_MATERIAL_WOOD_DARKWOOD_ZALANTAR: 	sName = IP_MATERIAL_NAME_WOOD_DARKWOOD_ZALANTAR;   	break;
    case IP_MATERIAL_WOOD_ASH:               	sName = IP_MATERIAL_NAME_WOOD_ASH;                 	break;
    case IP_MATERIAL_WOOD_YEW:               	sName = IP_MATERIAL_NAME_WOOD_YEW;                 	break;
    case IP_MATERIAL_WOOD_OAK:               	sName = IP_MATERIAL_NAME_WOOD_OAK;					break;
    case IP_MATERIAL_WOOD_PINE:              	sName = IP_MATERIAL_NAME_WOOD_PINE;                	break;
    case IP_MATERIAL_WOOD_CEDAR:             	sName = IP_MATERIAL_NAME_WOOD_CEDAR;               	break;
    case IP_MATERIAL_ELEMENTAL:              	sName = IP_MATERIAL_NAME_ELEMENTAL;                	break;
    case IP_MATERIAL_ELEMENTAL_AIR:          	sName = IP_MATERIAL_NAME_ELEMENTAL_AIR;            	break;
    case IP_MATERIAL_ELEMENTAL_EARTH:        	sName = IP_MATERIAL_NAME_ELEMENTAL_EARTH;          	break;
    case IP_MATERIAL_ELEMENTAL_FIRE:         	sName = IP_MATERIAL_NAME_ELEMENTAL_FIRE;           	break;
    case IP_MATERIAL_ELEMENTAL_WATER:        	sName = IP_MATERIAL_NAME_ELEMENTAL_WATER;          	break;
    case IP_MATERIAL_GEM:                    	sName = IP_MATERIAL_NAME_GEM;                      	break;
    case IP_MATERIAL_GEM_ALEXANDRITE:			sName = IP_MATERIAL_NAME_GEM_ALEXANDRITE;			break;
    case IP_MATERIAL_GEM_AMETHYST:           	sName = IP_MATERIAL_NAME_GEM_AMETHYST;             	break;
    case IP_MATERIAL_GEM_AVENTURINE:         	sName = IP_MATERIAL_NAME_GEM_AVENTURINE;           	break;
    case IP_MATERIAL_GEM_BELJURIL:           	sName = IP_MATERIAL_NAME_GEM_BELJURIL;             	break;
    case IP_MATERIAL_GEM_BLOODSTONE:         	sName = IP_MATERIAL_NAME_GEM_BLOODSTONE;           	break;
    case IP_MATERIAL_GEM_BLUE_DIAMOND:       	sName = IP_MATERIAL_NAME_GEM_BLUE_DIAMOND;         	break;
    case IP_MATERIAL_GEM_CANARY_DIAMOND:     	sName = IP_MATERIAL_NAME_GEM_CANARY_DIAMOND;       	break;
    case IP_MATERIAL_GEM_DIAMOND:            	sName = IP_MATERIAL_NAME_GEM_DIAMOND;              	break;
    case IP_MATERIAL_GEM_EMERALD:            	sName = IP_MATERIAL_NAME_GEM_EMERALD;              	break;
    case IP_MATERIAL_GEM_FIRE_AGATE:         	sName = IP_MATERIAL_NAME_GEM_FIRE_AGATE;           	break;
    case IP_MATERIAL_GEM_FIRE_OPAL:          	sName = IP_MATERIAL_NAME_GEM_FIRE_OPAL;            	break;
    case IP_MATERIAL_GEM_FLUORSPAR:          	sName = IP_MATERIAL_NAME_GEM_FLUORSPAR;            	break;
    case IP_MATERIAL_GEM_GARNET:             	sName = IP_MATERIAL_NAME_GEM_GARNET;               	break;
    case IP_MATERIAL_GEM_GREENSTONE:         	sName = IP_MATERIAL_NAME_GEM_GREENSTONE;           	break;
    case IP_MATERIAL_GEM_JACINTH:            	sName = IP_MATERIAL_NAME_GEM_JACINTH;              	break;
    case IP_MATERIAL_GEM_KINGS_TEAR:         	sName = IP_MATERIAL_NAME_GEM_KINGS_TEAR;           	break;
    case IP_MATERIAL_GEM_MALACHITE:          	sName = IP_MATERIAL_NAME_GEM_MALACHITE;            	break;
    case IP_MATERIAL_GEM_OBSIDIAN:           	sName = IP_MATERIAL_NAME_GEM_OBSIDIAN;             	break;
    case IP_MATERIAL_GEM_PHENALOPE:          	sName = IP_MATERIAL_NAME_GEM_PHENALOPE;            	break;
    case IP_MATERIAL_GEM_ROGUE_STONE:        	sName = IP_MATERIAL_NAME_GEM_ROGUE_STONE;          	break;
    case IP_MATERIAL_GEM_RUBY:               	sName = IP_MATERIAL_NAME_GEM_RUBY;                 	break;
    case IP_MATERIAL_GEM_SAPPHIRE:           	sName = IP_MATERIAL_NAME_GEM_SAPPHIRE;				break;
    case IP_MATERIAL_GEM_STAR_SAPPHIRE:      	sName = IP_MATERIAL_NAME_GEM_STAR_SAPPHIRE;        	break;
    case IP_MATERIAL_GEM_TOPAZ:              	sName = IP_MATERIAL_NAME_GEM_TOPAZ;                	break;
    case IP_MATERIAL_GEM_CRYSTAL_DEEP:       	sName = IP_MATERIAL_NAME_GEM_CRYSTAL_DEEP;         	break;
    case IP_MATERIAL_GEM_CRYSTAL_MUNDANE:    	sName = IP_MATERIAL_NAME_GEM_CRYSTAL_MUNDANE;      	break;
	case IP_MATERIAL_PAPER: 					sName = IP_MATERIAL_NAME_PAPER; 					break; 
	case IP_MATERIAL_GLASS: 					sName = IP_MATERIAL_NAME_GLASS; 					break; 
	case IP_MATERIAL_ICE: 						sName = IP_MATERIAL_NAME_ICE; 						break; 
	case IP_MATERIAL_ROPE_HEMP: 				sName = IP_MATERIAL_NAME_ROPE_HEMP; 				break; 
	case IP_MATERIAL_STONE: 					sName = IP_MATERIAL_NAME_STONE; 					break; 
	case IP_MATERIAL_DEEP_CORAL: 				sName = IP_MATERIAL_NAME_DEEP_CORAL; 				break; 
	case IP_MATERIAL_WOOD_LIVING: 				sName = IP_MATERIAL_NAME_WOOD_LIVING; 				break; 
	case IP_MATERIAL_OBDURIUM: 					sName = IP_MATERIAL_NAME_OBDURIUM; 					break; 
	case IP_MATERIAL_WOOD_BRONZE: 				sName = IP_MATERIAL_NAME_WOOD_BRONZE; 				break; 
	case IP_MATERIAL_BYESHK: 					sName = IP_MATERIAL_NAME_BYESHK; 					break; 
	case IP_MATERIAL_CALOMEL: 					sName = IP_MATERIAL_NAME_CALOMEL; 					break; 
	case IP_MATERIAL_CRYSTEEL_RIEDRAN: 			sName = IP_MATERIAL_NAME_CRYSTEEL_RIEDRAN; 			break; 
	case IP_MATERIAL_DENSEWOOD: 				sName = IP_MATERIAL_NAME_DENSEWOOD; 				break; 
	case IP_MATERIAL_DRAGONSHARD: 				sName = IP_MATERIAL_NAME_DRAGONSHARD; 				break; 
	case IP_MATERIAL_IRON_FLAMETOUCHED: 		sName = IP_MATERIAL_NAME_IRON_FLAMETOUCHED; 		break; 
	case IP_MATERIAL_LIVEWOOD: 					sName = IP_MATERIAL_NAME_LIVEWOOD; 					break; 
	case IP_MATERIAL_MOURNLODE_PURPLE: 			sName = IP_MATERIAL_NAME_MOURNLODE_PURPLE; 			break; 
	case IP_MATERIAL_SOARWOOD: 					sName = IP_MATERIAL_NAME_SOARWOOD; 					break; 
	case IP_MATERIAL_TARGATH: 					sName = IP_MATERIAL_NAME_TARGATH; 					break; 
	case IP_MATERIAL_ASTRAL_DRIFTMETAL: 		sName = IP_MATERIAL_NAME_ASTRAL_DRIFTMETAL; 		break; 
	case IP_MATERIAL_ATANDUR: 					sName = IP_MATERIAL_NAME_ATANDUR; 					break; 
	case IP_MATERIAL_BLENDED_QUARTZ: 			sName = IP_MATERIAL_NAME_BLENDED_QUARTZ; 			break; 
	case IP_MATERIAL_CHITIN: 					sName = IP_MATERIAL_NAME_CHITIN; 					break; 
	case IP_MATERIAL_DARKLEAF_ELVEN: 			sName = IP_MATERIAL_NAME_DARKLEAF_ELVEN; 			break; 
	case IP_MATERIAL_DLARUN: 					sName = IP_MATERIAL_NAME_DLARUN; 					break; 
	case IP_MATERIAL_DUSTWOOD: 					sName = IP_MATERIAL_NAME_DUSTWOOD; 					break; 
	case IP_MATERIAL_ELUKIAN_CLAY: 				sName = IP_MATERIAL_NAME_ELUKIAN_CLAY; 				break; 
	case IP_MATERIAL_ENTROPIUM: 				sName = IP_MATERIAL_NAME_ENTROPIUM;					break; 
	case IP_MATERIAL_GREENSTEEL_BAATORIAN: 		sName = IP_MATERIAL_NAME_GREENSTEEL_BAATORIAN; 		break; 
	case IP_MATERIAL_HIZAGKUUR: 				sName = IP_MATERIAL_NAME_HIZAGKUUR; 				break; 
	case IP_MATERIAL_IRON_FEVER: 				sName = IP_MATERIAL_NAME_IRON_FEVER; 				break; 
	case IP_MATERIAL_IRON_GEHENNAN_MORGHUTH: 	sName = IP_MATERIAL_NAME_IRON_GEHENNAN_MORGHUTH; 	break; 
	case IP_MATERIAL_LEAFWEAVE: 				sName = IP_MATERIAL_NAME_LEAFWEAVE; 				break; 
	case IP_MATERIAL_LIVING_METAL: 				sName = IP_MATERIAL_NAME_LIVING_METAL; 				break; 
	case IP_MATERIAL_MINDSTEEL_URDRUKAR: 		sName = IP_MATERIAL_NAME_MINDSTEEL_URDRUKAR; 		break; 
	case IP_MATERIAL_TRUESTEEL_SOLANIAN: 		sName = IP_MATERIAL_NAME_TRUESTEEL_SOLANIAN; 		break; 
	case IP_MATERIAL_WOOD_AGAFARI: 				sName = IP_MATERIAL_NAME_WOOD_AGAFARI; 				break; 
	case IP_MATERIAL_CRYSTAL_DASL: 				sName = IP_MATERIAL_NAME_CRYSTAL_DASL; 				break; 
	case IP_MATERIAL_DRAKE_IVORY: 				sName = IP_MATERIAL_NAME_DRAKE_IVORY; 				break; 
	case IP_MATERIAL_ROPE_GIANT_HAIR: 			sName = IP_MATERIAL_NAME_ROPE_GIANT_HAIR; 			break; 
	case IP_MATERIAL_OBSIDIAN: 					sName = IP_MATERIAL_NAME_OBSIDIAN; 					break; 
	case IP_MATERIAL_BAMBOO: 					sName = IP_MATERIAL_NAME_BAMBOO; 					break; 
	case IP_MATERIAL_POTTERY: 					sName = IP_MATERIAL_NAME_POTTERY; 					break;
	case IP_MATERIAL_GLASSTEEL:					sName = IP_MATERIAL_NAME_GLASSTEEL;					break;
	case IP_MATERIAL_HERB:						sName = IP_MATERIAL_NAME_HERB;						break; 	
	
    default: return "";
  }
  
  return (bLowerCase ? GetStringLowerCase( sName) : sName);
}
  
  
//::///////////////////////////////////////////////////////////////
//  int GetIPMaterial( string sMaterialName)
//      Given a material name this function returns its type number (2da row)
//::///////////////////////////////////////////////////////////////
// Parameters:  string sMaterialName - the material name IP_MATERIAL_NAME_*
//
// Returns: the material type number IP_MATERIAL_* of the specified material
//          name or IP_MATERIAL_INVALID if the type could not be determined
//          from the specified name.
//::///////////////////////////////////////////////////////////////
int GetIPMaterial( string sMaterialName);
int GetIPMaterial( string sMaterialName)
{ if( sMaterialName == IP_MATERIAL_NAME_INVALID) return IP_MATERIAL_INVALID;
  
  sMaterialName = GetStringUpperCase( sMaterialName);
	if(      sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_UNKNOWN))                return IP_MATERIAL_UNKNOWN;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_ADAMANTINE))             return IP_MATERIAL_ADAMANTINE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_BRASS))                  return IP_MATERIAL_BRASS;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_BRONZE))                 return IP_MATERIAL_BRONZE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_CARBON))                 return IP_MATERIAL_CARBON;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_COLD_IRON))              return IP_MATERIAL_COLD_IRON;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_COPPER))                 return IP_MATERIAL_COPPER;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_DARKSTEEL))              return IP_MATERIAL_DARKSTEEL;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GOLD))                   return IP_MATERIAL_GOLD;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_IRON))                   return IP_MATERIAL_IRON;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_LEAD))                   return IP_MATERIAL_LEAD;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_MITHRAL))                return IP_MATERIAL_MITHRAL;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_PLATINUM))               return IP_MATERIAL_PLATINUM;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_SILVER))                 return IP_MATERIAL_SILVER;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_SILVER_ALCHEMICAL))      return IP_MATERIAL_SILVER_ALCHEMICAL;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_STEEL))                  return IP_MATERIAL_STEEL;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_BONE))                   return IP_MATERIAL_BONE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_HIDE))                   return IP_MATERIAL_HIDE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_HIDE_SALAMANDER))        return IP_MATERIAL_HIDE_SALAMANDER;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_HIDE_UMBER_HULK))        return IP_MATERIAL_HIDE_UMBER_HULK;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_HIDE_WYVERN))            return IP_MATERIAL_HIDE_WYVERN;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_HIDE_DRAGON_BLACK))      return IP_MATERIAL_HIDE_DRAGON_BLACK;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_HIDE_DRAGON_BLUE))       return IP_MATERIAL_HIDE_DRAGON_BLUE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_HIDE_DRAGON_BRASS))      return IP_MATERIAL_HIDE_DRAGON_BRASS;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_HIDE_DRAGON_BRONZE))     return IP_MATERIAL_HIDE_DRAGON_BRONZE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_HIDE_DRAGON_COPPER))     return IP_MATERIAL_HIDE_DRAGON_COPPER;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_HIDE_DRAGON_GOLD))       return IP_MATERIAL_HIDE_DRAGON_GOLD;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_HIDE_DRAGON_GREEN))      return IP_MATERIAL_HIDE_DRAGON_GREEN;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_HIDE_DRAGON_RED))        return IP_MATERIAL_HIDE_DRAGON_RED;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_HIDE_DRAGON_SILVER))     return IP_MATERIAL_HIDE_DRAGON_SILVER;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_HIDE_DRAGON_WHITE))      return IP_MATERIAL_HIDE_DRAGON_WHITE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_LEATHER))                return IP_MATERIAL_LEATHER;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_SCALE))                  return IP_MATERIAL_SCALE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_COTTON))                 return IP_MATERIAL_COTTON;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_CLOTH))                  return IP_MATERIAL_CLOTH;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_SILK))                   return IP_MATERIAL_SILK;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_WOOL))                   return IP_MATERIAL_WOOL;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_WOOD))                   return IP_MATERIAL_WOOD;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_WOOD_IRONWOOD))          return IP_MATERIAL_WOOD_IRONWOOD;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_WOOD_DUSKWOOD))          return IP_MATERIAL_WOOD_DUSKWOOD;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_WOOD_DARKWOOD_ZALANTAR)) return IP_MATERIAL_WOOD_DARKWOOD_ZALANTAR;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_WOOD_ASH))               return IP_MATERIAL_WOOD_ASH;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_WOOD_YEW))               return IP_MATERIAL_WOOD_YEW;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_WOOD_OAK))               return IP_MATERIAL_WOOD_OAK;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_WOOD_PINE))              return IP_MATERIAL_WOOD_PINE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_WOOD_CEDAR))             return IP_MATERIAL_WOOD_CEDAR;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_ELEMENTAL))              return IP_MATERIAL_ELEMENTAL;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_ELEMENTAL_AIR))          return IP_MATERIAL_ELEMENTAL_AIR;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_ELEMENTAL_EARTH))        return IP_MATERIAL_ELEMENTAL_EARTH;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_ELEMENTAL_FIRE))         return IP_MATERIAL_ELEMENTAL_FIRE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_ELEMENTAL_WATER))        return IP_MATERIAL_ELEMENTAL_WATER;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM))                    return IP_MATERIAL_GEM;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_ALEXANDRITE))        return IP_MATERIAL_GEM_ALEXANDRITE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_AMETHYST))           return IP_MATERIAL_GEM_AMETHYST;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_AVENTURINE))         return IP_MATERIAL_GEM_AVENTURINE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_BELJURIL))           return IP_MATERIAL_GEM_BELJURIL;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_BLOODSTONE))         return IP_MATERIAL_GEM_BLOODSTONE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_BLUE_DIAMOND))       return IP_MATERIAL_GEM_BLUE_DIAMOND;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_CANARY_DIAMOND))     return IP_MATERIAL_GEM_CANARY_DIAMOND;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_DIAMOND))            return IP_MATERIAL_GEM_DIAMOND;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_EMERALD))            return IP_MATERIAL_GEM_EMERALD;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_FIRE_AGATE))         return IP_MATERIAL_GEM_FIRE_AGATE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_FIRE_OPAL))          return IP_MATERIAL_GEM_FIRE_OPAL;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_FLUORSPAR))          return IP_MATERIAL_GEM_FLUORSPAR;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_GARNET))             return IP_MATERIAL_GEM_GARNET;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_GREENSTONE))         return IP_MATERIAL_GEM_GREENSTONE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_JACINTH))            return IP_MATERIAL_GEM_JACINTH;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_KINGS_TEAR))         return IP_MATERIAL_GEM_KINGS_TEAR;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_MALACHITE))          return IP_MATERIAL_GEM_MALACHITE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_OBSIDIAN))           return IP_MATERIAL_GEM_OBSIDIAN;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_PHENALOPE))          return IP_MATERIAL_GEM_PHENALOPE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_ROGUE_STONE))        return IP_MATERIAL_GEM_ROGUE_STONE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_RUBY))               return IP_MATERIAL_GEM_RUBY;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_SAPPHIRE))           return IP_MATERIAL_GEM_SAPPHIRE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_STAR_SAPPHIRE))      return IP_MATERIAL_GEM_STAR_SAPPHIRE;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_TOPAZ))              return IP_MATERIAL_GEM_TOPAZ;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_CRYSTAL_DEEP))       return IP_MATERIAL_GEM_CRYSTAL_DEEP;
	else if( sMaterialName == GetStringUpperCase( IP_MATERIAL_NAME_GEM_CRYSTAL_MUNDANE))    return IP_MATERIAL_GEM_CRYSTAL_MUNDANE;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_PAPER)) 					return IP_MATERIAL_PAPER;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_GLASS))					return IP_MATERIAL_GLASS;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_ICE))						return IP_MATERIAL_ICE;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_ROPE_HEMP))				return IP_MATERIAL_ROPE_HEMP;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_STONE))					return IP_MATERIAL_STONE;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_DEEP_CORAL))				return IP_MATERIAL_DEEP_CORAL;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_WOOD_LIVING))				return IP_MATERIAL_WOOD_LIVING;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_OBDURIUM))				return IP_MATERIAL_OBDURIUM;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_WOOD_BRONZE))				return IP_MATERIAL_WOOD_BRONZE;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_BYESHK))					return IP_MATERIAL_BYESHK;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_CALOMEL))					return IP_MATERIAL_CALOMEL;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_CRYSTEEL_RIEDRAN))		return IP_MATERIAL_CRYSTEEL_RIEDRAN;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_DENSEWOOD))				return IP_MATERIAL_DENSEWOOD;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_DRAGONSHARD))				return IP_MATERIAL_DRAGONSHARD;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_IRON_FLAMETOUCHED))		return IP_MATERIAL_IRON_FLAMETOUCHED;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_LIVEWOOD))				return IP_MATERIAL_LIVEWOOD;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_MOURNLODE_PURPLE))		return IP_MATERIAL_MOURNLODE_PURPLE;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_SOARWOOD))				return IP_MATERIAL_SOARWOOD;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_TARGATH))					return IP_MATERIAL_TARGATH;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_ASTRAL_DRIFTMETAL))		return IP_MATERIAL_ASTRAL_DRIFTMETAL;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_ATANDUR))					return IP_MATERIAL_ATANDUR;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_BLENDED_QUARTZ))			return IP_MATERIAL_BLENDED_QUARTZ;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_CHITIN))					return IP_MATERIAL_CHITIN;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_DARKLEAF_ELVEN))			return IP_MATERIAL_DARKLEAF_ELVEN;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_DLARUN))					return IP_MATERIAL_DLARUN;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_DUSTWOOD))				return IP_MATERIAL_DUSTWOOD;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_ELUKIAN_CLAY))			return IP_MATERIAL_ELUKIAN_CLAY;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_ENTROPIUM)) 				return IP_MATERIAL_ENTROPIUM;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_GREENSTEEL_BAATORIAN)) 	return IP_MATERIAL_GREENSTEEL_BAATORIAN;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_HIZAGKUUR)) 				return IP_MATERIAL_HIZAGKUUR;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_IRON_FEVER)) 				return IP_MATERIAL_IRON_FEVER;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_IRON_GEHENNAN_MORGHUTH)) 	return IP_MATERIAL_IRON_GEHENNAN_MORGHUTH;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_LEAFWEAVE)) 				return IP_MATERIAL_LEAFWEAVE;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_LIVING_METAL)) 			return IP_MATERIAL_LIVING_METAL;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_MINDSTEEL_URDRUKAR)) 		return IP_MATERIAL_MINDSTEEL_URDRUKAR;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_TRUESTEEL_SOLANIAN)) 		return IP_MATERIAL_TRUESTEEL_SOLANIAN;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_WOOD_AGAFARI)) 			return IP_MATERIAL_WOOD_AGAFARI;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_CRYSTAL_DASL)) 			return IP_MATERIAL_CRYSTAL_DASL;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_DRAKE_IVORY)) 			return IP_MATERIAL_DRAKE_IVORY;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_ROPE_GIANT_HAIR)) 		return IP_MATERIAL_ROPE_GIANT_HAIR;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_OBSIDIAN)) 				return IP_MATERIAL_OBSIDIAN;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_BAMBOO)) 					return IP_MATERIAL_BAMBOO;
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_POTTERY))					return IP_MATERIAL_POTTERY;	
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_GLASSTEEL))				return IP_MATERIAL_GLASSTEEL;		
	else if( sMaterialName == GetStringUpperCase(IP_MATERIAL_NAME_HERB))					return IP_MATERIAL_HERB;		
	
	return IP_MATERIAL_INVALID;
}
  
  
//::///////////////////////////////////////////////////////////////
//  string IPGetMaterialName( itemproperty ipMaterial, int bLowerCase = FALSE)
//      Given an itempropety this function returns the material name of the property
//      as a string if it is a material property. If the specified itemproperty is
//      not a material property it returns IP_MATERIAL_NAME_INVALID.
//::///////////////////////////////////////////////////////////////
// Parameters:  itemproperty ipMaterial - the itemproperty to check
//              int          bLowerCase - if TRUE the returned name is all lower case
//                                        if FALSE the returned name is first letter cap
//
// Returns: the material name IP_MATERIAL_NAME_* of the material itemproperty
//          or IP_MATERIAL_NAME_INVALID if the itemproperty is not a material
//          itemproperty or is an invalid itemproperty.
//::///////////////////////////////////////////////////////////////
string IPGetMaterialName( itemproperty ipMaterial, int bLowerCase = FALSE);
string IPGetMaterialName( itemproperty ipMaterial, int bLowerCase = FALSE)
{
	int iType     = GetItemPropertyType( ipMaterial);
	int iMaterial = GetItemPropertyCostTableValue( ipMaterial);
	if( !GetIsItemPropertyValid( ipMaterial) || (iType != ITEM_PROPERTY_MATERIAL) || (iMaterial < IP_MATERIAL_UNKNOWN) || (iMaterial > IP_NUM_MATERIALS)) return IP_MATERIAL_NAME_INVALID;
  
	return GetMaterialName( iMaterial, bLowerCase);
}
  
  
//::///////////////////////////////////////////////////////////////
//  int IPGetMaterialType( itemproperty ipMaterial)
//      Given an itempropety this function returns the material type of the property
//      if it is a material itemproperty. If the specified itemproperty is invalid or
//      not a material property it returns IP_MATERIAL_INVALID.
//::///////////////////////////////////////////////////////////////
// Parameters:  itemproperty ipMaterial - the itemproperty to check
//
// Returns: the material type IP_MATERIAL_* of the material itemproperty or
//          IP_MATERIAL_INVALID if the itemproperty is not a material itemproperty
//          or is an invalid itemproperty.
//::///////////////////////////////////////////////////////////////
int IPGetMaterialType( itemproperty ipMaterial);
int IPGetMaterialType( itemproperty ipMaterial)
{ 
	int iType     = GetItemPropertyType( ipMaterial);
	int iMaterial = GetItemPropertyCostTableValue( ipMaterial);
	if( !GetIsItemPropertyValid( ipMaterial) || (iType != ITEM_PROPERTY_MATERIAL) || (iMaterial < IP_MATERIAL_UNKNOWN) || (iMaterial > IP_NUM_MATERIALS)) return IP_MATERIAL_INVALID;
	return (((iMaterial > IP_MATERIAL_INVALID) && (iMaterial <= IP_NUM_MATERIALS)) ? iMaterial : IP_MATERIAL_INVALID);
}
  
  
//::///////////////////////////////////////////////////////////////
//  itemproperty ItemPropertyMaterialByName( string sMaterialName)
//      Given a valid material name this function returns a new material itemproperty of
//      that type or and invalid itemproperty if the material name is not recognized.
//::///////////////////////////////////////////////////////////////
// Parameters:  string sMaterialName - the material name IP_MATERIAL_NAME_*
//
// Returns: a material itemproperty or an invalid itempropery if the specified
//          material name is unrecognized.
//::///////////////////////////////////////////////////////////////
itemproperty ItemPropertyMaterialByName( string sMaterialName);
itemproperty ItemPropertyMaterialByName( string sMaterialName)
{
	return ItemPropertyMaterial( GetIPMaterial( sMaterialName));
}
  
  
//::///////////////////////////////////////////////////////////////
//  void IPAddMaterialProperty( int iMaterialType, int nDurationType, object oItem, float fDuration = 0.0f)
//      Adds a material itempropery specified by material type to an item for a
//      given duration type and duration.
//::///////////////////////////////////////////////////////////////
// Parameters:  int    iMaterialType - the material type IP_MATERIAL_*
//              int    nDurationType - the duration type
//                                     DURATION_TYPE_TEMPORARY, must also supply a duration
//                                     DURATION_TYPE_PERMANENT, duration is ignored
//              object oItem         - the item to add the itempropery to.
//              float  fDuration     - the duration in seconds that the itemproperty
//                                     will stay on the item before being automatically
//                                     removed. Ignored if duration type is permanent.
//                                     Default = 0.0 seconds.
//
// Returns: none. Note this does not check to see if the material property already
//          exists on the item and can add duplicate material properties to it.
//::///////////////////////////////////////////////////////////////
void IPAddMaterialProperty( int iMaterialType, int nDurationType, object oItem, float fDuration = 0.0f);
void IPAddMaterialProperty( int iMaterialType, int nDurationType, object oItem, float fDuration = 0.0f)
{
	itemproperty ipMaterial = ItemPropertyMaterial( iMaterialType);
	if( GetIsItemPropertyValid( ipMaterial)) AddItemProperty( nDurationType, ipMaterial, oItem, fDuration);
}
  
  
//::///////////////////////////////////////////////////////////////
//  void IPAddMaterialPropertyByName( string sMaterialName, int nDurationType, object oItem, float fDuration = 0.0f)
//      Adds a material itempropery specified by material name to an item for a
//      given duration type and duration.
//::///////////////////////////////////////////////////////////////
// Parameters:  string sMaterialName - the material name IP_MATERIAL_NAME_*
//              int    nDurationType - the duration type
//                                     DURATION_TYPE_TEMPORARY, must also supply a duration
//                                     DURATION_TYPE_PERMANENT, duration is ignored
//              object oItem         - the item to add the itempropery to.
//              float  fDuration     - the duration in seconds that the itemproperty
//                                     will stay on the item before being automatically
//                                     removed. Ignored if duration type is permanent.
//                                     Default = 0.0 seconds.
//
// Returns: none. Note this does not check to see if the material property already
//          exists on the item and can add duplicate material properties to it.
//::///////////////////////////////////////////////////////////////
void IPAddMaterialPropertyByName( string sMaterialName, int nDurationType, object oItem, float fDuration = 0.0f);
void IPAddMaterialPropertyByName( string sMaterialName, int nDurationType, object oItem, float fDuration = 0.0f)
{
	IPAddMaterialProperty( GetIPMaterial( sMaterialName), nDurationType, oItem, fDuration);
}
  
  
//::///////////////////////////////////////////////////////////////
//  void IPSafeAddMaterialProperty( int iMaterialType, object oItem, float fDuration = 0.0f,  int nAddItemPropertyPolicy = X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, int bIgnoreDurationType = FALSE, int bIgnoreSubType = FALSE)
//      Adds a material itempropery specified by material type to an item for a
//      given duration. Checks to see if a material itemproperty of the same type
//      already exists on the item and adds the new one based on the add/drop policy
//      and ignore parameters specified.
//::///////////////////////////////////////////////////////////////
// Parameters:  int    iMaterialType          - the material type IP_MATERIAL_*
//              object oItem                  - the item to add the itempropery to.
//              float  fDuration              - 0.0 for permanent, anything else is temporary
//                                              Default = 0.0
//              int    nAddItemPropertyPolicy - the add/drop policy to use X2_IP_ADDPROP_POLICY_*
//                                              Default = X2_IP_ADDPROP_POLICY_REPLACE_EXISTING
//              int    bIgnoreDurationType    - TRUE or FALSE to ignore existing itemproperty duration types.
//                                              Default = FALSE
//              int    bIgnoreSubType         - TRUE or FALSE to ignore existing itemproperty subtypes
//                                              Default = FALSE
//
// Returns: none.
//::///////////////////////////////////////////////////////////////
void IPSafeAddMaterialProperty( int iMaterialType, object oItem, float fDuration = 0.0f,  int nAddItemPropertyPolicy = X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, int bIgnoreDurationType = FALSE, int bIgnoreSubType = FALSE);
void IPSafeAddMaterialProperty( int iMaterialType, object oItem, float fDuration = 0.0f,  int nAddItemPropertyPolicy = X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, int bIgnoreDurationType = FALSE, int bIgnoreSubType = FALSE)
{
	itemproperty ipMaterial = ItemPropertyMaterial( iMaterialType);
	if( GetIsItemPropertyValid( ipMaterial)) IPSafeAddItemProperty( oItem, ipMaterial, fDuration, nAddItemPropertyPolicy, bIgnoreDurationType, bIgnoreSubType);
}
  
  
//::///////////////////////////////////////////////////////////////
//  void IPSafeAddMaterialPropertyByName( string sMaterialName, object oItem, float fDuration = 0.0f,  int nAddItemPropertyPolicy = X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, int bIgnoreDurationType = FALSE, int bIgnoreSubType = FALSE)
//      Adds a material itempropery specified by material name to an item for a
//      given duration. Checks to see if a material itemproperty of the same type
//      already exists on the item and adds the new one based on the add/drop policy
//      and ignore parameters specified.
//::///////////////////////////////////////////////////////////////
// Parameters:  string sMaterialName          - the material name IP_MATERIAL_NAME_*
//              object oItem                  - the item to add the itempropery to.
//              float  fDuration              - 0.0 for permanent, anything else is temporary
//                                              Default = 0.0
//              int    nAddItemPropertyPolicy - the add/drop policy to use X2_IP_ADDPROP_POLICY_*
//                                              Default = X2_IP_ADDPROP_POLICY_REPLACE_EXISTING
//              int    bIgnoreDurationType    - TRUE or FALSE to ignore existing itemproperty duration types.
//                                              Default = FALSE
//              int    bIgnoreSubType         - TRUE or FALSE to ignore existing itemproperty subtypes
//                                              Default = FALSE
//
// Returns: none.
//::///////////////////////////////////////////////////////////////
void IPSafeAddMaterialPropertyByName( string sMaterialName, object oItem, float fDuration = 0.0f,  int nAddItemPropertyPolicy = X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, int bIgnoreDurationType = FALSE, int bIgnoreSubType = FALSE);
void IPSafeAddMaterialPropertyByName( string sMaterialName, object oItem, float fDuration = 0.0f,  int nAddItemPropertyPolicy = X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, int bIgnoreDurationType = FALSE, int bIgnoreSubType = FALSE)
{ 
	IPSafeAddMaterialProperty( GetIPMaterial( sMaterialName), oItem, fDuration, nAddItemPropertyPolicy, bIgnoreDurationType, bIgnoreSubType);
}
  
  
//::///////////////////////////////////////////////////////////////
//  int GetItemHasMaterial( object oItem, int iMaterialType)
//      Given a valid item and material type, this function returns TRUE if the
//      item has an itemproperty of the specified type on it.
//::///////////////////////////////////////////////////////////////
// Parameters:  object oItem         - the item to check.
//              int    iMaterialType - the material type to check for IP_MATERIAL_*
//
// Returns: TRUE if the item is a valid item and has a material itemproperty of
//          the specified type on it. FALSE otherwise.
//::///////////////////////////////////////////////////////////////
int GetItemHasMaterial( object oItem, int iMaterialType);
int GetItemHasMaterial( object oItem, int iMaterialType)
{ 
	if( !GetIsObjectValid( oItem) || (GetObjectType( oItem) != OBJECT_TYPE_ITEM) ||
      (iMaterialType <= IP_MATERIAL_INVALID) || (iMaterialType > IP_NUM_MATERIALS)) return FALSE;
  
	itemproperty ipMaterial = GetFirstItemProperty( oItem);
	while( GetIsItemPropertyValid( ipMaterial))
	{
		if( IPGetMaterialType( ipMaterial) == iMaterialType) return TRUE;
		ipMaterial = GetNextItemProperty( oItem);
	}
	
	return FALSE;
}
  
  
//::///////////////////////////////////////////////////////////////
//  int GetItemHasMaterialByName( object oItem, string sMaterialName)
//      Given a valid item and material name, this function returns TRUE if the
//      item has an itemproperty of the specified type on it.
//::///////////////////////////////////////////////////////////////
// Parameters:  object oItem         - the item to check.
//              string sMaterialName - the material Name to check for IP_MATERIAL_NAME_*
//
// Returns: TRUE if the item is a valid item and has a material itemproperty of
//          the specified type on it. FALSE otherwise.
//::///////////////////////////////////////////////////////////////
int GetItemHasMaterialByName( object oItem, string sMaterialName);
int GetItemHasMaterialByName( object oItem, string sMaterialName)
{
	return GetItemHasMaterial( oItem, GetIPMaterial( sMaterialName));
}
 
 //:: Returns the general type of material nMaterial is.
int GetMaterialType(int nMaterial);
int GetMaterialType(int nMaterial)
{
	if ( nMaterial == IP_MATERIAL_INVALID )
		return MATERIAL_TYPE_INVALID;	 
	 
	else if (  nMaterial == IP_MATERIAL_BONE
			|| nMaterial == IP_MATERIAL_SCALE
			|| nMaterial == IP_MATERIAL_CHITIN
			|| nMaterial == IP_MATERIAL_DRAKE_IVORY )
		return MATERIAL_TYPE_BONE;
		
	else if ( nMaterial == IP_MATERIAL_HERB )
		return MATERIAL_TYPE_BOTANICAL;
		
	else if ( nMaterial == IP_MATERIAL_ELUKIAN_CLAY
			|| nMaterial == IP_MATERIAL_POTTERY )
		return MATERIAL_TYPE_CERAMIC;
		
	else if ( nMaterial == IP_MATERIAL_CLOTH
			|| nMaterial == IP_MATERIAL_COTTON
			|| nMaterial == IP_MATERIAL_SILK
			|| nMaterial == IP_MATERIAL_WOOL )
		return MATERIAL_TYPE_FIBER;
		
	else if ( nMaterial == IP_MATERIAL_GEM
			|| nMaterial == IP_MATERIAL_GEM_ALEXANDRITE
			|| nMaterial == IP_MATERIAL_GEM_AMETHYST
			|| nMaterial == IP_MATERIAL_GEM_AVENTURINE
			|| nMaterial == IP_MATERIAL_GEM_BELJURIL
			|| nMaterial == IP_MATERIAL_GEM_BLOODSTONE
			|| nMaterial == IP_MATERIAL_GEM_BLUE_DIAMOND
			|| nMaterial == IP_MATERIAL_GEM_CANARY_DIAMOND
			|| nMaterial == IP_MATERIAL_GEM_DIAMOND
			|| nMaterial == IP_MATERIAL_GEM_EMERALD
			|| nMaterial == IP_MATERIAL_GEM_FIRE_AGATE
			|| nMaterial == IP_MATERIAL_GEM_FIRE_OPAL
			|| nMaterial == IP_MATERIAL_GEM_FLUORSPAR
			|| nMaterial == IP_MATERIAL_GEM_GARNET
			|| nMaterial == IP_MATERIAL_GEM_GREENSTONE
			|| nMaterial == IP_MATERIAL_GEM_JACINTH
			|| nMaterial == IP_MATERIAL_GEM_KINGS_TEAR
			|| nMaterial == IP_MATERIAL_GEM_MALACHITE
			|| nMaterial == IP_MATERIAL_GEM_OBSIDIAN
			|| nMaterial == IP_MATERIAL_GEM_PHENALOPE
			|| nMaterial == IP_MATERIAL_GEM_ROGUE_STONE
			|| nMaterial == IP_MATERIAL_GEM_RUBY
			|| nMaterial == IP_MATERIAL_GEM_SAPPHIRE
			|| nMaterial == IP_MATERIAL_GEM_STAR_SAPPHIRE
			|| nMaterial == IP_MATERIAL_GEM_TOPAZ
			|| nMaterial == IP_MATERIAL_GEM_CRYSTAL_DEEP
			|| nMaterial == IP_MATERIAL_GEM_CRYSTAL_MUNDANE
			|| nMaterial == IP_MATERIAL_GLASS
			|| nMaterial == IP_MATERIAL_ICE
			|| nMaterial == IP_MATERIAL_CRYSTAL_DASL
			|| nMaterial == IP_MATERIAL_OBSIDIAN 
			|| nMaterial == IP_MATERIAL_GLASSTEEL)
		return MATERIAL_TYPE_CRYSTAL;

	else if ( nMaterial == IP_MATERIAL_HIDE
			|| nMaterial == IP_MATERIAL_HIDE_SALAMANDER
			|| nMaterial == IP_MATERIAL_HIDE_UMBER_HULK
			|| nMaterial == IP_MATERIAL_HIDE_WYVERN
			|| nMaterial == IP_MATERIAL_HIDE_DRAGON_BLACK
			|| nMaterial == IP_MATERIAL_HIDE_DRAGON_BLUE
			|| nMaterial == IP_MATERIAL_HIDE_DRAGON_BRASS
			|| nMaterial == IP_MATERIAL_HIDE_DRAGON_BRONZE
			|| nMaterial == IP_MATERIAL_HIDE_DRAGON_COPPER
			|| nMaterial == IP_MATERIAL_HIDE_DRAGON_GOLD
			|| nMaterial == IP_MATERIAL_HIDE_DRAGON_GREEN
			|| nMaterial == IP_MATERIAL_HIDE_DRAGON_RED
			|| nMaterial == IP_MATERIAL_HIDE_DRAGON_SILVER
			|| nMaterial == IP_MATERIAL_HIDE_DRAGON_WHITE
			|| nMaterial == IP_MATERIAL_LEATHER
			|| nMaterial == IP_MATERIAL_LEAFWEAVE )
		return MATERIAL_TYPE_LEATHER;		
		
	else if ( nMaterial == IP_MATERIAL_ADAMANTINE
			|| nMaterial == IP_MATERIAL_BRASS
			|| nMaterial == IP_MATERIAL_COLD_IRON
			|| nMaterial == IP_MATERIAL_DARKSTEEL
			|| nMaterial == IP_MATERIAL_MITHRAL
			|| nMaterial == IP_MATERIAL_SILVER_ALCHEMICAL
			|| nMaterial == IP_MATERIAL_STEEL
			|| nMaterial == IP_MATERIAL_BYESHK
			|| nMaterial == IP_MATERIAL_CALOMEL
			|| nMaterial == IP_MATERIAL_CRYSTEEL_RIEDRAN
			|| nMaterial == IP_MATERIAL_IRON_FLAMETOUCHED
			|| nMaterial == IP_MATERIAL_MOURNLODE_PURPLE
			|| nMaterial == IP_MATERIAL_TARGATH
			|| nMaterial == IP_MATERIAL_ASTRAL_DRIFTMETAL
			|| nMaterial == IP_MATERIAL_ATANDUR
			|| nMaterial == IP_MATERIAL_BLENDED_QUARTZ
			|| nMaterial == IP_MATERIAL_DLARUN
			|| nMaterial == IP_MATERIAL_ENTROPIUM
			|| nMaterial == IP_MATERIAL_GREENSTEEL_BAATORIAN
			|| nMaterial == IP_MATERIAL_HIZAGKUUR
			|| nMaterial == IP_MATERIAL_IRON_FEVER
			|| nMaterial == IP_MATERIAL_IRON_GEHENNAN_MORGHUTH
			|| nMaterial == IP_MATERIAL_LIVING_METAL
			|| nMaterial == IP_MATERIAL_MINDSTEEL_URDRUKAR
			|| nMaterial == IP_MATERIAL_TRUESTEEL_SOLANIAN
			|| nMaterial == IP_MATERIAL_BRONZE
			|| nMaterial == IP_MATERIAL_COPPER
			|| nMaterial == IP_MATERIAL_GOLD
			|| nMaterial == IP_MATERIAL_IRON
			|| nMaterial == IP_MATERIAL_LEAD
			|| nMaterial == IP_MATERIAL_PLATINUM
			|| nMaterial == IP_MATERIAL_SILVER
			|| nMaterial == IP_MATERIAL_OBDURIUM )
		return MATERIAL_TYPE_METAL;			
			
	else if ( nMaterial == IP_MATERIAL_PAPER )
		return MATERIAL_TYPE_PAPER;
	
	else if ( nMaterial == IP_MATERIAL_ROPE_HEMP
			|| nMaterial == IP_MATERIAL_ROPE_GIANT_HAIR )
		return MATERIAL_TYPE_ROPE;
			
	else if ( nMaterial == IP_MATERIAL_CARBON
			|| nMaterial == IP_MATERIAL_ELEMENTAL
			|| nMaterial == IP_MATERIAL_ELEMENTAL_AIR
			|| nMaterial == IP_MATERIAL_ELEMENTAL_EARTH
			|| nMaterial == IP_MATERIAL_ELEMENTAL_FIRE
			|| nMaterial == IP_MATERIAL_ELEMENTAL_WATER
			|| nMaterial == IP_MATERIAL_STONE
			|| nMaterial == IP_MATERIAL_DEEP_CORAL
			|| nMaterial == IP_MATERIAL_DRAGONSHARD )
		return MATERIAL_TYPE_STONE;	

	else if ( nMaterial == IP_MATERIAL_WOOD
			|| nMaterial == IP_MATERIAL_WOOD_IRONWOOD
			|| nMaterial == IP_MATERIAL_WOOD_DUSKWOOD
			|| nMaterial == IP_MATERIAL_WOOD_DARKWOOD_ZALANTAR
			|| nMaterial == IP_MATERIAL_WOOD_ASH
			|| nMaterial == IP_MATERIAL_WOOD_YEW
			|| nMaterial == IP_MATERIAL_WOOD_OAK
			|| nMaterial == IP_MATERIAL_WOOD_PINE
			|| nMaterial == IP_MATERIAL_WOOD_CEDAR
			|| nMaterial == IP_MATERIAL_WOOD_LIVING
			|| nMaterial == IP_MATERIAL_WOOD_BRONZE
			|| nMaterial == IP_MATERIAL_DENSEWOOD
			|| nMaterial == IP_MATERIAL_LIVEWOOD
			|| nMaterial == IP_MATERIAL_SOARWOOD
			|| nMaterial == IP_MATERIAL_DARKLEAF_ELVEN
			|| nMaterial == IP_MATERIAL_DUSTWOOD
			|| nMaterial == IP_MATERIAL_WOOD_AGAFARI
			|| nMaterial == IP_MATERIAL_BAMBOO )
		return MATERIAL_TYPE_WOOD;	
	
	else { return MATERIAL_TYPE_UNKNOWN; }
}
  
 //:: Returns the name of nMaterialType as a string.
string GetMaterialTypeName(int nMaterialType, int bLowerCase = FALSE);
string GetMaterialTypeName(int nMaterialType, int bLowerCase = FALSE)
{	
	string sName;
	
	sName = Get2DACache("prc_materialtype", "Name", nMaterialType);
	
	if (sName == "")
		sName = "Invalid";
	
	return (bLowerCase ? GetStringLowerCase( sName) : sName);
}

//:: Returns the Hardness of a material.
int GetIPMaterialHardness(int nMaterial);
int GetIPMaterialHardness(int nMaterial)
{
	int nHardness;
	nHardness = StringToInt(Get2DACache("prc_material", "Hardness", nMaterial));
	
	if (nHardness < 0)
		nHardness = 1000;
	
	return nHardness;	
}

//:: Returns the Hit Points Per Inch of a material.
int GetIPMaterialHitPointMod(int nMaterial);
int GetIPMaterialHitPointMod(int nMaterial)
{
	int nHPMod;
	nHPMod = StringToInt(Get2DACache("prc_material", "HitPointsPerInch", nMaterial));
	
	if (nHPMod < 1)
		nHPMod = 1000;
	
	return nHPMod;	
}



//:: void main(){}
