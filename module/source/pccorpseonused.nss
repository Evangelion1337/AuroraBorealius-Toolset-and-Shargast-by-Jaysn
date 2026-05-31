//::////////////////////////////////////////////////////////////////////////::\\
//::  PC Corpse OnUsed Event                                                ::\\
//::  Written by: Haelix                                                    ::\\
//::  For use with SpitNyerEye's OnPC Death and Respawn System              ::\\
//::////////////////////////////////////////////////////////////////////////::\\
/*
This script goes in the "pccorpse" on used event
*/
void main()
  {
   object oPC = GetLastUsedBy() ; // Sets the object oPC as the PC who just used the "corpse"
   string sOwner = GetLocalString(OBJECT_SELF, "sOwner") ; //  Recalls the local string set during the PC OnPlayerDeath event
   string sPC = GetPCPlayerName(oPC) ; // Gets oPC's name
      if (sPC==sOwner) // If oPC is has the same name as the corpse
        {
         ActionStartConversation(oPC, "pccorpse_conv", TRUE) ; // then the conversation which allows the PC to loot it starts
        }
      else // if not
        {
         AssignCommand(oPC, ActionSpeakString("This is not my gear.")) ; // then the corpse floats this text
        }
}

