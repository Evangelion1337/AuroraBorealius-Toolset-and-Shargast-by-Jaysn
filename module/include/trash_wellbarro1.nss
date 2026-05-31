//put onHeartbeat of your own trashcan,
//make the trashcan usable and has inventory.
//This will check the area for remains,
//pick out all the inventory in the remains, and
//transfer it to its own inventory.
//Created by semajack
//ne questions or tips send to semajack@hotmail.com

void TrashObject(object oTrash, string sResref, int iStack)
{
    object oItem;
    if(GetHasInventory(oTrash) == TRUE)
    {
    oItem = GetFirstItemInInventory(oTrash);
        while(GetIsObjectValid(oItem))
        {
        iStack = GetItemStackSize(oItem);
        sResref = GetResRef(oItem);
        CreateItemOnObject(sResref,OBJECT_SELF,iStack);
        DestroyObject(oItem);
        oItem = GetNextItemInInventory(oTrash);
        }
    //DestroyObject(oTrash);
    }
    else
    {
    iStack = GetItemStackSize(oTrash);
    sResref = GetResRef(oTrash);
    CreateItemOnObject(sResref,OBJECT_SELF,iStack);
    DestroyObject(oTrash);
    }
}
void main()
{
int oGo = GetLocalInt(OBJECT_SELF,"go");
object oArea = GetArea(OBJECT_SELF);
object oTrash = GetFirstObjectInArea(oArea);
//object oItem = GetFirstItemInInventory(oTrash);
string sResref;
int iStack;

    if(oGo == 30)
    {
    SetLocalInt(OBJECT_SELF,"go",0);
    while(GetIsObjectValid(oTrash))
        {
            if(GetObjectType(oTrash) == OBJECT_TYPE_PLACEABLE && GetTag(oTrash) == "BodyBag")
            {
            TrashObject(oTrash, sResref, iStack);
            }
            else
            {
            //if(GetObjectType(oTrash) == OBJECT_TYPE_ITEM)
            //TrashObject(oTrash, sResref, iStack);
            }
        oTrash = GetNextObjectInArea(oArea);
        }
    }
    else
    {
    ++oGo;
    SetLocalInt(OBJECT_SELF,"go",oGo);
    }

}
