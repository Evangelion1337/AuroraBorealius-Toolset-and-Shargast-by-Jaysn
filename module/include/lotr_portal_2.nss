void main()
{ object oPC = GetLastUsedBy();
  if( !GetIsPC( oPC)) return;

  ActivatePortal( oPC, "153.92.211.51:5121", "", "WP_LOTR_OO2", TRUE);
}
