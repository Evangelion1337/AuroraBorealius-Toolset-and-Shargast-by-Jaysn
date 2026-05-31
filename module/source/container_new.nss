void CreateThing(string sTemplate, int type, location locHere)
{
     CreateObject(type, sTemplate, locHere);
}

void main()
{
    string tag;
    location loc;
    int what=GetObjectType(OBJECT_SELF);

    tag=GetTag(OBJECT_SELF);
    loc=GetLocation(OBJECT_SELF);
    AssignCommand(GetArea(OBJECT_SELF), DelayCommand(20.0,CreateThing(tag,what,loc)));
}

