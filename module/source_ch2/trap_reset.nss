//File name: trap_reset
//Usage/Description:
//      Script fired during attmept to reset/disable a trap
//      for use with CEP traps.

#include "zep_inc_scrptdlg"

void main()
{
    object oPC = GetLastUsedBy();
    string sTag = GetTag(OBJECT_SELF);
    int nTrap = StringToInt(GetStringRight(sTag,1));

    sTag = GetStringLeft(sTag,GetStringLength(sTag)-1);
    object oO = GetNearestObjectByTag(sTag, OBJECT_SELF,  nTrap);
    object oAOE;
    string sMessageToPC = GetStringByStrRef(nZEPTrapReset ,GENDER_MALE);
    SendMessageToPC(oPC,sMessageToPC);
    DeleteLocalInt(oO,"TRP_TRIGGERED");

    object oTrap = GetLocalObject(oO,"TRP_PLCBL_OBJ");
    oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT,oTrap);
    if(GetAreaOfEffectCreator(oAOE)==oO)
    {
        DestroyObject(oAOE);
    }

    if(sTag=="RPFTrap")
    {
        //AssignCommand(oTrap, PlaySound("as_sw_clothcl1"));
        AssignCommand(oTrap, PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
    }
    else if(sTag=="MPFTrap")
    {
        //AssignCommand(oTrap, PlaySound("as_dr_metmedcr2"));
        AssignCommand(oTrap, PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
        DestroyObject(oTrap,1.0);
        DeleteLocalInt(oO,"TRP_PLCBL_SHOW");
    }
    else if(sTag=="FlFTrap")
    {
        AssignCommand(oTrap, PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
        DestroyObject(oTrap,1.0);
        DeleteLocalInt(oO,"TRP_PLCBL_SHOW");
        SetLocked(GetNearestObject(OBJECT_TYPE_DOOR,oO),FALSE);
    }
    else
    {
        AssignCommand(oTrap, PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
        DestroyObject(oTrap,1.0);
        DeleteLocalInt(oO,"TRP_PLCBL_SHOW");
    }

    PlaySound("as_sw_lever1");
}
