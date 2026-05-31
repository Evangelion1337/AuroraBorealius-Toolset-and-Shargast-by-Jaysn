/*
Supply Based Rest System: Version 1.2
Created by: Demetrious and OldManWhistler

For questions or comments, or to get the latest version please visit:
http://nwvault.ign.com/Files/scripts/data/1055903555000.shtml

****************************************************************************
CONTENTS
****************************************************************************

Placeables>>Misc Interior - restful bed, restful bed (invisible object), restful cot, restful bedroll, restful campsite.

Items>>Misc>>kits - Supply kit, Woodland kit, DM Rest Widget.

Supply Kit weighs 30 lbs, costs 100gp and can be used by anyone to create a restful object.
Supply Kit weighs 15 lbs, costs 75gp and can only be used by rangers/druids.

Scripts - sbr_onrest, sbr_restful_obj, sbr_onactivate, sbr_onacquire, sbr_include, logmessage



****************************************************************************
DESCRIPTION
****************************************************************************

This is a supply based rest system.  There are three methods of resting in this system:

1)  Restful beds, cots, bedrolls - I personally place these in towns or cities and maybe rarely in dungeons where it is assumed that there are sufficient supplies to rest (ie food, water, bed).  These objects will ALWAYS allow a player to rest.

2)  Supply kit resting (or woodland kit resting) - Using this item will create a campfire that players may use to rest.  For roleplaying, the kit contains all supplies needed to rest and these are used while the players rest.  It is removed after a time delay of several minutes.

3)  DM Controlled rest widget - DM can turn resting on/off for the entire module, a specific area, or a specific player.

This is an attempt create a rest system closer to the resting that I remember from PnP.  This system encourages players to rest as a group and forces them to ration supplies.  Finally it forces the players to guard the campfire because how bad would it be if a bear destroyed the campfire before they could all rest.

The kits are purposefully heavy.  This is to encourage appropriate rationing of supplies.

If player rest is restricted by a BW trigger or by your widget, you will receive a message stating the reason rest was restricted and the message will include the player name and area and level that restricted rest. Both the player and the DM will receive a message that indicates the reason for rest being canceled.



****************************************************************************
INSTALLATION
****************************************************************************

// SupplyBasedRest.erf contains the base scripts, the placeables and the items.
// sbr_acttag.erf is only needed if you use an activate item system
// where you execute the item's tag as a script
// (ie: you use X0_ONITEMACTV as your OnActivateItem script).

// #1: Modify OnAcquiredItem module event script (create if it does not exist).
// Add the following line to somewhere in the void main function. If you do
// not have an OnAcquiredItem script then you can use 'sbr_onacquire' as your
// OnAcquiredItem script.
ExecuteScript("sbr_onacquire", OBJECT_SELF);

// #2: Set your module OnPlayerRest script to "sbr_onrest".

// #3: Modify OnActivateItem module event script. You can skip this step if you use an activate item script
// that executes a script with the same name as the item tag and you have imported sbr_acttag.erf.
ExecuteScript("sbr_onactivate", OBJECT_SELF);

// #4: Add the kits to some stores and place restful objects in your inns.

// #5: (optional) Create a journal entry that explains the rest system and give
// it to players when they enter the module. A sample journal entry is provided
// in this documentation.

// #6: (optional) You can extend the rest system by handling the SBR_EVENT_REST
// in the module OnUserDefined event. You could easily add a wandering monster system,
// a "dream plane" or have cutscenes play when resting in specific areas.
// Read more about the OnUserDefined event at:
// http://www.reapers.org/nwn/reference/compiled/event.OnUserDefined.html
// SBR_EVENT_REST is defined in the sbr_include script.



****************************************************************************
CONFIGURATION
****************************************************************************

Configuration settings can be found in 'sbr_include'.

Always recompile your module after modifying sbr_include because it is an include file.
#1: Select "Build" from the toolset menu and then choose "Build Module".
#2: Click the "Advanced Controls" box to bring up the advanced options.
#3: Make sure that the only boxes that are selected are "Compile" and "Scripts".
#4: Click the "Build" button.
#5: Remember to always make sure you are using the options you want to use when running "Build Module"!

// The variable below sets up how the DM Rest widget is configured.
// Change this to true to only toggle rest module wide rather
// than using the 3 different level options.
// If this is TRUE clicking the ground, yourself or a player will
// toggle the Module level rest restriction.
// If FALSE, then you have 3 options.
//    Target yourself = Module level toggle.
//    Target ground (ie the area) = Area level toggle.
//    Target player = Party level toggle.
//
// In either mode, targeting an NPC or other placeable will report
// all pertinent rest system information to you.
const int SBR_MAKE_IT_SIMPLE = FALSE;

// This is the maximum distance the player can be from a "restful object" to
// automatically use it when they hit rest.  *****BUILDERS remember that this does NOT
// account for walls so be careful at inns with bed placement******
const float SBR_DISTANCE = 5.0;

// This is the event number that will be signalled to your module OnUserDefined Event
// when a player rests. This user defined event is how you should extend the system
// so that specific things happen on rest. IE: create some wandering monsters,
// play a cutscene, teleport them to a "dream" area, etc.
const int SBR_EVENT_REST = 2000;



****************************************************************************
PLAYER DOCUMENTATION
****************************************************************************

This module uses Supply Based Rest.

In order to rest you must be near a "Restful Object". These objects have "Restful" in their name: a Restful Bed or a Restful Campsite, for example. You can use a restful object by clicking on it or by pressing the rest button while you are near it.

If you are not near a restful object then you must use a supply kit to build one. Using a supply kit will create a temporary Restful Campsite that will last several minutes. There are two ways to use a supply kit. You can either right click on the kit and activate the item, or you can hit the rest button (or press 'r') twice in rapid succession.

There are two kinds of supply kits: regular kits that anyone can use and woodland kits that are lighter/cheaper but can only be carried by rangers or druids. You cannot carry a woodland kit unless you are a ranger or druid.

Supply kits are quite heavy and quite expensive. This is to encourage players to rest as a group and to encourage players to ration the how often they rest.

Sometimes you will encounter areas that are not secure for rest. This means you must find a safe area (an enclosed room for example) before you can rest.



****************************************************************************
BUILDER NOTES
****************************************************************************
This version will allow you to use the new BioWare rest restriction triggers "on top of" these restrictions.  For example, the rules above will still apply, but you can go the extra step and make players close the door to the room (like the BioWare trigger) just by laying down the standard trigger - all code is included and integrated into the system.  For discussion on this new trigger - see bottom of document.

LogMessage is used for displaying text to players and DMs.  It is scripting package designed by OldManWhistler.  You can configure who receives feedback to almost anything imaginable.  See the actual script for details and see the sbr_include file to see the multitude of options available to you.



****************************************************************************
DM FUNCTIONS
****************************************************************************

1)  DM Rest Widget.  Allows you to have total control over rest in your module.  There are 2 modes: standard and "MAKEITSIMPLE".  In standard mode, if you target your avatar it will toggle rest enable/disable on a module level.  Targeting the ground will toggle rest enable/disable on an area level and targeting a player will toggle rest enable/disable on a party level.  In "MAKEITSIMPLE" mode, targeting the ground, yourself or a player will toggle the module level rest restriction.  Finally, targeting an NPC or placeable will report the rest settings just like clicking a restful bed (see below).

Toggling the module level rest will NOT remove area, or party rest restrictions you set with the widget.  The same goes for area and party restrictions.  They are all INDEPENDENT and ALL must be OFF to allow the player to rest.  You will receive a message why they can't but you could have 3 separate settings to clear if in standard mode.  I included the feature with extra flexibility due to the huge varieties of server set-ups using NWN.  For single party, classic DM adventure - "MAKEITSIMPLE" is the easiest.

To change modes:  Open the sbr_include file and change the "MAKEITSIMPLE" variable to either TRUE or FALSE.  Default is FALSE.  BUILD YOUR MODULE IF YOU CHANGE ANY INCLUDE FILE - at least compile all scripts using the build function.

2)  Rest settings report.  The report has a lot of pertinent information to you to help you keep track of exactly what is the status of the rest system.  You will receive the following information if you use the DM Rest Widget on an NPC/placeable OR if you click on any restful object, :

- Module Rest Setting
- Area Rest Setting
- BW trigger information: is there a Bioware rest trigger in the current area.

The following information is reported based on the nearest player. NOTE:  It uses GetNearestCreature function and therefore will return "No valid player found" if the "nearest" player is in a different area transition.  This is a good feature for PW or other situations with multiple parties.

- Player Rest Setting
- Number of party kits (both woodland and supply kit information).



****************************************************************************
QUESTIONS AND COMMENTS
****************************************************************************

Q: What is the difference between the supply kit and the woodland kit?

A: The woodland kit can be used by rangers and druids.  It attempts to simulate the fact that these classes can find many resources from the land.  Therefore, woodland kits are significantly lighter as these classes will supplement the kit with things from the woods.  The woodlands kits are medium size item and the supply kits are a large item.  Woodland kits are a little bit cheaper too.

NOTE:  If you are NOT a druid or a ranger, the OnAcquire code will drop any woodland kit you attempt to hold or purchase.  This is to avoid other players acting as pack mules for the druid or ranger so that they can use the cheaper kits.  Not exactly "realistic" but forces them to play fair.

If you don't like this added feature of the woodland kit - don't add any to stores and then you do NOT need the sbr_onacquire script.


Q: What do the kits cost?

A:  100 for supply kit and 75 for woodland kit. This is a pretty hefty price tag for a brand new level 1 adventures and therefore you may need to adjust the starting money value (or just give out a few supply kits for "free" when you begin the adventure).  Another option would be to make the players rest in a town or inn until they gain enough money to begin traveling and camping out in the wilderness.


Q: How does this affect game play balance?

A:  The number of kits the players carry ARE the only limit to resting so be careful with not only how much money the players have, but use caution with store inventories and with magical bag or bags of holding.  The kits are large so that only 3 supply kits or 6 woodland kits can fit into a bag of holding but as a designer, it may be important to further ration the kits (The are "rationed" in a sense of the weight and price tag).  I initially had the weight at 50lb for the supply kit but decided that this was too heavy for non-fighter based parties and so I backed the weight down.  You can adjust the weight or price by editing the price in the toolset and then restocking any stores that you have created.


**BW Rest Trigger Commentary and Answers**
Q: What is the deal with the new BW rest triggers?

First off, much of this is opinion, much is fact.  They are not simple and they are not easy to integrate into a module.  They are poorly documented and the documentation contains errors.  In the official campaign there are 2 checks that are performed to rest.  One is area specific and one looks for this trigger.  There are subroutines for both of these checks.  If you do NOT have rest script - the trigger does nothing despite what the comment says.  You should also NOT have the area level "No rest" box checked like it says.  All this being said you can use the idea but it takes custom work on your end as a builder.
How do they work in this system?  Closer to what I expected :) .  In this system, if you lay down a BW rest trigger that ENTIRE AREA becomes a region where the players MUST find a secure region.  It will NOT affect other areas (this is a coding change I made to the trigger subroutine - by default one BW trigger negated resting throughout the entire module without adding more code other places).  That is it.  The trigger must contain one door.  You could still use the "no rest" box in the area properties to disallow rest everywhere in the area at all times.
I hated to have to include this long explanation but thought it would save me time and effort in the long run of answering a lot of questions related to this system.



****************************************************************************
CONCLUSION
****************************************************************************

As a builder, I find the system easy to install and very flexible.  I think it is straightforward for players and functions to limit rest in a way that allows the players to decide when, where, and how they want it to happen while the final decision to "how many times" is left to the builder when they place the objects and supplies.

Special thanks to Mogney, Dick Nervous, and JohhnyB for play testing, feedback, and fine tuning of the concept.

Demetrious



****************************************************************************
CHANGELOG
****************************************************************************

v1.1 to v1.2
- Cosmetic module changes: made the signs, door and merchants plot so they couldn't be destroyed and screw up the tutorial.
- Revamped the documentation and installation instructions.
- Changed "IsDM" checks to check for DMPossessed creatures. The system will treat DM possessed creatures the same as DMs.
- Added a module OnUserDefined event for players resting so that you can easily extend the rest system without touching the code.
- Changed interface so that players have to hit 'r' or the rest button twice to enable the "automatically use supply" feature. In live play some players would accidently hit R because they forgot to press enter before they started typing. This solves that issue.
- Hitting the rest button when you are near a "restful" object will automatically use that restful object instead of a kit. In live play some players who were not used to the system would try a normal rest and accidently use another kit. This solves that issue.
- Changed it so that woodland kits are not destroyed when picked up by non-ranger/druids. Now they will be dropped. In live play some players would accidently destroy woodland kits by picking them up. This solves that issue.
- Modified the store conversations to reflect the changes.
- Version 1.1 was tagged as requiring SoU. Version 1.2 can be used by anyone -- regardless of whether they have SoU.
*/
