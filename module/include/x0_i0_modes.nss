//:://////////////////////////////////////////////////
//:: X0_I0_MODES
/*
  Small include library for various behavior modes,
  such as stealth mode, detect mode, etc.
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 01/19/2003
//:://////////////////////////////////////////////////

/**********************************************************************
 * CONSTANTS
 **********************************************************************/

string sModeVarname = "NW_MODES_CONDITION";

int NW_MODE_STEALTH                = 0x00000001;
int NW_MODE_DETECT                 = 0x00000002;

// int NW_MODE_                = 0x00000000;

/**********************************************************************
 * FUNCTION PROTOTYPES
 **********************************************************************/

// TRUE if the given creature has the given mode active
int GetModeActive(int nMode, object oCreature=OBJECT_SELF);

// Mark that the given creature has the given mode active or not
void SetModeActive(int nMode, int bActive=TRUE, object oCreature=OBJECT_SELF);

// If stealth mode is active, turn on the appropriate skills.
void UseStealthMode();

// If detect mode is active, turn on the appropriate skills.
void UseDetectMode();


/**********************************************************************
 * FUNCTION DEFINITIONS
 **********************************************************************/

// TRUE if the given creature has the given mode active
int GetModeActive(int nMode, object oCreature=OBJECT_SELF)
{
    return (GetLocalInt(oCreature, sModeVarname) & nMode);
}

// Mark that the given creature has the given mode active or not
void SetModeActive(int nMode, int bActive=TRUE, object oCreature=OBJECT_SELF)
{
    int nCurrentModes = GetLocalInt(oCreature, sModeVarname);
    if (bActive) {
        SetLocalInt(oCreature, sModeVarname, nCurrentModes | nMode);
    } else {
        SetLocalInt(oCreature, sModeVarname, nCurrentModes & ~nMode);
    }

}

// If stealth mode is active, turn on the appropriate skills.
void UseStealthMode()
{
    if (GetModeActive(NW_MODE_STEALTH))
    {
        ActionUseSkill(SKILL_HIDE, OBJECT_SELF);
        ActionUseSkill(SKILL_MOVE_SILENTLY, OBJECT_SELF);
    }
}

// If detect mode is active, turn on the appropriate skills.
void UseDetectMode()
{
    if (GetModeActive(NW_MODE_DETECT)) {
        ActionUseSkill(SKILL_SEARCH, OBJECT_SELF);
    }
}
