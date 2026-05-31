void main()
{
string sResref="dereg"; // resref of those little monsters
location lLocation=GetLocation(OBJECT_SELF); // or another place you want to spawn them
CreateObject(OBJECT_TYPE_CREATURE,sResref,lLocation);
}

