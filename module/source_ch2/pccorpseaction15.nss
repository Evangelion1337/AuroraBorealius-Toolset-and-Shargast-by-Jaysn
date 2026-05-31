//::////////////////////////////////////////////////////////////////////////::\\
//:: OBJECT Auto-loot to PC inventory                                       ::\\
//:: Concept By: SpitNyerEye                                                ::\\
//:: Written By: Haelix/SpitNyerEye                                                     ::\\
//::////////////////////////////////////////////////////////////////////////::\\
void main()
{
   object oPC = GetPCSpeaker() ; // Sets the object oPC as the PC speaking to the corpse
   object oItem = GetFirstItemInInventory(OBJECT_SELF) ; // Gets the first item in the corpse's inventory
      while (GetIsObjectValid(oItem)) // As long as it finds item in inventory
           {
            AssignCommand(OBJECT_SELF, ActionGiveItem(oItem, oPC)) ; // The corpse puts the items into the PC's inventory
            oItem = GetNextItemInInventory(OBJECT_SELF) ; // Checks for other items
           }

    /*
   If you want to give the PC some XP back for looting the corpse then uncomment
   (remove the // from the begining of) the 2 lines in the following section.  If
   You want to change the percentage returned, change the number (.33) to the
   decimal number representing the percentage of the XP you want to restore.
   */
//   int nGiveBack = FloatToInt(0.33 * GetLocalInt(OBJECT_SELF,"nXPTaken")) ; // Gets the XP Penalty taken on respawn does some math to calculate the amount of XP to give back
//   GiveXPToCreature(oPC, nGiveBack) ; // Give the XP calculated to the PC

   /*
   The next line destroys the EMPTY corpse after a 0.9 second delay.  If you want
   the corpse to stick around a bit longer change the number to the delay (in
   SECONDS) that you want the empty corpse to hag around
   */
   DestroyObject(OBJECT_SELF,0.9f) ; // Destroys the corpse
}
