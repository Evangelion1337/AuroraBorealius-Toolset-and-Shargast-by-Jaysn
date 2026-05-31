void TransferItems(object oDisk, object oCaster)
{
    int bDrop = !GetIsObjectValid(oCaster);
    if(bDrop)
    {
        oCaster = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_lootbag3", GetLocation(oDisk));
        SetLocalInt(oCaster, "NW_DO_ONCE", TRUE);
        DestroyObject(oCaster, 0.4);
    }

    object oInv;
    int i;
    for(i = 0; i < 14; i++)
    {
        oInv = GetItemInSlot(i, oDisk);
        if(GetIsObjectValid(oInv))
            ActionGiveItem(oInv, oCaster);
    }

    oInv = GetFirstItemInInventory(oDisk);
    while(GetIsObjectValid(oInv))
    {
        ActionGiveItem(oInv, oCaster);
        oInv = GetNextItemInInventory(oDisk);
    }
}

void DestroyDisk(object oDisk)
{
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_UNSUMMON), GetLocation(oDisk));
    DestroyObject(oDisk, 0.5);
}