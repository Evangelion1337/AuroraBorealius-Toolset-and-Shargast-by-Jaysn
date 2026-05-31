//Filename: trap_on_load
//Usage/Description:
//      Trap script for use with CEP Traps.  Used in trap
//      search routines.

#include "zep_inc_scrptdlg"

void AssociateTrap(string sTag, int nID)
{
    object oPlcbl = GetObjectByTag(sTag);
    object oTrap;
    int nN=1;
    int nT;
    string sStringPart1 = GetStringByStrRef(nZEPTrapSearch1,GENDER_MALE);
    string sStringPart2 = GetStringByStrRef(nZEPTrapSearch2,GENDER_MALE);
    string sStringPart3 = GetStringByStrRef(nZEPTrapSearch3,GENDER_MALE);

    while(GetIsObjectValid(oPlcbl))
    {
        nT = 1;
        oTrap = GetNearestObject(OBJECT_TYPE_TRIGGER|OBJECT_TYPE_DOOR|OBJECT_TYPE_PLACEABLE, oPlcbl,nT);
        while(GetIsObjectValid(oTrap))
        {
            PrintString(sStringPart1+sTag+sStringPart2+IntToString(nID)+sStringPart3+GetTag(oTrap));
            if(GetIsTrapped(oTrap)&&(GetTrapBaseType(oTrap)==nID))
                break;

            PrintString(sStringPart1+sTag+sStringPart2+IntToString(GetTrapBaseType(oTrap))+sStringPart3+GetTag(oTrap));


            nT++;
            oTrap = GetNearestObject(OBJECT_TYPE_ALL, oPlcbl,nT);
        }

        if(GetIsObjectValid(oTrap))
        {
            if(nID==45)
            {
                SetLocalObject(oTrap,"TRP_PLCBL_OBJ",oPlcbl);
            }
            else
            {
                SetLocalLocation(oTrap,"TRP_PLCBL_LOC",GetLocation(oPlcbl));
                DestroyObject(oPlcbl);
            }
        }
        oPlcbl = GetObjectByTag(sTag,nN);
        nN++;//meant to be this way round
    }
}

void main()
{
    AssociateTrap("RazorWire",123);
    AssociateTrap("RollingRock",120);
    AssociateTrap("WallBlade",125);
    AssociateTrap("FallingBrick",126);
    AssociateTrap("SwingingRock",124);
    AssociateTrap("SwingingBlade",127);
    AssociateTrap("WhirlingBlade",129);
    AssociateTrap("Flood",128);
    AssociateTrap("RugPit",121);
    AssociateTrap("MetalPit",122);
}
