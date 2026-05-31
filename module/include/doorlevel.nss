//:://////////////////////////////////////////////
/*
    Magic locked cemetary gate with effects
*/
//:://////////////////////////////////////////////
//:: Created By: Michael "Huntsman" Paddon
//:: Creator of Grail War - The Beginning module
//:: Created On: 11th August 2002
//:://////////////////////////////////////////////
/*
for this to work you need a waypoint with the tag WP_FALLDOWN set at the point
where you want the PC to be thrown to before they fall down.
This script should be place on the FAIL TO OPEN of the gate or door you use it on.
Make sure the gate is locked and needs key to open, and the plot box is checked.
*/

void main()
{
object oPC = GetClickingObject();
location lWay = GetLocation(GetObjectByTag("WP_FALLDOWN"));
int iLevel = GetHitDice(oPC);
effect eKnock = EffectKnockdown();

//Check if it is PC, and level is 6 or better to open gate
if (GetIsPC(oPC) && (iLevel <= 5))
{
//Speak text above gate, and effects for spell, and knocking PC down.
SpeakString("You feel the magic holding the gate fast is to strong for you currently and you're thrown away harshly to the ground");
ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_FNF_SCREEN_SHAKE),OBJECT_SELF, 1.0);
DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_FNF_WAIL_O_BANSHEES),OBJECT_SELF, 1.0));
DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_EVIL),OBJECT_SELF, 1.0));
DelayCommand(1.5, AssignCommand(oPC, ActionForceMoveToLocation(lWay, TRUE)));

 ActionDoCommand(ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnock, oPC, 8.0f));
 }
      else
      {
      SpeakString("You feel the magic holding the gate fast buckle and break under the force of your will, and the gate swings open");
      SetLocked(OBJECT_SELF, FALSE);
      ActionOpenDoor(OBJECT_SELF);
      }
   }
