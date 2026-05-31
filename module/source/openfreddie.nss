#include "nw_i0_plot"
void main()
{
    object oStore = GetNearestObjectByTag("X2_STOREWEAP003");
    if (GetObjectType(oStore) == OBJECT_TYPE_STORE)
    {

    }
    else
    {
        ActionSpeakStringByStrRef(53090, TALKVOLUME_TALK);
    }
}
