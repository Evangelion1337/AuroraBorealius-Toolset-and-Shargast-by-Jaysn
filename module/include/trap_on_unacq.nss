void main()
{
    object oItem = GetModuleItemLost();
    object oPC = GetModuleItemLostBy();

    if(GetTag(oItem)=="NW_IT_TRAP048")
    {
        object oTrap = GetNearestTrapToObject(oPC);
        SetLocalLocation(oTrap,"TRP_PLCBL_LOC",GetLocation(oPC));
    }
}
