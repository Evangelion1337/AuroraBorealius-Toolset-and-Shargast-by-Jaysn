// Script Name: Level Restricted Area
// Purpose: Restrict access to areas by PC level
// Placement: Place in OnAreaTransitionClick on Doors
// Author: Qobra, with help from Adam_wasserman & Janus-SOK
// Created: 22 July 2002
// NOTE: You can change the level restriction by setting the 2 vaules (5 & 10)
// to anything you like within range 1-20.


void main() {

object oClicker = GetClickingObject();
object oTarget = GetTransitionTarget( OBJECT_SELF );
location lLoc = GetLocation( oTarget );
if ((GetHitDice(oClicker) >= 6) && (GetHitDice(oClicker) <=60)) {
AssignCommand( oClicker, JumpToLocation( lLoc ) );
} else {
SpeakString( "You have not reached the 6th horizon of life and cannot enter this area. Return to Lelitient and grow. " + "." );
}
}
