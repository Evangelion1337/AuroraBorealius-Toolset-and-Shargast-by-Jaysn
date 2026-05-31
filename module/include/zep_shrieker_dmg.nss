void main()
{
    effect eVis3 = EffectVisualEffect(VFX_COM_BLOOD_REG_GREEN);
    location lShrieker = GetLocation(OBJECT_SELF);
    {
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT,eVis3,lShrieker);

    }

}
