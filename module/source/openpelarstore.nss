//::///////////////////////////////////////////////
//:: FileName at_055
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 10/24/2002 4:05:39 PM
//:://////////////////////////////////////////////
void main()
{

// Either open the store with that tag or let the user know that no store exists.
object oStore = GetNearestObjectByTag("PELARGIRARMOURY");
if(GetObjectType(oStore) == OBJECT_TYPE_STORE)
OpenStore(oStore, GetPCSpeaker());
else
ActionSpeakStringByStrRef(53090, TALKVOLUME_TALK);
}

