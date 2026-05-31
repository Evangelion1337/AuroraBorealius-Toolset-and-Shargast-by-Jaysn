void main()
{
    object oObject = GetItemActivated();
    object oTarget = GetItemActivatedTarget();
    string sTag = GetTag(oObject);
    string sDestination1 = "WP_town";
    string sDestination2 = "WP_bla";
    if (sTag == "MagicWand1")
    {
        AssignCommand(oTarget, ActionJumpToLocation(GetLocation(GetObjectByTag(sDestination1))));
    }
    else if (sTag == "MagicWand2")
    {
       AssignCommand(oTarget, ActionJumpToLocation(GetLocation(GetObjectByTag(sDestination2))));
    }
}


