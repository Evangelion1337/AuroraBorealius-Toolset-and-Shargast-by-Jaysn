void main()
{
   effect eVis1 = EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_NATURE);
   effect eVis2 = EffectVisualEffect(VFX_COM_CHUNK_GREEN_SMALL);
   location lShrieker = GetLocation(OBJECT_SELF);

   {
        DestroyObject(OBJECT_SELF,0.0);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT,eVis1,lShrieker);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT,eVis2,lShrieker);

   }

}
