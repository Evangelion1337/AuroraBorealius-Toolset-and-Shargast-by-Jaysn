//::///////////////////////////////////////////////
//:: commoner_resume
//:://////////////////////////////////////////////
/*
     Sends commoner to its destination waypoint after
     speaking its one liner.
*/
//:://////////////////////////////////////////////
//:: Created By: EntropyDecay
//:: Created On: May 2003
//:://////////////////////////////////////////////

void main()
{
  object oArea = GetArea(OBJECT_SELF);
  int nWalkType = GetLocalInt(oArea, "nWalkType");

  AssignCommand(OBJECT_SELF, DelayCommand(0.1,ClearAllActions()));
  AssignCommand(OBJECT_SELF, DelayCommand(0.1,
      ActionForceMoveToObject(
          GetLocalObject(OBJECT_SELF, "oWalkTarget"),
          nWalkType, 0.4, 60.0)));
  AssignCommand(OBJECT_SELF,
      DelayCommand(0.1,
          ActionDoCommand(DestroyObject(OBJECT_SELF, 0.1))));
}
