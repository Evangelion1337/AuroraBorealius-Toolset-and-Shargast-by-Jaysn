////////////////////////////////////////////////////////////////////////////////
//                                                  //                        //
//  _kb_plugins                                     //      VERSION 3.3       //
//                                                  //                        //
//  by Scrotok on 9 Feb 03                          ////////////////////////////
//  Thanks to Keron Blackfeld for 99% of the work!                            //
//  email Questions and Comments to: jnbplatte@intellisys.net                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//  NEWBIES: You don't need to place this script anywhere -- it's already     //
//  taken care of for you.                                                    //
//                                                                            //
//  This script works in conjunction with the "_kb_loot_corpse" script.       //
//                                                                            //
//  When any script (OnDisturbed, OnSpellCastAt, etc.) for the lootable       //
//  corpse placeable (tag "invis_corpse_obj") is executed, a call is made     //
//  to "_kb_plugins" (once per module reset) to "register" installed plugins. //
//                                                                            //
//  End-users don't need to make any changes to this script.  Plugin creators //
//  will need to contact Scrotok so that your plugin can be listed and the    //
//  appropriate hooks created for distribution.                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/*  Version 3.3 Change Log:
    - fixed comments to clarify that "doa_bashbreak" script refers to DOA's "Bashed Loot Breakage" plugin
    - fixed comments to clarify that "doa_lootnotify" script refers to DOA's "Party Loot Notification" plugin
    - fixed comments to clarify that "_kb_raise_res" script refers to Scrotok's "Raise Dead/Resurrection" plugin
*/

void main()
{
   // Used for debugging
   int bModDebug = GetLocalInt(GetModule(),"bModDebug");
   if (bModDebug)
      SendMessageToPC(GetFirstPC(),"[kb_lootcorpse] Looking for plugins...");

   // Register installed plugins (available plugins listed below)
   // ("registration" means setting a module-level variable to 1 for that
   // plugin, so that plugin behavior can function)

   // IMPORTANT: You must keep OBJECT_INVALID in the lines below!
   ExecuteScript("doa_lootnotify", OBJECT_INVALID); // DOA's "Party Loot Notification" plugin
   ExecuteScript("_kb_raise_res", OBJECT_INVALID); // Scrotok's "Raise Dead/Resurrection" plugin
   ExecuteScript("doa_bashbreak", OBJECT_INVALID); // DOA's "Bashed Loot Breakage" plugin

   // Run this script only once
   SetLocalInt(GetModule(),"kb_lootcorpse_plugins",1);
}

