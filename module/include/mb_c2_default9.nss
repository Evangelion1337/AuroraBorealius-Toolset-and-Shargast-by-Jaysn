/*
** Create invisible Message Taker with these scripts
** OnSpawn NW_C2_DEFAULT9
*/
void main()
{
  string sACTION = GetLocalString(OBJECT_SELF, "SPEAK_ACTION");

  SetListenPattern(OBJECT_SELF, "**", 7070); //listen for post
  //SetListenPattern(OBJECT_SELF, sFILTER, 7071);
  ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectInvisibility(INVISIBILITY_TYPE_IMPROVED),
                        OBJECT_SELF);
  SetListening(OBJECT_SELF, TRUE);
  DelayCommand(2.0, FloatingTextStringOnCreature("Please speak the message "+sACTION, GetLocalObject(OBJECT_SELF, "Activator"), FALSE));
  DelayCommand(300.0, DestroyObject(OBJECT_SELF));
}
