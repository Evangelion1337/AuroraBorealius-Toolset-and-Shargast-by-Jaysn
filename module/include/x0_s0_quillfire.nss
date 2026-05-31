//::///////////////////////////////////////////////
//:: Quillfire
//:: [x0_s0_quillfire.nss]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Fires a cluster of quills at a target. Ranged Attack.
    2d8 + 1 point /2 levels (max 5)

*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 17 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs May 02, 2003
/*
Patch 1.71

- poison made extraordinary
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
/*
  Spellcast Hook Code
  Added 2003-06-20 by Georg
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more

*/

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

// End of Spell Cast Hook

    //Declare major variables  ( fDist / (3.0f * log( fDist ) + 2.0f) )
    spellsDeclareMajorVariables();
    int nCasterLvl = spell.Level;
    int nDamage = 0;
    int nCnt;
    effect eVis = EffectVisualEffect(VFX_IMP_ACID_S);

    if(spellsIsTarget(spell.Target, SPELL_TARGET_SINGLETARGET, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Apply a single damage hit for each missile instead of as a single mass
        //Make SR Check
//        {
            // BK: No spell resistance for quillfire
            //if(!MyResistSpell(OBJECT_SELF, oTarget, fDelay))
//            {
                //eMissile = EffectVisualEffect(VFX_IMP_MIRV_FLAME);
                //* apply bonus damage for level
                int nBonus = spell.Level / 2;
                if (nBonus > 5)
                {
                    nBonus = 5;
                }
                //Roll damage
                int nDam = MaximizeOrEmpower(8,1,spell.Meta,nBonus);
                effect eDam = EffectDamage(nDam, DAMAGE_TYPE_MAGICAL);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spell.Target);
                // * also applies poison damage
                effect ePoison = EffectPoison(POISON_LARGE_SCORPION_VENOM);
                ePoison = ExtraordinaryEffect(ePoison);
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePoison, spell.Target);

                //Apply the MIRV and damage effect
                //ApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, oTarget);
//            }
//      }
    }
}
