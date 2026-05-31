//::///////////////////////////////////////////////
//:: Tome of Battle include: Martial Lore Skill
//:: tob_inc_martlore
//::///////////////////////////////////////////////
/** @file
    Defines various functions and other stuff that
    do something related to the Martial Lore skill
    See page #28 of Tome of Battle
    
    Functions below are called by the initiator as
    he makes a maneuver.

    @author Stratovarius
    @date   Created - 2007.3.19
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Returns the maneuver that the Initiator just used
 * @param oInitiator  The maneuver initiator
 * @param nSpellId   maneuver to check
 *
 * @return           nothing, uses SendMessageToPC to give results
 */
void IdentifyManeuver(object oInitiator, int nSpellId);

/**
 * Returns the disciplines that the Initiator has
 * @param oInitiator  The maneuver initiator
 *
 * @return           nothing, uses SendMessageToPC to give results
 */
void IdentifyDiscipline(object oInitiator);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "tob_inc_tobfunc"

//////////////////////////////////////////////////
/*             Internal functions               */
//////////////////////////////////////////////////

void _DoMartialLoreCheck(object oInitiator, object oCheck, int nManeuverLevel, int nSpellId)
{
    // NPCs wouldn't benefit from being told the name of the maneuver
    if(!GetIsPC(oCheck))
        return;

    // No Bonus normally
    int nSwordSage = 0;

    if(TOBGetHasDisciplineFocus(oInitiator, nSpellId)) nSwordSage = 2;

    // Roll the check, DC is reduced by Swordsage bonus instead of bonus on check. Same end result.
    if(GetIsSkillSuccessful(oCheck, SKILL_MARTIAL_LORE, 10 + nManeuverLevel - nSwordSage))
    {    // get the name of the initiator and maneuver
        FloatingTextStringOnCreature(GetName(oInitiator) + " Initiates " + GetStringByStrRef(StringToInt(Get2DACache("spells", "Name", nSpellId))), oCheck, FALSE);
    }
    else // Skill check failed
    {
        FloatingTextStringOnCreature(GetName(oInitiator) + " Initiates Unknown Maneuver", oCheck, FALSE);
    }
}

void _DoDisciplineCheck(object oInitiator, object oCheck, int nInitiatorLevel)
{
    // NPCs wouldn't benefit from being told the disciplines
    if(!GetIsPC(oCheck))
        return;

    if(GetIsSkillSuccessful(oCheck, SKILL_MARTIAL_LORE, 20 + nInitiatorLevel))
    {
        // Check the Disciplines, 1 to 9
        string sDiscipline = "";
        int i;
        for(i = 1; i < 10; i++)
        {
            if(TOBGetHasDisciplineFocus(oInitiator, i))
            {
                sDiscipline += GetDisciplineName(i);
                sDiscipline += ", ";
            }
        }
        // Send the Message
        SendMessageToPC(oCheck, GetName(oInitiator) + " Knows Maneuvers From" + sDiscipline);
    }
    else // Skill check failed
    {
        SendMessageToPC(oCheck, GetName(oInitiator) + " Discipline Check Failed.");
    }
}

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

void IdentifyManeuver(object oInitiator, int nSpellId)
{
    int nManeuverLevel = GetManeuverLevel(oInitiator);

    // The area to check for martial lore users
    object oTarget = MyFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, GetLocation(oInitiator), TRUE, OBJECT_TYPE_CREATURE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget) && oTarget != oInitiator)
    {
        // If the target has points in the skill
        if(GetSkillRank(SKILL_MARTIAL_LORE, oTarget) > 0) _DoMartialLoreCheck(oInitiator, oTarget, nManeuverLevel, nSpellId);

    //Select the next target within the area.
    oTarget = MyNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, GetLocation(oInitiator), TRUE, OBJECT_TYPE_CREATURE);
    }
}

void IdentifyDiscipline(object oInitiator)
{
    int nInitiatorLevel = GetInitiatorLevel(oInitiator);

    // The area to check for martial lore users
    object oTarget = MyFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, GetLocation(oInitiator), TRUE, OBJECT_TYPE_CREATURE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while(GetIsObjectValid(oTarget))
    {
        // If the target has points in the skill
        if(GetSkillRank(SKILL_MARTIAL_LORE, oTarget) > 0
        && oTarget != oInitiator)
            _DoDisciplineCheck(oInitiator, oTarget, nInitiatorLevel);

    //Select the next target within the area.
    oTarget = MyNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, GetLocation(oInitiator), TRUE, OBJECT_TYPE_CREATURE);
    }
}