void ZEP_PurifyItem(object oItem) {
    if (GetLocalInt(oItem, "ZEP_CR_TEMPITEM")) {
        PrintString("Destroyed: "+GetName(oItem));
        DestroyObject(oItem);
    }
}

void main() {
    object oPC = GetEnteringObject();
    if (GetLocalInt(oPC, "ZEP_CR_STARTED")) {
        ZEP_PurifyItem(GetItemInSlot(INVENTORY_SLOT_CHEST, oPC));
        ZEP_PurifyItem(GetItemInSlot(INVENTORY_SLOT_HEAD, oPC));
        ZEP_PurifyItem(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC));
        ZEP_PurifyItem(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC));
        object oItem = GetFirstItemInInventory(oPC);
        while (GetIsObjectValid(oItem)) {
            ZEP_PurifyItem(oItem);
            oItem = GetNextItemInInventory(oPC);
        }
        DeleteLocalInt(oPC, "ZEP_CR_STARTED");
    }
}
