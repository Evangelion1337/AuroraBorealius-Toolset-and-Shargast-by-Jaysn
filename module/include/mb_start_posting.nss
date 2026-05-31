// Create the Listener
void main()
{
   object oPC = GetPCSpeaker();

   AssignCommand(oPC, ClearAllActions());
   AssignCommand(oPC, ActionPauseConversation());
   object oListener = CreateObject(OBJECT_TYPE_CREATURE, "ad_post_taker", GetLocation(oPC), FALSE);
   SetLocalString(oListener, "SPEAK_ACTION", "BODY");
   SetLocalObject(oListener, "Activator", oPC);
   SetLocalObject(oPC,"MBOARD",OBJECT_SELF);
}
