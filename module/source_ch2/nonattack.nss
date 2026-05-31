//Goes OnPerceived of an NPC
void main()
{

object oPC = GetLastPerceived();

if (!GetIsPC(oPC)) return;

if (!GetLastPerceptionSeen()) return;
if (GetItemPossessedBy(oPC, "Gessacherring")== OBJECT_INVALID) //Change "Your Item Tag" to the tag of the item being checked for.
   return;

object oTarget;
oTarget = GetObjectByTag("PC"); //Change "Hostile" to the faction you want to change reputations with.

AdjustReputation(oPC, oTarget, -100); //Change -100 to whatever amount you want reputation to change.

}


