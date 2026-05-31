// Trigger OnEnter -- close and lock all doors in the area.
//:://////////////////////////////////////////////////////////////
#include "nw_i0_plot"
  void main()
{ object oPC = GetEnteringObject();
  if( !GetIsPC( oPC)) return;

  int iNTH = 1;
  object oDoor = GetNearestObject( OBJECT_TYPE_DOOR, oPC, iNTH);
  while( GetIsObjectValid( oDoor))
  { AssignCommand( GetArea( oDoor), ActionCloseDoor( oDoor));
    AssignCommand( GetArea( oDoor), ActionDoCommand( SetLocked( oDoor, TRUE)));
    oDoor = GetNearestObject( OBJECT_TYPE_DOOR, oPC, ++iNTH);
  }
}

