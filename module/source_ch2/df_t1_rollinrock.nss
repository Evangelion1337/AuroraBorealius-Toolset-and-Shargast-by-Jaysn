void TrapPlayAnim(object oTrap)
{
   AssignCommand(oTrap, PlayAnimation(ANIMATION_PLACEABLE_ACTIVATE));
}

void RollingRockHitPC(object oPC, int nDamage)
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oPC);
    AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_NORMAL), oPC));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectKnockdown(), oPC, 30.0f);
}

int TrapSave(object oPC, int nDC, int nDamage)
{
    if(!ReflexSave(oPC, nDC, SAVING_THROW_TYPE_TRAP))
    {
        if (GetHasFeat(FEAT_IMPROVED_EVASION, oPC))
            nDamage /= 2;
    }
    else if (GetHasFeat(FEAT_EVASION, oPC) || GetHasFeat(FEAT_IMPROVED_EVASION, oPC))
    {
        nDamage = 0;
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_IMP_REFLEX_SAVE_THROW_USE), oPC);
    }
    else
        nDamage /= 2;

    return nDamage;
}

void main()
{
    if(GetLocalInt(OBJECT_SELF,"TRP_TRIGGERED"))
        return;

    SetLocalInt(OBJECT_SELF,"TRP_TRIGGERED",1);


    object oTrap;

    if(GetLocalInt(OBJECT_SELF,"TRP_PLCBL_SHOW")==0)
    {
        location lPlcbl = GetLocalLocation(OBJECT_SELF,"TRP_PLCBL_LOC");
        SetLocalInt(OBJECT_SELF,"TRP_PLCBL_SHOW",1);
        oTrap = CreateObject(OBJECT_TYPE_PLACEABLE,"rollingrockpcbl",lPlcbl);
        SetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ",oTrap);
    }
    else
        oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");

    AssignCommand(oTrap,PlaySound("as_na_rockcavlg1"));
    AssignCommand(oTrap,DelayCommand(1.0,TrapPlayAnim(oTrap)));

    int nDC=25;
    int nDamage = d6(2);
    location lEnd;
    vector vVector,vOrigin, vAngle;
    float fFacing;
    object oArea;

    lEnd = GetLocation(oTrap);
    fFacing = GetFacingFromLocation(lEnd);
    vVector = GetPositionFromLocation(lEnd);
    vAngle = AngleToVector(fFacing);
    oArea = GetAreaFromLocation(lEnd);
    lEnd = Location(oArea,Vector(vVector.x+(-20.0*vAngle.x),vVector.y+(-20.0*vAngle.y),vVector.z),-fFacing);

    vOrigin = Vector(vVector.x+(-24.0*vAngle.x),vVector.y+(-24.0*vAngle.y),vVector.z);

    object oPC = GetFirstObjectInShape(SHAPE_SPELLCYLINDER,24.5,lEnd,FALSE,OBJECT_TYPE_CREATURE,vOrigin);
    while(GetIsObjectValid(oPC))
    {
        nDamage = TrapSave(oPC, nDC, nDamage);

        if(nDamage>0)
        {
            DelayCommand(1.5,RollingRockHitPC(oPC,nDamage));
        }
        oPC = GetNextObjectInShape(SHAPE_SPELLCYLINDER,24.5,lEnd,FALSE,OBJECT_TYPE_CREATURE,vOrigin);
    }
}
