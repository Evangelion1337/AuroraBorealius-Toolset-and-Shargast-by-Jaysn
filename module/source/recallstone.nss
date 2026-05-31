void main()
{


if (GetTag(GetItemActivated()) ==  "recallstone")
   {
    if (GetItemActivatedTarget() == GetItemActivator())
    {
    SetLocalLocation(GetItemActivator(),"last_location_kok", GetLocation(GetItemActivator()));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SOUND_BURST), GetItemActivator());
    }
    else if (GetItemActivatedTarget() == GetObjectByTag("recallstone"))
    {
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_UNSUMMON), GetItemActivator());
    AssignCommand(GetItemActivator(), DelayCommand(0.5, ActionJumpToLocation(GetLocalLocation(GetItemActivator(), "last_location_kok_last"))));
//    DelayCommand(1.4, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_BREACH), GetItemActivator())); //Optional
    }
    else
    {
    SetLocalLocation(GetItemActivator(),"last_location_kok_last", GetLocation(GetItemActivator()));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_UNSUMMON), GetItemActivator());
    AssignCommand(GetItemActivator(), DelayCommand(0.5, ActionJumpToLocation(GetLocalLocation(GetItemActivator(), "last_location_kok"))));
//    DelayCommand(1.4, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_BREACH), GetItemActivator())); //Optional
} }}
