//for external player
void main()
{ object oPC = GetLastUsedBy();
  if( !GetIsPC( oPC)) return;

  ActivatePortal( oPC, "153.92.211.51:5121", "", "WP_ROSD", TRUE);
}
