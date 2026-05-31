//mm_dwarfguard
//OnPerception
#include "nw_i0_generic"
#include "prc_inc_racial"

void main()
{ object oPC = GetLastPerceived();

  if( !GetIsPC(oPC)) return;
  
  if( !GetLastPerceptionSeen()) return;
  
  if( (MyPRCGetRacialType(oPC) == RACIAL_TYPE_DWARF) ||
      (MyPRCGetRacialType(oPC) == RACIAL_TYPE_GNOME))
    return;

  ClearAllActions();  // its a good idea to clear out previous actions before giving him new ones to do in this case.
  DetermineCombatRound( oPC);
  SpeakString( "Die Interloper!");
}

