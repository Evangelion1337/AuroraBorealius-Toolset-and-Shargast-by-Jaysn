////////////////////////////////////////////////////////////////////////////////
//                                                  //                        //
//  _kb_corpse_spell                                //      VERSION 3.3       //
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
//  This script works in conjunction with the "_kb_loot_corpse" script.  The  //
//  OnSpellCastAt events of the lootable corpse placeable (tag                //
//  "invis_corpse_obj") and the lootable bones placeable ("loot_bones_obj")   //
//  contain this script.                                                      //
//                                                                            //
//  This script allows third-party plugins to function (if installed), or     //
//  runs the default behavior (if no plugins installed).                      //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

void main()
{
   /* Register Plugins */
   if (!GetLocalInt(GetModule(),"kb_lootcorpse_plugins"))
      ExecuteScript("_kb_plugins", OBJECT_SELF);

// PLUGIN BEHAVIOR
   // Scrotok's Raise Dead/Resurrection plugin
   if (GetLocalInt(GetModule(),"kb_raise_res"))
      ExecuteScript("_kb_raise_res", OBJECT_SELF);

// DEFAULT BEHAVIOR if plugin not installed

}
