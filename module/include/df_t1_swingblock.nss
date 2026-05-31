void TrapPlayAnim(object oTrap)
{
   AssignCommand(oTrap, PlayAnimation(ANIMATION_PLACEABLE_ACTIVATE));
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
        oTrap = CreateObject(OBJECT_TYPE_PLACEABLE,"swingingrockpcbl",lPlcbl);
        SetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ",oTrap);
    }
    else
        oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");


    AssignCommand(oTrap,DelayCommand(1.0,TrapPlayAnim(oTrap)));

    int nDC =20;
    int nDamage, nN;
    object oTriggerer = GetEnteringObject();

    nDamage = TrapSave(oTriggerer, nDC, d6(2));
    if(nDamage>0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oTriggerer);
        AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_NORMAL), oTriggerer));
    }

    object oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTriggerer);
    while(GetIsObjectValid(oPC)&&(GetDistanceBetween(oTriggerer,oPC)<2.0))
    {
        nDamage = d6(2);

        nDamage = TrapSave(oPC, nDC, nDamage);

        if(nDamage>0)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oPC);
            AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_NORMAL), oPC));
        }

        nN++;
        oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTriggerer, nN);
    }
}
