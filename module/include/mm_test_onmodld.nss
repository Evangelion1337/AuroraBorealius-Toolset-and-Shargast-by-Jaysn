// Name     : Avlis Persistence System OnModuleLoad
// Purpose  : Initialize APS on module load event
// Authors  : Ingmar Stieger
// Modified : January 27, 2003

// This file is licensed under the terms of the
// GNU GENERAL PUBLIC LICENSE (GPL) Version 2


#include "aps_include"

void main()
{
    // Init placeholders for ODBC gateway
    SQLInit();

//CNR addon
     ExecuteScript("cnr_module_oml",OBJECT_SELF);
//End CNR addon


    //sets up the save every 20 minutes
 DelayCommand(2400.0, SignalEvent(OBJECT_SELF, EventUserDefined(200)));

//Custom Colour Tokens addon

    SetCustomToken(100, "</c>"); // CLOSE tag
    SetCustomToken(101, "<cþ  >"); // red
    SetCustomToken(102, "<c þ >"); // green
    SetCustomToken(103, "<c  þ>"); // blue
    SetCustomToken(104, "<c þþ>"); // cyan
    SetCustomToken(105, "<cþ þ>"); // magenta
    SetCustomToken(106, "<cþþ >"); // yellow
    SetCustomToken(107, "<c   >"); // black
    SetCustomToken(108, "<c¥  >"); // dark red
    SetCustomToken(109, "<c ¥ >"); // dark green
    SetCustomToken(110, "<c  ¥>"); // dark blue
    SetCustomToken(111, "<c ¥¥>"); // dark cyan
    SetCustomToken(112, "<c¥ ¥>"); // dark magenta
    SetCustomToken(113, "<c¥¥ >"); // dark yellow
    SetCustomToken(114, "<c¥¥¥>"); // grey
    SetCustomToken(117, "<cŒŒŒ>"); // dark grey
    SetCustomToken(115, "<cþ¥ >"); // orange
    SetCustomToken(116, "<cþŒ >"); // dark orange
    SetCustomToken(117, "<cÚ¥#>"); // brown
    SetCustomToken(118, "<cÂ† >"); // dark brown
//End Custom Colour Tokens addon

   //Ignore this... this is for NWNX/SQL database functionality
/*    if(ENABLE_NWNX_DATABASE)
   {
        //Initialize NWNX DB support
        SQLInit();
        //Create subrace table in database (if it doesn't exist)
        DelayCommand(1.0, NWNX_CreateSubraceDBTables());
   } */


   //Functions available for use are:
   //
   // ::The Most Important Method (Used to define your subrace). MUST BE CALLED BEFORE ALL OTHERS.::
   //----- CreateSubrace(int Race, string SubraceName, string HideResRef, string UniqueItemResref, int IsLightSensitive = FALSE, int DamageTakenWhileInLight = 0, int IsUndergroundSensitive = FALSE, int DamageTakenWhileInUnderground = 0, int ECL = 0, int IsUndead = FALSE, int PrestigiousSubrace = FALSE)
   //
   // ::Used to Add another Race that can be part of the Subrace.::
   // ::Reuse as many times as needed.::
   //----- AddAdditionalBaseRaceToSubrace(string subraceName, int AdditionalBaseRace)
   //
   // ::Used to add an Alignment Restriction to a Subrace.
   //----- CreateSubraceAlignmentRestriction(string subraceName, int CanBeAlignment_Good = TRUE , int CanBeAlignment_Neutral1 = TRUE, int CanBeAlignment_Evil = TRUE, int CanBeAlignment_Lawful = TRUE, int CanBeAlignment_Neutral2 = TRUE, int CanBeAlignment_Chaotic = TRUE)
   //
   // ::Used to add a Class restriction on the Subrace.
   //----- CreateSubraceClassRestriction(string subraceName, int CanBe_Barbarian = TRUE, int CanBe_Bard = TRUE, int CanBe_Cleric = TRUE, int CanBe_Druid = TRUE, int CanBe_Fighter = TRUE, int CanBe_Monk = TRUE, int CanBe_Paladin = TRUE, int CanBe_Ranger = TRUE, int CanBe_Rogue = TRUE, int CanBe_Sorcerer = TRUE, int CanBe_Wizard = TRUE)
   //
   // ::Used to change a Player Subrace's Appearance::
   // ::Use only ONCE per subrace::
   //----- CreateSubraceAppearance(string subraceName, int AppearanceChangeTime, int MaleAppearance, int FemaleAppearance)
   //
   // ::Used to give PC's a change in Ability scores, or Attack Bonus or Armour Class. During the day or Night.
   // ::USed in conjunction with CreateCustomStats() <Look Below>.
   //----- CreateTemporaryStatModifier(string subraceName, struct SubraceStats Stats, int TimeToApply, int InInteriorArea = TRUE, int InExteriorArea = TRUE, int InNaturalArea = TRUE, int InArtifacialArea = TRUE, int InUndergroundArea = TRUE, int InAbovegroundArea = TRUE)
   //
   // ::Used to define the Ability increase or decrease, AC increase/decrease, AB increase/Decrease.
   //----- SubraceStats CreateCustomStats(int StatModifierType, float StrengthModifier, float DexterityModifier, float ConstitutionModifier, float IntelligenceModifier, float WisdomModifier, float CharismaModifier, float ACModifier, float ABModifier)
   //
   // ::Used to disable/allow only the use of melee, ranged or other kind of weapons during certain times of day or permanently.
   // ::Use only ONCE per subrace::
   //----- SubraceRestrictUseOfWeaponsOfType(string subraceName, int WeaponType, int TimeOfDay = TIME_BOTH)
   //
   // ::Used to disable/allow only the use of heavy, medium or light armour during the day, night or permanently.
   // ::Use only ONCE per subrace::
   //----- SubraceRestrictUseOfArmourAndShieldsOfType(string subraceName, int Type, int TimeOfDay = TIME_BOTH, int Allow = FALSE)
   //
   // ::Add a favored Class to Subrace
   // ::Use only ONCE per subrace::
   //----- AddSubraceFavoredClass(string subraceName, int MaleFavoredClass, int FamaleFavoredClass)
   //
   // ::Add an effect to the Subrace, that takes effect during the night (lasts until morning), day(lasts until dusk) or permanently.
   // ::Use as many times as desired::
   //----- AddSubraceEffect(string subraceName, int EffectID, int Value1, int Value2, int nDurationType, float fDuration, int TimeOfDay)
   //
   // ::Add another skin for the subrace to be equipped at a particular level.
   // :: Use as Many times as desired.
   //----- AddAdditionalSkinsToSubrace(string subraceName, string SkinResRef, int EquipLevel, int iTime = TIME_BOTH)
   //
   // ::Use to create varying Spell resistance for the subrace.
   //----- CreateSubraceSpellResistance(string subraceName, int SpellResistanceBase, int SpellResistanceMax)
   //
   // ::Add 'claws' to the playable subrace.
   // :: Use as many times as desired.
   //----- AddClawsToSubrace(string subraceName, string RightClawResRef, string LeftClawResRef , int EquipLevel)
   //
   // :: Setup the player belonging to the subrace to 'switch' to another subrace
   //----- SetupSubraceSwitch(string subraceName, string switchSubraceName, int Level, int MustMeetRequirements = TRUE)
   //
   // :: Give additional 'unique' items
   //----- AddSubraceItem(string subraceName, string ItemResRef, int Level = 1)
   //
   // :: Set-up a Prestige class restriction for a subrace.
   //----- CreateSubracePrestigiousClassRestriction(string subraceName, int MinimumLevels = 1, int CanBe_ArcaneArcher = TRUE, int CanBe_Assasin = TRUE, int CanBe_Blackguard = TRUE, int CanBe_ChampionOfTorm = TRUE, int CanBe_RedDragonDisciple = TRUE, int CanBe_DwarvenDefender = TRUE, int CanBe_HarperScout = TRUE, int CanBe_PaleMaster = TRUE, int CanBe_ShadowDancer = TRUE, int CanBe_Shifter = TRUE, int CanBe_WeaponMaster = TRUE);
   //
   //
   // The following scripts load up the example subraces created by me (Shayan).
   // You can use these or add to them or delete them all.
   // You can find the Creature Hide relating to these subraces in Items -> Custom -> Creature Items -> Skin/Hide
   // You can also find the Unique Items relating to these subraces in Items -> Plot Items

   //:: Spell Hooking - Uncomment line 93 to enable it. Remember to have imported
   //::                 sha_spellhooks script.
   //SetLocalString(GetModule(), "X2_S_UD_SPELLSCRIPT", "sha_spellhooks");

}

