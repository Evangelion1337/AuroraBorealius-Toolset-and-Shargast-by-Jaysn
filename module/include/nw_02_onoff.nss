//::///////////////////////////////////////////////
//:: NW_O2_ONOFF.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Turns the placeable object's animation on/off
*/
//:://////////////////////////////////////////////
//:: Created By:  Brent
//:: Created On:  January 2002
//:://////////////////////////////////////////////


void main()
{
    if (GetLocalInt(OBJECT_SELF,"NW_L_AMION") == 0)
    {
        PlayAnimation(ANIMATION_PLACEABLE_ACTIVATE);
        DelayCommand(0.4,SetPlaceableIllumination(OBJECT_SELF, TRUE));
        SetLocalInt(OBJECT_SELF,"NW_L_AMION",1);
        DelayCommand(0.5,RecomputeStaticLighting(GetArea(OBJECT_SELF)));
    }
    else
    {
        PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE);
        DelayCommand(0.4,SetPlaceableIllumination(OBJECT_SELF, FALSE));
        SetLocalInt(OBJECT_SELF,"NW_L_AMION",0);
        DelayCommand(0.9,RecomputeStaticLighting(GetArea(OBJECT_SELF)));
    }
}
