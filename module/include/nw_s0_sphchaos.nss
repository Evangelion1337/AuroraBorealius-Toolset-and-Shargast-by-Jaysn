//::///////////////////////////////////////////////
//:: Sphere of Chaos
//:: NW_S0_SphChaos.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This applies random effects to everyone in the
    AOE depending on the level of the caster.  Enemies
    get negative effects and allies get positive
    effects.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 9, 2001
//:://////////////////////////////////////////////

void main()
{
    //Declare major variables
    object oTarget;
    int nRoll, nVis, bValid;
    int nDuration = 5;
    effect eVis;
    effect eChaos;
    //Get first target in the spell area
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetSpellTargetLocation(), TRUE);
    while (GetIsObjectValid(oTarget))
    {
        bValid = FALSE;
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_SPHERE_OF_CHAOS));
        //Roll for the power level of the effect to be applied
        nRoll = d20() + GetCasterLevel(OBJECT_SELF);
        //Make a faction check to see if the target is friend or foe
        if(GetIsFriend(oTarget))
        {
            //Set the effect based on the roll
            if(nRoll <= 14)
            {
                eChaos = EffectDamageBonus(4, DAMAGE_TYPE_MAGICAL);
            }
            else if(nRoll > 15 && nRoll <= 18)
            {
                eChaos = EffectSavingThrow(SAVING_THROW_ALL, 3);
            }
            else if(nRoll > 18 && nRoll <= 21)
            {
                eChaos = EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS);
            }
            else if(nRoll > 21 && nRoll <= 24)
            {
                eChaos = EffectSpellResistance(10);
            }
            else if(nRoll > 24 && nRoll <= 27)
            {
                eChaos = EffectAttackBonus(3);
            }
            else if(nRoll > 27 && nRoll <= 31)
            {
                eChaos = EffectHaste();
            }
            else if(nRoll > 31 && nRoll <= 35)
            {
                eChaos = EffectDamageReduction(10, 2);
            }
            else
            {
                eChaos =  EffectRegenerate(5, 1.0);
            }
            //Set effect type and VFX impact
            bValid = TRUE;
            nVis = VFX_IMP_MAGIC_PROTECTION;
        }
        else
        {
            //Make SR check
            if(!ResistSpell(OBJECT_SELF, oTarget))
            {
                //Make Will Save
                if(!WillSave(oTarget, GetSpellSaveDC()))
                {
                    //Set the effect based on the roll
                    if(nRoll <= 14)
                    {
                        eChaos = EffectDazed();
                    }
                    else if(nRoll > 15 && nRoll <= 18)
                    {
                        eChaos = EffectSavingThrow(SAVING_THROW_ALL, 3);
                    }
                    else if(nRoll > 18 && nRoll <= 21)
                    {
                        eChaos = EffectBlind();
                    }
                    else if(nRoll > 21 && nRoll <= 24)
                    {
                        eChaos = EffectConfused();
                    }
                    else if(nRoll > 24 && nRoll <= 27)
                    {
                        eChaos = EffectFrightened();
                    }
                    else if(nRoll > 27 && nRoll <= 31)
                    {
                        eChaos = EffectStunned();
                    }
                    else if(nRoll > 31 && nRoll <= 35)
                    {
                        eChaos = EffectParalyze();
                    }
                    else
                    {
                        eChaos = EffectDeath();
                    }
                    //Set effect type and VFX impact
                    nVis = VFX_IMP_CONFUSION_S;
                    bValid = TRUE;
                    SpeakString(IntToString(nRoll));
                }
            }
        }
        if(bValid == TRUE)
        {
            //Set Visual and Apply effects
            eVis = EffectVisualEffect(nVis);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eChaos, oTarget, RoundsToSeconds(5));
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetSpellTargetLocation(), TRUE);
    }
}

