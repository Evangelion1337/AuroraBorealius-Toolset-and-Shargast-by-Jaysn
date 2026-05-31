#include "x2_inc_itemprop"
void main()
{
object oPC = GetPCItemLastEquippedBy();
object oItem = GetPCItemLastEquipped();
DelayCommand(0.2,AssignCommand(oPC,ClearAllActions(TRUE)));
if ((GetItemHasItemProperty(oItem, ITEM_PROPERTY_HOLY_AVENGER))
&&((GetLevelByClass(CLASS_TYPE_PALADIN, oPC) == 0)
||(GetAlignmentLawChaos(oPC) != ALIGNMENT_LAWFUL)
||(GetAlignmentGoodEvil(oPC) != ALIGNMENT_GOOD)))
{
SetLocalInt(oItem, "HA_Depower", 1);
IPRemoveMatchingItemProperties(oItem, ITEM_PROPERTY_HOLY_AVENGER, -1);
SendMessageToPC(oPC, "You are not a Paladin and/or Lawful Good. You cannot use Holy Avengers.");
}
}
