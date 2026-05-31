/*
** SetListeningPatterns NW_C2_DEFAULT4
*/
#include "NW_I0_GENERIC"
#include "mb_inc"

void main()
{
   string sACTION = GetLocalString(OBJECT_SELF, "SPEAK_ACTION");

   int iMatch = GetListenPatternNumber();
   object oShouter = GetLastSpeaker();
   ClearAllActions();

   if(iMatch == 7070 && GetIsObjectValid(oShouter))
   {
      if(oShouter == GetLocalObject(OBJECT_SELF, "Activator"))
      {
        SetLocalString(GetLocalObject(oShouter,"MBOARD"), sACTION, GetMatchedSubstring(0));
        DeleteLocalObject(oShouter,"MBOARD");
        if(sACTION=="TITLE")
           SetCustomToken(7001, GetMatchedSubstring(0));
        else
           SetCustomToken(7002, GetMatchedSubstring(0));

        int nOK = MB_FailFilterTest(oShouter, GetMatchedSubstring(0));
        SetLocalInt(oShouter, "BAD_WORDS", nOK);

        AssignCommand(oShouter, ActionResumeConversation());
        DeleteLocalObject(OBJECT_SELF, "Activator");
        DestroyObject(OBJECT_SELF, 1.0);
      }
   }

   if(GetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT))
   {
       SignalEvent(OBJECT_SELF, EventUserDefined(1004));
   }
}
