//::----------------------------------------------------------
//:: Function Name: zep_pc_has_holyw
//:: Function use: Function used in zep_demi_regen_c
//:: conversation to check if the PC has the special Holy
//:: Water item needed to destroy the Demilich.  Note that
//:: despite name this function will check for whatever
//:: item is specified by ZEP_DEMI_DEST_TAG.  Will also
//:: create custom token for use in conversation file so
//:: the appropriate item name is displayed.
//::----------------------------------------------------------
//:: Included files: zep_inc_demi

#include "zep_inc_demi"

int StartingConditional()
{
object oPC=GetPCSpeaker();  //PC destroying the demilich

//Check if PC has destroying item.  Referred to as "HolyWater"
//in code since that is its default type.
object oHolyWater=GetItemPossessedBy(oPC,ZEP_DEMI_DEST_TAG);
//If PC DOES have the right item, get it's name and create a
//custom token to use in the conversation for it.
if (oHolyWater!=OBJECT_INVALID)
    {
    string sHolyWaterName=GetName(oHolyWater);
    SetCustomToken(1001,sHolyWaterName);
    return TRUE;
    }
else return FALSE;
}
