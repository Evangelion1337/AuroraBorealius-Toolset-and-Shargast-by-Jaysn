//Onlevel 

void main()
{
object oPC = GetPCLevellingUp();


string oPCname = GetName(oPC);

   ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_LIGHTNING_M), oPC);
   ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_BREACH), oPC);
   ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SUPER_HEROISM), oPC);
   SpeakString(( oPCname + " is now a greater foe!!!"), TALKVOLUME_SHOUT);
}
