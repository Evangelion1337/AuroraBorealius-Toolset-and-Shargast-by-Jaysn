//:://///////////////////////////////////////////////////////////////////////
//:: Name Simple Drop Weapons v1.2
//:: FileName se_drop_weapon
//:: Copyright (c) 2005 Melnibone Corp.
//:://///////////////////////////////////////////////////////////////////////
/*
    DESCRIPTION:

    On death of the NPC drop it's equipped items to the ground in a life
    like manner.

    Self cleaning - Set a timer for the decay of the weapons if not picked
    up, owned or sold.

    APPLICATION INSTRUCTIONS:

    1) Open the OnDeath script of the npc, by default
       this will be nw_c2_default7.

    2) Add this include to the top of the script ie:
       #include "se_drop_weapons"

    3) Add - SE_DropHandSlot(OBJECT_SELF, INVENTORY_SLOT_LEFTHAND, 180.0, TRUE);
             SE_DropHandSlot(OBJECT_SELF, INVENTORY_SLOT_RIGHTHAND, 180.0, TRUE);
             Inside the void main() of nw_c2_default7, or your OnDeath script.

    4) Set the decay timer in the SE_DropHandSlot function.
       Set to (3) minutes by default(setting it to 0.0 turns decay off)

    5) Set the droppable flag nDroppable:
       TRUE - Only drop if marked as droppable on the npc
       FALSE - Drop hand slots if marked as droppable or not

*/
//:://///////////////////////////////////////////////////////////////////////
//:: Created By: Sir Elric
//:: Created On: 25rd June, 2005
//:: [Some original code used and edited from HCR]
//:://///////////////////////////////////////////////////////////////////////

// Generates a location appropriate for an item dropped to the ground
//  - oBody:        a dead NPC/creature
//  - nSlot:        one of the INVENTORY_SLOT_*HAND constants
location SE_CreateDropLocation(object oBody, int nSlot);
location SE_CreateDropLocation(object oBody, int nSlot)
{
    vector vBody = GetPosition(oBody);

    // get the offsets appropriate to the hand the item is falling from
    float fFacing = (nSlot == INVENTORY_SLOT_LEFTHAND) ? 45.0f : -45.0f;
    float fWeapon = (nSlot == INVENTORY_SLOT_LEFTHAND) ? -20.0f : 20.0f;

    // add a random element to facings and direction, values are arbitray
    fFacing += GetFacing(oBody) + IntToFloat(d20());
    fWeapon += GetFacing(oBody) - IntToFloat(d20(2));
    float fDistance = 0.5f + (IntToFloat(d10())/10);

    // get co-ordinates of a point fDistance meters away at fFacing degrees
    float fX = vBody.x + cos(fFacing) * fDistance;
    float fY = vBody.y + sin(fFacing) * fDistance;

    // return the location
    return Location(GetArea(oBody), Vector(fX, fY, vBody.z), fWeapon);
}

// Destroys any associated dropped items remaining on the ground,
// if not currently owned or in a store.
//  - oItem:        one of the visible INVENTORY_SLOT_* constants
void SE_CleanUpDropped(object oItem);
void SE_CleanUpDropped(object oItem)
{
    object oMod   = GetModule();
    object oOwner = GetItemPossessor(oItem);

    // if not held by something valid
    if(GetIsObjectValid(oOwner) == FALSE)
       AssignCommand(oMod, DestroyObject(oItem));
}

// Drop items from oNPC to the ground from one of the hand inventory slots.
//  - oNPC:       a dead NPC/creature
//  - nSlot:      one of the INVENTORY_SLOT_*HAND slots
//  - fDelay:     delay timer to clean up dropped item in seconds - 0.0 is off
//  - nDroppable: only drop if marked as droppable on the npc - TRUE or FALSE
void SE_DropHandSlot(object oNPC, int nSlot, float fDecay, int nDroppable);
void SE_DropHandSlot(object oNPC, int nSlot, float fDecay, int nDroppable)
{
    object oItem = GetItemInSlot(nSlot, oNPC);

    // pre-emptive abort: object is not valid
    if(GetIsObjectValid(oItem) == FALSE)
    {
        return;
    }
    // if set as droppable or drop all flag is set continue
    if(GetDroppableFlag(oItem) || !GetDroppableFlag(oItem) && !nDroppable)
    {
       object oMod = GetModule();
       object oCopy;
       // stop duping
       SetDroppableFlag(oItem, FALSE);
       // copy item to ground, destroy original
       oCopy = CopyObject(oItem, SE_CreateDropLocation(oNPC, nSlot));
       // note this only removes the "visual" items on the dead NPC
       DestroyObject(oItem);
       // clean up dropped copy if not owned after delay(if set, 0.0 is off)
       if(fDecay > 0.0)
       AssignCommand(oMod, DelayCommand(fDecay, SE_CleanUpDropped(oCopy)));
    }
}
//* void main(){}
