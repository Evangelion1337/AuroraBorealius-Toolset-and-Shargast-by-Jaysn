// -----------------------------------------------
// : File Door_closeanlck
// : Created 01 JUL 02 11:48 AM
// : Created by Darryl Sandell
// closes open door after set time
// and locks door.
// -----------------------------------------------
void main()
{
DelayCommand(5.0, ActionCloseDoor(OBJECT_SELF));
SetLocked(OBJECT_SELF, 1);
}

