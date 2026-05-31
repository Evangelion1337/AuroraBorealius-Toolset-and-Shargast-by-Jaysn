//::///////////////////////////////////////////////
//:: ZEP_TORCHES_OFF.nss
//:: Copyright (c) 2001 Bioware Corp.
//:: Modified by Dan Heidel 2/06/04 for CEP
//:://////////////////////////////////////////////
/*
    This is a quick function I threw together that will turn all of the light-emitter
    placeables in an area off.  There are probably more elegant ways to do this but
    I was tired. ;)
    The whole thing with getting two objects and checking them against each other
    came from an odd bug when the zep_torch routine used to call a delay before
    destroying the old placeable - this would result in a game crash when this script
    was called.  I've since removed that delay but left the error-checking routine
    in just in case.

*/
void main()
{
object oArea = GetArea(GetFirstPC());
object oFoo = GetFirstObjectInArea(oArea);
object oFoo2;
int nFoo = 1;
while (oFoo != OBJECT_INVALID){
    nFoo++;
    if(oFoo == oFoo2) oFoo = GetNextObjectInArea(oArea);
    if(GetLocalInt(oFoo, "CEP_L_LIGHTINITIALIZED") == 1) {
        if(GetLocalInt(oFoo, "CEP_L_AMION") == 1)ExecuteScript("zep_torch", oFoo);
        SendMessageToPC(GetFirstPC(), GetTag(oFoo));
    }
    oFoo2 = oFoo;
    oFoo = GetNextObjectInArea(oArea);
    if(nFoo>200) return;
}
}
