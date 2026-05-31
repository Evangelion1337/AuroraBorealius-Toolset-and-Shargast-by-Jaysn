// Declarations
// StaticSpawn - Summon the monster with the given tag at the given spot.
// Set the local variable ms_info to the given value
void StaticSpawn(string szClass, location lWhere, string info);
// The main event handler.
void main()
{
// VARIABLES
// The Spawnmaster object
SpeakString("Isengard is under attack! Rally Servants of Sauron to Isengard!", TALKVOLUME_SHOUT);
object oSpawnMaster;
// The tag for this monster
string szMonsterTag = GetTag(OBJECT_SELF);
int nLength = 0;
string szSpawnPointTag = "";
string szSpawnPointInfo;
string szMonsterClass;
object oSpawnPoint;
float fSpawnTime;
location lSpawnPoint;
// Check to see if we are an "ms_" monster
if( GetSubString(szMonsterTag, 0, 3) == "ms_" ) {
nLength = GetStringLength(szMonsterTag);
// Get the Spawn Point for this monster
szSpawnPointTag = GetSubString(szMonsterTag, 3, (nLength - 3));
} else {
// Check to see if we have an ms_info local variable
szSpawnPointTag = GetLocalString(OBJECT_SELF, "ms_info");
}
// If this creature has a spawn point...
if(szSpawnPointTag != "") {
// ActionSpeakString("I was a MSMonster with SpawnPointTag " + szSpawnPointTag, TALKVOLUME_SHOUT);
// Get the waypoint and info
oSpawnPoint = GetWaypointByTag(szSpawnPointTag);
szSpawnPointInfo = GetName(oSpawnPoint);
// ActionSpeakString("SpawnpointInfo is "+szSpawnPointInfo, TALKVOLUME_SHOUT);
nLength = GetStringLength(szSpawnPointInfo);
// Spawn time is the first 3 characters
fSpawnTime = StringToFloat( GetSubString(szSpawnPointInfo, 0, 3) + ".0" );
// Monster class to spawn is the 4th char onward
szMonsterClass = GetSubString(szSpawnPointInfo, 4, (nLength - 4));
// Location to spawn is the loc. of the spawnpoint...
lSpawnPoint = GetLocation(oSpawnPoint);
// Get the spawn master
oSpawnMaster = GetObjectByTag("spawnmaster");
// Dispatch the command to the spawn master.
AssignCommand(
oSpawnMaster,
DelayCommand(fSpawnTime, StaticSpawn(szMonsterClass, lSpawnPoint, szSpawnPointTag))
);
}
}
// SummonMonster
// Conjure a monster with the given class at the given point.
void StaticSpawn(string szClass, location lWhere, string info) {
object oNewMonster = CreateObject(OBJECT_TYPE_CREATURE, szClass, lWhere);
SetLocalString(oNewMonster, "ms_info", info);
}



