//::///////////////////////////////////////////////
//::
//:: Nordavinds Doppelganger
//:: version 1.1
//::
//:: Doppelganger.nss
//::
//:://////////////////////////////////////////////
//::
//:: Fixed:*The doppelganger doesn't drop the cloned
//:: equipment and is instead destroyed after
//:: a preset time of 90 seconds.
//:: *The trigger only spawns in one doppelganger
//:: to each player.
//::
//:: DISCLAIMER: I just realized that I might be way
//:: off when it comes to what a Doppelganger is when
//:: it comes to the D&D rules. Well, here you have my
//:: version of it anyway. I'd like to dedicate this
//:: script to the sheep Dolly, the very first official
//:: clone. Now YOU can clone the unsuspecting players
//:: of YOUR campaign! *cackles with insane glee*
//::
//:: This script is placed on the OnEnter of either
//:: a trigger or an area (though I'd guess a trigger
//:: would be the best choice. It duplicates/clones
//:: anyone (any PC that is) that enters and strips
//:: the clone for excessive inventory. The clone is
//:: NEVER created in the toolset and have no scripts
//:: attached. At least that I am aware of. Since this
//:: is so you have to give the doppelganger all its
//:: commands in this script. The doppelganger will be
//:: created at a waypoint with the tag "WP_NEST". You
//:: have to create it in your module if you want the
//:: Doppelganger to be created. Modify it as you wish.
//::
//:: If you want this script to affect more than player characters
//:: you have to comment if(GetIsPC(GetEnteringObject()))
//:: (add // on the line and on the { and }. Though be aware!
//:: Cloned familiars and summoned creature clones are friendly
//:: towards the PC! =(
//::
//:: I created this script because I saw someone had problems
//:: to do it. I do not blame them for that, as it would
//:: have been impossible without the CopyObject command
//:: that came with the 1.28 patch.
//::
//:: Feel free to do whatever you want with this
//:: script as it might have great potentials in the
//:: right hands. Though if you want to put it in a module
//:: without finding a workaround to the items that
//:: drops from the doppelganger, I strongly suggest
//:: you put some 'block' on it so it will only
//:: launch one time for each creature. Else you'd get
//:: a goldmine for the sturdy adventurer.
//::
//::
//:: -Cheers!
//::
//:://////////////////////////////////////////////
//::
//:: Created By: Nordavind
//:: Created On: Mars 2, 2003
//::
//:://////////////////////////////////////////////

//////////////////////////////////////////////////////////
// Here you can modify the Doppelganger to suit your need
//////////////////////////////////////////////////////////
void ModifyDoppelganger(object oDoppelganger)
{
/* I had to add this line as the cloned familiars and the
cloned summoned creatures that followed was friendly
toward the PC.
... DOH! it didn't work! The Familiars and summoned
creature clones are still friendly. Hmh, any suggestions
about how to make them hostile towards the PC?? */
ChangeToStandardFaction(oDoppelganger, STANDARD_FACTION_HOSTILE);

/* Destroying the objects in the Doppelgangers inventory
(unfortunately I don't know if it is possible to tag
the items the Doppelganger has equiped as not dropable) */
object oItem = GetFirstItemInInventory(oDoppelganger);
while (GetIsObjectValid(oItem) == TRUE)
{
DestroyObject(oItem);
oItem = GetNextItemInInventory(oDoppelganger);
}

/* Working around this with the SetIsDestroyable, making
the corpse unlootable.. *damn* I had hoped this worked,
though testing proved otherwise, the items were dropped to
the ground. Now I have no idea how to work around this,
any suggestions would be appreciated */
AssignCommand(oDoppelganger, SetIsDestroyable(FALSE, FALSE, FALSE));

// Destroying the gold coins on the Doppelganger
int nGold = GetGold(oDoppelganger);
TakeGoldFromCreature(nGold, oDoppelganger, TRUE);

/* Making sure the doppelganger has full health
(as the PC might have been wounded)*/
int nHP = GetMaxHitPoints(oDoppelganger);
ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nHP), oDoppelganger);
}

////////////////////////////////////////////////////////////
// Here you can assign actions/behavior to the Doppelganger
////////////////////////////////////////////////////////////
void CommandDoppelganger(object oDoppelganger, object oPc)
{
AssignCommand(oDoppelganger, ActionMoveToObject(oPc, TRUE, 7.0f));
AssignCommand(oDoppelganger, ActionDoCommand(PlayVoiceChat(VOICE_CHAT_TAUNT, OBJECT_SELF)));
AssignCommand(oDoppelganger, ActionDoCommand(ActionPlayAnimation(ANIMATION_FIREFORGET_TAUNT)));
AssignCommand(oDoppelganger, ActionDoCommand(ActionAttack(oPc, FALSE)));
}

////////////////////////////////////////////////////////////
// Here we make the doppelganger dissepear...
////////////////////////////////////////////////////////////
void DestroyDoppelganger(object oDoppelganger)
{
// Removing the items in the creatures item slots
object oSlot = GetItemInSlot(INVENTORY_SLOT_ARMS, oDoppelganger); DestroyObject(oSlot, 0.1f);
oSlot = GetItemInSlot(INVENTORY_SLOT_ARROWS, oDoppelganger); DestroyObject(oSlot, 0.1f);
oSlot = GetItemInSlot(INVENTORY_SLOT_BELT, oDoppelganger); DestroyObject(oSlot, 0.1f);
oSlot = GetItemInSlot(INVENTORY_SLOT_BOLTS, oDoppelganger); DestroyObject(oSlot, 0.1f);
oSlot = GetItemInSlot(INVENTORY_SLOT_BOOTS, oDoppelganger); DestroyObject(oSlot, 0.1f);
oSlot = GetItemInSlot(INVENTORY_SLOT_BULLETS, oDoppelganger); DestroyObject(oSlot, 0.1f);
oSlot = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oDoppelganger); DestroyObject(oSlot, 0.1f);
oSlot = GetItemInSlot(INVENTORY_SLOT_CLOAK, oDoppelganger); DestroyObject(oSlot, 0.1f);
oSlot = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oDoppelganger); DestroyObject(oSlot, 0.1f);
oSlot = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oDoppelganger); DestroyObject(oSlot, 0.1f);
oSlot = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oDoppelganger); DestroyObject(oSlot, 0.1f);
oSlot = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oDoppelganger); DestroyObject(oSlot, 0.1f);
oSlot = GetItemInSlot(INVENTORY_SLOT_LEFTRING, oDoppelganger); DestroyObject(oSlot, 0.1f);
oSlot = GetItemInSlot(INVENTORY_SLOT_NECK, oDoppelganger); DestroyObject(oSlot, 0.1f);
oSlot = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oDoppelganger); DestroyObject(oSlot, 0.1f);
oSlot = GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oDoppelganger); DestroyObject(oSlot, 0.1f);

/* If you want any effects on the doppelganger when it dissepears,
uncomment the lines below and alter it to suit your liking.*/
//effect eDeath = EffectVisualEffect(VFX_IMP_RAISE_DEAD);
//ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oDoppelganger);

// Removing the Creature now as we finaly have gotten rid of the items.
AssignCommand(oDoppelganger, AssignCommand(oDoppelganger, SetIsDestroyable(TRUE, FALSE, FALSE)));
DestroyObject(oDoppelganger, 0.01f);

/* I have moved the destroy chest and helmet armor to here so
the corpse don't dissepear naked */
oSlot = GetItemInSlot(INVENTORY_SLOT_CHEST, oDoppelganger); DestroyObject(oSlot, 0.1f);
oSlot = GetItemInSlot(INVENTORY_SLOT_HEAD, oDoppelganger); DestroyObject(oSlot, 0.1f);
}

////////////////////////////////////////////////////////////
// The Main script that launches OnEnter
////////////////////////////////////////////////////////////
void main()
{
object oPc = GetEnteringObject();
string sName = GetName(oPc);

/* Since we haven't created the Local Int in the line below
it will return a '0', making the creation of the doppelganger
possible*/
if (GetLocalInt(oPc, sName+"'s Doppelganger") == 0)
{ if(GetIsPC(GetEnteringObject()))
{
object oNest = GetWaypointByTag("WP_NEST");
location lNest = GetLocation(oNest);
object oDoppelganger = CopyObject(oPc, lNest, OBJECT_INVALID, "doppelganger"); //modified the tag!
ModifyDoppelganger(oDoppelganger);
CommandDoppelganger(oDoppelganger, oPc);
/* With the line below the local Int will return a '1', making it impossible
to create further doppelgangers to this PC */
SetLocalInt(oPc, sName+"'s Doppelganger", 1);
/* Alter the line below to decide how long the doppelganger will excist.
This is in seconds. Hopefully the doppelganger is killed before the
time runs out.*/
DelayCommand(90.0f, DestroyDoppelganger(oDoppelganger));
}
}
}
