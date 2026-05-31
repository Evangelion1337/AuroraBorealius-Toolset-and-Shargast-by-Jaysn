#include "mk_inc_generic"
#include "mk_inc_body"

void MK_RemoveEffectsOfType(object oCreature, int nEffectType, int nEffectSubType=0);

void MK_ApplyEffect(object oCreature, int nEffect);

void MK_RemoveEffectsOfType(object oCreature, int nEffectType, int nEffectSubType)
{
    effect eEffect = GetFirstEffect(oCreature);
    while (GetIsEffectValid(eEffect))
    {
        if ( (                         GetEffectType   (eEffect) == nEffectType    ) &&
             ( (nEffectSubType==0) || (GetEffectSubType(eEffect) == nEffectSubType))    )
        {
            RemoveEffect(oCreature, eEffect);
        }
        eEffect = GetNextEffect(oCreature);
    }
}

void MK_ApplyEffect(object oCreature, int nEffect)
{
    if ((nEffect>0) && (GetIsObjectValid(oCreature)))
    {
        effect eEffect = SupernaturalEffect(EffectVisualEffect(nEffect));
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oCreature);
    }
}

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    int nAction = MK_GenericDialog_GetAction();

    string sColumn = MK_GetRacialTypeAsString(oPC)+"_"+MK_GetGenderAsString(oPC);

    string sVFX2DA = "mk_vfx";

    if ((nAction>=1) && (nAction<=20))
    {
        int nEffect = StringToInt(Get2DAString(sVFX2DA, sColumn, nAction));
        MK_ApplyEffect(oPC, nEffect);
    }
    else if (nAction==21)
    {
        MK_RemoveEffectsOfType(oPC, EFFECT_TYPE_VISUALEFFECT, SUBTYPE_SUPERNATURAL);
    }

    int iRow=0;
    string sVFXName;
    string sEffect;
    int iCount=0;
    for (iRow=1; iRow<=10; iRow++)
    {
        sVFXName = Get2DAString(sVFX2DA, "Name", iRow);
        sEffect = Get2DAString(sVFX2DA, sColumn, iRow);

        if ((sVFXName=="") && (sEffect!=""))
        {
            iCount++;
            sVFXName = "Effect "+sEffect;
        }

        MK_GenericDialog_SetCondition(iRow, sEffect!="");
        SetCustomToken(14440+iRow,sVFXName);
    }
    if (iCount==0)
    {
        SendMessageToPC(oPC, "It seems there is no column '"+sColumn+"' in '"+sVFX2DA+".2da'.");
    }

    return TRUE;
}
