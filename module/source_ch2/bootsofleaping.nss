/*Based on Fly to Location script

   by Gaia_Werewolf//edited by ffbj

   This script is used on an item with the "Unique Item" spell property. */
#include "x2_inc_switches"

void main()
{

 int nEvent =GetUserDefinedItemEventNumber();
     if (!nEvent == X2_ITEM_EVENT_ACTIVATE)
     return;
// Check if item target is valid.
    object oPC;
    oPC = GetItemActivator();
    object oArea;
    oArea = GetArea(oPC);
     if(GetLocalInt(oPC, "Mounted") == 1)
          {
       SendMessageToPC(oPC, "You must Dismount to use this item.");
       return;
          }

       {
     if (GetIsObjectValid(GetItemActivatedTarget()))
     return;

      if(GetLocalInt(oArea, "NO_ITEM_USE") == 1)

        {
       SendMessageToPC(oPC, "This item is not usuable here.");
       return;
        }

effect eFly;
location nDestination;

nDestination = GetItemActivatedTargetLocation();
eFly = EffectDisappearAppear(nDestination);

    // Cutscene effects! Totally unnecessary, but eh.
DelayCommand(2.0, FadeToBlack(oPC, FADE_SPEED_FASTEST));
DelayCommand(4.5, FadeFromBlack(oPC, FADE_SPEED_FASTEST));

    // Duration MUST be 3.0 or higher. Higher for busy areas.
 ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFly, oPC, 3.5);
  }


}
