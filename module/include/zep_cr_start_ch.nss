#include "zep_inc_craft"

void main() {
    object oPC = GetPCSpeaker();
    object oHelmet = GetItemInSlot(INVENTORY_SLOT_HEAD, oPC);
    ZEP_StartCraft(oPC, oHelmet);
    ZEP_SetPart(oPC, ZEP_CR_HELMET, 182);
}
