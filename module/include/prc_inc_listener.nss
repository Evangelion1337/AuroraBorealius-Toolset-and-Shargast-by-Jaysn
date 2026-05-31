//::///////////////////////////////////////////////
//:: Generic Listener interface include
//:: prc_inc_listener
//::///////////////////////////////////////////////
/** @file
    This file defines a function for using a
    simple generic listener creature.

    The listener is limited to a single listening
    pattern by default, but as an object is returned,
    you may add your own if you so wish using
    AddPattern().
    It may listen either to a specific creature or
    at some location depending on the value of the
    oListenTo parameter of SpawnListener().
    If oListenTo is not a valid object, the listener
    is spawned at the location specified by lSpawnAt
    and will remain there listening to all speakers
    within it's range.
    But if oListenTo is a valid object, the listener
    will spawn near it and attempt to stay next to
    it. And the listener will only pass on strings
    spoken by the specified object.

    When the listener hears a string that it is
    supposed to act on, it will ExecuteScript() the
    script attached to the event on itself.
    Use GetLastSpeaker() to retrieve the object
    that spoke the string and GetMatchedSubstringsCount()
    & GetMatchedSubstring() to retrieve the spoken string.


    If a time to live is specified (fTTL > 0), the listener
    will destroy itself once that time has run out.
    It will also destroy itself if it has been set to listen
    to a particular object and that object ceases being valid.


    Regarding the patterns used, taken from NWN Lexicon:

    >From Noel (Bioware):
    >** will match zero or more characters
    >*w one or more whitespace
    >*n one or more numeric
    >*p one or more punctuation
    >*a one or more alphabetic
    >| is or
    >( and ) can be used for blocks
    >
    >- setting a creature to listen for "**" will match any string
    >- telling him to listen for "**funk**" will match any string that contains the word "funk".
    >- "**(bash|open|unlock)**(chest|door)**" will match strings like "open the door please" or "he just bashed that chest!"

    If several patterns would match the same string, the one
    added first using AddPattern will be the one matched.
*/
//:://////////////////////////////////////////////
//:: Created By: Ornedan
//:: Created On: 19.06.2005
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/* Constant defintions                          */
//////////////////////////////////////////////////

//const string LISTENER_STORE_VARIABLE = "PRC_SGListener_Last_Heard_String";
//const int PRC_GENERIC_LISTENER_FIRST_PATTERN_NUMBER = 0xffff;
const string PRC_GENERIC_LISTENER_SCRIPT_NAME = "prc_glist_onhb";


//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

/**
 * Creates a new listener. See prc_inc_listener header for details.
 *
 * @param sScriptToCall The name of the script to call when the listener hears something matching it's pattern.
 * @param lSpawnAt      Location to spawnt the listener at. This is ignored if oListenTo is a valid object.
 * @param sPattern      A regular expression defining the pattern of strings the listener listens to.
 *                      Defaults to everything.
 * @param oListenTo     Object to listen to. If this is specified, the listener will be spawned by it instead of at
 *                      lSpawnAt and will attempt to follow it around. It will also only fire the script for
 *                      strings spoken by this object.
 * @param fTTL          How long the listener will exist. Once this runs out, the listener will self-destruct. A
 *                      value of 0.0f or less means the listener is permanent (unless the object it is listening
 *                      to ceases being valid if one was specified).
 *                      NOTE: Due to some weirdness in when the listener actually starts listening, it won't
 *                      actually hear anything for the first 3 or so seconds of it's existence.
 *                      seconds of this duration
 * @param bNotify       If this is TRUE, the listener will give a notice when it's spawned to either the target it's
 *                      listening to, or everyone in the area it's listening in.
 *
 * @return  The newly created listener.
 */
object SpawnListener(string sScriptToCall, location lSpawnAt,
                     string sPattern = "**", object oListenTo = OBJECT_INVALID, float fTTL = 0.0f, int bNotify = TRUE, string sNewTag = "");

/**
 * Adds a new pattern for the specified listener to listen to. Not recommended for use with
 * creatures other than those created with SpawnListener().
 *
 * @param oListener     The listener object to add the pattern to.
 * @param sPattern      A regular expression defining the pattern of strings the listener listens to.
 * @param sScriptToCall The name of the script to call when the listener hears something matching the
 *                      given pattern.
 */
void AddPattern(object oListener, string sPattern, string sScriptToCall);

/**
 * Nulls the listener's listening patterns and destroys it. Use this instead of
 * DestroyObject(), because
 * 1) Destruction is not immediate, so nulling the listening patterns is required
 *    to make sure it does not register any more strings in the meantime.
 * 2) The listener is normally set undestroyable, which this function undoes
 *    automatically.
 *
 * @param oListener     The listener object to destroy.
 * @param bFirst        Whether the function is being run for the first time,
 *                      or it has already recuresed. When calling, always leave
 *                      this to default (ie, TRUE).
 */
void DestroyListener(object oListener, int bFirst = TRUE);

//#include "inc_utility"
#include "prc_alterations"

//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////

object SpawnListener(string sScriptToCall, location lSpawnAt,
                     string sPattern = "**", object oListenTo = OBJECT_INVALID, float fTTL = 0.0f, int bNotify = TRUE, string sNewTag = "")
{
    // Check for whether we are listening to a single object or at a location
    if(GetIsObjectValid(oListenTo)) // Use GetIsObjectValid instead of direct comparison to OBJECT_INVALID, because using an invalid location may crash the game.
        lSpawnAt = GetLocation(oListenTo);

    object oListener = CreateObject(OBJECT_TYPE_CREATURE, "prc_gen_listener", lSpawnAt, FALSE, sNewTag);
    // Paranoia check
    if(!GetIsObjectValid(oListener))
    {
        string sErr = "prc_inc_listener: SpawnListener(): ERROR: created listener is invalid!\n"
                    + "sScriptToCall = '" + sScriptToCall + "'\n"
                    + "lSpawnAt = " + DebugLocation2Str(lSpawnAt) + "\n"
                    + "sPattern = '" + sPattern + "'\n"
                    + "oListenTo = " + DebugObject2Str(oListenTo) + "\n"
                    + "fTTL = " + FloatToString(fTTL) + "\n"
                    + "bNotify = " + DebugBool2String(bNotify) + "\n";
        if(DEBUG) DoDebug(sErr);
        else      WriteTimestampedLogEntry(sErr);
        return OBJECT_INVALID;
    }

    // A few more tricks to make sure the listener will will not be affected by anything
    SetImmortal(oListener, TRUE);
    SetPlotFlag(oListener, TRUE);
    AssignCommand(oListener, SetIsDestroyable(FALSE, FALSE, FALSE));
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneGhost(), oListener);
    // Or seen
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY), oListener, 9999.0f);

    // Set the number of heartbeats until refreshing the invisbility VFX
    SetLocalInt(oListener, "PRC_GenericListener_VFXRefreshTimer", 1500);

    // The actual listening part
    SetListening(oListener, TRUE);
    AddPattern(oListener, sPattern, sScriptToCall);

    // Store data for use in heartbeat depending on whether listening to a single creature or an area
    if(GetIsObjectValid(oListenTo))
    {
        SetLocalInt(oListener, "PRC_GenericListener_ListenToSingle", TRUE);
        SetLocalObject(oListener, "PRC_GenericListener_ListeningTo", oListenTo);

        // Make the listener start following the target
        AssignCommand(oListener, ActionForceFollowObject(oListenTo));
    }
    else
        SetLocalLocation(oListener, "PRC_GenericListener_ListeningLocation", lSpawnAt);

    // Has limited duration?
    if(fTTL > 0.0f)
    {
        DelayCommand(fTTL, DestroyListener(oListener));

        // Paranoia - also set a timer so that the listener destroys itself on hearbeat once it's time is up
        SetLocalInt(oListener, "PRC_GenericListener_HasLimitedDuration", TRUE);
        SetLocalInt(oListener, "PRC_GenericListener_DestroyTimer", FloatToInt(fTTL + 6.0f) / 6);
    }

    // Should we send a notice that the listener is working
    if(!bNotify)
        SetLocalInt(oListener, "PRC_GenericListener_NoNotification", TRUE);

    AddEventScript(oListener, EVENT_ONHEARTBEAT, PRC_GENERIC_LISTENER_SCRIPT_NAME, TRUE, FALSE);

    return oListener;
}

void AddPattern(object oListener, string sPattern, string sScriptToCall)
{
    // Get the index to store the pattern in
    int nPattern = GetLocalInt(oListener, "PRC_GenericListener_FreePattern");

    SetListenPattern(oListener, sPattern, nPattern);
    SetLocalString(oListener, "PRC_GenericListener_ListenScript_" + IntToString(nPattern), sScriptToCall);

    SetLocalInt(oListener, "PRC_GenericListener_FreePattern", nPattern + 1);
}

void DestroyListener(object oListener, int bFirst = TRUE)
{
    if(bFirst)
    {
        int nMax = GetLocalInt(oListener, "PRC_GenericListener_FreePattern");
        int i;
        for(i = 0; i < nMax; i++)
        {
            SetListenPattern(oListener, "", i);
            DeleteLocalString(oListener, "PRC_GenericListener_ListenScript_" + IntToString(i));
        }

        SetCommandable(TRUE, oListener);
        AssignCommand(oListener, ClearAllActions());

        RemoveEventScript(oListener, EVENT_ONHEARTBEAT, PRC_GENERIC_LISTENER_SCRIPT_NAME, TRUE, FALSE);
    }

    AssignCommand(oListener, SetIsDestroyable(TRUE, FALSE, FALSE));
    AssignCommand(oListener, DestroyObject(oListener));

    DestroyObject(oListener);

    DelayCommand(0.5f, DestroyListener(oListener, FALSE));
}
