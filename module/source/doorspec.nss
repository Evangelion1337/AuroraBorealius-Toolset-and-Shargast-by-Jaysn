//::///////////////////////////////
//::
//::
//::*******************************
//:: Jade Golem Module Core V1.0
//:: Created By: DigitalKnightmare
//:: Copyright (c) Fuck Copyright
//::*******************************
//::
//:: IT_DOOR - LOTS OF DOOR STUFF 1 SCRIPT
//:: PLACE 001-005 in the front of your door
//:: name and place this script on the OnUsed script slot
//::///////////////////////////////
void main()
{
string sStringValue = GetStringLeft(GetName(OBJECT_SELF),3);
object oDoor = GetNearestObject(OBJECT_TYPE_DOOR);
int iNight = GetIsNight();
int iDoorLocked = GetLocked(oDoor);
int iStringValue = StringToInt(sStringValue);

switch(iStringValue)
{
case 001: ///ClOSE DOOR
DelayCommand(10.0, ActionCloseDoor(OBJECT_SELF));
break;


case 002: ///ClOSE DOOR & LOCK
DelayCommand(20.0, ActionCloseDoor(OBJECT_SELF));
SetLocked(OBJECT_SELF, TRUE);
break;


case 003: ///LEVER DOOR - JUST OPEN DOOR
ActionPlayAnimation(ANIMATION_PLACEABLE_ACTIVATE);
AssignCommand(oDoor, ActionOpenDoor(oDoor));
SetLocked(oDoor, FALSE);
break;


case 004: ///LEVER DOOR - OPEN AND RELOCK DOOR
ActionPlayAnimation(ANIMATION_PLACEABLE_ACTIVATE);
if (iDoorLocked == TRUE)
{
AssignCommand(oDoor, ActionOpenDoor(oDoor));
SetLocked(oDoor, FALSE);
}
else
{
AssignCommand(oDoor, ActionCloseDoor(oDoor));
SetLocked(oDoor, TRUE);
break;

case 005: ///TIME DOOR - OPEN DURING DAY CLOSE DURING NIGHT
if (iNight == TRUE)
{
ActionCloseDoor(OBJECT_SELF);
SetLocked(OBJECT_SELF, TRUE);
ActionSpeakString("CLOSED FOR THE NIGHT!",TALKVOLUME_TALK);
}
else
DelayCommand(10.0, ActionCloseDoor(OBJECT_SELF));
break;


}
}
}
