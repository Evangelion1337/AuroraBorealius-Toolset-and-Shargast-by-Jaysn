/**
 * prc_ccc_const
 *
 * contains the constants 
 */

/**
 * Constants for determining whether a PC goes through the convoCC
 */
 
const int CONVOCC_ENTER_BOOT_PC         =  0;
const int CONVOCC_ENTER_NEW_PC          =  1;
const int CONVOCC_ENTER_RETURNING_PC    =  2;

 
/**
 * Constants for each stage in the convoCC
 */

const int STAGE_INTRODUCTION            =  0;
const int STAGE_GENDER                  =  1;
const int STAGE_GENDER_CHECK            =  2;
const int STAGE_RACE                    =  3;
const int STAGE_RACE_CHECK              =  4;
const int STAGE_CLASS                   =  5;
const int STAGE_CLASS_CHECK             =  6;
const int STAGE_ALIGNMENT               =  7;
const int STAGE_ALIGNMENT_CHECK         =  8;
const int STAGE_ABILITY                 =  9;
const int STAGE_ABILITY_CHECK           = 10;
const int STAGE_SKILL                   = 11;
const int STAGE_SKILL_CHECK             = 12;
const int STAGE_FEAT                    = 13;
const int STAGE_FEAT_CHECK              = 14;
const int STAGE_BONUS_FEAT              = 15;
const int STAGE_BONUS_FEAT_CHECK        = 16;
const int STAGE_WIZ_SCHOOL              = 17;
const int STAGE_WIZ_SCHOOL_CHECK        = 18;
const int STAGE_SPELLS_0                = 19;
const int STAGE_SPELLS_1                = 20;
const int STAGE_SPELLS_CHECK            = 21;
const int STAGE_FAMILIAR                = 22;
const int STAGE_FAMILIAR_CHECK          = 23;
const int STAGE_DOMAIN                  = 24;
const int STAGE_DOMAIN_CHECK1           = 25;
const int STAGE_DOMAIN_CHECK2           = 26;
const int STAGE_APPEARANCE              = 27;
const int STAGE_APPEARANCE_CHECK        = 28;
const int STAGE_PORTRAIT                = 29;
const int STAGE_PORTRAIT_CHECK          = 30;
const int STAGE_SOUNDSET                = 31;
const int STAGE_SOUNDSET_CHECK          = 32;
const int STAGE_HEAD                    = 33;
const int STAGE_HEAD_CHECK              = 34;
const int STAGE_TATTOO                  = 35;
const int STAGE_TATTOO_CHECK            = 36;
const int STAGE_WINGS                   = 37;
const int STAGE_WINGS_CHECK             = 38;
const int STAGE_TAIL                    = 39;
const int STAGE_TAIL_CHECK              = 40;
const int STAGE_SKIN_COLOUR             = 41;
const int STAGE_SKIN_COLOUR_CHOICE      = 42;
const int STAGE_SKIN_COLOUR_CHECK       = 43;
const int STAGE_HAIR_COLOUR             = 44;
const int STAGE_HAIR_COLOUR_CHOICE      = 45;
const int STAGE_HAIR_COLOUR_CHECK       = 46;
const int STAGE_TATTOO1_COLOUR          = 47;
const int STAGE_TATTOO1_COLOUR_CHOICE   = 48;
const int STAGE_TATTOO1_COLOUR_CHECK    = 49;
const int STAGE_TATTOO2_COLOUR          = 50;
const int STAGE_TATTOO2_COLOUR_CHOICE   = 51;
const int STAGE_TATTOO2_COLOUR_CHECK    = 52;

const int FINAL_STAGE                   = 99;

/**
 * constants used in the convoCC that aren't convo stages
 */
 
// brownie model in the CEP
const int APPEARANCE_TYPE_CEP_BROWNIE = 1002;

// wemic model in the CEP
const int APPEARANCE_TYPE_CEP_WEMIC = 1000;

