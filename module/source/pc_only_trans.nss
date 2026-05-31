//  OnAreaTransitionClick(Door Transition)/OnClick(Transition Trigger) script ...
#include "x0_i0_transport"
void main()
{
    object oClicker = GetClickingObject();
    AssignCommand(oClicker, ClearAllActions(TRUE));
    if(GetIsPC(oClicker))
        //  Transport oClicker and Associates ...
        TransportToLocation(oClicker, GetLocation(GetTransitionTarget(OBJECT_SELF)));
        //  Transport ALL of oClicker's Party Members, including PCs and their Associates ...
        //TransportAllToLocation(oClicker, GetLocation(GetTransitionTarget(OBJECT_SELF)));
    else
    {
        //  Define some unique object as the Jump destination ...
        object oDestination = GetObjectByTag("Unique_Tag_of_Object");
        AssignCommand(oClicker, JumpToObject(oDestination));
    }
}

