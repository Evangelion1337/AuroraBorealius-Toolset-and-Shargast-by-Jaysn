//::///////////////////////////////////////////////
//:: skin include
//:: prc_inc_skin
//::///////////////////////////////////////////////
/** @file
    This include contains GetPCSkin(). If only using
    this function please include this directly and not via
    the entire spell engine :p

    Is included by inc_persist_loca for persistent
    local variables
*/
//:://////////////////////////////////////////////
//:: Created By: fluffyamoeba
//:: Created On: 2008-4-23
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

/**
 * Sets up the pcskin object on oPC.
 * If it already exists, simply return it. Otherwise, create and equip it.
 *
 * @param oPC The creature whose skin object to look for.
 * @return    Either the skin found or the skin created.
 */
object GetPCSkin(object oPC);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "inc_debug"

//////////////////////////////////////////////////
/* private functions                            */
//////////////////////////////////////////////////
// to duplicate ForceEquip() from inc_utility

void _ForceEquipSkin(object oPC, object oSkin, int nThCall = 0)
{
    // Make sure that the object we are attempting equipping is the latest one to be ForceEquipped into this slot
    if(GetIsObjectValid(GetLocalObject(oPC, "ForceEquipToSlot_17"))
    && GetLocalObject(oPC, "ForceEquipToSlot_17") != oSkin)
        return;

    // Fail on non-commandable NPCs after ~1min
    if(!GetIsPC(oPC) && !GetCommandable(oPC) && nThCall > 60)
    {
        WriteTimestampedLogEntry("ForceEquip() failed on non-commandable NPC: " + DebugObject2Str(oPC) + " for item: " + DebugObject2Str(oSkin));
        return;
    }

    float fDelay;

    // Check if the equipping has already happened
    if(GetItemInSlot(INVENTORY_SLOT_CARMOUR, oPC) != oSkin)
    {
        // Test and increment the control counter
        if(nThCall++ == 0)
        {
            // First, try to do the equipping non-intrusively and give the target a reasonable amount of time to do it
            AssignCommand(oPC, ActionEquipItem(oSkin, INVENTORY_SLOT_CARMOUR));
            fDelay = 1.0f;

            // Store the item to be equipped in a local variable to prevent contest between two different calls to ForceEquip
            SetLocalObject(oPC, "ForceEquipToSlot_17", oSkin);
        }
        else
        {
            // Nuke the target's action queue. This should result in "immediate" equipping of the item
            if(GetIsPC(oPC) || nThCall > 5) // Skip nuking NPC action queue at first, since that can cause problems. 5 = magic number here. May need adjustment
            {
                if(!GetIsObjectValid(oSkin))
                {
                    oSkin = GetPCSkin(oPC);
                    return;
                }
                else
                {
                    AssignCommand(oPC, ClearAllActions());
                    AssignCommand(oPC, ActionEquipItem(oSkin, INVENTORY_SLOT_CARMOUR));
                }
            }
            // Use a lenghtening delay in order to attempt handling lag and possible other interference. From 0.1s to 1s
            fDelay = (nThCall < 10 ? nThCall : 10) / 10.0f; // yes this is the same as PRCMin(nThCall, 10)
        }

        // Loop
        DelayCommand(fDelay, _ForceEquipSkin(oPC, oSkin, nThCall));
    }
    // It has, so clean up
    else
        DeleteLocalObject(oPC, "ForceEquipToSlot_17");
}

//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

object GetPCSkin(object oPC)
{
    // According to a bug report, this is being called on non-creature objects. This should catch the culprit
    if(DEBUG) Assert(GetObjectType(oPC) == OBJECT_TYPE_CREATURE, "GetObjectType(oPC) == OBJECT_TYPE_CREATURE", "GetPRCSkin() called on non-creature object: " + DebugObject2Str(oPC), "prc_inc_skin", "object GetPCSkin(object oPC)");
    object oSkin = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oPC);
    if(!GetIsObjectValid(oSkin))
    {
        //oSkin = GetLocalObject(oPC, "PRCSkinCache");
        //if(!GetIsObjectValid(oSkin))
        {
            //Added this check to prevent creation of extra skins on module entry
            oSkin = GetItemPossessedBy(oPC, "base_prc_skin");
            if(GetIsObjectValid(oSkin))
            {
                _ForceEquipSkin(oPC, oSkin, INVENTORY_SLOT_CARMOUR);
                //AssignCommand(oPC, ActionEquipItem(oSkin, INVENTORY_SLOT_CARMOUR));
            }
            else
            {
                oSkin = CreateItemOnObject("base_prc_skin", oPC);
                _ForceEquipSkin(oPC, oSkin, INVENTORY_SLOT_CARMOUR);
                //AssignCommand(oPC, ActionEquipItem(oSkin, INVENTORY_SLOT_CARMOUR));

                // The skin should not be droppable
                SetDroppableFlag(oSkin, FALSE);
                // other scripts should not be able to destroy the skin
                AssignCommand(oSkin, SetIsDestroyable(FALSE));
            }

            // Cache the skin reference for further lookups during the same script
            //SetLocalObject(oPC, "PRCSkinCache", oSkin);
            //DelayCommand(0.0f, DeleteLocalObject(oPC, "PRCSkinCache"));
        }
    }
    return oSkin;
}

