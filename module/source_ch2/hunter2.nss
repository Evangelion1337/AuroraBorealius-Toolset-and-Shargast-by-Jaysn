// notifies a monster tagged "HUNTER" that a PC has entered
// the area this script is attached to; also set a local variable
// that can be checked later to see if the PC went into an area
// to prevent an event from occuring again to the same PC
// (until another PC comes along and triggers this event that is).
// "HUNTER" can also use the object (oEntering) stored on the
// event to help track down the trespassing PC.
void main()
{
     object oEntering = GetEnteringObject();
     // make sure its a PC
     if (GetIsPC(oEntering))
     {
          // prevent "HUNTER" from coming again
          if (!(GetLocalObject(OBJECT_SELF, "PC_Entered") == oEntering))
          {
               object oMonster = GetObjectByTag("WalkingDead");
               // set a local variable on the Area
               SetLocalObject(OBJECT_SELF, "PC_Entered", oEntering);
               // tell "HUNTER" to come and eat
               SignalEvent(oMonster, EventUserDefined(100));
          }
object oPC = GetEnteringObject();

if (!GetIsPC(oPC)) return;

object oTarget;
oTarget = GetObjectByTag("as_cv_belltower1");

SoundObjectPlay(oTarget);

SoundObjectSetVolume(oTarget, 20);

oTarget = GetObjectByTag("WP_FLARE2");

//Visual effects can't be applied to waypoints, so if it is a WP
//the VFX will be applied to the WP's location instead

int nInt;
nInt = GetObjectType(oTarget);

if (nInt != OBJECT_TYPE_WAYPOINT) ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DOOM), oTarget);
else ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DOOM), GetLocation(oTarget));

if (!GetIsPC(oPC)) return;

FloatingTextStringOnCreature("Wonder what the bell and smoke was for?", oPC);

}
   }
