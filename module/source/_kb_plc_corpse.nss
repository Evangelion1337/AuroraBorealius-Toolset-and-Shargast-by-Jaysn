////////////////////////////////////////////////////////////////////////////////
//                                                  //                        //
// _kb_plc_corpse                                   //      VERSION 3.3       //
//                                                  //                        //
//  by Scrotok on 9 Feb 03                          ////////////////////////////
//  Thanks to Keron Blackfeld for 99% of the work!                            //
//  email Questions and Comments to: jnbplatte@intellisys.net                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//  This script works in conjunction with the "_kb_loot_corpse" script.       //
//  Place this script in the OnSpawn event of any creature you want to spawn  //
//  dead, then add "Dead" as the first 4 letters of its tag -- it will then   //
//  be lootable!                                                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/*  Version 3.2 Change Log:
    - changed EffectDamage to include DAMAGE_POWER_PLUS_FIVE to ensure creature spawns dead
    - renamed oDeadNPC to oHostBody for consistency
*/

void main()
{
    object oHostBody = OBJECT_SELF; //Get the Dead Creature Object
    string sBaseTag = GetTag(oHostBody); //Get that TAG of the dead creature
    string sPrefix = GetStringLeft(sBaseTag, 4); //Look for Dead Prefix
    if (sPrefix == "Dead") //Do Spawned Corpse
    {
        //Set up and Deliver our Death Blow
        /*  this is only needed if you need this
            creature to SPAWN as a corpse. */
        //Set up for the kill
        effect eDamage = EffectDamage(9999, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_PLUS_FIVE);
        //Deliver the killing effect
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eDamage, oHostBody);
    }
}
