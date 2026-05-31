#include "x2_inc_itemprop"
void main()
{
object oPC = GetPCItemLastUnequippedBy();
object oItem = GetPCItemLastUnequipped();
int iHoly = GetLocalInt(oItem, "HA_Depower");
if(GetLocalInt(oItem,"HA_Depower")==1)
{
itemproperty ipAdd = ItemPropertyHolyAvenger();
IPSafeAddItemProperty(oItem, ipAdd);
SetLocalInt(oItem, "HA_Depower", 0);
}
}
