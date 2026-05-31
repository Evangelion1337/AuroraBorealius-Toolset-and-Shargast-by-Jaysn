//::///////////////////////////////////////////////
//:: Demilich constants, includes, and scripts for
//:: use with CEP adaptation of Demigog's demilich.
//::///////////////////////////////////////////////

//::--------------------------------------------------------------
//:: Begin Demilich Constants and functions added by Loki Hakanin
//::--------------------------------------------------------------

#include "zep_inc_scrptdlg"

//First is RESREF of demilich skull placable to be created
//when the demilich goes into resting mode.
const string ZEP_DEMI_SKULL_RESREF = "zep_demi_skull";
//Second is RESREF of matching dust plume.
const string ZEP_DEMI_DUST_RESREF = "zep_demi_dust";

//Also have matching TAGs for the above two:
const string ZEP_DEMI_SKULL_TAG = "zep_demi_skull";
const string ZEP_DEMI_DUST_TAG = "zep_demi_dust";

//Following sets the save DC of the demilich's attempt to
//slay arcane spellcaters and trap their souls.
const int DEMILICH_SOUL_EAT_SAVE_DC = 15;

//Following sets the maximum number of soulgem victims the
//demilich will take on at a time.  Recommend this not be
//set higher than 8 or so, since LocalObject varibles are
//used to keep track of the victims.
const int DEMILICH_NUM_SOULGEMS = 8;

//Sets the minimum level an arcane caster must be in order
//for the demilich to attampt to pull out their soul upon
//a spell being cast at it.
const int DEMILICH_POWER_THRESHOLD = 15;

//Last we have the new tag which the demliich will use to
//differentiate a regenerating demilich from a normal one.
const string ZEP_DEMI_REGEN_SKULL = "zep_demi_skull_regen";

//Time, in seconds, for Demilich to regenerate from battle
//injuries.  Defaults to 5 minutes.  Note that PCs must use
//Holy Water on the demilich's bones in the span of that
//time in order to destroy it once and for all.
const int ZEP_DEMI_REGEN_TIME = 300;

//Messages Displayed over head of victims of soul-geming just
//before they are killed again by the Demilich's heartbeat
//script.
//Note that messages are concatenated with the name of the
//slain creature for a personalized effect.

string ZEP_DEMI_RESLAY_MSG = GetStringByStrRef(nZEPCantBeRaised ,GENDER_MALE);
//" jerks upright and spasms for a few moments before collapsing again.";
string ZEP_DEMI_RESLAY_MSG2 = GetStringByStrRef(nZEPNoRaiseExplan  ,GENDER_MALE);
//"Until the demilich's captive souls are freed, its victims cannot be raised.";

//Next float variable defines the demilich's perception range,
//while resting or regenerating, in meters.
const float ZEP_DEMI_PERC_RANGE = 5.0;

//Following messages are used for demilich's respawn scripts.
//First displayed by a just-respawned demilich that was
//regenerating.
//Latter displayed by a disturbed demilich that is responding
//to intruders.
string ZEP_DEMI_REGEN_MSG = GetStringByStrRef(nZEPDemiRestored,GENDER_MALE);
//"At last, I am restored...";
string ZEP_DEMI_DIST_MSG =  GetStringByStrRef(nZEPDemiDisturbed ,GENDER_MALE);
//"You disturb my work!";

//Following is message spoken in Demilich's OnSpellCastAt
//script if he's hit by a spell from a high level caster
string ZEP_DEMI_ONSPELL_MSG = GetStringByStrRef(nZEPDemiHavePower ,GENDER_MALE);
//"Yes, I sense you have power...your potential shall be mine!";

//Following defines RESREF and TAG of item that is needed
//to destroy a regenerating demilich.
const string ZEP_DEMI_DEST_RESREF = "zep_holy_water";
const string ZEP_DEMI_DEST_TAG = "zep_holy_water";

//Following is name of conversation to start if someone uses
//the demilich's bone pile.  First is for a default bone pile
//and second is for a regenerating bone pile that has already
//been defeated once.
const string ZEP_DEMI_ONUSE_CONV = "zep_demi_bones";
const string ZEP_DEMI_ONUSE_REGEN = "zep_demi_regen_c";

//Following string is floating text displayed over the
//demilich upon it's final destruction.
string ZEP_DEMI_FINAL_DEST = GetStringByStrRef(nZEPDemiVictFree ,GENDER_MALE);
//"With the demilich destroyed, the souls of its victims are released to their bodies.";

//Following flag sets whether to automatically resurrect
//victims of soul-gem entrappment upon the demilich's
//destruction.

const int ZEP_DEMI_RESS_VICTIMS = FALSE;

//::-------------------------------------------------
//:: Begin Demilich Functions added by Loki Hakanin
//::-------------------------------------------------

//Function will spawn appropriate bones and dust plume
//for demilich.  Will also copy over variables associated
//with any soultrapped victims, and change tag to flag bone
//pile as regenerating as necessary.
// Arguments:
// object oDemilichToReplace = The demilich that we're going
//                                to despawn
// int nWasDestroyed = Are we replacing the demilich with a
//                      rest-mode bone pile (FALSE), or a
//                      regenerating bone pile (TRUE)?
void ZEPDemilichSpawnBones(object oDemilichToReplace,int nWasDestroyed);

void ZEPDemilichSpawnBones(object oDemilichToReplace,int nWasDestroyed)
{
 //So we'll first get the Demilich's location, and then create
 //a pair of the usual demilich placables there.  However,
 //if the demilich is regenerating from wounds, we'll change
 //the tag of the skull pile to the ZEP_DEMI_REGEN_SKULL
 //constant value.
 //The scripts on the skull will use this tag to determine
 //if it is a fresh (i.e. undestroyed) demilich, or a crippled,
 //regenerating one.
 //We will also copy over the NumSouls local variable and the
 //set of LocalObjects pointing to the Demlich's set of soul-
 //gem'em victims, if any.
 location lDestroyedLocation = GetLocation(oDemilichToReplace);
 object oSkullPile;

  //If Demliich in question was destroyed, we create the skull
  //pile with the variant tag defined above, allowing the
  //skull pile to differentiate itself from a "healthy"
  //demilich.  This saves us a local variable.
 if (nWasDestroyed)
    oSkullPile=CreateObject(OBJECT_TYPE_PLACEABLE,ZEP_DEMI_SKULL_RESREF,lDestroyedLocation,FALSE,ZEP_DEMI_REGEN_SKULL);
 else oSkullPile=CreateObject(OBJECT_TYPE_PLACEABLE,ZEP_DEMI_SKULL_RESREF,lDestroyedLocation,FALSE);

 object oDustPlume=CreateObject(OBJECT_TYPE_PLACEABLE,ZEP_DEMI_DUST_RESREF,lDestroyedLocation,FALSE);

 //Now for the copying.  Loop through all GemVictim objects,
 //based on NumSouls.  Remember that GemVictim indexes start
 //from 0 (like an array in many programming languages),
 //though the Numsouls variable is a positive int.
 int nCounter=0;
 int nNumSouls=GetLocalInt(oDemilichToReplace,"NumSouls");
    //SendMessageToAllDMs(("NumSouls(SpawnBones):"+(IntToString(nNumSouls))));
 //Set NumSouls counter on skull pile
 SetLocalInt(oSkullPile,"NumSouls",nNumSouls);
 string sVictimCounterName="GemVictim";
 object oVictimCounter;

 for (nCounter=0; nCounter < nNumSouls; nCounter++)
    {
    //Get object variable name, then set a variable on the
    //skull pile with the same name, pointing to same
    //object.
    //Note we don't delete the local objects of the Demlich
    //here as they will be cleaned up upon the final destruction
    //of the demilich, which always follows this function's call.
    sVictimCounterName=("GemVictim"+(IntToString(nCounter)));
    oVictimCounter=GetLocalObject(oDemilichToReplace,sVictimCounterName);
  //  if (oVictimCounter==OBJECT_INVALID)
  //      SendMessageToAllDMs(("VictimCount("+(IntToString(nCounter))+") invalid."));
    SetLocalObject(oSkullPile,sVictimCounterName,oVictimCounter);
    }

}

//Function will play some dazed effects for a second,
//display some text explaining that the resurrection spell
//fails due to the demilich having oCreatureToSlay's soul,
//and then re-kills them.
void ZEPDemilichReSlay(object oCreatureToSlay);

void ZEPDemilichReSlay(object oCreatureToSlay)
{
  //We'll get the name of our victim and concatenate it with
  //our first message.  This personalizes things a bit.
  string sVictimName=GetName(oCreatureToSlay);

  AssignCommand(oCreatureToSlay,ClearAllActions());
  //Play spasm animation:
  AssignCommand(oCreatureToSlay,ActionPlayAnimation(ANIMATION_FIREFORGET_SPASM));
  //At the same time, display a descriptive string about the
  //creature's state.
  FloatingTextStringOnCreature((sVictimName+ZEP_DEMI_RESLAY_MSG),oCreatureToSlay,FALSE);
  //Kill the creature again.
  ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDeath(FALSE),oCreatureToSlay);
  //Further descriptive string.
  DelayCommand(6.0,FloatingTextStringOnCreature(ZEP_DEMI_RESLAY_MSG2,oCreatureToSlay,FALSE));
}

//Function will kill all soulgem victims of the Demilich again
//if they have been raised, playing some appriopriate animations
//and VFX, and displaying some text.
//Essentially, we'll check against the NumSouls variable
//on our demilich, and then cycle through all GemVictim
//local objects, running a function to display effects and
//kill them as necessary.
void ZEPDemilichReSlaySoulGemVictims(object oDemilich);

void ZEPDemilichReSlaySoulGemVictims(object oDemilich)
{
 int nCounter=0;        //Counter for variable names
 int nNumSouls=GetLocalInt(oDemilich,"NumSouls");      //Number of consumed souls
 string sVictimCounterName; //Used with nCounter to create proper local variable name
 object oVictimCounter;     //Counter for actual objects pointed to by demilich's victim list.

 //Don't forget, Counter (i.e., the "GemVictim" variable
 //name index) starts from 0, like an array index.
 //But nNumSouls is a positive int, so this for loop should be
 //logically consistent.
 for (nCounter=0; nCounter < nNumSouls; nCounter++)
    {
    sVictimCounterName=("GemVictim"+(IntToString(nCounter)));
    oVictimCounter=GetLocalObject(oDemilich,sVictimCounterName);
    //If the victim has more than 0 HPs... (i.e. is alive)
    //we'll kill them again, with explanatory text.
    if (GetCurrentHitPoints(oVictimCounter) > 0)
        ZEPDemilichReSlay(oVictimCounter);
    }
}


//Following function spawns a demilich from the bones
//that it left behind, either when resting or regenerating.
//Note that the soulgem victim list is copied over, and
//therefore preserved.
//Arguments:
//     oSourceBones- the bone placable that relevant variables
//     will be copied over from.
//     nDestroyBones- destroy object oSourceBones upon completion
//     of the function...TRUE= destroy it, FALSE = do nothing.
object ZEPDemilichFromBones(object oSourceBones, int nDestroyBones);

object ZEPDemilichFromBones(object oSourceBones, int nDestroyBones)
{
//First we create the Demilich.
object oReturnDemilich=CreateObject(OBJECT_TYPE_CREATURE,"zep_demi_lich",GetLocation(oSourceBones));
//Now we'll use a loop to copy over the soulgem victim list.
int nNumSouls = GetLocalInt(oSourceBones,"NumSouls");
int nCounter=0;
string sVarNameCounter;
object oVictimCounter;

//For loop will use int counter, concatenated with "GemVictim"
//to generate correct variable names.  Will then retrieve
//these variables from the oSourceBones object and copy
//them over to our new Demilich.
for (nCounter=0; nCounter < nNumSouls; nCounter++)
    {
    sVarNameCounter = ("GemVictim"+IntToString(nCounter));
    oVictimCounter = GetLocalObject(oSourceBones,sVarNameCounter);
    SetLocalObject(oReturnDemilich,sVarNameCounter,oVictimCounter);
    }
//Now we set the "NumSouls" counter on our newsly-spawned
//Demilich.
SetLocalInt(oReturnDemilich,"NumSouls",nNumSouls);

//Now, we're going to compare our bone pile's resref against
//the regenerating resref.  If it's the same, we display the
//regeneration message (defined above).
//Else we play the default "disturbed" message, since this
//function is called in two ways...a regenerating demilich
//or a disturbed Demilich.
string sBonePileTag=GetTag(oSourceBones);
if (sBonePileTag == ZEP_DEMI_REGEN_SKULL)
    {
    AssignCommand(oReturnDemilich,ActionSpeakString(ZEP_DEMI_REGEN_MSG,TALKVOLUME_SHOUT));
    FloatingTextStringOnCreature(ZEP_DEMI_REGEN_MSG,oReturnDemilich);
    }
else
    {
    AssignCommand(oReturnDemilich,ActionSpeakString(ZEP_DEMI_DIST_MSG,TALKVOLUME_SHOUT));
    FloatingTextStringOnCreature(ZEP_DEMI_DIST_MSG,oReturnDemilich);
    }

//Last, if the user has specified that we should destroy the
//bones and dust plume, we do so.
if (nDestroyBones == TRUE)
    {
    object oDustPlume=GetNearestObjectByTag(ZEP_DEMI_DUST_TAG);
//    if (oDustPlume==OBJECT_INVALID)
//        SendMessageToAllDMs("Bad Dust plume!");
    DestroyObject(oDustPlume);
    DestroyObject(oSourceBones);
    }
return oReturnDemilich;
}

//:: ---------------------------------------
//:: End Demilich functions and constants
//:: ---------------------------------------
