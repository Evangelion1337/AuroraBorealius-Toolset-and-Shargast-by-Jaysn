////////////////////////////////////////////////////////////////////////////////
//                                                  //                        //
//  _kb_loot_corpse (include file)                  //      VERSION 3.3       //
//                                                  //                        //
//  by Scrotok on 9 Feb 03                          ////////////////////////////
//  Thanks to Keron Blackfeld for 99% of the work!                            //
//  email Questions and Comments to: jnbplatte@intellisys.net                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//  CAUTION: You MUST re-save/compile (F7 key) "nw_c2_default7" whenever      //
//  "_kb_loot_corpse" is modified!                                            //
//                                                                            //
//  CAUTION: You MUST re-save (not the F7 key!) "_kb_loot_corpse" if you make //
//  any changes to "_kb_inc_invmgmt" (for programmers only: because it is an  //
//  #include file).  To re-save it, make a change to the script, then UNDO    //
//  the change, then re-save.                                                 //
//                                                                            //
//  NEWBIES: You don't need to place this script anywhere -- it's included as //
//  part of "nw_c2_default7" using the #include command.  All you need to do  //
//  is configure the script (see below) as desired.                           //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                                                                            //
//  CONFIGURING THE SCRIPT                                                    //
//                                                                            //
//  This script supports some configuration by the user. Following the        //
//  void LeaveCorpse() of the _kb_loot_corpse, you'll find a section where    //
//  you can set a few things. These include: (with default values displayed)  //
//                                                                            //
//                                                                            //
//  int nUseLootable =  TRUE    This enables the script. Setting is to FALSE  //
//                              disables it.                                  //
//                                                                            //
//  int nMoveEquipped = TRUE    Setting this to FALSE will stop the script    //
//                              from moving equipped items (other than        //
//                              Armour/Helmet and Weapons/Shield/Torch) to    //
//                              the lootable corpse placeable. (To prevent    //
//                              the move/copy of Armour/Helmet and Weapons/   //
//                              Shield/Torch, use the next four toggles.)     //
//                              Remember that CREATURE SLOTTED items are      //
//                              NEVER moved.                                  //
//                                                                            //
//  int nCopyArmour  =  TRUE    This will use the ResRef to create a copy of  //
//                              the Armour/Helmet the creature is wearing.    //
//                              If you do not want to use this function, you  //
//                              may want to consider the next one (called     //
//                              nMoveArmour).  nCopyArmour takes precedence   //
//                              over nMoveArmour if both are TRUE.            //
//                                                                            //
//  int nMoveArmour  = FALSE    Setting this TRUE will just move the armour   //
//                              from the Chest slot to the lootable corpse    //
//                              placeable on death; it will also move the     //
//                              helmet from the Head slot to the lootable     //
//                              corpse placeable.  This can be a visual issue //
//                              when used with NPCs - since when the armour   //
//                              is moved, the NPC will become 'naked'.        //
//                                                                            //
//  *** If you do not wish to use either of the armour functions, just set    //
//      both values to FALSE. Then just add an additional suit of armour      //
//      and/or helmet to the inventory of creatures you want to have drop     //
//      their armour/helmet.                                                  //
//                                                                            //
//  int nDropWeapons =  TRUE    This will use the ResRef for dropping the     //
//                              weapons on the ground - which is accomplished //
//                              by creating new ones on the ground and        //
//                              destroying the ones in the creature's         //
//                              inventory.  NOTE: Even though the parameter   //
//                              is called nDropWeapons, anything held in the  //
//                              left or right hand (shield, torch, etc.) is   //
//                              affected by this parameter.  nDropWeapons     //
//                              takes precedence over nMoveWeapons if both    //
//                              are TRUE.                                     //
//                                                                            //
//  int nMoveWeapons = FALSE    Setting this TRUE will just move the weapons  //
//                              to the Lootable Object just as the rest of    //
//                              inventory is handled.  NOTE: Even though the  //
//                              parameter is called nMoveWeapons, anything    //
//                              held in the left or right hand (shield,       //
//                              torch, etc.) is affected by this parameter.   //
//                                                                            //
//  *** If you do not wish to use either of the weapon functions, just set    //
//      both values to FALSE. Then just add additional weapons/shields/       //
//      torches to the inventory of creatures you want to have drop those     //
//      items.                                                                //
//                                                                            //
//  int nUseBlood =     TRUE    Set this to TRUE if you want a Bloodspot to   //
//                              appear under the corpse for a little extra    //
//                              gory appeal. In addition, it will allow for   //
//                              a grisly display if the corpse is destroyed.  //
//                              Undead/constructs/elementals will not leave a //
//                              Bloodspot or "gib" when bashed.               //
//                                                                            //
//  int nTinyBlood = FALSE      Set this to FALSE if you don't want Tiny-     //
//                              sized creatures (rats, bats, etc.) to leave a //
//                              Bloodspot, scorch mark, or small flame.  They //
//                              will still "gib" normally.  Only applies if   //
//                              nUseBlood = TRUE.                             //
//                                                                            //
//  int nUseFlame =     TRUE    Set this to TRUE if you want a scorch mark or //
//                              a small flame (which burns out after 10-120   //
//                              seconds, and is replaced by a scorch mark) to //
//                              appear if 1/3 or more of the damage which     //
//                              killed the creature was fire or electrical.   //
//                              Scorch mark or flame will appear instead of   //
//                              Bloodspot.  If the total fire or electrical   //
//                              damage exceeds the creature's max HP, a small //
//                              flame appears instead of a scorch mark.  The  //
//                              corpse will still gib normally.  Undead,      //
//                              constructs, and elementals will leave a       //
//                              scorch mark, small flame, or nothing.  Only   //
//                              applies if nUseBlood = TRUE.                  //
//                                                                            //
//  int nCorpseFade =   0       This is the delay in actual seconds that the  //
//                              corpse will remain before it fades. If you    //
//                              set this to 0 (zero) it will turn off the     //
//                              corpse fade - allowing all bodies and loot    //
//                              to remain indefinitely.                       //
//                                                                            //
//  int nUseBonesBash = TRUE    Set this to TRUE if you want bones to appear  //
//                              when the corpse is bashed.  The bones cannot  //
//                              be bashed; they will only disappear if        //
//                              nBonesFade > 0.                               //
//                                                                            //
//  int nUseBonesFade = TRUE    Set this to TRUE if you want bones to appear  //
//                              when the corpse fades.  The bones cannot      //
//                              be bashed; they will only disappear if        //
//                              nBonesFade > 0.                               //
//                                                                            //
//  int nBonesFade = 60         This is the delay in actual seconds that the  //
//                              bones will remain before they fade.  If you   //
//                              set this to 0 (zero) it will turn off the     //
//                              bones fade - allowing all bones (and loot,    //
//                              if the bones contain any) to remain forever.  //
//                                                                            //
//  int nTinyBones = FALSE      Set this to FALSE if you don't want Tiny-     //
//                              sized creatures (rats, bats, etc.) to turn    //
//                              into bones when their corpse is bashed or     //
//                              fades.  Only applies if nUseBonesBash and/or  //
//                              nUseBonesFade = TRUE.                         //
//                                                                            //
//  int nKeepInventoryBash = FALSE   Set this to TRUE if you want all items   //
//                                   in a creature's inventory to remain when //
//                                   its corpse is bashed.  If installed,     //
//                                   DOA's "Bashed Loot Breakage" plugin      //
//                                   ("doa_bashbreak") takes precedence over  //
//                                   nKeepInventoryBash.                      //
//                                                                            //
//  int nKeepInventoryFade = FALSE   Set this to TRUE if you want all items   //
//                                   in a creature's inventory to remain when //
//                                   its corpse fades.                        //
//                                                                            //
//  int nKeepEmpties =  TRUE    Set this to FALSE if you want EMPTY corpses   //
//                              to fade immediately after their inventory is  //
//                              emptied (and dropped weapons are claimed,     //
//                              unless nKeepWeaponsEmpty is TRUE).            //
//                                                                            //
//  int nKeepWeaponsBonesFade = FALSE    Set this to FALSE if you want        //
//                                       dropped, unclaimed, non-plot weapons //
//                                       to be destroyed when bones fade.     //
//                                       Only valid if nBonesFade > 0.        //
//                                                                            //
//  int nKeepWeaponsCorpseFade = TRUE    Set this to FALSE if you want        //
//                                       dropped, unclaimed, non-plot weapons //
//                                       to be destroyed when corpses fade.   //
//                                       Only valid if nCorpseFade > 0.       //
//                                                                            //
//  int nKeepWeaponsBash = TRUE          Set this to FALSE if you want        //
//                                       dropped, unclaimed, non-plot weapons //
//                                       to be destroyed when corpses are     //
//                                       bashed.                              //
//                                                                            //
//  int nKeepWeaponsEmpty = TRUE         Set this to TRUE if you want empty   //
//                                       corpses to be destroyed even if      //
//                                       dropped weapons are unclaimed.       //
//                                                                            //
//  *** Even though the 4 parameters listed above start with "nKeepWeapons",  //
//      anything held in the left or right hand (shield, torch, etc.) is      //
//      affected by these parameters, not just weapons.                       //
//                                                                            //
//  int nOverrideForPlacedCorpses = TRUE    Set this to TRUE if you want the  //
//                                          'Spawned Corpses' you place to be //
//                                          permament. Setting it to FALSE    //
//                                          will cause your Placed Dead       //
//                                          creatures to act as the settings  //
//                                          above dictate. (i.e. Fading Out   //
//                                          after the delay or being emptied) //
//                                          To use this functionality, you    //
//                                          should place the _kb_plc_corpse   //
//                                          script in the OnSpawn of the      //
//                                          critter you want to spawn dead.   //
//                                                                             //
////////////////////////////////////////////////////////////////////////////////

/*  Version 3.3 Change Log:
    - added SetPlotFlag to ensure oLootCorpse can't be destroyed before oHostBody is emptied (and weapons are dropped)
    - fixed comments to clarify that "doa_bashbreak" script refers to DOA's "Bashed Loot Breakage" plugin
/*  Version 3.2 Change Log:
    - consolidated inventory management functions to _kb_inc_invmgmt
    - DestroyInventory function calls changed to DestroyInventory + DestroyDroppedWeapons in _kb_inc_invmgmt (identical)
    - added nTinyBlood and nUseFlame (added Flameout function and rewrote Bloodspot routine)
    - added GetIsObjectValid check before destroying Bloodspot
    - removed ActionWait (wasn't needed)
    - combined several DelayCommand's into a single function (FadeCorpse) to improve performance
    - improved FadeCorpse to take advantage of new functionality (nKeepInventoryFade, nUseBonesFade, etc.)
    - fixed bug in DropLeftWeapon/DropRightWeapon that caused dropped weapons to have incorrect GetIdentified value
    - fixed bug where 2 copies of droppable, equipped, Plot armor were created instead of 1 when corpse was bashed
    - fixed bug that caused copied armor to have incorrect GetPlotFlag and GetIdentified values
    - added nUseBonesBash to create bones when corpse is bashed
    - added nUseBonesFade to create bones when corpse fades
    - added nBonesFade to determine when bones fade (if ever)
    - added nTinyBones to prevent bones from appearing for tiny-sized creatures
    - added nKeepInventoryBash to keep all items in a creature's inventory when its corpse is bashed
    - added nKeepInventoryFade to keep all items in a creature's inventory when its corpse fades
    - replaced nKeepWeapons with: nKeepWeaponsBonesFade, nKeepWeaponsCorpseFade, nKeepWeaponsBash, and nKeepWeaponsEmpty
    - changed comments to clarify weapons/shields/torches are affected by "weapons" parameters/functions
    - changed comments to reflect that undead/constructs/elementals will not leave Bloodspot or "gib" when bashed
    - fixed bug so that nCopyArmour takes precedence over nMoveArmour if both are TRUE
    - added comments to clarify that nCopyArmour takes precedence over nMoveArmour if both are TRUE
    - added comments to clarify that nDropWeapons takes precedence over nMoveWeapons if both are TRUE
    - renamed oDeadNPC to oHostBody, and vDeadNPCLoc to vHostBodyLoc for consistency
    - fixed bug so that nCopyArmour/nMoveArmour affect helmets equipped in the creature's Head slot, as well
    - added support for "Destroy Target" command of DM's Helper wand (used to destroy the corpse or bones)
    - added code to pass oLeftWpn/oRightWpn from oHostBody to oLootCorpse for use with Scrotok's Raise Dead/Ressurection Plugin
*/

#include "_kb_inc_invmgmt"
#include "sd_lootsystem"



/*******************************************************************************
 ** This script was borrowed from the Hard Core Ruleset, where they use it to **
 ** move a Dead PC's inventory to a lootable corpse object. Credit where      **
 ** credit is due, I always say. :)                                           **
 *******************************************************************************/
object strip_equipped(object oHostBody, object oLootCorpse, object oEquip)
{
    if(GetIsObjectValid(oEquip) && GetDroppableFlag(oEquip))
     {
        AssignCommand(oLootCorpse, ActionTakeItem(oEquip, oHostBody));
     }
    return oEquip;
}

/*******************************************************************************
 ** These scripts drop weapons/shields/torches held in the corpse's hands.    **
 **                                                                           **
 ** SPECIAL THANKS TO DREZDAR and MOJO for their help in getting these two    **
 ** drop weapon scripts written. I never would have gotten the vectors right, **
 ** but THEY sure did!                                                        **
 **                                                                           **
 ** (East = 0, North = 90, West = 180, South = 270)                           **
 **                                                                           **
 *******************************************************************************/
void DropLeftWeapon(object oLeftWpn, object oLootCorpse)
{
   if(GetIsObjectValid(oLeftWpn) && GetDroppableFlag(oLeftWpn))
    {
        vector vCorpseLoc = GetPositionFromLocation(GetLocation(oLootCorpse));
        float fDifferential = 45.0f + IntToFloat(d20());//Randomize the Drop Angle
        float fDistance = 0.5f + (IntToFloat(d10())/10);//Randomize the Drop Distance
        float fVarWpnFace = -20.0f - IntToFloat(d20(2));//Randomize the Drop Facing
        float fFacing = GetFacing(oLootCorpse);
        fFacing = fFacing + fDifferential;
        if (fFacing > 360.0f)
        {   fFacing = 720.0f - fFacing; }
        if (fFacing < 0.0f)
        {   fFacing = 360.0f + fFacing; }
        float fWpnFacing = GetFacing(oLootCorpse) + fVarWpnFace;
        if (fWpnFacing > 360.0f)
        {   fWpnFacing = 720.0f - fWpnFacing; }
        if (fWpnFacing < 0.0f)
        {   fWpnFacing = 360.0f + fWpnFacing; }
        object oArea = GetArea(oLootCorpse);
        //Generate New Location
        float fNewX;
        float fNewY;
        float fNewZ;
        if ((fFacing > 0.0f) && (fFacing < 90.0f))
        {   fNewX = vCorpseLoc.x + ((cos(fFacing))*fDistance); fNewY = vCorpseLoc.y + ((sin(fFacing))*fDistance); fNewZ = vCorpseLoc.z; }
        else if ((fFacing > 90.0f) && (fFacing < 180.0f))
        {   fNewX = vCorpseLoc.x - ((cos(180.0f - fFacing))*fDistance); fNewY = vCorpseLoc.y + ((sin(180.0f - fFacing))*fDistance); fNewZ = vCorpseLoc.z; }
        else if ((fFacing > 180.0f) && (fFacing < 270.0f))
        {   fNewX = vCorpseLoc.x - ((cos(fFacing - 180.0f))*fDistance); fNewY = vCorpseLoc.y - ((sin(fFacing - 180.0f))*fDistance); fNewZ = vCorpseLoc.z; }
        else if ((fFacing > 270.0f) && (fFacing < 360.0f))
        {   fNewX = vCorpseLoc.x + ((cos(360.0f - fFacing))*fDistance); fNewY = vCorpseLoc.y - ((sin(360.0f - fFacing))*fDistance); fNewZ = vCorpseLoc.z; }
        else if (fFacing == 0.0f)
        {   fNewX = vCorpseLoc.x + fDistance; fNewY = vCorpseLoc.y; fNewZ = vCorpseLoc.z; }
        else if (fFacing == 90.0f)
        {   fNewX = vCorpseLoc.x; fNewY = vCorpseLoc.y + fDistance; fNewZ = vCorpseLoc.z; }
        else if (fFacing == 180.0f)
        {   fNewX = vCorpseLoc.x - fDistance; fNewY = vCorpseLoc.y; fNewZ = vCorpseLoc.z; }
        else if (fFacing == 270.0f)
        {   fNewX = vCorpseLoc.x; fNewY = vCorpseLoc.y - fDistance; fNewZ = vCorpseLoc.z; }
        vector vNewFinal = Vector(fNewX, fNewY, fNewZ);
        location lDropLeft = Location(oArea, vNewFinal, fWpnFacing);
        //Drop Weapon
        string sLeftWpnRef = GetResRef(oLeftWpn);
        int nID = GetIdentified(oLeftWpn);
        if (GetPlotFlag(oLeftWpn))
         {
            SetPlotFlag(oLeftWpn, FALSE);
            DestroyObject(oLeftWpn);
            oLeftWpn = CreateObject(OBJECT_TYPE_ITEM, sLeftWpnRef, lDropLeft, FALSE);
            SetPlotFlag(oLeftWpn, TRUE);
         }
        else
         {
            DestroyObject(oLeftWpn);
            oLeftWpn = CreateObject(OBJECT_TYPE_ITEM, sLeftWpnRef, lDropLeft, FALSE);
         }
        SetIdentified(oLeftWpn, nID);
        SetLocalObject(oLootCorpse, "oLeftWpn", oLeftWpn);
    }
   // We're done with oHostBody, so allow oLootCorpse to be destroyable
   AssignCommand(oLootCorpse, ActionDoCommand(SetPlotFlag(oLootCorpse, FALSE)));
}

void DropRightWeapon(object oRightWpn, object oLootCorpse)
{
   if(GetIsObjectValid(oRightWpn) && GetDroppableFlag(oRightWpn))
    {
        vector vCorpseLoc = GetPositionFromLocation(GetLocation(oLootCorpse));
        float fDifferential = -45.0f + IntToFloat(d20());//Randomize the Drop Angle
        float fDistance = 0.5f + (IntToFloat(d10())/10);//Randomize the Drop Distance
        float fVarWpnFace = 20.0f - IntToFloat(d20(2));//Randomize the Drop Facing
        float fFacing = GetFacing(oLootCorpse);
        fFacing = fFacing + fDifferential;
        if (fFacing > 360.0f)
        {   fFacing = 720.0f - fFacing; }
        if (fFacing < 0.0f)
        {   fFacing = 360.0f + fFacing; }
        float fWpnFacing = GetFacing(oLootCorpse) + fVarWpnFace;
        if (fWpnFacing > 360.0f)
        {   fWpnFacing = 720.0f - fWpnFacing; }
        if (fWpnFacing < 0.0f)
        {   fWpnFacing = 360.0f + fWpnFacing; }
        object oArea = GetArea(oLootCorpse);
        //Generate New Location
        float fNewX;
        float fNewY;
        float fNewZ;
        if ((fFacing > 0.0f) && (fFacing < 90.0f))
        {   fNewX = vCorpseLoc.x + ((cos(fFacing))*fDistance); fNewY = vCorpseLoc.y + ((sin(fFacing))*fDistance); fNewZ = vCorpseLoc.z; }
        else if ((fFacing > 90.0f) && (fFacing < 180.0f))
        {   fNewX = vCorpseLoc.x - ((cos(180.0f - fFacing))*fDistance); fNewY = vCorpseLoc.y + ((sin(180.0f - fFacing))*fDistance); fNewZ = vCorpseLoc.z; }
        else if ((fFacing > 180.0f) && (fFacing < 270.0f))
        {   fNewX = vCorpseLoc.x - ((cos(fFacing - 180.0f))*fDistance); fNewY = vCorpseLoc.y - ((sin(fFacing - 180.0f))*fDistance); fNewZ = vCorpseLoc.z; }
        else if ((fFacing > 270.0f) && (fFacing < 360.0f))
        {   fNewX = vCorpseLoc.x + ((cos(360.0f - fFacing))*fDistance); fNewY = vCorpseLoc.y - ((sin(360.0f - fFacing))*fDistance); fNewZ = vCorpseLoc.z; }
        else if (fFacing == 0.0f)
        {   fNewX = vCorpseLoc.x + fDistance; fNewY = vCorpseLoc.y; fNewZ = vCorpseLoc.z; }
        else if (fFacing == 90.0f)
        {   fNewX = vCorpseLoc.x; fNewY = vCorpseLoc.y + fDistance; fNewZ = vCorpseLoc.z; }
        else if (fFacing == 180.0f)
        {   fNewX = vCorpseLoc.x - fDistance; fNewY = vCorpseLoc.y; fNewZ = vCorpseLoc.z; }
        else if (fFacing == 270.0f)
        {   fNewX = vCorpseLoc.x; fNewY = vCorpseLoc.y - fDistance; fNewZ = vCorpseLoc.z; }
        vector vNewFinal = Vector(fNewX, fNewY, fNewZ);
        location lDropRight = Location(oArea, vNewFinal, fWpnFacing);
        //Drop Weapon
        string sRightWpnRef = GetResRef(oRightWpn);
        int nID = GetIdentified(oRightWpn);
        if (GetPlotFlag(oRightWpn))
         {
            SetPlotFlag(oRightWpn, FALSE);
            DestroyObject(oRightWpn);
            oRightWpn = CreateObject(OBJECT_TYPE_ITEM, sRightWpnRef, lDropRight, FALSE);
            SetPlotFlag(oRightWpn, TRUE);
         }
        else
         {
            DestroyObject(oRightWpn);
            oRightWpn = CreateObject(OBJECT_TYPE_ITEM, sRightWpnRef, lDropRight, FALSE);
         }
        SetIdentified(oRightWpn, nID);
        SetLocalObject(oLootCorpse, "oRightWpn", oRightWpn);
    }
}

/*******************************************************************************
 ** This script gets rid of the bloodspot, lootable corpse, and creature body **
 *******************************************************************************/
void FadeCorpse(object oCorpseBlood, object oLootCorpse, object oHostBody)
{
   //Delete the BloodSpot (if created)
   if (GetIsObjectValid(oCorpseBlood))
    {
       DestroyObject(oCorpseBlood);
    }
   // Empty (or don't empty) the lootable corpse placeable
   if (GetLocalInt(oLootCorpse, "nKeepInventoryFade") == FALSE)
      // Delete all items (except Plot) from lootable corpse placeable
      DestroyInventory(oLootCorpse);
   else
    {
       // Do nothing (delete nothing from lootable corpse placeable)
    }
   // If user wants bones to be created when corpse fades...
   if (GetLocalInt(oLootCorpse, "nUseBonesFade"))
    {
       if ((GetLocalInt(oLootCorpse, "nTinyBones") == FALSE) && (GetCreatureSize(oHostBody) == CREATURE_SIZE_TINY))
        {
           // Do nothing -- no bones for tiny creatures if nTinyBones is FALSE
        }
       else
        {
           // Create the bones
           object oBones = CreateObject(OBJECT_TYPE_PLACEABLE, "loot_bones_obj", GetLocation(oLootCorpse), FALSE);
           // Move inventory to bones
           TransferToBones(oLootCorpse, oBones);
           // Fade bones after nBoneFade seconds
           if (GetLocalInt(oLootCorpse, "nBonesFade") > 0)
            {
               // Remember racial type and Blueprint ResRef for use with Scrotok's Raise Dead/Resurrection plugin
               SetLocalInt(oBones, "nRacialType", GetLocalInt(oLootCorpse, "nRacialType"));
               SetLocalString(oBones, "sHostBodyResRef", GetLocalString(oLootCorpse, "sHostBodyResRef"));
               // Pass dropped weapon/shield/torch info to bones
               SetLocalObject(oBones, "oLeftWpn", GetLocalObject(oLootCorpse, "oLeftWpn"));
               SetLocalObject(oBones, "oRightWpn", GetLocalObject(oLootCorpse, "oRightWpn"));
               int nKeepWeaponsBonesFade = GetLocalInt(oLootCorpse, "nKeepWeaponsBonesFade");
               // Remember nKeepWeaponsBonesFade for use with DM's Helper wand
               SetLocalInt(oBones, "nKeepWeaponsBonesFade", nKeepWeaponsBonesFade);
               float fBonesFade = IntToFloat(GetLocalInt(oLootCorpse, "nBonesFade"));
               AssignCommand(oBones, DelayCommand(fBonesFade, BonesCleanup(oBones, nKeepWeaponsBonesFade)));
            }
        }
    }
   // Delete unclaimed, dropped, non-Plot weapons unless nKeepWeaponsCorpseFade = 1
   if (!GetLocalInt(oLootCorpse, "nKeepWeaponsCorpseFade"))
      DestroyDroppedWeapons(oLootCorpse);
   // Delete the lootable corpse placeable
   DestroyObject(oLootCorpse);
   // Empty and delete actual creature corpse (body)
   DestroyInventory(oHostBody);
   /*  There is no call to DestroyDroppedWeapons since if the weapons are
       dropped, they are already deleted from oHostBody. If the weapons are
       not dropped, then the function would still not delete the weapons
       since GetItemPossessor would be a valid object */
   SetIsDestroyable(TRUE,FALSE,FALSE);
   // NOTE: The following line MUST be last in this script, since oHostBody
   // is the same as OBJECT_SELF
   DestroyObject(oHostBody);
}

/*******************************************************************************
 ** This script replaces the small flame with a scorch mark                   **
 *******************************************************************************/
void Flameout(object oCorpseBlood, object oLootCorpse)
{
   location lBloodLoc = GetLocation(oCorpseBlood);
/*
   // Used for debugging
   SendMessageToPC(GetFirstPC(), "Flame script started...");
   if (!GetIsObjectValid(oCorpseBlood))
    {
       // This should never happen (if you bash/fade corpse, oHostBody is
       // destroyed, so Flameout won't run (can't add to action queue of invalid
       // object)
       SendMessageToPC(GetFirstPC(), "Flame already destroyed... location for new scorch unknown?");
    }
*/
   // Get rid of small flame
   DestroyObject(oCorpseBlood);
   // ... and turn it into a scorch mark
   oCorpseBlood = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_weathmark", lBloodLoc, FALSE);
   ExecuteScript("sl_destroyself2", oCorpseBlood);
   //Set Local for deletion later if needed
   SetLocalObject(oLootCorpse, "oBloodSpot", oCorpseBlood);
}

void BodyFade(object oHostBody, object oBlood)
{
  object oBones;
  location lLoc = GetLocation(oHostBody);
  SetPlotFlag(oHostBody, FALSE);
  AssignCommand(oHostBody, SetIsDestroyable(TRUE,FALSE,FALSE));
  if ((GetRacialType(oHostBody) != RACIAL_TYPE_CONSTRUCT) &&
      (GetRacialType(oHostBody) != RACIAL_TYPE_ELEMENTAL)&&
      (GetRacialType(oHostBody) != RACIAL_TYPE_DRAGON)&&
      (GetRacialType(oHostBody) != RACIAL_TYPE_ANIMAL)&&
       GetTag(oHostBody)!="sd_coff_mummy")

     {
      oBones = CreateObject(OBJECT_TYPE_PLACEABLE, "sd_remains", lLoc, FALSE);
      ExecuteScript("sl_destroyself", oBones);
     }
  DestroyObject(oBlood);
  if (GetIsDead(oHostBody))DestroyObject(oHostBody, 0.2f);
 }

void LeaveCorpse()
{
    //SET YOUR LOOTABLE CORPSES PREFERENCES HERE ///////////////
                                                                                                                               //
    int nUseLootable =   TRUE;             // Set this to FALSE if you want disable the lootable corpse functionality          //
    int nMoveEquipped =  FALSE;            // Set this to FALSE if you don't want to move Equipped items to the corpse         //
    int nCopyArmour  =   FALSE;             // This will use the ResRef to create a copy of the armour/helmet                   //
    int nMoveArmour  =   FALSE;             // Setting this TRUE will just move the armour/helmet (Naked NPCs)                  //
    int nDropWeapons =   TRUE;             // This will use the ResRef for dropping the weapons on the ground                  //
    int nMoveWeapons =  FALSE;             // Setting this TRUE will just move the weapons to the Lootable Object              //
    int nUseBlood =      FALSE;             // Set this to TRUE if you want a Bloodspot to appear under the corpse and have     //
                                           //   "gibs" when a corpse is destroyed.  Undead/constructs/elementals won't leave a //
                                           //   Bloodspot or gib.                                                              //
    int nTinyBlood =     FALSE;             // Set this to FALSE if you don't want Tiny-sized creatures (rats, bats, etc.) to   //
                                           //   leave a Bloodspot, scorch mark, or small flame.  They will still "gib"         //
                                           //   normally.  Only applies if nUseBlood = TRUE.                                   //
    int nUseFlame =      FALSE;             // Set this to TRUE if you want a scorch mark or a small flame (which burns out     //
                                           //   after 10-120 seconds, and is replaced by a scorch mark) to appear if 1/3 or    //
                                           //   more of the damage which killed the creature was fire or electrical.  Scorch   //
                                           //   mark or flame will appear instead of Bloodspot.  If the total fire or          //
                                           //   electrical damage exceeds the creature's max HP, a small flame appears instead //
                                           //   of a scorch mark.  The corpse will still gib normally.  Undead, constructs,    //
                                           //   and elementals will leave a scorch mark, small flame, or nothing.  Only        //
                                           //   applies if nUseBlood = TRUE.                                                   //
    int nCorpseFade =     0;              // Set this to 0 (ZERO) if you DO NOT want the corpses to fade                      //
    int nUseBonesBash =  FALSE;             // Set this to TRUE if you want bones to appear when the corpse is bashed.  The     //
                                           //   bones cannot be bashed; they will only disappear if nBonesFade > 0.            //
    int nUseBonesFade =  TRUE;             // Set this to TRUE if you want bones to appear when the corpse fades.  The bones   //
                                           //   cannot be bashed; they will only disappear if nBonesFade > 0.                  //
    int nBonesFade =      120;             // This is the delay in actual seconds that the bones will remain before they fade. //
                                           //   If you set this to 0 (zero) it will turn off the bones fade - allowing all     //
                                           //   bones (and loot, if the bones contain any) to remain forever.                  //
    int nTinyBones =     FALSE;             // Set this to FALSE if you don't want Tiny-sized creatures (rats, bats, etc.) to   //
                                           //   turn into bones when their corpse is bashed or fades.  Only applies if         //
                                           //   nUseBonesBash and/or nUseBonesFade = TRUE.                                     //
    int nKeepInventoryBash = FALSE;        // Set this to TRUE if you want all items in a creature's inventory to remain when  //
                                           //   its corpse is bashed.  If installed, DOA's "Bashed Loot Breakage" plugin       //
                                           //   ("doa_bashbreak") takes precedence over nKeepInventoryBash.                    //
    int nKeepInventoryFade = FALSE;        // Set this to TRUE if you want all items in a creature's inventory to remain when  //
                                           //   its corpse fades.                                                              //
    int nKeepEmpties =   TRUE;             // Set this to FALSE if you want EMPTY corpses to fade immediately.                 //
    int nKeepWeaponsBonesFade = FALSE;     // Set this to FALSE if you want dropped, unclaimed, non-plot weapons to be         //
                                           //   destroyed when bones fade.  Only valid if nBonesFade > 0.                      //
    int nKeepWeaponsCorpseFade = FALSE;    // Set this to FALSE if you want dropped, unclaimed, non-plot weapons to be         //
                                           //   destroyed when corpses fade.  Only valid if nCorpseFade > 0.                   //
    int nKeepWeaponsBash = TRUE;           // Set this to FALSE if you want dropped, unclaimed, non-plot weapons to be         //
                                           //   destroyed when corpses are bashed.                                             //
    int nKeepWeaponsEmpty = TRUE;          // Set this to TRUE if you want empty corpses to be destroyed even if dropped       //
                                           //   weapons are unclaimed.                                                         //
    int nOverrideForPlacedCorpses =  FALSE;// Set this to TRUE if you want the 'Spawned Corpses' you                           //
                                           //   place to be permament. Setting it to FALSE will cause                          //
                                           //   your Placed Dead creatures to act as the settings above dictate.               //


    float lsDelay  = 240.0;                   // Corpse & loot fade delay


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //ALTER THE FOLLOWING AT YOUR OWN RISK :)
    object oHostBody = OBJECT_SELF; //Get the Dead Creature Object
    object oBlood;
    object oSaveBlood;
    string sBaseTag = GetTag(oHostBody); //Get that TAG of the dead creature
    string sPrefix = GetStringLeft(sBaseTag, 4); //Look for Dead Prefix
    location lLoc = GetLocation(oHostBody);

    if ((GetRacialType(oHostBody) != RACIAL_TYPE_UNDEAD) &&
        (GetRacialType(oHostBody) != RACIAL_TYPE_CONSTRUCT) &&
        (GetRacialType(oHostBody) != RACIAL_TYPE_ELEMENTAL)&&
        (GetRacialType(oHostBody) != RACIAL_TYPE_DRAGON))
     {
      oBlood = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_bloodstain", lLoc, FALSE);
     }
    DelayCommand(lsDelay, BodyFade(oHostBody, oBlood));



    if(nUseLootable) //If False, do nothing
    {

        //Do 'spawned corpse' settings if desired
        if (sPrefix == "Dead")
        {
            if (nOverrideForPlacedCorpses)
            {
                nKeepEmpties = TRUE; //Set 'Spawned Dead' corpses to Keep Empties
                nCorpseFade = 0; //Disable Corpse Fade for 'Spawned Dead' corpses
            }
        }

        SetIsDestroyable(FALSE,TRUE,FALSE); //Protect our corpse from decaying

/*
UNDER CONSTRUCTION :)

     // Create lootable corpse object only if oHostBody has something to loot
     if (GetIsObjectValid(GetFirstItemInInventory(oHostBody)))
      {

      }
     else
      {
         // Don't create lootable corpse object(nothing to loot)
         if (nKeepEmpties == FALSE)
          {
             // Get rid of corpse immediately, since it's already empty
             nCorpseFade = 1;
          }
         else
          {
             // Ensure oHostBody is destroyed/fades properly
             // Ensure blood spot is created and destroyed/fades properly
          }
      }
*/

        //Set the spawnpoint for our lootable object and sink it
        float fSinkCorpseObj = 0.1f; //set depth to sink lootable object
        vector vHostBodyLoc = GetPosition(oHostBody); //get original vector so we can change it
        float fCorpseFacing = GetFacing(oHostBody); //get original facing
        vector vCorpseLoc = Vector(vHostBodyLoc.x, vHostBodyLoc.y, vHostBodyLoc.z - fSinkCorpseObj); //adjust z-axis to sink lootable object
        location lCorpseLoc = Location(GetArea(oHostBody), vCorpseLoc, fCorpseFacing); //create new location

        object oLootCorpse = CreateObject(OBJECT_TYPE_PLACEABLE, "rr_sack", lCorpseLoc, FALSE); //Spawn our lootable object
        SetLocalObject(oLootCorpse, "oHostBody", oHostBody); //Set Local for deletion later if needed
        SetLocalObject(oLootCorpse, "oBlood", oBlood);
        NameSack(oLootCorpse);
        DelayCommand(0.1,sd_droploot(oHostBody, oLootCorpse));
        DelayCommand(lsDelay, LootClear(oLootCorpse));

        // Ensure oLootCorpse can't be destroyed until oHostBody is emptied (and weapons are dropped)
        //SetPlotFlag(oLootCorpse, TRUE);

        SetLocalInt(oLootCorpse, "nKeepEmpty", nKeepEmpties); //Set Local for deletion later if needed

        SetLocalInt(oLootCorpse, "nUseBonesBash", nUseBonesBash); //Set Local for later use
        SetLocalInt(oLootCorpse, "nUseBonesFade", nUseBonesFade); //Set Local for later use
        SetLocalInt(oLootCorpse, "nBonesFade", nBonesFade); //Set Local for later use
        SetLocalInt(oLootCorpse, "nTinyBones", nTinyBones); //Set Local for later use

        SetLocalInt(oLootCorpse, "nKeepInventoryBash", nKeepInventoryBash); //Set Local for later use
        SetLocalInt(oLootCorpse, "nKeepInventoryFade", nKeepInventoryFade); //Set Local for later use

        // Remember racial type and Blueprint ResRef for use with Scrotok's Raise Dead/Resurrection plugin
        SetLocalInt(oLootCorpse, "nRacialType", GetRacialType(oHostBody));
        SetLocalString(oLootCorpse, "sHostBodyResRef", GetResRef(oHostBody));

        object oCorpseBlood;
        // If nUseBlood is TRUE and oHostBody isn't Undead/Construct/Elemental, set Local for later "gibbing" if bashed
        if ((nUseBlood) && (GetRacialType(oHostBody) != RACIAL_TYPE_UNDEAD) && (GetRacialType(oHostBody) != RACIAL_TYPE_CONSTRUCT) && (GetRacialType(oHostBody) != RACIAL_TYPE_ELEMENTAL))
         {
            SetLocalInt(oLootCorpse, "nUseBlood", TRUE);
         }
        // If nUseBlood = TRUE, continue Bloodspot routine
        if (nUseBlood)
         {
            location lBloodLoc = GetLocation(oHostBody); //get original location for placing blood spot
            if ((nTinyBlood == FALSE) && (GetCreatureSize(oHostBody) == CREATURE_SIZE_TINY))
             {
                // Do nothing -- no bloodspot for tiny creatures if nTinyBlood is FALSE
             }
            else
             {
                if (nUseFlame)
                 {
                    // If nUseFlame = TRUE, determine if scorch, flame, or bloodspot should appear
                    int nFireDam = GetDamageDealtByType(DAMAGE_TYPE_FIRE);
                    int nElecDam = GetDamageDealtByType(DAMAGE_TYPE_ELECTRICAL);
                    int nTotDam = GetTotalDamageDealt();
                    int nMaxHP = GetMaxHitPoints();
                    int nFlameout;

/*
                    // Used for debugging
                    SendMessageToPC(GetFirstPC(), "nFireDam: "+IntToString(nFireDam)+" nElecDam: "+IntToString(nElecDam)+" nTotDam: "+IntToString(nTotDam)+" nMaxHP: "+IntToString(nMaxHP)+" nTotDam/3: "+IntToString(nTotDam/3));
*/

                    // If 1/3 or more of the damage is due to fire or electricity...
                    // (only the final damage that actually killed the creature is
                    // considered; tracking the cumulative damage taken would require
                    // altering the default OnDamaged script for every creature,
                    // which is not desirable)
                    if ((nFireDam >= (nTotDam/3)) || (nElecDam >= (nTotDam/3)))
                     {
                        // If massive fire or electricity damage, spawn a small flame
                        // which turns into a scorch mark after 10-120 seconds
                        // ("massive" means >= max HP)
                        if ((nFireDam >= nMaxHP) || (nElecDam >= nMaxHP))
                         {
                            oCorpseBlood = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_flamesmall", lBloodLoc, FALSE);
                            ExecuteScript("sl_destroyself", oCorpseBlood);
/*
                            // Used for debugging
                            nFlameout = 30;
*/
                            nFlameout = d12(10);
                            DelayCommand(IntToFloat(nFlameout), Flameout(oCorpseBlood, oLootCorpse));
                         }
                        else
                         {
                            // Otherwise, spawn a scorch mark
                            oCorpseBlood = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_weathmark", lBloodLoc, FALSE);
                            ExecuteScript("sl_destroyself", oCorpseBlood);
                         }
                     }
                    else
                     {
                        // Not enough (or zero) fire/electrical damage, so just spawn bloodspot (or do nothing for Undead/Constructs/Elementals)
                        if ((GetRacialType(oHostBody) != RACIAL_TYPE_UNDEAD) && (GetRacialType(oHostBody) != RACIAL_TYPE_CONSTRUCT) && (GetRacialType(oHostBody) != RACIAL_TYPE_ELEMENTAL))
                         {
                            oCorpseBlood = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_bloodstain", lBloodLoc, FALSE);
                            ExecuteScript("sl_destroyself", oCorpseBlood);
                         }
                     }
                 }
                else
                 {
                    // If nUseFlame = FALSE, just spawn the bloodspot (or do nothing for Undead/Constructs/Elementals)
                    if ((GetRacialType(oHostBody) != RACIAL_TYPE_UNDEAD) && (GetRacialType(oHostBody) != RACIAL_TYPE_CONSTRUCT) && (GetRacialType(oHostBody) != RACIAL_TYPE_ELEMENTAL))
                     {
                        oCorpseBlood = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_bloodstain", lBloodLoc, FALSE);
                        ExecuteScript("sl_destroyself", oCorpseBlood);
                     }
                 }
                // oBloodSpot will either be a bloodstain, scorch mark, small flame, or OBJECT_INVALID (for Undead/Constructs/Elementals)
                SetLocalObject(oLootCorpse, "oBloodSpot", oCorpseBlood); //Set Local for deletion later if needed
             }
         }

        // Get DEAD CREATURE'S INVENTORY - Move to oLootCorpse
        int nAmtGold = GetGold(oHostBody); //Get any gold from the dead creature
        if(nAmtGold)
        {
            AssignCommand(oLootCorpse, TakeGoldFromCreature(nAmtGold, oHostBody, FALSE));
        }

        if (nMoveEquipped)
        {
            //Get any DROPPABLE loot the dead creature has equipped
            object oEquip1 = strip_equipped(oHostBody, oLootCorpse, GetItemInSlot(INVENTORY_SLOT_ARMS, oHostBody));
            object oEquip2 = strip_equipped(oHostBody, oLootCorpse, GetItemInSlot(INVENTORY_SLOT_ARROWS, oHostBody));
            object oEquip3 = strip_equipped(oHostBody, oLootCorpse, GetItemInSlot(INVENTORY_SLOT_BELT, oHostBody));
            object oEquip4 = strip_equipped(oHostBody, oLootCorpse, GetItemInSlot(INVENTORY_SLOT_BOLTS, oHostBody));
            object oEquip5 = strip_equipped(oHostBody, oLootCorpse, GetItemInSlot(INVENTORY_SLOT_BOOTS, oHostBody));
            object oEquip6 = strip_equipped(oHostBody, oLootCorpse, GetItemInSlot(INVENTORY_SLOT_BULLETS, oHostBody));
            object oEquip7 = strip_equipped(oHostBody, oLootCorpse, GetItemInSlot(INVENTORY_SLOT_CLOAK, oHostBody));
            // Version 3.2: Moved oEquip8 (helmets) to the armour section (see below)
            object oEquip9 = strip_equipped(oHostBody, oLootCorpse, GetItemInSlot(INVENTORY_SLOT_LEFTRING, oHostBody));
            object oEquip10 = strip_equipped(oHostBody, oLootCorpse, GetItemInSlot(INVENTORY_SLOT_NECK, oHostBody));
            object oEquip11 = strip_equipped(oHostBody, oLootCorpse, GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oHostBody));

            SetLocalObject(oLootCorpse, "oEquip1", oEquip1);
            SetLocalObject(oLootCorpse, "oEquip2", oEquip2);
            SetLocalObject(oLootCorpse, "oEquip3", oEquip3);
            SetLocalObject(oLootCorpse, "oEquip4", oEquip4);
            SetLocalObject(oLootCorpse, "oEquip5", oEquip5);
            SetLocalObject(oLootCorpse, "oEquip6", oEquip6);
            SetLocalObject(oLootCorpse, "oEquip7", oEquip7);
            // Version 3.2: Moved oEquip8 (helmets) to the armour section (see below)
            SetLocalObject(oLootCorpse, "oEquip9", oEquip9);
            SetLocalObject(oLootCorpse, "oEquip10", oEquip10);
            SetLocalObject(oLootCorpse, "oEquip11", oEquip11);
        }

        // Handle Weapons/Shields/Torches equipped (held) in left/right hands
        // NOTE: nDropWeapons takes precedence over nMoveWeapons if both are TRUE
        /*
           If oHostBody has nothing in left/right hand, and has oLeftWpn/
           oRightWpn set (due to Scrotok's Raise Dead/Resurrection plugin),
           set oLeftWpn/oRightWpn (dropped weapon info) on oLootCorpse for
           later use
        */
        if (nDropWeapons)
         {
            if (GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHostBody) == OBJECT_INVALID)
             {
                if (GetIsObjectValid(GetLocalObject(oHostBody, "oRightWpn")))
                 {
                    SetLocalObject(oLootCorpse, "oRightWpn", GetLocalObject(oHostBody, "oRightWpn"));
                 }
             }
            if (GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oHostBody) == OBJECT_INVALID)
             {
                if (GetIsObjectValid(GetLocalObject(oHostBody, "oLeftWpn")))
                 {
                    SetLocalObject(oLootCorpse, "oLeftWpn", GetLocalObject(oHostBody, "oLeftWpn"));
                 }
             }
         }

        if (nMoveWeapons || nDropWeapons)
        {
            //Move equipped Weapons/Shields/Torches from oHostBody to oLootCorpse
            object oEquip12 = strip_equipped(oHostBody, oLootCorpse, GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHostBody));
            object oEquip13 = strip_equipped(oHostBody, oLootCorpse, GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oHostBody));

            // oEquip12/13 == OBJECT_INVALID if oHostBody has nothing in right/left hand slots
            SetLocalObject(oLootCorpse, "oEquip12", oEquip12);
            SetLocalObject(oLootCorpse, "oEquip13", oEquip13);
        }

        if (nDropWeapons)
         {
            // oEquip12/13 == OBJECT_INVALID if oHostBody has nothing in right/left hand slots
            object oEquip12 = GetLocalObject(oLootCorpse, "oEquip12");
            object oEquip13 = GetLocalObject(oLootCorpse, "oEquip13");

            // Drop the weapons/shields/torches
            /*
               The following commands destroy oEquip12 and oEquip13, and store
               the dropped weapons on oLootCorpse as "oLeftWpn" and "oRightWpn".
               Nothing gets stored in oLeftWpn/oRightWpn if oEquip12/13 ==
               OBJECT_INVALID.
            */
            // Make sure DropLeftWeapon comes after DropRightWeapon in the lines
            // below, in order for the SetPlotFlag fix (version 3.3) to work
            AssignCommand(oLootCorpse, ActionDoCommand(DropRightWeapon(oEquip12, oLootCorpse)));
            AssignCommand(oLootCorpse, ActionDoCommand(DropLeftWeapon(oEquip13, oLootCorpse)));

            SetLocalInt(oLootCorpse, "nKeepWeaponsBonesFade", nKeepWeaponsBonesFade); //Set Local to prevent deletion later if needed
            SetLocalInt(oLootCorpse, "nKeepWeaponsCorpseFade", nKeepWeaponsCorpseFade); //Set Local to prevent deletion later if needed
            SetLocalInt(oLootCorpse, "nKeepWeaponsBash", nKeepWeaponsBash); //Set Local to prevent deletion later if needed
            SetLocalInt(oLootCorpse, "nKeepWeaponsEmpty", nKeepWeaponsEmpty); //Set Local for later use
         }

        // Handle Armour/Helmets
        // NOTE: nCopyArmour takes precedence over nMoveArmour if both are TRUE
        if(nCopyArmour)
        {
            nMoveArmour = FALSE;
            // Handle armour
            object oArmour = GetItemInSlot(INVENTORY_SLOT_CHEST, oHostBody);
            SetLocalObject(oLootCorpse, "oOrigArmour", oArmour);
            if (GetDroppableFlag(oArmour))
             {
                string sArmourRef = GetResRef(oArmour);
                object oLootArmour = CreateItemOnObject(sArmourRef, oLootCorpse);

                SetPlotFlag(oLootArmour, GetPlotFlag(oArmour));
                SetIdentified(oLootArmour, GetIdentified(oArmour));

                // Set Plot flag to FALSE for original armor so it can be
                // destroyed later if corpse is bashed
                SetPlotFlag(oArmour, FALSE);

                SetLocalObject(oLootCorpse, "oLootArmour", oLootArmour);
                SetLocalObject(oLootCorpse, "oEquip14", oLootArmour);
             }

            // Handle helmet
            object oHelmet = GetItemInSlot(INVENTORY_SLOT_HEAD, oHostBody);
            SetLocalObject(oLootCorpse, "oOrigHelmet", oHelmet);
            if (GetDroppableFlag(oHelmet))
             {
                string sHelmetRef = GetResRef(oHelmet);
                object oLootHelmet = CreateItemOnObject(sHelmetRef, oLootCorpse);

                SetPlotFlag(oLootHelmet, GetPlotFlag(oHelmet));
                SetIdentified(oLootHelmet, GetIdentified(oHelmet));

                // Set Plot flag to FALSE for original helmet so it can be
                // destroyed later if corpse is bashed
                SetPlotFlag(oHelmet, FALSE);

                SetLocalObject(oLootCorpse, "oLootHelmet", oLootHelmet);
                SetLocalObject(oLootCorpse, "oEquip8", oLootHelmet);
             }
        }

        if(nMoveArmour)
        {
            nCopyArmour = FALSE;
            // Handle armour
            object oEquip14 = strip_equipped(oHostBody, oLootCorpse, GetItemInSlot(INVENTORY_SLOT_CHEST, oHostBody));
            SetLocalObject(oLootCorpse, "oEquip14", oEquip14);
            // Handle helmet
            object oEquip8 = strip_equipped(oHostBody, oLootCorpse, GetItemInSlot(INVENTORY_SLOT_HEAD, oHostBody));
            SetLocalObject(oLootCorpse, "oEquip8", oEquip8);
        }

        //Get the remaining loot from the dead creature and move it to oLootCorpse
        int nEquipCount = 14;
        object oLootEQ = GetFirstItemInInventory(oHostBody);
        while(GetIsObjectValid(oLootEQ))
         {
            nEquipCount++;
            // AssignCommand(oLootCorpse, ActionDoCommand(SendMessageToPC(GetFirstPC(), "oEquip"+IntToString(nEquipCount)+": "+GetTag(oLootEQ))));

            object oEquipTemp = strip_equipped(oHostBody, oLootCorpse, oLootEQ);
            string sEquipCount = "oEquip" + IntToString(nEquipCount);
            SetLocalObject(oLootCorpse, sEquipCount, oEquipTemp);
            oLootEQ = GetNextItemInInventory(oHostBody);
         }

        // We're done with oHostBody, so allow oLootCorpse to be destroyable
        if (!nDropWeapons)
         {
            AssignCommand(oLootCorpse, ActionDoCommand(SetPlotFlag(oLootCorpse, FALSE)));
         }

        // Fade corpse out of existence after specified delay (unless set to 0)
        if (nCorpseFade > 0)
        {
            float fCorpseFade = IntToFloat(nCorpseFade);
            // ActionWait(fCorpseFade); // Removed for version 3.2
            DelayCommand(fCorpseFade, FadeCorpse(oCorpseBlood, oLootCorpse, oHostBody));
        }
    }
}
//void main(){}
