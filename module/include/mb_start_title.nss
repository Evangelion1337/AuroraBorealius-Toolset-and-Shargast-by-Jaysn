// Create the Listener
void main()
{
   object oPC = GetPCSpeaker();

   if(GetLocalInt(oPC, "MB_POSTED")==1)
   {
      FloatingTextStringOnCreature("You have already posted. Please try again later.",oPC,FALSE);
      return;
   }
   AssignCommand(oPC, ClearAllActions());
   AssignCommand(oPC, ActionPauseConversation());
   object oListener = CreateObject(OBJECT_TYPE_CREATURE, "ad_post_taker", GetLocation(oPC), FALSE);
   SetLocalString(oListener, "SPEAK_ACTION", "TITLE");
   SetLocalObject(oListener, "Activator", oPC);
   SetLocalObject(oPC,"MBOARD",OBJECT_SELF);
}
