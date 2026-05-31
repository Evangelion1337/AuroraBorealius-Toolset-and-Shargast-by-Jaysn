void main()
{
   DeleteLocalString(OBJECT_SELF, "SPEAK_ACTION");
   DeleteLocalString(OBJECT_SELF, "BODY");
   DeleteLocalString(OBJECT_SELF, "TITLE");
   int nLoop;
   for(nLoop=1; nLoop<30; nLoop++)
   {
      SetCustomToken(7000+nLoop, "");
   }
   for(nLoop=1; nLoop<8; nLoop++)
   {
      DeleteLocalInt(GetPCSpeaker(),"POST_ID_"+IntToString(nLoop));
   }
   DeleteLocalInt(GetPCSpeaker(), "BAD_WORDS");
   DeleteLocalObject(OBJECT_SELF, "Activator");
   DeleteLocalInt(OBJECT_SELF,"MB_LOOP");
   DeleteLocalInt(GetPCSpeaker(),"MB_LOOP");
}
