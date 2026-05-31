#include "housing_db"

void main()
{
    object oDoor = OBJECT_SELF;
    object oPC = GetLastUsedBy();
    if(!GetIsPC(oPC)) return;

    string sDoorTag = GetTag(oDoor);
    int nPropID = GetPropertyIDByDoor(sDoorTag);
    if(nPropID < 1) return;

    if(CanAccessProperty(nPropID, oPC))
    {
        SetLocked(oDoor, FALSE);
        DelayCommand(3.0, SetLocked(oDoor, TRUE));
    }
    else if(IsPropertyLocked(sDoorTag))
    {
        SendMessageToPC(oPC, "This door is locked. Only the owner or guests may enter.");
    }
}
