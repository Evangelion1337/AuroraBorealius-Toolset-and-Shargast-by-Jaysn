//:://////////////////////////////////////////////////////////////////////////
//:: Filename:   rs_shareloot
//:: Created By: Robert Stehwien (rstehwien@hotmail.com)
//:: Created On: 8/7/2002
//:: Purpose:    Split loot between party member
//:: Instructions:
//::    Attach to the OnClose event of a placable container
//::    Players place items in container and close it.  This sells each
//::    non-plot item worth more than 0 gold.  Gems and Gold are worth full
//::    value and everything else is worth 50% (minimum 1 gold).  If the
//::    value is greater than 0 gold it is then divided up among the group
//::    with a minimum of 1 gold each.
//:://////////////////////////////////////////////////////////////////////////

int GetNumberOfPartyMembers(object oMember);
int SellInventory(object oContainer = OBJECT_SELF);
void GivePartyGold(object oMember, int nGold);

// main loop called OnClose event
void main()
{
    object oLastOpener = GetLastOpenedBy();
    if ( GetIsObjectValid(oLastOpener) == FALSE )
        return;

    int nPartySize = GetNumberOfPartyMembers(oLastOpener);
    if ( nPartySize <= 0 )
        return;

    int nValue = SellInventory();
    if ( nValue <= 0 )
        return;

    // figure out share, with a minimum of 1 gp each
    int nShare = nValue/nPartySize;
    if ( nShare < 1 )
        nShare = 1;

    GivePartyGold(oLastOpener, nShare);
}

// Sells all the items in a givent inventory and returns the value
//
// oContainer         container to search
int SellInventory(object oContainer = OBJECT_SELF)
{
    int nValue = GetGold(oContainer);
    int nCurValue;
    float nPercent;
    int bShowContainerWarning = TRUE;

    object oItem = GetFirstItemInInventory(oContainer);
    while ( GetIsObjectValid(oItem) == TRUE )
    {
        // don't sell off containers
        if ( GetHasInventory(oItem) == TRUE )
        {
            // recursively calling GetInventorySellValue(oItem) causes
            // a crash on the last GetNextItemInInventory() for the oItem
            // all of the items in containers are found in the loot seller
            if ( bShowContainerWarning == TRUE )
            {
                ActionSpeakString("I will not sell containers.");
                bShowContainerWarning = FALSE;
            }
        }

        // sell off non plot items with a value over 0 gold
        else if ( (GetPlotFlag(oItem) == FALSE) &&
                  (GetGoldPieceValue(oItem) > 0) )
        {
            // gems are worth full value, everything else the default percent (50%)
            nPercent = 0.15;
            if ( GetBaseItemType(oItem) == BASE_ITEM_GEM )
                nPercent = 1.0;

            // make sure everything sells for at least 1 gold
            nCurValue = FloatToInt(GetGoldPieceValue(oItem) * nPercent);
            if ( nCurValue <= 0 )
                nCurValue = 1;

            nValue += nCurValue;

            DestroyObject(oItem);
        }

        oItem = GetNextItemInInventory(oContainer);
    }

    return nValue;
}

// gives gold to each party member
//
// oMember         PC in target party
// nGold           amount of gold to give each member
void GivePartyGold(object oMember, int nGold)
{
    object oPartyMember = GetFirstFactionMember(oMember, TRUE);
    while (GetIsObjectValid(oPartyMember) == TRUE)
    {
        GiveGoldToCreature(oPartyMember, nGold);
        oPartyMember = GetNextFactionMember(oMember, TRUE);
    }
}

// Returns the number of PCs in oMember's party
//
// oMember         PC in target party
int GetNumberOfPartyMembers(object oMember)
{
    int nCount = 0;
    object oPartyMember = GetFirstFactionMember(oMember, TRUE);
    while (GetIsObjectValid(oPartyMember) == TRUE)
    {
        nCount += 1;
        oPartyMember = GetNextFactionMember(oMember, TRUE);
    }
    return nCount;
}
