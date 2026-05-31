//::///////////////////////////////////////////////
//:: Actions include
//:: prc_inc_actions
//::///////////////////////////////////////////////
/** @file
    Defines functions related to use of actions.

    @author Ornedan
    @date   Created - 2006.01.26
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

/// A marker local the presence of which indicates that a creature's
/// available swift action has been used for a particular round
const string PRC_SWIFT_ACTION_MARKER = "PRC_SwiftActionUsed";

/// A marker local the presence of which indicates that a creature's
/// available move action has been used for a particular round
const string PRC_MOVE_ACTION_MARKER = "PRC_MoveActionUsed";


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Determines whether the given creature can use a swift action at this moment
 * and if it can, marks that action as used.
 * Conditions are that it has not used a swift action already in the last
 * 6 seconds, and that that GetCanTakeFreeAction() returns TRUE.
 * In addition, if a PC, it must be commandable by the player. This is in order
 * to prevent abuse of instant action feats.
 *
 * @param oCreature Creature whose eligibility to use a swift action to test.
 * @return          TRUE if the creature can take a swift action now, FALSE otherwise.
 */
int TakeSwiftAction(object oCreature);

/**
 * Determines whether the given creature can use a free action at this moment.
 * Condition is that it is not affected by a condition that would prevent
 * action queue processing.
 * If the bTestControllability is set to true, this will also test for
 * conditions that would prevent control by the player.
 *
 * @param oCreature            Creature whose eligibility to use a free action to test.
 * @param bTestControllability Whether to test for controllability affecting conditions.
 * @return                     TRUE if the creature can take a free action now, FALSE otherwise.
 */
int GetCanTakeFreeAction(object oCreature, int bTestControllability = FALSE);

/**
 * Determines whether the given creature can use a move action at this moment
 * and if it can, marks that action as used.
 * Conditions are that it has not used a move action already in the last
 * 6 seconds
 * In addition, if a PC, it must be commandable by the player. This is in order
 * to prevent abuse of instant action feats.
 *
 * @param oCreature Creature whose eligibility to use a move action to test.
 * @return          TRUE if the creature can take a move action now, FALSE otherwise.
 */
int TakeMoveAction(object oCreature);

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

int TakeSwiftAction(object oCreature)
{
    if(!GetLocalInt(oCreature, PRC_SWIFT_ACTION_MARKER)    &&
       GetCanTakeFreeAction(oCreature, GetIsPC(oCreature)) &&
       GetCommandable(oCreature)
       )
    {
        // Mark swift action used up for this round
        SetLocalInt(oCreature, PRC_SWIFT_ACTION_MARKER, TRUE);
        DelayCommand(6.0f, DeleteLocalInt(oCreature, PRC_SWIFT_ACTION_MARKER));

        // Can use swift action
        return TRUE;
    }

    // Can't use swift action
    FloatingTextStringOnCreature("You have already used your swift action this round.", oCreature, FALSE);
    return FALSE;
}

int GetCanTakeFreeAction(object oCreature, int bTestControllability = FALSE)
{
    effect eTest = GetFirstEffect(oCreature);
    int nEType;
    while(GetIsEffectValid(eTest))
    {
        nEType = GetEffectType(eTest);
        if(nEType == EFFECT_TYPE_CUTSCENE_PARALYZE ||
           nEType == EFFECT_TYPE_DAZED             ||
           nEType == EFFECT_TYPE_PARALYZE          ||
           nEType == EFFECT_TYPE_PETRIFY           ||
           nEType == EFFECT_TYPE_SLEEP             ||
           nEType == EFFECT_TYPE_STUNNED           ||
           (bTestControllability &&
            (nEType == EFFECT_TYPE_CHARMED         ||
             nEType == EFFECT_TYPE_CONFUSED        ||
             nEType == EFFECT_TYPE_DOMINATED       ||
             nEType == EFFECT_TYPE_FRIGHTENED      ||
             nEType == EFFECT_TYPE_TURNED
             )
            )
           )
            return FALSE;

        // Get next effect
        eTest = GetNextEffect(oCreature);
    }

    return TRUE;
}

int TakeMoveAction(object oCreature)
{
    if(!GetLocalInt(oCreature, PRC_MOVE_ACTION_MARKER) && GetCommandable(oCreature))
    {
        // Mark move action used up for this round
        SetLocalInt(oCreature, PRC_MOVE_ACTION_MARKER, TRUE);
        DelayCommand(6.0f, DeleteLocalInt(oCreature, PRC_MOVE_ACTION_MARKER));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSlow(), oCreature, 4.0);

        // Can use move action
        return TRUE;
    }

    // Can't use move action
    FloatingTextStringOnCreature("You have already used your move action this round.", oCreature, FALSE);
    return FALSE;
}