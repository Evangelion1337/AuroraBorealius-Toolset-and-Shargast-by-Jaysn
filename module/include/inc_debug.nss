//:://////////////////////////////////////////////
//:: Debug include
//:: inc_debug
//:://////////////////////////////////////////////
/** @file
    This file contains a debug printing function, the
    purpose of which is to be leavable in place in code,
    so that debug printing can be centrally turned off
    by commenting out the contents of the function.

    Also, an assertion function and related function for
    killing script execution.
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/*                  Globals                     */
//////////////////////////////////////////////////

/**
 * Prefix all your debug calls with an if(DEBUG) so that they get stripped away
 * during compilation as dead code when this is turned off.
 */
//const int DEBUG = FALSE;
#include "prc_inc_switch"
int DEBUG = GetPRCSwitch(PRC_DEBUG);

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * May print the given string, depending on whether debug printing is needed.
 *
 * Calls to this function should be guarded by an "if(DEBUG)" clause in order
 * to be disableable.
 *
 * @param sString The string to print
 */
void DoDebug(string sString, object oAdditionalRecipient = OBJECT_INVALID);

/**
 * Kills script execution using the Die() function if the given assertion
 * is false. If a message has been given, also prints it using DoDebug().
 * An assertion is something that should always be true if the program
 * is functioning correctly. An assertion being false indicates a fatal error.
 *
 * The format of the string printed when an assertion fails is:
 *  "Assertion failed: sAssertion\nsMessage; At sScriptName: sFunction"
 *
 * Calls to this function should be guarded by an "if(DEBUG)" clause in order
 * to be disableable.
 *
 * Example use:
 *
 * if(DEBUG) Assert(1 == 1, "1 == 1", "Oh noes! Arithmetic processing is b0rked.", "fooscript", "Baz()");
 *
 * @param bAssertion  The result of some evaluation that should always be true.
 * @param sAssertion  A string containing the statement evalueated for bAssertion.
 * @param sMessage    The message to print if bAssertion is FALSE. Will be
 *                    prefixed with "Assertion failed: " when printed.
 *                    If left to default (empty), the message printed will simply
 *                    be "Assertion failed!".
 * @param sFileName   Name of the script file where the call to this function occurs.
 * @param sFunction   Name of the function where the call to this function occurs.
 */
void Assert(int bAssertion, string sAssertion, string sMessage = "", string sFileName = "", string sFunction = "");

/**
 * Kills the execution of the current script by forcing a Too Many Instructions
 * error.
 * Not recommended for use outside of debugging purposes. Scripts should be able
 * to handle expectable error conditions gracefully.
 */
void Die();

/**
 * Converts data about a given object into a string of the following format:
 * "'GetName' - 'GetTag' - 'GetResRef' - ObjectToString"
 *
 * @param o Object to convert into a string
 * @return  A string containing identifying data about o
 */
string DebugObject2Str(object o);

/**
 * Converts the given location into a string representation.
 *
 * @param loc Location to convert into a string
 * @return    A string representation of loc
 */
string DebugLocation2Str(location loc);

/**
 * Converts the given itemproperty into a string representation.
 *
 * @param iprop Itemproperty to convert into a string
 * @return      A string representation of iprop
 */
string DebugIProp2Str(itemproperty iprop);

/**
 * Converts a boolean to a string. Quick debug version.
 * @see BooleanToString to use the tlkified one
 *
 * @param bool The boolean value to convert. 0 is considered false
 *             and everything else is true.
 */
string DebugBool2String(int bool);

/**
 * Converts the given effect into a string representation.
 *
 * @param eEffect   effect to convert into a string
 * @return          A string representation of effect
 */
string DebugEffect2String(effect eEffect);

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

void DoDebug(string sString, object oAdditionalRecipient = OBJECT_INVALID)
{
    SendMessageToPC(GetFirstPC(), "<c´jŸ>" + sString + "</c>");
    if(oAdditionalRecipient != OBJECT_INVALID)
        SendMessageToPC(oAdditionalRecipient, "<c´jŸ>" + sString + "</c>");
    WriteTimestampedLogEntry(sString);
}

void Assert(int bAssertion, string sAssertion, string sMessage = "", string sFileName = "", string sFunction = "")
{
    if(bAssertion == FALSE)
    {
        //SpawnScriptDebugger();
        string sErr = "Assertion failed: " + sAssertion;

        if(sMessage != "" || sFileName != "" || sFunction != "")
        {
            sErr += "\n";

            if(sMessage != "")
                sErr += sMessage;

            if(sFileName != "" || sFunction != "")
            {
                if(sMessage != "")
                    sErr += "\n";

                sErr += "At " + sFileName;

                if(sFileName != "" && sFunction != "")
                    sErr += ": ";

                sErr += sFunction;
            }
        }

        DoDebug(sErr);
        Die();
    }
}

void Die()
{
    while(TRUE) {;}
}

string DebugObject2Str(object o)
{
    return o == OBJECT_INVALID ?
            "OBJECT_INVALID" :   // Special case
            "'" + GetName(o) + "' - '" + GetTag(o) + "' - '" + GetResRef(o) + "' - " + ObjectToString(o);
}

string DebugLocation2Str(location loc)
{
    object oArea = GetAreaFromLocation(loc);
    vector vPos = GetPositionFromLocation(loc);
    string sX, sY, sZ, sF;
    // 3 decimal places and no leading whitespace
    sX = FloatToString(vPos.x,0,3);
    sY = FloatToString(vPos.y,0,3);
    sZ = FloatToString(vPos.z,0,3);
    sF = FloatToString(GetFacingFromLocation(loc),0,3);

    return "Area: Name = '" + GetName(oArea) + "', Tag = '" + GetTag(oArea) + "'; Position: (" + sX + ", " + sY + ", " + sZ + ",); Facing: " + sF;
}

string DebugIProp2Str(itemproperty iprop)
{
    return "Type: " + IntToString(GetItemPropertyType(iprop)) + "; "
         + "Subtype: " + IntToString(GetItemPropertySubType(iprop)) + "; "
         + "Duration type: " + (GetItemPropertyDurationType(iprop) == DURATION_TYPE_INSTANT ?   "DURATION_TYPE_INSTANT"   :
                                GetItemPropertyDurationType(iprop) == DURATION_TYPE_TEMPORARY ? "DURATION_TYPE_TEMPORARY" :
                                GetItemPropertyDurationType(iprop) == DURATION_TYPE_PERMANENT ? "DURATION_TYPE_PERMANENT" :
                                IntToString(GetItemPropertyDurationType(iprop))) + "; "
         + "Param1: " + IntToString(GetItemPropertyParam1(iprop)) + "; "
         + "Param1 value: " + IntToString(GetItemPropertyParam1Value(iprop)) + "; "
         + "Cost table: " + IntToString(GetItemPropertyCostTable(iprop)) + "; "
         + "Cost table value: " + IntToString(GetItemPropertyCostTableValue(iprop));
}

string DebugBool2String(int bool)
{
    return bool ? "True" : "False";
}

string DebugEffect2String(effect eEffect)
{
    return "Effect; Type = " + IntToString(GetEffectType(eEffect))
          + ", SpellID: "     + IntToString(GetEffectSpellId(eEffect))
          + ", Subtype: "     + IntToString(GetEffectSubType(eEffect))
          + ", Duration: "    + IntToString(GetEffectDurationType(eEffect))
          + ", Creator: "     + GetName(GetEffectCreator(eEffect));
}