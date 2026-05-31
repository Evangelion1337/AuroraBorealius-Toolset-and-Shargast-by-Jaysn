void TrapPlayAnim(object oTrap)
{
   AssignCommand(oTrap, PlayAnimation(ANIMATION_PLACEABLE_ACTIVATE));
}


void ResetWhirlingBlades()
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");

    DeleteLocalInt(OBJECT_SELF,"TRP_TRIGGERED");

    if(GetIsObjectValid(oTrap))
    {
        AssignCommand(oTrap, PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
        DestroyObject(oTrap,1.0);
        DeleteLocalInt(OBJECT_SELF,"TRP_PLCBL_SHOW");
    }
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
        oTrap = CreateObject(OBJECT_TYPE_PLACEABLE,"whirlbladepcbl",lPlcbl);
        SetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ",oTrap);
    }
    else
        oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");

    AssignCommand(oTrap,DelayCommand(1.0,TrapPlayAnim(oTrap)));
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,EffectAreaOfEffect(40),GetLocation(oTrap),120.0);
    DelayCommand(120.0, ResetWhirlingBlades());

    int nDC;
    int nDamage;
    string sTag = GetTag(oTrap);

    object oPC = GetFirstObjectInShape(SHAPE_SPHERE,5.0,GetLocation(oTrap));
    while(GetIsObjectValid(oPC))
    {
        nDamage = d4(2)+4;
        nDC = 20;
        if(!ReflexSave(oPC, nDC, SAVING_THROW_TYPE_TRAP))
        {
            if (GetHasFeat(FEAT_IMPROVED_EVASION, oPC))
            {
                nDamage /= 2;
            }
        }
        else if (GetHasFeat(FEAT_EVASION, oPC) || GetHasFeat(FEAT_IMPROVED_EVASION, oPC))
        {
            nDamage = 0;
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_IMP_REFLEX_SAVE_THROW_USE), oPC);
        }
        else
        {
            nDamage /= 2;
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_IMP_REFLEX_SAVE_THROW_USE), oPC);
        }

        if(nDamage>0)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_SLASHING, DAMAGE_POWER_NORMAL), oPC);
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_BLOOD_CRT_RED), GetLocation(oPC));
        }
        oPC = GetNextObjectInShape(SHAPE_SPHERE,5.0,GetLocation(oTrap));
    }
}
