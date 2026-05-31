//::///////////////////////////////////////////////
//:: Example XP3 OnLoad Script
//:: x3_mod_def_load
//:: (c) 2008 Bioware Corp.
//:://////////////////////////////////////////////
//  Modified by Proleric 14-May-2008 :
//
//  - All module and area switches for horses included (commented out).
//  - No horses in interior areas by default.
//  - Some area switches enabled as an example.
//  - Fix for the save/load bug with unattached NPCs (commented out, because it's module-specific).

/*
    Put into: OnModuleLoad Event

    This example script demonstrates how to tweak the
    behavior of several subsystems in your module.

    For more information, please check x2_inc_switches
    which holds definitions for several variables that
    can be set on modules, creatures, doors or waypoints
    to change the default behavior of Bioware scripts.

    Warning:
    Using some of these switches may change your games
    balancing and may introduce bugs or instabilities. We
    recommend that you only use these switches if you
    know what you are doing. Consider these features
    unsupported!

    Please do NOT report any bugs you experience while
    these switches have been changed from their default
    positions.

    Make sure you visit the forums at nwn.bioware.com
    to find out more about these scripts.

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-07-16
//:://////////////////////////////////////////////
/*
     Example settings for horses at the bottom.
*/
//:://////////////////////////////////////////////
//:: Updated By: Azbest
//:: Last Update: April 18th, 2008
//:://////////////////////////////////////////////

#include "x2_inc_switches"
#include "x2_inc_restsys"

// Custom code

void bhLoadBugFix(string sNPC_Tag);

// end Custom code

void main()
{
   if (GetGameDifficulty() ==  GAME_DIFFICULTY_CORE_RULES || GetGameDifficulty() ==  GAME_DIFFICULTY_DIFFICULT)
   {
        // * Setting the switch below will enable a seperate Use Magic Device Skillcheck for
        // * rogues when playing on Hardcore+ difficulty. This only applies to scrolls
        SetModuleSwitch (MODULE_SWITCH_ENABLE_UMD_SCROLLS, TRUE);

       // * Activating the switch below will make AOE spells hurt neutral NPCS by default
       // SetModuleSwitch (MODULE_SWITCH_AOE_HURT_NEUTRAL_NPCS, TRUE);
   }

   // * AI: Activating the switch below will make the creaures using the WalkWaypoint function
   // * able to walk across areas
   // SetModuleSwitch (MODULE_SWITCH_ENABLE_CROSSAREA_WALKWAYPOINTS, TRUE);

   // * Spells: Activating the switch below will make the Glyph of Warding spell behave differently:
   // * The visual glyph will disappear after 6 seconds, making them impossible to spot
   // SetModuleSwitch (MODULE_SWITCH_ENABLE_INVISIBLE_GLYPH_OF_WARDING, TRUE);

   // * Craft Feats: Want 50 charges on a newly created wand? We found this unbalancing,
   // * but since it is described this way in the book, here is the switch to get it back...
   // SetModuleSwitch (MODULE_SWITCH_ENABLE_CRAFT_WAND_50_CHARGES, TRUE);

   // * Craft Feats: Use this to disable Item Creation Feats if you do not want
   // * them in your module
   // SetModuleSwitch (MODULE_SWITCH_DISABLE_ITEM_CREATION_FEATS, TRUE);

   // * Palemaster: Deathless master touch in PnP only affects creatures up to a certain size.
   // * We do not support this check for balancing reasons, but you can still activate it...
   // SetModuleSwitch (MODULE_SWITCH_SPELL_CORERULES_DMASTERTOUCH, TRUE);

   // * Epic Spellcasting: Some Epic spells feed on the liveforce of the caster. However this
   // * did not fit into NWNs spell system and was confusing, so we took it out...
   // SetModuleSwitch (MODULE_SWITCH_EPIC_SPELLS_HURT_CASTER, TRUE);

   // * Epic Spellcasting: Some Epic spells feed on the liveforce of the caster. However this
   // * did not fit into NWNs spell system and was confusing, so we took it out...
   // SetModuleSwitch (MODULE_SWITCH_RESTRICT_USE_POISON_TO_FEAT, TRUE);

    // * Spellcasting: Some people don't like caster's abusing expertise to raise their AC
    // * Uncommenting this line will drop expertise mode whenever a spell is cast by a player
    // SetModuleSwitch (MODULE_VAR_AI_STOP_EXPERTISE_ABUSE, TRUE);


    // * Item Event Scripts: The game's default event scripts allow routing of all item related events
    // * into a single file, based on the tag of that item. If an item's tag is "test", it will fire a
    // * script called "test" when an item based event (equip, unequip, acquire, unacquire, activate,...)
    // * is triggered. Check "x2_it_example.nss" for an example.
    // * This feature is disabled by default.
   SetModuleSwitch (MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS, TRUE);

   if (GetModuleSwitchValue (MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS) == TRUE)
   {
        // * If Tagbased scripts are enabled, and you are running a Local Vault Server
        // * you should use the line below to add a layer of security to your server, preventing
        // * people to execute script you don't want them to. If you use the feature below,
        // * all called item scrips will be the prefix + the Tag of the item you want to execute, up to a
        // * maximum of 16 chars, instead of the pure tag of the object.
        // * i.e. without the line below a user activating an item with the tag "test",
        // * will result in the execution of a script called "test". If you uncomment the line below
        // * the script called will be "1_test.nss"
        // SetUserDefinedItemEventPrefix("1_");

   }

   // * This initializes Bioware's wandering monster system as used in Hordes of the Underdark
   // * You can deactivate it, making your module load faster if you do not use it.
   // * If you want to use it, make sure you set "x2_mod_def_rest" as your module's OnRest Script
   // SetModuleSwitch (MODULE_SWITCH_USE_XP2_RESTSYSTEM, TRUE);

   if (GetModuleSwitchValue(MODULE_SWITCH_USE_XP2_RESTSYSTEM) == TRUE)
   {

       // * This allows you to specify a different 2da for the wandering monster system.
       // SetWanderingMonster2DAFile("des_restsystem");

       //* Do not change this line.
       WMBuild2DACache();
   }

   // CUSTOM CODE FOR HORSES
   //
   // See Proleric's Lexicon or x3_inc_horse for full explanation of the module options.
   //
   // This example excludes horses from indoor areas, except one in which no mounting is allowed.
   //
   // Similar lines in the official Bioware script have been consolidated into this section.

   SetMaxHenchmen(99);

   // Fix for the save/load bug with unattached NPCs.
   // You will need one line for each henchman in your module, and one for any other NPC who might own horses at some point.
   // Activate the next two lines to see how this works in this demo module.
   // bhLoadBugFix("Meruppi");
   // bhLoadBugFix("Gidush");

   // Area Control
   SetLocalInt(GetModule(), "X3_MOUNTS_EXTERNAL_ONLY", TRUE);          // Horses not allowed in indoor areas
// SetLocalInt(GetModule(), "X3_MOUNTS_NO_UNDERGROUND", TRUE);         // Horses not allowed underground
// SetLocalInt(GetObjectByTag("AreaTag"), "X3_NO_HORSES", TRUE);                // Horses not allowed in this area
   SetLocalInt(GetObjectByTag("DismountZone"), "X3_NO_MOUNTING", TRUE);         // No mounting in this area
   SetLocalInt(GetObjectByTag("DismountZone"), "X3_MOUNT_OK_EXCEPTION", TRUE);  // Horses allowed in this area
// SetLocalFloat(GetObjectByTag("DismountZone"), "fX3_MOUNT_MULTIPLE", 0.5);    // Mount animation faster or slower in this area
// SetLocalFloat(GetObjectByTag("DismountZone"), "fX3_DISMOUNT_MULTIPLE", 0.5); // Dismount animation faster or slower in this area
// SetLocalInt(GetObjectByTag("AreaTag"), "X3_ABORT_WHEN_STUCK", TRUE);         // Abort mount if unable to run to horse in this area

   // Abilities & Combat
// SetLocalInt(GetModule(), "X3_HORSE_DISABLE_SPEED", TRUE);           // No speed increase on mounting
// SetLocalInt(GetModule(), "X3_HORSE_DISABLE_SKILL", TRUE);           // No skill penalties to Hide etc on mounting
// SetLocalInt(GetModule(), "X3_MOUNT_NO_REST_DISMOUNT", TRUE);        // Allow rest when mounted
// SetLocalInt(GetModule(), "X3_HORSE_ENABLE_ACBOOST", TRUE);          // Increase rider AC to match horse on mounting
// SetLocalInt(GetModule(), "X3_NO_MOUNTED_COMBAT_FEAT", TRUE);        // Disable Mounted Combat feat
// SetLocalInt(GetModule(), "X3_HORSE_ENABLE_HPBOOST", TRUE);          // Give rider temporary hit points on mounting
// SetLocalInt(GetModule(), "X3_ENABLE_MOUNT_DAMAGE", TRUE);           // Horse shares damage on dismounting
// SetLocalInt(GetModule(), "X3_HORSE_NO_CORPSES", TRUE);              // Mounted horses leave no corpses
// SetLocalInt(GetModule(), "X3_NO_SHAPESHIFT_SPELL_CHECK", TRUE);     // Allow mounted creatures to be shapeshifted by spells

   // Henchman Control
 SetLocalInt(GetModule(), "X3_RESTORE_HENCHMEN_LOCATIONS", TRUE);      // Henchmen's horses respawn near henchmen on loading saved game
// SetLocalInt(GetModule(), "X3_HORSE_NO_HENCHMAN_INCREASE", TRUE);    // No increase in maximum henchmen to accommodate horses
// SetLocalInt(GetModule(), "X3_HORSE_MAX_HENCHMEN ", 5);              // Upper limit on maximum henchmen to accommodate horses

   // Saddlebags
// SetLocalInt(GetModule(), "X3_HORSE_ENABLE_SADDLEBAGS", TRUE);       // Enable saddlebags
// SetLocalString(GetModule(), "X3_SADDLEBAG_DATABASE", "MyDataBase"); // Name of saddlebag database

   // Paladin Mounts
// SetLocalInt(GetModule(), "X3_HORSE_PALADIN_USE_PHB", TRUE);         // Paladin mount summoning duration as Player's Handbook
// SetLocalInt(GetModule(), "X3_MOUNT_NO_REST_DESPAWN", TRUE);         // Paladin mount does not despawn on rest
// SetLocalString(GetModule(), "X3_PALMOUNT_SUMMONOVR", "MyScript");   // Custom summoning script
// SetLocalString(GetModule(), "X3_EXTEND_PALMOUNT", "MyScript");      // Custom post-mount script
// SetLocalString(GetModule(), "X3_EXTEND_PALDMOUNT", "MyScript");     // Custom post-dismount script

   // Mounting System
// SetLocalInt(GetModule(), "X3_NO_MOUNT_COMMANDABLE", TRUE);          // Allow horse and rider to be commandable during mount / dismount
// SetLocalInt(GetModule(), "X3_HORSE_ACT_VS_DELAY", TRUE);            // Use actions rather than delays when mounting/dismounting
// SetLocalFloat(GetModule(), "fX3_MOUNT_DELAY", 2.0);                 // Mount animation additional time in seconds
// SetLocalFloat(GetModule(), "fX3_TIMEOUT_TO_MOUNT", 6.0);            // Maximum time allowed to run to horse in seconds
 SetLocalInt(GetModule(), "bX3_MOUNT_NO_ZAXIS", TRUE);                 // Enabled in official Bioware script
// SetLocalFloat(GetModule(), "fX3_FREQUENCY", 2.0);                   // Frequency of pathfinding during run to horse in seconds

   // Database
// SetLocalInt(GetModule(), "X3_ENABLE_MOUNT_DB", TRUE);               // Enable data base functions

}

// Fix for the save/load bug with unattached NPCs

// Calls to this function are commented out above, because they must be bespoke for each module.

void bhLoadBugFix(string sNPC_Tag)
{
  object   oNPC   = GetObjectByTag(sNPC_Tag);
  location oLoc   = GetLocation(oNPC);
  int      nHench = 1;
  object   oHench;

  oHench = GetHenchman(oNPC, nHench);

  while (GetIsObjectValid(oHench))
    {
      SetAILevel(oHench, AI_LEVEL_HIGH);
      AssignCommand(oHench, JumpToLocation(oLoc));
      oHench = GetHenchman(oNPC, ++nHench);
    }
}
