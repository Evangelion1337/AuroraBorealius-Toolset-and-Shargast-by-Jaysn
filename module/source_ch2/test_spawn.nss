#include "NW_O2_CONINCLUDE"
#include "NW_I0_GENERIC"

void main()
{
     SetSpawnInCondition(NW_FLAG_DAY_NIGHT_POSTING);
     SetSpawnInCondition(NW_FLAG_APPEAR_SPAWN_IN_ANIMATION);
     SetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS);
     SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS);
    SetListeningPatterns();    // Goes through and sets up which shouts the NPC will listen to.

}
