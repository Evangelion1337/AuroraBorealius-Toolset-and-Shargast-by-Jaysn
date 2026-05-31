void TrapPlayAnim(object oTrap)
{
   AssignCommand(oTrap, PlayAnimation(ANIMATION_PLACEABLE_ACTIVATE));
}

void main()
{
    if(GetLocalInt(OBJECT_SELF,"TRP_TRIGGERED"))
        return;

    SetLocalInt(OBJECT_SELF,"TRP_TRIGGERED",1);

    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");

    TrapPlayAnim(oTrap);
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,EffectAreaOfEffect(38),GetLocation(oTrap),HoursToSeconds(200));
    return;
}
