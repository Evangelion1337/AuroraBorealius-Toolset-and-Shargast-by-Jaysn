/*  +================================================+
    +==========   Builders' Compendium     ==========+
    +===                                          ===+
    +===   A 1st Order of Role-Players' Creation  ===+
    +==========      www.1stOrder.net      ==========+
    +================================================+



            To use: #include "zep_inc_1st_rp"

            NO OTHER FILES ARE INCLUDED BY THIS ONE

    1st Order of Role-Players' Library of odd, yet useful functions
    Author - TheExcimer-500  with lots of advice & playtesting by our guild members
                             particular thanks to GrendelsBathMat, Hamza al-Assad, and Cherenzig

    To find out more about the 1st Order of Role-Players' Guild, visit us
    at our website www.1stOrder.net

*/




/* List of Functions
        ACTIONS
A1st_EquipItem
A1st_SitInNearestChair

        RETURNS AN OBJECT
o1st_GetNearestPC
o1st_GetNearestPCinRadius
o1st_GetNearestNPC
o1st_GetNearestNPCinRadius
o1st_RespawnNPC
o1st_CopyNPC
o1st_GetObjectInInventory

        RETURNS A FLOATING NUMBER
f1st_GetSpeed_PercentChange
f1st_DegreesToRadians
f1st_RadiansToDegrees
f1st_GetXYDirectionBetween
f1st_GetXYDistanceBetween
f1st_GetZDistanceBetween
f1st_SendMessageToParty
f1st_GetSpeed_PercentChange

        RETURNS A STRING
s1st_PCGetVarName
s1st_PCGetVarNameShort
s1st_Get_2DAModelName

        RETURNS AN INTEGER
n1st_GetIsPCLeader
n1st_GetHasClass
n1st_GetAnimalReactionToPC
n1st_GetIsStackableItem
n1st_VFXNo_Color
n1st_AnimNo
n1st_SkillNo
n1st_GetIsSameFactionAs
n1st_GetHasEffectOfType
n1st_GetNumberOfEffectOfType
n1st_GetNumberPartyMembers
n1st_CheckIsItemMagical
n1st_2DA_Check
n1st_Get_2DARow
n1st_HasItemInInventory

        DOES NOT RETURN A VALUE
X1st_CopyInventory
X1st_CopyInventoryEq
X1st_CopyNPC
X1st_RemoveAllPartyMembers
X1st_AddAllPCsInAreaToParty
X1st_GameTimeDelayScript
X1st_CopyItem_Delay
X1st_Copy_DelayDestroyObject
X1st_CreateItem_Delay
X1st_CopyObject_Delay
X1st_GiveGoldToAllEqually
X1st_MakeCutsceneInvisible
X1st_DestroyAllItems
X1st_DestroyAllItems_NotDMFI
X1st_DestroyDMFIItems
X1st_GiveDMFIItems
X1st_Give1ORPItems
X1st_RespawnNPC
X1st_JumpPCPartyToObject
X1st_JumpAllPCsInAreaToObject
X1st_Item_DestroyNonEquiped
X1st_Item_DestroyOnlyEquiped
X1st_Inventory_IDAllItems
X1st_Faction_ClearFactionReputation
X1st_GameTimeDelayScript
x1st_Effect_RemoveType
*/


/////////FUNCTION DECLARATIONS\\\\\\\\\\\\\

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Converts degrees into radians (Returns float value)
float f1st_DegreesToRadians(float degrees);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Converts radians into degrees (Returns float value)
float f1st_RadiansToDegrees(float radians);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Get the XY plane direction from one object to another (regardless of height differences)
// The direction will be from oFrom's perspective looking at oPointsTo.
// Use this with SetFacing to have oFrom turn to face oPointsTo
float f1st_GetXYDirectionBetween(object oFrom, object oPointsTo);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//When dealing with objects at different heights, GetDistanceBetween will give you the
//real distance between the objects. Our GetXYDistance will give you the distance between
//them in the XY-Plane (hence it doesn't take into account the height difference).
//This is an absolute value (non-negative), and the order of the objects will not matter.
float f1st_GetXYDistanceBetween(object oObject1, object oObject2);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Returns the height difference of one object (oObjectTo) compared to another (oObjectFrom)
//This can be positive or negative as objectTo can be above or below oObjectFrom.
//Returns a Float value. If you only want a positive value, use the "fabs" FloatAbsolute Bioware Function
float f1st_GetZDistanceBetween(object oObjectFrom, object oObjectTo);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Returns a unique string based on the legal letters of the character's name, and the CD Key
//Useful for local and campaign variables. Maximum string length is 30 characters (22 for char.name + 8 CD Key).
//Important Note: If you are not logged in (i.e. playing in Single-Player Mode) then this
//will only return the legal characters of the PC's Name, it will not include the CD KEy.
//ALSO NOTE: this string length is 30 character, the maximum variable string length of Databases is 32!
//           use s1st_PCGetVarNameShort(object oPC) for a shorter version.
string s1st_PCGetVarName(object oPC);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Returns a unique string based on the legal letters of the character's name, and the CD Key
//Useful for local and campaign variables. Maximum string length is 26 characters (18 for char.name + 8 CD Key).
//Important Note: If you are not logged in (i.e. playing in Single-Player Mode) then this
//will only return the legal characters of the PC's Name, it will not include the CD KEy.
//ALSO NOTE: Campaign Variable Names can have a maximum length of 32 characters, Local Variables
//"suppose-ably" (Yay Joey) do not have this limit. Since only 18 letters from the character name are used
//it's possible that the same player (same CD key) could have two characters with the same first 18 letters!
//thus you might want to use the slightly longer s1st_PCGetVarName(opc) function instead.
string s1st_PCGetVarNameShort(object oPC);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//A simple True/False returning function to check if the PC has a specific class (defined by
//CLASS_TYPE_ constants), and if it has at least nLevel in it.
//Thus if you wanted to test if the character was an 8th level wizard if(nPC_Has_Class(oPC, CLASS_TYPE_WIZARD,8)==TRUE)
int n1st_GetHasClass(object oPC, int nClassType, int nLevel=1);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This returns an animal's reaction value based upon the PC.
//It returns values from 2 (Strong Dislike/Fear/Hate) to 9 (Like/Accepting)
//The initial check is for TAME animals, however it can be adjusted through
//setting a local variable on the animal:
// This variable should be set on the animal if it differs from Tame.
//    Variable Name   Type     Values    Description
//    nReaction       int         0      Animal is TAME (Checks need to be made. Easy for Rangers/Druids)
//                                1      Animal is Always Friendly to Druids/Rangers (else TAME for checks on others)
//                                2      Animal is Always Friendly to all PCs (no Checks)
//                                3      Animal is WILD (Difficult Checks - probably only Rangers/Druids will pass - or someone with a lot of sugar cubes)
int n1st_GetAnimalReactionToPC(object oPC, object oAnimal);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Returns TRUE if item is one that is stackable (i.e. bullets, arrows, etc.)
//Returns FALSE if not (i.e. Dwarven Waraxe)
int n1st_GetIsStackableItem(object oItem);


//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Copies the inventory from one object to another.
void X1st_CopyInventory(object oCopyFrom, object oCopyTo);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Copies the inventory from one object to another & Equips if equipped on oCopyFrom.
void X1st_CopyInventoryEq(object oCopyFrom, object oCopyTo);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This function when called will create a copy of an object
//if fDelayDestroy is set, that object will be destroyed at that time
//Useful for when you want to Delay the copying of an object that
//will be destroyed at some time later (i.e. for Cutscenes :D)
// If an owner is specified and the object is an item, it will be put into their inventory
// If the object is a creature, they will be created at the location.
// If a new tag is specified, it will be assigned to the new object.
void X1st_Copy_DelayDestroyObject(object oSource, location lLoc, float fDelayDestroy, object oOwner = OBJECT_INVALID, string sNewTag="");

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This function acquires either the LIGHT VFX# or the GLOW VFX# for
//a string sent to it specifying the color and what type.
//sColor syntax for LIGHT VFXs: Color_#, where # is intensity
//Valid <Color> for LIGHT VFXs: White, Yellow, Orange, Red, Green, Blue, Purple
//____note - green calls a GREY lighting effect which is green for some inscrutible reason)
//Valid Intensity #s for LIGHT VFXs: 5, 10, 15, 20 are the available radii.
//____
//sColor syntax for GLOW VFXs: Color_ss, where ss is either LT or RG and refers to the Light version of the glow
//____________________________or the regular version (i.e. light blue is Blue_LT, and regular blue is BLUE_RG)
//Valid <Color> for GLOW VFXs: Purple, Red, Yellow, Green, Orange, Brown, Gray & white.
//
//Notes: upper/lower case doesn't matter, and it only looks at the first and
//______last two "letters" of the string. Hence you can abbreviate the color (i.e. Yellow can be just YE)
//______The exception to this is Gray (or grey). This must be fully spelled out (either way)
//______There is also no Light version of the Glow Gray or White. However, you must use
//______either LT or RG anyway! ex. GREY_LT, WHITE_RG, WH_RG.
int n1st_VFXNo_Color(string sColor);


//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This function returns the Animation # given just the last part of the
//Animation constant... i.e. n1st_AnimNo(Bow) will return ANIMATION_FIREFORGET_BOW
//It will return the looping version if both fireforget/looping versions exist.
//i.e. n1st_AnimNo(spasm) will return ANIMATION_LOOPING_SPASM and not ANIMATION_FIREFORGET_SPASM
//Also note - upper/lower case does not matter.
//If no match is made, it will return -1.
//CONJURE1, CONJURE2, DEAD_BACK, DEAD_FRONT, GET_LOW, GET_MID, LISTEN, LOOK,
//MEDITATE, PAUSE, DRUNK, TIRED, PAUSE2, SIT, SIT_CHAIR, SPASM, TALK, LAUGH,
//PLEAD, WORSHIP, BOW, DUCK, DODGE, WAVES, LOOK_LEFT, LOOK_RIGHT, BORED, SCRATCH_HEAD
//READ, SALUTE, STEAL, STRETCHES, VICTORY, VICTORY2, VICTORY3, TALK_FORCEFUL (or ARGUE)
int n1st_AnimNo(string sAnim);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This function returns the SKILL_ constant given a string input
//Use: Animal_Empathy (or Animal), Appraise, Bluff, Concentration, Craft_Armor (or Armor), Craft_Trap,
//     Craft_Weapon (or Weapon), Disable_Trap, Discipline, Heal, Hide, Intimidate, Listen,
//     Lore, Move_Silently (or Silently or Silent), Open_Lock (or Lock), Parry, Perform, Persuade, Pick_Pocket,
//     Search, Set_Trap, Spellcraft, Spot, Taunt, Tumble, Use_Magic_Device (or Magic_Device)
// Upper/Lower case doesn't matter. Useful for variables :)
int n1st_SkillNo(string sSkill);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Returns true if oMember1 is in the same faction (or PC Party) as oMember2
//I really thought there was a function to do this already, but
//alas I couldn't find it. -- b-mail TheExcimer-500 if one already exists, please.
//FYI - this loops through oMember1's entire faction looking for oMember2.
//Thus you should use the smaller faction (if known) for oMember1 ;)
int n1st_GetIsSameFactionAs(object oMember1, object oMember2);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Breaks up the entire party (except for henchmen/familiars/companions
//hopefully these stay with their Master - someone needs to verify this)
void X1st_RemoveAllPartyMembers(object oPC);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Adds all PCs in the same area as oPC to oPC's party. NOTE this does not
//Remove any PCs from oPC's original PARTY
//!!!BUT!!!  It will break up a PC in that area from its party.
void X1st_AddAllPCsInAreaToParty(object oPC);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//returns true if oTarget has an effect specified by an EFFECT_TYPE_...
int n1st_GetHasEffectOfType(object oTarget, int nEffectTypeConst);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//returns the number of effects of the type specified
int n1st_GetNumberOfEffectOfType(object oTarget, int nEffectTypeConst);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Allows a delayed execution of a script on an object using
//"Game Time" as opposed to realtime (which you should just use DelayCommand(float, ExecuteScript...)
//
//  This function checks the time remaining and runs itself again as follows:
//  Under 5  Game Minutes     -> Every 12 Real Seconds
//  Under 1  Game Hours       -> Every 30 Real Seconds
//  Under 6  Game Hours       -> Every Real Minute.
//  Less than 1 Day           -> Every 5.0 Real Minutes
//  Greater than 1 Day        -> Every 12 Real Minutes.
//  Greater than 1 Month      -> Every 30 Real Minutes.
//
// IMPORTANT NOTE: You can run multiple delays of the same script on the same object
//                 ONLY IF it has a different delay time specified in seconds (regardless of the start time of the script).
//                 Good Example: X1st_GameTimeDelayScript("same", GetFirstPC(), 0, 5, 0, 0);  and X1st_GameTimeDelayScript("same", GetFirstPC(), 0, 5, 0, 1);
//                 BadExample: X1st_GameTimeDelayScript("same", GetFirstPC(), 0, 1, 0, 0);  and X1st_GameTimeDelayScript("same", GetFirstPC(), 0, 0, 60,0);
//                            Bad b/c 1 hour = 60 minutes, hence it's the same time in seconds.
//
//      The reason for this is that this function creates a Count-down Identifier based
//          on the script name and the # of total time (in seconds) when it is first called.
//          Thus in the Good Example the variable names will be based upon "same18000" for the first call and
//          "same18001" for the second call. For the bad example both will led to "same3600".
//
// Variable names must be kept to 32 characters. The ones generated in this script use the following syntax:
// @@<script_name><sec>  where @@ are two character headers.
// Since 1 year in seconds leads to 8 character places, this leaves script names up to 22 characters
// that can be used for objects. Since scripts can only be 16 characters, we're safe :) Heck I might just go crazy and add another character to the header - you watch me now!
void X1st_GameTimeDelayScript(string sScript, object oTarget, int nDays, int nHours=0, int nMinutes=0, int nSeconds=0, int nMonths=0);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This is a quick GetNearestCreature function, without all the confusing lines\\
// oBJ  => object to find the nearest PC (notDM) to
// nNth => 1st nearest PC, 2nd nearest PC, ...
// Those that use this (two line function) that uses the one line Bioware function are just plain nuts (like me).
//                  But so far 10 out of 10 times, I've had to look up the function on the lexicon. Too many choices makes me confused...
object o1st_GetNearestPC(int nNth=1, object oOBJ=OBJECT_SELF);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This is a quick GetNearestCreature function, without all the confusing lines\\
// oBJ  => object to find the nearest NPC to
// nNth => 1st nearest NPC, 2nd nearest NPC, ...
// Those that use this (two line function) that uses the one line Bioware function are just plain nuts (like me).
//    But so far 10 out of 10 times, I've had to look up the function on the lexicon. Too many choices makes me confused...
object o1st_GetNearestNPC(int nNth=1, object oOBJ=OBJECT_SELF);


//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//A command to simplify executing a script on all PCs in area
//ACK - NOPE not doing this one yet.
//void X1st_ExecuteScriptOnAllPCsInArea(string sScript, object oArea, int nDM = FALSE);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//A Delayed CopyItem function.
//oSource is the Item you want to copy (NOTE this is ITEM - if you're using this on a creature, don't blame me.)
//oOwner - This with either be created in oOwner's inventory (if it has one), or at the owner's location (like a waypoint)
//nCopyLocalVariables => Well that's long enough to explain what it does. If the item has local variables stored on it, it'll copy them onto the new item
//nDontUse => LEAVE IT ALONE! This is the secret to how this function works.
//            Ok - if you set it equal to TRUE, then this function ignore the delay - hence it's just CopyItem.
void X1st_CopyItem_Delay(float fDelay, object oSource, object oOwner, int nCopyLocalVariables=TRUE,int nDontUse=FALSE);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//A Delayed CreateItem function. (NOTE - with CreateObjectVoid you can't place the object in the inventory)
//sResRef is the ResRef of the Item you want to create (NOTE this is ITEM - if you're using this on a creature, don't blame me.)
//oOwner - This with either be created in oOwner's inventory (if it has one), or at the owner's location (like a waypoint)
//nDontUse => LEAVE IT ALONE! This is the secret to how this function works.
//            Ok - if you set it equal to TRUE, then this function ignore the delay - hence it's just CreateItemOnObject.
void X1st_CreateItem_Delay(float fDelay, string sResRef, object oOwner, int nDontUse=FALSE);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//A Delayed CopyObject function.
//sTAG is the tag of the object you want to copy
//lLOC - The location which this object will be placed  (remember GetLocation(oWP) :)
//nDontUse => LEAVE IT ALONE! This is the secret to how this function works.
//            Ok - if you set it equal to TRUE, then this function ignore the delay - hence it's just CreateItemOnObject.
void X1st_CopyObject_Delay(float fDelay, string sTag, location lLOC, int nDontUse=FALSE);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Returns the CORRECT number of members in the PC's party (including the PC)
//Bioware's GetNumberPartyMembers(object oPC) function returns 1 too many (oddly enough that looks like it's on purpose)
//If you want to include the associates of the PC then set the second condition to TRUE. (Associates are familiars, henchmen...)
int n1st_GetNumberPartyMembers(object oPC,int Include_Associates=FALSE);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Gives the correct amount of gold ot all in the PC's party
//nTotalGoldToDivvyUp => the total amount of gold which will be evenly divided up by the
//                       number of party members.
//NOTE - you can use a negative amount for nTotalGoldToDivvyUp to remove gold from each member :)
void X1st_GiveGoldToAllEqually(object oPC, int nTotalGoldToDivvyUp);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Applies the visual effect for Cutscene Invisible and sets/removes an int
//on the PC to cancel perception of the PC by the NPCs using our script set
void X1st_MakeCutsceneInvisible(object oPC, float fDuration);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//Destroys all items in the container (works for PCs as well)
void X1st_DestroyAllItems(object oContainer);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This will strip the PC of all items except DMFI & 1ORP widgets
void X1st_DestroyAllItems_NotDMFI(object oPC);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This will remove any DMFI/1ORP widgets from a container (or PC)
void X1st_DestroyDMFIItems(object oContainer);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This will give appropriate DMFI Items
//It does include base race/class languages, but not additional Languages due to INT
void X1st_GiveDMFIItems(object oPC);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This will give the 1ORP items
void X1st_Give1ORPItems(object oPC);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This Action Command attempts to equip an item to an appropriate slot
void A1st_EquipItem(object oNPC, object oItem);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This action Copies the NPC at the same location
//if sNewTag is not specified, the new NPC will have the same tag as the old one.
//How it works: 1) Ghosts original; 2) Copies original; 3) destroys original
//The Bad news: Copy Object DOES NOT copy the local variables!
//The Good news: This function will look for the common variables 1ORP and NPCActivities use
//and will copy them. Thus you can change these variables (listed below) on the Original first,
//and then use this function.
//1ORP Variables copied: nSpawnStatue, nSpawnRaiseable, nSpawnDeadRaise, nSpawnDead, nBlood, & nSpawnHorse
//
//NPCActivities variables copied: nGNBStateSpeed, nWrap_Mode, bGNBQuickMove
//At this time the NPCActivities Conversations are not copied - sorry.
//You can also change the new NPC's AI level using the Constants AI_LEVEL_XXX
void X1st_RespawnNPC(object oNPC, string sNewTag="", int nAI=AI_LEVEL_DEFAULT);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This action Copies the NPC at the same location & returns the new creature
//if sNewTag is not specified, the new NPC will have the same tag as the old one.
//How it works: 1) Ghosts original; 2) Copies original; 3) destroys original
//The Bad news: Copy Object DOES NOT copy the local variables!
//The Good news: This function will look for the common variables 1ORP and NPCActivities use
//and will copy them. Thus you can change these variables (listed below) on the Original first,
//and then use this function.
//1ORP Variables copied: nSpawnStatue, nSpawnRaiseable, nSpawnDeadRaise, nSpawnDead, nBlood, & nSpawnHorse
//
//NPCActivities variables copied: nGNBStateSpeed, nWrap_Mode, bGNBQuickMove
//At this time the NPCActivities Conversations are not copied - sorry.
//You can also change the new NPC's AI level using the Constants AI_LEVEL_XXX
object o1st_RespawnNPC(object oNPC, string sNewTag="", int nAI=AI_LEVEL_DEFAULT);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This action Copies the NPC returns the new creature as an object
//if sNewTag is not specified, the new NPC will have the same tag as the old one.
//if lLoc is invalid, the NPC will spawn at the same location as the original.
//Unlike our Respawn versions, CopyNPC does not destroy the original!
//The Bad news: Copy Object DOES NOT copy the local variables!
//The Good news: This function will look for the common variables 1ORP and NPCActivities use
//and will copy them. Thus you can change these variables (listed below) on the Original first,
//and then use this function.
//1ORP Variables copied: nSpawnStatue, nSpawnRaiseable, nSpawnDeadRaise, nSpawnDead, nBlood, & nSpawnHorse
//
//NPCActivities variables copied: nGNBStateSpeed, nWrap_Mode, bGNBQuickMove
//At this time the NPCActivities Conversations are not copied - sorry.
//You can also change the new NPC's AI level using the Constants AI_LEVEL_XXX
object o1st_CopyNPC(object oNPC, location lLoc, string sNewTag="", int nAI=AI_LEVEL_DEFAULT);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This action Copies the NPC
//if sNewTag is not specified, the new NPC will have the same tag as the old one.
//if lLoc is invalid, the NPC will spawn at the same location as the original.
//Unlike our Respawn versions, CopyNPC does not destroy the original!
//The Bad news: Copy Object DOES NOT copy the local variables!
//The Good news: This function will look for the common variables 1ORP and NPCActivities use
//and will copy them. Thus you can change these variables (listed below) on the Original first,
//and then use this function.
//1ORP Variables copied: nSpawnStatue, nSpawnRaiseable, nSpawnDeadRaise, nSpawnDead, nBlood, & nSpawnHorse
//
//NPCActivities variables copied: nGNBStateSpeed, nWrap_Mode, bGNBQuickMove
//At this time the NPCActivities Conversations are not copied - sorry.
//You can also change the new NPC's AI level using the Constants AI_LEVEL_XXX
void X1st_CopyNPC(object oNPC, location lLoc, string sNewTag="", int nAI=AI_LEVEL_DEFAULT);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This function Jumps the PC & its entire Party to an Object (such as a waypoint)
//This could also be used to jump all NPCs of a faction to the object.
void X1st_JumpPCPartyToObject(object oPC, object oWP);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This function Jumps all PCs in an area to an Object (such as a waypoint)
void X1st_JumpAllPCsInAreaToObject(object oArea, object oWP);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This function will have oCreature attempt to sit in the nearest available chair/couch/bench...
//A search is created for all objects within a radius of fDist from the Creature (10.0m=1side of an area's square)
//If it finds an unoccupied object which has one of the catch phrases below as part of it's tag
//It will have the creature move to that object and sit in it. Alternatively, you can
//specify your own phrase.
//
// The following phrases must be a part of the object's tag, unless you state otherwise:
//      chair, couch, bench, throne, stool
//These cover all the default CEP/BW objects - it is not case sensitive, and your tag
//can have other letters in it. For example the following Tags all satisfy the search:
//"redchair", "RedChair", "couchend", "EvilThroneofDoom", "throneup" etc...
//Also Note that the chair need not be usable & can even be STATIC!!!
void A1st_SitInNearestChair(object oCreature, float fDist=10.0, string sPhrase = "all");

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This will strip the PC or Container of all Items (non-equipped) including DMFI & 1orpWidgets
void X1st_Item_DestroyNonEquiped(object oContainer);

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This will strip the PC or NPC of all Equipped Items
void X1st_Item_DestroyOnlyEquiped(object oContainer);


//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This will ID All items in the PC,NPC or Container
void X1st_Inventory_IDAllItems(object oContainer);










/////////FUNCTION DEFINITIONS\\\\\\\\\\\\\

//////////////////////\\\\\\\\\\\\\\\\\\\\\\\\
/////////f1st_DegreesToRadians\\\\\\\\\\\\\
//////////////////////\\\\\\\\\\\\\\\\\\\\\\\\
float f1st_DegreesToRadians(float degrees)
{
  float Radians = (2.0*PI*degrees)/360.0;
  return Radians;
}

//////////////////////\\\\\\\\\\\\\\\\\\\\\\\\
/////////f1st_RadiansToDegrees\\\\\\\\\\\\\
//////////////////////\\\\\\\\\\\\\\\\\\\\\\\\
float f1st_RadiansToDegrees(float radians)
{
 float Degrees =(radians*360.0)/(2.0*PI);
 return Degrees;
}


//////////////////////\\\\\\\\\\\\\\\\\\\\\\\\
///////f1st_GetXYDirectionBetween\\\\\\\\\\
//////////////////////\\\\\\\\\\\\\\\\\\\\\\\\
float f1st_GetXYDirectionBetween(object oFrom, object oPointsTo)
{
 vector vOFrom = GetPosition(oFrom);
 vector vOTo = GetPosition(oPointsTo);
 vector vFrom = Vector(vOFrom.x, vOFrom.y,0.0);
 vector vTo = Vector(vOTo.x, vOTo.y,0.0);
 float fDirection = VectorToAngle(vTo-vFrom);
 return fDirection;
}

//////////////////////\\\\\\\\\\\\\\\\\\\\\\\\
////////f1st_GetXYDistanceBetween\\\\\\\\\\
//////////////////////\\\\\\\\\\\\\\\\\\\\\\\\
float f1st_GetXYDistanceBetween(object oObject1, object oObject2)
{
 vector vWPCAM = GetPosition(oObject2);
 vector vWPPC = GetPosition(oObject1);
 vector v1 = Vector(vWPCAM.x, vWPCAM.y,0.0);
 vector v2 = Vector(vWPPC.x, vWPPC.y,0.0);
 float fDistance = fabs(VectorMagnitude(v1-v2));
 return fDistance;
}

//////////////////////\\\\\\\\\\\\\\\\\\\\\\\\
////////f1st_GetZDistanceBetween\\\\\\\\\\\
//////////////////////\\\\\\\\\\\\\\\\\\\\\\\\
float f1st_GetZDistanceBetween(object oObjectFrom, object oObjectTo)
{
   vector vWPCAM = GetPosition(oObjectTo);
   vector vWPPC = GetPosition(oObjectFrom);
   vector v1h = Vector(0.0,0.0,vWPCAM.z);
   vector v2h = Vector(0.0,0.0,vWPPC.z);
   float fHeight = VectorMagnitude(v1h - v2h); //As far as Lexicon can tell this can be anything.
   return fHeight;
}


//////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//////////////s1st_PCGetVarName(object oPC)\\\\\\\\\\\
//////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\
string s1st_PCGetVarName(object oPC)
{
  //Function by TheExcimer-500 1st Order of Role-Players Guild.
  int i; //A counter -> Per contare
  string sCD = GetPCPublicCDKey(oPC); //8 letters/numbers => 8 lettere o numeri
  string sCharName = GetName(oPC);

  //Look for illegal characters: "space", !@#$%^&*()-`~[]{}\;":'<>,./?123456789     =>Cerchi i caratteri illegali:
  //Take any "legal" characters and form a variable name of length 8(key) + 12 (name)  =>Prenda tutti i caratteri "legali" e formi un nome variabile della lunghezza 8(key) + di 12 (nome)
  string sBad = " !@#$%^&*()-`~[]{}\;:'<>,./?123456789|-+=";
  string sGood = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"; //A better way to do it ;)
  string sVarName;
  int nCharName = GetStringLength(sCharName);
  string sLetter;

  for (i=0;i<nCharName;i++)  //Search through each letter of the name. Add only if it's legal. => Ricerca attraverso ogni lettera del nome. Aggiunga soltanto se è legale.
   {
     sLetter = GetStringUpperCase(GetSubString(sCharName, i, 1));
     if (FindSubString(sGood, sLetter) !=-1 ) {sVarName = sVarName + sLetter;}
   }

  //Next I only want the first 30 legal characters.   => Dopo desidero soltanto i primi 30 caratteri legali.
  if (GetStringLength(sVarName)>30) {sVarName = GetStringLeft(sVarName, 22);}
  sVarName =sVarName + sCD;
  return sVarName;
}

//////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//////////////s1st_PCGetVarNameShort(object oPC)\\\\\\\\\\\
//////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\
string s1st_PCGetVarNameShort(object oPC)
{
  //Function by TheExcimer-500 1st Order of Role-Players Guild.
  int i; //A counter -> Per contare
  string sCD = GetPCPublicCDKey(oPC); //8 letters/numbers => 8 lettere o numeri
  string sCharName = GetName(oPC);

  //Look for illegal characters: "space", !@#$%^&*()-`~[]{}\;":'<>,./?123456789     =>Cerchi i caratteri illegali:
  //Take any "legal" characters and form a variable name of length 8(key) + 12 (name)  =>Prenda tutti i caratteri "legali" e formi un nome variabile della lunghezza 8(key) + di 12 (nome)
  string sBad = " !@#$%^&*()-`~[]{}\;:'<>,./?123456789|-+=";
  string sGood = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"; //A better way to do it ;)
  string sVarName;
  int nCharName = GetStringLength(sCharName);
  string sLetter;

  for (i=0;i<nCharName;i++)  //Search through each letter of the name. Add only if it's legal. => Ricerca attraverso ogni lettera del nome. Aggiunga soltanto se è legale.
   {
     sLetter = GetStringUpperCase(GetSubString(sCharName, i, 1));
     if (FindSubString(sGood, sLetter) !=-1 ) {sVarName = sVarName + sLetter;}
   }

  //Next I only want the first 18 legal characters.   => Dopo desidero soltanto i primi 30 caratteri legali.
  if (GetStringLength(sVarName)>30) {sVarName = GetStringLeft(sVarName, 18);}
  sVarName =sVarName + sCD;
  return sVarName;
}

///////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//                                     n1st_GetHasClass
///////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

int n1st_GetHasClass(object oPC, int nClassType, int nLevel=1)
{
 if (GetLevelByClass(nClassType, oPC) >= nLevel) {return TRUE;}
 return FALSE;
}
///////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


///////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//                                    n1st_GetIsPCLeader
///////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

int n1st_GetIsPCLeader(object oPC)
{
   int iResult=FALSE;
   if (oPC==GetFactionLeader(oPC)){iResult==TRUE;}
   return iResult;
}
///////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

/////////////////////////\\\\\\\\\\\\\\\\\\\\\
//////////////nPC_GetAnimalReaction\\\\\\\\\\\
////////////////////////\\\\\\\\\\\\\\\\\\\\\\
int n1st_GetAnimalReactionToPC(object oPC, object oAnimal)
{
  int nPCReaction;
  int nReaction = GetLocalInt(oAnimal, "nReaction");
  nPCReaction = GetSkillRank(SKILL_ANIMAL_EMPATHY, oPC)/2 + GetAbilityModifier(ABILITY_CHARISMA, oPC);
  if (nReaction ==3) {nPCReaction-=4;}
  if (nPCReaction<2){nPCReaction=2;}
  if (nPCReaction>9){nPCReaction=9;}
  return nPCReaction; //Value of 1-10 (Hates -> Loves)    => Value di 1-10 (avversioni - amori)

/* This variable should be set on the animal if it differs from Tame.
    Variable Name   Type     Values    Description
    nReaction       int         0      Animal is TAME (Checks need to be made. Easy for Rangers/Druids)
                                1      Animal is Always Friendly to Druids/Rangers (else TAME for checks on others)
                                2      Animal is Always Friendly to all PCs (no Checks)
                                3      Animal is WILD (Difficult Checks - probably only Rangers/Druids will pass - or someone with a lot of sugar cubes)


  An nPCReaction value of 1 means the horse will not respond. This value is saved for any cruelty the PC inflicts on it and it is not used as an initial reaction
  Likewise a value of 10 means the horse truly loves the PC, which is also reserved for acts of kindness.

  Un valore di 1 significa che il cavallo non risponderà. Questo valore è conservato per tutta
  la crudeltà che il pc infligge su esso e non è usato come reazione iniziale. Inoltre un valore di 10 mezzi
  il cavallo allineare ama il pc, che inoltre è riservato agli atti di bontà.
*/
}

//////////////////////////\\\\\\\\\\\\\\\\\\\\\
//////////////n1st_GetIsStackableItem\\\\\\\\\\
//////////////////////////\\\\\\\\\\\\\\\\\\\\\
int n1st_GetIsStackableItem(object oItem)
{
 int nType = GetBaseItemType(oItem);
 if ( (nType == BASE_ITEM_ARROW) || (nType == BASE_ITEM_BLANK_POTION) || (nType == BASE_ITEM_BLANK_SCROLL) || (nType == BASE_ITEM_BULLET) || (nType == BASE_ITEM_DART)
      || (nType == BASE_ITEM_ENCHANTED_POTION) || (nType == BASE_ITEM_ENCHANTED_SCROLL) || (nType == BASE_ITEM_GEM) || (nType == BASE_ITEM_GOLD) || (nType == BASE_ITEM_GRENADE)
      || (nType == BASE_ITEM_HEALERSKIT) || (nType == BASE_ITEM_POTIONS) || (nType == BASE_ITEM_SCROLL) || (nType == BASE_ITEM_SHURIKEN) || (nType == BASE_ITEM_BOLT)
       || (nType == BASE_ITEM_THIEVESTOOLS))
 {return TRUE;}
 return FALSE;
}

//////////////////////////\\\\\\\\\\\\\\\\\\\\\
///////////////////X1st_CopyInventory\\\\\\\\\\
//////////////////////////\\\\\\\\\\\\\\\\\\\\\
void X1st_CopyInventory(object oCopyFrom, object oCopyTo)
{

  if (oCopyFrom==oCopyTo){PrintString("********ERROR**********"); PrintString("X1st_CopyInventory Function - oCopyFrom=oCopyTo not allowed");return;}
  if ( (GetIsObjectValid(oCopyFrom)==FALSE)|| (GetIsObjectValid(oCopyTo)==FALSE)
        ||(GetHasInventory(oCopyFrom) ==FALSE) || (GetHasInventory(oCopyTo)==FALSE) )
            {PrintString("********ERROR**********"); PrintString("X1st_CopyInventory Function - COPY ERROR not allowed");return;}

  object oItem; object oCopy;

  //First cycle through the items equipted.
  int i = 0;
  for (i=0;i<NUM_INVENTORY_SLOTS;i++)
   {
    oItem = GetItemInSlot(i,oCopyFrom);
    if (GetIsObjectValid(oItem)==TRUE)
     {
       oCopy = CopyItem(oItem,oCopyTo,TRUE);
       SetLocalInt(oItem,"nCopiedOver",1);
     }
   }

  oItem = GetFirstItemInInventory(oCopyFrom);
  while (GetIsObjectValid(oItem) == TRUE)
   {
    if (GetLocalInt(oItem,"nCopiedOver")!=1){CopyItem(oItem, oCopyTo, TRUE);}
    DeleteLocalInt(oItem,"nCopiedOver");
    oItem = GetNextItemInInventory(oCopyFrom);
   }

}

//////////////////////////\\\\\\\\\\\\\\\\\\\\\
///////////////////X1st_CopyInventoryEq\\\\\\\\\\
//////////////////////////\\\\\\\\\\\\\\\\\\\\\
void X1st_CopyInventoryEq(object oCopyFrom, object oCopyTo)
{
  if ( (GetIsObjectValid(oCopyFrom)==FALSE)|| (GetIsObjectValid(oCopyTo)==FALSE)
        ||(GetHasInventory(oCopyFrom) ==FALSE) || (GetHasInventory(oCopyTo)==FALSE) )
            {return;}
  object oItem;
  object oCopy;

  //First cycle through the items equipted.
  int i = 0;
  for (i=0;i<NUM_INVENTORY_SLOTS;i++)
   {
    oItem = GetItemInSlot(i,oCopyFrom);
    if (GetIsObjectValid(oItem)==TRUE)
     {
       oCopy = CopyItem(oItem,oCopyTo,TRUE);
       AssignCommand(oCopyTo, ActionEquipItem(oCopy,i));
       SetLocalInt(oItem,"nCopiedOver",1);
     }
   }

  oItem = GetFirstItemInInventory(oCopyFrom);
  while (GetIsObjectValid(oItem) == TRUE)
   {
    if (GetLocalInt(oItem,"nCopiedOver")!=1){CopyItem(oItem, oCopyTo, TRUE);}
    DeleteLocalInt(oItem,"nCopiedOver");
    oItem = GetNextItemInInventory(oCopyFrom);
   }
}


///////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\
///////////////////X1st_Copy_DelayDestroyObject\\\\\\\\\\
//////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\
void X1st_Copy_DelayDestroyObject(object oSource, location lLoc, float fDelayDestroy, object oOwner = OBJECT_INVALID, string sNewTag="")
{
 object oCopy = CopyObject(oSource, lLoc, oOwner, sNewTag);
 DelayCommand(fDelayDestroy-1.0, SetPlotFlag(oCopy, FALSE));
 DestroyObject(oCopy, fDelayDestroy);
}


///////////////////\\\\\\\\\\\\\\\\\\\
////////////n1st_VFXNo_Color\\\\\\\\\\
///////////////////\\\\\\\\\\\\\\\\\\\
int n1st_VFXNo_Color(string sColor)
{
 /* This is an adaptation from the zep_inc_main function ColorInit
    I looked but could not find who specifically to thank for that
    so THANKS TO ALL AT CEP once again for everything they've added to NWN
 */
    int    nLight = VFX_DUR_LIGHT;
    string sLeft  = GetStringUpperCase(GetStringLeft(sColor, 2));
    string sRight = GetStringRight(sColor, 2);

    if(sLeft == "BL")
     {
        if(sRight == "_5") nLight = VFX_DUR_LIGHT_BLUE_5;
        if(sRight == "10") nLight = VFX_DUR_LIGHT_BLUE_10;
        if(sRight == "15") nLight = VFX_DUR_LIGHT_BLUE_15;
        if(sRight == "20") nLight = VFX_DUR_LIGHT_BLUE_20;
        if (GetStringUpperCase(sRight) == "RG") {nLight = VFX_DUR_GLOW_BLUE;}
        if (GetStringUpperCase(sRight) == "LT") {nLight = VFX_DUR_GLOW_LIGHT_BLUE;}
     }
    if(sLeft == "GR")
     {  //note: grey lighting is actually green, go figure
        if(sRight == "_5") nLight = VFX_DUR_LIGHT_GREY_5;
        if(sRight == "10") nLight = VFX_DUR_LIGHT_GREY_10;
        if(sRight == "15") nLight = VFX_DUR_LIGHT_GREY_15;
        if(sRight == "20") nLight = VFX_DUR_LIGHT_GREY_20;

        //Gray is handled separately...
        if (GetStringUpperCase(sRight) == "RG") {nLight = VFX_DUR_GLOW_GREEN;}
        if (GetStringUpperCase(sRight) == "LT") {nLight = VFX_DUR_GLOW_LIGHT_GREEN;}
     }
    if(sLeft == "OR")
     {
        if(sRight == "_5") nLight = VFX_DUR_LIGHT_ORANGE_5;
        if(sRight == "10") nLight = VFX_DUR_LIGHT_ORANGE_10;
        if(sRight == "15") nLight = VFX_DUR_LIGHT_ORANGE_15;
        if(sRight == "20") nLight = VFX_DUR_LIGHT_ORANGE_20;
        if (GetStringUpperCase(sRight) == "RG") {nLight = VFX_DUR_GLOW_ORANGE;}
        if (GetStringUpperCase(sRight) == "LT") {nLight = VFX_DUR_GLOW_LIGHT_ORANGE;}
     }
    if(sLeft == "PU")
     {
        if(sRight == "_5") nLight = VFX_DUR_LIGHT_PURPLE_5;
        if(sRight == "10") nLight = VFX_DUR_LIGHT_PURPLE_10;
        if(sRight == "15") nLight = VFX_DUR_LIGHT_PURPLE_15;
        if(sRight == "20") nLight = VFX_DUR_LIGHT_PURPLE_20;
        if (GetStringUpperCase(sRight) == "RG") {nLight = VFX_DUR_GLOW_PURPLE;}
        if (GetStringUpperCase(sRight) == "LT") {nLight = VFX_DUR_GLOW_LIGHT_PURPLE;}
     }
    if(sLeft == "RE")
     {
        if(sRight == "_5") nLight = VFX_DUR_LIGHT_RED_5;
        if(sRight == "10") nLight = VFX_DUR_LIGHT_RED_10;
        if(sRight == "15") nLight = VFX_DUR_LIGHT_RED_15;
        if(sRight == "20") nLight = VFX_DUR_LIGHT_RED_20;
        if (GetStringUpperCase(sRight) == "RG") {nLight = VFX_DUR_GLOW_RED;}
        if (GetStringUpperCase(sRight) == "LT") {nLight = VFX_DUR_GLOW_LIGHT_RED;}
     }
    if(sLeft == "WH")
     {
        if(sRight == "_5") nLight = VFX_DUR_LIGHT_WHITE_5;
        if(sRight == "10") nLight = VFX_DUR_LIGHT_WHITE_10;
        if(sRight == "15") nLight = VFX_DUR_LIGHT_WHITE_15;
        if(sRight == "20") nLight = VFX_DUR_LIGHT_WHITE_20;
        if (GetStringUpperCase(sRight) == "RG") {nLight = VFX_DUR_GLOW_WHITE;}
        if (GetStringUpperCase(sRight) == "LT") {nLight = VFX_DUR_GLOW_WHITE;}
     }
    if(sLeft == "YE")
     {
        if(sRight == "_5") nLight = VFX_DUR_LIGHT_YELLOW_5;
        if(sRight == "10") nLight = VFX_DUR_LIGHT_YELLOW_10;
        if(sRight == "15") nLight = VFX_DUR_LIGHT_YELLOW_15;
        if(sRight == "20") nLight = VFX_DUR_LIGHT_YELLOW_20;
        if (GetStringUpperCase(sRight) == "RG") {nLight = VFX_DUR_GLOW_YELLOW;}
        if (GetStringUpperCase(sRight) == "LT") {nLight = VFX_DUR_GLOW_LIGHT_YELLOW;}
     }

    if (sLeft == "BR") //Brown - Glow only!
     {
        if (GetStringUpperCase(sRight) == "RG") {nLight = VFX_DUR_GLOW_BROWN;}
        if (GetStringUpperCase(sRight) == "LT") {nLight = VFX_DUR_GLOW_LIGHT_BROWN;}
     }

    if ( (GetStringUpperCase(sColor) == "GREY") || (GetStringUpperCase(sColor) == "GRAY"))
     {
        if (GetStringUpperCase(sRight) == "RG") {nLight = VFX_DUR_GLOW_GREY;}
        if (GetStringUpperCase(sRight) == "LT") {nLight = VFX_DUR_GLOW_GREY;}
     }

    return nLight;
}

int n1st_AnimNo(string sAnim)
{
 int nAnim=-1;
 sAnim = GetStringUpperCase(sAnim);
 if (sAnim == "CONJURE1")       {nAnim = ANIMATION_LOOPING_CONJURE1;}
 if (sAnim == "CONJURE2")       {nAnim = ANIMATION_LOOPING_CONJURE2;}
 if (sAnim == "CUSTOM1")        {nAnim = ANIMATION_LOOPING_CUSTOM1;}
 if (sAnim == "CUSTOM10")       {nAnim = ANIMATION_LOOPING_CUSTOM10;}
 if (sAnim == "CUSTOM2")        {nAnim = ANIMATION_LOOPING_CUSTOM2;}
 if (sAnim == "CUSTOM3")        {nAnim = ANIMATION_LOOPING_CUSTOM3;}
 if (sAnim == "CUSTOM4")        {nAnim = ANIMATION_LOOPING_CUSTOM4;}
 if (sAnim == "CUSTOM5")        {nAnim = ANIMATION_LOOPING_CUSTOM5;}
 if (sAnim == "CUSTOM6")        {nAnim = ANIMATION_LOOPING_CUSTOM6;}
 if (sAnim == "CUSTOM7")        {nAnim = ANIMATION_LOOPING_CUSTOM7;}
 if (sAnim == "CUSTOM8")        {nAnim = ANIMATION_LOOPING_CUSTOM8;}
 if (sAnim == "CUSTOM9")        {nAnim = ANIMATION_LOOPING_CUSTOM9;}
 if (sAnim == "DEAD")           {nAnim = ANIMATION_LOOPING_DEAD_BACK;}
 if (sAnim == "DEAD_BACK")      {nAnim = ANIMATION_LOOPING_DEAD_BACK;}
 if (sAnim == "DEAD_FRONT")     {nAnim = ANIMATION_LOOPING_DEAD_FRONT;}
 if ( (sAnim == "LOW") || (sAnim == "GET_LOW")) {nAnim = ANIMATION_LOOPING_GET_LOW;}
 if ( (sAnim == "MID") || (sAnim == "GET_MID")) {nAnim = ANIMATION_LOOPING_GET_MID;}
 if (sAnim == "LISTEN")         {nAnim = ANIMATION_LOOPING_LISTEN;}
 if ( (sAnim == "LOOK_FAR") || (sAnim == "LOOK"))       {nAnim = ANIMATION_LOOPING_LOOK_FAR;}
 if (sAnim == "MEDITATE")       {nAnim = ANIMATION_LOOPING_MEDITATE;}
 if (sAnim == "PAUSE")          {nAnim = ANIMATION_LOOPING_PAUSE;}
 if ( (sAnim == "PAUSE_DRUNK") || (sAnim == "DRUNK"))   {nAnim = ANIMATION_LOOPING_PAUSE_DRUNK;}
 if ( (sAnim == "PAUSE_TIRED") || (sAnim == "TIRED"))   {nAnim = ANIMATION_LOOPING_PAUSE_TIRED;}
 if (sAnim == "PAUSE2")          {nAnim = ANIMATION_LOOPING_PAUSE2;}
 if ( (sAnim == "SIT") || (sAnim == "SIT_CROSS"))    {nAnim = ANIMATION_LOOPING_SIT_CROSS;}
 if (sAnim == "SIT_CHAIR")      {nAnim = ANIMATION_LOOPING_SIT_CHAIR;}
 if (sAnim == "SPASM")          {nAnim = ANIMATION_LOOPING_SPASM;}
 if ( (sAnim == "TALK") || (sAnim == "TALK_NORMAL"))    {nAnim = ANIMATION_LOOPING_TALK_NORMAL;}
 if ( (sAnim == "LAUGH") || (sAnim == "TALK_LAUGHING")) {nAnim = ANIMATION_LOOPING_TALK_LAUGHING;}
 if ( (sAnim == "PLEAD") || (sAnim == "TALK_PLEADING")) {nAnim = ANIMATION_LOOPING_TALK_PLEADING;}
 if (sAnim == "WORSHIP")        {nAnim = ANIMATION_LOOPING_WORSHIP;}
 if ( (sAnim == "BOW") || (sAnim == "BOWS") )           {nAnim = ANIMATION_FIREFORGET_BOW;}
 if ( (sAnim == "DODGE_DUCK") || (sAnim == "DUCK"))     {nAnim = ANIMATION_FIREFORGET_DODGE_DUCK;}
 if ( (sAnim == "DODGE_SIDE") || (sAnim == "DODGE"))    {nAnim = ANIMATION_FIREFORGET_DODGE_SIDE;}
 if (sAnim == "DRINK")             {nAnim = ANIMATION_FIREFORGET_DRINK;}
 if ((sAnim == "GREET") || (sAnim == "GREETING") || (sAnim == "WAVE") || (sAnim == "WAVES"))       {nAnim = ANIMATION_FIREFORGET_GREETING;}
 if ( (sAnim == "HEAD_TURN_LEFT") || (sAnim == "LOOK_LEFT"))       {nAnim = ANIMATION_FIREFORGET_HEAD_TURN_LEFT;}
 if ( (sAnim == "HEAD_TURN_RIGHT")|| (sAnim == "LOOK_RIGHT"))      {nAnim = ANIMATION_FIREFORGET_HEAD_TURN_RIGHT;}
 if ( (sAnim == "PAUSE_BORED")|| (sAnim == "BORED"))      {nAnim = ANIMATION_FIREFORGET_PAUSE_BORED;}
 if ( (sAnim == "PAUSE_SCRATCH_HEAD")|| (sAnim == "SCRATCH_HEAD")) {nAnim = ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD;}
 if (sAnim == "READ")             {nAnim = ANIMATION_FIREFORGET_READ;}
 if (sAnim == "SALUTE")           {nAnim = ANIMATION_FIREFORGET_SALUTE;}
 if ( (sAnim == "STEALS") || (sAnim == "STEAL"))     {nAnim = ANIMATION_FIREFORGET_STEAL;}
 if ( (sAnim == "STRETCHES") || (sAnim == "TAUNTS") || (sAnim == "TAUNT"))     {nAnim = ANIMATION_FIREFORGET_TAUNT;}
 if ( (sAnim == "VICTORY1") || (sAnim == "VICTORY") || (sAnim == "CHEERS"))    {nAnim = ANIMATION_FIREFORGET_VICTORY1;}
 if (sAnim == "VICTORY2")     {nAnim = ANIMATION_FIREFORGET_VICTORY2;}
 if (sAnim == "VICTORY3")     {nAnim = ANIMATION_FIREFORGET_VICTORY3;}
 if ( (sAnim == "THREATEN") || (sAnim == "TALK_FORCEFUL") || (sAnim == "ARGUE") ) {nAnim = ANIMATION_LOOPING_TALK_FORCEFUL;}

 return nAnim;
}

int n1st_SkillNo(string sSkill)
{
  int nSkill = SKILL_SEARCH;
  sSkill = GetStringUpperCase(sSkill);

  if ( (sSkill == "ANIMAL") || (sSkill == "ANIMAL_EMPATHY") || (sSkill=="SKILL_ANIMAL_EMPATHY") ) {nSkill = SKILL_ANIMAL_EMPATHY;}
  if ( (sSkill == "APPRAISE")|| (sSkill=="SKILL_APPRAISE")) {nSkill = SKILL_APPRAISE;}
  if ( (sSkill == "BLUFF") || (sSkill=="SKILL_BLUFF")) {nSkill = SKILL_BLUFF;}
  if ( (sSkill == "SKILL_CONCENTRATION") || (sSkill=="CONCENTRATION")) {nSkill = SKILL_CONCENTRATION;}
  if ( (sSkill == "SKILL_CRAFT_ARMOR") || (sSkill=="CRAFT_ARMOR")  || (sSkill=="ARMOR")) {nSkill = SKILL_CRAFT_ARMOR;}
  if ( (sSkill == "SKILL_CRAFT_TRAP") || (sSkill=="CRAFT_TRAP")) {nSkill = SKILL_CRAFT_TRAP;}
  if ( (sSkill == "SKILL_CRAFT_WEAPON") || (sSkill=="CRAFT_WEAPON")  || (sSkill=="WEAPON")) {nSkill = SKILL_CRAFT_WEAPON;}
  if ( (sSkill == "SKILL_DISABLE_TRAP") || (sSkill=="DISABLE_TRAP") ) {nSkill = SKILL_DISABLE_TRAP;}
  if ( (sSkill == "SKILL_DISCIPLINE") || (sSkill=="DISCIPLINE")  || (sSkill=="DISC")) {nSkill = SKILL_DISCIPLINE;}
  if ( (sSkill == "SKILL_HEAL") || (sSkill=="HEAL")) {nSkill = SKILL_HEAL;}
  if ( (sSkill == "SKILL_HIDE") || (sSkill=="HIDE")) {nSkill = SKILL_HIDE;}
  if ( (sSkill == "SKILL_INTIMIDATE") || (sSkill=="INTIMIDATE")) {nSkill = SKILL_INTIMIDATE;}
  if ( (sSkill == "SKILL_LISTEN") || (sSkill=="LISTEN")) {nSkill = SKILL_LISTEN;}
  if ( (sSkill == "SKILL_LORE") || (sSkill=="LORE")) {nSkill = SKILL_LORE;}
  if ( (sSkill == "SKILL_MOVE_SILENTLY") || (sSkill=="MOVE_SILENTLY")  || (sSkill=="SILENT") || (sSkill=="SILENTLY")) {nSkill = SKILL_MOVE_SILENTLY;}
  if ( (sSkill == "SKILL_OPEN_LOCK") || (sSkill=="OPEN_LOCK")  || (sSkill=="LOCK")) {nSkill = SKILL_OPEN_LOCK;}
  if ( (sSkill == "SKILL_PARRY") || (sSkill=="PARRY")) {nSkill = SKILL_PARRY;}
  if ( (sSkill == "SKILL_PERFORM") || (sSkill=="PERFORM")) {nSkill = SKILL_PERFORM;}
  if ( (sSkill == "SKILL_PERSUADE") || (sSkill=="PERSUADE")) {nSkill = SKILL_PERSUADE;}
  if ( (sSkill == "SKILL_PICK_POCKET") || (sSkill=="PICK_POCKET")) {nSkill = SKILL_PICK_POCKET;}
  if ( (sSkill == "SKILL_SEARCH") || (sSkill=="SEARCH")) {nSkill = SKILL_SEARCH;}
  if ( (sSkill == "SKILL_SET_TRAP") || (sSkill=="SET_TRAP")) {nSkill = SKILL_SET_TRAP;}
  if ( (sSkill == "SKILL_SPELLCRAFT") || (sSkill=="SPELLCRAFT")) {nSkill = SKILL_SPELLCRAFT;}
  if ( (sSkill == "SKILL_SPOT") || (sSkill=="SPOT")) {nSkill = SKILL_SPOT;}
  if ( (sSkill == "SKILL_TAUNT") || (sSkill=="TAUNT")) {nSkill = SKILL_TAUNT;}
  if ( (sSkill == "SKILL_TUMBLE") || (sSkill=="TUMBLE")) {nSkill = SKILL_TUMBLE;}
  if ( (sSkill == "SKILL_USE_MAGIC_DEVICE") || (sSkill=="USE_MAGIC_DEVICE") || (sSkill=="MAGIC_DEVICE")) {nSkill = SKILL_USE_MAGIC_DEVICE;}

  return nSkill;
}



int n1st_GetIsSameFactionAs(object oMember1, object oMember2)
{
  int nReturn=FALSE;
  object oFM = GetFirstFactionMember(oMember1, FALSE);
  while (GetIsObjectValid(oFM)==TRUE)
   {
     if (oFM == oMember2) {nReturn = TRUE;}
     oFM = GetNextFactionMember(oMember1, FALSE);
   }
   return nReturn;
}

void X1st_RemoveAllPartyMembers(object oPC)
{
 if (GetIsPC(oPC) == FALSE) {return;}
 object oPCParty = GetFirstFactionMember(oPC);

 while (GetIsObjectValid(oPCParty) == TRUE)
   {
      if (oPCParty!=oPC)
       {RemoveFromParty(oPCParty);}
      oPCParty = GetNextFactionMember(oPC);
   }
}

void X1st_AddAllPCsInAreaToParty(object oPC)
{
 if (GetIsPC(oPC) == FALSE) {return;}
 object oArea = GetArea(oPC);

 object oPCEval = GetFirstPC();
 while (GetIsObjectValid(oPCEval) == TRUE)
 {
   if ( (n1st_GetIsSameFactionAs(oPC, oPCEval)==FALSE) && (GetArea(oPCEval) == oArea) )
    {
      RemoveFromParty(oPCEval);
      AddToParty(oPCEval, oPC);
    }
  oPCEval = GetNextPC();
 }
}

int n1st_GetHasEffectOfType(object oTarget, int nEffectTypeConst)
{

 int nReturn=FALSE;
 effect eEff = GetFirstEffect(oTarget);
 while (GetIsEffectValid(eEff) == TRUE)
  {
    if (GetEffectType(eEff) == nEffectTypeConst) {nReturn=TRUE;}
    eEff = GetNextEffect(oTarget);
  }
 return nReturn;
}


int n1st_GetNumberOfEffectOfType(object oTarget, int nEffectTypeConst)
{

 int nReturn=0;
 effect eEff = GetFirstEffect(oTarget);
 while (GetIsEffectValid(eEff) == TRUE)
  {
    if (GetEffectType(eEff) == nEffectTypeConst) {nReturn++;}
    eEff = GetNextEffect(oTarget);
  }
 return nReturn;
}



void X1st_GameTimeDelayScript(string sScript, object oTarget, int nDays, int nHours=0, int nMinutes=0, int nSeconds=0, int nMonths=0)
{
  float fDelay;
  object oS = oTarget;
  int nCYear=GetCalendarYear();
  int nCMonth=GetCalendarMonth();
  int nCDay = GetCalendarDay();;
  int nCHour=GetTimeHour();
  int nCMinute=GetTimeMinute();
  int nCSecond=GetTimeSecond();
  int nTime1;
  int nYear=nCYear;
  int nExecute;

  //Set up Script ID.
  string sID = sScript + IntToString( nSeconds + 60*(nMinutes + 60*(nHours + 24*(nDays))));

  //Check to see if function has been initialized on the object\\
  int nCheck = GetLocalInt(oS, "nI"+sID);

  //Initialized - Check to see if script is ready to run
  if (nCheck==1)
   {
      int nSYear    = GetLocalInt(oS, "nY"+sID);
      int nSMonth   = GetLocalInt(oS, "nM"+sID);
      int nSDay     = GetLocalInt(oS, "nD"+sID);
      int nSHour    = GetLocalInt(oS, "nh"+sID);
      int nSMinute  = GetLocalInt(oS, "nm"+sID);
      int nSSecond  = GetLocalInt(oS, "ns"+sID);

     while (nExecute!=1)  //Allows a quick way out of a bunch of if statements.
      {
        if (nSYear<nCYear) {nExecute=1;break;}
        if (nCYear<nSYear) {DelayCommand(1800.0, X1st_GameTimeDelayScript(sScript, oTarget, nDays, nHours, nMinutes, nSeconds, nMonths)); return;}

        //Now nSYear == nCYear
        if (nSMonth<nCMonth) {nExecute=1;break;}
        if (nSMonth>nCMonth) {DelayCommand(1800.0, X1st_GameTimeDelayScript(sScript, oTarget, nDays, nHours, nMinutes, nSeconds, nMonths)); return;}

        //Now nSMonth = nCMonth
        if (nSDay<nCDay) {nExecute=1;break;}
        if (nSDay>nCDay) {DelayCommand(720.0, X1st_GameTimeDelayScript(sScript, oTarget, nDays, nHours, nMinutes, nSeconds, nMonths)); return;}

        //Now nSDay = nCDay
        if (nSHour<nCHour) {nExecute=1;break;}
        if (nSHour>nCHour)
          {
            if (nSHour>nCHour+5) {fDelay=300.0;} else{fDelay=60.0;}
            DelayCommand(fDelay, X1st_GameTimeDelayScript(sScript, oTarget, nDays, nHours, nMinutes, nSeconds, nMonths));
            return;
          }

        //Now nSHour = nCHour
        if (nSMinute<nCMinute) {nExecute=1;break;}
        if (nSMinute>nCMinute)
          {
            if (nSMinute>nCMinute+4) {fDelay=30.0;} else{fDelay=12.0;}
            DelayCommand(fDelay, X1st_GameTimeDelayScript(sScript, oTarget, nDays, nHours, nMinutes, nSeconds, nMonths));
            return;
          }

        //Now nSMinute = nCMinute
        if (nSSecond<=nCSecond) {nExecute=1;break;}
        if (nSSecond>nCSecond)
          {
            DelayCommand(6.0, X1st_GameTimeDelayScript(sScript, oTarget, nDays, nHours, nMinutes, nSeconds, nMonths));
            return;
          }
       break; //Ends while loop after first run. Of course this should happen either through the return or Breaks
      }
      //At this point nExecute  must be equal to 1, or there's an error in the script
      //Assuming my scripting is flawless as always *laughter is heard in the background*
      ExecuteScript(sScript, oTarget);
      //So why was nExecute needed?!? Silly me. So much for "flawless" scripting.
   }

  //Uninitialized Case - Get the delay sequencer ready! Engage!
  if (nCheck!=1)
   {
     SetLocalInt(oS, "nI"+sID, 1);
     DelayCommand(6.0, X1st_GameTimeDelayScript(sScript, oTarget, nDays, nHours, nMinutes, nSeconds, nMonths));

     //Resynchronize & Set GameTime to execute
     nSeconds = nCSecond+nSeconds;
     while (nSeconds>60)
      {
        nSeconds=nSeconds-60;
        nMinutes++;
      }
     nMinutes = nCMinute + nMinutes;
     while (nMinutes>60)
      {
       nMinutes=nMinutes-60;
       nHours++;
      }
     nHours = nCHour + nHours;
     while (nHours>24)
      {
       nHours=nHours-24;
       nDays++;
      }
     nDays = nDays + nCDay;
     while (nDays>28)
      {
       nMonths++;
       nDays=nDays-28;
      }
     nMonths = nCMonth + nMonths;
     while (nMonths>12)
      {
       nMonths=nMonths-12;
       nYear = nYear+1;
      }

     //Now we have the DATE (nYear, nMonths, nDays, nHours, nMinutes, nSeconds)
     //in GAME TIME for when the script is scheduled to run.
     SetLocalInt(oS, "nY"+sID, nYear);
     SetLocalInt(oS, "nM"+sID, nMonths);
     SetLocalInt(oS, "nD"+sID, nDays);
     SetLocalInt(oS, "nh"+sID, nHours);
     SetLocalInt(oS, "nm"+sID, nMinutes);
     SetLocalInt(oS, "ns"+sID, nSeconds);
   }
}



////////////////////////\\\\\\\\\\\\\\\\\\\\\\\
///////////////////o1st_GetNearestPC\\\\\\\\\\\
////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\
object o1st_GetNearestPC(int nNth=1, object oOBJ=OBJECT_SELF)
{object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC,oOBJ,nNth);
 return oPC;
}

////////////////////////\\\\\\\\\\\\\\\\\\\\\\\
///////////////////o1st_GetNearestNPC\\\\\\\\\\\
////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\
object o1st_GetNearestNPC(int nNth=1, object oOBJ=OBJECT_SELF)
{object oNPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_NOT_PC,oOBJ,nNth);
 return oNPC;
}


////////////////////////\\\\\\\\\\\\\\\\\\\\\\\
///////////////////X1st_CopyItem_Delay\\\\\\\\\\
////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\
void X1st_CopyItem_Delay(float fDelay, object oSource, object oOwner, int nCopyLocalVariables=TRUE,int nDontUse=FALSE)
{
  if (nDontUse==FALSE){DelayCommand(fDelay, X1st_CopyItem_Delay(fDelay,oSource, oOwner,nCopyLocalVariables,TRUE));}
  else {object oCopy = CopyItem(oSource, oOwner,nCopyLocalVariables);}
}


////////////////////////\\\\\\\\\\\\\\\\\\\\\\\
///////////////////X1st_CopyObject_Delay\\\\\\\\\\
////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\
void X1st_CopyObject_Delay(float fDelay, string sTag, location lLOC, int nDontUse=FALSE)
{
 if (nDontUse==FALSE){DelayCommand(fDelay, X1st_CopyObject_Delay(fDelay,sTag,lLOC,TRUE));}
 else {object oCopy = CopyObject(GetObjectByTag(sTag), lLOC);}
}


////////////////////////\\\\\\\\\\\\\\\\\\\\\\\
///////////////////X1st_CreateItem_Delay\\\\\\\\\\
////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\
//A Delayed CreateItem function. (NOTE - with CreateObjectVoid you can't place the object in the inventory)
//oSource is the Item you want to copy (NOTE this is ITEM - if you're using this on a creature, don't blame me.)
//oOwner - This with either be created in oOwner's inventory (if it has one), or at the owner's location (like a waypoint)
//nDontUse => LEAVE IT ALONE! This is the secret to how this function works.
//            Ok - if you set it equal to TRUE, then this function ignore the delay - hence it's just CreateItemOnObject.
void X1st_CreateItem_Delay(float fDelay, string sResRef, object oOwner, int nDontUse=FALSE)
{
  if (nDontUse==FALSE){DelayCommand(fDelay, X1st_CreateItem_Delay(fDelay,sResRef, oOwner,TRUE));}
  else
   {
     object oCopy;
     if (GetHasInventory(oOwner)==TRUE){oCopy = CreateItemOnObject(sResRef, oOwner);}
     else {CreateObject(OBJECT_TYPE_ITEM, sResRef, GetLocation(oOwner));}
   }
}

////////////////////////\\\\\\\\\\\\\\\\\\\\\\\
////////////n1st_GetNumberPartyMembers\\\\\\\\\\
////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\
int n1st_GetNumberPartyMembers(object oPC,int nInclude_Associates=FALSE)
{
 int nMembers;
 int nAssociates=TRUE;
 if (nInclude_Associates==TRUE){nAssociates==FALSE;}
 object oPartyMember = GetFirstFactionMember(oPC, nAssociates);
 while (GetIsObjectValid(oPartyMember)==TRUE)
  {
    nMembers++;
    oPartyMember=GetNextFactionMember(oPC, nAssociates);
  }
 return nMembers;
}

////////////////////////\\\\\\\\\\\\\\\\\\\\\\\
////////////X1st_GiveGoldToAllEqually\\\\\\\\\\
////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\
void X1st_GiveGoldToAllEqually(object oPC, int nTotalGoldToDivvyUp)
{
    int nMembers = n1st_GetNumberPartyMembers(oPC);
    int nGP = nTotalGoldToDivvyUp/nMembers;

    object oPartyMember = GetFirstFactionMember(oPC);
    while (GetIsObjectValid(oPartyMember)==TRUE)
      {
        if (nGP>0){GiveGoldToCreature(oPartyMember, nGP);}
        if (nGP<0){TakeGoldFromCreature(-nGP,oPartyMember,TRUE);}
        oPartyMember = GetNextFactionMember(oPC);
      }
}

////////////////////////\\\\\\\\\\\\\\\\\\\\\\\
////////////X1st_MakeCutsceneInvisible\\\\\\\\\\
////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\
void X1st_MakeCutsceneInvisible(object oPC, float fDuration)
{
   effect eInv = EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY);
   SetLocalInt(oPC, "n1orp_iscutsceneinvisible",TRUE);
   ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eInv, oPC, fDuration);
   DelayCommand(fDuration, DeleteLocalInt(oPC, "n1orp_iscutsceneinvisible"));
}


////////////////////////\\\\\\\\\\\\\\\\\\\\\\\
///////////////X1st_DestroyAllItems\\\\\\\\\\\\\
////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\
void X1st_DestroyAllItems(object oContainer)
{
  object oItem;
  int i = 0;
  for (i=0;i<NUM_INVENTORY_SLOTS;i++)
   {
    oItem = GetItemInSlot(i,oContainer);
    if (GetIsObjectValid(oItem)==TRUE){SetPlotFlag(oItem, FALSE);DestroyObject(oItem);}
   }

  oItem = GetFirstItemInInventory(oContainer);
  while (GetIsObjectValid(oItem)==TRUE)
    {
      SetPlotFlag(oItem, FALSE);
      DestroyObject(oItem);
     oItem = GetNextItemInInventory(oContainer);
    }
}

////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\
///////////////X1st_DestroyAllItems_NotDMFI\\\\\\\\\\\\\
////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
void X1st_DestroyAllItems_NotDMFI(object oPC)
{
  object oItem;
  string sTag;

  //First cycle through the items equipted.
  int i = 0;
  for (i=0;i<NUM_INVENTORY_SLOTS;i++)
   {
    oItem = GetItemInSlot(i,oPC);
    if ((GetIsObjectValid(oItem)==TRUE)&& (sTag != "DMFI") && (sTag!="1ORP") && (sTag!="HLSL") )
        {SetPlotFlag(oItem, FALSE);DestroyObject(oItem);}
   }

  oItem = GetFirstItemInInventory(oPC);
  while (GetIsObjectValid(oItem)==TRUE)
    {
      sTag = GetStringUpperCase(GetStringLeft(GetTag(oItem),4));
       if ( (sTag != "DMFI") && (sTag!="1ORP") && (sTag!="HLSL") )
         {
           SetPlotFlag(oItem, FALSE);
           DestroyObject(oItem);
         }
     oItem = GetNextItemInInventory(oPC);
    }
}


////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\
///////////////////X1st_DestroyDMFIItems\\\\\\\\\\\\\\\\
////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
void X1st_DestroyDMFIItems(object oContainer)
{
  object oItem;
  string sTag;

  //First cycle through the items equipted.
  int i = 0;
  for (i=0;i<NUM_INVENTORY_SLOTS;i++)
   {
    oItem = GetItemInSlot(i,oContainer);
    if ((sTag == "DMFI") || (sTag=="1ORP") || (sTag=="HLSL") )
        {SetPlotFlag(oItem, FALSE);DestroyObject(oItem);}
   }

  oItem = GetFirstItemInInventory(oContainer);

  while (GetIsObjectValid(oItem)==TRUE)
    {
      sTag = GetStringUpperCase(GetStringLeft(GetTag(oItem),4));
       if ( (sTag == "DMFI") || (sTag=="1ORP") || (sTag=="HLSL") )
         {
           SetPlotFlag(oItem, FALSE);
           DestroyObject(oItem);
         }
     oItem = GetNextItemInInventory(oContainer);
    }
}


////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\
/////////////////////X1st_GiveDMFIItems\\\\\\\\\\\\\\\\\
////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
void X1st_GiveDMFIItems(object oPC)
{
  object oItem;
  string sResRef;
  int nNLang; //not used here.

///PLAYER RACES:
string sDMFI_LANG_ELF      = "hlslang_1";
string sDMFI_LANG_HALFLING = "hlslang_3";
string sDMFI_LANG_DWARF    = "hlslang_4";
string sDMFI_LANG_GNOME    = "hlslang_2";
string sDMFI_LANG_ORC      = "hlslang_5";  //Half-Orc

//PLAYER CLASSES:
string sDMFI_LANG_THIEF    = "hlslang_9";   //GIVEN TO ALL ROGUES regardless of INT (could not find the reference in the PH 3rd Ed though.)
string sDMFI_LANG_ANIMAL   = "hlslang_8";   //Given to all Rangers/Druids as part of Animal Empathy
string sDMFI_LANG_DRUIDIC  = "hlslang_60";  //GIVEN TO ALL DRUIDS regardless of INT (pg 35 3rd ED Player's Handbook)


  sResRef = "dmfi_playerbook";
  if (GetIsObjectValid(GetItemPossessedBy(oPC, sResRef))==FALSE){CreateItemOnObject(sResRef, oPC);}
  sResRef = "dmfi_pc_follow";
  if (GetIsObjectValid(GetItemPossessedBy(oPC, sResRef))==FALSE){CreateItemOnObject(sResRef, oPC);}
  sResRef = "dmfi_pc_dicebag";
  if (GetIsObjectValid(GetItemPossessedBy(oPC, sResRef))==FALSE){CreateItemOnObject(sResRef, oPC);}
  sResRef = "dmfi_pc_emote";
  if (GetIsObjectValid(GetItemPossessedBy(oPC, sResRef))==FALSE){CreateItemOnObject(sResRef, oPC);}
   int nRace = GetRacialType(oPC);
         switch (nRace)
          {
            case RACIAL_TYPE_DWARF:
             nNLang=1;
             if (GetIsObjectValid(GetItemPossessedBy(oPC, sDMFI_LANG_DWARF))==FALSE) {CreateItemOnObject(sDMFI_LANG_DWARF, oPC);}
            break;

            case RACIAL_TYPE_ELF:
             nNLang=1;
             if (GetIsObjectValid(GetItemPossessedBy(oPC, sDMFI_LANG_ELF)) == FALSE) {CreateItemOnObject(sDMFI_LANG_ELF, oPC);}
            break;

            case RACIAL_TYPE_GNOME:
             nNLang=2;
             if (GetIsObjectValid(GetItemPossessedBy(oPC, sDMFI_LANG_GNOME)) == FALSE) {CreateItemOnObject(sDMFI_LANG_GNOME, oPC);}
             if (GetIsObjectValid(GetItemPossessedBy(oPC, sDMFI_LANG_ANIMAL)) == FALSE) {CreateItemOnObject(sDMFI_LANG_ANIMAL, oPC);}
            break;

            case RACIAL_TYPE_HALFELF:
             nNLang=1;
             if (GetIsObjectValid(GetItemPossessedBy(oPC, sDMFI_LANG_ELF)) == FALSE) {CreateItemOnObject(sDMFI_LANG_ELF, oPC);}
            break;

            case RACIAL_TYPE_HALFLING:
             nNLang=1;
             if (GetIsObjectValid(GetItemPossessedBy(oPC, sDMFI_LANG_HALFLING)) == FALSE) {CreateItemOnObject(sDMFI_LANG_HALFLING, oPC);}
            break;

            case RACIAL_TYPE_HALFORC:
             nNLang=1;
             if (GetIsObjectValid(GetItemPossessedBy(oPC, sDMFI_LANG_ORC)) == FALSE) {CreateItemOnObject(sDMFI_LANG_ORC, oPC);}
            break;
          }

         if (n1st_GetHasClass(oPC, CLASS_TYPE_DRUID)==TRUE)
           {
             nNLang++; nNLang++;
             if (GetIsObjectValid(GetItemPossessedBy(oPC, sDMFI_LANG_ANIMAL)) == FALSE)
                {CreateItemOnObject(sDMFI_LANG_ANIMAL, oPC);}

             if (GetIsObjectValid(GetItemPossessedBy(oPC, sDMFI_LANG_DRUIDIC)) == FALSE)
                {CreateItemOnObject(sDMFI_LANG_DRUIDIC, oPC);}
           }

         if (n1st_GetHasClass(oPC, CLASS_TYPE_RANGER)==TRUE)
           {
             nNLang++;
             if (GetIsObjectValid(GetItemPossessedBy(oPC, sDMFI_LANG_ANIMAL)) == FALSE)
              {CreateItemOnObject(sDMFI_LANG_ANIMAL, oPC);}
           }

         if (n1st_GetHasClass(oPC, CLASS_TYPE_ROGUE)==TRUE)
           {
             nNLang++;
             if (GetIsObjectValid(GetItemPossessedBy(oPC, sDMFI_LANG_THIEF)) == FALSE)
               {CreateItemOnObject(sDMFI_LANG_THIEF, oPC);}
           }
}


////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\
/////////////////////X1st_Give1ORPItems\\\\\\\\\\\\\\\\\
////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
void X1st_Give1ORPItems(object oPC)
{
string s1st_AMULET         = "1orp_amlt_telprt";
string s1st_LOOTKEY        = "1orp_itm_lootkey";
string s1st_BANDAGES       = "1orp_bandages";
string s1st_VOICEJUMP = "1orp_dmfi_voicej";
string s1st_LOADPW_BOOK    = "1orp_srvr_loadpw";
string s1st_RELOADMOD_BOOK = "1orp_srvr_loadmd";
string s1st_1STBOOK        = "1orp_book_items";

 //Amulet of Teleportation:
     if ( GetIsObjectValid(GetItemPossessedBy(oPC, s1st_AMULET)) == FALSE)
        {CreateItemOnObject(s1st_AMULET, oPC);}

     //Looting Key...
     if ( GetIsObjectValid(GetItemPossessedBy(oPC, s1st_LOOTKEY)) == FALSE)
        {CreateItemOnObject(s1st_LOOTKEY, oPC);}

     //Bandages
     if ( GetIsObjectValid(GetItemPossessedBy(oPC, s1st_BANDAGES)) == FALSE)
        {CreateItemOnObject(s1st_BANDAGES, oPC);}

     //DMFI Voice Jumper
     if ( GetIsObjectValid(GetItemPossessedBy(oPC, s1st_VOICEJUMP)) == FALSE)
        {CreateItemOnObject(s1st_VOICEJUMP, oPC);}

     //Our instruction book
     if ( GetIsObjectValid(GetItemPossessedBy(oPC, s1st_1STBOOK)) == FALSE)
        {CreateItemOnObject(s1st_1STBOOK, oPC);}
}

////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\
//////////////////////A1st_EquipItem\\\\\\\\\\\\\\\\\\\
////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
void A1st_EquipItem(object oNPC, object oItem)
{
 if ( (GetIsObjectValid(oNPC)==FALSE) || (GetIsObjectValid(oItem)==FALSE) ) {return;}

 int nBaseType = GetBaseItemType(oItem);
 int nSlot;

 switch (nBaseType)
  {
    case BASE_ITEM_AMULET:
      nSlot = INVENTORY_SLOT_NECK;
     break;

    case BASE_ITEM_ARMOR:
      nSlot = INVENTORY_SLOT_CHEST;
     break;

    case BASE_ITEM_ARROW:
      nSlot = INVENTORY_SLOT_ARROWS;
     break;

    case BASE_ITEM_LARGESHIELD: case BASE_ITEM_SMALLSHIELD:
    case BASE_ITEM_TOWERSHIELD: case BASE_ITEM_TORCH:
      nSlot = INVENTORY_SLOT_LEFTHAND;
     break;

    case BASE_ITEM_RING:
      nSlot = INVENTORY_SLOT_RIGHTRING;
      if (GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_RIGHTRING,oNPC))==TRUE)
        {nSlot = INVENTORY_SLOT_LEFTRING;}
     break;

    case BASE_ITEM_HELMET:
      nSlot = INVENTORY_SLOT_HEAD;
     break;

    case BASE_ITEM_BELT:
      nSlot = INVENTORY_SLOT_BELT;
     break;

    case BASE_ITEM_BOLT:
      nSlot = INVENTORY_SLOT_BOLTS;
     break;

    case BASE_ITEM_BOOTS:
      nSlot = INVENTORY_SLOT_BOOTS;
     break;

    case BASE_ITEM_BRACER:
    case BASE_ITEM_GLOVES:
      nSlot = INVENTORY_SLOT_ARMS;
     break;

    case BASE_ITEM_BULLET:
      nSlot = INVENTORY_SLOT_BULLETS;
     break;

     case BASE_ITEM_CLOAK:
      nSlot = INVENTORY_SLOT_CLOAK;
     break;

/*  //move this to default... Should just return a log error on fail to equip
    case BASE_ITEM_BASTARDSWORD:
    case BASE_ITEM_BATTLEAXE:
    case BASE_ITEM_CBLUDGWEAPON:    //?
    case BASE_ITEM_CLUB:
    case BASE_ITEM_CPIERCWEAPON:    //?
    case BASE_ITEM_CSLASHWEAPON:    //?
    case BASE_ITEM_CSLSHPRCWEAP:    //?
    case BASE_ITEM_DAGGER:
    case BASE_ITEM_DART:
    case BASE_ITEM_DIREMACE:
    case BASE_ITEM_DOUBLEAXE:
    case BASE_ITEM_DWARVENWARAXE:
    case BASE_ITEM_GREATAXE:
    case BASE_ITEM_GREATSWORD:
    case BASE_ITEM_HALBERD:
    case BASE_ITEM_HANDAXE:
    case BASE_ITEM_HEAVYCROSSBOW:
    case BASE_ITEM_HEAVYFLAIL:
    case BASE_ITEM_KAMA:
    case BASE_ITEM_KATANA:
    case BASE_ITEM_KUKRI:
    case BASE_ITEM_LIGHTCROSSBOW:
    case BASE_ITEM_LIGHTFLAIL:
    case BASE_ITEM_LIGHTHAMMER:
    case BASE_ITEM_LIGHTMACE:
    case BASE_ITEM_LONGBOW:
    case BASE_ITEM_LONGSWORD:
    case BASE_ITEM_MAGICSTAFF:
    case BASE_ITEM_MORNINGSTAR:
    case BASE_ITEM_QUARTERSTAFF:
    case BASE_ITEM_RAPIER:
    case BASE_ITEM_SCIMITAR:
    case BASE_ITEM_SCYTHE:
    case BASE_ITEM_SHORTBOW:
    case BASE_ITEM_SHORTSPEAR:
    case BASE_ITEM_RAPIER:
      nSlot = ;
     break;
*/
     default:
      nSlot = INVENTORY_SLOT_RIGHTHAND;
     break;
  }
 AssignCommand(oNPC,ActionEquipItem(oItem, nSlot));
}

void X1st_RespawnNPC(object oNPC, string sNewTag="", int nAI=AI_LEVEL_DEFAULT)
 {
   if (GetIsObjectValid(oNPC)==FALSE){return;}

   int nSpawnStatue    = GetLocalInt(oNPC, "sSpawnStatue");
   int nSpawnRaiseable = GetLocalInt(oNPC, "nSpawnRaiseable");
   int nSpawnDeadRaise = GetLocalInt(oNPC, "nSpawnDeadRaise");
   int nSpawnDead      = GetLocalInt(oNPC, "nSpawnDead");
   int nBlood          = GetLocalInt(oNPC, "nBlood");
   int nSpawnHorse     = GetLocalInt(oNPC, "nSpawnHorse");


   //NPC Activities
   int n1O_NPCActivities = GetLocalInt(oNPC, "n1O_NPCActivities");
   int nGNBStateSpeed = GetLocalInt(oNPC, "nGNBStateSpeed");
   int nWrap_Mode     = GetLocalInt(oNPC, "nWrap_Mode");
   int bGNBQuickMove  = GetLocalInt(oNPC, "bGNBQuickMove");


   if (sNewTag==""){sNewTag=GetTag(oNPC);}
   location lLoc = GetLocation(oNPC);
   effect eGhost = EffectCutsceneGhost();
   ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eGhost,oNPC,5.0);
   object oNew = CopyObject(oNPC, lLoc, OBJECT_INVALID, sNewTag);
   SetPlotFlag(oNPC, FALSE);
   DestroyObject(oNPC);


   SetLocalInt(oNew, "sSpawnStatue",nSpawnStatue);
   SetLocalInt(oNew, "nSpawnRaiseable",nSpawnRaiseable);
   SetLocalInt(oNew, "nSpawnDeadRaise",nSpawnDeadRaise);
   SetLocalInt(oNew, "nSpawnDead",nSpawnDead);
   SetLocalInt(oNew, "nBlood",nBlood);
   SetLocalInt(oNew, "nSpawnHorse",nSpawnHorse);

   SetLocalInt(oNew, "n1O_NPCActivities",1);
   SetLocalInt(oNew, "nGNBStateSpeed",nGNBStateSpeed);
   SetLocalInt(oNew, "nWrap_Mode",nWrap_Mode);
   SetLocalInt(oNew, "bGNBQuickMove",bGNBQuickMove);
   SetAILevel(oNew, nAI);
 }

object o1st_RespawnNPC(object oNPC, string sNewTag="",int nAI=AI_LEVEL_DEFAULT)
 {
   if (GetIsObjectValid(oNPC)==FALSE){return OBJECT_INVALID;}

   int nSpawnStatue    = GetLocalInt(oNPC, "sSpawnStatue");
   int nSpawnRaiseable = GetLocalInt(oNPC, "nSpawnRaiseable");
   int nSpawnDeadRaise = GetLocalInt(oNPC, "nSpawnDeadRaise");
   int nSpawnDead      = GetLocalInt(oNPC, "nSpawnDead");
   int nBlood          = GetLocalInt(oNPC, "nBlood");
   int nSpawnHorse     = GetLocalInt(oNPC, "nSpawnHorse");

   int n1O_NPCActivities = GetLocalInt(oNPC, "n1O_NPCActivities");
   int nGNBStateSpeed = GetLocalInt(oNPC, "nGNBStateSpeed");
   int nWrap_Mode     = GetLocalInt(oNPC, "nWrap_Mode");
   int bGNBQuickMove  = GetLocalInt(oNPC, "bGNBQuickMove");


   if (sNewTag==""){sNewTag=GetTag(oNPC);}
   location lLoc = GetLocation(oNPC);
   effect eGhost = EffectCutsceneGhost();
   ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eGhost,oNPC,5.0);
   object oNew = CopyObject(oNPC, lLoc, OBJECT_INVALID, sNewTag);
   SetPlotFlag(oNPC, FALSE);
   DestroyObject(oNPC);

   SetLocalInt(oNew, "sSpawnStatue",nSpawnStatue);
   SetLocalInt(oNew, "nSpawnRaiseable",nSpawnRaiseable);
   SetLocalInt(oNew, "nSpawnDeadRaise",nSpawnDeadRaise);
   SetLocalInt(oNew, "nSpawnDead",nSpawnDead);
   SetLocalInt(oNew, "nBlood",nBlood);
   SetLocalInt(oNew, "nSpawnHorse",nSpawnHorse);

   SetLocalInt(oNew, "n1O_NPCActivities",1);
   SetLocalInt(oNew, "nGNBStateSpeed",nGNBStateSpeed);
   SetLocalInt(oNew, "nWrap_Mode",nWrap_Mode);
   SetLocalInt(oNew, "bGNBQuickMove",bGNBQuickMove);
   SetAILevel(oNew, nAI);
   return oNew;
 }


object o1st_CopyNPC(object oNPC, location lLoc, string sNewTag="", int nAI=AI_LEVEL_DEFAULT)
{
   if (GetIsObjectValid(oNPC)==FALSE){return OBJECT_INVALID;}

   int nSpawnStatue    = GetLocalInt(oNPC, "sSpawnStatue");
   int nSpawnRaiseable = GetLocalInt(oNPC, "nSpawnRaiseable");
   int nSpawnDeadRaise = GetLocalInt(oNPC, "nSpawnDeadRaise");
   int nSpawnDead      = GetLocalInt(oNPC, "nSpawnDead");
   int nBlood          = GetLocalInt(oNPC, "nBlood");
   int nSpawnHorse     = GetLocalInt(oNPC, "nSpawnHorse");

   int n1O_NPCActivities = GetLocalInt(oNPC, "n1O_NPCActivities");
   int nGNBStateSpeed = GetLocalInt(oNPC, "nGNBStateSpeed");
   int nWrap_Mode     = GetLocalInt(oNPC, "nWrap_Mode");
   int bGNBQuickMove  = GetLocalInt(oNPC, "bGNBQuickMove");

   if (sNewTag==""){sNewTag=GetTag(oNPC);}
   if (GetIsObjectValid(GetAreaFromLocation(lLoc))==FALSE){lLoc = GetLocation(oNPC);}

   object oNew = CopyObject(oNPC, lLoc, OBJECT_INVALID, sNewTag);

   SetLocalInt(oNew, "sSpawnStatue",nSpawnStatue);
   SetLocalInt(oNew, "nSpawnRaiseable",nSpawnRaiseable);
   SetLocalInt(oNew, "nSpawnDeadRaise",nSpawnDeadRaise);
   SetLocalInt(oNew, "nSpawnDead",nSpawnDead);
   SetLocalInt(oNew, "nBlood",nBlood);
   SetLocalInt(oNew, "nSpawnHorse",nSpawnHorse);

   SetLocalInt(oNew, "n1O_NPCActivities",1);
   SetLocalInt(oNew, "nGNBStateSpeed",nGNBStateSpeed);
   SetLocalInt(oNew, "nWrap_Mode",nWrap_Mode);
   SetLocalInt(oNew, "bGNBQuickMove",bGNBQuickMove);
   SetAILevel(oNew, nAI);
   return oNew;
}

void X1st_CopyNPC(object oNPC, location lLoc, string sNewTag="", int nAI=AI_LEVEL_DEFAULT)
{
   if (GetIsObjectValid(oNPC)==FALSE){return;}

   int nSpawnStatue    = GetLocalInt(oNPC, "sSpawnStatue");
   int nSpawnRaiseable = GetLocalInt(oNPC, "nSpawnRaiseable");
   int nSpawnDeadRaise = GetLocalInt(oNPC, "nSpawnDeadRaise");
   int nSpawnDead      = GetLocalInt(oNPC, "nSpawnDead");
   int nBlood          = GetLocalInt(oNPC, "nBlood");
   int nSpawnHorse     = GetLocalInt(oNPC, "nSpawnHorse");

   int n1O_NPCActivities = GetLocalInt(oNPC, "n1O_NPCActivities");
   int nGNBStateSpeed = GetLocalInt(oNPC, "nGNBStateSpeed");
   int nWrap_Mode     = GetLocalInt(oNPC, "nWrap_Mode");
   int bGNBQuickMove  = GetLocalInt(oNPC, "bGNBQuickMove");

   if (sNewTag==""){sNewTag=GetTag(oNPC);}
   if (GetIsObjectValid(GetAreaFromLocation(lLoc))==FALSE){lLoc = GetLocation(oNPC);}

   object oNew = CopyObject(oNPC, lLoc, OBJECT_INVALID, sNewTag);

   SetLocalInt(oNew, "sSpawnStatue",nSpawnStatue);
   SetLocalInt(oNew, "nSpawnRaiseable",nSpawnRaiseable);
   SetLocalInt(oNew, "nSpawnDeadRaise",nSpawnDeadRaise);
   SetLocalInt(oNew, "nSpawnDead",nSpawnDead);
   SetLocalInt(oNew, "nBlood",nBlood);
   SetLocalInt(oNew, "nSpawnHorse",nSpawnHorse);

   SetLocalInt(oNew, "n1O_NPCActivities",1);
   SetLocalInt(oNew, "nGNBStateSpeed",nGNBStateSpeed);
   SetLocalInt(oNew, "nWrap_Mode",nWrap_Mode);
   SetLocalInt(oNew, "bGNBQuickMove",bGNBQuickMove);
   SetAILevel(oNew, nAI);
}

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This function Jumps the PC & its entire Party to an Object (such as a waypoint)
void X1st_JumpPCPartyToObject(object oPC, object oWP)
{
  if ( (GetIsObjectValid(oWP)==FALSE) || (GetIsObjectValid(oPC)==FALSE) )
            {PrintString("Function X1st_JumpPCPartyToObject failed: Object not valid)"); return;}

  object oPCP = GetFirstFactionMember(oPC);
  while (GetIsObjectValid(oPCP)==TRUE)
   {
     AssignCommand(oPCP, ClearAllActions(TRUE));
     AssignCommand(oPCP, ActionJumpToObject(oWP, FALSE));
     oPCP = GetNextFactionMember(oPC);
   }
}

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This function Jumps all PCs in an area to an Object (such as a waypoint)
void X1st_JumpAllPCsInAreaToObject(object oArea, object oWP)
{
  if ( (GetIsObjectValid(oWP)==FALSE) || (GetIsObjectValid(oArea)==FALSE) )
            {PrintString("Function X1st_JumpAllPCsInAreaToObject failed: Object not valid)"); return;}
  int nI=1;
  object oPCP = o1st_GetNearestPC(nI,oArea);
  while (GetIsObjectValid(oPCP)==TRUE)
   {
     AssignCommand(oPCP, ClearAllActions(TRUE));
     AssignCommand(oPCP, ActionJumpToObject(oWP, FALSE));
     nI++;
     oPCP =o1st_GetNearestPC(nI,oArea);
   }
}

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
void A1st_SitInNearestChair(object oCreature, float fDist=10.0, string sPhrase = "all")
{
  object oS = oCreature;
  object oChair;
  string sTag;
  int nI; int nBoo;
  float fClosest=fDist; float fDistoO;
  location LoS = GetLocation(oS);
  location lChair;
  vector v1; vector v2; vector vUnit;

  object oO = GetFirstObjectInShape(SHAPE_SPHERE,fDist,LoS,FALSE,OBJECT_TYPE_PLACEABLE);

  while (GetIsObjectValid(oO)==TRUE)
   {
     sTag = GetStringUpperCase(GetTag(oO));
     nBoo = FALSE;
      if ( (sPhrase!="all") && (FindSubString(sTag,GetStringUpperCase(sPhrase))!=-1) && (GetSittingCreature(oO)==OBJECT_INVALID) ) {nBoo=TRUE;}
      if ( (sPhrase=="all") && (GetSittingCreature(oO)==OBJECT_INVALID) && ( (FindSubString(sTag,"CHAIR")!=-1) || (FindSubString(sTag,"COUCH")!=-1)
                   || (FindSubString(sTag,"THRONE")!=-1) || (FindSubString(sTag,"BENCH")!=-1) || (FindSubString(sTag,"STOOL")!=-1)) )
       {nBoo=TRUE;}

      if (nBoo==TRUE)
       {
         fDistoO = GetDistanceBetween(oS, oO);
         if (fDistoO<fClosest) {oChair=oO; fClosest=fDistoO;}
       }
     oO = GetNextObjectInShape(SHAPE_SPHERE,fDist,LoS,FALSE,OBJECT_TYPE_PLACEABLE);
   }
  if (GetIsObjectValid(oChair)==TRUE) //Credit for removing items from hands belongs to DMFI team (I would've left that out).
   {
        effect eGhost = EffectCutsceneGhost();
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eGhost, oS, 5.0);

        lChair = GetLocation(oChair);
        v1 = GetPositionFromLocation(lChair);
        v2 = GetPosition(oS);

/*
      //move PC towards chair\\
        vUnit = v2-v1; vUnit = vUnit/VectorMagnitude(vUnit);
        v1 = v1+0.5*vUnit; //move PC witin 2m of chair
        lChair = Location(GetArea(oChair),v1, 270.0+GetFacing(oChair));             //90.0-VectorToAngle(vUnit));
        AssignCommand(oS, ActionMoveToLocation(lChair,FALSE));
*/
      //Move PC to back of chair\\
        v1 = GetPositionFromLocation(lChair);
        v2 = AngleToVector(GetFacing(oChair)); //left of chair //Facing and Vectors seem to be off.
        v2 = v2/VectorMagnitude(v2);
        v1=v1+0.8*v2;
        lChair=Location(GetArea(oChair),v1, 180.0+GetFacing(oChair));
        AssignCommand(oS, ActionMoveToLocation(lChair));

      //Jump PC in front of chair\\
        v1 = GetPositionFromLocation(lChair);
        v2 = AngleToVector(90.0+GetFacing(oChair));  //Facing and Vectors seem to be off.
        v2 = v2/VectorMagnitude(v2);
        v1=v1;//-0.02*v2;
        lChair=Location(GetArea(oChair),v1, 180.0+GetFacing(oChair));       //90.0+GetFacing(oChair));
        //AssignCommand(oS, ActionJumpToLocation(lChair));
        //AssignCommand(oS, ActionJumpToObject(oChair,FALSE)); //Doesn't work well at all.
        AssignCommand(oS, ActionUnequipItem(GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oS)));
        AssignCommand(oS, ActionUnequipItem(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oS)));
        //AssignCommand(oS, SetFacing(GetFacing(oChair)));
        //AssignCommand(oS, ActionPlayAnimation(ANIMATION_LOOPING_SIT_CHAIR,1.0,31415926535897.9));
      AssignCommand(oS,ActionSit(oChair));
   }
}

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This will strip the PC or Container of all Items (non-equipped) including DMFI & 1orpWidgets
void X1st_Item_DestroyNonEquiped(object oContainer)
{
  object oS = oContainer;
  object oItem = GetFirstItemInInventory(oS);
  while (GetIsObjectValid(oItem)==TRUE)
   {
     SetPlotFlag(oItem,FALSE);
     DestroyObject(oItem);
     oItem = GetNextItemInInventory(oS);
   }
}

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This will strip the PC or NPC of all Equipped Items
void X1st_Item_DestroyOnlyEquiped(object oContainer)
{
  object oS = oContainer;
  object oItem;
  int nI;
  for (nI=0;nI<NUM_INVENTORY_SLOTS+1;nI++)
   {
     oItem = GetItemInSlot(nI, oS);
     SetPlotFlag(oItem,FALSE);
     DestroyObject(oItem);
   }
}

//////////////////////////////////////1st Order of Role Players\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//This will ID All items in the PC,NPC or Container
void X1st_Inventory_IDAllItems(object oContainer)
{
    object oS = oContainer;
    object oItem = GetFirstItemInInventory(oS);
    while (GetIsObjectValid(oItem)==TRUE)
     {
       SetIdentified(oItem, TRUE);
       oItem = GetNextItemInInventory(oS);
     }
}

//This function will determine if the item possess any magical properties.
//TRUE means magical, FALSE non-magical.
int n1st_CheckIsItemMagical(object oItem);
int n1st_CheckIsItemMagical(object oItem) //is this all that's needed?!?
{
   return GetIsItemPropertyValid(GetFirstItemProperty(oItem));
}
//This will send a server message to all members of a party.
//oPCofParty is ANY PC within the party. sMessage is the message you want to send.
void f1st_SendMessageToParty(object oPCofParty, string sMessage);
void f1st_SendMessageToParty(object oPCofParty, string sMessage)
{
  object oPC = GetFirstFactionMember(oPCofParty);
  while (GetIsObjectValid(oPC)==TRUE)
   {
     SendMessageToPC(oPC, sMessage);
     oPC = GetNextFactionMember(oPCofParty);
   }
}

//This resets the personal reputation between all members of two factions.
//Works for a PC's Party as well.
void X1st_Faction_ClearFactionReputation(object oFaction1, object oFaction2);
void X1st_Faction_ClearFactionReputation(object oFaction1, object oFaction2)
{
   object oF1 = GetFirstFactionMember(oFaction1);
   object oF2 = GetFirstFactionMember(oFaction2);
    while (GetIsObjectValid(oF1)==TRUE)
     {
        while (GetIsObjectValid(oF2)==TRUE)
         {
           ClearPersonalReputation(oF1,oF2);
           oF2 = GetNextFactionMember(oFaction2);
         }
       oF1 = GetNextFactionMember(oFaction1);
       oF2 = GetFirstFactionMember(oFaction2);
     }

}
//Returns the nNth nearest PC in radius - if none - OBJECT_INVALID is returned
object o1st_GetNearestPCinRadius(int nNth=1, object oOBJ=OBJECT_SELF, float fRadius=10.0);
object o1st_GetNearestPCinRadius(int nNth=1, object oOBJ=OBJECT_SELF, float fRadius=10.0)
{object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC,oOBJ,nNth);
 if (GetDistanceBetween(oOBJ,oPC)>fRadius){oPC=OBJECT_INVALID;}
 return oPC;
}

//Returns the nNth nearest NPC in radius - if none - OBJECT_INVALID is returned
object o1st_GetNearestNPCinRadius(int nNth=1, object oOBJ=OBJECT_SELF, float fRadius=10.0);
object o1st_GetNearestNPCinRadius(int nNth=1, object oOBJ=OBJECT_SELF, float fRadius=10.0)
{object oNPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_NOT_PC,oOBJ,nNth);
 if (GetDistanceBetween(oOBJ,oNPC)>fRadius){oNPC=OBJECT_INVALID;}
 return oNPC;
}

//Checks 2da Row value versus Model Name (returns TRUE or FALSE)
// Current Values for s2DA: "appearance", "wingmodel", "tailmodel", "placeables", or "phenotype"
//Stores information as Variable on Module so that checks only need to be done once/game
//    NOTE for phenotypes sModel is the TLK # (as a string, i.e. "###")
int n1st_2DA_Check(string s2DA, int nRow, string sModel);

//First Checks 2DA Row vs. Model name, if matches, then returns the same Row
//        if no match, it then searches 2da for model name & either returns -1
//        if it cannot find it, or the correct row number.
//       if you set nRow = -1, then it searches the 2DA for sModel, and returns
//       either -1 if it doesn't find it, or the row number if it does.
// Current Values for s2DA: "appearance", "wingmodel", "tailmodel", "placeables", or "phenotype"
// Stores information as Variable on Module to speed up frequent checks on same model.
//    NOTE for phenotypes sModel is the TLK # (as a string, i.e. "###")
int n1st_Get_2DARow(string s2DA, int nRow, string sModel);

//Acquires the Model Name (in lower case) for a row# of a 2da
//        if row # does not exist returns ""  (empty string)
// Current Values for s2DA: "appearance", "wingmodel", "tailmodel", "placeables", or "phenotype"
// Stores information as Variable on Module to speed up frequent checks on same model.
//    NOTE for phenotypes sModel is the TLK # (as a string, i.e. "###")
string s1st_Get_2DAModelName(string s2DA, int nRow);


//Checks object oInventory for an item  (Returns TRUE if found, FALSE if not)
//  To check only sTag, state the TAG Name of the object
//  To check for item by ResRef only, use "" for sTag, and then the sResRef to check for
//  To check for item by NAME only, use "" for sTag & sResRef, and then enter the name to check for
//  To check for item using multiple criteria, specify what to check for, leaving "" for what to bypass
//    i.e. to Check for an item with TAG = "item_001"   and NAME = "Brain of CharlieX" use:
//      n1st_HasItemInInventory(oPC, "item_001", "", "Brain of CharlieX");
int n1st_HasItemInInventory(object oInventory, string sTag, string sResRef="", string sName="");

//Returns the Item object in oInventory's Inventory (or returns OBJECT_INVALID, if it does not exist)
//  To check only sTag, state the TAG Name of the object
//  To check for item by ResRef only, use "" for sTag, and then the sResRef to check for
//  To check for item by NAME only, use "" for sTag & sResRef, and then enter the name to check for
//  To check for item using multiple criteria, specify what to check for, leaving "" for what to bypass
//    i.e. to Check for an item with TAG = "item_001"   and NAME = "Brain of CharlieX" use:
//      n1st_HasItemInInventory(oPC, "item_001", "", "Brain of CharlieX");
object o1st_GetItemInInventory(object oInventory, string sTag, string sResRef="", string sName="");

//Returns the percentage change necessary to alter the creature's walkrate
//Negative Values for slow down, positive for speedup.
//fWalkRate is the rate you want to set.
//fDefaultRate is the walk speed from the Appearances.2da file.
//             this does not need to be set for PC Races and can be left 0.
//Takes into account Haste/Slowed creatures
float f1st_GetSpeed_PercentChange(object oCreature, float fWalkRate, float fDefault_Rate=0.0);

//Remove Effect of Type
// oObject <= Object you want to remove the effect of type from
// int nEffect_Type <= the effect type constant to remove (use constants EFFECT_TYPE_xxxx)
void x1st_Effect_RemoveType(object oObject, int nEffect_Type);

//FUNCTION DEFINITIONS\\
int n1st_2DA_Check(string s2DA, int nRow, string sModel)
{
  string sColumn;
  string sVar_Prefix;
  string sVar;
  string sModelStored;
  int nBool = FALSE;
  int nCheck=FALSE;
  if (nRow<0){return nBool;}
  sModel = GetStringLowerCase(sModel);
  s2DA = GetStringLowerCase(s2DA);

//Acquire Column for Model Names & Establish variable prefix
//"appearance", "wingmodel", "tailmodel", "placeables"
  if (s2DA == "phenotype")
    {sColumn = "Name"; sVar_Prefix = "1o2P2_"; nCheck=TRUE;}

  if (s2DA == "appearance")
    {sColumn = "RACE"; sVar_Prefix = "1o2A1_"; nCheck=TRUE;}

  if (s2DA == "placeables")
    {sColumn = "ModelName";sVar_Prefix = "1o2P1_"; nCheck=TRUE;}

  if (s2DA == "tailmodel")
    {sColumn = "MODEL";sVar_Prefix = "1o2T1_"; nCheck=TRUE;}

  if (s2DA == "wingmodel")
    {sColumn = "MODEL";sVar_Prefix = "1o2W1_"; nCheck=TRUE;}

//Using a valid 2da file for this?
if (nCheck==FALSE){return nCheck;}

//Check Module Variable
  sVar= sVar_Prefix + IntToString(nRow);     //Row can be 1-5, sVar_Suf=6
  sModelStored = GetLocalString(GetModule(), sVar);

  if (sModelStored == sModel){return TRUE;}
  if (sModelStored !=""){return FALSE;} //Case where a different model name is stored

//At this point the local variable has not been initialized.
//Explore 2DA file (in this case only check Row vs Model - do not search)

  sModelStored = Get2DAString(s2DA,sColumn,nRow);
  sModelStored = GetStringLowerCase(sModelStored);
  if (sModelStored == sModel){nBool=TRUE;}
  SetLocalString(GetModule(), sVar, sModelStored);
  return nBool;
}

int n1st_Get_2DARow(string s2DA, int nRow, string sModel)
{
  string sColumn;
  string sVar_Prefix;
  string sVar;
  string sModel2DA;
  int nModelRowStored;

//  int nNeedCoffee = FALSE;
  int nBool   = FALSE;
  int nCheck  = FALSE;
  int nEOF    = 0;    // current row # of 2da. -2 means EOF.

  sModel = GetStringLowerCase(sModel);
  s2DA = GetStringLowerCase(s2DA);

//Adjust sModel length (shouldn't be more than 16, but if it is..)
  if (GetStringLength(sModel)>16){sModel=GetStringLeft(sModel,16);}


//Acquire Column for Model Names & Establish variable prefix
//"appearance", "wingmodel", "tailmodel", "placeables"
  if (s2DA == "phenotype")
    {sColumn = "Name"; sVar_Prefix = "1o2P2_"; nCheck=TRUE;}

  if (s2DA == "appearance")
    {sColumn = "RACE"; sVar_Prefix = "1o2A1_"; nCheck=TRUE;}

  if (s2DA == "placeables")
    {sColumn = "ModelName";sVar_Prefix = "1o2P1_"; nCheck=TRUE;}

  if (s2DA == "tailmodel")
    {sColumn = "MODEL";sVar_Prefix = "1o2T1_"; nCheck=TRUE;}

  if (s2DA == "wingmodel")
    {sColumn = "MODEL";sVar_Prefix = "1o2W1_"; nCheck=TRUE;}

//Using a valid 2da file for this?
if (nCheck==FALSE){return -1;}

//Check Module Variable
  sVar= sVar_Prefix + sModel;
  nModelRowStored = GetLocalInt(GetModule(), sVar);
  nEOF = GetLocalInt(GetModule(), sVar_Prefix + "EOF_RESULT");

  if (nModelRowStored == -1){return -1;}
  if (nModelRowStored != 0){return nModelRowStored;}
  if (nEOF == -2){return -1;}
//  nNeedCoffee=TRUE;            // why -2 for EOF?

//At this point the local variable has not been initialized.
//here we will initialize variables as reading them from the 2DA
// Starting from the last check & ending when the model name is found.
// Also needs to enter an EOF line

//First quick check if nRow is given...
if (nRow!=-1)
 {
   sModel2DA = GetStringLowerCase(Get2DAString(s2DA,sColumn,nRow));
   if (sModel2DA==sModel)
    {
      SetLocalInt(GetModule(), sVar, nRow);
      return nRow;
    }
 }

// Now we need to do the full 2DA search.
// I'd be tempted to try a more complex search rather than linear, but...

//Get last line
nRow=nEOF;
//switch(nNeedCoffee){case TRUE: break;}
//nNeedCoffee=FALSE;
if (nRow<0){nRow=0;}
sModel2DA = GetStringLowerCase(Get2DAString(s2DA,sColumn,nRow));
while (sModel2DA!="")
 {
 // was it found? if so record position and return.
    if (sModel2DA==sModel)
     {
       SetLocalInt(GetModule(), sVar, nRow);
       SetLocalInt(GetModule(), sVar_Prefix + "EOF_RESULT",nRow);
       return nRow;
     }
   nRow++;
   sModel2DA = GetStringLowerCase(Get2DAString(s2DA,sColumn,nRow));
 }

//NOT FOUND & EOF.
 SetLocalInt(GetModule(), sVar_Prefix + "EOF_RESULT",-2);
 return -1;
}


//Acquires the Model Name (in lower case) for a row# of a 2da
//        if row # does not exist returns ""  (empty string)
// Current Values for s2DA: "appearance", "wingmodel", "tailmodel", "placeables", or "phenotype"
// Stores information as Variable on Module to speed up frequent checks on same model.
//    NOTE for phenotypes sModel is the TLK # (as a string, i.e. "###")
string s1st_Get_2DAModelName(string s2DA, int nRow)
{
  if (nRow <0){return "";}

  string sColumn;
  string sVar_Prefix;
  string sVar;
  string sModel;
  int nBool = FALSE;
  int nCheck = FALSE;

  s2DA = GetStringLowerCase(s2DA);

//Acquire Column for Model Names & Establish variable prefix
//"appearance", "wingmodel", "tailmodel", "placeables"
  if (s2DA == "phenotype")
    {sColumn = "Name"; sVar_Prefix = "1o2P2_"; nCheck=TRUE;}

  if (s2DA == "appearance")
    {sColumn = "RACE"; sVar_Prefix = "1o2A1_"; nCheck=TRUE;}

  if (s2DA == "placeables")
    {sColumn = "ModelName";sVar_Prefix = "1o2P1_"; nCheck=TRUE;}

  if (s2DA == "tailmodel")
    {sColumn = "MODEL";sVar_Prefix = "1o2T1_"; nCheck=TRUE;}

  if (s2DA == "wingmodel")
    {sColumn = "MODEL";sVar_Prefix = "1o2W1_"; nCheck=TRUE;}

//Using a valid 2da file for this?
if (nCheck==FALSE){return "";}

//Check Module Variable
  sVar= sVar_Prefix + IntToString(nRow);     //Row can be 1-5, sVar_Suf=6
  sModel = GetLocalString(GetModule(), sVar);

  if (GetStringLength(sModel)>0){return sModel;}

//At this point the local variable has not been initialized.
//Explore 2DA file

  sModel = Get2DAString(s2DA,sColumn,nRow);
  sModel = GetStringLowerCase(sModel);
  SetLocalString(GetModule(), sVar, sModel);
  return sModel;
}




int n1st_HasItemInInventory(object oInventory, string sTag, string sResRef="", string sName="")
{
    if (GetIsObjectValid(oInventory)==FALSE){return FALSE;}
    if (GetHasInventory(oInventory)==FALSE){return FALSE;}

    object oItem = GetFirstItemInInventory(oInventory);
    object oItem2;

    int nBoolTag = FALSE;
    int nBoolResRef = FALSE;
    int nBoolName = FALSE;
    int nTests=0;
    if (sTag!=""){nTests=1;}
    if (sResRef!=""){nTests=nTests+1;}
    if (sName!=""){nTests=nTests+1;}

    while (GetIsObjectValid(oItem)==TRUE)
     {
        nBoolTag    = FALSE;
        nBoolResRef = FALSE;
        nBoolName   = FALSE;

        if ((sTag!="") && (GetTag(oItem)==sTag)) {nBoolTag=TRUE;}
        if ((sResRef!="") && (GetResRef(oItem)==sResRef)) {nBoolResRef=TRUE;}
        if ((sName!="") && (GetName(oItem)==sName)) {nBoolName=TRUE;}
        if (nTests==nBoolTag+nBoolResRef+nBoolName){return TRUE;}


        if (GetHasInventory(oItem)==TRUE)
          {
            oItem2 = GetFirstItemInInventory(oItem);
            while (GetIsObjectValid(oItem2)==TRUE)
              {
                nBoolTag    = FALSE;
                nBoolResRef = FALSE;
                nBoolName   = FALSE;

                if ((sTag!="") && (GetTag(oItem)==sTag)) {nBoolTag=TRUE;}
                if ((sResRef!="") && (GetResRef(oItem)==sResRef)) {nBoolResRef=TRUE;}
                if ((sName!="") && (GetName(oItem)==sName)) {nBoolName=TRUE;}
                if (nTests==nBoolTag+nBoolResRef+nBoolName){return TRUE;}
                oItem2 = GetNextItemInInventory(oItem);
              }
          }

         oItem = GetNextItemInInventory(oInventory);
     }
  return FALSE;
}


object o1st_GetItemInInventory(object oInventory, string sTag, string sResRef="", string sName="")
{
    if (GetIsObjectValid(oInventory)==FALSE){return OBJECT_INVALID;}
    if (GetHasInventory(oInventory)==FALSE){return OBJECT_INVALID;}

    object oItem = GetFirstItemInInventory(oInventory);
    object oItem2;

    int nBoolTag = FALSE;
    int nBoolResRef = FALSE;
    int nBoolName = FALSE;
    int nTests=0;
    if (sTag!=""){nTests=1;}
    if (sResRef!=""){nTests=nTests+1;}
    if (sName!=""){nTests=nTests+1;}

    while (GetIsObjectValid(oItem)==TRUE)
     {
        nBoolTag    = FALSE;
        nBoolResRef = FALSE;
        nBoolName   = FALSE;

        if ((sTag!="") && (GetTag(oItem)==sTag)) {nBoolTag=TRUE;}
        if ((sResRef!="") && (GetResRef(oItem)==sResRef)) {nBoolResRef=TRUE;}
        if ((sName!="") && (GetName(oItem)==sName)) {nBoolName=TRUE;}
        if (nTests==nBoolTag+nBoolResRef+nBoolName){return oItem;}


        if (GetHasInventory(oItem)==TRUE)
          {
            oItem2 = GetFirstItemInInventory(oItem);
            while (GetIsObjectValid(oItem2)==TRUE)
              {
                nBoolTag    = FALSE;
                nBoolResRef = FALSE;
                nBoolName   = FALSE;

                if ((sTag!="") && (GetTag(oItem)==sTag)) {nBoolTag=TRUE;}
                if ((sResRef!="") && (GetResRef(oItem)==sResRef)) {nBoolResRef=TRUE;}
                if ((sName!="") && (GetName(oItem)==sName)) {nBoolName=TRUE;}
                if (nTests==nBoolTag+nBoolResRef+nBoolName){return oItem2;}
                oItem2 = GetNextItemInInventory(oItem);
              }
          }

         oItem = GetNextItemInInventory(oInventory);
     }
  return OBJECT_INVALID;
}


float f1st_GetSpeed_PercentChange(object oCreature, float fWalkRate, float fDefault_Rate=0.0)
{
  int nRace = GetRacialType(oCreature);
  effect eEff;
  float fSpeed_Percent=0.0;
  float fRace_Speed;
  switch (nRace)
   {
      case RACIAL_TYPE_DWARF: fRace_Speed = 1.06; break;
      case RACIAL_TYPE_ELF: fRace_Speed = 1.43; break;
      case RACIAL_TYPE_GNOME: fRace_Speed = 1.0; break;
      case RACIAL_TYPE_HALFLING: fRace_Speed = 1.43; break;
      default: fRace_Speed = 1.6; break;
   }

//Make adjustments for Haste/Slow:
  int nHaste=0;
  int nSlow=0;

  eEff = GetFirstEffect(oCreature);
  while (GetIsEffectValid(eEff)==TRUE)
   {
      if (GetEffectType(eEff) == EFFECT_TYPE_HASTE) {nHaste=1;}
      if (GetEffectType(eEff) == EFFECT_TYPE_SLOW) {nSlow=-1;}
      eEff = GetNextEffect(oCreature);
   }
  nHaste = nHaste+nSlow;

  switch (nHaste)
   {
     case 0:
     break;

     case -1:  //Slow
      fRace_Speed = fRace_Speed - 0.5*fRace_Speed;
     break;

     case 1:   //Haste
      fRace_Speed = fRace_Speed + 0.5*fRace_Speed;
     break;
   }

  fSpeed_Percent = fWalkRate/fRace_Speed - 1.0;

  return fSpeed_Percent;
}

void x1st_Effect_RemoveType(object oObject, int nEffect_Type)
{

    effect eFX = GetFirstEffect(oObject);
    while (GetIsEffectValid(eFX) == TRUE)
     {
       if (GetEffectType(eFX) == nEffect_Type){RemoveEffect(oObject,eFX);}
       eFX = GetNextEffect(oObject);
     }


}




//void main(){}

/*
    PrintString("+================================================+");
    PrintString("+==========   Builders' Compendium     ==========+");
    PrintString("+===                                          ===+");
    PrintString("+===   A 1st Order of Role-Players' Creation  ===+");
    PrintString("+==========      www.1stOrder.net      ==========+");
    PrintString("+================================================+");
