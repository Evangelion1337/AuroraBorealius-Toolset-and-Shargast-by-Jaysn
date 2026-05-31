void main()
{
     object oWP = GetObjectByTag("PelargirGaurd_15");
     location lDestination = GetLocation(oWP);
     ActionMoveToLocation(lDestination,FALSE);
}
