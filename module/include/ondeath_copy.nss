//On Damage Copy
//Basic utilitarian script that copies an object
//Put this in a dummy's ondeath event to have a new one created in the dummy's demise
void main()
{
    object oSelf = OBJECT_SELF; //The caller, a dummy
    string sResref = GetResRef(oSelf); //The caller's resref, a unique identifier
    location lSelf = GetLocation(oSelf); //The caller's location, when called
    int iType = GetObjectType(oSelf); //The caller's object type, such as OBJECT_TYPE_PLACEABLE
    CreateObject(iType, sResref, lSelf, FALSE); //Create an Object as per the above qualities at the location, ie a copy
}
