void main()
{
    DelayCommand(15.0, ActionCloseDoor(OBJECT_SELF));
    if(GetLockKeyTag(OBJECT_SELF) != "")
        SetLocked(OBJECT_SELF,TRUE);

    return;
}

