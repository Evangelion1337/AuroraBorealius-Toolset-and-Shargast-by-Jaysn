/*
    zep_inc_phenos  - Version 2.0
    created July 3&4 - TJ aka TheExcimer-500
    recreated August 28 - *sighs* instead of fishing...

    to use type: #include "zep_inc_phenos"  at the top of your script

    Functions zep_Mount, zep_DisMount, zep_Fly, zep_Fly_Land
*/

    #include "zep_inc_constant"
    #include "zep_inc_1st_rp"

/* Variables placed on PC

    Flying:
        nCEP_Phenotype_C  <= the PC's native Phenotype (Standard or Large) [not used, yet - will be needed for Issig's Slight/Tall]
        nCEP_Wings_Remove_C <= 0 leave alone, if 1 remove


    Mounts:
        oCEP_Mount_C <= Mount Object (if any).
        nCEP_Mount_Cape <= Cape #.  (for now we're going to remove the capes)

    ALL:
        nCEP_SPEED_EFFECT_C <= 0 leave alone, -1 remove decrease, +1 remove increase


*/



//Constants (DO NOT CHANGE)
const float fDEFAULT_SPEED = 1000.0;
const int nNO_WING_CHANGE = 0;

//Constants (CAN BE CHANGED - if you know what you're doing)
const int nMAX_PHENOTYPE_ALLOWED = 2; // 3 & 4 will be Issig's, not in here yet
const int nMIN_PHENOTYPE_STANDARD = 10;
const int nMAX_PHENOTYPE_STANDARD = 20;
const int nMIN_PHENOTYPE_LARGE = 25;
const int nMAX_PHENOTYPE_LARGE = 40;


//Constants (CAN BE CHANGED by Users)

const float fSPEED_AURENTHIL = 2.5;
const float fSPEED_HORSE_BLACK = 2.2;
const float fSPEED_HORSE_BROWN = 2.2;
const float fSPEED_HORSE_NIGHTMARE = 2.4;
const float fSPEED_HORSE_WHITE = 2.2;
const float fSPEED_PONY_BROWN = 1.9;
const float fSPEED_PONY_LTBROWN = 1.9;
const float fSPEED_PONY_SPOT = 1.9;

/////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\
//                 FUNCTION DECLARATIONS
/////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\

///////////////////////////// zep_Fly \\\\\\\\\\\\\\\\\\\\\\\\\\\
//zep_Fly(object oFlyer, int nAttachWingType=nNO_WING_CHANGE, float fWalk_Speed=fDEFAULT_SPEED, string sItem_ResRef="")
//object oFlyer => Must be a PC Race, Dynamic Skeleton (Brownies can fly, not wemics!)
//          Kobolds, VampireMale/Female, Succubus, or Erinyes
//        This will be the NPC or PC to switch to the FLYING phenotype
//        Only valid for NORMAL or LARGE PCs (i.e. not valid for Issig's Slight/Tall yet)
//
//int nAttachWingType => This will attempt to create wings on oFlyer. Wings will not be created
//        if oFlyer Already has them! Works with CEP CONSTANTS "nCEP_WG_..." (see zep_2daconstants)
//        Some CEP values:  CEP_WG_ANGEL_ARMORED  CEP_WG_ANGEL_SKIN  CEP_WG_BIRD  CEP_WG_BIRD_RAVEN  CEP_WG_BIRD_SKIN
//         CEP_WG_BUTTERFLY  CEP_WG_BUTTERFLY_DKFOREST  CEP_WG_BUTTERFLY_SKIN  CEP_WG_DEMON_SKIN  CEP_WG_DRAGON_BLACK
//         CEP_WG_DRAGON_RED  CEP_WG_DRAGON_GOLD  CEP_WG_DRAGON_DRACOLICH  CEP_WG_DRAGON_SKIN  CEP_WG_FLYING_DEMON_1  CEP_WG_FLYING_DEMON_2
//
//fWALK_SPEED => This changes the walk/run speed of the oFlyer. It is in 10 meters/round
//               For example a Human walks at 1.6. Any Haste/Slow speed effects will be "adjusted",
//               however the other effects from Haste/Slow (such as #attacks) will not be changed.
//               leaving fDEFAULT_SPEED for FLYING will mean NO CHANGE.
//
//sItem_ResRef => This is the BLUEPRINT RESREF of an item to give oFlyer.
//                If oFlyer already has this item in inventory, it will not give another.
//                Useful if you have a blueprint item that oFlyer can use to LAND.
//
// The function zep_Fly_Land works with this function.
void zep_Fly(object oFlyer, int nAttachWingType=nNO_WING_CHANGE, float fWalk_Speed=fDEFAULT_SPEED, string sItem_ResRef="");


///////////////////////////// zep_Fly_Land \\\\\\\\\\\\\\\\\\\\\\\\\\\
// zep_Fly_Land(object oFlyer, int nRemoveAttachedWing=TRUE, string sRemove_Item_ResRef="")
//
//  object oFlyer        <= The creature that you want to "land"
//
//  nRemoveAttachedWing  <= If you used the function zep_Fly to add a wing, this will remove it.
//
//  sRemove_Item_ResRef=""  <=  This will remove an item with blueprint RESREF from oFlyer's inventory
//
//This function will work with zep_Fly and restore any walk-speed changes made.
void zep_Fly_Land(object oFlyer, int nRemoveAttachedWing=FALSE, string sRemove_Item_ResRef="");

//Checks to see if oFlyer does not already have wings attached.
// If no wings, it then adds them
void zep_Wings_Add(object oFlyer, int nAttachWingType);

//If wings added with zep_Wings_Add, this will remove them
void zep_Wings_Remove(object oFlyer);
void zep_Walk_Speed(object oPC, float fWalk_Speed);
void zep_UnWalk_Speed(object oPC);




///////////////////////////// zep_Mount \\\\\\\\\\\\\\\\\\\\\\\\\\\
// zep_Mount(object oRider, object oMount=OBJECT_INVALID, int nMount=0, float fWalk_Speed=fDEFAULT_SPEED, string sItem_ResRef="")
//
// oRider <= The PC or NPC that will Saddle-up.
//           Valid for PC Races (not wemics or brownies) & Dynamic Skeletons
//
// To state what mount oRider will use you have two options:
// oMount <=  This is a horse or pony creature in your module that the PC or NPC will interact with
//            If this method is used, oMount will "vanish" and upon dismounting will reappear.
//            Use OBJECT_INVALID to NOT use this method
//
// nMount <= This is an interger to represent the specific mount to use.
//         Horses: nCEP_PH_HORSE_BLACK, nCEP_PH_HORSE_BROWN, nCEP_PH_HORSE_WHITE, nCEP_PH_HORSE_AURENTHIL, nCEP_PH_HORSE_NIGHTMARE
//         Ponies: nCEP_PH_PONY_SPOT, nCEP_PH_PONY_LTBROWN, nCEP_PH_PONY_BROWN
//
// fWalk_Speed <= This is the speed adjustment that you wish to make. The Default settings
//                will use the values we believed to work well. However, you may want to try others if you're not satisfied
//                It is given in meters/round. A human walks 1.6 m/r. Our default horses walk at 2.2 m/r.
//                This compensates for any Haste/Slow effects (removing their speed adjustment, but leaving their attack/round and AC bonus)
//                   Under Default: Ponies are slower than horses. Aurenthil/Nightmare are faster.
//                Use 0.0 to disable any speed changes. You can also edit these constants in zep_inc_phenos (if you used the .erf version)
//
// sItem_ResRef <= This is the RESREF for a blueprint item that you want the PC to be given.
//                 It will check the PC's inventory and if missing, it'll add it.
//
//   Use zep_Dismount with this function
//   IMPORTANT NOTE: oMount can only be mounts with *P1* in their appearance names (under object properties box)
void zep_Mount(object oRider, object oMount=OBJECT_INVALID, int nMount=0, float fWalk_Speed=fDEFAULT_SPEED, string sItem_ResRef="");


///////////////////////////// zep_Dismount \\\\\\\\\\\\\\\\\\\\\\\\\\\
//zep_Dismount(object oRider, string sRemoveItem_ResRef="")
//          to Dismount from a horse/pony - use with zep_Mount
//
// sRemoveItem_ResRef <= This is the ResRef for a blueprint item that you want to remove from oRider
//
// This function automatically restores oMount if used, and resets the PC/NPC's walkspeed (if used)
// If oRider is not riding, nothing will happen
//            One good place to use this is on transitions to interiors ;)
void zep_Dismount(object oRider, string sRemoveItem_ResRef="");



/////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\
//                     FUNCTION CODE
/////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\


/////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\
//                       zep_Fly
/////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\

void zep_Fly(object oFlyer, int nAttachWingType=nNO_WING_CHANGE, float fWalk_Speed=fDEFAULT_SPEED, string sItem_ResRef="")
{
    if (GetIsObjectValid(oFlyer)==FALSE) {return;}
    if (GetObjectType(oFlyer)!=OBJECT_TYPE_CREATURE){return;}

    int nAppearance = GetAppearanceType(oFlyer);
    if (nAppearance == APPEARANCE_TYPE_INVALID){return;}

    int nNewPhenotype;
    int nBool = FALSE;
    object oItem;
    int nAppearance2;

    int nPhenotype_C = GetPhenoType(oFlyer);
    if (nPhenotype_C >nMAX_PHENOTYPE_ALLOWED){return;} //prevents horseriders from flying.

//Handle Switching (speed, wings afterwards)
switch (nAppearance)
 {
    case nCEP_APP_ERINYES:
       if (n1st_2DA_Check("appearance",nCEP_APP_ERINYES,sCEP_APP_ERINYES)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_ERINYES_FLY,sCEP_APP_ERINYES_FLY);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
          nBool=TRUE;
        }
     break;

    case nCEP_APP_KOBOLD_A:
       if (n1st_2DA_Check("appearance",nCEP_APP_KOBOLD_A,sCEP_APP_KOBOLD_A)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_KOBOLD_A_FLY,sCEP_APP_KOBOLD_A_FLY);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
          nBool=TRUE;
        }
     break;

    case nCEP_APP_KOBOLD_B:
       if (n1st_2DA_Check("appearance",nCEP_APP_KOBOLD_B,sCEP_APP_KOBOLD_B)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_KOBOLD_B_FLY,sCEP_APP_KOBOLD_B_FLY);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
          nBool=TRUE;
        }
     break;

    case nCEP_APP_KOBOLD_CH_A:
       if (n1st_2DA_Check("appearance",nCEP_APP_KOBOLD_CH_A,sCEP_APP_KOBOLD_CH_A)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_KOBOLD_CH_A_FLY, sCEP_APP_KOBOLD_CH_A_FLY);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
          nBool=TRUE;
        }
     break;

    case nCEP_APP_KOBOLD_CH_B:
       if (n1st_2DA_Check("appearance",nCEP_APP_KOBOLD_CH_B,sCEP_APP_KOBOLD_CH_B)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_KOBOLD_CH_B_FLY, sCEP_APP_KOBOLD_CH_B_FLY);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
          nBool=TRUE;
        }
     break;

    case nCEP_APP_KOBOLD_SH_A:
       if (n1st_2DA_Check("appearance",nCEP_APP_KOBOLD_SH_A,sCEP_APP_KOBOLD_SH_A)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_KOBOLD_SH_A_FLY, sCEP_APP_KOBOLD_SH_A_FLY);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
          nBool=TRUE;
        }
     break;

    case nCEP_APP_KOBOLD_SH_B:
       if (n1st_2DA_Check("appearance",nCEP_APP_KOBOLD_SH_B,sCEP_APP_KOBOLD_SH_B)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_KOBOLD_SH_B_FLY, sCEP_APP_KOBOLD_SH_B_FLY);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
          nBool=TRUE;
        }
     break;

    case nCEP_APP_SUCCUBUS:
       if (n1st_2DA_Check("appearance",nCEP_APP_SUCCUBUS, sCEP_APP_SUCCUBUS)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_SUCCUBUS_FLY, sCEP_APP_SUCCUBUS_FLY);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
          nBool=TRUE;
        }
     break;

    case nCEP_APP_VAMPIRE_F:
       if (n1st_2DA_Check("appearance",nCEP_APP_VAMPIRE_F, sCEP_APP_VAMPIRE_F)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_VAMPIRE_F_FLY, sCEP_APP_VAMPIRE_F_FLY);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
          nBool=TRUE;
        }
     break;

    case nCEP_APP_VAMPIRE_M:
       if (n1st_2DA_Check("appearance",nCEP_APP_VAMPIRE_M, sCEP_APP_VAMPIRE_M)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_VAMPIRE_M_FLY, sCEP_APP_VAMPIRE_M_FLY);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
          nBool=TRUE;
        }
     break;

    case nCEP_APP_SKELETON_DYN:
       if (n1st_2DA_Check("appearance",nCEP_APP_SKELETON_DYN, sCEP_APP_SKELETON_DYN)==TRUE)
        {
          SetPhenoType(nCEP_PH_FLY,oFlyer);
          nBool=TRUE;
        }
     break;

    case nCEP_APP_BROWNIE_DYN:
       if (n1st_2DA_Check("appearance",nCEP_APP_BROWNIE_DYN, sCEP_APP_BROWNIE_DYN)==TRUE)
        {
          if (nPhenotype_C == 0) {SetPhenoType(nCEP_PH_FLY,oFlyer);}
          else {SetPhenoType(nCEP_PH_FLY_L,oFlyer);}
          nBool=TRUE;
        }
     break;

    case APPEARANCE_TYPE_DWARF:
    case APPEARANCE_TYPE_ELF:
    case APPEARANCE_TYPE_GNOME:
    case APPEARANCE_TYPE_HALF_ELF:
    case APPEARANCE_TYPE_HALF_ORC:
    case APPEARANCE_TYPE_HALFLING:
    case APPEARANCE_TYPE_HUMAN:
       if (nPhenotype_C == 0)
          {
             nNewPhenotype = n1st_Get_2DARow("phenotype",nCEP_PH_FLY,sCEP_PH_FLY);
             if (nNewPhenotype!=-1)
              {
                SetPhenoType(nNewPhenotype,oFlyer);
                nBool=TRUE;
              }
          }
       else
        {
             nNewPhenotype = n1st_Get_2DARow("phenotype",nCEP_PH_FLY_L,sCEP_PH_FLY_L);
             if (nNewPhenotype!=-1)
              {
                SetPhenoType(nNewPhenotype,oFlyer);
                nBool=TRUE;
              }
        }

     break;

 }  // end Switch

 if (nBool==FALSE) {return;}     // no changes made as oFlyer failed to meet requirements
 string sSay;
 SetLocalInt(oFlyer, "nCEP_Phenotype_C", nPhenotype_C); // how we'll get the PC back
 if (nAttachWingType != nNO_WING_CHANGE){zep_Wings_Add(oFlyer, nAttachWingType);}
 if (fWalk_Speed != fDEFAULT_SPEED){zep_Walk_Speed(oFlyer, fWalk_Speed);}
 if ( (sItem_ResRef !="") && (n1st_HasItemInInventory(oFlyer,"",sItem_ResRef)==FALSE) )
  {
    oItem = CreateItemOnObject(sItem_ResRef, oFlyer);
    if (GetIsObjectValid(oItem)==FALSE)
    {
      sSay = "********* ERROR in zep_FLY: Create Item failed. Blueprint with sResRef: " + sItem_ResRef + " does not exist or could not be given to: " + GetName(oFlyer);
      PrintString(sSay);
    }
  }

}


/////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\
//                     zep_Fly_Land
/////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\

void zep_Fly_Land(object oFlyer, int nRemoveAttachedWing=FALSE, string sRemove_Item_ResRef="")
{
  if (GetObjectType(oFlyer)!=OBJECT_TYPE_CREATURE){return;}
  if (GetIsObjectValid(oFlyer)==FALSE) {return;}

  int nAppearance = GetAppearanceType(oFlyer);
  if (nAppearance == APPEARANCE_TYPE_INVALID){return;}


  int nBool = FALSE;
  object oItem;
  int nAppearance2;

  int nPhenotype = GetPhenoType(oFlyer);

  if (nPhenotype>nMAX_PHENOTYPE_ALLOWED)
  {
    if (nPhenotype>nMAX_PHENOTYPE_STANDARD){SetPhenoType(2,oFlyer);}
    else {SetPhenoType(0,oFlyer);}
    nBool=TRUE;
  }

////////////////WINGS\\\\\\\\\\\\\\
if (nRemoveAttachedWing==TRUE){zep_Wings_Remove(oFlyer);}

////////////////ITEM\\\\\\\\\\\\\\
if (sRemove_Item_ResRef!="")
 {
    oItem = o1st_GetItemInInventory(oFlyer, "",sRemove_Item_ResRef);
    DestroyObject(oItem);
 }

////////////////SPEED\\\\\\\\\\\\\\
zep_UnWalk_Speed(oFlyer);
//////////////////\\\\\\\\\\\\\\\\\\

DeleteLocalInt(oFlyer,"nCEP_Phenotype_C");
if (nBool==TRUE){return;}

switch (nAppearance)
 {
    case nCEP_APP_ERINYES_FLY:
       if (n1st_2DA_Check("appearance",nCEP_APP_ERINYES_FLY,sCEP_APP_ERINYES_FLY)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_ERINYES,sCEP_APP_ERINYES);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
        }
     break;

    case nCEP_APP_KOBOLD_A_FLY:
       if (n1st_2DA_Check("appearance",nCEP_APP_KOBOLD_A_FLY,sCEP_APP_KOBOLD_A_FLY)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_KOBOLD_A,sCEP_APP_KOBOLD_A);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
        }
     break;

    case nCEP_APP_KOBOLD_B_FLY:
       if (n1st_2DA_Check("appearance",nCEP_APP_KOBOLD_B_FLY,sCEP_APP_KOBOLD_B_FLY)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_KOBOLD_B,sCEP_APP_KOBOLD_B);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
        }
     break;

    case nCEP_APP_KOBOLD_CH_A_FLY:
       if (n1st_2DA_Check("appearance",nCEP_APP_KOBOLD_CH_A_FLY,sCEP_APP_KOBOLD_CH_A_FLY)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_KOBOLD_CH_A, sCEP_APP_KOBOLD_CH_A);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
        }
     break;

    case nCEP_APP_KOBOLD_CH_B_FLY:
       if (n1st_2DA_Check("appearance",nCEP_APP_KOBOLD_CH_B_FLY,sCEP_APP_KOBOLD_CH_B_FLY)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_KOBOLD_CH_B, sCEP_APP_KOBOLD_CH_B);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
        }
     break;

    case nCEP_APP_KOBOLD_SH_A_FLY:
       if (n1st_2DA_Check("appearance",nCEP_APP_KOBOLD_SH_A_FLY,sCEP_APP_KOBOLD_SH_A_FLY)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_KOBOLD_SH_A, sCEP_APP_KOBOLD_SH_A);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
        }
     break;

    case nCEP_APP_KOBOLD_SH_B_FLY:
       if (n1st_2DA_Check("appearance",nCEP_APP_KOBOLD_SH_B_FLY,sCEP_APP_KOBOLD_SH_B_FLY)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_KOBOLD_SH_B, sCEP_APP_KOBOLD_SH_B);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
        }
     break;

    case nCEP_APP_SUCCUBUS_FLY:
       if (n1st_2DA_Check("appearance",nCEP_APP_SUCCUBUS_FLY, sCEP_APP_SUCCUBUS_FLY)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_SUCCUBUS, sCEP_APP_SUCCUBUS);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
        }
     break;

    case nCEP_APP_VAMPIRE_F_FLY:
       if (n1st_2DA_Check("appearance",nCEP_APP_VAMPIRE_F_FLY, sCEP_APP_VAMPIRE_F_FLY)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_VAMPIRE_F, sCEP_APP_VAMPIRE_F);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
        }
     break;

    case nCEP_APP_VAMPIRE_M_FLY:
       if (n1st_2DA_Check("appearance",nCEP_APP_VAMPIRE_M_FLY, sCEP_APP_VAMPIRE_M_FLY)==TRUE)
        {
          nAppearance2 = n1st_Get_2DARow("appearance",nCEP_APP_VAMPIRE_M, sCEP_APP_VAMPIRE_M);
          if (nAppearance2 != -1) {SetCreatureAppearanceType(oFlyer, nAppearance2);}
        }
     break;

  }
}



/////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\
//                     zep_Mount
/////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\

void zep_Mount(object oRider, object oMount=OBJECT_INVALID, int nMount=0, float fWalk_Speed=fDEFAULT_SPEED, string sItem_ResRef="")
{
    //Verify oRider is of the correct Phenotype (i.e. not already on a horse or flying)

    if (GetObjectType(oRider)!=OBJECT_TYPE_CREATURE){return;}
    int nPhenotype_C = GetPhenoType(oRider);
    if (nPhenotype_C >nMAX_PHENOTYPE_ALLOWED){return;}

    int nAppearance = GetAppearanceType(oRider);

    int nNewPhenotype;
    int nBool = FALSE;
    object oItem;
    int nAppearance2;


    //Verify oRider is of valid appearance
    //The IMPORTANT point is that the model name is the same.
    //doesn't matter at all when the Appearance # is.
    string sModel = GetStringLowerCase(s1st_Get_2DAModelName("appearance",nAppearance));

    if (sModel == GetStringLowerCase(sCEP_APP_PCRACE_DWARF)){nBool=TRUE;}
    if (sModel == GetStringLowerCase(sCEP_APP_PCRACE_ELF)){nBool=TRUE;}
    if (sModel == GetStringLowerCase(sCEP_APP_PCRACE_GNOME)){nBool=TRUE;}
    if (sModel == GetStringLowerCase(sCEP_APP_PCRACE_HALFELF)){nBool=TRUE;}
    if (sModel == GetStringLowerCase(sCEP_APP_PCRACE_HALFLING)){nBool=TRUE;}
    if (sModel == GetStringLowerCase(sCEP_APP_PCRACE_HALFORC)){nBool=TRUE;}
    if (sModel == GetStringLowerCase(sCEP_APP_PCRACE_HUMAN)){nBool=TRUE;}
    if (sModel == GetStringLowerCase(sCEP_APP_SKELETON_DYN)){nBool=TRUE;}

    if (nBool==FALSE){return;}

    nBool=FALSE;
// Next step - find out what the mount is:
    if (oMount !=OBJECT_INVALID)
     {
        nAppearance2 = GetAppearanceType(oMount);
        sModel = GetStringLowerCase(s1st_Get_2DAModelName("appearance",nAppearance2));
        if (sModel == GetStringLowerCase(sCEP_APP_HORSE_AURENTHIL)){nBool=TRUE; nMount = nCEP_PH_HORSE_AURENTHIL;}
        if (sModel == GetStringLowerCase(sCEP_APP_HORSE_BLACK)){nBool=TRUE; nMount = nCEP_PH_HORSE_BLACK;}
        if (sModel == GetStringLowerCase(sCEP_APP_HORSE_BROWN)){nBool=TRUE; nMount = nCEP_PH_HORSE_BROWN;}
        if (sModel == GetStringLowerCase(sCEP_APP_HORSE_NIGHTMARE)){nBool=TRUE; nMount = nCEP_PH_HORSE_NIGHTMARE;}
        if (sModel == GetStringLowerCase(sCEP_APP_HORSE_WHITE)){nBool=TRUE; nMount = nCEP_PH_HORSE_WHITE;}
        if (sModel == GetStringLowerCase(sCEP_APP_PONY_BROWN)){nBool=TRUE; nMount = nCEP_PH_PONY_BROWN;}
        if (sModel == GetStringLowerCase(sCEP_APP_PONY_LTBROWN)){nBool=TRUE; nMount = nCEP_PH_PONY_LTBROWN;}
        if (sModel == GetStringLowerCase(sCEP_APP_PONY_SPOTTED)){nBool=TRUE; nMount = nCEP_PH_PONY_SPOT;}
     }
    else
     {
         switch (nMount)
          {
            case nCEP_PH_HORSE_AURENTHIL:
            case nCEP_PH_HORSE_AURENTHIL_L:
            case nCEP_PH_HORSE_BLACK:
            case nCEP_PH_HORSE_BLACK_L:
            case nCEP_PH_HORSE_BROWN:
            case nCEP_PH_HORSE_BROWN_L:
            case nCEP_PH_HORSE_NIGHTMARE:
            case nCEP_PH_HORSE_NIGHTMARE_L:
            case nCEP_PH_HORSE_WHITE:
            case nCEP_PH_HORSE_WHITE_L:
            case nCEP_PH_PONY_BROWN:
            case nCEP_PH_PONY_BROWN_L:
            case nCEP_PH_PONY_LTBROWN:
            case nCEP_PH_PONY_LTBROWN_L:
            case nCEP_PH_PONY_SPOT:
            case nCEP_PH_PONY_SPOT_L:
              nBool=TRUE;
             break;
          }
     }

//At this point it is either a valid entry for the mount or not.

    if (nBool==FALSE){return;}

// ok Validated Rider & Mount...  Fix for Phenotypes
   if ( (nPhenotype_C == 0) && (nMount> nMAX_PHENOTYPE_STANDARD) ) {nMount=nMount-20;}
   if ( (nPhenotype_C == 2) && (nMount< nMIN_PHENOTYPE_LARGE) ) {nMount=nMount+20;}


//Now we still need to verify that the 2da has the entry. *sighs*

nBool=FALSE;
int nMountFinal = -1;

         switch (nMount)
          {
            case nCEP_PH_HORSE_AURENTHIL:
              nMountFinal = n1st_Get_2DARow("phenotype",nMount,sCEP_PH_HORSE_AURENTHIL);
              if (fWalk_Speed==fDEFAULT_SPEED) {fWalk_Speed=fSPEED_AURENTHIL;}
             break;

            case nCEP_PH_HORSE_AURENTHIL_L:
              nMountFinal = n1st_Get_2DARow("phenotype",nMount,sCEP_PH_HORSE_AURENTHIL_L);
              if (fWalk_Speed==fDEFAULT_SPEED) {fWalk_Speed=fSPEED_AURENTHIL;}
             break;

            case nCEP_PH_HORSE_BLACK:
              nMountFinal = n1st_Get_2DARow("phenotype",nMount,sCEP_PH_HORSE_BLACK);
              if (fWalk_Speed==fDEFAULT_SPEED) {fWalk_Speed=fSPEED_HORSE_BLACK;}
             break;

            case nCEP_PH_HORSE_BLACK_L:
              nMountFinal = n1st_Get_2DARow("phenotype",nMount,sCEP_PH_HORSE_BLACK_L);
              if (fWalk_Speed==fDEFAULT_SPEED) {fWalk_Speed=fSPEED_HORSE_BLACK;}
             break;

            case nCEP_PH_HORSE_BROWN:
              nMountFinal = n1st_Get_2DARow("phenotype",nMount,sCEP_PH_HORSE_BROWN);
              if (fWalk_Speed==fDEFAULT_SPEED) {fWalk_Speed=fSPEED_HORSE_BROWN;}
             break;

            case nCEP_PH_HORSE_BROWN_L:
              nMountFinal = n1st_Get_2DARow("phenotype",nMount,sCEP_PH_HORSE_BROWN_L);
              if (fWalk_Speed==fDEFAULT_SPEED) {fWalk_Speed=fSPEED_HORSE_BROWN;}
             break;

            case nCEP_PH_HORSE_NIGHTMARE:
              nMountFinal = n1st_Get_2DARow("phenotype",nMount,sCEP_PH_HORSE_NIGHTMARE);
              if (fWalk_Speed==fDEFAULT_SPEED) {fWalk_Speed=fSPEED_HORSE_NIGHTMARE;}
             break;

            case nCEP_PH_HORSE_NIGHTMARE_L:
              nMountFinal = n1st_Get_2DARow("phenotype",nMount,sCEP_PH_HORSE_NIGHTMARE_L);
              if (fWalk_Speed==fDEFAULT_SPEED) {fWalk_Speed=fSPEED_HORSE_NIGHTMARE;}
             break;

            case nCEP_PH_HORSE_WHITE:
              nMountFinal = n1st_Get_2DARow("phenotype",nMount,sCEP_PH_HORSE_WHITE);
              if (fWalk_Speed==fDEFAULT_SPEED) {fWalk_Speed=fSPEED_HORSE_WHITE;}
             break;

            case nCEP_PH_HORSE_WHITE_L:
              nMountFinal = n1st_Get_2DARow("phenotype",nMount,sCEP_PH_HORSE_WHITE_L);
              if (fWalk_Speed==fDEFAULT_SPEED) {fWalk_Speed=fSPEED_HORSE_WHITE;}
             break;

            case nCEP_PH_PONY_BROWN:
              nMountFinal = n1st_Get_2DARow("phenotype",nMount,sCEP_PH_PONY_BROWN);
              if (fWalk_Speed==fDEFAULT_SPEED) {fWalk_Speed=fSPEED_PONY_BROWN;}
             break;

            case nCEP_PH_PONY_BROWN_L:
              nMountFinal = n1st_Get_2DARow("phenotype",nMount,sCEP_PH_PONY_BROWN_L);
              if (fWalk_Speed==fDEFAULT_SPEED) {fWalk_Speed=fSPEED_PONY_BROWN;}
             break;

            case nCEP_PH_PONY_LTBROWN:
              nMountFinal = n1st_Get_2DARow("phenotype",nMount,sCEP_PH_PONY_LTBROWN);
              if (fWalk_Speed==fDEFAULT_SPEED) {fWalk_Speed=fSPEED_PONY_LTBROWN;}
             break;

            case nCEP_PH_PONY_LTBROWN_L:
              nMountFinal = n1st_Get_2DARow("phenotype",nMount,sCEP_PH_PONY_LTBROWN_L);
              if (fWalk_Speed==fDEFAULT_SPEED) {fWalk_Speed=fSPEED_PONY_LTBROWN;}
             break;

            case nCEP_PH_PONY_SPOT:
              nMountFinal = n1st_Get_2DARow("phenotype",nMount,sCEP_PH_PONY_SPOT);
              if (fWalk_Speed==fDEFAULT_SPEED) {fWalk_Speed=fSPEED_PONY_SPOT;}
             break;

            case nCEP_PH_PONY_SPOT_L:
              nMountFinal = n1st_Get_2DARow("phenotype",nMount,sCEP_PH_PONY_SPOT_L);
              if (fWalk_Speed==fDEFAULT_SPEED) {fWalk_Speed=fSPEED_PONY_SPOT;}
             break;

          }
if (nMountFinal == -1){return;} //after all that, the 2da file does not have this phenotype

//Saddle up CowOrc
SetPhenoType(nMountFinal, oRider);

/////////////////////REMOVE CAPES\\\\\\\\\\\\\\\\\\
//nCEP_Mount_Cape          NO! Why? B/c if the player logs out their armor will remain changed!
//                         This is on the top of the post-CEPv2 list of things to fix anyway.

//Remove existing Horse if any\\
SetLocalObject(oRider, "oCEP_Mount_C",oMount); //thus either object invalid or the mount
effect eInvisible = EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY);
effect eGhost = EffectCutsceneGhost();
effect eDisApp = EffectDisappearAppear(GetLocation(oMount));

    if (oMount !=OBJECT_INVALID)
    {
       AssignCommand(oMount, ClearAllActions(TRUE));
       ApplyEffectToObject(DURATION_TYPE_PERMANENT, eInvisible,oMount);
       DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eGhost,oMount));
       DelayCommand(2.0, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDisApp,oMount));
    }

// Speed Adjustment & Give Item
if (fWalk_Speed>0.0) {zep_Walk_Speed(oRider, fWalk_Speed);}

if ( (sItem_ResRef !="") && (n1st_HasItemInInventory(oRider,"",sItem_ResRef)==FALSE) )
  {oItem = CreateItemOnObject(sItem_ResRef, oRider);}

}

////////////////////////////////////DISMOUNT\\\\\\\\\\\\\\\\\\\\\\\\\\\\
void zep_Dismount(object oRider, string sRemoveItem_ResRef="")    //ntired=TRUE; switch(ntired){case TRUE: GetCoffee(oExcimer); break;}
{
  //Checks\\
    if (GetObjectType(oRider)!=OBJECT_TYPE_CREATURE){return;}
    int nPhenotype_C = GetPhenoType(oRider);
    if (nPhenotype_C <nMAX_PHENOTYPE_ALLOWED+1){return;}

//Restore Phenotype:
    if (nPhenotype_C>nMAX_PHENOTYPE_STANDARD){DelayCommand(1.5,SetPhenoType(2,oRider));}
    else {DelayCommand(1.5,SetPhenoType(0,oRider));}

//speed:
  zep_UnWalk_Speed(oRider);

//Restore Mount
object oMount = GetLocalObject(oRider, "oCEP_Mount_C"); //thus either object invalid or the mount
effect eFX;
float fDelay=3.0;
if (GetIsObjectValid(oMount)==TRUE)
 {
    x1st_Effect_RemoveType(oMount,EFFECT_TYPE_DISAPPEARAPPEAR );
    x1st_Effect_RemoveType(oMount,EFFECT_TYPE_CUTSCENEGHOST );

    AssignCommand(oMount, ActionJumpToObject(oRider,FALSE));
    DelayCommand(2.0, x1st_Effect_RemoveType(oMount,EFFECT_TYPE_VISUALEFFECT));
    DelayCommand(3.0,DeleteLocalObject(oRider,"oCEP_Mount_C"));
 }

object oItem;
////////////////ITEM\\\\\\\\\\\\\\
if (sRemoveItem_ResRef!="")
 {
    oItem = o1st_GetItemInInventory(oRider, "",sRemoveItem_ResRef);
    DestroyObject(oItem);
 }
}






void zep_Wings_Remove(object oFlyer)
{
  if (GetObjectType(oFlyer)!=OBJECT_TYPE_CREATURE){return;}
  int nWinged = GetLocalInt(oFlyer, "nCEP_Wings_Remove_C");
  if (nWinged == 0) {return;}

  SetLocalInt(oFlyer, "nCEP_Wings_Remove_C", 0);
  DeleteLocalInt(oFlyer, "nCEP_Wings_Remove_C");
  SetCreatureWingType(nCEP_WG_NONE, oFlyer);
}


void zep_Wings_Add(object oFlyer, int nAttachWingType)
{
  if (GetObjectType(oFlyer)!=OBJECT_TYPE_CREATURE){return;}

  if (GetCreatureWingType(oFlyer)!=CREATURE_WING_TYPE_NONE)
    {return;}

  SetLocalInt(oFlyer, "nCEP_Wings_Remove_C", 0);

 string sModel;
 switch (nAttachWingType)
  {
    case nCEP_WG_ANGEL: sModel = sCEP_WG_ANGEL; break;
    case nCEP_WG_ANGEL_ARMORED: sModel =sCEP_WG_ANGEL_ARMORED; break;
    case nCEP_WG_ANGEL_FALLEN: sModel =sCEP_WG_ANGEL_FALLEN; break;
    case nCEP_WG_ANGEL_SKIN: sModel =sCEP_WG_ANGEL_SKIN; break;
    case nCEP_WG_BAT: sModel =sCEP_WG_BAT; break;
    case nCEP_WG_BAT_SKIN: sModel =sCEP_WG_BAT_SKIN; break;
    case nCEP_WG_BIRD: sModel =sCEP_WG_BIRD; break;
    case nCEP_WG_BIRD_BLUE: sModel =sCEP_WG_BIRD_BLUE; break;
    case nCEP_WG_BIRD_DARK: sModel =sCEP_WG_BIRD_DARK; break;
    case nCEP_WG_BIRD_KENKU: sModel =sCEP_WG_BIRD_KENKU; break;
    case nCEP_WG_BIRD_RAVEN: sModel =sCEP_WG_BIRD_RAVEN; break;
    case nCEP_WG_BIRD_RED: sModel =sCEP_WG_BIRD_RED; break;
    case nCEP_WG_BIRD_SKIN: sModel =sCEP_WG_BIRD_SKIN; break;
    case nCEP_WG_BUTTERFLY: sModel =sCEP_WG_BUTTERFLY; break;
    case nCEP_WG_BUTTERFLY_BLACK: sModel =sCEP_WG_BUTTERFLY_BLACK; break;
    case nCEP_WG_BUTTERFLY_BLUE: sModel =sCEP_WG_BUTTERFLY_BLUE; break;
    case nCEP_WG_BUTTERFLY_BRGBLUE: sModel =sCEP_WG_BUTTERFLY_BRGBLUE; break;
    case nCEP_WG_BUTTERFLY_DKFOREST: sModel =sCEP_WG_BUTTERFLY_DKFOREST; break;
    case nCEP_WG_BUTTERFLY_FOREST: sModel =sCEP_WG_BUTTERFLY_FOREST; break;
    case nCEP_WG_BUTTERFLY_GREENGOLD: sModel =sCEP_WG_BUTTERFLY_GREENGOLD; break;
    case nCEP_WG_BUTTERFLY_ICEGREEN: sModel =sCEP_WG_BUTTERFLY_ICEGREEN; break;
    case nCEP_WG_BUTTERFLY_MAUVE: sModel =sCEP_WG_BUTTERFLY_MAUVE; break;
    case nCEP_WG_BUTTERFLY_ORANGE: sModel =sCEP_WG_BUTTERFLY_ORANGE; break;
    case nCEP_WG_BUTTERFLY_RED: sModel =sCEP_WG_BUTTERFLY_RED; break;
    case nCEP_WG_BUTTERFLY_SIENNA: sModel =sCEP_WG_BUTTERFLY_SIENNA; break;
    case nCEP_WG_BUTTERFLY_SKIN: sModel =sCEP_WG_BUTTERFLY_SKIN; break;
    case nCEP_WG_BUTTERFLY_VIOLET: sModel =sCEP_WG_BUTTERFLY_VIOLET; break;
    case nCEP_WG_BUTTERFLY_VIOLETGOLD: sModel =sCEP_WG_BUTTERFLY_VIOLETGOLD; break;
    case nCEP_WG_BUTTERFLY_YELLOW: sModel =sCEP_WG_BUTTERFLY_YELLOW; break;
    case nCEP_WG_DEMON: sModel =sCEP_WG_DEMON; break;
    case nCEP_WG_DEMON_BALOR: sModel =sCEP_WG_DEMON_BALOR; break;
    case nCEP_WG_DEMON_BLUE_TRANS: sModel =sCEP_WG_DEMON_BLUE_TRANS; break;
    case nCEP_WG_DEMON_ERINYES: sModel =sCEP_WG_DEMON_ERINYES; break;
    case nCEP_WG_DEMON_MEPHISTO: sModel =sCEP_WG_DEMON_MEPHISTO; break;
    case nCEP_WG_DEMON_RED_TRANS: sModel =sCEP_WG_DEMON_RED_TRANS; break;
    case nCEP_WG_DEMON_SKIN: sModel =sCEP_WG_DEMON_SKIN; break;
    case nCEP_WG_DRAGON_BIG: sModel =sCEP_WG_DRAGON_BIG; break;
    case nCEP_WG_DRAGON_BLACK: sModel =sCEP_WG_DRAGON_BLACK; break;
    case nCEP_WG_DRAGON_BLUE: sModel =sCEP_WG_DRAGON_BLUE; break;
    case nCEP_WG_DRAGON_BRASS: sModel =sCEP_WG_DRAGON_BRASS ; break;
    case nCEP_WG_DRAGON_BRONZE: sModel =sCEP_WG_DRAGON_BRONZE ; break;
    case nCEP_WG_DRAGON_COPPER: sModel =sCEP_WG_DRAGON_COPPER ; break;
    case nCEP_WG_DRAGON_DRACOLICH: sModel =sCEP_WG_DRAGON_DRACOLICH ; break;
    case nCEP_WG_DRAGON_GOLD: sModel =sCEP_WG_DRAGON_GOLD ; break;
    case nCEP_WG_DRAGON_GREEN: sModel =sCEP_WG_DRAGON_GREEN ; break;
    case nCEP_WG_DRAGON_PRISMATIC: sModel =sCEP_WG_DRAGON_PRISMATIC ; break;
    case nCEP_WG_DRAGON_RED: sModel =sCEP_WG_DRAGON_RED ; break;
    case nCEP_WG_DRAGON_SHADOW: sModel =sCEP_WG_DRAGON_SHADOW ; break;
    case nCEP_WG_DRAGON_SILVER: sModel =sCEP_WG_DRAGON_SILVER ; break;
    case nCEP_WG_DRAGON_SKIN: sModel =sCEP_WG_DRAGON_SKIN ; break;
    case nCEP_WG_DRAGON_WHITE: sModel =sCEP_WG_DRAGON_WHITE ; break;
    case nCEP_WG_FLYING_ANGEL: sModel =sCEP_WG_FLYING_ANGEL ; break;
    case nCEP_WG_FLYING_DEMON_1: sModel =sCEP_WG_FLYING_DEMON_1 ; break;
    case nCEP_WG_FLYING_DEMON_2: sModel =sCEP_WG_FLYING_DEMON_2 ; break;
    case nCEP_WG_GARGOYLE: sModel =sCEP_WG_GARGOYLE ; break;
    case nCEP_WG_HALFDRAGON_GOLD: sModel =sCEP_WG_HALFDRAGON_GOLD ; break;
    case nCEP_WG_HALFDRAGON_SILVER: sModel =sCEP_WG_HALFDRAGON_SILVER ; break;

//Yes... you'd think that someone with advanced degrees in Mathematics & Physics
//       would've come up with a better solution too.
  }

//Now we have the "row #" and the wing model name.
 int nRowNumber = n1st_Get_2DARow("wingmodel",nAttachWingType, sModel);

 if (nRowNumber !=-1)
  {
    SetLocalInt(oFlyer, "nCEP_Wings_Remove_C", 1);
    SetCreatureWingType(nRowNumber, oFlyer);
  }
}


void zep_Walk_Speed(object oPC, float fWalk_Speed)
{
  effect eSpeed;
  float fSpeed_Change = f1st_GetSpeed_PercentChange(oPC, fWalk_Speed);
  int nSpeed_Change = FloatToInt(100*fSpeed_Change);

  if (fWalk_Speed==0.0){SetLocalInt(oPC, "nCEP_SPEED_EFFECT_C",0); return;}

  if (nSpeed_Change<-1)
   {
     eSpeed = EffectMovementSpeedDecrease(-nSpeed_Change);
     ApplyEffectToObject(DURATION_TYPE_PERMANENT, eSpeed, oPC);
     SetLocalInt(oPC, "nCEP_SPEED_EFFECT_C",-1);
   }
  if (nSpeed_Change>1)
   {
     eSpeed = EffectMovementSpeedIncrease(nSpeed_Change);
     ApplyEffectToObject(DURATION_TYPE_PERMANENT, eSpeed, oPC);
     SetLocalInt(oPC, "nCEP_SPEED_EFFECT_C",1);
   }
}

void zep_UnWalk_Speed(object oPC)
{
effect eEff = GetFirstEffect(oPC);
int nSpeed_ADJ = GetLocalInt(oPC, "nCEP_SPEED_EFFECT_C");
int nSpeed_Eff_Type;
  if (nSpeed_ADJ == -1){nSpeed_Eff_Type=EFFECT_TYPE_MOVEMENT_SPEED_DECREASE;}
  if (nSpeed_ADJ == 1) {nSpeed_Eff_Type=EFFECT_TYPE_MOVEMENT_SPEED_INCREASE;}
if (nSpeed_ADJ !=0)
   {
      while (GetIsEffectValid(eEff)==TRUE)
        {
          if (GetEffectType(eEff)==nSpeed_Eff_Type){RemoveEffect(oPC,eEff);}
          eEff = GetNextEffect(oPC);
        }
   }
}
