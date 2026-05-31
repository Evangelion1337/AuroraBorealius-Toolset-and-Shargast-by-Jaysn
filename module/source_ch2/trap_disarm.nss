void main()
{
    object oAOE;
    object oPlcbl = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");

    oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT,oPlcbl);
    if(GetAreaOfEffectCreator(oAOE)==OBJECT_SELF)
    {
        DestroyObject(oAOE);
    }

    if(GetIsObjectValid(oPlcbl))
    {
        AssignCommand(oPlcbl, PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
        if(GetTag(oPlcbl)=="RazorWire")
            DestroyObject(oPlcbl);
    }

    DeleteLocalInt(OBJECT_SELF,"TRP_PLCBL_SHOW");
    DeleteLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    DeleteLocalLocation(OBJECT_SELF,"TRP_PLCBL_LOC");
}
