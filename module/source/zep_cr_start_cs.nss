#include "zep_inc_craft"

void main() {
    object oPC = GetPCSpeaker();
    object oShield = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
    ZEP_StartCraft(oPC, oShield);
    ZEP_SetPart(oPC, ZEP_CR_SHIELD, 57);
}
