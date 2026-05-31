//for externals
void main()
{ object oPC = GetLastUsedBy();
  if( !GetIsPC( oPC)) return;

  ActivatePortal( oPC, "153.92.211.51:5122", "ROS2", "WP_ROSD", TRUE);
}
