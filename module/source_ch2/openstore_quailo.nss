#include "nw_i0_plot"
void main()
{
    object oStore = GetNearestObjectByTag("x2_genie_store");
    if (GetObjectType(oStore) == OBJECT_TYPE_STORE)
    {

    }
    else
    {
        ActionSpeakStringByStrRef(53090, TALKVOLUME_TALK);
    }
}
