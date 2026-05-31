///////////////////////////////////////////////////
// Beholder Ray: On exit                         //
///////////////////////////////////////////////////
/*
    Removes the silence effect caused by the
    beholder's central eye ray.
*/
///////////////////////////////////////////////////
// Created By: Zarathustra217                    //
// Created On: Okt 7. 2002                       //
///////////////////////////////////////////////////
#include "NW_I0_SPELLS"

void main()
{
    object oTarget = GetExitingObject();
    int bValid = FALSE;
    effect eAOE;
    eAOE = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eAOE) && bValid == FALSE)
    {
        //Debug String
        //AssignCommand(oTarget, SpeakString("Effect is valid"));
        if (GetEffectCreator(eAOE) == GetAreaOfEffectCreator())
        {
            //Debug String
            //AssignCommand(oTarget, SpeakString("Effect creator is true"));
            if(GetEffectType(eAOE) == EFFECT_TYPE_SILENCE)
            {
                //Debug String
                //AssignCommand(oTarget, SpeakString("Effect type is silence"));
                //AssignCommand(oTarget, SpeakString("Removing effects"));
                RemoveEffect(oTarget, eAOE);
                bValid = TRUE;
            }
        }
        eAOE = GetNextEffect(oTarget);
    }
}
