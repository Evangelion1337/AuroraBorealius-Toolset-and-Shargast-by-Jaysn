//ffbj addition 15.04.07

void main()
{
  object oTrap = GetModuleItemAcquired();
  object oPC = GetModuleItemAcquiredBy();
  string sPC = GetName(oPC);
  SetName(oTrap,  sPC + " Trap ");
}
