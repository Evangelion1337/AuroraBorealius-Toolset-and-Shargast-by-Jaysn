//::///////////////////////////////////////////////
//:: ZEP_TORCHUPDATE.nss
//:: Created by by Dan Heidel 1/21/04 for CEP
//:://////////////////////////////////////////////
/*
    This function is used to update the light effect that is placed on a
    light-emitting placeable.  Note, this function does not actually change the
    CEP_L_LIGHTCONST localstring that determines the color of the lighting
    effect - you haveto writea function to do this yourself.  However, if the
    value of CEP_L_LIGHTCONST is changed, there will be no update until the next
    time the placeable switches on or off unless this function is called.
*/

#include "zep_inc_main"

void main()
{
    int nAmIOn = GetLocalInt(OBJECT_SELF, "CEP_L_AMION");
    int nLightCycle = GetLocalInt(OBJECT_SELF, "CEP_L_LIGHTCYCLE");
    string sLightConst = GetLocalString(OBJECT_SELF, "CEP_L_LIGHTCONST");
    string sLightSwap = GetLocalString(OBJECT_SELF, "CEP_L_LIGHTSWAP");
    int nLight = ColorInit(sLightConst);
    if (nAmIOn == 1)
    {
        object oSelf = OBJECT_SELF;
        effect eEffect = GetFirstEffect(oSelf);
        while (GetIsEffectValid(eEffect) == TRUE)
        {
            if (GetEffectType(eEffect) == EFFECT_TYPE_VISUALEFFECT)
                RemoveEffect(oSelf, eEffect);
            eEffect = GetNextEffect(oSelf);
        }
        effect eLight = EffectVisualEffect(nLight);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLight, oSelf);
    }
    else
    {
        object oSelf = OBJECT_SELF;
        PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE);
        effect eEffect = GetFirstEffect(oSelf);
        while (GetIsEffectValid(eEffect) == TRUE)
        {
            if (GetEffectType(eEffect) == EFFECT_TYPE_VISUALEFFECT)
                RemoveEffect(oSelf, eEffect);
        }
    }

}


