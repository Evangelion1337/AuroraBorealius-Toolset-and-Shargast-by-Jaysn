int StartingConditional()
{
    if (GetLocalInt(GetPCSpeaker(),"ZEP_CR_PART")!=ITEM_APPR_ARMOR_MODEL_ROBE)
        return TRUE;
    else return FALSE;
}
