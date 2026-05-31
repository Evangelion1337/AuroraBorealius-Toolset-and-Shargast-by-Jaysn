void main()
{
 object oDoor = GetObjectByTag("orcdoor_001");
 int nMyStat = GetLocalInt(OBJECT_SELF,"sLeverStateStored");
 if(nMyStat == 0)
  {
   ActionPlayAnimation(ANIMATION_PLACEABLE_ACTIVATE);
   SetLocalInt(OBJECT_SELF,"sLeverStateStored",1);
   ActionUnlockObject(oDoor);
   ActionOpenDoor(oDoor);
  }
 else
  {
   ActionPlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE);
   SetLocalInt(OBJECT_SELF,"sLeverStateStored",0);
   ActionCloseDoor(oDoor);
  }
}
