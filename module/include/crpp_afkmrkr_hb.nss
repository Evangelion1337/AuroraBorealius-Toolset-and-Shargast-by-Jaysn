// LOK AFK Marker Heartbeat.
// Checks each HB to see if the player has moved.
// You can adjust the range as its possible for the player to move
// without her own actions causing because of the way people get
// shoved around by others.
// Set the Reflex Value to some number other than 1 to have a distance
// the PC can move around before the VFX is taken away.

void main()
{
object oPC = GetLocalObject(OBJECT_SELF,"PC"); // Get the stored PC
object oWidget = GetLocalObject(OBJECT_SELF,"Widget"); // Get the stored Widget
location lMyLocation = GetLocation(OBJECT_SELF);  // Where am I?
location lMastersLoc = GetLocation(oPC);  // Where's the PC
float fMaxRange = IntToFloat(GetReflexSavingThrow(OBJECT_SELF)); // How far can we move before this triggers?
float fDistanceBetween = GetDistanceBetween(OBJECT_SELF,oPC); // How far apart are we?
//SpeakString("Distance is currently "+FloatToString(fDistanceBetween)); //Debug code
if (d8()==5) FloatingTextStringOnCreature("I am currently AFK",oPC); // Randomly restate our AFK'ness
if (fDistanceBetween>fMaxRange)  // Have we moved too far?
{
    effect eLOKAFK; // Declare our effects and objects in here to save overhead if we don't make it here.
    effect eTest;
    eTest = GetFirstEffect(oPC);  // Cycle through the effects on the PC
    while (GetIsEffectValid(eTest))
    {
      if (GetEffectCreator( eTest) == oWidget) // If we find one cast by the Widget
      {
        RemoveEffect(oPC, eTest);              // Then we get rid of it.
      }
      eTest = GetNextEffect(oPC);
    }
    SetLocalInt(oPC,"IsAFK",FALSE); // Set the PC as not having the VFX
    DelayCommand(3.0,DestroyObject(OBJECT_SELF)); // Get rid of ourselves with a slight delay to make sure everything finished up.
    FloatingTextStringOnCreature("I am back from AFK!",oPC); // Let everyone know we're back.
}
}
