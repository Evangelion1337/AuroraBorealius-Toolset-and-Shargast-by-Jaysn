//:://////////////////////////////////////////////////
//:: X0_D1_HEN_QUITS
//:: Copyright (c) 2002 Floodgate Entertainment
//:://////////////////////////////////////////////////
/*
The henchman's been pissed off so badly s/he's going
to quit working for this player and go back to his/her
waypoint.
 */
//:://////////////////////////////////////////////////
//:: Created By: Naomi Novik
//:: Created On: 09/13/2002
//:://////////////////////////////////////////////////

#include "x0_i0_henchman"

void main()
{
    QuitHenchman(GetPCSpeaker());
}
