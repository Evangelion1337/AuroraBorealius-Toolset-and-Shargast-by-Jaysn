////////////////////////////////////////////////////////////////////////////////
//                                                  //                        //
//  _kb_corpse_used                                 //      VERSION 3.3       //
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
//  OnUsed event of the lootable corpse placeable (tag "invis_corpse_obj")    //
//  contains this script.  This script causes the PC searching the corpse to  //
//  crouch down and visibly reach for the corpse.                             //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/*  Version 3.3 Change Log:
    - fixed comments to clarify that "doa_lootnotify" script refers to DOA's "Party Loot Notification" plugin
/*  Version 3.2 Change Log:
    - renamed script from "_kb_loot_crouch" to "_kb_corpse_used" for naming consistency
    - added simple plugin architecture (requires file _kb_plugins)
    - integration with DOA's "Party Loot Notification" plugin ("doa_lootnotify") now requires zero editing (no include call)
    - added check of GetIsOpen to ensure crouch animation only plays when corpse is opened
*/

void main()
{
   /* Register Plugins */
   if (!GetLocalInt(GetModule(),"kb_lootcorpse_plugins"))
      ExecuteScript("_kb_plugins", OBJECT_SELF);

// PLUGIN BEHAVIOR
   if (GetLocalInt(GetModule(),"doa_lootnotify"))
    {
       ExecuteScript("doa_lootnotify_o", OBJECT_SELF);
    }
   else
    {
// DEFAULT BEHAVIOR if plugin not installed
       object oPC = GetLastUsedBy();

       // Play crouch animation only if PC just opened the corpse inventory GUI
       // EXCEPTION: If the PC opens the corpse inventory, then quickly presses
       // the "I" key (to open the PC inventory), a BioWare software bug will
       // trick the software into permanently thinking the corpse inventory is
       // open (even though the GUI can be opened and closed normally).  This will
       // cause the animation to play when corpse is opened or closed (a minor
       // bug).
       if (GetIsOpen(OBJECT_SELF))
        {
           AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW, 1.0f, 1.2f));
        }
    }
}

