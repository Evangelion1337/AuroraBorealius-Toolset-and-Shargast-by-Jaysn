void main()
{
    effect eMarilith = EffectModifyAttacks(5);
    eMarilith = SupernaturalEffect(eMarilith);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eMarilith, OBJECT_SELF);
}
