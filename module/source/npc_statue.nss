  void main()
{
    effect eHold = EffectVisualEffect(VFX_DUR_FREEZE_ANIMATION);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eHold, OBJECT_SELF);
//    effect ePetrify = EffectVisualEffect(VFX_DUR_PETRIFY);
//    ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePetrify, OBJECT_SELF);
    SetLocalInt(OBJECT_SELF, "X1_L_IMMUNE_TO_DISPEL", 10);

}
