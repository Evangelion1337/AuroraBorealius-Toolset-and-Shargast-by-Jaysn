void main()
{
object door;

DelayCommand(10.0,AssignCommand(OBJECT_SELF,ActionCloseDoor(OBJECT_SELF)));

DelayCommand (11.0, ActionDoCommand( SetLocked( door, TRUE )));
}

