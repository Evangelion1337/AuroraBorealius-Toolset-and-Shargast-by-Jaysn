void RespawnObject(string sResRef, int iType, location lLoc) {
CreateObject(iType, sResRef, lLoc);
}
void main()
{
string sResRef = GetResRef(OBJECT_SELF);
int iType = GetObjectType(OBJECT_SELF);
// For creatures, save the location at spawn-time as a local location and
// use it instead. Otherwise, the creature will respawn where it died.
// No changes are required for placeables as they do not move (usually ;-)
location lLoc =GetLocation(GetWaypointByTag("WAYPOINT TAG GOES HERE"));
float fDelay = 240.0;  // 5 minute delay; adjust as desired
AssignCommand(GetModule(), DelayCommand(fDelay, RespawnObject(sResRef, iType, lLoc)));
}

