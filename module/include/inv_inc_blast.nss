#include "prc_inc_clsfunc"
#include "prc_inc_sp_tch"

int GetBlastDamageDices(object oInvoker, int nInvokerLevel)
{
    int nDmgDice;
    if(nInvokerLevel < 13)
        nDmgDice = (nInvokerLevel + 1) / 2;
    else if(nInvokerLevel < 20)
        nDmgDice = (nInvokerLevel + 7) / 3;
    else
        nDmgDice = 9 + (nInvokerLevel - 20) / 2;

    //check for the epic feats
    if(GetHasFeat(FEAT_EPIC_ELDRITCH_BLAST_I, oInvoker))
    {
        int nFeatAmt = 0;
        int bDone = FALSE;
        while(!bDone)
        {   if(nFeatAmt >= 9)
                bDone = TRUE;
            else if(GetHasFeat(FEAT_EPIC_ELDRITCH_BLAST_II + nFeatAmt, oInvoker))
                nFeatAmt++;
            else
                bDone = TRUE;
        }
        nDmgDice += nFeatAmt;
    }

    return nDmgDice;
}

// Spellblast should use only AoE spells but Dispel Magic can be cast as AoE or single target
// we make sure here that we use AoE version
int CheckSpecialTarget(int nSpellID)
{
    return nSpellID == SPELL_DISPEL_MAGIC
         || nSpellID == SPELL_GREATER_DISPELLING
         || nSpellID == SPELL_LESSER_DISPEL
         || nSpellID == SPELL_MORDENKAINENS_DISJUNCTION
         || nSpellID == SPELL_POWER_WORD_KILL;
}

void DoSpellBlast(object oPC, int bHit)
{
    int nSpellbookID = GetLocalInt(oPC, "ET_SPELL_CURRENT");
//DoDebug("nSpellbookID = "+IntToString(nSpellbookID));
    if(nSpellbookID)
    {
        object oTarget = GetSpellTargetObject();
        if(GetIsObjectValid(oTarget))
        {
            nSpellbookID--;
            DeleteLocalInt(oPC, "ET_SPELL_CURRENT");
            int nSpellID = GetLocalInt(oPC, "ET_REAL_SPELL_CURRENT");
//DoDebug("nSpellID = "+IntToString(nSpellID));
            string sArray = GetLocalString(oPC, "ET_SPELL_CURRENT");
//DoDebug("sArray = "+sArray);
            int nUses = sArray == "" ? GetHasSpell(nSpellbookID, oPC) :
                        persistant_array_get_int(oPC, sArray, nSpellbookID);

            if(nUses)
            {
                // expend spell use
                if(sArray == "")
                {
                    DecrementRemainingSpellUses(oPC, nSpellID);
                }
                else
                {
                    nUses--;
                    persistant_array_set_int(oPC, sArray, nSpellbookID, nUses);
                }

                // use AoE Dispel Magic
                int bTargetOverride = CheckSpecialTarget(nSpellID);

                if(bHit)
                {
                    int nCastingClass = GetETArcaneClass(oPC);
                    int nDC = 10 + PRCGetSpellLevelForClass(nSpellID, nCastingClass) + GetDCAbilityModForClass(nCastingClass, oPC);
                    //clear action queue to apply spell effect right after blast effect
                    ClearAllActions();
                    //override PRCDoMeleeTouchAttack() - we already know that blast hit
                    ActionDoCommand(SetLocalInt(oPC, "AttackHasHit", bHit));
                    SetLocalInt(oPC, "EldritchSpellBlast", TRUE);
					if(DEBUG) DoDebug("inv_inc_blast >> EldritchSpellBlast Set");
                    ActionCastSpell(nSpellID, 0, nDC, 0, METAMAGIC_NONE, nCastingClass, FALSE, bTargetOverride);
                    ActionDoCommand(DeleteLocalInt(oPC, "AttackHasHit"));
                    DelayCommand(0.5, DeleteLocalInt(oPC, "EldritchSpellBlast"));
                }
            }
        }
    }
}

void ApplyBlastDamage(object oCaster, object oTarget, int iAttackRoll, int iSR, int iDamage, int iDamageType, int iDamageType2, int nHellFire, int bSneak = TRUE, int nMsg = FALSE)
{
	if (DEBUG) DoDebug("ApplyBlastDamage oCaster "+GetName(oCaster)+" oTarget "+GetName(oTarget)+" iAttackRoll "+IntToString(iAttackRoll)+" iSR "+IntToString(iSR)+" iDamage "+IntToString(iDamage)+" iDamageType "+IntToString(iDamageType)+" iDamageType2 "+IntToString(iDamageType2)+" nHellFire "+IntToString(nHellFire)+" bSneak "+IntToString(bSneak)+" nMsg "+IntToString(nMsg)); 

	// Is it a critical hit?
    iDamage *= iAttackRoll;
    if(iAttackRoll)
    {
        // Heal the Undead
        if (iDamageType == DAMAGE_TYPE_NEGATIVE && (MyPRCGetRacialType(oTarget) == RACIAL_TYPE_UNDEAD || GetLocalInt(oTarget, "AcererakHealing") || (GetHasFeat(FEAT_TOMB_TAINTED_SOUL, oTarget) && GetAlignmentGoodEvil(oTarget) != ALIGNMENT_GOOD)))
        {
            //Set the heal effect
            effect eHeal = EffectHeal(iDamage);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget);
        }
        else // Other targets
        {
            if(!GetPRCSwitch(PRC_SPELL_SNEAK_DISABLE) && bSneak)
                iDamage += SpellSneakAttackDamage(oCaster, oTarget);

            effect eDamage;
            if(!iSR)
            {
                if(iDamageType == iDamageType2)
                    eDamage = EffectDamage(iDamage, iDamageType);
                else
                {
                    eDamage = EffectDamage(iDamage / 2, iDamageType);
                    eDamage = EffectLinkEffects(eDamage, EffectDamage(iDamage / 2, iDamageType2));
                }
                if(nHellFire)
                    eDamage = EffectLinkEffects(eDamage, EffectDamage(d6(nHellFire), DAMAGE_TYPE_DIVINE));
            }
            else if(iDamageType == DAMAGE_TYPE_ACID || iDamageType2 == DAMAGE_TYPE_ACID)
            {
                 if(iDamageType == iDamageType2)
                    eDamage = EffectDamage(iDamage, iDamageType);
                 else
                    eDamage = EffectDamage(iDamage / 2, iDamageType);
            }

            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget);
        }        
    }
}

int HellFireConDamage(object oPC)
{
    if(GetIsImmune(oPC, IMMUNITY_TYPE_ABILITY_DECREASE))
    {
        if(DEBUG) DoDebug("HellFireConDamage: Immune to ability damage!");
        return FALSE;
    }

    ApplyAbilityDamage(oPC, ABILITY_CONSTITUTION, 1, DURATION_TYPE_TEMPORARY, TRUE, -1.0);
    return TRUE;
}

int GetIsHellFireBlast(object oPC)
{
    if(GetLocalInt(oPC, "INV_HELLFIRE"))
    {
        DeleteLocalInt(oPC, "INV_HELLFIRE");
        return TRUE;
    }
    return FALSE;
}
