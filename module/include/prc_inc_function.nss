//::///////////////////////////////////////////////
//:: [PRC Feat Router]
//:: [prc_inc_function.nss]
//:://////////////////////////////////////////////
//:: This file serves as a hub for the various
//:: PRC passive feat functions.  If you need to
//:: add passive feats for a new PRC, link them here.
//::
//:: This file also contains a few multi-purpose
//:: PRC functions that need to be included in several
//:: places, ON DIFFERENT PRCS. Make local include files
//:: for any functions you use ONLY on ONE PRC.
//:://////////////////////////////////////////////
//:: Created By: Aaon Graywolf
//:: Created On: Dec 19, 2003
//:://////////////////////////////////////////////

//:: Updated for 8 class slots by Jaysyn 2024/02/05

//--------------------------------------------------------------------------
// This is the "event" that is called to re-evalutate PRC bonuses.  Currently
// it is fired by OnEquip, OnUnequip and OnLevel.  If you want to move any
// classes into this event, just copy the format below.  Basically, this function
// is meant to keep the code looking nice and clean by routing each class's
// feats to their own self-contained script
//--------------------------------------------------------------------------

//:: Test Void
//void main (){}


//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

const int TEMPLATE_SLA_START = 16304;
const int TEMPLATE_SLA_END   = 16400;

const string PRC_ScrubPCSkin_Generation = "PRC_ScrubPCSkin_Generation";
const string PRC_EvalPRCFeats_Generation = "PRC_EvalPRCFeats_Generation";


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

void EvalPRCFeats(object oPC);

int BlastInfidelOrFaithHeal(object oCaster, object oTarget, int iEnergyType, int iDisplayFeedback);

void ScrubPCSkin(object oPC, object oSkin);

void DeletePRCLocalInts(object oSkin);

void DelayedAddIPFeats(int nExpectedGeneration, object oPC);

void DelayedReApplyUnhealableAbilityDamage(int nExpectedGeneration, object oPC);

int nbWeaponFocus(object oPC);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

// Minimalist includes
#include "prc_inc_util"
#include "prc_inc_spells"
#include "prc_inc_stunfist"
#include "inc_nwnx_funcs"
#include "prc_template_con"

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

void DeleteCharacterData(object oPC)
{
    DeletePersistantLocalString(oPC, "PRC_Class_Script1");
    DeletePersistantLocalString(oPC, "PRC_Class_Script2");
    DeletePersistantLocalString(oPC, "PRC_Class_Script3");
	DeletePersistantLocalString(oPC, "PRC_Class_Script4");
	DeletePersistantLocalString(oPC, "PRC_Class_Script5");
	DeletePersistantLocalString(oPC, "PRC_Class_Script6");
	DeletePersistantLocalString(oPC, "PRC_Class_Script7");
	DeletePersistantLocalString(oPC, "PRC_Class_Script8");
    DeletePersistantLocalInt(oPC, "PRC_Class_Data");
}

void SetupCharacterData(object oPC)
{
    // iData format:
    // 0x01 - run alternate magic system setup
    // 0x02 - add new metamagic feats for spontaneous casters
    // 0x04 - run reduced arcane spell failure check
    // use bitwise to combine flags

    int i, iData, iShifting;
    for(i = 1; i <= 8; i++)
    {
        int nClassType = GetClassByPosition(i, oPC);
        if(nClassType != CLASS_TYPE_INVALID)
        {
            string sScript;
            switch(nClassType)
            {
                case CLASS_TYPE_ABJURANT_CHAMPION:     sScript = "prc_abchamp";                     break;			
                case CLASS_TYPE_ACOLYTE:               sScript = "prc_acolyte";                     break;
                case CLASS_TYPE_ALIENIST:              sScript = "prc_alienist";                    break;
                case CLASS_TYPE_ARCANE_DUELIST:        sScript = "prc_arcduel";                     break;
                case CLASS_TYPE_ARCHIVIST:             sScript = "prc_archivist";    iData |= 0x01; break;
                case CLASS_TYPE_ASSASSIN:                                            				break;
                //case CLASS_TYPE_BAELNORN:              sScript = "prc_baelnorn";                  break;
                case CLASS_TYPE_BARD:                                                iData |= 0x07; break;
                case CLASS_TYPE_BATTLESMITH:           sScript = "prc_battlesmith";                 break;
                case CLASS_TYPE_BEGUILER:                                            iData |= 0x03; break;
                case CLASS_TYPE_BINDER:                sScript = "bnd_binder";                      break;
                case CLASS_TYPE_BFZ:                   sScript = "prc_bfz";                         break;
                case CLASS_TYPE_BLACK_BLOOD_CULTIST:   sScript = "prc_bbc";                         break;
                case CLASS_TYPE_BLACKGUARD:            sScript = "prc_blackguard";                  break;
                case CLASS_TYPE_BLADESINGER:           sScript = "prc_bladesinger";  iData |= 0x04; break;
                case CLASS_TYPE_BLIGHTLORD:            sScript = "prc_blightlord";                  break;
                case CLASS_TYPE_BLOODCLAW_MASTER:      sScript = "tob_bloodclaw";                   break;
                case CLASS_TYPE_BONDED_SUMMONNER:      sScript = "prc_bondedsumm";                  break;
                case CLASS_TYPE_CELEBRANT_SHARESS:                                   iData |= 0x07; break;
                case CLASS_TYPE_CHILD_OF_NIGHT:        sScript = "shd_childnight";                  break;
                case CLASS_TYPE_COC:                   sScript = "prc_coc";                         break;
                case CLASS_TYPE_COMBAT_MEDIC:          sScript = "prc_cbtmed";                      break;
                case CLASS_TYPE_CONTEMPLATIVE:         sScript = "prc_contemplate";                 break;
                case CLASS_TYPE_CRUSADER:              sScript = "tob_crusader";     iData |= 0x01; break;
                case CLASS_TYPE_CULTIST_SHATTERED_PEAK: sScript = "prc_shatterdpeak";               break;
                case CLASS_TYPE_CW_SAMURAI:            sScript = "prc_cwsamurai";                   break;
                case CLASS_TYPE_DEEPSTONE_SENTINEL:    sScript = "tob_deepstone";                   break;
                case CLASS_TYPE_DIAMOND_DRAGON:        sScript = "psi_diadra";                      break;
                case CLASS_TYPE_DISC_BAALZEBUL:        sScript = "prc_baalzebul";                   break;
                case CLASS_TYPE_DISCIPLE_OF_ASMODEUS:  sScript = "prc_discasmodeus";                break;
                case CLASS_TYPE_DISCIPLE_OF_MEPH:      sScript = "prc_discmeph";                    break;
                case CLASS_TYPE_DISPATER:              sScript = "prc_dispater";                    break;
                case CLASS_TYPE_DRAGON_DEVOTEE:        sScript = "prc_dragdev";                     break;
                case CLASS_TYPE_DRAGON_DISCIPLE:       sScript = "prc_dradis";                      break;
                case CLASS_TYPE_DRAGON_SHAMAN:         sScript = "prc_dragonshaman";                break;
                case CLASS_TYPE_DRAGONFIRE_ADEPT:      sScript = "inv_drgnfireadpt"; iData |= 0x01; break;
                case CLASS_TYPE_DREAD_NECROMANCER:     sScript = "prc_dreadnecro";   iData |= 0x03; break;
                case CLASS_TYPE_DRUID:                                            iShifting = TRUE; break;
                case CLASS_TYPE_DRUNKEN_MASTER:        sScript = "prc_drunk";                       break;
                case CLASS_TYPE_DUELIST:               sScript = "prc_duelist";                     break;
                case CLASS_TYPE_DUSKBLADE:             sScript = "prc_duskblade";    iData |= 0x03; break;
                case CLASS_TYPE_ENLIGHTENEDFIST:       sScript = "prc_enlfis";                      break;
                case CLASS_TYPE_ELEMENTAL_SAVANT:      sScript = "prc_elemsavant";                  break;
                case CLASS_TYPE_ETERNAL_BLADE:         sScript = "tob_eternalblade";                break;
                case CLASS_TYPE_FACTOTUM:              sScript = "prc_factotum";                    break;
                case CLASS_TYPE_FAVOURED_SOUL:         sScript = "prc_favouredsoul"; iData |= 0x03; break;
				case CLASS_TYPE_FISTRAZIEL:			   sScript = "prc_fistraziel";					break;
                case CLASS_TYPE_FIST_OF_ZUOKEN:        sScript = "psi_zuoken";       iData |= 0x01; break;
				case CLASS_TYPE_FOCHLUCAN_LYRIST:	   sScript = "prc_fochlyr";						break;
                case CLASS_TYPE_FOE_HUNTER:            sScript = "prc_foe_hntr";                    break;
				case CLASS_TYPE_FORESTMASTER:		   sScript = "prc_forestmaster";				break;
                case CLASS_TYPE_FORSAKER:              sScript = "prc_forsaker";                    break;
                case CLASS_TYPE_FRE_BERSERKER:         sScript = "prc_frebzk";                      break;
                case CLASS_TYPE_FROSTRAGER:            sScript = "prc_frostrager";                  break;
                case CLASS_TYPE_FROST_MAGE:            sScript = "prc_frostmage";                   break;
                case CLASS_TYPE_HALFLING_WARSLINGER:   sScript = "prc_warsling";                    break;
                case CLASS_TYPE_HARPER:                                              iData |= 0x03; break;
                case CLASS_TYPE_HEARTWARDER:           sScript = "prc_heartwarder";                 break;
                case CLASS_TYPE_HENSHIN_MYSTIC:        sScript = "prc_henshin";                     break;
                case CLASS_TYPE_HEXBLADE:                                            iData |= 0x03; break;
                case CLASS_TYPE_HEXTOR:                sScript = "prc_hextor";                      break;
                case CLASS_TYPE_IAIJUTSU_MASTER:       sScript = "prc_iaijutsu_mst";                break;
                case CLASS_TYPE_INCARNATE:             sScript = "moi_incarnate";                   break;
                case CLASS_TYPE_INCARNUM_BLADE:        sScript = "moi_iblade";                      break;
                case CLASS_TYPE_INITIATE_DRACONIC:     sScript = "prc_initdraconic";                break;
                case CLASS_TYPE_IRONMIND:              sScript = "psi_ironmind";                    break;
                case CLASS_TYPE_IRONSOUL_FORGEMASTER:  sScript = "moi_ironsoul";                    break;
                case CLASS_TYPE_JADE_PHOENIX_MAGE:     sScript = "tob_jadephoenix";                 break;
                case CLASS_TYPE_JUDICATOR:             sScript = "prc_judicator";                   break;
                case CLASS_TYPE_JUSTICEWW:                                           iData |= 0x03; break;
                case CLASS_TYPE_KNIGHT:                sScript = "prc_knight";                      break;
                case CLASS_TYPE_KNIGHT_CHALICE:        sScript = "prc_knghtch";                     break;
                case CLASS_TYPE_KNIGHT_WEAVE:                                        iData |= 0x03; break;
				case CLASS_TYPE_KNIGHT_SACRED_SEAL:    sScript = "bnd_kss";                         break;
                case CLASS_TYPE_LASHER:                sScript = "prc_lasher";                      break;
                case CLASS_TYPE_LEGENDARY_DREADNOUGHT: sScript = "prc_legendread";                  break;
                case CLASS_TYPE_LICH:                  sScript = "pnp_lich_level";                  break;
				case CLASS_TYPE_LION_OF_TALISID:	   sScript = "prc_lot";							break;
                case CLASS_TYPE_MAGEKILLER:            sScript = "prc_magekill";                    break;
                case CLASS_TYPE_MASTER_HARPER:         sScript = "prc_masterh";                     break;
                case CLASS_TYPE_MASTER_OF_NINE:        sScript = "tob_masterofnine";                break;
                case CLASS_TYPE_MASTER_OF_SHADOW:      sScript = "shd_mastershadow";                break;
                case CLASS_TYPE_MIGHTY_CONTENDER_KORD: sScript = "prc_contendkord";                 break;
                case CLASS_TYPE_MORNINGLORD:           sScript = "prc_morninglord";                 break;
				case CLASS_TYPE_MONK:				   sScript = "prc_monk";						break;
                case CLASS_TYPE_NIGHTSHADE:            sScript = "prc_nightshade";                  break;
                case CLASS_TYPE_NINJA:                 sScript = "prc_ninjca";                      break;
                case CLASS_TYPE_OLLAM:                 sScript = "prc_ollam";                       break;
                case CLASS_TYPE_OOZEMASTER:            sScript = "prc_oozemstr";                    break;
                case CLASS_TYPE_ORDER_BOW_INITIATE:    sScript = "prc_ootbi";                       break;
                case CLASS_TYPE_PEERLESS:              sScript = "prc_peerless";                    break;
                case CLASS_TYPE_PNP_SHIFTER :                                     iShifting = TRUE; break;
                case CLASS_TYPE_PRC_EYE_OF_GRUUMSH:    sScript = "prc_eog";                         break;
                case CLASS_TYPE_PSION:                                               iData |= 0x01; break;
                case CLASS_TYPE_PSYWAR:                                              iData |= 0x01; break;
                case CLASS_TYPE_PSYCHIC_ROGUE:         sScript = "psi_psyrogue";     iData |= 0x01; break;
                case CLASS_TYPE_PYROKINETICIST:        sScript = "psi_pyro";                        break;
                case CLASS_TYPE_RAGE_MAGE:                                           iData |= 0x04; break;
                case CLASS_TYPE_REAPING_MAULER :       sScript = "prc_reapmauler";                  break;
                case CLASS_TYPE_RUBY_VINDICATOR:       sScript = "tob_rubyknight";                  break;
                case CLASS_TYPE_RUNESCARRED:           sScript = "prc_runescarred";                 break;
                case CLASS_TYPE_SACREDFIST:            sScript = "prc_sacredfist";                  break;
                case CLASS_TYPE_SANCTIFIED_MIND:       sScript = "psi_sancmind";                    break;
                case CLASS_TYPE_SAPPHIRE_HIERARCH:     sScript = "moi_sapphire";                    break;
                case CLASS_TYPE_SCOUT:                 sScript = "prc_scout";                       break;
                case CLASS_TYPE_SERENE_GUARDIAN:       sScript = "prc_sereneguard";                 break;
                case CLASS_TYPE_SHADOW_ADEPT:          sScript = "prc_shadowadept";                 break;
                case CLASS_TYPE_SHADOWCASTER:          sScript = "shd_shadowcaster"; iData |= 0x01; break;
                case CLASS_TYPE_SHADOWSMITH:                                         iData |= 0x01; break;
                case CLASS_TYPE_SHADOW_SUN_NINJA:      sScript = "tob_shadowsun";                   break;
                case CLASS_TYPE_SHADOWBLADE:           sScript = "prc_sb_shdstlth";                 break;
				case CLASS_TYPE_SHADOWLORD:			   sScript = "prc_shadowlord";					break;
                case CLASS_TYPE_SHADOWMIND:            sScript = "psi_shadowmind";                  break;
                case CLASS_TYPE_SHADOWBANE_STALKER:    sScript = "prc_shadstalker";                 break;
                case CLASS_TYPE_SHADOW_THIEF_AMN:      sScript = "prc_amn";                         break;
                case CLASS_TYPE_SHAMAN:                sScript = "prc_shaman";                      break;
                case CLASS_TYPE_SHINING_BLADE:         sScript = "prc_sbheir";                      break;
                case CLASS_TYPE_SHOU:                  sScript = "prc_shou";                        break;
                case CLASS_TYPE_SKULLCLAN_HUNTER:      sScript = "prc_skullclan";                   break;
                case CLASS_TYPE_SLAYER_OF_DOMIEL:      sScript = "prc_slayerdomiel";                break;
                case CLASS_TYPE_SOHEI:                 sScript = "prc_sohei";                       break;
                case CLASS_TYPE_SOLDIER_OF_LIGHT:      sScript = "prc_soldoflight";                 break;
                case CLASS_TYPE_SORCERER:                                            iData |= 0x03; break;
                case CLASS_TYPE_SOULBORN:              sScript = "moi_soulborn";                    break;
                case CLASS_TYPE_SOUL_EATER:            sScript = "prc_souleater"; iShifting = TRUE; break;
                case CLASS_TYPE_SOULKNIFE:             sScript = "psi_sk_clseval";                  break;
                case CLASS_TYPE_SPELLSWORD:            sScript = "prc_spellswd";     iData |= 0x04; break;
                case CLASS_TYPE_SPINEMELD_WARRIOR:     sScript = "moi_spinemeld";                   break;
                case CLASS_TYPE_STORMLORD:             sScript = "prc_stormlord";                   break;
                case CLASS_TYPE_SUBLIME_CHORD:         sScript = "prc_schord";       iData |= 0x03; break;
                case CLASS_TYPE_SUEL_ARCHANAMACH:                                    iData |= 0x03; break;
                case CLASS_TYPE_SWASHBUCKLER:          sScript = "prc_swashbuckler";                break;
                case CLASS_TYPE_SWIFT_WING:            sScript = "prc_swiftwing";                   break;
                case CLASS_TYPE_SWORDSAGE:             sScript = "tob_swordsage";    iData |= 0x01; break;
                case CLASS_TYPE_TALON_OF_TIAMAT:       sScript = "prc_talontiamat";                 break;
                case CLASS_TYPE_TEMPEST:               sScript = "prc_tempest";                 	break;
                case CLASS_TYPE_TEMPUS:                sScript = "prc_battletempus";                break;
                case CLASS_TYPE_TENEBROUS_APOSTATE:    sScript = "bnd_tenebrous";                   break;
                case CLASS_TYPE_THAYAN_KNIGHT:         sScript = "prc_thayknight";                  break;
                case CLASS_TYPE_THRALL_OF_GRAZZT_A:    sScript = "tog";                             break;
                case CLASS_TYPE_THRALLHERD:            sScript = "psi_thrallherd";                  break;
                case CLASS_TYPE_TOTEMIST:              sScript = "moi_totemist";                    break;
                case CLASS_TYPE_TOTEM_RAGER:           sScript = "moi_totemrager";                  break;
                case CLASS_TYPE_TRUENAMER:             sScript = "true_truenamer";   iData |= 0x01; break;
                case CLASS_TYPE_VASSAL:                sScript = "prc_vassal";                      break;
				case CLASS_TYPE_VERDANT_LORD:          sScript = "prc_verdantlord";                 break;
                case CLASS_TYPE_VIGILANT:              sScript = "prc_vigilant";                    break;
                case CLASS_TYPE_WARBLADE:              sScript = "tob_warblade";     iData |= 0x01; break;
                case CLASS_TYPE_WARCHIEF:              sScript = "prc_warchief";                    break;
                case CLASS_TYPE_WARFORGED_JUGGERNAUT:  sScript = "prc_juggernaut";                  break;
                case CLASS_TYPE_WARLOCK:               sScript = "inv_warlock";      iData |= 0x01; break;
                case CLASS_TYPE_WARMAGE:                                             iData |= 0x03; break;
                case CLASS_TYPE_WARMIND:               sScript = "psi_warmind";      iData |= 0x01; break;
                case CLASS_TYPE_WEREWOLF:              sScript = "prc_werewolf";                    break;                
                case CLASS_TYPE_WILDER:                                              iData |= 0x01; break;
                
                // Races that can cast spells
                case CLASS_TYPE_DRAGON:                                              iData |= 0x03; break;
				case CLASS_TYPE_SHAPECHANGER:                                        iData |= 0x03; break;
                case CLASS_TYPE_OUTSIDER:                                            iData |= 0x03; break;
                case CLASS_TYPE_ABERRATION:                                          iData |= 0x03; break;
                case CLASS_TYPE_MONSTROUS:                                           iData |= 0x03; break;
                case CLASS_TYPE_FEY:                                                 iData |= 0x03; break;
            }
            if(sScript != "")
                SetPersistantLocalString(oPC, "PRC_Class_Script"+IntToString(i), sScript);
        }
        if (DEBUG) DoDebug("SetupCharacterData Class: " + IntToString(nClassType));
        if (DEBUG) DoDebug("SetupCharacterData Data: " + IntToString(iData));
    }
    if(iData)
        SetPersistantLocalInt(oPC, "PRC_Class_Data", iData);

    if(iShifting)
        SetPersistantLocalInt(oPC, "PRC_UNI_SHIFT_SCRIPT", 1);

    //Setup class info for onleveldown script
    int nCharData = ((GetClassByPosition(8, oPC) & 0xFF) << 56) |
					((GetClassByPosition(7, oPC) & 0xFF) << 48) |
					((GetClassByPosition(6, oPC) & 0xFF) << 40) |
                    ((GetClassByPosition(5, oPC) & 0xFF) << 32) |
					((GetClassByPosition(4, oPC) & 0xFF) << 24) |
					((GetClassByPosition(3, oPC) & 0xFF) << 16) |
                    ((GetClassByPosition(2, oPC) & 0xFF) << 8) |					
                    (GetClassByPosition(1, oPC) & 0xFF);

    SetPersistantLocalInt(oPC, "PRC_Character_Data", nCharData);
}

void DelayedExecuteScript(int nExpectedGeneration, string sScriptName, object oPC)
{
    if (nExpectedGeneration != GetLocalInt(oPC, PRC_EvalPRCFeats_Generation))
    {
        //Generation has changed, so don't apply the effect
        return;
    }
    ExecuteScript(sScriptName, oPC);
}

void DelayedReApplyUnhealableAbilityDamage(int nExpectedGeneration, object oPC)
{
    if (nExpectedGeneration != GetLocalInt(oPC, PRC_ScrubPCSkin_Generation))
    {
        //Generation has changed, so don't apply the effect
        return;
    }
    ReApplyUnhealableAbilityDamage(oPC);
}

int ToBFeats(object oPC)
{
    if(GetHasFeat(FEAT_SHADOW_BLADE, oPC) ||
       GetHasFeat(FEAT_RAPID_ASSAULT, oPC) ||
       GetHasFeat(FEAT_DESERT_WIND_DODGE, oPC) ||
       GetHasFeat(FEAT_DESERT_FIRE, oPC) ||
       GetHasFeat(FEAT_IRONHEART_AURA, oPC) ||
       GetHasFeat(FEAT_SHADOW_TRICKSTER, oPC) ||
       GetHasFeat(FEAT_WHITE_RAVEN_DEFENSE, oPC) ||
       GetHasFeat(FEAT_DEVOTED_BULWARK, oPC) ||
       GetHasFeat(FEAT_SNAP_KICK, oPC) ||
       GetHasFeat(FEAT_THREE_MOUNTAINS, oPC) ||
       GetHasFeat(FEAT_VAE_SCHOOL, oPC) ||
       GetHasFeat(FEAT_INLINDL_SCHOOL, oPC) ||
       GetHasFeat(FEAT_XANIQOS_SCHOOL, oPC) ||
       GetHasFeat(FEAT_SHIELD_WALL, oPC) ||
       GetHasFeat(FEAT_CROSSBOW_SNIPER, oPC) ||
       GetHasFeat(FEAT_CRESCENT_MOON, oPC) ||
       GetHasFeat(FEAT_QUICK_STAFF, oPC) ||
       GetHasFeat(FEAT_BEAR_FANG, oPC) ||
       GetHasFeat(FEAT_IMPROVED_RAPID_SHOT, oPC) ||
       GetHasFeat(FEAT_DIRE_FLAIL_SMASH, oPC) ||
       GetHasFeat(FEAT_SHIELD_SPECIALIZATION_LIGHT, oPC) ||
       GetHasFeat(FEAT_SHIELD_SPECIALIZATION_HEAVY, oPC) ||
       GetHasFeat(FEAT_FOCUSED_SHIELD, oPC) ||
       GetHasFeat(FEAT_SHIELDMATE, oPC) ||
       GetHasFeat(FEAT_IMPROVED_SHIELDMATE, oPC) ||
       GetHasFeat(FEAT_SHIELDED_CASTING, oPC) ||
       GetHasFeat(FEAT_BLADE_MEDITATION_DESERT_WIND   , oPC) ||
       GetHasFeat(FEAT_BLADE_MEDITATION_DEVOTED_SPIRIT, oPC) ||
       GetHasFeat(FEAT_BLADE_MEDITATION_DIAMOND_MIND  , oPC) ||
       GetHasFeat(FEAT_BLADE_MEDITATION_IRON_HEART    , oPC) ||
       GetHasFeat(FEAT_BLADE_MEDITATION_SETTING_SUN   , oPC) ||
       GetHasFeat(FEAT_BLADE_MEDITATION_SHADOW_HAND   , oPC) ||
       GetHasFeat(FEAT_BLADE_MEDITATION_STONE_DRAGON  , oPC) ||
       GetHasFeat(FEAT_BLADE_MEDITATION_TIGER_CLAW    , oPC) ||
       GetHasFeat(FEAT_BLADE_MEDITATION_WHITE_RAVEN   , oPC) ||
       GetRacialType(oPC) == RACIAL_TYPE_RETH_DEKALA ||
       GetRacialType(oPC) == RACIAL_TYPE_HADRIMOI)
        return TRUE;
        
    return FALSE;    
}

void EvalPRCFeats(object oPC)
{
    // Player is currently making character in ConvoCC
    // don't run EvalPRCFeats() yet
    if(oPC == GetLocalObject(GetModule(), "ccc_active_pc"))
        return;

	if(GetHasFeat(FEAT_COMBAT_FOCUS, oPC)) ExecuteScript("prc_combatfocus", oPC);

    int nGeneration = PRC_NextGeneration(GetLocalInt(oPC, PRC_EvalPRCFeats_Generation));
    if (DEBUG > 1) DoDebug("EvalPRCFeats Generation: " + IntToString(nGeneration));
    SetLocalInt(oPC, PRC_EvalPRCFeats_Generation, nGeneration);

    //permanent ability changes
    if(GetPRCSwitch(PRC_NWNXEE_ENABLED))
        ExecuteScript("prc_nwnx_funcs", oPC);

    //Add IP Feats to the hide
    DelayCommand(0.0f, DelayedAddIPFeats(nGeneration, oPC));

    // If there is a bonus domain, it will always be in the first slot, so just check that.
    // It also runs things that clerics with those domains need
    if (GetPersistantLocalInt(oPC, "PRCBonusDomain1") > 0 || GetLevelByClass(CLASS_TYPE_CLERIC, oPC) || GetLevelByClass(CLASS_TYPE_SHAMAN, oPC))
        DelayCommand(0.1f, ExecuteScript("prc_domain_skin", oPC));

    // special add atk bonus equal to Enhancement
    ExecuteScript("ft_sanctmartial", oPC);

    //hook in the weapon size restrictions script
    //ExecuteScript("prc_restwpnsize", oPC);  //<- Script no longer exists

    //Route the event to the appropriate class specific scripts
    int i, iData;
    string sScript;
    for (i = 1; i <= 8; i++)
    {
        sScript = GetPersistantLocalString(oPC, "PRC_Class_Script"+IntToString(i));
        if(sScript != "")
        {
        	if (DEBUG) DoDebug("PRC_Class_Script: "+sScript);
            ExecuteScript(sScript, oPC);
        }    
    }

    iData = GetPersistantLocalInt(oPC, "PRC_Class_Data");

    // Handle alternate caster types gaining new stuff
    if(iData & 0x01)
        ExecuteScript("prc_amagsys_gain", oPC);

    // Add ip feats for spontaneous casters using metamagic
    if(iData & 0x02)
        ExecuteScript("prc_metamagic", oPC);

    // Handle classes with reduced arcane spell failure
    if(iData & 0x04)
        ExecuteScript("prc_reducedasf", oPC);

    if(GetPersistantLocalInt(oPC, "PRC_UNI_SHIFT_SCRIPT"))
        //Executing shifter-related stuff like this has these advantages:
        //1) All races and classes that need it can get it without a different script needing to be created for each.
        //2) PCs with shifter-related stuff from multiple classes or races don't run the same functions multiple times.
        ExecuteScript("prc_uni_shift", oPC);

    // Templates
    //these go here so feats can be reused
    ExecuteScript("prc_templates", oPC);

    // Feats
    //these are here so if templates add them the if check runs after the template was applied
    ExecuteScript("prc_feats", oPC);
    
    if (ToBFeats(oPC))
        ExecuteScript("tob_feats", oPC);
        
    if (GetIsIncarnumUser(oPC) || GetRacialType(oPC) == RACIAL_TYPE_JAEBRIN)
        ExecuteScript("moi_events", oPC); 
        
    if (GetIsBinder(oPC))
        ExecuteScript("bnd_events", oPC); 

    // check if character with crafting feat has appropriate base item in her inventory
    // x - moved from prc_onhb_indiv.nss
    if(GetPRCSwitch(PRC_CRAFTING_BASE_ITEMS))
        DelayCommand(0.5f, ExecuteScript("prc_crftbaseitms", oPC));

    // Add the teleport management feats.
    // 2005.11.03: Now added to all base classes on 1st level - Ornedan
//    ExecuteScript("prc_tp_mgmt_eval", oPC);

    // Size changes. Removed due to double-dipping most size adjustments
    //ExecuteScript("prc_size", oPC);

    // Speed changes
    // The local int is for when items are requipped too quickly and this script bugs out
    if (!GetLocalInt(oPC, "PRCSpeedDelay"))
    {
    	ExecuteScript("prc_speed", oPC);
    	SetLocalInt(oPC, "PRCSpeedDelay", TRUE);
    	DelayCommand(0.15, DeleteLocalInt(oPC, "PRCSpeedDelay"));
    }	

    // ACP system
    if((GetIsPC(oPC) &&
        (GetPRCSwitch(PRC_ACP_MANUAL)   ||
         GetPRCSwitch(PRC_ACP_AUTOMATIC)
         )
        ) ||
       (!GetIsPC(oPC) &&
        GetPRCSwitch(PRC_ACP_NPC_AUTOMATIC)
        )
       )
        ExecuteScript("acp_auto", oPC);

// this is handled inside the PRC Options conversation now.
/*    // Epic spells
    if((GetCasterLvl(CLASS_TYPE_CLERIC,   oPC) >= 21 ||
        GetCasterLvl(CLASS_TYPE_DRUID,    oPC) >= 21 ||
        GetCasterLvl(CLASS_TYPE_SORCERER, oPC) >= 21 ||
        GetCasterLvl(CLASS_TYPE_FAVOURED_SOUL, oPC) >= 21 ||
        GetCasterLvl(CLASS_TYPE_HEALER, oPC) >= 21 ||
        GetCasterLvl(CLASS_TYPE_WIZARD,   oPC) >= 21
        ) &&
        !GetHasFeat(FEAT_EPIC_SPELLCASTING_REST, oPC)
       )
    {
        IPSafeAddItemProperty(oSkin, PRCItemPropertyBonusFeat(IP_CONST_FEAT_EPIC_REST), 0.0f,
                              X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
    }*/

    // Miscellaneous
    ExecuteScript("prc_sneak_att", oPC);
    ExecuteScript("race_skin", oPC);
    ExecuteScript("prc_mithral", oPC);
    if(GetPRCSwitch(PRC_ENFORCE_RACIAL_APPEARANCE) && GetIsPC(oPC))
        ExecuteScript("race_appear", oPC);

    //Reserve Feats
    if(!GetLocalInt(oPC, "ReserveFeatsRunning"))
    {
        if(GetHasFeat(FEAT_HOLY_WARRIOR, oPC) || 
           GetHasFeat(FEAT_MYSTIC_BACKLASH, oPC) || 
           GetHasFeat(FEAT_ACIDIC_SPLATTER, oPC) || 
           GetHasFeat(FEAT_FIERY_BURST, oPC) || 
           GetHasFeat(FEAT_STORM_BOLT, oPC) || 
           GetHasFeat(FEAT_WINTERS_BLAST, oPC) || 
           GetHasFeat(FEAT_CLAP_OF_THUNDER, oPC) || 
           GetHasFeat(FEAT_SICKENING_GRASP, oPC) || 
           GetHasFeat(FEAT_TOUCH_OF_HEALING, oPC) || 
           GetHasFeat(FEAT_DIMENSIONAL_JAUNT, oPC) || 
           GetHasFeat(FEAT_CLUTCH_OF_EARTH, oPC) || 
           GetHasFeat(FEAT_BORNE_ALOFT, oPC) || 
           GetHasFeat(FEAT_PROTECTIVE_WARD, oPC) || 
           GetHasFeat(FEAT_SHADOW_VEIL, oPC) || 
           GetHasFeat(FEAT_SUNLIGHT_EYES, oPC) || 
           GetHasFeat(FEAT_TOUCH_OF_DISTRACTION, oPC) || 
           GetHasFeat(FEAT_UMBRAL_SHROUD, oPC) || 
           GetHasFeat(FEAT_CHARNEL_MIASMA, oPC) || 
           GetHasFeat(FEAT_DROWNING_GLANCE, oPC) || 
           GetHasFeat(FEAT_INVISIBLE_NEEDLE, oPC) || 
           GetHasFeat(FEAT_SUMMON_ELEMENTAL, oPC) || 
           GetHasFeat(FEAT_DIMENSIONAL_REACH, oPC) || 
           GetHasFeat(FEAT_HURRICANE_BREATH, oPC) || 
           GetHasFeat(FEAT_MINOR_SHAPESHIFT, oPC) || 
           GetHasFeat(FEAT_FACECHANGER, oPC))
        {
            ExecuteScript("prc_reservefeat", oPC);
        }
    }

    /*if(// Psionics
       GetLevelByClass(CLASS_TYPE_PSION,            oPC) ||
       GetLevelByClass(CLASS_TYPE_WILDER,           oPC) ||
       GetLevelByClass(CLASS_TYPE_PSYWAR,           oPC) ||
       GetLevelByClass(CLASS_TYPE_FIST_OF_ZUOKEN,   oPC) ||
       GetLevelByClass(CLASS_TYPE_WARMIND,          oPC) ||
       // New spellbooks
       GetLevelByClass(CLASS_TYPE_BARD,             oPC) ||
       GetLevelByClass(CLASS_TYPE_SORCERER,         oPC) ||
       GetLevelByClass(CLASS_TYPE_SUEL_ARCHANAMACH, oPC) ||
       GetLevelByClass(CLASS_TYPE_FAVOURED_SOUL,    oPC) ||
       GetLevelByClass(CLASS_TYPE_MYSTIC,           oPC) ||
       GetLevelByClass(CLASS_TYPE_HEXBLADE,         oPC) ||
       GetLevelByClass(CLASS_TYPE_DUSKBLADE,        oPC) ||
       GetLevelByClass(CLASS_TYPE_WARMAGE,          oPC) ||
       GetLevelByClass(CLASS_TYPE_DREAD_NECROMANCER,oPC) ||
       GetLevelByClass(CLASS_TYPE_JUSTICEWW,        oPC) ||
       GetLevelByClass(CLASS_TYPE_WITCH,            oPC) ||
       GetLevelByClass(CLASS_TYPE_SUBLIME_CHORD,    oPC) ||
       GetLevelByClass(CLASS_TYPE_ARCHIVIST,        oPC) ||
       GetLevelByClass(CLASS_TYPE_BEGUILER,         oPC) ||
       GetLevelByClass(CLASS_TYPE_HARPER,           oPC) ||
       GetLevelByClass(CLASS_TYPE_TEMPLAR,          oPC) ||
       // Truenaming
       GetLevelByClass(CLASS_TYPE_TRUENAMER,        oPC) ||
       // Tome of Battle
       GetLevelByClass(CLASS_TYPE_CRUSADER,         oPC) ||
       GetLevelByClass(CLASS_TYPE_SWORDSAGE,        oPC) ||
       GetLevelByClass(CLASS_TYPE_WARBLADE,         oPC) ||
       // Invocations
       GetLevelByClass(CLASS_TYPE_DRAGONFIRE_ADEPT, oPC) ||
       GetLevelByClass(CLASS_TYPE_WARLOCK, oPC) ||
       // Racial casters
       (GetLevelByClass(CLASS_TYPE_OUTSIDER, oPC) && GetRacialType(oPC) == RACIAL_TYPE_RAKSHASA)
        )
      {
        DelayCommand(1.0, DelayedExecuteScript(nGeneration, "prc_amagsys_gain", oPC));

        //add selectable metamagic feats for spontaneous spellcasters
        ExecuteScript("prc_metamagic", oPC);
      }*/

    // Gathers all the calls to UnarmedFists & Feats to one place.
    // Must be after all evaluationscripts that need said functions.
    //if(GetLocalInt(oPC, "CALL_UNARMED_FEATS") || GetLocalInt(oPC, "CALL_UNARMED_FISTS")) // ExecuteScript() is pretty expensive, do not run it needlessly - 20060702, Ornedan
    ExecuteScript("unarmed_caller", oPC);

    // Gathers all the calls to SetBaseAttackBonus() to one place
    // Must be after all evaluationscripts that need said function.
    ExecuteScript("prc_bab_caller", oPC);

    // Classes an invoker can take
    if(	GetLevelByClass(CLASS_TYPE_ABJURANT_CHAMPION,		oPC) ||
		GetLevelByClass(CLASS_TYPE_ACOLYTE,					oPC) ||
		GetLevelByClass(CLASS_TYPE_ANIMA_MAGE,				oPC) ||
		GetLevelByClass(CLASS_TYPE_ARCTRICK,				oPC) ||
		GetLevelByClass(CLASS_TYPE_BLOOD_MAGUS,				oPC) ||
		GetLevelByClass(CLASS_TYPE_DISCIPLE_OF_ASMODEUS,	oPC) ||
		GetLevelByClass(CLASS_TYPE_ENLIGHTENEDFIST,      	oPC) ||
		GetLevelByClass(CLASS_TYPE_MAESTER,					oPC) ||
		GetLevelByClass(CLASS_TYPE_TALON_OF_TIAMAT,			oPC) ||
		GetLevelByClass(CLASS_TYPE_UNSEEN_SEER,				oPC) ||	
		GetLevelByClass(CLASS_TYPE_VIRTUOSO,				oPC) ||			
		GetLevelByClass(CLASS_TYPE_WILD_MAGE,				oPC))
       {
			//Arcane caster first class position, take arcane
           if(GetFirstArcaneClassPosition(oPC) == 1)
               SetLocalInt(oPC, "INV_Caster", 1);
           //Invoker first class position. take invoker
           else if(GetClassByPosition(1, oPC) == CLASS_TYPE_WARLOCK || GetClassByPosition(1, oPC) == CLASS_TYPE_DRAGONFIRE_ADEPT)
               SetLocalInt(oPC, "INV_Caster", 2);
           //Non arcane first class position, invoker second.  Take invoker
           else if(GetFirstArcaneClassPosition(oPC) ==0 && (GetClassByPosition(2, oPC) == CLASS_TYPE_WARLOCK || GetClassByPosition(2, oPC) == CLASS_TYPE_DRAGONFIRE_ADEPT))
               SetLocalInt(oPC, "INV_Caster", 2);
           //last class would be Non-invoker first class position, arcane second position. take arcane.
           else
               SetLocalInt(oPC, "INV_Caster", 1);
		   
		   //:: Set arcane or invocation bonus caster levels
	   		if ( GetLevelByClass(CLASS_TYPE_ABJURANT_CHAMPION, oPC) > 0	&&
				 GetHasFeat(FEAT_ABCHAMP_NONE, oPC) )
			{ 
				SetLocalInt(oPC, "INV_Caster", 1);
			}
			else
			{ 
				SetLocalInt(oPC, "INV_Caster", 2);
			}

			if ( GetLevelByClass(CLASS_TYPE_ACOLYTE, oPC) > 0	&&
				 GetHasFeat(FEAT_AOTS_NONE, oPC) || GetHasFeat(FEAT_AOTS_MYSTERY_SHADOWCASTER, oPC) || GetHasFeat(FEAT_AOTS_MYSTERY_SHADOWSMITH, oPC))
			{ 
				SetLocalInt(oPC, "INV_Caster", 1);
			}				 
			else
			{ 
				SetLocalInt(oPC, "INV_Caster", 2);
			}			

			if ( GetLevelByClass(CLASS_TYPE_ANIMA_MAGE, oPC) > 0  &&
				 GetHasFeat(FEAT_ANIMA_NONE, oPC) )
			{ 
				SetLocalInt(oPC, "INV_Caster", 1);
			}
			else
			{ 
				SetLocalInt(oPC, "INV_Caster", 2);
			}
			
			if ( GetLevelByClass(CLASS_TYPE_ARCTRICK, oPC) > 0  &&
				 GetHasFeat(FEAT_ARCTRICK_NONE, oPC) )
			{ 
				SetLocalInt(oPC, "INV_Caster", 1);
			}
			else
			{ 
				SetLocalInt(oPC, "INV_Caster", 2);
			}	
			
			if ( GetLevelByClass(CLASS_TYPE_BLOOD_MAGUS, oPC) > 0  &&
				 GetHasFeat(FEAT_BLDMAGUS_NONE, oPC) )
			{ 
				SetLocalInt(oPC, "INV_Caster", 1);
			}
			else
			{ 
				SetLocalInt(oPC, "INV_Caster", 2);
			}	
			
			if ( GetLevelByClass(CLASS_TYPE_DISCIPLE_OF_ASMODEUS, oPC) > 0	&&
				 GetHasFeat(FEAT_ASMODEUS_NONE, oPC) || GetHasFeat(FEAT_ASMODEUS_MYSTERY_SHADOWCASTER, oPC) || GetHasFeat(FEAT_ASMODEUS_MYSTERY_SHADOWSMITH, oPC))
			{ 
				SetLocalInt(oPC, "INV_Caster", 1);
			}				 
			else
			{ 
				SetLocalInt(oPC, "INV_Caster", 2);
			}				

			if ( GetLevelByClass(CLASS_TYPE_ENLIGHTENEDFIST, oPC) > 0  &&
				 GetHasFeat(FEAT_ENLIGHTENEDFIST_NONE, oPC) )
			{ 
				SetLocalInt(oPC, "INV_Caster", 1);
			}
			else
			{ 
				SetLocalInt(oPC, "INV_Caster", 2);
			}				

			if ( GetLevelByClass(CLASS_TYPE_MAESTER, oPC) > 0  &&
				 GetHasFeat(FEAT_MAESTER_NONE, oPC) )
			{ 
				SetLocalInt(oPC, "INV_Caster", 1);
			}
			else
			{ 
				SetLocalInt(oPC, "INV_Caster", 2);
			}	

			if ( GetLevelByClass(CLASS_TYPE_TALON_OF_TIAMAT, oPC) > 0	&&
				 GetHasFeat(FEAT_TIAMAT_NONE, oPC) || GetHasFeat(FEAT_TIAMAT_MYSTERY_SHADOWCASTER, oPC) || GetHasFeat(FEAT_TIAMAT_MYSTERY_SHADOWSMITH, oPC))
			{ 
				SetLocalInt(oPC, "INV_Caster", 1);
			}				 
			else
			{ 
				SetLocalInt(oPC, "INV_Caster", 2);
			}			

			if ( GetLevelByClass(CLASS_TYPE_UNSEEN_SEER, oPC) > 0  &&
				 GetHasFeat(FEAT_UNSEEN_NONE, oPC) )
			{ 
				SetLocalInt(oPC, "INV_Caster", 1);
			}
			else
			{ 
				SetLocalInt(oPC, "INV_Caster", 2);
			}

			if ( GetLevelByClass(CLASS_TYPE_VIRTUOSO, oPC) > 0  &&
				 GetHasFeat(FEAT_VIRTUOSO_NONE, oPC) )
			{ 
				SetLocalInt(oPC, "INV_Caster", 1);
			}
			else
			{ 
				SetLocalInt(oPC, "INV_Caster", 2);
			}

			if ( GetLevelByClass(CLASS_TYPE_WILD_MAGE, oPC) > 0  &&
				 GetHasFeat(FEAT_WILDMAGE_NONE, oPC) )
			{ 
				SetLocalInt(oPC, "INV_Caster", 1);
			}
			else
			{ 
				SetLocalInt(oPC, "INV_Caster", 2);
			}				
			
/*            //Arcane caster first class position, take arcane
           if(GetFirstArcaneClassPosition(oPC) == 1)
               SetLocalInt(oPC, "INV_Caster", 1);
           //Invoker first class position. take invoker
           else if(GetClassByPosition(1, oPC) == CLASS_TYPE_WARLOCK || GetClassByPosition(1, oPC) == CLASS_TYPE_DRAGONFIRE_ADEPT)
               SetLocalInt(oPC, "INV_Caster", 2);
           //Non arcane first class position, invoker second.  Take invoker
           else if(GetFirstArcaneClassPosition(oPC) ==0 && (GetClassByPosition(2, oPC) == CLASS_TYPE_WARLOCK || GetClassByPosition(2, oPC) == CLASS_TYPE_DRAGONFIRE_ADEPT))
               SetLocalInt(oPC, "INV_Caster", 2);
           //last class would be Non-invoker first class position, arcane second position. take arcane.
           else
               SetLocalInt(oPC, "INV_Caster", 1); */
       }
}

void DelayedAddIPFeats(int nExpectedGeneration, object oPC)
{
    if (nExpectedGeneration != GetLocalInt(oPC, PRC_EvalPRCFeats_Generation))
    {
        //Generation has changed, so don't apply the effect
        return;
    }

    object oSkin = GetPCSkin(oPC);

    //Horse menu
    AddSkinFeat(FEAT_HORSE_MENU, 40, oSkin, oPC);

    // Switch convo feat
    //Now everyone gets it at level 1, but just to be on the safe side
    AddSkinFeat(FEAT_OPTIONS_CONVERSATION, 229, oSkin, oPC);

    //PnP familiars
    if(GetHasFeat(FEAT_SUMMON_FAMILIAR, oPC) && GetPRCSwitch(PRC_PNP_FAMILIARS))
        IPSafeAddItemProperty(oSkin, PRCItemPropertyBonusFeat(IP_CONST_PNP_FAMILIAR), 0.0f, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    else if(!GetHasFeat(FEAT_SUMMON_FAMILIAR, oPC) || !GetPRCSwitch(PRC_PNP_FAMILIARS))
        RemoveItemProperty(oSkin, ItemPropertyBonusFeat(IP_CONST_PNP_FAMILIAR));

    //PnP Spell Schools
    if(GetPRCSwitch(PRC_PNP_SPELL_SCHOOLS)
        && GetLevelByClass(CLASS_TYPE_WIZARD, oPC)
        && !GetIsPolyMorphedOrShifted(oPC)
        && !GetHasFeat(FEAT_PNP_SPELL_SCHOOL_GENERAL,       oPC)
        && !GetHasFeat(FEAT_PNP_SPELL_SCHOOL_ABJURATION,    oPC)
        && !GetHasFeat(FEAT_PNP_SPELL_SCHOOL_CONJURATION,   oPC)
        && !GetHasFeat(FEAT_PNP_SPELL_SCHOOL_DIVINATION,    oPC)
        && !GetHasFeat(FEAT_PNP_SPELL_SCHOOL_ENCHANTMENT,   oPC)
        && !GetHasFeat(FEAT_PNP_SPELL_SCHOOL_EVOCATION,     oPC)
        && !GetHasFeat(FEAT_PNP_SPELL_SCHOOL_ILLUSION,      oPC)
        && !GetHasFeat(FEAT_PNP_SPELL_SCHOOL_NECROMANCY,    oPC)
        && !GetHasFeat(FEAT_PNP_SPELL_SCHOOL_TRANSMUTATION, oPC)
        //&& !PRCGetHasEffect(EFFECT_TYPE_POLYMORPH, oPC) //so it doesnt pop up on polymorphing
        //&& !GetLocalInt(oSkin, "nPCShifted") //so it doenst pop up on shifting
        )
    {
        if(GetXP(oPC))// ConvoCC compatibility fix
            ExecuteScript("prc_pnp_shcc_s", oPC);
    }

    /*//Arcane Archer old imbue arrow
    if(GetLevelByClass(CLASS_TYPE_ARCANE_ARCHER, oPC) >= 2
        && !GetHasFeat(FEAT_PRESTIGE_IMBUE_ARROW, oPC)
        && GetPRCSwitch(PRC_PNP_SPELL_SCHOOLS))
    {
        //add the old feat to the hide
        IPSafeAddItemProperty(oSkin, PRCItemPropertyBonusFeat(IP_CONST_FEAT_FEAT_PRESTIGE_IMBUE_ARROW), 0.0f,
                              X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, FALSE);
    }*/

    //handle PnP sling switch
    if(GetPRCSwitch(PRC_PNP_SLINGS))
    {
        if(GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC)) == BASE_ITEM_SLING)
            IPSafeAddItemProperty(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC),
                ItemPropertyMaxRangeStrengthMod(20),
                999999.9);
    }
}

void TemplateSLAs(object oPC)
{
    int i;
    for(i = TEMPLATE_SLA_START; i <= TEMPLATE_SLA_END; i++)
    {
        DeleteLocalInt(oPC, "TemplateSLA_"+IntToString(i));
    }
}

void DeletePRCLocalInts(object oSkin)
{
    // This will get rid of any SetCompositeAttackBonus LocalInts:
    object oPC = GetItemPossessor(oSkin);
    DeleteLocalInt(oPC, "CompositeAttackBonusR");
    DeleteLocalInt(oPC, "CompositeAttackBonusL");

    //Do not use DelayCommand for this--it's too dangerous:
    //if SetCompositeAttackBonus is called at the wrong time the result will be incorrect.
    DeleteNamedComposites(oPC, "PRC_ComAttBon");

    // PRCGetClassByPosition and PRCGetLevelByPosition cleanup
    // not needed now that GetClassByPosition() works for custom classes
    // DeleteLocalInt(oPC, "PRC_ClassInPos1");
    // DeleteLocalInt(oPC, "PRC_ClassInPos2");
    // DeleteLocalInt(oPC, "PRC_ClassInPos3");
    // DeleteLocalInt(oPC, "PRC_ClassLevelInPos1");
    // DeleteLocalInt(oPC, "PRC_ClassLevelInPos2");
    // DeleteLocalInt(oPC, "PRC_ClassLevelInPos3");

    //persistant local token object cache
    //looks like logging off then back on without the server rebooting breaks it
    //I guess because the token gets a new ID, but the local still points to the old one
    DeleteLocalObject(oPC, "PRC_HideTokenCache");

    DeleteLocalInt(oSkin, "PRC_ArcaneSpellFailure");
    
    DeleteLocalInt(oPC, "PRC_SwiftActionUsed");
    DeleteLocalInt(oPC, "PRC_MoveActionUsed");

    // In order to work with the PRC system we need to delete some locals for each
    // PRC that has a hide

    //Do not use DelayCommand for this--it's too dangerous:
    //if SetCompositeBonus is called between the time EvalPRCFeats removes item properties
    //and the time this delayed command is executed, the result will be incorrect.
    //Since this error case actually happens frequently with any delay here, just don't do it.
    DeleteNamedComposites(oSkin, "PRC_CBon");

    if (DEBUG) DoDebug("Clearing class flags");

    // Elemental Savants
    DeleteLocalInt(oSkin,"ElemSavantResist");
    DeleteLocalInt(oSkin,"ElemSavantPerfection");
    DeleteLocalInt(oSkin,"ElemSavantImmMind");
    DeleteLocalInt(oSkin,"ElemSavantImmParal");
    DeleteLocalInt(oSkin,"ElemSavantImmSleep");
    // HeartWarder
    DeleteLocalInt(oSkin,"FeyType");
    // OozeMaster
    DeleteLocalInt(oSkin,"IndiscernibleCrit");
    DeleteLocalInt(oSkin,"IndiscernibleBS");
    DeleteLocalInt(oSkin,"OneOozeMind");
    DeleteLocalInt(oSkin,"OneOozePoison");
    // Storm lord
    DeleteLocalInt(oSkin,"StormLResElec");
    // Spell sword
    DeleteLocalInt(oSkin,"SpellswordSFBonusNormal");
    DeleteLocalInt(oSkin,"SpellswordSFBonusEpic");
    // Acolyte of the skin
    DeleteLocalInt(oSkin,"AcolyteSymbBonus");
    DeleteLocalInt(oSkin,"AcolyteResistanceCold");
    DeleteLocalInt(oSkin,"AcolyteResistanceFire");
    DeleteLocalInt(oSkin,"AcolyteResistanceAcid");
    DeleteLocalInt(oSkin,"AcolyteResistanceElectric");
    // Battleguard of Tempus
    DeleteLocalInt(oSkin,"FEAT_WEAP_TEMPUS");
    // Bonded Summoner
    DeleteLocalInt(oSkin,"BondResEle");
    DeleteLocalInt(oSkin,"BondSubType");
    // Disciple of Meph
    DeleteLocalInt(oSkin,"DiscMephResist");
    DeleteLocalInt(oSkin,"DiscMephGlove");
    // Initiate of Draconic Mysteries
    DeleteLocalInt(oSkin,"IniSR");
    DeleteLocalInt(oSkin,"IniStunStrk");
    // Man at Arms
    DeleteLocalInt(oSkin,"ManArmsCore");
    // Telflammar Shadowlord
    DeleteLocalInt(oSkin,"ShaDiscorp");
    // Vile Feats
    DeleteLocalInt(oSkin,"DeformGaunt");
    DeleteLocalInt(oSkin,"DeformObese");
    // Sneak Attack
    DeleteLocalInt(oSkin,"RogueSneakDice");
    DeleteLocalInt(oSkin,"BlackguardSneakDice");
    // Sacred Fist
    DeleteLocalInt(oSkin,"SacFisMv");
    // Minstrel
    DeleteLocalInt(oSkin,"MinstrelSFBonus"); //:: @todo Make ASF reduction compositable
    // Nightshade
    DeleteLocalInt(oSkin,"ImmuNSWeb");
    DeleteLocalInt(oSkin,"ImmuNSPoison");
    // Soldier of Light
    DeleteLocalInt(oSkin,"ImmuPF");
    // Ultimate Ranger
    DeleteLocalInt(oSkin,"URImmu");
    // Thayan Knight
    DeleteLocalInt(oSkin,"ThayHorror");
    DeleteLocalInt(oSkin,"ThayZulkFave");
    DeleteLocalInt(oSkin,"ThayZulkChamp");
    // Black Flame Zealot
    DeleteLocalInt(oSkin,"BFZHeart");
    // Henshin Mystic
    DeleteLocalInt(oSkin,"Happo");
    DeleteLocalInt(oSkin,"HMInvul");
    //Blightlord
    DeleteLocalInt(oSkin, "WntrHeart");
    DeleteLocalInt(oSkin, "BlightBlood");
    // Contemplative
    DeleteLocalInt(oSkin, "ContempDisease");
    DeleteLocalInt(oSkin, "ContempPoison");
    DeleteLocalInt(oSkin, "ContemplativeDR");
    DeleteLocalInt(oSkin, "ContemplativeSR");
    // Dread Necromancer
    DeleteLocalInt(oSkin, "DNDamageResist");
    // Warsling Sniper
    DeleteLocalInt(oPC, "CanRicochet");
    // Blood Magus
    DeleteLocalInt(oSkin, "ThickerThanWater");
	//:: Crusader
	DeleteLocalInt(oPC, "DelayedDamageHB");
	//:: Factotum
	DeleteLocalInt(oPC, "InspirationHB");
	
    // Feats
    DeleteLocalInt(oPC, "ForceOfPersonalityWis");
    DeleteLocalInt(oPC, "ForceOfPersonalityCha");
    DeleteLocalInt(oPC, "InsightfulReflexesInt");
    DeleteLocalInt(oPC, "InsightfulReflexesDex");
    DeleteLocalInt(oSkin, "TactileTrapsmithSearchIncrease");
    DeleteLocalInt(oSkin, "TactileTrapsmithDisableIncrease");
    DeleteLocalInt(oSkin, "TactileTrapsmithSearchDecrease");
    DeleteLocalInt(oSkin, "TactileTrapsmithDisableDecrease");

    // Warmind
    DeleteLocalInt(oSkin, "EnduringBody");

    // Ironmind
    DeleteLocalInt(oSkin, "IronMind_DR");

    // Suel Archanamach
    DeleteLocalInt(oSkin, "SuelArchanamachSpellFailure");

    // Favoured Soul
    DeleteLocalInt(oSkin, "FavouredSoulResistElementAcid");
    DeleteLocalInt(oSkin, "FavouredSoulResistElementCold");
    DeleteLocalInt(oSkin, "FavouredSoulResistElementElec");
    DeleteLocalInt(oSkin, "FavouredSoulResistElementFire");
    DeleteLocalInt(oSkin, "FavouredSoulResistElementSonic");
    DeleteLocalInt(oSkin, "FavouredSoulDR");

    // Domains
    DeleteLocalInt(oSkin, "StormDomainPower");

    // Skullclan Hunter
    DeleteLocalInt(oSkin, "SkullClanFear");
    DeleteLocalInt(oSkin, "SkullClanDisease");
    DeleteLocalInt(oSkin, "SkullClanProtectionEvil");
    DeleteLocalInt(oSkin, "SkullClanSwordLight");
    DeleteLocalInt(oSkin, "SkullClanParalysis");
    DeleteLocalInt(oSkin, "SkullClanAbilityDrain");
    DeleteLocalInt(oSkin, "SkullClanLevelDrain");

    // Sohei
    DeleteLocalInt(oSkin, "SoheiDamageResist");

    // Dragon Disciple
    DeleteLocalInt(oPC, "DragonDiscipleBreathWeaponUses");
    
    //Dragon Shaman
    DeleteLocalInt(oPC, "DragonShamanTotem");

    //Warblade
    DeleteLocalInt(oSkin, "PRC_WEAPON_APTITUDE_APPLIED");

    //Shifter(PnP)
    DeleteLocalInt(oSkin, "PRC_SHIFTER_TEMPLATE_APPLIED");

    DeleteLocalInt(oPC, "ScoutFreeMove");
    DeleteLocalInt(oPC, "ScoutFastMove");
    DeleteLocalInt(oPC, "ScoutBlindsight");

    //Truenamer
    // Called elsewhere now
    /*int UtterID;
    for(UtterID = 3526; UtterID <= 3639; UtterID++) // All utterances
        DeleteLocalInt(oPC, "PRC_LawOfResistance" + IntToString(UtterID));
    for(UtterID = 3418; UtterID <= 3431; UtterID++) // Syllable of Detachment to Word of Heaven, Greater
        DeleteLocalInt(oPC, "PRC_LawOfResistance" + IntToString(UtterID));*/

    //Invocations
    DeleteLocalInt(oPC, "ChillingFogLock");
    //Endure Exposure wearing off
    array_delete(oPC, "BreathProtected");
    DeleteLocalInt(oPC, "DragonWard");

    //Scry on Familiar
    DeleteLocalInt(oPC, "Scry_Familiar");
    
    // Undead HD
    DeleteLocalInt(oPC, "PRCUndeadHD");
    DeleteLocalInt(oPC, "PRCUndeadFSPen");

    //Template Spell-Like Abilities
    DelayCommand(0.5f, TemplateSLAs(oPC));

    // future PRCs Go below here
}

void ScrubPCSkin(object oPC, object oSkin)
{
    int nGeneration = PRC_NextGeneration(GetLocalInt(oPC, PRC_ScrubPCSkin_Generation));
    if (DEBUG > 1) DoDebug("ScrubPCSkin Generation: " + IntToString(nGeneration));
    SetLocalInt(oPC, PRC_ScrubPCSkin_Generation, nGeneration);

    int iCode = GetHasFeat(FEAT_SF_CODE,oPC);
    int ipType, st;
    if(!(/*GetIsPolyMorphedOrShifted(oPC) || */GetIsObjectValid(GetMaster(oPC))))
    {
        itemproperty ip = GetFirstItemProperty(oSkin);
        while(GetIsItemPropertyValid(ip))
        {
            // Insert Logic here to determine if we spare a property
            ipType = GetItemPropertyType(ip);
            if(ipType == ITEM_PROPERTY_BONUS_FEAT)
            {
                // Check for specific Bonus Feats
                // Reference iprp_feats.2da
                st = GetItemPropertySubType(ip);

                // Spare 400 through 570 and 398 -- epic spells & spell effects
                //also spare the new spellbook feats (1000-12000 & 17701-24704
                //also spare the psionic, trunaming, tob, invocation feats (12000-16000)
                // spare template, tob stuff (16300-17700)
                // changed by fluffyamoeba so that iprp weapon specialization, dev crit, epic weapon focus, epic weapon spec
                // overwhelming crit and weapon of choice are no longer skipped.
                if ((st < 400 || st > 570)
				&& st != 102 //:: ACP Feats
				&& st != 586 //:: ACP Feats
				&& st != 587 //:: ACP Feats
                && st != 398
                && (st < 1000 || st > 13520)
                //&& (st < 1000 || st > 13999)
                //&& (st < 14501 || st > 15999)
                && (st < 16300 || st > 24704)
                && (st < 223 || st > 226)         // draconic feats
                && (st < 229 || st > 249)         // Pnp spellschool feats and PRC options feat (231-249 & 229)
                && st != 259                      // 259 - psionic focus
                && (st < 141 || st > 200)         // 141 - shadowmaster shades, 142-151 bonus domains casting feats, 152 - 200 bonus domain powers
				&& st != 26000			         // Bullybasher Giant Bearing
                && ( (st == IP_CONST_FEAT_PRC_POWER_ATTACK_QUICKS_RADIAL || 
                      st == IP_CONST_FEAT_POWER_ATTACK_SINGLE_RADIAL || 
                      st == IP_CONST_FEAT_POWER_ATTACK_FIVES_RADIAL) ? // Remove the PRC Power Attack radials if the character no longer has Power Attack
                     !GetHasFeat(FEAT_POWER_ATTACK, oPC) :
                     TRUE // If the feat is not relevant to this clause, always pass
                    )
                )
                    RemoveItemProperty(oSkin, ip);
            }
            else if(ipType == ITEM_PROPERTY_BONUS_SPELL_SLOT_OF_LEVEL_N)
            {
                //bonus spellslots code here
                //st = GetItemPropertySubType(ip);
                RemoveItemProperty(oSkin, ip);
            }
            else
                RemoveItemProperty(oSkin, ip);

            // Get the next property
            ip = GetNextItemProperty(oSkin);
        }
    }
    if(iCode)
      AddItemProperty(DURATION_TYPE_PERMANENT,PRCItemPropertyBonusFeat(381),oSkin);

    // Schedule restoring the unhealable ability damage
    DelayCommand(0.1f, DelayedReApplyUnhealableAbilityDamage(nGeneration, oPC));

    // Remove all natural weapons too
    // ClearNaturalWeapons(oPC);
    // Done this way to remove prc_inc_natweap and prc_inc_combat from the include
    // Should help with compile speeds and the like
    //array_delete(oPC, "ARRAY_NAT_SEC_WEAP_RESREF");
    //array_delete(oPC, "ARRAY_NAT_PRI_WEAP_RESREF");
    //array_delete(oPC, "ARRAY_NAT_PRI_WEAP_ATTACKS");
}

int BlastInfidelOrFaithHeal(object oCaster, object oTarget, int iEnergyType, int iDisplayFeedback)
{
    //Don't bother doing anything if iEnergyType isn't either positive/negative energy
    if(iEnergyType != DAMAGE_TYPE_POSITIVE && iEnergyType != DAMAGE_TYPE_NEGATIVE)
        return FALSE;

    //If the target is undead and damage type is negative
    //or if the target is living and damage type is positive
    //then we're healing.  Otherwise, we're harming.
    int iTombTainted = GetHasFeat(FEAT_TOMB_TAINTED_SOUL, oTarget) && GetAlignmentGoodEvil(oTarget) != ALIGNMENT_GOOD;
    int iHeal = ( iEnergyType == DAMAGE_TYPE_NEGATIVE && (MyPRCGetRacialType(oTarget) == RACIAL_TYPE_UNDEAD || iTombTainted)) ||
                ( iEnergyType == DAMAGE_TYPE_POSITIVE && MyPRCGetRacialType(oTarget) != RACIAL_TYPE_UNDEAD && !iTombTainted);
    int iRetVal = FALSE;
    int iAlignDif = CompareAlignment(oCaster, oTarget);
    string sFeedback = "";

    if(iHeal){
        if((GetHasFeat(FEAT_FAITH_HEALING, oCaster) && iAlignDif < 2)){
            iRetVal = TRUE;
            sFeedback = "Faith Healing";
        }
    }
    else{
        if((GetHasFeat(FEAT_BLAST_INFIDEL, oCaster) && iAlignDif >= 2)){
            iRetVal = TRUE;
            sFeedback = "Blast Infidel";
        }
    }

    if(iDisplayFeedback) FloatingTextStringOnCreature(sFeedback, oCaster);
    return iRetVal;
}

int GetShiftingFeats(object oPC)
{
    int nNumFeats;
    nNumFeats = GetHasFeat(FEAT_BEASTHIDE_ELITE, oPC)
              + GetHasFeat(FEAT_DREAMSIGHT_ELITE, oPC)
              + GetHasFeat(FEAT_GOREBRUTE_ELITE, oPC)
              + GetHasFeat(FEAT_LONGSTRIDE_ELITE, oPC)
              + GetHasFeat(FEAT_LONGTOOTH_ELITE, oPC)
              + GetHasFeat(FEAT_RAZORCLAW_ELITE, oPC)
              + GetHasFeat(FEAT_WILDHUNT_ELITE, oPC)
              + GetHasFeat(FEAT_EXTRA_SHIFTER_TRAIT, oPC)
              + GetHasFeat(FEAT_HEALING_FACTOR, oPC)
              + GetHasFeat(FEAT_SHIFTER_AGILITY, oPC)
              + GetHasFeat(FEAT_SHIFTER_DEFENSE, oPC)
              + GetHasFeat(FEAT_GREATER_SHIFTER_DEFENSE, oPC)
              + GetHasFeat(FEAT_SHIFTER_FEROCITY, oPC)
              + GetHasFeat(FEAT_SHIFTER_INSTINCTS, oPC)
              + GetHasFeat(FEAT_SHIFTER_SAVAGERY, oPC);

     return nNumFeats;
}

//Including DelayedApplyEffectToObject here because it is often used in conjunction with EvalPRCFeats and I don't know a better place to put it
void DelayedApplyEffectToObject(int nExpectedGeneration, int nCurrentGeneration, int nDuration, effect eEffect, object oTarget, float fDuration)
{
    if (nExpectedGeneration != nCurrentGeneration)
    {
        //Generation has changed, so don't apply the effect
        return;
    }
    ApplyEffectToObject(nDuration, eEffect, oTarget, fDuration);
}

//Including DelayedApplyEffectToObject here because it is often used in conjunction with EvalPRCFeats and I don't know a better place to put it
void DelayApplyEffectToObject(float fDelay, string sGenerationName, int nDuration, effect eEffect, object oTarget, float fDuration = 0.0f)
{
    /*
    There are a couple of problems that can arise in code that removes and reapplies effects; 
    this function helps deal with those problems. One example of a typical place where these problems 
    frequently arise is in the class scripts called by the EvalPRCFeats function.

    The first problem is that when code removes and immediately reapplies a series of effects,
    some of those effects may not actually be reapplied. This is because the RemoveEffect() function 
    doesn't actually remove an effect, it marks it to be removed later--when the currently running 
    script finishes. If any of the effects we reapply matches one of the effects marked to be
    removed, that reapplied effect will be removed when the currently running script finishes
    and so will be unexpectedly missing. To illustrate:
        1) We start with effect A and B.
        2) The application function is called; it removes all effects and reapplies effects B and C.
        3) The actual removal happens when the script ends: effect A and B are removed.
        End result: we have only effect C instead of the expected B and C.
    The solution to this is to reapply the effects later using DelayCommand().
    
    This introduces a new problem. If the function that removes and reapplies the effects is called
    multiple times quickly, it can queue up a series of delayed applications. This causes two problems:
    if the data on which the effects are calculated changes, the earlier delayed applications can
    apply effects that should no longer be used, but they are anyway because the delayed code doesn't
    know this. To illustrate:
        1) The application function is called; it removes all effects, schedules delayed application of effect A.
        2) The application function is called again; it removes all effects, schedules delayed application of effect B.
        3) Delayed application of effect A occurs.
        4) Delayed application of effect B occurs.
        End result: we have both effect A and B instead of the expected result, B alone.
    Another problem is that we can end up with multiple copies of the same effect.
    If this happens enough, it can cause "Effect List overflow" errors. Also, if the effect stacks
    with itself, this gives a greater bonus or penalty than it should. To illustrate:
        1) The application function is called; it removes all effects, schedules delayed application of effect C.
        2) The application function is called; it removes all effects, schedules delayed application of effect C.
        3) Delayed application of effect C occurs.
        4) Delayed application of effect C occurs.
        End result: we have effect C twice instead of just once.
    The solution is to both these problems is for the application function to increment an integer each time it
    is called and to pass this to the delayed application function. The delayed application actually happens only
    if the generation when it runs is the same as the generation when it was scheduled. To illustrate:
        1) We start with effect A and B applied.
        2) The application function is called: it increments generation to 2, schedules delayed application of effect B and C.
        3) The application function is called: it increments generation to 3, schedules delayed application of effect C.
        4) The generation 2 delayed application function executes: it sees that the current generation is 3 and simply exits, doing nothing.
        5) The generation 3 delayed application function executes: it sees that the current generation is 3, so it applies effect C.
        End result: we have one copy of effect C, which is what we wanted.
    */

    if (fDelay < 0.0f || GetStringLength(sGenerationName) == 0)
    {
        ApplyEffectToObject(nDuration, eEffect, oTarget, fDuration);
    }
    else
    {
        int nExpectedGeneration = GetLocalInt(oTarget, sGenerationName); //This gets the generation now
        DelayCommand(
            fDelay, 
            DelayedApplyEffectToObject(
                nExpectedGeneration, 
                GetLocalInt(oTarget, sGenerationName), //This is delayed by the DelayCommand, so it gets the generation when DelayedApplyEffectToObject is actually executed
                nDuration, 
                eEffect,
                oTarget,
                fDuration
            )
        );
    }
}

//Including DelayedAddItemProperty here to keep it with DelayedApplyEffectToObject, though more properly it should probably be in inc_item_props.nss
void DelayedAddItemProperty(int nExpectedGeneration, int nCurrentGeneration, int nDurationType, itemproperty ipProperty, object oItem, float fDuration)
{
    if (nExpectedGeneration != nCurrentGeneration)
    {
        //Generation has changed, so don't apply the effect
        return;
    }
    AddItemProperty(nDurationType, ipProperty, oItem, fDuration);
}

//Including DelayAddItemProperty here to keep it with DelayApplyEffectToObject, though more properly it should probably be in inc_item_props.nss
void DelayAddItemProperty(float fDelay, object oGenerationHolder, string sGenerationName, int nDurationType, itemproperty ipProperty, object oItem, float fDuration = 0.0f)
{
    /*
    There are a couple of problems that can arise in code that removes and reapplies item properties;
    this function helps deal with those problems. One example of a typical place where these problems 
    frequently arise is in the class scripts called by the EvalPRCFeats function.

    The first problem is that when code removes and immediately reapplies a series of item properties,
    some of those properties may not actually be reapplied. This is because the RemoveItemProperty() function 
    doesn't actually remove a property, it marks it to be removed later--when the currently running 
    script finishes. If any of the properties we reapply matches one of the properties marked to be
    removed, that reapplied property will be removed when the currently running script finishes
    and so will be unexpectedly missing. To illustrate:
        1) We start with properties A and B.
        2) The application function is called; it removes all properties and reapplies properties B and C.
        3) The actual removal happens when the script ends: property A and B are removed.
        End result: we have only property C instead of the expected B and C.
    The solution to this is to reapply the properties later using DelayCommand().
    
    This introduces a new problem. If the function that removes and reapplies the properties is called
    multiple times quickly, it can queue up a series of delayed applications. This causes two problems:
    if the data on which the properties are calculated changes, the earlier delayed applications can
    apply properties that should no longer be used, but they are anyway because the delayed code doesn't
    know this. To illustrate:
        1) The application function is called; it removes all properties, schedules delayed application of property A.
        2) The application function is called again; it removes all properties, schedules delayed application of property B.
        3) Delayed application of property A occurs.
        4) Delayed application of property B occurs.
        End result: we have both property A and B instead of the expected result, B alone.
    Another problem is that we can end up with multiple copies of the same property.
    If this happens enough, it can cause "Effect List overflow" errors. Also, if the property stacks
    with itself, this gives a greater bonus or penalty than it should. To illustrate:
        1) The application function is called; it removes all properties, schedules delayed application of property C.
        2) The application function is called; it removes all properties, schedules delayed application of property C.
        3) Delayed application of property C occurs.
        4) Delayed application of property C occurs.
        End result: we have property C twice instead of just once.
    The solution is to both these problems is for the application function to increment an integer each time it
    is called and to pass this to the delayed application function. The delayed application actually happens only
    if the generation when it runs is the same as the generation when it was scheduled. To illustrate:
        1) We start with property A and B applied.
        2) The application function is called: it increments generation to 2, schedules delayed application of property B and C.
        3) The application function is called: it increments generation to 3, schedules delayed application of property C.
        4) The generation 2 delayed application function executes: it sees that the current generation is 3 and simply exits, doing nothing.
        5) The generation 3 delayed application function executes: it sees that the current generation is 3, so it applies property C.
        End result: we have one copy of property C, which is what we wanted.
    */
    
    if (fDelay < 0.0f || GetStringLength(sGenerationName) == 0)
    {
        AddItemProperty(nDurationType, ipProperty, oItem, fDuration);
    }
    else
    {
        int nExpectedGeneration = GetLocalInt(oGenerationHolder, sGenerationName); //This gets the generation now
        DelayCommand(
            fDelay, 
            DelayedAddItemProperty(
                nExpectedGeneration, 
                GetLocalInt(oGenerationHolder, sGenerationName), //This is delayed by the DelayCommand, so it gets the generation when DelayedAddItemProperty is actually executed
                nDurationType, 
                ipProperty,
                oItem,
                fDuration
            )
        );
    }
}

/**
 * @brief Sets the number of remaining uses per day for a feat based on an ability modifier.
 *
 * This function calculates the number of daily uses for a feat (`iFeat`) that a creature (`oPC`)
 * possesses, based on their ability modifier (default: Charisma). It first removes any existing
 * remaining uses and then reassigns the number based on the effective modifier.
 *
 * @param oPC The creature object for whom the feat usage is being set.
 * @param iFeat The feat constant (e.g., FEAT_WHATEVER) to set uses for.
 * @param iAbiMod (Optional) The ability score to base the uses on (e.g., ABILITY_CHARISMA).
 *                Use -1 to ignore ability modifiers. Defaults to ABILITY_CHARISMA.
 * @param iMod (Optional) A flat modifier to add to the calculated ability modifier. Default is 0.
 * @param iMin (Optional) The minimum number of uses to allow (even if the ability modifier is low). Default is 1.
 *
 * @note
 * If the creature does not have the feat, no changes are made.
 * If the ability modifier is negative or zero, it is treated as zero.
 * If `iAbiMod` is -1, the ability modifier is ignored and `iMod` alone is used.
 * The final number of uses will never be below `iMin`.
 *
 * @see GetAbilityModifier()
 * @see GetHasFeat()
 * @see DecrementRemainingFeatUses()
 * @see IncrementRemainingFeatUses()
 */
void FeatUsePerDay(object oPC, int iFeat, int iAbiMod = ABILITY_CHARISMA, int iMod = 0, int iMin = 1)
{
    if(!GetHasFeat(iFeat,oPC))
        return;

    int iAbi = GetAbilityModifier(iAbiMod, oPC);
    iAbi = (iAbi > 0) ? iAbi : 0;

    if (iAbiMod == -1) iAbi = 0;
    iAbi += iMod;

    if(iAbi < iMin)
        iAbi = iMin;

    while(GetHasFeat(iFeat, oPC))
        DecrementRemainingFeatUses(oPC, iFeat);

    while(iAbi)
    {
        IncrementRemainingFeatUses(oPC, iFeat);
        iAbi--;
    }
}

void DomainUses(object oPC)
{
    int nUses;
    if(!GetHasFeat(FEAT_BONUS_DOMAIN_STRENGTH, oPC) || PRC_Funcs_GetFeatKnown(oPC, FEAT_STRENGTH_DOMAIN_POWER))
    {
        nUses = GetLevelByClass(CLASS_TYPE_MIGHTY_CONTENDER_KORD, oPC) ? GetAbilityModifier(ABILITY_STRENGTH, oPC) : 1;
        FeatUsePerDay(oPC, FEAT_STRENGTH_DOMAIN_POWER, -1, nUses);
    }
    if(GetHasFeat(FEAT_BONUS_DOMAIN_SUN, oPC) && GetLevelByClass(CLASS_TYPE_MYSTIC, oPC) && PRC_Funcs_GetFeatKnown(oPC, FEAT_SUN_DOMAIN_POWER))
    {
        nUses = GetHasFeat(FEAT_EXTRA_TURNING, oPC) ? 7 : 3;
        FeatUsePerDay(oPC, FEAT_SUN_DOMAIN_POWER, ABILITY_CHARISMA, nUses);
    }
    else if(!GetHasFeat(FEAT_BONUS_DOMAIN_SUN, oPC) || PRC_Funcs_GetFeatKnown(oPC, FEAT_SUN_DOMAIN_POWER))
        FeatUsePerDay(oPC, FEAT_SUN_DOMAIN_POWER, -1, 1);

    if(!GetHasFeat(FEAT_BONUS_DOMAIN_BLIGHTBRINGER, oPC) || PRC_Funcs_GetFeatKnown(oPC, FEAT_DOMAIN_POWER_BLIGHTBRINGER))
        FeatUsePerDay(oPC, FEAT_DOMAIN_POWER_BLIGHTBRINGER, ABILITY_CHARISMA, 3);
    if(!GetHasFeat(FEAT_BONUS_DOMAIN_AIR, oPC) || PRC_Funcs_GetFeatKnown(oPC, FEAT_AIR_DOMAIN_POWER))
        FeatUsePerDay(oPC, FEAT_AIR_DOMAIN_POWER, ABILITY_CHARISMA, 3);
    if(!GetHasFeat(FEAT_BONUS_DOMAIN_EARTH, oPC) || PRC_Funcs_GetFeatKnown(oPC, FEAT_EARTH_DOMAIN_POWER))
        FeatUsePerDay(oPC, FEAT_EARTH_DOMAIN_POWER, ABILITY_CHARISMA, 3);
    if(!GetHasFeat(FEAT_BONUS_DOMAIN_FIRE, oPC) || PRC_Funcs_GetFeatKnown(oPC, FEAT_FIRE_DOMAIN_POWER))
        FeatUsePerDay(oPC, FEAT_FIRE_DOMAIN_POWER, ABILITY_CHARISMA, 3);
    if(!GetHasFeat(FEAT_BONUS_DOMAIN_WATER, oPC) || PRC_Funcs_GetFeatKnown(oPC, FEAT_WATER_DOMAIN_POWER))
        FeatUsePerDay(oPC, FEAT_WATER_DOMAIN_POWER, ABILITY_CHARISMA, 3);
    if(!GetHasFeat(FEAT_BONUS_DOMAIN_SLIME, oPC) || PRC_Funcs_GetFeatKnown(oPC, FEAT_DOMAIN_POWER_SLIME))
        FeatUsePerDay(oPC, FEAT_DOMAIN_POWER_SLIME, ABILITY_CHARISMA, 3);
    if(!GetHasFeat(FEAT_BONUS_DOMAIN_SPIDER, oPC) || PRC_Funcs_GetFeatKnown(oPC, FEAT_DOMAIN_POWER_SPIDER))
        FeatUsePerDay(oPC, FEAT_DOMAIN_POWER_SPIDER, ABILITY_CHARISMA, 3);
    if(!GetHasFeat(FEAT_BONUS_DOMAIN_SCALEYKIND, oPC) || PRC_Funcs_GetFeatKnown(oPC, FEAT_DOMAIN_POWER_SCALEYKIND))
        FeatUsePerDay(oPC, FEAT_DOMAIN_POWER_SCALEYKIND, ABILITY_CHARISMA, 3);
    if(!GetHasFeat(FEAT_BONUS_DOMAIN_PLANT, oPC) || PRC_Funcs_GetFeatKnown(oPC, FEAT_PLANT_DOMAIN_POWER))
        FeatUsePerDay(oPC, FEAT_PLANT_DOMAIN_POWER, ABILITY_CHARISMA, 3);	
	if(!GetHasFeat(FEAT_BONUS_DOMAIN_MADNESS, oPC) || PRC_Funcs_GetFeatKnown(oPC, FEAT_DOMAIN_POWER_MADNESS))
        FeatUsePerDay(oPC, FEAT_DOMAIN_POWER_MADNESS, ABILITY_CHARISMA, 3);
	if(!GetHasFeat(FEAT_BONUS_DOMAIN_MOON, oPC) || PRC_Funcs_GetFeatKnown(oPC, FEAT_DOMAIN_POWER_MOON))
        FeatUsePerDay(oPC, FEAT_DOMAIN_POWER_MOON, ABILITY_CHARISMA, 3);	
}

void HathranFear(object oPC)
{
 	if(!GetHasFeat(FEAT_HATH_FEAR1, oPC))
		return; 

	int nLevel = GetLevelByClass(CLASS_TYPE_HATHRAN, oPC);
    int nUses = 0;

    // Base uses based on progression
    if (nLevel >= 8)
    {
        nUses = 3;
    }
    else if (nLevel >= 6)
    {
        nUses = 2;
    }
    else if (nLevel >= 3)
    {
        nUses = 1;
    }

    // Add +1 per 3 levels gained above 9
    if (nLevel > 9)
    {
        int nBonusLevels = nLevel - 9;
        nUses += nBonusLevels / 3;
    }
	
	FeatUsePerDay(oPC, FEAT_HATH_FEAR1, -1, nUses);

}


void MephlingBreath(object oPC)  //:: Mephlings
{	
	if(!GetHasFeat(FEAT_MEPHLING_BREATH, oPC)) 
		return;    
	
	int nMephBreath = ((1 + GetHitDice(oPC)) / 4);
	
    FeatUsePerDay(oPC, FEAT_MEPHLING_BREATH, -1, nMephBreath);	
}

void FeatAlaghar(object oPC)
{
    int iAlagharLevel = GetLevelByClass(CLASS_TYPE_ALAGHAR, oPC);

    if (!iAlagharLevel) return;

    int iClangStrike = iAlagharLevel/3;
    int iClangMight = (iAlagharLevel - 1)/3;
    int iRockburst = (iAlagharLevel + 2)/4;

    FeatUsePerDay(oPC, FEAT_CLANGEDDINS_STRIKE, -1, iClangStrike);
    FeatUsePerDay(oPC, FEAT_CLANGEDDINS_MIGHT, -1, iClangMight);
    FeatUsePerDay(oPC, FEAT_ALAG_ROCKBURST, -1, iRockburst);
}

void FeatDiabolist(object oPC)
{
   int Diabol = GetLevelByClass(CLASS_TYPE_DIABOLIST, oPC);

   if (!Diabol) return;

   int iUse = (Diabol + 3)/3;

   FeatUsePerDay(oPC,FEAT_DIABOL_DIABOLISM_1,-1,iUse);
   FeatUsePerDay(oPC,FEAT_DIABOL_DIABOLISM_2,-1,iUse);
   FeatUsePerDay(oPC,FEAT_DIABOL_DIABOLISM_3,-1,iUse);
}

void FeatNinja (object oPC)
{
    int iNinjaLevel = GetLevelByClass(CLASS_TYPE_NINJA, oPC);
    // Ascetic Stalker
    if (GetHasFeat(FEAT_ASCETIC_STALKER, oPC))
        iNinjaLevel += GetLevelByClass(CLASS_TYPE_MONK, oPC);   

    // Martial Stalker
    if (GetHasFeat(FEAT_MARTIAL_STALKER, oPC))
        iNinjaLevel += GetLevelByClass(CLASS_TYPE_FIGHTER, oPC);   

    if (!iNinjaLevel) return;

    int nUsesLeft = iNinjaLevel / 2;
    if (nUsesLeft < 1)
        nUsesLeft = 1;
        
    // Expanded Ki Pool    
    if (GetHasFeat(FEAT_EXPANDED_KI_POOL, oPC)) nUsesLeft += 3;

    FeatUsePerDay(oPC, FEAT_KI_POWER, ABILITY_WISDOM, nUsesLeft);
    FeatUsePerDay(oPC, FEAT_GHOST_STEP, ABILITY_WISDOM, nUsesLeft);
    FeatUsePerDay(oPC, FEAT_GHOST_STRIKE, ABILITY_WISDOM, nUsesLeft);
    FeatUsePerDay(oPC, FEAT_GHOST_WALK, ABILITY_WISDOM, nUsesLeft);
    FeatUsePerDay(oPC, FEAT_KI_DODGE, ABILITY_WISDOM, nUsesLeft);

    SetLocalInt(oPC, "prc_ninja_ki", nUsesLeft);
}

void DrowJudicator(object oPC)
{
    int iJudicator = GetLevelByClass(CLASS_TYPE_JUDICATOR, oPC);
	
    if (iJudicator < 1) return;
	
    int nUses = 3; // base 3 uses at 10th level

    if (iJudicator > 10)
    {
        nUses += (iJudicator - 10) / 3; // +1 use per 3 levels above 10
    }
	
    FeatUsePerDay(oPC, FEAT_SELVETARMS_WRATH, -1, nUses);
}

void Oozemaster(object oPC)
{
    if (GetLevelByClass(CLASS_TYPE_OOZEMASTER, oPC) < 10) return;

    int iOozeLvl = GetLevelByClass(CLASS_TYPE_OOZEMASTER, oPC);
    int nUses = 5; // base 5 uses at 10th level

    if (iOozeLvl > 10)
    {
        nUses += (iOozeLvl - 10) / 2; // +1 use per 2 levels above 10
    }
	
    FeatUsePerDay(oPC, FEAT_OOZY_GLOB5, -1, nUses);
}

/* void Oozemaster(object oPC)
{
    if (GetLevelByClass(CLASS_TYPE_OOZEMASTER, oPC) < 4) return;

    int iOozeLvl = GetLevelByClass(CLASS_TYPE_OOZEMASTER, oPC);
    int nUses = 2 + 2 * ((iOozeLvl - 4) / 3);
	
	FeatUsePerDay(oPC, FEAT_OOZY_GLOB5, -1, nUses);    
} */

void EyeOfGruumsh(object oPC)
{
    if (GetLevelByClass(CLASS_TYPE_PRC_EYE_OF_GRUUMSH, oPC) < 4) return;

    int iEOGLevel = GetLevelByClass(CLASS_TYPE_PRC_EYE_OF_GRUUMSH, oPC);
    int nUses = 2 + 2 * ((iEOGLevel - 4) / 3);
	
	FeatUsePerDay(oPC, FEAT_BLINDING_SPITTLE, -1, nUses);    
}

void BarbarianRage(object oPC)
{
    if(!GetHasFeat(FEAT_BARBARIAN_RAGE, oPC)) return;

    int nUses = (GetLevelByClass(CLASS_TYPE_BARBARIAN, oPC) + GetLevelByClass(CLASS_TYPE_BLACK_BLOOD_CULTIST, oPC) + GetLevelByClass(CLASS_TYPE_PRC_EYE_OF_GRUUMSH, oPC)) / 4 + 1;
		nUses += (GetLevelByClass(CLASS_TYPE_RAGE_MAGE, oPC) + 2) / 5;
		nUses += (GetLevelByClass(CLASS_TYPE_BATTLERAGER, oPC) + 1) / 2;
		nUses += (GetLevelByClass(CLASS_TYPE_CELEBRANT_SHARESS, oPC) + 2) / 4;
		nUses += GetLevelByClass(CLASS_TYPE_RUNESCARRED, oPC) ? ((GetLevelByClass(CLASS_TYPE_RUNESCARRED, oPC) / 4) + 1) : 0;
		nUses += (GetLevelByClass(CLASS_TYPE_TOTEM_RAGER, oPC) + 4) / 6;	

    if(GetHasFeat(FEAT_EXTRA_RAGE, oPC)) nUses += 2;

    FeatUsePerDay(oPC, FEAT_BARBARIAN_RAGE, -1, nUses);
    FeatUsePerDay(oPC, FEAT_GREATER_RAGE, -1, nUses);

	int nLevel = GetLevelByClass(CLASS_TYPE_RAGE_MAGE, oPC);
	if (nLevel > 0)
	{
		// Spell Rage: starts at 1st level, +1 use every 5 Rage Mage levels
		int nUses = 1 + (nLevel / 5);

		FeatUsePerDay(oPC, FEAT_SPELL_RAGE, -1, nUses);
	}
/*     if(GetLevelByClass(CLASS_TYPE_RAGE_MAGE, oPC) > 0)
    {
        if(GetLevelByClass(CLASS_TYPE_RAGE_MAGE, oPC) > 9)
            nUses = 3;
        else if(GetLevelByClass(CLASS_TYPE_RAGE_MAGE, oPC) > 4)
            nUses = 2;
        else
            nUses = 1;

        FeatUsePerDay(oPC, FEAT_SPELL_RAGE, -1, nUses);
    } */
}

void BardSong(object oPC)
{
    // This is used to set the number of bardic song uses per day, as bardic PrCs can increase it
    // or other classes can grant it on their own
    if(!GetHasFeat(FEAT_BARD_SONGS, oPC)) return;

    int nTotal = GetLevelByClass(CLASS_TYPE_BARD, oPC);
		nTotal += GetLevelByClass(CLASS_TYPE_DIRGESINGER, oPC);
		nTotal += GetLevelByClass(CLASS_TYPE_VIRTUOSO, oPC);
		nTotal += GetLevelByClass(CLASS_TYPE_FOCHLUCAN_LYRIST, oPC);
		nTotal += GetLevelByClass(CLASS_TYPE_SUBLIME_CHORD, oPC) / 2;

    if(GetHasFeat(FEAT_EXTRA_MUSIC, oPC)) nTotal += 4;

    FeatUsePerDay(oPC, FEAT_BARD_SONGS, -1, nTotal);
}

void FeatVirtuoso(object oPC)
{
    int iVirtuosoLevel = GetLevelByClass(CLASS_TYPE_VIRTUOSO, oPC);
    if (!iVirtuosoLevel) return;

    int nUses = GetLevelByClass(CLASS_TYPE_BARD, oPC) + iVirtuosoLevel;
    if(GetHasFeat(FEAT_EXTRA_MUSIC, oPC)) nUses += 4;
    SetPersistantLocalInt(oPC, "Virtuoso_Performance_Uses", nUses);
    int nFeat;
    for(nFeat = FEAT_VIRTUOSO_SUSTAINING_SONG; nFeat <= FEAT_VIRTUOSO_PERFORMANCE; nFeat++)
    {
        FeatUsePerDay(oPC, nFeat, -1, nUses);
    }
}

void HexCurse(object oPC)
{
    int iHexLevel = GetLevelByClass(CLASS_TYPE_HEXBLADE, oPC);

    if (!iHexLevel) return;

    //Hexblade's Curse
    int nUses = (iHexLevel + 3) / 4; // every 4 levels get 1 more use
    FeatUsePerDay(oPC, FEAT_HEXCURSE, ABILITY_CHARISMA, nUses);

    //Swift Cast
    if(iHexLevel > 13)
        nUses = (iHexLevel + 2) / 4;
    else if(iHexLevel > 10)
        nUses = 3;
    else if(iHexLevel > 7)
        nUses = 2;
    else if(iHexLevel > 5)
        nUses = 1;
    else
        nUses = 0;
    FeatUsePerDay(oPC, FEAT_SWIFT_CAST, -1, nUses);
}

void FeatShadowblade(object oPC)
{
    int iShadowLevel = GetLevelByClass(CLASS_TYPE_SHADOWBLADE, oPC);
    if (!iShadowLevel) return;

    FeatUsePerDay(oPC, FEAT_UNERRING_STRIKE, -1, iShadowLevel);
    FeatUsePerDay(oPC, FEAT_UNEXPECTED_STRIKE, -1, iShadowLevel);
    FeatUsePerDay(oPC, FEAT_EPHEMERAL_WEAPON, -1, iShadowLevel);
    FeatUsePerDay(oPC, FEAT_SHADOWY_STRIKE, -1, iShadowLevel);
    FeatUsePerDay(oPC, FEAT_FAR_SHADOW, -1, iShadowLevel);
}

void FeatIronMind(object oPC)
{
    int iIronmindLvl = GetLevelByClass(CLASS_TYPE_IRONMIND, oPC);
    if (iIronmindLvl <= 0) return;

    int nBonus;

    // Armoured Mind: starts at level 1
    if (iIronmindLvl >= 1)
    {
        nBonus = 1 + (iIronmindLvl - 1) / 3;
        FeatUsePerDay(oPC, FEAT_ARMOURED_MIND, -1, nBonus);
    }

    // Mind Over Body: starts at level 3
    if (iIronmindLvl >= 3)
    {
        nBonus = 1 + (iIronmindLvl - 3) / 3;
        FeatUsePerDay(oPC, FEAT_MIND_OVER_BODY, -1, nBonus);
    }
}

void FeatNoble(object oPC)
{
    int iNobleLevel = GetLevelByClass(CLASS_TYPE_NOBLE, oPC);
    if (!iNobleLevel) return;

    int nBonus = 0;
    if (iNobleLevel >= 17) nBonus = 5;
    else if (iNobleLevel >= 13) nBonus = 4;
    else if (iNobleLevel >= 9) nBonus = 3;
    else if (iNobleLevel >= 5) nBonus = 2;
    else if (iNobleLevel >= 2) nBonus = 1;

    FeatUsePerDay(oPC, FEAT_NOBLE_CONFIDENCE, -1, nBonus);

    nBonus = (iNobleLevel - 11) / 3 + 1;

    FeatUsePerDay(oPC, FEAT_NOBLE_GREATNESS, -1, nBonus);
}

void DarkKnowledge(object oPC)
{
    int iArchivistLevel = GetLevelByClass(CLASS_TYPE_ARCHIVIST, oPC);
    if(!iArchivistLevel) return;

    int nUses = (iArchivistLevel / 3) + 3;
    FeatUsePerDay(oPC, FEAT_DK_TACTICS,       -1, nUses);
    FeatUsePerDay(oPC, FEAT_DK_PUISSANCE,     -1, nUses);
    FeatUsePerDay(oPC, FEAT_DK_FOE,           -1, nUses);
    FeatUsePerDay(oPC, FEAT_DK_DREADSECRET,   -1, nUses);
    FeatUsePerDay(oPC, FEAT_DK_FOREKNOWLEDGE, -1, nUses);
}

void FeatImbueArrow(object oPC)
{
    if(GetPRCSwitch(PRC_USE_NEW_IMBUE_ARROW))
        FeatUsePerDay(oPC, FEAT_PRESTIGE_IMBUE_ARROW, -1, 0, 0);
}

void DragonDisciple(object oPC)
{
    if(!GetHasFeat(FEAT_DRAGON_DIS_BREATH, oPC))
        return;

    //Dragon Disciples that do not possess any breath weapon
    if(GetHasFeat(FEAT_CHIANG_LUNG_DRAGON, oPC)
    || GetHasFeat(FEAT_PAN_LUNG_DRAGON, oPC)
    || GetHasFeat(FEAT_SHEN_LUNG_DRAGON, oPC)
    || GetHasFeat(FEAT_TUN_MI_LUNG_DRAGON, oPC)
    || GetHasFeat(FEAT_YU_LUNG_DRAGON, oPC))
        DecrementRemainingFeatUses(oPC, FEAT_DRAGON_DIS_BREATH);
}

void Warlock(object oPC)
{
    if(GetHasFeat(FEAT_FIENDISH_RESILIENCE, oPC))
    {
        //Add daily Uses of Fiendish Resilience for epic warlock
        if(GetHasFeat(FEAT_EPIC_FIENDISH_RESILIENCE_I, oPC))
        {
            int nFeatAmt = 0;
            int bDone = FALSE;
            while(!bDone)
            {
                if(nFeatAmt >= 9)
                    bDone = TRUE;
                else if(GetHasFeat(FEAT_EPIC_FIENDISH_RESILIENCE_II + nFeatAmt, oPC))
                    nFeatAmt++;
                else
                    bDone = TRUE;
            }
            nFeatAmt++;
            FeatUsePerDay(oPC, FEAT_FIENDISH_RESILIENCE, -1, nFeatAmt);
        }
        else
            FeatUsePerDay(oPC, FEAT_FIENDISH_RESILIENCE, -1, 1);
    }

    //Hellfire infusion
    int nCha = GetAbilityModifier(ABILITY_CHARISMA, oPC);
    FeatUsePerDay(oPC, FEAT_HELLFIRE_INFUSION, -1, nCha);

    //Eldritch Spellweave
    nCha += 3;
    FeatUsePerDay(oPC, FEAT_ELDRITCH_SPELLWEAVE, -1, nCha);
}

void KotMC(object oPC)
{
    int iKotMCLevel = GetLevelByClass(CLASS_TYPE_KNIGHT_MIDDLECIRCLE, oPC);
    if(!iKotMCLevel) return;

    int nUses = iKotMCLevel / 3;
    FeatUsePerDay(oPC, FEAT_KOTMC_TRUE_STRIKE, -1, nUses);
}

void Ravager(object oPC)
{
    int nRavager = GetLevelByClass(CLASS_TYPE_RAVAGER, oPC);	
    int nUses;

    if (nRavager < 1) return;

    if (nRavager < 4)
        nUses = 1;
    else if (nRavager < 7)
        nUses = 2;
    else if (nRavager < 11)
        nUses = 3;
    else
        nUses = 4 + ((nRavager - 11) / 5); // +1 every 5 levels after 11

    FeatUsePerDay(oPC, FEAT_PAIN_TOUCH, -1, nUses);
	
    if(!GetHasFeat(FEAT_AURA_OF_FEAR, oPC)) return;
		
	nUses = 0;
	
    if (nRavager < 5)
        nUses = 1;
    else if (nRavager < 8)
        nUses = 2;
    else if (nRavager < 12)
        nUses = 3;
    else if (nRavager < 17)
        nUses = 4;
    else
        nUses = 5 + ((nRavager - 17) / 5); // +1 every 5 levels after 17

    FeatUsePerDay(oPC, FEAT_AURA_OF_FEAR, -1, nUses);

    if(!GetHasFeat(FEAT_CRUELEST_CUT, oPC)) return;	
	
	nUses = 0;
	
    if (nRavager < 6)
        nUses = 1;
    else if (nRavager < 9)
        nUses = 2;
    else if (nRavager < 13)
        nUses = 3;
    else if (nRavager < 18)
        nUses = 4;
    else
        nUses = 5 + ((nRavager - 18) / 5); // +1 every 5 levels after 18

    FeatUsePerDay(oPC, FEAT_CRUELEST_CUT, -1, nUses);
	
    if(!GetHasFeat(FEAT_VISAGE_OF_TERROR, oPC)) return;	
	
	nUses = 0;

	nUses = 1 + ((nRavager - 10) / 5); // +1 every 5 levels after 10

    FeatUsePerDay(oPC, FEAT_VISAGE_OF_TERROR, -1, nUses);	
	
}
	

void Templar(object oPC)
{
    if(!GetHasFeat(FEAT_SECULAR_AUTHORITY, oPC)) return;

    int nTemplar = GetLevelByClass(CLASS_TYPE_TEMPLAR, oPC);
    int nUses = nTemplar + ((GetHitDice(oPC) - nTemplar) / 4);
    FeatUsePerDay(oPC, FEAT_SECULAR_AUTHORITY, -1, nUses);
}

void FeatRacial(object oPC)
{
    //Shifter bonus shifting uses
    int nRace = GetRacialType(oPC);
    if(nRace == RACIAL_TYPE_SHIFTER)
    {
        int nShiftFeats = GetShiftingFeats(oPC);
        int nBonusShiftUses = (nShiftFeats / 2) + 1;
        FeatUsePerDay(oPC, FEAT_SHIFTER_SHIFTING, -1, nBonusShiftUses);
    }
    else if(nRace == RACIAL_TYPE_FORESTLORD_ELF)
    {
        int nUses = GetHitDice(oPC) / 5 + 1;
        FeatUsePerDay(oPC, FEAT_FORESTLORD_TREEWALK, -1, nUses);
    }
}

void CombatMedic(object oPC)
{
    int iCombMed = GetLevelByClass(CLASS_TYPE_COMBAT_MEDIC, oPC);
    if(!iCombMed) return;

    FeatUsePerDay(oPC, FEAT_HEALING_KICKER_1, ABILITY_WISDOM, iCombMed);
    FeatUsePerDay(oPC, FEAT_HEALING_KICKER_2, ABILITY_WISDOM, iCombMed);
    FeatUsePerDay(oPC, FEAT_HEALING_KICKER_3, ABILITY_WISDOM, iCombMed);
}

void MasterOfShrouds(object oPC)
{
    if(!GetLevelByClass(CLASS_TYPE_MASTER_OF_SHROUDS, oPC)) return;

    FeatUsePerDay(oPC, FEAT_MOS_UNDEAD_1, ABILITY_CHARISMA, 3);
    FeatUsePerDay(oPC, FEAT_MOS_UNDEAD_2, ABILITY_CHARISMA, 3);
    FeatUsePerDay(oPC, FEAT_MOS_UNDEAD_3, ABILITY_CHARISMA, 3);
    FeatUsePerDay(oPC, FEAT_MOS_UNDEAD_4, ABILITY_CHARISMA, 3);
}

void SLAUses(object oPC)
{
    if(!GetHasFeat(FEAT_SPELL_LIKE_ABILITY_1, oPC)) return;

    FeatUsePerDay(oPC, FEAT_SPELL_LIKE_ABILITY_1, -1, GetPersistantLocalInt(oPC, "PRC_SLA_Uses_1"));
    FeatUsePerDay(oPC, FEAT_SPELL_LIKE_ABILITY_2, -1, GetPersistantLocalInt(oPC, "PRC_SLA_Uses_2"));
    FeatUsePerDay(oPC, FEAT_SPELL_LIKE_ABILITY_3, -1, GetPersistantLocalInt(oPC, "PRC_SLA_Uses_3"));
    FeatUsePerDay(oPC, FEAT_SPELL_LIKE_ABILITY_4, -1, GetPersistantLocalInt(oPC, "PRC_SLA_Uses_4"));
    FeatUsePerDay(oPC, FEAT_SPELL_LIKE_ABILITY_5, -1, GetPersistantLocalInt(oPC, "PRC_SLA_Uses_5"));
}

void ShadowShieldUses(object oPC)
{
    if(!GetHasFeat(FEAT_SA_SHIELDSHADOW, oPC)) return;
    FeatUsePerDay(oPC, FEAT_SA_SHIELDSHADOW, -1, GetPrCAdjustedCasterLevelByType(TYPE_ARCANE, oPC));
}

void BlighterFeats(object oPC)
{
    int nClass = GetLevelByClass(CLASS_TYPE_BLIGHTER, oPC);
    if (nClass <= 0) return;

    // Phase 1: Levels 3–10
    int nWildShapeUses = 0;
    if (nClass >= 3)
    {
        int nPhase1 = (nClass <= 10) ? nClass : 10;
        nWildShapeUses = 1 + ((nPhase1 - 3) / 2);
    }

    // Phase 2: Additional uses every 4 levels after 10
    if (nClass > 10)
    {
        nWildShapeUses += ((nClass - 11) / 4) + 1;
    }

    // Contagious Touch: starts at level 5, +1 use every 2 levels
    int nTouchUses = 0;
    if (nClass >= 5)
    {
        nTouchUses = 1 + ((nClass - 5) / 2);
    }

    FeatUsePerDay(oPC, FEAT_UNDEAD_WILD_SHAPE, -1, nWildShapeUses);
    FeatUsePerDay(oPC, FEAT_CONTAGIOUS_TOUCH, -1, nTouchUses);
}



/* void BlighterFeats(object oPC)
{
    int nClass = GetLevelByClass(CLASS_TYPE_BLIGHTER, oPC);
    if(0 >= nClass) return;
    
    if (nClass == 3)
        FeatUsePerDay(oPC, FEAT_UNDEAD_WILD_SHAPE, -1, 1);
    else if (nClass == 4)
        FeatUsePerDay(oPC, FEAT_UNDEAD_WILD_SHAPE, -1, 2);   
    else if (nClass == 5)
    {
        FeatUsePerDay(oPC, FEAT_UNDEAD_WILD_SHAPE, -1, 2);         
        FeatUsePerDay(oPC, FEAT_CONTAGIOUS_TOUCH, -1, 1);
    }  
    else if (nClass == 6)
    {
        FeatUsePerDay(oPC, FEAT_UNDEAD_WILD_SHAPE, -1, 3);         
        FeatUsePerDay(oPC, FEAT_CONTAGIOUS_TOUCH, -1, 1);
    } 
    else if (nClass == 7)
    {
        FeatUsePerDay(oPC, FEAT_UNDEAD_WILD_SHAPE, -1, 3);         
        FeatUsePerDay(oPC, FEAT_CONTAGIOUS_TOUCH, -1, 2);
    }  
    else if (nClass == 8)
    {
        FeatUsePerDay(oPC, FEAT_UNDEAD_WILD_SHAPE, -1, 4);         
        FeatUsePerDay(oPC, FEAT_CONTAGIOUS_TOUCH, -1, 2);
    }  
    else if (nClass == 9)
    {
        FeatUsePerDay(oPC, FEAT_UNDEAD_WILD_SHAPE, -1, 4);         
        FeatUsePerDay(oPC, FEAT_CONTAGIOUS_TOUCH, -1, 3);
    }  
    else 
    {
        FeatUsePerDay(oPC, FEAT_UNDEAD_WILD_SHAPE, -1, 5);         
        FeatUsePerDay(oPC, FEAT_CONTAGIOUS_TOUCH, -1, 3);
    }      
} */

void MysteryFeats(object oPC)
{
    int nClass = GetLevelByClass(CLASS_TYPE_CHILD_OF_NIGHT, oPC);
    if(nClass > 0)
    {
        if (nClass >= 10)
            FeatUsePerDay(oPC, FEAT_CLOAK_SHADOWS, -1, 2);
        else if (nClass >= 6)
            FeatUsePerDay(oPC, FEAT_CLOAK_SHADOWS, -1, 3);
        else
            FeatUsePerDay(oPC, FEAT_CLOAK_SHADOWS, -1, 1);        
            
        if (nClass >= 7)
            FeatUsePerDay(oPC, FEAT_DANCING_SHADOWS, -1, 2);
        else
            FeatUsePerDay(oPC, FEAT_DANCING_SHADOWS, -1, 1);
    }
	nClass = GetLevelByClass(CLASS_TYPE_NOCTUMANCER, oPC);
	if (nClass >= 2)
	{
		int nUses;
		if (nClass < 5)
			nUses = 1;
		else if (nClass < 8)
			nUses = 2;
		else
			nUses = 3 + (nClass - 8) / 3;

		FeatUsePerDay(oPC, FEAT_INNATE_COUNTERSPELL, -1, nUses);
	}	
/*     {
        if (nClass >= 8)
            FeatUsePerDay(oPC, FEAT_INNATE_COUNTERSPELL, -1, 3);
        else if (nClass >= 5)
            FeatUsePerDay(oPC, FEAT_INNATE_COUNTERSPELL, -1, 2);
        else
            FeatUsePerDay(oPC, FEAT_INNATE_COUNTERSPELL, -1, 1); 
    }  */  
    nClass = GetLevelByClass(CLASS_TYPE_SHADOWSMITH, oPC);
    if(nClass > 0)
    {
        FeatUsePerDay(oPC, FEAT_TOUCH_SHADOW  , -1, nClass); 
        FeatUsePerDay(oPC, FEAT_SHROUD_SHADOW , -1, nClass);
        FeatUsePerDay(oPC, FEAT_SHADOW_CRAFT  , -1, nClass/2);
        FeatUsePerDay(oPC, FEAT_ARMOR_SHADOW  , -1, nClass/2);
        FeatUsePerDay(oPC, FEAT_ARMOR_SHADOW_Q, -1, nClass/2);
    }    
}

void WildMage(object oPC)
{
    int nClass = GetLevelByClass(CLASS_TYPE_WILD_MAGE, oPC);

    if (nClass >= 2)
    {
        int nUses = 1 + ((nClass - 2) / 3);
        FeatUsePerDay(oPC, FEAT_WILD_MAGE_RANDOM_DEFLECTOR, -1, nUses);
    }
}
/* void WildMage(object oPC)
{
    int nClass = GetLevelByClass(CLASS_TYPE_WILD_MAGE, oPC);
    if(nClass > 0)
    {
        if (nClass >= 8)
            FeatUsePerDay(oPC, FEAT_WILD_MAGE_RANDOM_DEFLECTOR, -1, 2);
        else if (nClass >= 5)
            FeatUsePerDay(oPC, FEAT_WILD_MAGE_RANDOM_DEFLECTOR, -1, 3);
        else
            FeatUsePerDay(oPC, FEAT_WILD_MAGE_RANDOM_DEFLECTOR, -1, 1); 
    }        
}  */

void Factotum(object oPC)
{
    int nClass = GetLevelByClass(CLASS_TYPE_FACTOTUM, oPC);
    if(nClass > 0)
    {
        if (nClass >= 20)
        {
            FeatUsePerDay(oPC, FEAT_OPPORTUNISTIC_PIETY_TURN, ABILITY_WISDOM, 6);
            FeatUsePerDay(oPC, FEAT_OPPORTUNISTIC_PIETY_HEAL, ABILITY_WISDOM, 6);
        }    
        else if (nClass >= 15)
        {
            FeatUsePerDay(oPC, FEAT_OPPORTUNISTIC_PIETY_TURN, ABILITY_WISDOM, 5);
            FeatUsePerDay(oPC, FEAT_OPPORTUNISTIC_PIETY_HEAL, ABILITY_WISDOM, 5);
        }  
        else if (nClass >= 10)
        {
            FeatUsePerDay(oPC, FEAT_OPPORTUNISTIC_PIETY_TURN, ABILITY_WISDOM, 4);
            FeatUsePerDay(oPC, FEAT_OPPORTUNISTIC_PIETY_HEAL, ABILITY_WISDOM, 4);
        }              
        else
        {
            FeatUsePerDay(oPC, FEAT_OPPORTUNISTIC_PIETY_TURN, ABILITY_WISDOM, 3);
            FeatUsePerDay(oPC, FEAT_OPPORTUNISTIC_PIETY_HEAL, ABILITY_WISDOM, 3);
        }  
    }        
}

/* void Factotum(object oPC)
{
    int nClass = GetLevelByClass(CLASS_TYPE_FACTOTUM, oPC);
    if(nClass > 0)
    {
        if (nClass >= 20)
        {
            FeatUsePerDay(oPC, FEAT_OPPORTUNISTIC_PIETY_TURN, ABILITY_WISDOM, 0, 6);
            FeatUsePerDay(oPC, FEAT_OPPORTUNISTIC_PIETY_HEAL, ABILITY_WISDOM, 0, 6);
        }    
        else if (nClass >= 15)
        {
            FeatUsePerDay(oPC, FEAT_OPPORTUNISTIC_PIETY_TURN, ABILITY_WISDOM, 0, 5);
            FeatUsePerDay(oPC, FEAT_OPPORTUNISTIC_PIETY_HEAL, ABILITY_WISDOM, 0, 5);
        }  
        else if (nClass >= 10)
        {
            FeatUsePerDay(oPC, FEAT_OPPORTUNISTIC_PIETY_TURN, ABILITY_WISDOM, 0, 4);
            FeatUsePerDay(oPC, FEAT_OPPORTUNISTIC_PIETY_HEAL, ABILITY_WISDOM, 0, 4);
        }              
        else
        {
            FeatUsePerDay(oPC, FEAT_OPPORTUNISTIC_PIETY_TURN, ABILITY_WISDOM, 0, 3);
            FeatUsePerDay(oPC, FEAT_OPPORTUNISTIC_PIETY_HEAL, ABILITY_WISDOM, 0, 3);
        }  
    }        
} */

void Sharess(object oPC)
{
    int nClass = GetLevelByClass(CLASS_TYPE_CELEBRANT_SHARESS, oPC);
    if(nClass > 0)
    {
        FeatUsePerDay(oPC, FEAT_CELEBRANT_SHARESS_FASCINATE , -1, 0, nClass); 
        FeatUsePerDay(oPC, FEAT_CELEBRANT_SHARESS_CONFUSE   , -1, 0, nClass);
        FeatUsePerDay(oPC, FEAT_CELEBRANT_SHARESS_DOMINATE  , -1, 0, nClass);
    } 
}    

void SoulbornDefense(object oPC)
{
    int nClass = GetLevelByClass(CLASS_TYPE_SOULBORN, oPC);
    if(nClass > 0)
    {
        if (nClass >= 37)
            FeatUsePerDay(oPC, FEAT_SHARE_INCARNUM_DEFENSE, -1, 0, 8);         
        else if (nClass >= 33)
            FeatUsePerDay(oPC, FEAT_SHARE_INCARNUM_DEFENSE, -1, 0, 7);         
        else if (nClass >= 29)
            FeatUsePerDay(oPC, FEAT_SHARE_INCARNUM_DEFENSE, -1, 0, 6);     
        else if (nClass >= 25)
            FeatUsePerDay(oPC, FEAT_SHARE_INCARNUM_DEFENSE, -1, 0, 5);         
        else if (nClass >= 21)
            FeatUsePerDay(oPC, FEAT_SHARE_INCARNUM_DEFENSE, -1, 0, 4);     
        else if (nClass >= 17)
            FeatUsePerDay(oPC, FEAT_SHARE_INCARNUM_DEFENSE, -1, 0, 3);    
        else if (nClass >= 13)
            FeatUsePerDay(oPC, FEAT_SHARE_INCARNUM_DEFENSE, -1, 0, 2);             
        else
            FeatUsePerDay(oPC, FEAT_SHARE_INCARNUM_DEFENSE, -1, 0, 1);
    }        
}

void TotemistReshape(object oPC)
{
    int nClass = GetLevelByClass(CLASS_TYPE_TOTEMIST, oPC);
    if(nClass > 0)
    {
        if (nClass >= 40)
            FeatUsePerDay(oPC, FEAT_REBIND_TOTEM_SOULMELD, -1, 0, 9);     
        else if (nClass >= 36)
            FeatUsePerDay(oPC, FEAT_REBIND_TOTEM_SOULMELD, -1, 0, 8);     
        else if (nClass >= 32)
            FeatUsePerDay(oPC, FEAT_REBIND_TOTEM_SOULMELD, -1, 0, 7);     
        else if (nClass >= 28)
            FeatUsePerDay(oPC, FEAT_REBIND_TOTEM_SOULMELD, -1, 0, 6);     
        else if (nClass >= 24)
            FeatUsePerDay(oPC, FEAT_REBIND_TOTEM_SOULMELD, -1, 0, 5);     
        else if (nClass >= 20)
            FeatUsePerDay(oPC, FEAT_REBIND_TOTEM_SOULMELD, -1, 0, 4); 
        else if (nClass >= 16)
            FeatUsePerDay(oPC, FEAT_REBIND_TOTEM_SOULMELD, -1, 0, 3);             
        else if (nClass >= 12)
            FeatUsePerDay(oPC, FEAT_REBIND_TOTEM_SOULMELD, -1, 0, 2);             
        else
            FeatUsePerDay(oPC, FEAT_REBIND_TOTEM_SOULMELD, -1, 0, 1);
    }        
}

void CWSamurai(object oPC)
{
    int nClass = GetLevelByClass(CLASS_TYPE_CW_SAMURAI, oPC);
    if(nClass > 0)
    {
        if (nClass >= 17)
            FeatUsePerDay(oPC, FEAT_KIAI_SMITE, -1, 0, 4); 
        else if (nClass >= 12)
            FeatUsePerDay(oPC, FEAT_KIAI_SMITE, -1, 0, 3);             
        else if (nClass >= 7)
            FeatUsePerDay(oPC, FEAT_KIAI_SMITE, -1, 0, 2);             
        else
            FeatUsePerDay(oPC, FEAT_KIAI_SMITE, -1, 0, 1);
    }        
}

void CrusaderSmite(object oPC)
{
    int nClass = GetLevelByClass(CLASS_TYPE_CRUSADER, oPC);
    if(nClass > 0)
    {
        if (nClass >= 18)
            FeatUsePerDay(oPC, FEAT_CRUSADER_SMITE, -1, 0, 2);            
        else
            FeatUsePerDay(oPC, FEAT_CRUSADER_SMITE, -1, 0, 1);
    }        
}

void AnimaMage(object oPC)
{
    int nClass = GetLevelByClass(CLASS_TYPE_ANIMA_MAGE, oPC);
    if(nClass > 0)
    {
        int nUses;
        // Levels 1-6: 1 use
        if(nClass < 7)
        {
            nUses = 1;
        }
        // Levels 7-8: 2 uses
        else if(nClass < 9)
        {
            nUses = 2;
        }
        // Levels 9-10: 3 uses
        else if(nClass <= 10)
        {
            nUses = 3;
        }
        // Levels above 10: 1 additional use per 3 levels
        else
        {
            nUses = 3 + ((nClass - 10) / 3);
        }
        FeatUsePerDay(oPC, FEAT_ANIMA_VESTIGE_METAMAGIC, -1, 0, nUses);
    }
}

/* void AnimaMage(object oPC)
{
    int nClass = GetLevelByClass(CLASS_TYPE_ANIMA_MAGE, oPC);
    if(nClass > 0)
    {
        if (nClass >= 9)
            FeatUsePerDay(oPC, FEAT_ANIMA_VESTIGE_METAMAGIC, -1, 0, 3);    
        else if (nClass >= 7)
            FeatUsePerDay(oPC, FEAT_ANIMA_VESTIGE_METAMAGIC, -1, 0, 2);             
        else
            FeatUsePerDay(oPC, FEAT_ANIMA_VESTIGE_METAMAGIC, -1, 0, 1);
    }        
} */

void FeatSpecialUsePerDay(object oPC)
{
    FeatUsePerDay(oPC, FEAT_WWOC_WIDEN_SPELL, ABILITY_CHARISMA, GetLevelByClass(CLASS_TYPE_WAR_WIZARD_OF_CORMYR, oPC));
    FeatUsePerDay(oPC, FEAT_FIST_DAL_QUOR_STUNNING_STRIKE, -1, GetLevelByClass(CLASS_TYPE_FIST_DAL_QUOR, oPC));
    FeatUsePerDay(oPC, FEAT_AD_FALSE_KEENNESS, -1, GetLevelByClass(CLASS_TYPE_ARCANE_DUELIST, oPC));
    FeatUsePerDay(oPC, FEAT_LASHER_STUNNING_SNAP, -1, GetLevelByClass(CLASS_TYPE_LASHER, oPC));
    FeatUsePerDay(oPC, FEAT_AD_BLUR, -1, GetLevelByClass(CLASS_TYPE_ARCANE_DUELIST, oPC));
    FeatUsePerDay(oPC, FEAT_SHADOW_RIDE, -1, GetLevelByClass(CLASS_TYPE_CRINTI_SHADOW_MARAUDER, oPC));
    FeatUsePerDay(oPC, FEAT_SHADOWJUMP, -1, GetLevelByClass(CLASS_TYPE_SHADOWLORD, oPC));
    FeatUsePerDay(oPC, FEAT_SHADOWBANE_SMITE, -1, (GetLevelByClass(CLASS_TYPE_SHADOWBANE_INQUISITOR, oPC)+2)/4);
    FeatUsePerDay(oPC, FEAT_INCARNUM_RADIANCE, -1, (GetLevelByClass(CLASS_TYPE_INCARNATE, oPC)+2)/5);
    FeatUsePerDay(oPC, FEAT_RAPID_MELDSHAPING, -1, (GetLevelByClass(CLASS_TYPE_INCARNATE, oPC)+1)/6);
    FeatUsePerDay(oPC, FEAT_SMITE_OPPOSITION, -1, (GetLevelByClass(CLASS_TYPE_SOULBORN, oPC)+5)/5);
    FeatUsePerDay(oPC, FEAT_SMITE_CHAOS, -1, (GetLevelByClass(CLASS_TYPE_SAPPHIRE_HIERARCH, oPC)+2)/3);
    FeatUsePerDay(oPC, FEAT_INCANDESCENT_OVERLOAD, -1, (GetLevelByClass(CLASS_TYPE_INCANDESCENT_CHAMPION, oPC)-1)/3);
    FeatUsePerDay(oPC, FEAT_NECROCARNATE_SOULSHIELD, -1, GetLevelByClass(CLASS_TYPE_NECROCARNATE, oPC)/2);
    FeatUsePerDay(oPC, FEAT_SCION_DANTALION_SCHOLARSHIP, -1, GetLevelByClass(CLASS_TYPE_SCION_DANTALION, oPC));
    FeatUsePerDay(oPC, FEAT_SMITE_GOOD_ALIGN, -1, (GetLevelByClass(CLASS_TYPE_FISTRAZIEL, oPC)+1)/2);
	FeatUsePerDay(oPC, FEAT_DOA_LEARN_SECRETS, -1, (GetLevelByClass(CLASS_TYPE_DISCIPLE_OF_ASMODEUS, oPC)+1)/2);
	FeatUsePerDay(oPC, FEAT_BLIGHTTOUCH, -1, (GetLevelByClass(CLASS_TYPE_BLIGHTLORD, oPC) - 1) / 2);
    FeatUsePerDay(oPC, FEAT_FIST_OF_IRON, ABILITY_WISDOM, 3);
    FeatUsePerDay(oPC, FEAT_SMITE_UNDEAD, ABILITY_CHARISMA, 3);
    FeatUsePerDay(oPC, FEAT_COC_WRATH, ABILITY_CHARISMA, 3);
    FeatUsePerDay(oPC, FEAT_KILLOREN_ASPECT_D, ABILITY_CHARISMA);
    FeatUsePerDay(oPC, FEAT_AVENGING_STRIKE, ABILITY_CHARISMA, 0, 1);
    FeatUsePerDay(oPC, FEAT_INCARNUM_BLADE_REBIND, ABILITY_CONSTITUTION, 1);
    FeatUsePerDay(oPC, FEAT_WITCHBORN_INTEGUMENT, ABILITY_CONSTITUTION, 1);
    FeatUsePerDay(oPC, FEAT_LIPS_RAPTUR);
	FeatUsePerDay(oPC, FEAT_COMMAND_SPIDERS, ABILITY_CHARISMA, 3);
	FeatUsePerDay(oPC, FEAT_FM_FOREST_DOMINION, ABILITY_CHARISMA, 3);
	FeatUsePerDay(oPC, FEAT_SOD_DEATH_TOUCH, -1, (GetLevelByClass(CLASS_TYPE_SLAYER_OF_DOMIEL, oPC)+4)/4);
	FeatUsePerDay(oPC, FEAT_SUEL_DISPELLING_STRIKE, -1, (GetLevelByClass(CLASS_TYPE_SUEL_ARCHANAMACH, oPC) + 2) / 4);
	FeatUsePerDay(oPC, FEAT_PLANT_CONTROL, ABILITY_CHARISMA, 3);
	FeatUsePerDay(oPC, FEAT_PLANT_DEFIANCE, ABILITY_CHARISMA, 3);
    FeatDiabolist(oPC);
    FeatAlaghar(oPC);
    ShadowShieldUses(oPC);
    CombatMedic(oPC);
    FeatNinja(oPC);
    FeatNoble(oPC);
    MasterOfShrouds(oPC);
    HexCurse(oPC);
    FeatRacial(oPC);
    FeatShadowblade(oPC);
    SoulbornDefense(oPC);
	FeatIronMind(oPC);

    int nDread = GetLevelByClass(CLASS_TYPE_DREAD_NECROMANCER, oPC);
    if (nDread >= 1)
	{//:: Enervating Touch	
		if (nDread >= 17)
		{			
			FeatUsePerDay(oPC, FEAT_DN_ENERVATING_TOUCH, -1, nDread);
		}
		else
		{
			FeatUsePerDay(oPC, FEAT_DN_ENERVATING_TOUCH, -1, nDread/2);
		}
	}
	
	if (nDread >= 3)
	{//:: Negative Energy Burst
		int NegBurstUses = 0;
		
		if (nDread >= 8)
		{
        // Gains 1 more daily use of Negative Energy Burst every 5 levels after 3rd
			int additionalUses = (nDread - 3) / 5;
			NegBurstUses += 1 + additionalUses;
			FeatUsePerDay(oPC, FEAT_DN_NEG_NRG_BURST, -1, NegBurstUses);
		}
		else if (nDread >= 3) 
		{
        // Dread Necromancer gains 1 use at level 3
			NegBurstUses += 1;
			FeatUsePerDay(oPC, FEAT_DN_NEG_NRG_BURST, -1, NegBurstUses);
		}
	}
	if (nDread >= 7)
	{//:: Scabrous Touch
		int ScabUses = 0;
		
		// Gains 1 more daily use every 5 levels after 21
		if (nDread >= 26) 
		{			
			int additionalUses = (nDread - 21) / 5;
			ScabUses += 4 + additionalUses;
			FeatUsePerDay(oPC, FEAT_DN_SCABROUS_TOUCH, -1, ScabUses);
		}
		// Epic Dread Necromancer gains 1 more daily use at level 21
		else if (nDread >= 21) 
		{ 
			ScabUses += 4;	
			FeatUsePerDay(oPC, FEAT_DN_SCABROUS_TOUCH, -1, ScabUses);
		}
		else if (nDread >= 16) 
		{
			ScabUses += 3; 
			FeatUsePerDay(oPC, FEAT_DN_SCABROUS_TOUCH, -1, ScabUses);
		}
		else if (nDread >= 11) 
		{
			ScabUses += 2; 
			FeatUsePerDay(oPC, FEAT_DN_SCABROUS_TOUCH, -1, ScabUses);
		}
		
		else 
		{
			ScabUses += 1; 
			FeatUsePerDay(oPC, FEAT_DN_SCABROUS_TOUCH, -1, ScabUses);
		}			
	}

    SLAUses(oPC);
    DomainUses(oPC);
    BardSong(oPC);
	EyeOfGruumsh(oPC);
    BarbarianRage(oPC);
    FeatVirtuoso(oPC);
    ResetExtraStunfistUses(oPC);
    DarkKnowledge(oPC);
    FeatImbueArrow(oPC);
    DragonDisciple(oPC);
    Warlock(oPC);
    KotMC(oPC);
    Templar(oPC);
    BlighterFeats(oPC);
    MysteryFeats(oPC);
    WildMage(oPC);
    Factotum(oPC);
    Sharess(oPC);
    TotemistReshape(oPC);
    CWSamurai(oPC);
    CrusaderSmite(oPC);
    AnimaMage(oPC);
	MephlingBreath(oPC);
	HathranFear(oPC);
	Oozemaster(oPC);
	DrowJudicator(oPC);
	Ravager(oPC);
}

