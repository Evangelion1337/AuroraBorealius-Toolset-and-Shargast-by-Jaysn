#include "zep_inc_craft"

void main() {
    object oPC = GetPCSpeaker();
    object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
    ZEP_StartCraft(oPC, oArmor);
}
