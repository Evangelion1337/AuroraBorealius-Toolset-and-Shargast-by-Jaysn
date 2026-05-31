//::///////////////////////////////////////////////
//:: Spell Include: Transposition
//:: spinc_trans
//::///////////////////////////////////////////////
/** @file
    Common code for Benign Transposition and
    Baleful Transposition.
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

#include "prc_inc_spells"
#include "prc_inc_teleport"
#include "prc_add_spell_dc"
/////////////////////////
// Function Prototypes //
/////////////////////////

/**
 * Changes the positions of current spellcaster and spell target.
 *
 * @param bAllowHostile If this flag is FALSE then the target creature
 *                      must be a member of the caster's party (have the same faction
 *                      leader). If this flag is false then it may be a party member
 *                      or a hostile creature.
 * @param bRunSpellhook By default, this is TRUE and the function runs the spellhook.
 *                      But in some cases, such as feats or psionic powers, the script
 *                      calling this function may need to handle the matter differently.
 *                      In such cases, set this to FALSE, which will cause the spellhook
 *                      not to be run from this function.
 */
void DoTransposition(int bAllowHostile, int bRunSpellhook = TRUE);


//////////////////////////
// Function Definitions //
//////////////////////////

//
// Displays transposition VFX.
//
void TransposeVFX(object o1, object o2)
{
    // Apply vfx to the creatures moving.
    effect eVis = EffectVisualEffect(VFX_IMP_HEALING_X);
    SPApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, o1);
    SPApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, o2);
}

//
// Transposes the 2 creatures.
//
void Transpose(object o1, object o2)
{
    // Get the locations of the 2 creatures to swap, keeping the facings
    // the same.
    location loc1 = Location(GetArea(o1), GetPosition(o1), GetFacing(o2));
    location loc2 = Location(GetArea(o2), GetPosition(o2), GetFacing(o1));

    // Make sure both creatures are capable of being teleported
    if(!(GetCanTeleport(o1, loc2, TRUE) && GetCanTeleport(o2, loc1, TRUE)))
        return;

    // Swap the creatures.
    AssignCommand(o2, JumpToLocation(loc1));
    DelayCommand(0.1, AssignCommand(o2, ClearAllActions(TRUE)));
    AssignCommand(o1, JumpToLocation(loc2));
    DelayCommand(0.1, AssignCommand(o1, ClearAllActions(TRUE)));

    DelayCommand(0.1, TransposeVFX(o1, o2));
}


void DoTransposition(int bAllowHostile, int bRunSpellhook = TRUE)
{
    PRCSetSchool(SPELL_SCHOOL_CONJURATION);
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if(bRunSpellhook)
        if(!X2PreSpellCastCode()) return;

    object oCaster = OBJECT_SELF;
    object oTarget = PRCGetSpellTargetObject();
    if (!GetIsDead(oTarget))
    {
        // Get the spell target.  If he has the same faction leader we do (i.e. he's in the party)
        // or he's a hostile target and hostiles are allowed then we will do the switch.
        int bParty = GetFactionLeader(oTarget) == GetFactionLeader(oCaster);
        if(bParty || (bAllowHostile && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)))
        {
            // Targets outside the party get a will save and SR to resist.
            if (bParty ||
                (!PRCDoResistSpell(oCaster, oTarget) && !PRCMySavingThrow(SAVING_THROW_WILL, oTarget, PRCGetSaveDC(oTarget, oCaster))))
            {
                //Fire cast spell at event for the specified target
                PRCSignalSpellEvent(oTarget, !bParty);

                // Move the creatures.
                DelayCommand(0.1, Transpose(oCaster, oTarget));
            }
        }
    }

    PRCSetSchool();
}
