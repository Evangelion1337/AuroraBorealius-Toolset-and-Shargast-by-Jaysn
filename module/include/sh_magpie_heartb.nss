void main()
{
object oBag = GetObjectByTag("BodyBag",1);

if (GetHasInventory(oBag) == TRUE)
{
if (oBag != OBJECT_INVALID)
{
ActionMoveToObject(oBag,FALSE,100.0);
object oLoot = GetFirstItemInInventory(oBag);
while (oLoot != OBJECT_INVALID)
{
oLoot = GetNextItemInInventory(oBag);
ActionTakeItem(oLoot, oBag);
}
object oInv = GetFirstItemInInventory(OBJECT_SELF);
while (oInv != OBJECT_INVALID)
{
oInv = GetNextItemInInventory(OBJECT_SELF);
ActionDoCommand(DestroyObject(oInv));
}
}
}
}


