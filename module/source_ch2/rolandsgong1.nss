void main()
{
    //Ring The Bell...
    ActionDoCommand(PlaySound("as_cv_potclang3"));

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectVisualEffect(VFX_FNF_PWSTUN),OBJECT_SELF);
    DelayCommand(3.0, SpeakString (" Roland is ready to help you "));
    DelayCommand(3.0, OpenStore(GetObjectByTag("Rolandstore"), GetLastUsedBy()));
}
