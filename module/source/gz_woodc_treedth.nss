void RegrowTree(location lLoc)
{
     CreateObject(OBJECT_TYPE_PLACEABLE,"gz_obj_tree_mark",lLoc,TRUE);
}

void main()
{
    location lLoc = GetLocation(OBJECT_SELF);
    AssignCommand(GetNearestObjectByTag(GetTag(OBJECT_SELF)),DelayCommand(150.0f,RegrowTree(lLoc)));
    SetLocalInt(GetLastKiller(),"T1_NPC_KILLEDLASTREE",TRUE);
}
