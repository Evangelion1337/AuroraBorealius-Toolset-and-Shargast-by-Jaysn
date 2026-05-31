/** @file
    Primogenitor's Random Equipment Functions

    This include file contains a group of functions that will create equipment
    on the creatures they are called upon.
    The equipment will be just the basic bioware defaults, so you will have to
    add/replace with enchanted versions yourself.
    If the target already has equipment, this will be created and equiped instead.
    However, the AI may restore the other if it is better.

    To use, include this file in a script.
    Then call EquipWeapon, EquipArmor, and/or EquipMisc from the OnSpawn
    Best used if spawned out of combat, otherwise they may not equip
    Aslo, call these after any levelling has been done to use gained feats
    If used on creatures with claws/bites/slams then the handed weapons will be
    used instead of the natural weapons, even if they are inferior.


    @author Primogenitor

    @todo See what functions can be replaced with stuff from inc_utility (and linked files)
*/

#include "prc_misc_const"
#include "prc_feat_const"


//Major PREF function
//spawns a unenchanted weapon randomly picked from
//those most suitable.
//takes into acount feats such as martial proficiency, weapon focus, improved critical
//dual weilding, weapon of choice, and shield proficiency
void EquipWeapon(object oObject = OBJECT_SELF);

//Major PREF function
//spawns a unenchanted armor randomly picked from
//those most suitable
//will spawn clothing as well so you shouldnt have any nudists!
//may not be visible on non-dynamic models such as many monsters
void EquipArmor(object oObject = OBJECT_SELF);

//Major PREF function
//spawns unenchanted other equipment randomly picked
//also adds potions, modified by level
//also adds scrolls, modified by spellcaster level
//also adds healing kits, modified by heal skill
void EquipMisc(object oObject = OBJECT_SELF);

object EquipLightArmor(object oObject);
object EquipMediumArmor(object oObject);
object EquipHeavyArmor(object oObject);
object EquipClothes(object oObject);

void EquipAmmo(object oObject = OBJECT_SELF);
object EquipWeaponOfChoice(object oObject);
object EquipEpicWeaponSpecialization(object oObject);
object EquipWeaponSpecialization(object oObject);
object EquipDevastatingCritical(object oObject);
object EquipEpicWeaponFocus(object oObject);
object EquipOverwhelmingCritical(object oObject);
object EquipImprovedCritical(object oObject);
object EquipWeaponFocus(object oObject);
object EquipWeaponProfDruid(object oObject, int nHands = 1);
object EquipWeaponProfRogue(object oObject, int nHands = 1);
object EquipWeaponProfElf(object oObject, int nHands = 1);
object EquipWeaponProfWizard(object oObject, int nHands = 1);
object EquipWeaponProfSimple(object oObject, int nHands = 1);
object EquipWeaponProfMartial(object oObject, int nHands = 1);
object EquipWeaponProfExotic(object oObject, int nHands = 1);
object EquipShield(object oObject);
void EquipScroll(object oObject);

int GetCanDualWeild(object oObject);
int GetIsLeftHandFree(object oObject, object oWeapon);

int IsItemWeapon(object oItem);
int PrimoGetWeaponSize(object oItem);
string GetBaseResRef(int nBaseItemType);

int EQUIPSPAWNDEBUG = FALSE;//TRUE;

void EquipDebugString(string sDebug)
{
    if(EQUIPSPAWNDEBUG)
    {
        SendMessageToPC(GetFirstPC(), sDebug);
        SendMessageToAllDMs(sDebug);
        WriteTimestampedLogEntry(sDebug);
    }
}

void EquipAmmo(object oObject = OBJECT_SELF)
{
    object oWeapon = oObject;
    oObject = GetItemPossessor(oWeapon);
    int nBaseItemType = GetBaseItemType(oWeapon);
    if (nBaseItemType == BASE_ITEM_DART
        ||nBaseItemType == BASE_ITEM_SHURIKEN
        ||nBaseItemType == BASE_ITEM_THROWINGAXE)
        SetItemStackSize(oWeapon, 99);
    else if (nBaseItemType == BASE_ITEM_HEAVYCROSSBOW
        ||nBaseItemType ==BASE_ITEM_LIGHTCROSSBOW)
    {
        oWeapon = CreateItemOnObject("nw_wambo001", oObject, 99);
        ActionEquipItem(oWeapon, INVENTORY_SLOT_BOLTS);
    }
    else if (nBaseItemType == BASE_ITEM_LONGBOW
        ||nBaseItemType ==BASE_ITEM_SHORTBOW)
    {
        oWeapon = CreateItemOnObject("nw_wamar001", oObject, 99);
        ActionEquipItem(oWeapon, INVENTORY_SLOT_ARROWS);
    }
    else if (nBaseItemType == BASE_ITEM_SLING)
    {
        oWeapon = CreateItemOnObject("nw_wambu001", oObject, 99);
        ActionEquipItem(oWeapon, INVENTORY_SLOT_BULLETS);
    }
    return;
}

string FilledIntToString2(int nX)
{
    string sReturn = "";
    if (nX < 100)
        sReturn = sReturn + "0";
    if (nX < 10)
        sReturn = sReturn + "0";
    sReturn = sReturn + IntToString(nX);
    return sReturn;
}

void EquipWeapon(object oObject = OBJECT_SELF)
{
    object oWeaponLH;
    object oWeaponRH;

    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK,oObject) == TRUE)
    {
        if(GetCanDualWeild(oObject) == TRUE)
        {
            //dual kamas
            oWeaponRH = CreateItemOnObject("nw_wspka001", oObject);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            oWeaponLH = CreateItemOnObject("nw_wspka001", oObject);
            AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            EquipDebugString(GetName(oObject) + "Is dual Kama monk");
            return;
        }
        EquipDebugString(GetName(oObject) + "is Barefist Monk");
        return;//use fists
        //monk weapons
    }
    else if(GetLevelByClass(CLASS_TYPE_WEAPON_MASTER, oObject) > 0)
    {
        oWeaponRH = EquipWeaponOfChoice(oObject);
        EquipAmmo(oWeaponRH);
        AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
        if(GetIsLeftHandFree(oObject, oWeaponRH))
        {
            if(GetCanDualWeild(oObject))
            {
                oWeaponLH = EquipWeaponOfChoice(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
                return;
            }
            else if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oObject))
            {
                oWeaponLH = EquipShield(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
                return;
            }
            else
            {
                oWeaponLH = EquipWeaponOfChoice(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
                return;
            }
        }
        return;
    }
    else if(GetLevelByClass(CLASS_TYPE_FIGHTER, oObject) > 0)
    {
        oWeaponRH = EquipEpicWeaponSpecialization(oObject);
        if(GetIsObjectValid(oWeaponRH))
        {
            EquipAmmo(oWeaponRH);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            if(GetIsLeftHandFree(oObject, oWeaponRH))
            {
                if(GetCanDualWeild(oObject))
                {
                    oWeaponLH = EquipEpicWeaponSpecialization(oObject);
                    AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
                }
                else if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oObject))
                {
                    oWeaponLH = EquipShield(oObject);
                    AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
                }
                else
                {
                    oWeaponLH = EquipEpicWeaponSpecialization(oObject);
                    AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
                }
            }
            return;
        }
        oWeaponRH = EquipWeaponSpecialization(oObject);
        if(GetIsObjectValid(oWeaponRH))
        {
            EquipAmmo(oWeaponRH);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            if(GetIsLeftHandFree(oObject, oWeaponRH))
            {
                if(GetCanDualWeild(oObject))
                {
                    oWeaponLH = EquipWeaponSpecialization(oObject);
                    AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
                }
                else if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oObject))
                {
                    oWeaponLH = EquipShield(oObject);
                    AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
                }
                else
                {
                    oWeaponLH = EquipWeaponSpecialization(oObject);
                    AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
                }
            }
            return;
        }
    }

    oWeaponRH = EquipDevastatingCritical(oObject);
    if(GetIsObjectValid(oWeaponRH))
    {
        EquipAmmo(oWeaponRH);
        AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
        if(GetIsLeftHandFree(oObject, oWeaponRH))
        {
            if(GetCanDualWeild(oObject))
            {
                oWeaponLH = EquipDevastatingCritical(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
            else if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oObject))
            {
                oWeaponLH = EquipShield(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
            else
            {
                oWeaponLH = EquipDevastatingCritical(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
        }
        return;
    }

    oWeaponRH = EquipEpicWeaponFocus(oObject);
    if(GetIsObjectValid(oWeaponRH))
    {
        EquipAmmo(oWeaponRH);
        AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
        if(GetIsLeftHandFree(oObject, oWeaponRH))
        {
            if(GetCanDualWeild(oObject))
            {
                oWeaponLH = EquipEpicWeaponFocus(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
            else if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oObject))
            {
                oWeaponLH = EquipShield(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
            else
            {
                oWeaponLH = EquipEpicWeaponFocus(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
        }
        return;
    }


    oWeaponRH = EquipOverwhelmingCritical(oObject);
    if(GetIsObjectValid(oWeaponRH))
    {
        EquipAmmo(oWeaponRH);
        AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
        if(GetIsLeftHandFree(oObject, oWeaponRH))
        {
            if(GetCanDualWeild(oObject))
            {
                oWeaponLH = EquipOverwhelmingCritical(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
            else if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oObject))
            {
                oWeaponLH = EquipShield(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
            else
            {
                oWeaponLH = EquipOverwhelmingCritical(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
        }
        return;
    }

    oWeaponRH = EquipImprovedCritical(oObject);
    if(GetIsObjectValid(oWeaponRH))
    {
        EquipAmmo(oWeaponRH);
        AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
        if(GetIsLeftHandFree(oObject, oWeaponRH))
        {
            if(GetCanDualWeild(oObject))
            {
                oWeaponLH = EquipImprovedCritical(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
            else if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oObject))
            {
                oWeaponLH = EquipShield(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
            else
            {
                oWeaponLH = EquipImprovedCritical(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
        }
        return;
    }

    oWeaponRH = EquipWeaponFocus(oObject);
    if(GetIsObjectValid(oWeaponRH))
    {
        EquipAmmo(oWeaponRH);
        AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
        if(GetIsLeftHandFree(oObject, oWeaponRH))
        {
            if(GetCanDualWeild(oObject))
            {
                oWeaponLH = EquipWeaponFocus(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
            else if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oObject))
            {
                oWeaponLH = EquipShield(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
            else
            {
                oWeaponLH = EquipWeaponFocus(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
        }
        return;
    }

    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oObject) == TRUE)
    {
        if(GetCanDualWeild(oObject) == TRUE)
        {
            oWeaponRH = EquipWeaponProfDruid(oObject,1);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            if(GetIsLeftHandFree(oObject, oWeaponRH)==TRUE)
            {
                oWeaponLH = EquipWeaponProfDruid(oObject,1);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
            return;
        }
        else if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oObject) == TRUE
            && Random (2) == 1)
        {
            oWeaponRH = EquipWeaponProfDruid(oObject,1);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            if(GetIsLeftHandFree(oObject, oWeaponRH)==TRUE)
            {
                oWeaponLH = EquipShield(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
            return;
        }
        else
        {
            oWeaponRH = EquipWeaponProfDruid(oObject,2);
            EquipAmmo(oWeaponRH);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
        }
        return;
    }
    else if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oObject) == TRUE)
    {
        if(GetCanDualWeild(oObject) == TRUE)
        {
            oWeaponRH = EquipWeaponProfExotic(oObject,1);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            if(GetIsLeftHandFree(oObject, oWeaponRH)==TRUE)
            {
                oWeaponLH = EquipWeaponProfExotic(oObject,1);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
            return;
        }
        else if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oObject) == TRUE
            && Random (2) == 1)
        {
            oWeaponRH = EquipWeaponProfExotic(oObject,1);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            if(GetIsLeftHandFree(oObject, oWeaponRH)==TRUE)
            {
                oWeaponLH = EquipShield(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
            return;
        }
        else
        {
            oWeaponRH = EquipWeaponProfExotic(oObject,2);
            EquipAmmo(oWeaponRH);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
        }
        return;
    }
    else if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oObject) == TRUE)
    {
        if(GetCanDualWeild(oObject) == TRUE)
        {
            oWeaponRH = EquipWeaponProfMartial(oObject,1);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            if(GetIsLeftHandFree(oObject, oWeaponRH)==TRUE)
            {
                oWeaponLH = EquipWeaponProfMartial(oObject,1);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
        }
        else if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oObject) == TRUE
            && Random (2) == 1)
        {
            oWeaponRH = EquipWeaponProfMartial(oObject,1);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            if(GetIsLeftHandFree(oObject, oWeaponRH)==TRUE)
            {
                oWeaponLH = EquipShield(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
        }
        else
        {
            oWeaponRH = EquipWeaponProfMartial(oObject,2);
            EquipAmmo(oWeaponRH);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
        }
        return;
    }
    else if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_ELF, oObject) == TRUE)
    {
        //elves only have accss to medium and large weapons
        //two medium swords, short and long bows
        if(GetCanDualWeild(oObject) == TRUE
            && GetCreatureSize(oObject) >= CREATURE_SIZE_MEDIUM)
        {
            oWeaponRH = EquipWeaponProfElf(oObject,1);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            if(GetIsLeftHandFree(oObject, oWeaponRH)==TRUE)
            {
                oWeaponLH = EquipWeaponProfElf(oObject,1);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
            return;
        }
        else if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oObject) == TRUE
            && GetCreatureSize(oObject) >= CREATURE_SIZE_MEDIUM
            && Random (2) == 1)
        {
            oWeaponRH = EquipWeaponProfElf(oObject,1);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            if(GetIsLeftHandFree(oObject, oWeaponRH)==TRUE)
            {
                oWeaponLH = EquipShield(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
            return;
        }
        else if(GetCreatureSize(oObject) >= CREATURE_SIZE_MEDIUM)
        {
            oWeaponRH = EquipWeaponProfElf(oObject,2);
            EquipAmmo(oWeaponRH);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            return;
        }
        else
        {
            //fall through
        }
    }
    else if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oObject) == TRUE)
    {
        if(GetCanDualWeild(oObject) == TRUE)
        {
            oWeaponRH = EquipWeaponProfRogue(oObject,1);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            if(GetIsLeftHandFree(oObject, oWeaponRH)==TRUE)
            {
                oWeaponLH = EquipWeaponProfRogue(oObject,1);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
        }
        else if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oObject) == TRUE
            && Random (2) == 1)
        {
            oWeaponRH = EquipWeaponProfRogue(oObject,1);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            if(GetIsLeftHandFree(oObject, oWeaponRH)==TRUE)
            {
                oWeaponLH = EquipShield(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
        }
        else
        {
        oWeaponRH = EquipWeaponProfRogue(oObject,2);
        EquipAmmo(oWeaponRH);
        AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
        }
        return;
    }
    else if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oObject) == TRUE)
    {
        if(GetCanDualWeild(oObject) == TRUE)
        {
            oWeaponRH = EquipWeaponProfSimple(oObject,1);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            if(GetIsLeftHandFree(oObject, oWeaponRH)==TRUE)
            {
                oWeaponLH = EquipWeaponProfSimple(oObject,1);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
        }
        else if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oObject) == TRUE
            && Random (2) == 1)
        {
            oWeaponRH = EquipWeaponProfSimple(oObject,1);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            if(GetIsLeftHandFree(oObject, oWeaponRH)==TRUE)
            {
                oWeaponLH = EquipShield(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
        }
        else
        {
        oWeaponRH = EquipWeaponProfSimple(oObject,2);
        EquipAmmo(oWeaponRH);
        AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
        }
        return;
    }
    else if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_WIZARD, oObject) == TRUE)
    {
        if(GetCanDualWeild(oObject) == TRUE)
        {
            oWeaponRH = EquipWeaponProfWizard(oObject,1);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            if(GetIsLeftHandFree(oObject, oWeaponRH)==TRUE)
            {
                oWeaponLH = EquipWeaponProfWizard(oObject,1);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
        }
        else if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oObject) == TRUE
            && Random (2) == 1)
        {
            oWeaponRH = EquipWeaponProfWizard(oObject,1);
            AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
            if(GetIsLeftHandFree(oObject, oWeaponRH)==TRUE)
            {
                oWeaponLH = EquipShield(oObject);
                AssignCommand(oObject, ActionEquipItem(oWeaponLH,INVENTORY_SLOT_LEFTHAND));
            }
        }
        else
        {
        oWeaponRH = EquipWeaponProfWizard(oObject,2);
        EquipAmmo(oWeaponRH);
        AssignCommand(oObject, ActionEquipItem(oWeaponRH,INVENTORY_SLOT_RIGHTHAND));
        }
        return;
    }
}

object EquipWeaponProfSimple(object oObject, int nHands = 1)
{
    int nMaxSize;
    object oItem;
    int nLowNumber;
    int nHighNumber;

    if(nHands < 1 || nHands > 2)
        nHands = Random(2)+1;

    if(nHands == 1)
    {
        nMaxSize = GetCreatureSize(oObject);
        switch (nMaxSize)
        {
        case CREATURE_SIZE_HUGE:
            //fallthrough
        case CREATURE_SIZE_LARGE:
            nLowNumber = 8;
            nHighNumber = 12;
            break;
        case CREATURE_SIZE_MEDIUM:
            nLowNumber = 7;
            nHighNumber = 9;
            break;
        case CREATURE_SIZE_SMALL:
            nLowNumber = 0;
            nHighNumber = 6;
            break;
        case CREATURE_SIZE_TINY:
            nLowNumber = 0;
            nHighNumber = 0;
            break;
        }
    }
    else if(nHands == 2)
    {
        nMaxSize = GetCreatureSize(oObject)+1;
        switch (nMaxSize)
        {
        case CREATURE_SIZE_HUGE:
            //fallthrough
        case CREATURE_SIZE_LARGE:
            nLowNumber = 7;
            nHighNumber = 12;
            break;
        case CREATURE_SIZE_MEDIUM:
            nLowNumber = 6;
            nHighNumber = 12;
            break;
        case CREATURE_SIZE_SMALL:
            nLowNumber = 1;
            nHighNumber = 9;
            break;
        case CREATURE_SIZE_TINY:
            nLowNumber = 0;
            nHighNumber = 0;
            break;
        }
    }

    int nRandom = nLowNumber+Random(nHighNumber-nLowNumber+1);
    string sResRef;
    switch(nRandom)
    {
        //:: Tiny size
        case 0:// Dagger
            sResRef = "nw_wswdg001";
            break; 
			
	//:: Small size
        case 1:// Spear
            sResRef = "nw_wplss001";
            break;
        case 2: // Mace
            sResRef = "nw_wblml001";
            break;
        case 3:// Sickle
            sResRef = "nw_wspsc001";
            break;
        case 4:// Goad
            sResRef = "prc_wspgd001";
            break;					
        case 5:// Dart
            sResRef = "nw_wthdt001";
            break;
        case 6:// Sling
            sResRef = "nw_wbwsl001";
            break;
        case 7:// Light Xbow
            sResRef = "nw_wbwxl001";
            break;
	
	//::  Medium size
        case 8:// Club
            sResRef = "nw_wblcl001";
            break;
        case 9: // Morningstar
            sResRef = "nw_wblms001";
            break;
        case 10: // Heavy Mace
            sResRef = "prc_wxblmh001";
            break;				
        case 11: // Heavy Xbow
            sResRef = "nw_wbwxh001";
            break;
			
	//:: Large size
        case 12:// Quarterstaff
            sResRef = "nw_wdbqs001";
            break;
            //none
    }
    oItem = CreateItemOnObject(sResRef,oObject);
    return oItem;
}

object EquipWeaponProfMartial(object oObject, int nHands = 1)
{
    int nMaxSize;
    object oItem;
    int nLowNumber;
    int nHighNumber;

    if(nHands < 1 || nHands > 2)
        nHands = Random(2)+1;

    if(nHands == 1)
    {
        nMaxSize = GetCreatureSize(oObject);
        switch (nMaxSize)
        {
        case CREATURE_SIZE_HUGE:
            //fallthrough
        case CREATURE_SIZE_LARGE:
            nLowNumber = 14;
            nHighNumber = 20;
            break;
        case CREATURE_SIZE_MEDIUM:
            nLowNumber = 0;
            nHighNumber = 12;
            break;
        case CREATURE_SIZE_SMALL:
            nLowNumber = 0;
            nHighNumber = 5;
            break;
        case CREATURE_SIZE_TINY:
            //no tiny martials
            //use simple instead
            oItem = EquipWeaponProfSimple(oObject, nHands);
            return oItem;
            break;
        }
    }
    else if(nHands == 2)
    {
        nMaxSize = GetCreatureSize(oObject)+1;
        switch (nMaxSize)
        {
        case CREATURE_SIZE_HUGE:
            //fallthrough
        case CREATURE_SIZE_LARGE:
            nLowNumber = 13;
            nHighNumber = 21;
            break;
        case CREATURE_SIZE_MEDIUM:
            nLowNumber = 13;
            nHighNumber = 21;
            break;
        case CREATURE_SIZE_SMALL:
            nLowNumber = 0;
            nHighNumber = 5;
            break;
        case CREATURE_SIZE_TINY:
            //no tiny martials
            //use simple instead
            oItem = EquipWeaponProfSimple(oObject, nHands);
            return oItem;
            break;
        }
    }

    int nRandom = nLowNumber+Random(nHighNumber-nLowNumber+1);
    string sResRef;
    switch(nRandom)
    {
	//:: Tiny size
        // no tiny martials
		
	//:: Small size
        case 0:// Handaxe
            sResRef = "nw_waxhn001";
            break;
        case 1:// Light Hammer
            sResRef = "nw_wblmhl001";
            break;
        case 2:// Short Sword
            sResRef = "nw_wswss001";
            break;
        case 3:// Throwing Axe
            sResRef = "nw_wthax001";
            break;
        case 4:// Light Pick
            sResRef = "prc_wblpl001";
            break;
        case 5:// Sap
            sResRef = "prc_wspsp001";
            break;				
	
	//:: Medium size
        case 6:// Battleaxe
            sResRef = "nw_waxbt001";
            break;
        case 7:// Light Flail
            sResRef = "nw_wblfl001";
            break;
        case 8:// Longsword
            sResRef = "nw_wswls001";
            break;
        case 9:// Rapier
            sResRef = "nw_wswrp001";
            break;
        case 10:// Scimitar
            sResRef = "nw_wswsc001";
            break;
        case 11:// Warhammer
            sResRef = "nw_wblhw001";
			break;
        case 12:// Heavy Pick
			sResRef = "prc_wswhp001";
            break;
        case 13:// Shortbow
            sResRef = "nw_wbwsh001";
            break;
	
	//:: Large size
        case 14:// Greataxe
            sResRef = "nw_waxgr001";
            break;
        case 15:// Greatsword
            sResRef = "nw_wswgs001";
            break;
        case 16:// Halberd
            sResRef = "nw_wplhb001";
            break;
        case 17:// Heavy Flail
            sResRef = "nw_wblfh001";
            break;
        case 18:// Falchion
            sResRef = "prc_wswfa001";
            break;
        case 19:// Maul
            sResRef = "prc_wxblma001";
            break;
        case 20:// Trident
            sResRef = "nw_wpltr001";
            break;	
        case 21:// Longbow
            sResRef = "nw_wbwln001";
            break;
            //none
    }
    oItem = CreateItemOnObject(sResRef,oObject);
    return oItem;
}

object EquipWeaponProfExotic(object oObject, int nHands = 1)
{
    int nMaxSize;
    object oItem;
    int nLowNumber;
    int nHighNumber;

    if(nHands < 1 || nHands > 2)
        nHands = Random(2)+1;

    if(nHands == 1)
    {
        nMaxSize = GetCreatureSize(oObject);
        switch (nMaxSize)
        {
        case CREATURE_SIZE_HUGE:
            //fallthrough
        case CREATURE_SIZE_LARGE:
            nLowNumber = 6;
            nHighNumber = 10;
            break;
        case CREATURE_SIZE_MEDIUM:
            nLowNumber = 3;
            nHighNumber = 5;
            break;
        case CREATURE_SIZE_SMALL:
            nLowNumber = 0;
            nHighNumber = 7;
            break;
        case CREATURE_SIZE_TINY:
            nLowNumber = 0;
            nHighNumber = 4;
            break;
        }
    }
    else if(nHands == 2)
    {
        nMaxSize = GetCreatureSize(oObject)+1;
        switch (nMaxSize)
        {
        case CREATURE_SIZE_HUGE:
            //fallthrough
        case CREATURE_SIZE_LARGE:
            nLowNumber = 15;
            nHighNumber = 10;
            break;
        case CREATURE_SIZE_MEDIUM:
            nLowNumber = 8;
            nHighNumber = 18;
            break;
        case CREATURE_SIZE_SMALL:
            nLowNumber = 5;
            nHighNumber = 7;
            break;
        case CREATURE_SIZE_TINY:
            nLowNumber = 0;
            nHighNumber = 2;
            break;
        }
    }

    int nRandom = nLowNumber+Random(nHighNumber-nLowNumber+1);
    string sResRef;
    switch(nRandom)
    {
	//:: Tiny size
        case 0:// Kama
            sResRef = "nw_wspka001";
            break;
        case 1:// Kukri
            sResRef = "nw_wspku001";
            break;
        case 2:// Sai
            sResRef = "prc_wswsi001";
            break;	
        case 3:// Katar
            sResRef = "prc_wswdp001";
            break;			
        case 4:// Shuriken
            sResRef = "nw_wthsh001";
            break;
			
	//:: Small size
        case 5:// Nunchaku
            sResRef = "prc_wspnn001";
            break;
        case 6:// Elven Lightblade
            sResRef = "prc_wspel001";
            break;		
		case 7:// Eagle Claw
            sResRef = "prc_wswec001";
            break;	
			
	//:: Medium size
        case 8:// Dwarven Waraxe
            sResRef = "x2_wdwraxe001";
            break;
        case 9:// Katana
            sResRef = "nw_wswka001";
            break;
        case 10:// Elven Thinblade
            sResRef = "prc_wspet001";
            break;			
        case 11:// Whip
            sResRef = "x2_it_wpwhip";
            break;
			
    //:: Large size
        case 12:// Bastard Sword
            sResRef = "nw_wswbs001";
            break;
        case 13:// Scythe
            sResRef = "nw_wplsc001";
            break;
        case 14:// Elven Courtblade
            sResRef = "prc_wspec001";
            break;			
        case 15:// Diremace
            sResRef = "nw_wdbma001";
            break;
        case 16:// Double Axe
            sResRef = "nw_wdbax001";
            break;
        case 17:// Double Sword
            sResRef = "nw_wdbsw001";
            break;
		case 18:// Double Scimitar
			sResRef = "prc_wxdbsc001";
            break;
            //none
    }
    oItem = CreateItemOnObject(sResRef,oObject);
    return oItem;
}

void EquipArmor(object oObject = OBJECT_SELF)
{
    object oItem;
    if(GetHasFeat(FEAT_ARMOR_PROFICIENCY_HEAVY, oObject) == TRUE
        && GetLevelByClass(CLASS_TYPE_WIZARD, oObject) == 0
        && GetLevelByClass(CLASS_TYPE_SORCERER, oObject) == 0
        && GetLevelByClass(CLASS_TYPE_BARD, oObject) == 0)
        oItem = EquipHeavyArmor(oObject);
    else if(GetHasFeat(FEAT_ARMOR_PROFICIENCY_MEDIUM, oObject) == TRUE
        && GetLevelByClass(CLASS_TYPE_WIZARD, oObject) == 0
        && GetLevelByClass(CLASS_TYPE_SORCERER, oObject) == 0)
        oItem = EquipMediumArmor(oObject);
    else if(GetHasFeat(FEAT_ARMOR_PROFICIENCY_LIGHT, oObject) == TRUE
        && GetLevelByClass(CLASS_TYPE_WIZARD, oObject) == 0)
        oItem = EquipLightArmor(oObject);
    else
        oItem = EquipClothes(oObject);
    AssignCommand(oObject, ActionEquipItem(oItem, INVENTORY_SLOT_CHEST));
}

void EquipMisc(object oObject = OBJECT_SELF)
{
    int nLevel = GetHitDice(oObject);
    object oItem;
    //other stuff
    //belt
    if((Random(10) + nLevel) > 14)
    {
        oItem = CreateItemOnObject("belt",oObject);
        AssignCommand(oObject, ActionEquipItem(oItem, INVENTORY_SLOT_BELT));
    }
    //boots
    if((Random(10) + nLevel) > 10)
    {
        oItem = CreateItemOnObject("boots",oObject);
        AssignCommand(oObject, ActionEquipItem(oItem, INVENTORY_SLOT_BOOTS));
    }
    //bracers
    if((Random(10) + nLevel) > 15)
    {
        oItem = CreateItemOnObject("bracers",oObject);
       AssignCommand(oObject, ActionEquipItem(oItem, INVENTORY_SLOT_ARMS));
    }
    //amulet
    if((Random(10) + nLevel) > 20)
    {
        oItem = CreateItemOnObject("amulet",oObject);
        AssignCommand(oObject, ActionEquipItem(oItem, INVENTORY_SLOT_NECK));
    }
    //ring
    if((Random(10) + nLevel) > 23)
    {
        oItem = CreateItemOnObject("ring",oObject);
        AssignCommand(oObject, ActionEquipItem(oItem, INVENTORY_SLOT_RIGHTRING));
    }
    if((Random(10) + nLevel) > 23)
    {
        oItem = CreateItemOnObject("ring",oObject);
        AssignCommand(oObject, ActionEquipItem(oItem,INVENTORY_SLOT_LEFTRING));
    }
    //potions
    int nCount = nLevel + d6() - 3;
    int i;
    for (i=1;i<=nCount;i++)
    {
        oItem = CreateItemOnObject("NW_IT_MPOTION"+FilledIntToString2(Random(23)+1),oObject);
        if(GetGoldPieceValue(oItem)>25*nLevel)
            DestroyObject(oItem);
        if(GetGoldPieceValue(oItem)<5*nLevel)
            DestroyObject(oItem);
    }
    //scrolls
    EquipScroll(oObject);
    //healing kits
    nCount = GetSkillRank(SKILL_HEAL, oObject)/5+d6()-3;
    for (i=1;i<=nCount;i++)
    {
        oItem = CreateItemOnObject("nw_it_medkit"+FilledIntToString2(Random(4)+1),oObject);
    }
    //lock picks

}

object EquipShield(object oObject)
{
    int nRandom = Random(3);
    object oItem;
    if(GetCreatureSize(oObject) <=CREATURE_SIZE_SMALL)
            oItem = CreateItemOnObject("nw_ashsw001",oObject);
    else if(GetCreatureSize(oObject) == CREATURE_SIZE_MEDIUM)
            oItem = CreateItemOnObject("nw_ashlw001",oObject);
    else if(GetCreatureSize(oObject) >= CREATURE_SIZE_LARGE)
            oItem = CreateItemOnObject("nw_ashto001",oObject);
    return oItem;
}

object EquipWeaponProfDruid(object oObject, int nHands = 1)
{
    int nMaxSize;
    object oItem;
    int nLowNumber;
    int nHighNumber;

    if(nHands < 1 || nHands > 2)
        nHands = Random(2)+1;

    if(nHands == 1)
    {
        nMaxSize = GetCreatureSize(oObject);
        switch (nMaxSize)
        {
        case CREATURE_SIZE_HUGE:
            //fallthrough
        case CREATURE_SIZE_LARGE:
            nLowNumber = 6;
            nHighNumber = 6;
            break;
        case CREATURE_SIZE_MEDIUM:
            nLowNumber = 5;
            nHighNumber = 5;
            break;
        case CREATURE_SIZE_SMALL:
            nLowNumber = 1;
            nHighNumber = 2;
            break;
        case CREATURE_SIZE_TINY:
            nLowNumber = 0;
            nHighNumber = 0;
            break;
        }
    }
    else if(nHands == 2)
    {
        nMaxSize = GetCreatureSize(oObject)+1;
        switch (nMaxSize)
        {
        case CREATURE_SIZE_HUGE:
            //fallthrough
        case CREATURE_SIZE_LARGE:
            nLowNumber = 6;
            nHighNumber = 6;
            break;
        case CREATURE_SIZE_MEDIUM:
            nLowNumber = 5;
            nHighNumber = 5;
            break;
        case CREATURE_SIZE_SMALL:
            nLowNumber = 1;
            nHighNumber = 4;
            break;
        case CREATURE_SIZE_TINY:
            nLowNumber = 0;
            nHighNumber = 0;
            break;
        }
    }

    int nRandom = nLowNumber+Random(nHighNumber-nLowNumber+1);
    string sResRef;
    switch(nRandom)
    {
        //tiny size
        case 0://dagger
            sResRef = "nw_wswdg001";
            break;
        //small size
        case 1://short spear
            sResRef = "nw_wplss001";
            break;
        case 2://scicle
            sResRef = "nw_wspsc001";
            break;
        case 3://sling
            sResRef = "nw_wbwsl001";
            break;
        case 4://dart
            sResRef = "nw_wthdt001";
            break;
        //medium size
        case 5://scimitar
            sResRef = "nw_wswsc001";
            break;
        //large size
        case 6://quarterstaff
            sResRef = "nw_wdbqs001";
            break;
            //none
    }
    oItem = CreateItemOnObject(sResRef,oObject);
    return oItem;
}

object EquipWeaponProfRogue(object oObject, int nHands = 1)
{
    int nMaxSize;
    object oItem;
    int nLowNumber;
    int nHighNumber;

    if(nHands < 1 || nHands > 2)
        nHands = Random(2)+1;

    if(nHands == 1)
    {
        nMaxSize = GetCreatureSize(oObject);
        switch (nMaxSize)
        {
        case CREATURE_SIZE_HUGE:
            //fallthrough
        case CREATURE_SIZE_LARGE:
            nLowNumber = 13;
            nHighNumber = 13;
            break;
        case CREATURE_SIZE_MEDIUM:
            nLowNumber = 7;
            nHighNumber = 12;
            break;
        case CREATURE_SIZE_SMALL:
            nLowNumber = 1;
            nHighNumber = 5;
            break;
        case CREATURE_SIZE_TINY:
            nLowNumber = 0;
            nHighNumber = 0;
            break;
        }
    }
    else if(nHands == 2)
    {
        nMaxSize = GetCreatureSize(oObject)+1;
        switch (nMaxSize)
        {
        case CREATURE_SIZE_HUGE:
            //fallthrough
        case CREATURE_SIZE_LARGE:
            nLowNumber = 13;
            nHighNumber = 13;
            break;
        case CREATURE_SIZE_MEDIUM:
            nLowNumber = 7;
            nHighNumber = 12;
            break;
        case CREATURE_SIZE_SMALL:
            nLowNumber = 1;
            nHighNumber = 7;
            break;
        case CREATURE_SIZE_TINY:
            nLowNumber = 0;
            nHighNumber = 0;
            break;
        }
    }

    int nRandom = nLowNumber+Random(nHighNumber-nLowNumber+1);
    string sResRef;
    switch(nRandom)
    {
	//:: Tiny size
        case 0:// Dagger
            sResRef = "nw_wswdg001";
            break;
			
    //:: Small size
        case 1:// Light Mace
            sResRef = "w_wblml001";
            break;
        case 2:// Short Sword
            sResRef = "nw_wswss001";
            break;
        case 3:// Handaxe
            sResRef = "nw_waxhn001";
            break;
        case 4:// Sap
            sResRef = "prc_wspsp001";
            break;			
        case 5:// Dart
            sResRef = "nw_wthdt001";
            break;
        case 6:// Sling
            sResRef = "nw_wbwsl001";
            break;
        case 7:// Light Xbow
            sResRef = "nw_wbwxl001";
            break;
			
    //:: Medium size
        case 8://club
            sResRef = "nw_wblcl001";
            break;
        case 9://morning star
            sResRef = "nw_wblms001";
            break;
        case 10://rapier
            sResRef = "nw_wswrp001";
            break;
        case 11://shorbow
            sResRef = "nw_wbwsh001";
            break;
        case 12://heavy xbow
            sResRef = "w_wbwxh001";
            break;
			
	//:: Large size
        case 13://quarterstaff
            sResRef = "nw_wdbqs001";
            break;
    }
    oItem = CreateItemOnObject(sResRef,oObject);
    return oItem;
}

object EquipWeaponProfWizard(object oObject, int nHands = 1)
{
    int nMaxSize;
    object oItem;
    int nLowNumber;
    int nHighNumber;

    if(nHands < 1 || nHands > 2)
        nHands = Random(2)+1;

    if(nHands == 1)
    {
        nMaxSize = GetCreatureSize(oObject);
        switch (nMaxSize)
        {
        case CREATURE_SIZE_HUGE:
            //fallthrough
        case CREATURE_SIZE_LARGE:
            nLowNumber = 4;
            nHighNumber = 4;
            break;
        case CREATURE_SIZE_MEDIUM:
            nLowNumber = 2;
            nHighNumber = 2;
            break;
        case CREATURE_SIZE_SMALL:
        //no small onehanded wizard, fall through
        case CREATURE_SIZE_TINY:
            nLowNumber = 0;
            nHighNumber = 0;
            break;
        }
    }
    else if(nHands == 2)
    {
        nMaxSize = GetCreatureSize(oObject)+1;
        switch (nMaxSize)
        {
        case CREATURE_SIZE_HUGE:
            //fallthrough
        case CREATURE_SIZE_LARGE:
            nLowNumber = 4;
            nHighNumber = 4;
            break;
        case CREATURE_SIZE_MEDIUM:
            nLowNumber = 2;
            nHighNumber = 3;
            break;
        case CREATURE_SIZE_SMALL:
            nLowNumber = 1;
            nHighNumber = 1;
            break;
        case CREATURE_SIZE_TINY:
            nLowNumber = 0;
            nHighNumber = 0;
            break;
        }
    }

    int nRandom = nLowNumber+Random(nHighNumber-nLowNumber+1);
    string sResRef;
    switch(nRandom)
    {
        //tiny size
        case 0://dagger
            sResRef = "nw_wswdg001";
            break;
        //small size
        case 1://light xbow
            sResRef = "nw_wbwxl001";
            break;
        //medium size
        case 2://club
            sResRef = "nw_wblcl001";
            break;
        case 3://heavy xbow
            sResRef = "w_wbwxh001";
            break;
        //large size
        case 4://quarterstaff
            sResRef = "nw_wdbqs001";
            break;
    }
    oItem = CreateItemOnObject(sResRef,oObject);
    return oItem;
}

object EquipWeaponProfElf(object oObject, int nHands = 1)
{
    int nMaxSize;
    object oItem;
    int nLowNumber;
    int nHighNumber;

    if(nHands < 1 || nHands > 2)
        nHands = Random(2)+1;

    if(nHands == 1)
    {
        nMaxSize = GetCreatureSize(oObject);
        switch (nMaxSize)
        {
        case CREATURE_SIZE_HUGE:
            //fallthrough
        case CREATURE_SIZE_LARGE:
            //fallthrough
        case CREATURE_SIZE_MEDIUM:
            nLowNumber = 0;
            nHighNumber = 1;
            break;
            //should never happen to be small or tiny
        case CREATURE_SIZE_SMALL:
        case CREATURE_SIZE_TINY:
        return OBJECT_INVALID;
        }
    }
    else if(nHands == 2)
    {
        nMaxSize = GetCreatureSize(oObject)+1;
        switch (nMaxSize)
        {
        case CREATURE_SIZE_HUGE:
            //fallthrough
        case CREATURE_SIZE_LARGE:
            nLowNumber = 3;
            nHighNumber = 3;
            break;
        case CREATURE_SIZE_MEDIUM:
            nLowNumber = 0;
            nHighNumber = 2;
            break;
        case CREATURE_SIZE_SMALL:
        case CREATURE_SIZE_TINY:
        return OBJECT_INVALID;
        }
    }

    int nRandom = nLowNumber+Random(nHighNumber-nLowNumber+1);
    string sResRef;
    switch(nRandom)
    {
	//:: Tiny size
            // No tiny
			
    //:: Small size
			// No small
			
	//:: Medium size
        case 0:// Rapier
            sResRef = "nw_wswrp001";
            break;
        case 1:// Longsword
            sResRef = "nw_wswls001";
            break;
        case 2:// Short Bow
            sResRef = "nw_wbwsh001";
            break;
			
    //:: Large size
        case 3:// Longbow
            sResRef = "nw_wbwln001";
            break;
    }
    oItem = CreateItemOnObject(sResRef,oObject);
    return oItem;

}

object EquipWeaponOfChoice(object oObject)
{
    string sResRef;
    if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_BASTARDSWORD, oObject))
        sResRef = "nw_wswbs001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_BATTLEAXE, oObject))
        sResRef = "nw_waxbt001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_CLUB, oObject))
        sResRef = "nw_wblcl001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_DAGGER, oObject))
        sResRef = "nw_wswdg001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_DIREMACE, oObject))
        sResRef = "nw_wdbma001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_DOUBLEAXE, oObject))
        sResRef = "nw_wdbax001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_DWAXE, oObject))
        sResRef = "x2_wdwraxe001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_GREATAXE, oObject))
        sResRef = "nw_waxgr001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_GREATSWORD, oObject))
        sResRef = "nw_wswgs001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_HALBERD, oObject))
        sResRef = "nw_wplhb001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_HANDAXE, oObject))
        sResRef = "nw_waxhn001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_HEAVYFLAIL, oObject))
        sResRef = "nw_wblfh001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_KAMA, oObject))
        sResRef = "nw_wspka001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_KATANA, oObject))
        sResRef = "nw_wswka001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_KUKRI, oObject))
        sResRef = "nw_wspku001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_LIGHTFLAIL, oObject))
        sResRef = "nw_wblfl001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_LIGHTHAMMER, oObject))
        sResRef = "nw_wblmhl001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_LIGHTMACE, oObject))
        sResRef = "w_wblml001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_LONGSWORD, oObject))
        sResRef = "nw_wswls001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_MORNINGSTAR, oObject))
        sResRef = "nw_wblms001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_QUARTERSTAFF, oObject))
        sResRef = "nw_wdbqs001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_RAPIER, oObject))
        sResRef = "nw_wswrp001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_SCIMITAR, oObject))
        sResRef = "nw_wswsc001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_SCYTHE, oObject))
        sResRef = "nw_wplsc001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_SHORTSPEAR, oObject))
        sResRef = "nw_wplss001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_SHORTSWORD, oObject))
        sResRef = "nw_wswss001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_SICKLE, oObject))
        sResRef = "nw_wspsc001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_TWOBLADEDSWORD, oObject))
        sResRef = "nw_wdbsw001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_WARHAMMER, oObject))
        sResRef = "nw_wblhw001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_DBL_SCIMITAR , oObject))
        sResRef = "prc_wxdbsc001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_EAGLE_CLAW , oObject))
        sResRef = "prc_wswec001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_ELVEN_COURTBLADE, oObject))
        sResRef = "prc_wspec001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_ELVEN_LIGHTBLADE, oObject))
        sResRef = "prc_wspel001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_ELVEN_THINBLADE, oObject))
        sResRef = "prc_wspet001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_FALCHION, oObject))
        sResRef = "prc_wswfa001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_GOAD, oObject))
        sResRef = "prc_wspgd001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_HEAVY_MACE, oObject))
        sResRef = "prc_wxblmh001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_HEAVY_PICK, oObject))
        sResRef = "prc_wswhp001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_KATAR, oObject))
        sResRef = "prc_wswdp001";	
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_LIGHT_LANCE, oObject))
        sResRef = "prc_wpllc001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_LIGHT_PICK, oObject))
        sResRef = "prc_wblpl001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_MAUL, oObject))
        sResRef = "prc_wxblma001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_NUNCHAKU, oObject))
        sResRef = "prc_wspnn001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_SAI, oObject))
        sResRef = "prc_wswsi001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_SAP, oObject))
        sResRef = "prc_wswsi001";
    else if(GetHasFeat(FEAT_WEAPON_OF_CHOICE_TRIDENT, oObject))
        sResRef = "nw_wpltr001";
	
    if(sResRef == "")
        return OBJECT_INVALID;
    object oItem = CreateItemOnObject(sResRef,oObject);
    EquipDebugString(GetName(oObject) + " has WeaponOfChoice "+GetName(oItem));
    return oItem;
}

object EquipEpicWeaponSpecialization(object oObject)
{
    int nRandom = Random(55);
    int nStartingPoint = nRandom;
    int nBaseItemType = -1;
    int bFirst = TRUE;
    while(nBaseItemType == -1)
    {
        switch(nRandom)
        {
            case 0:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_BASTARDSWORD,oObject))
                    nBaseItemType = BASE_ITEM_BASTARDSWORD;
                break;
            case 1:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_BATTLEAXE,oObject))
                    nBaseItemType = BASE_ITEM_BATTLEAXE;
                break;
            case 2:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_CLUB,oObject))
                    nBaseItemType = BASE_ITEM_CLUB;
                break;
            case 3:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_DAGGER,oObject))
                    nBaseItemType = BASE_ITEM_DAGGER;
                break;
            case 4:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_DART,oObject))
                    nBaseItemType = BASE_ITEM_DART;
                break;
            case 5:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_DIREMACE,oObject))
                    nBaseItemType = BASE_ITEM_DIREMACE;
                break;
            case 6:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_DOUBLEAXE,oObject))
                    nBaseItemType = BASE_ITEM_DOUBLEAXE;
                break;
            case 7:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_DWAXE,oObject))
                    nBaseItemType = BASE_ITEM_DWARVENWARAXE;
                break;
            case 8:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_GREATAXE,oObject))
                    nBaseItemType = BASE_ITEM_GREATAXE;
                break;
            case 9:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_GREATSWORD,oObject))
                    nBaseItemType = BASE_ITEM_GREATSWORD;
                break;
            case 10:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_HALBERD,oObject))
                    nBaseItemType = BASE_ITEM_HALBERD;
                break;
            case 11:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_HANDAXE,oObject))
                    nBaseItemType = BASE_ITEM_HANDAXE;
                break;
            case 12:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_HEAVYCROSSBOW,oObject))
                    nBaseItemType = BASE_ITEM_HEAVYCROSSBOW;
                break;
            case 13:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_HEAVYFLAIL,oObject))
                    nBaseItemType = BASE_ITEM_HEAVYFLAIL;
                break;
            case 14:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_KAMA,oObject))
                    nBaseItemType = BASE_ITEM_KAMA;
                break;
            case 15:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_KATANA,oObject))
                    nBaseItemType = BASE_ITEM_KATANA;
                break;
            case 16:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_KUKRI,oObject))
                    nBaseItemType = BASE_ITEM_KUKRI;
                break;
            case 17:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHTCROSSBOW,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTCROSSBOW;
                break;
            case 18:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHTFLAIL,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTFLAIL;
                break;
            case 19:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHTHAMMER,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTHAMMER;
                break;
            case 20:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHTMACE,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTMACE;
                break;
            case 21:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_LONGBOW,oObject))
                    nBaseItemType = BASE_ITEM_LONGBOW;
                break;
            case 22:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_LONGSWORD,oObject))
                    nBaseItemType = BASE_ITEM_LONGSWORD;
                break;
            case 23:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_MORNINGSTAR,oObject))
                    nBaseItemType = BASE_ITEM_MORNINGSTAR;
                break;
            case 24:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_QUARTERSTAFF,oObject))
                    nBaseItemType = BASE_ITEM_QUARTERSTAFF;
                break;
            case 25:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_RAPIER,oObject))
                    nBaseItemType = BASE_ITEM_RAPIER;
                break;
            case 26:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_SCIMITAR,oObject))
                    nBaseItemType = BASE_ITEM_SCIMITAR;
                break;
            case 27:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_SCYTHE,oObject))
                    nBaseItemType = BASE_ITEM_SCYTHE;
                break;
            case 28:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_SHORTBOW,oObject))
                    nBaseItemType = BASE_ITEM_SHORTBOW;
                break;
            case 29:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_SHORTSPEAR,oObject))
                    nBaseItemType = BASE_ITEM_SHORTSPEAR;
                break;
            case 30:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_SHORTSWORD,oObject))
                    nBaseItemType = BASE_ITEM_SHORTSWORD;
                break;
            case 31:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_SHURIKEN,oObject))
                    nBaseItemType = BASE_ITEM_SHURIKEN;
                break;
            case 32:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_SICKLE,oObject))
                    nBaseItemType = BASE_ITEM_SICKLE;
                break;
            case 33:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_SLING,oObject))
                    nBaseItemType = BASE_ITEM_SLING;
                break;
            case 34:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_THROWINGAXE,oObject))
                    nBaseItemType = BASE_ITEM_THROWINGAXE;
                break;
            case 35:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_TWOBLADEDSWORD,oObject))
                    nBaseItemType = BASE_ITEM_TWOBLADEDSWORD;
                break;
            case 36:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_WARHAMMER,oObject))
                    nBaseItemType = BASE_ITEM_WARHAMMER;
                break;
            case 37:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_EAGLE_CLAW,oObject))
                    nBaseItemType = BASE_ITEM_EAGLE_CLAW;
                break;
            case 38:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_LIGHTBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_LIGHTBLADE;
                break;
            case 39:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_THINBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_THINBLADE;
                break;
            case 40:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_KATAR,oObject))
                    nBaseItemType = BASE_ITEM_KATAR;
                break;
            case 41:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_NUNCHAKU,oObject))
                    nBaseItemType = BASE_ITEM_NUNCHAKU;
                break;
            case 42:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_SAI,oObject))
                    nBaseItemType = BASE_ITEM_SAI;
                break;
            case 43:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHT_PICK,oObject))
                    nBaseItemType = BASE_ITEM_LIGHT_PICK;
                break;
            case 44:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_SAP,oObject))
                    nBaseItemType = BASE_ITEM_SAP;
                break;
            case 45:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_GOAD,oObject))
                    nBaseItemType = BASE_ITEM_GOAD;
                break;
            case 46:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_HEAVY_PICK,oObject))
                    nBaseItemType = BASE_ITEM_HEAVY_PICK;
                break;
            case 47:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_HEAVY_MACE,oObject))
                    nBaseItemType = BASE_ITEM_HEAVY_MACE;
                break;
            case 48:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_ELVEN_COURTBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_COURTBLADE;
                break;
            case 49:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_DBL_SCIMITAR,oObject))
                    nBaseItemType = BASE_ITEM_DOUBLE_SCIMITAR;
                break;
            case 60:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_FALCHION,oObject))
                    nBaseItemType = BASE_ITEM_FALCHION;
                break;
            case 51:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_LIGHT_LANCE,oObject))
                    nBaseItemType = BASE_ITEM_LIGHT_LANCE;
                break;
            case 52:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_MAUL,oObject))
                    nBaseItemType = BASE_ITEM_MAUL;
                break;
            case 53:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_TRIDENT,oObject))
                    nBaseItemType = BASE_ITEM_TRIDENT;
                break;
            case 54:
                if(GetHasFeat(FEAT_EPIC_WEAPON_SPECIALIZATION_WHIP,oObject))
                    nBaseItemType = BASE_ITEM_WHIP;
                break;
				
        }
        if(nBaseItemType == -1)
        {
            nRandom++;
            if(nRandom >=55 )
                nRandom = 0;
            if(nRandom == nStartingPoint
                && bFirst == FALSE)
                nBaseItemType = -2;
        }
        bFirst = FALSE;
    }
    if(nBaseItemType == -2)
        return OBJECT_INVALID;
    object oItem = CreateItemOnObject(GetBaseResRef(nBaseItemType),oObject);
    EquipDebugString(GetName(oObject) + " has EpicWeaponSpec "+GetName(oItem));
    return oItem;
}

object EquipWeaponSpecialization(object oObject)
{
    int nRandom = Random(55);
    int nStartingPoint = nRandom;
    int nBaseItemType = -1;
    int bFirst = TRUE;
    while(nBaseItemType == -1)
    {
        switch(nRandom)
        {
            case 0:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_BASTARD_SWORD,oObject))
                    nBaseItemType = BASE_ITEM_BASTARDSWORD;
                break;
            case 1:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_BATTLE_AXE,oObject))
                    nBaseItemType = BASE_ITEM_BATTLEAXE;
                break;
            case 2:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_CLUB,oObject))
                    nBaseItemType = BASE_ITEM_CLUB;
                break;
            case 3:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DAGGER,oObject))
                    nBaseItemType = BASE_ITEM_DAGGER;
                break;
            case 4:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DART,oObject))
                    nBaseItemType = BASE_ITEM_DART;
                break;
            case 5:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DIRE_MACE,oObject))
                    nBaseItemType = BASE_ITEM_DIREMACE;
                break;
            case 6:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DOUBLE_AXE,oObject))
                    nBaseItemType = BASE_ITEM_DOUBLEAXE;
                break;
            case 7:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DWAXE,oObject))
                    nBaseItemType = BASE_ITEM_DWARVENWARAXE;
                break;
            case 8:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_GREAT_AXE,oObject))
                    nBaseItemType = BASE_ITEM_GREATAXE;
                break;
            case 9:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_GREAT_SWORD,oObject))
                    nBaseItemType = BASE_ITEM_GREATSWORD;
                break;
            case 10:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HALBERD,oObject))
                    nBaseItemType = BASE_ITEM_HALBERD;
                break;
            case 11:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HAND_AXE,oObject))
                    nBaseItemType = BASE_ITEM_HANDAXE;
                break;
            case 12:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HEAVY_CROSSBOW,oObject))
                    nBaseItemType = BASE_ITEM_HEAVYCROSSBOW;
                break;
            case 13:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HEAVY_FLAIL,oObject))
                    nBaseItemType = BASE_ITEM_HEAVYFLAIL;
                break;
            case 14:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_KAMA,oObject))
                    nBaseItemType = BASE_ITEM_KAMA;
                break;
            case 15:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_KATANA,oObject))
                    nBaseItemType = BASE_ITEM_KATANA;
                break;
            case 16:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_KUKRI,oObject))
                    nBaseItemType = BASE_ITEM_KUKRI;
                break;
            case 17:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_CROSSBOW,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTCROSSBOW;
                break;
            case 18:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_FLAIL,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTFLAIL;
                break;
            case 19:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_HAMMER,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTHAMMER;
                break;
            case 20:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_MACE,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTMACE;
                break;
            case 21:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LONG_SWORD,oObject))
                    nBaseItemType = BASE_ITEM_LONGSWORD;
                break;
            case 22:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LONGBOW,oObject))
                    nBaseItemType = BASE_ITEM_LONGBOW;
                break;
            case 23:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_MORNING_STAR,oObject))
                    nBaseItemType = BASE_ITEM_MORNINGSTAR;
                break;
            case 24:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_STAFF,oObject))
                    nBaseItemType = BASE_ITEM_QUARTERSTAFF;
                break;
            case 25:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_RAPIER,oObject))
                    nBaseItemType = BASE_ITEM_RAPIER;
                break;
            case 26:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SCIMITAR,oObject))
                    nBaseItemType = BASE_ITEM_SCIMITAR;
                break;
            case 27:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SCYTHE,oObject))
                    nBaseItemType = BASE_ITEM_SCYTHE;
                break;
            case 28:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SHORT_SWORD,oObject))
                    nBaseItemType = BASE_ITEM_SHORTSWORD;
                break;
            case 29:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SHORTBOW,oObject))
                    nBaseItemType = BASE_ITEM_SHORTBOW;
                break;
            case 30:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SHURIKEN,oObject))
                    nBaseItemType = BASE_ITEM_SHURIKEN;
                break;
            case 31:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SICKLE,oObject))
                    nBaseItemType = BASE_ITEM_SICKLE;
                break;
            case 32:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SLING,oObject))
                    nBaseItemType = BASE_ITEM_SLING;
                break;
            case 33:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SPEAR,oObject))
                    nBaseItemType = BASE_ITEM_SHORTSPEAR;
                break;
            case 34:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_THROWING_AXE,oObject))
                    nBaseItemType = BASE_ITEM_THROWINGAXE;
                break;
            case 35:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_TWO_BLADED_SWORD,oObject))
                    nBaseItemType = BASE_ITEM_TWOBLADEDSWORD;
                break;
            case 36:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_WAR_HAMMER,oObject))
                    nBaseItemType = BASE_ITEM_WARHAMMER;
                break;
            case 37:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_EAGLE_CLAW,oObject))
                    nBaseItemType = BASE_ITEM_EAGLE_CLAW;
                break;
            case 38:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_ELVEN_LIGHTBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_LIGHTBLADE;
                break;
            case 39:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_ELVEN_THINBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_THINBLADE;
                break;
            case 40:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_KATAR,oObject))
                    nBaseItemType = BASE_ITEM_KATAR;
                break;
            case 41:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_NUNCHAKU,oObject))
                    nBaseItemType = BASE_ITEM_NUNCHAKU;
                break;
            case 42:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SAI,oObject))
                    nBaseItemType = BASE_ITEM_SAI;
                break;
            case 43:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_PICK,oObject))
                    nBaseItemType = BASE_ITEM_LIGHT_PICK;
                break;
            case 44:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SAP,oObject))
                    nBaseItemType = BASE_ITEM_SAP;
                break;
            case 45:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_GOAD,oObject))
                    nBaseItemType = BASE_ITEM_GOAD;
                break;
            case 46:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HEAVY_PICK,oObject))
                    nBaseItemType = BASE_ITEM_HEAVY_PICK;
                break;
            case 47:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HEAVY_MACE,oObject))
                    nBaseItemType = BASE_ITEM_HEAVY_MACE;
                break;
            case 48:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_ELVEN_COURTBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_COURTBLADE;
                break;	
            case 49:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DBL_SCIMITAR,oObject))
                    nBaseItemType = BASE_ITEM_DOUBLE_SCIMITAR;
                break;	
            case 50:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_FALCHION,oObject))
                    nBaseItemType = BASE_ITEM_FALCHION;
                break;	
            case 51:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_LANCE,oObject))
                    nBaseItemType = BASE_ITEM_LIGHT_LANCE;
                break;	
            case 52:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_MAUL,oObject))
                    nBaseItemType = BASE_ITEM_MAUL;
                break;	
            case 53:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_TRIDENT,oObject))
                    nBaseItemType = BASE_ITEM_TRIDENT;
                break;		
            case 54:
                if(GetHasFeat(FEAT_WEAPON_SPECIALIZATION_WHIP,oObject))
                    nBaseItemType = BASE_ITEM_WHIP;
                break;						
        }
        if(nBaseItemType == -1)
        {
            nRandom++;
            if(nRandom >=55 )
                nRandom = 0;
            if(nRandom == nStartingPoint
                && bFirst == FALSE)
                nBaseItemType = -2;
        }
        bFirst = FALSE;
    }
    if(nBaseItemType == -2)
        return OBJECT_INVALID;
    object oItem = CreateItemOnObject(GetBaseResRef(nBaseItemType),oObject);
    EquipDebugString(GetName(oObject) + " has WeaponSpec "+GetName(oItem));
    return oItem;
}

object EquipDevastatingCritical(object oObject)
{
    int nRandom = Random(55);
    int nStartingPoint = nRandom;
    int nBaseItemType = -1;
    int bFirst = TRUE;
    while(nBaseItemType == -1)
    {
        switch(nRandom)
        {
            case 0:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_BASTARDSWORD,oObject))
                    nBaseItemType = BASE_ITEM_BASTARDSWORD;
                break;
            case 1:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_BATTLEAXE,oObject))
                    nBaseItemType = BASE_ITEM_BATTLEAXE;
                break;
            case 2:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_CLUB,oObject))
                    nBaseItemType = BASE_ITEM_CLUB;
                break;
            case 3:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_DAGGER,oObject))
                    nBaseItemType = BASE_ITEM_DAGGER;
                break;
            case 4:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_DART,oObject))
                    nBaseItemType = BASE_ITEM_DART;
                break;
            case 5:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_DIREMACE,oObject))
                    nBaseItemType = BASE_ITEM_DIREMACE;
                break;
            case 6:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_DOUBLEAXE,oObject))
                    nBaseItemType = BASE_ITEM_DOUBLEAXE;
                break;
            case 7:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_DWAXE,oObject))
                    nBaseItemType = BASE_ITEM_DWARVENWARAXE;
                break;
            case 8:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_GREATAXE,oObject))
                    nBaseItemType = BASE_ITEM_GREATAXE;
                break;
            case 9:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_GREATSWORD,oObject))
                    nBaseItemType = BASE_ITEM_GREATSWORD;
                break;
            case 10:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_HALBERD,oObject))
                    nBaseItemType = BASE_ITEM_HALBERD;
                break;
            case 11:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_HANDAXE,oObject))
                    nBaseItemType = BASE_ITEM_HANDAXE;
                break;
            case 12:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_HEAVYCROSSBOW,oObject))
                    nBaseItemType = BASE_ITEM_HEAVYCROSSBOW;
                break;
            case 13:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_HEAVYFLAIL,oObject))
                    nBaseItemType = BASE_ITEM_HEAVYFLAIL;
                break;
            case 14:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_KAMA,oObject))
                    nBaseItemType = BASE_ITEM_KAMA;
                break;
            case 15:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_KATANA,oObject))
                    nBaseItemType = BASE_ITEM_KATANA;
                break;
            case 16:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_KUKRI,oObject))
                    nBaseItemType = BASE_ITEM_KUKRI;
                break;
            case 17:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_LIGHTCROSSBOW,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTCROSSBOW;
                break;
            case 18:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_LIGHTFLAIL,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTFLAIL;
                break;
            case 19:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_LIGHTHAMMER,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTHAMMER;
                break;
            case 20:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_LIGHTMACE,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTMACE;
                break;
            case 21:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_LONGBOW,oObject))
                    nBaseItemType = BASE_ITEM_LONGBOW;
                break;
            case 22:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_LONGSWORD,oObject))
                    nBaseItemType = BASE_ITEM_LONGSWORD;
                break;
            case 23:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_MORNINGSTAR,oObject))
                    nBaseItemType = BASE_ITEM_MORNINGSTAR;
                break;
            case 24:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_QUARTERSTAFF,oObject))
                    nBaseItemType = BASE_ITEM_QUARTERSTAFF;
                break;
            case 25:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_RAPIER,oObject))
                    nBaseItemType = BASE_ITEM_RAPIER;
                break;
            case 26:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_SCIMITAR,oObject))
                    nBaseItemType = BASE_ITEM_SCIMITAR;
                break;
            case 27:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_SCYTHE,oObject))
                    nBaseItemType = BASE_ITEM_SCYTHE;
                break;
            case 28:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_SHORTBOW,oObject))
                    nBaseItemType = BASE_ITEM_SHORTBOW;
                break;
            case 29:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_SHORTSPEAR,oObject))
                    nBaseItemType = BASE_ITEM_SHORTSPEAR;
                break;
            case 30:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_SHORTSWORD,oObject))
                    nBaseItemType = BASE_ITEM_SHORTSWORD;
                break;
            case 31:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_SHURIKEN,oObject))
                    nBaseItemType = BASE_ITEM_SHURIKEN;
                break;
            case 32:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_SICKLE,oObject))
                    nBaseItemType = BASE_ITEM_SICKLE;
                break;
            case 33:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_SLING,oObject))
                    nBaseItemType = BASE_ITEM_SLING;
                break;
            case 34:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_THROWINGAXE,oObject))
                    nBaseItemType = BASE_ITEM_THROWINGAXE;
                break;
            case 35:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_TWOBLADEDSWORD,oObject))
                    nBaseItemType = BASE_ITEM_TWOBLADEDSWORD;
                break;
            case 36:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_WARHAMMER,oObject))
                    nBaseItemType = BASE_ITEM_WARHAMMER;
                break;
            case 37:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_EAGLE_CLAW,oObject))
                    nBaseItemType = BASE_ITEM_EAGLE_CLAW;
                break;
            case 38:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_ELVEN_LIGHTBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_LIGHTBLADE;
                break;
            case 39:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_ELVEN_THINBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_THINBLADE;
                break;
            case 40:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_KATAR,oObject))
                    nBaseItemType = BASE_ITEM_KATAR;
                break;
            case 41:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_NUNCHAKU,oObject))
                    nBaseItemType = BASE_ITEM_NUNCHAKU;
                break;
            case 42:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_SAI,oObject))
                    nBaseItemType = BASE_ITEM_SAI;
                break;
            case 43:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_LIGHT_PICK,oObject))
                    nBaseItemType = BASE_ITEM_LIGHT_PICK;
                break;
            case 44:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_SAP,oObject))
                    nBaseItemType = BASE_ITEM_SAP;
                break;
            case 45:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_GOAD,oObject))
                    nBaseItemType = BASE_ITEM_GOAD;
                break;
            case 46:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_HEAVY_PICK,oObject))
                    nBaseItemType = BASE_ITEM_HEAVY_PICK;
                break;
            case 47:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_HEAVY_MACE,oObject))
                    nBaseItemType = BASE_ITEM_HEAVY_MACE;
                break;	
            case 48:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_ELVEN_COURTBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_COURTBLADE;
                break;	
            case 49:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_DBL_SCIMITAR,oObject))
                    nBaseItemType = BASE_ITEM_DOUBLE_SCIMITAR;
                break;	
            case 50:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_FALCHION,oObject))
                    nBaseItemType = BASE_ITEM_FALCHION;
                break;	
            case 51:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_LIGHT_LANCE,oObject))
                    nBaseItemType = BASE_ITEM_LIGHT_LANCE;
                break;	
            case 52:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_MAUL,oObject))
                    nBaseItemType = BASE_ITEM_MAUL;
                break;	
            case 53:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_TRIDENT,oObject))
                    nBaseItemType = BASE_ITEM_TRIDENT;
                break;	
            case 54:
                if(GetHasFeat(FEAT_EPIC_DEVASTATING_CRITICAL_WHIP,oObject))
                    nBaseItemType = BASE_ITEM_WHIP;
                break;					
        }
        if(nBaseItemType == -1)
        {
            nRandom++;
            if(nRandom >=55 )
                nRandom = 0;
            if(nRandom == nStartingPoint
                && bFirst == FALSE)
                nBaseItemType = -2;
        }
        bFirst = FALSE;
    }
    if(nBaseItemType == -2)
        return OBJECT_INVALID;
    object oItem = CreateItemOnObject(GetBaseResRef(nBaseItemType),oObject);
    EquipDebugString(GetName(oObject) + " has DevCrit "+GetName(oItem));
    return oItem;
}

object EquipEpicWeaponFocus(object oObject)
{
    int nRandom = Random(55);
    int nStartingPoint = nRandom;
    int nBaseItemType = -1;
    int bFirst = TRUE;
    while(nBaseItemType == -1)
    {
        switch(nRandom)
        {
            case 0:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_BASTARDSWORD,oObject))
                    nBaseItemType = BASE_ITEM_BASTARDSWORD;
                break;
            case 1:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_BATTLEAXE,oObject))
                    nBaseItemType = BASE_ITEM_BATTLEAXE;
                break;
            case 2:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_CLUB,oObject))
                    nBaseItemType = BASE_ITEM_CLUB;
                break;
            case 3:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_DAGGER,oObject))
                    nBaseItemType = BASE_ITEM_DAGGER;
                break;
            case 4:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_DART,oObject))
                    nBaseItemType = BASE_ITEM_DART;
                break;
            case 5:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_DIREMACE,oObject))
                    nBaseItemType = BASE_ITEM_DIREMACE;
                break;
            case 6:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_DOUBLEAXE,oObject))
                    nBaseItemType = BASE_ITEM_DOUBLEAXE;
                break;
            case 7:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_DWAXE,oObject))
                    nBaseItemType = BASE_ITEM_DWARVENWARAXE;
                break;
            case 8:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_GREATAXE,oObject))
                    nBaseItemType = BASE_ITEM_GREATAXE;
                break;
            case 9:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_GREATSWORD,oObject))
                    nBaseItemType = BASE_ITEM_GREATSWORD;
                break;
            case 10:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_HALBERD,oObject))
                    nBaseItemType = BASE_ITEM_HALBERD;
                break;
            case 11:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_HANDAXE,oObject))
                    nBaseItemType = BASE_ITEM_HANDAXE;
                break;
            case 12:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_HEAVYCROSSBOW,oObject))
                    nBaseItemType = BASE_ITEM_HEAVYCROSSBOW;
                break;
            case 13:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_HEAVYFLAIL,oObject))
                    nBaseItemType = BASE_ITEM_HEAVYFLAIL;
                break;
            case 14:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_KAMA,oObject))
                    nBaseItemType = BASE_ITEM_KAMA;
                break;
            case 15:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_KATANA,oObject))
                    nBaseItemType = BASE_ITEM_KATANA;
                break;
            case 16:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_KUKRI,oObject))
                    nBaseItemType = BASE_ITEM_KUKRI;
                break;
            case 17:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_LIGHTCROSSBOW,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTCROSSBOW;
                break;
            case 18:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_LIGHTFLAIL,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTFLAIL;
                break;
            case 19:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_LIGHTHAMMER,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTHAMMER;
                break;
            case 20:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_LIGHTMACE,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTMACE;
                break;
            case 21:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_LONGBOW,oObject))
                    nBaseItemType = BASE_ITEM_LONGBOW;
                break;
            case 22:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_LONGSWORD,oObject))
                    nBaseItemType = BASE_ITEM_LONGSWORD;
                break;
            case 23:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_MORNINGSTAR,oObject))
                    nBaseItemType = BASE_ITEM_MORNINGSTAR;
                break;
            case 24:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_QUARTERSTAFF,oObject))
                    nBaseItemType = BASE_ITEM_QUARTERSTAFF;
                break;
            case 25:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_RAPIER,oObject))
                    nBaseItemType = BASE_ITEM_RAPIER;
                break;
            case 26:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_SCIMITAR,oObject))
                    nBaseItemType = BASE_ITEM_SCIMITAR;
                break;
            case 27:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_SCYTHE,oObject))
                    nBaseItemType = BASE_ITEM_SCYTHE;
                break;
            case 28:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_SHORTBOW,oObject))
                    nBaseItemType = BASE_ITEM_SHORTBOW;
                break;
            case 29:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_SHORTSPEAR,oObject))
                    nBaseItemType = BASE_ITEM_SHORTSPEAR;
                break;
            case 30:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_SHORTSWORD,oObject))
                    nBaseItemType = BASE_ITEM_SHORTSWORD;
                break;
            case 31:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_SHURIKEN,oObject))
                    nBaseItemType = BASE_ITEM_SHURIKEN;
                break;
            case 32:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_SICKLE,oObject))
                    nBaseItemType = BASE_ITEM_SICKLE;
                break;
            case 33:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_SLING,oObject))
                    nBaseItemType = BASE_ITEM_SLING;
                break;
            case 34:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_THROWINGAXE,oObject))
                    nBaseItemType = BASE_ITEM_THROWINGAXE;
                break;
            case 35:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_TWOBLADEDSWORD,oObject))
                    nBaseItemType = BASE_ITEM_TWOBLADEDSWORD;
                break;
            case 36:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_WARHAMMER,oObject))
                    nBaseItemType = BASE_ITEM_WARHAMMER;
                break;
            case 37:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_EAGLE_CLAW,oObject))
                    nBaseItemType = BASE_ITEM_EAGLE_CLAW;
                break;
            case 38:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_ELVEN_LIGHTBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_LIGHTBLADE;
                break;
            case 39:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_ELVEN_THINBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_THINBLADE;
                break;
            case 40:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_KATAR,oObject))
                    nBaseItemType = BASE_ITEM_KATAR;
                break;
            case 41:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_NUNCHAKU,oObject))
                    nBaseItemType = BASE_ITEM_NUNCHAKU;
                break;				
            case 42:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_SAI,oObject))
                    nBaseItemType = BASE_ITEM_SAI;
                break;	
            case 43:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_LIGHT_PICK,oObject))
                    nBaseItemType = BASE_ITEM_LIGHT_PICK;
                break;
            case 44:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_SAP,oObject))
                    nBaseItemType = BASE_ITEM_SAP;
                break;
            case 45:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_GOAD,oObject))
                    nBaseItemType = BASE_ITEM_GOAD;
                break;
            case 46:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_HEAVY_PICK,oObject))
                    nBaseItemType = BASE_ITEM_HEAVY_PICK;
                break;
            case 47:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_HEAVY_MACE,oObject))
                    nBaseItemType = BASE_ITEM_HEAVY_MACE;
                break;
            case 48:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_ELVEN_COURTBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_COURTBLADE;
                break;
            case 49:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_DBL_SCIMITAR,oObject))
                    nBaseItemType = BASE_ITEM_DOUBLE_SCIMITAR;
                break;
            case 50:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_FALCHION,oObject))
                    nBaseItemType = BASE_ITEM_FALCHION;
                break;						
            case 51:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_LIGHT_LANCE,oObject))
                    nBaseItemType = BASE_ITEM_LIGHT_LANCE;
                break;	
            case 52:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_MAUL,oObject))
                    nBaseItemType = BASE_ITEM_MAUL;
                break;	
            case 53:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_TRIDENT,oObject))
                    nBaseItemType = BASE_ITEM_TRIDENT;
                break;					
            case 54:
                if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_WHIP,oObject))
                    nBaseItemType = BASE_ITEM_WHIP;
                break;	
				
        }
        if(nBaseItemType == -1)
        {
            nRandom++;
            if(nRandom >=55 )
                nRandom = 0;
            if(nRandom == nStartingPoint
                && bFirst == FALSE)
                nBaseItemType = -2;
        }
        bFirst = FALSE;
    }
    if(nBaseItemType == -2)
        return OBJECT_INVALID;
    object oItem = CreateItemOnObject(GetBaseResRef(nBaseItemType),oObject);
    EquipDebugString(GetName(oObject) + " has EpicWeaponFocus "+GetName(oItem));
    return oItem;
}

object EquipOverwhelmingCritical(object oObject)
{
    int nRandom = Random(55);
    int nStartingPoint = nRandom;
    int nBaseItemType = -1;
    int bFirst = TRUE;
    while(nBaseItemType == -1)
    {
        switch(nRandom)
        {
            case 0:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_BASTARDSWORD,oObject))
                    nBaseItemType = BASE_ITEM_BASTARDSWORD;
                break;
            case 1:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_BATTLEAXE,oObject))
                    nBaseItemType = BASE_ITEM_BATTLEAXE;
                break;
            case 2:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_CLUB,oObject))
                    nBaseItemType = BASE_ITEM_CLUB;
                break;
            case 3:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_DAGGER,oObject))
                    nBaseItemType = BASE_ITEM_DAGGER;
                break;
            case 4:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_DART,oObject))
                    nBaseItemType = BASE_ITEM_DART;
                break;
            case 5:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_DIREMACE,oObject))
                    nBaseItemType = BASE_ITEM_DIREMACE;
                break;
            case 6:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_DOUBLEAXE,oObject))
                    nBaseItemType = BASE_ITEM_DOUBLEAXE;
                break;
            case 7:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_DWAXE,oObject))
                    nBaseItemType = BASE_ITEM_DWARVENWARAXE;
                break;
            case 8:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_GREATAXE,oObject))
                    nBaseItemType = BASE_ITEM_GREATAXE;
                break;
            case 9:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_GREATSWORD,oObject))
                    nBaseItemType = BASE_ITEM_GREATSWORD;
                break;
            case 10:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_HALBERD,oObject))
                    nBaseItemType = BASE_ITEM_HALBERD;
                break;
            case 11:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_HANDAXE,oObject))
                    nBaseItemType = BASE_ITEM_HANDAXE;
                break;
            case 12:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_HEAVYCROSSBOW,oObject))
                    nBaseItemType = BASE_ITEM_HEAVYCROSSBOW;
                break;
            case 13:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_HEAVYFLAIL,oObject))
                    nBaseItemType = BASE_ITEM_HEAVYFLAIL;
                break;
            case 14:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_KAMA,oObject))
                    nBaseItemType = BASE_ITEM_KAMA;
                break;
            case 15:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_KATANA,oObject))
                    nBaseItemType = BASE_ITEM_KATANA;
                break;
            case 16:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_KUKRI,oObject))
                    nBaseItemType = BASE_ITEM_KUKRI;
                break;
            case 17:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHTCROSSBOW,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTCROSSBOW;
                break;
            case 18:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHTFLAIL,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTFLAIL;
                break;
            case 19:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHTHAMMER,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTHAMMER;
                break;
            case 20:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHTMACE,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTMACE;
                break;
            case 21:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_LONGBOW,oObject))
                    nBaseItemType = BASE_ITEM_LONGBOW;
                break;
            case 22:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_LONGSWORD,oObject))
                    nBaseItemType = BASE_ITEM_LONGSWORD;
                break;
            case 23:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_MORNINGSTAR,oObject))
                    nBaseItemType = BASE_ITEM_MORNINGSTAR;
                break;
            case 24:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_QUARTERSTAFF,oObject))
                    nBaseItemType = BASE_ITEM_QUARTERSTAFF;
                break;
            case 25:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_RAPIER,oObject))
                    nBaseItemType = BASE_ITEM_RAPIER;
                break;
            case 26:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_SCIMITAR,oObject))
                    nBaseItemType = BASE_ITEM_SCIMITAR;
                break;
            case 27:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_SCYTHE,oObject))
                    nBaseItemType = BASE_ITEM_SCYTHE;
                break;
            case 28:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_SHORTBOW,oObject))
                    nBaseItemType = BASE_ITEM_SHORTBOW;
                break;
            case 29:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_SHORTSPEAR,oObject))
                    nBaseItemType = BASE_ITEM_SHORTSPEAR;
                break;
            case 30:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_SHORTSWORD,oObject))
                    nBaseItemType = BASE_ITEM_SHORTSWORD;
                break;
            case 31:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_SHURIKEN,oObject))
                    nBaseItemType = BASE_ITEM_SHURIKEN;
                break;
            case 32:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_SICKLE,oObject))
                    nBaseItemType = BASE_ITEM_SICKLE;
                break;
            case 33:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_SLING,oObject))
                    nBaseItemType = BASE_ITEM_SLING;
                break;
            case 34:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_THROWINGAXE,oObject))
                    nBaseItemType = BASE_ITEM_THROWINGAXE;
                break;
            case 35:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_TWOBLADEDSWORD,oObject))
                    nBaseItemType = BASE_ITEM_TWOBLADEDSWORD;
                break;
            case 36:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_WARHAMMER,oObject))
                    nBaseItemType = BASE_ITEM_WARHAMMER;
                break;
			case 37:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_EAGLE_CLAW,oObject))
                    nBaseItemType = BASE_ITEM_EAGLE_CLAW;
                break;
			case 38:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_ELVEN_LIGHTBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_LIGHTBLADE;
                break;				
			case 39:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_ELVEN_THINBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_THINBLADE;
                break;					
			case 40:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_KATAR,oObject))
                    nBaseItemType = BASE_ITEM_KATAR;
                break;				
			case 41:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_NUNCHAKU,oObject))
                    nBaseItemType = BASE_ITEM_NUNCHAKU;
                break;	
			case 42:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_SAI,oObject))
                    nBaseItemType = BASE_ITEM_SAI;
                break;	
			case 43:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHT_PICK,oObject))
                    nBaseItemType = BASE_ITEM_LIGHT_PICK;
                break;	
			case 44:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_SAP,oObject))
                    nBaseItemType = BASE_ITEM_SAP;
                break;	
			case 45:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_GOAD,oObject))
                    nBaseItemType = BASE_ITEM_GOAD;
                break;	
			case 46:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_HEAVY_PICK,oObject))
                    nBaseItemType = BASE_ITEM_HEAVY_PICK;
                break;					
			case 47:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_HEAVY_MACE,oObject))
                    nBaseItemType = BASE_ITEM_HEAVY_MACE;
                break;				
			case 48:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_ELVEN_COURTBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_COURTBLADE;
                break;					
			case 49:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_DBL_SCIMITAR,oObject))
                    nBaseItemType = BASE_ITEM_DOUBLE_SCIMITAR;
                break;
			case 50:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_FALCHION,oObject))
                    nBaseItemType = BASE_ITEM_FALCHION;
                break;				
			case 51:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_LIGHT_LANCE,oObject))
                    nBaseItemType = BASE_ITEM_LIGHT_LANCE;
                break;	
			case 52:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_MAUL,oObject))
                    nBaseItemType = BASE_ITEM_MAUL;
                break;	
			case 53:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_TRIDENT,oObject))
                    nBaseItemType = BASE_ITEM_TRIDENT;
                break;					
			case 54:
                if(GetHasFeat(FEAT_EPIC_OVERWHELMING_CRITICAL_WHIP,oObject))
                    nBaseItemType = BASE_ITEM_WHIP;
                break;				
        }
        if(nBaseItemType == -1)
        {
            nRandom++;
            if(nRandom >=55 )
                nRandom = 0;
            if(nRandom == nStartingPoint
                && bFirst == FALSE)
                nBaseItemType = -2;
        }
        bFirst = FALSE;
    }
    if(nBaseItemType == -2)
        return OBJECT_INVALID;
    object oItem = CreateItemOnObject(GetBaseResRef(nBaseItemType),oObject);
    EquipDebugString(GetName(oObject) + " has OverCrit "+GetName(oItem));
    return oItem;
}

object EquipImprovedCritical(object oObject)
{
    int nRandom = Random(55);
    int nStartingPoint = nRandom;
    int nBaseItemType = -1;
    int bFirst = TRUE;
    while(nBaseItemType == -1)
    {
        switch(nRandom)
        {
            case 0:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_BASTARD_SWORD,oObject))
                    nBaseItemType = BASE_ITEM_BASTARDSWORD;
                break;
            case 1:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_BATTLE_AXE,oObject))
                    nBaseItemType = BASE_ITEM_BATTLEAXE;
                break;
            case 2:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_CLUB,oObject))
                    nBaseItemType = BASE_ITEM_CLUB;
                break;
            case 3:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_DAGGER,oObject))
                    nBaseItemType = BASE_ITEM_DAGGER;
                break;
            case 4:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_DART,oObject))
                    nBaseItemType = BASE_ITEM_DART;
                break;
            case 5:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_DIRE_MACE,oObject))
                    nBaseItemType = BASE_ITEM_DIREMACE;
                break;
            case 6:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_DOUBLE_AXE,oObject))
                    nBaseItemType = BASE_ITEM_DOUBLEAXE;
                break;
            case 7:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_DWAXE,oObject))
                    nBaseItemType = BASE_ITEM_DWARVENWARAXE;
                break;
            case 8:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_GREAT_AXE,oObject))
                    nBaseItemType = BASE_ITEM_GREATAXE;
                break;
            case 9:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_GREAT_SWORD,oObject))
                    nBaseItemType = BASE_ITEM_GREATSWORD;
                break;
            case 10:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_HALBERD,oObject))
                    nBaseItemType = BASE_ITEM_HALBERD;
                break;
            case 11:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_HAND_AXE,oObject))
                    nBaseItemType = BASE_ITEM_HANDAXE;
                break;
            case 12:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_HEAVY_CROSSBOW,oObject))
                    nBaseItemType = BASE_ITEM_HEAVYCROSSBOW;
                break;
            case 13:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_HEAVY_FLAIL,oObject))
                    nBaseItemType = BASE_ITEM_HEAVYFLAIL;
                break;
            case 14:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_KAMA,oObject))
                    nBaseItemType = BASE_ITEM_KAMA;
                break;
            case 15:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_KATANA,oObject))
                    nBaseItemType = BASE_ITEM_KATANA;
                break;
            case 16:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_KUKRI,oObject))
                    nBaseItemType = BASE_ITEM_KUKRI;
                break;
            case 17:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_CROSSBOW,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTCROSSBOW;
                break;
            case 18:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_FLAIL,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTFLAIL;
                break;
            case 19:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_HAMMER,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTHAMMER;
                break;
            case 20:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_MACE,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTMACE;
                break;
            case 21:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_LONG_SWORD,oObject))
                    nBaseItemType = BASE_ITEM_LONGSWORD;
                break;
            case 22:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_LONGBOW,oObject))
                    nBaseItemType = BASE_ITEM_LONGBOW;
                break;
            case 23:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_MORNING_STAR,oObject))
                    nBaseItemType = BASE_ITEM_MORNINGSTAR;
                break;
            case 24:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_STAFF,oObject))
                    nBaseItemType = BASE_ITEM_QUARTERSTAFF;
                break;
            case 25:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_RAPIER,oObject))
                    nBaseItemType = BASE_ITEM_RAPIER;
                break;
            case 26:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_SCIMITAR,oObject))
                    nBaseItemType = BASE_ITEM_SCIMITAR;
                break;
            case 27:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_SCYTHE,oObject))
                    nBaseItemType = BASE_ITEM_SCYTHE;
                break;
            case 28:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_SHORT_SWORD,oObject))
                    nBaseItemType = BASE_ITEM_SHORTSWORD;
                break;
            case 29:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_SHORTBOW,oObject))
                    nBaseItemType = BASE_ITEM_SHORTBOW;
                break;
            case 30:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_SHURIKEN,oObject))
                    nBaseItemType = BASE_ITEM_SHURIKEN;
                break;
            case 31:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_SICKLE,oObject))
                    nBaseItemType = BASE_ITEM_SICKLE;
                break;
            case 32:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_SLING,oObject))
                    nBaseItemType = BASE_ITEM_SLING;
                break;
            case 33:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_SPEAR,oObject))
                    nBaseItemType = BASE_ITEM_SHORTSPEAR;
                break;
            case 34:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_THROWING_AXE,oObject))
                    nBaseItemType = BASE_ITEM_THROWINGAXE;
                break;
            case 35:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_TWO_BLADED_SWORD,oObject))
                    nBaseItemType = BASE_ITEM_TWOBLADEDSWORD;
                break;
            case 36:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_WAR_HAMMER,oObject))
                    nBaseItemType = BASE_ITEM_WARHAMMER;
            case 37:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_EAGLE_CLAW,oObject))
                    nBaseItemType = BASE_ITEM_EAGLE_CLAW;				
            case 38:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_ELVEN_LIGHTBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_LIGHTBLADE;
            case 39:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_ELVEN_THINBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_THINBLADE;
            case 40:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_KATAR,oObject))
                    nBaseItemType = BASE_ITEM_KATAR;
            case 41:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_NUNCHAKU,oObject))
                    nBaseItemType = BASE_ITEM_NUNCHAKU;
            case 42:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_SAI,oObject))
                    nBaseItemType = BASE_ITEM_SAI;
            case 43:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_PICK,oObject))
                    nBaseItemType = BASE_ITEM_LIGHT_PICK;
            case 44:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_SAP,oObject))
                    nBaseItemType = BASE_ITEM_SAP;
            case 45:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_GOAD,oObject))
                    nBaseItemType = BASE_ITEM_GOAD;
            case 46:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_HEAVY_PICK,oObject))
                    nBaseItemType = BASE_ITEM_HEAVY_PICK;		
            case 47:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_HEAVY_MACE,oObject))
                    nBaseItemType = BASE_ITEM_HEAVY_MACE;	
            case 48:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_ELVEN_COURTBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_COURTBLADE;
            case 49:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_DBL_SCIMITAR,oObject))
                    nBaseItemType = BASE_ITEM_DOUBLE_SCIMITAR;
            case 50:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_FALCHION,oObject))
                    nBaseItemType = BASE_ITEM_FALCHION;
            case 51:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_LANCE,oObject))
                    nBaseItemType = BASE_ITEM_LIGHT_LANCE;				
            case 52:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_MAUL,oObject))
                    nBaseItemType = BASE_ITEM_MAUL;					
            case 53:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_TRIDENT,oObject))
                    nBaseItemType = BASE_ITEM_TRIDENT;
			case 54:
                if(GetHasFeat(FEAT_IMPROVED_CRITICAL_WHIP,oObject))
                    nBaseItemType = BASE_ITEM_WHIP;							
                break;
        }
        if(nBaseItemType == -1)
        {
            nRandom++;
            if(nRandom >=55 )
                nRandom = 0;
            if(nRandom == nStartingPoint
                && bFirst == FALSE)
                nBaseItemType = -2;
        }
        bFirst = FALSE;
    }
    if(nBaseItemType == -2)
        return OBJECT_INVALID;
    object oItem = CreateItemOnObject(GetBaseResRef(nBaseItemType),oObject);
    EquipDebugString(GetName(oObject) + " has ImpCrit "+GetName(oItem));
    return oItem;
}

object EquipWeaponFocus(object oObject)
{
    int nRandom = Random(55);
    int nStartingPoint = nRandom;
    int nBaseItemType = -1;
    int bFirst = TRUE;
    while(nBaseItemType == -1)
    {
        switch(nRandom)
        {
            case 0:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_BASTARD_SWORD,oObject))
                    nBaseItemType = BASE_ITEM_BASTARDSWORD;
                break;
            case 1:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_BATTLE_AXE,oObject))
                    nBaseItemType = BASE_ITEM_BATTLEAXE;
                break;
            case 2:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_CLUB,oObject))
                    nBaseItemType = BASE_ITEM_CLUB;
                break;
            case 3:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_DAGGER,oObject))
                    nBaseItemType = BASE_ITEM_DAGGER;
                break;
            case 4:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_DART,oObject))
                    nBaseItemType = BASE_ITEM_DART;
                break;
            case 5:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_DIRE_MACE,oObject))
                    nBaseItemType = BASE_ITEM_DIREMACE;
                break;
            case 6:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_DOUBLE_AXE,oObject))
                    nBaseItemType = BASE_ITEM_DOUBLEAXE;
                break;
            case 7:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_DWAXE,oObject))
                    nBaseItemType = BASE_ITEM_DWARVENWARAXE;
                break;
            case 8:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_AXE,oObject))
                    nBaseItemType = BASE_ITEM_GREATAXE;
                break;
            case 9:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_SWORD,oObject))
                    nBaseItemType = BASE_ITEM_GREATSWORD;
                break;
            case 10:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_HALBERD,oObject))
                    nBaseItemType = BASE_ITEM_HALBERD;
                break;
            case 11:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_HAND_AXE,oObject))
                    nBaseItemType = BASE_ITEM_HANDAXE;
                break;
            case 12:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_CROSSBOW,oObject))
                    nBaseItemType = BASE_ITEM_HEAVYCROSSBOW;
                break;
            case 13:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_FLAIL,oObject))
                    nBaseItemType = BASE_ITEM_HEAVYFLAIL;
                break;
            case 14:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_KAMA,oObject))
                    nBaseItemType = BASE_ITEM_KAMA;
                break;
            case 15:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_KATANA,oObject))
                    nBaseItemType = BASE_ITEM_KATANA;
                break;
            case 16:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_KUKRI,oObject))
                    nBaseItemType = BASE_ITEM_KUKRI;
                break;
            case 17:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_CROSSBOW,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTCROSSBOW;
                break;
            case 18:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_FLAIL,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTFLAIL;
                break;
            case 19:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_HAMMER,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTHAMMER;
                break;
            case 20:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_MACE,oObject))
                    nBaseItemType = BASE_ITEM_LIGHTMACE;
                break;
            case 21:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_LONG_SWORD,oObject))
                    nBaseItemType = BASE_ITEM_LONGSWORD;
                break;
            case 22:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_LONGBOW,oObject))
                    nBaseItemType = BASE_ITEM_LONGBOW;
                break;
            case 23:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_MORNING_STAR,oObject))
                    nBaseItemType = BASE_ITEM_MORNINGSTAR;
                break;
            case 24:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_STAFF,oObject))
                    nBaseItemType = BASE_ITEM_QUARTERSTAFF;
                break;
            case 25:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_RAPIER,oObject))
                    nBaseItemType = BASE_ITEM_RAPIER;
                break;
            case 26:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_SCIMITAR,oObject))
                    nBaseItemType = BASE_ITEM_SCIMITAR;
                break;
            case 27:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_SCYTHE,oObject))
                    nBaseItemType = BASE_ITEM_SCYTHE;
                break;
            case 28:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_SHORT_SWORD,oObject))
                    nBaseItemType = BASE_ITEM_SHORTSWORD;
                break;
            case 29:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_SHORTBOW,oObject))
                    nBaseItemType = BASE_ITEM_SHORTBOW;
                break;
            case 30:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_SHURIKEN,oObject))
                    nBaseItemType = BASE_ITEM_SHURIKEN;
                break;
            case 31:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_SICKLE,oObject))
                    nBaseItemType = BASE_ITEM_SICKLE;
                break;
            case 32:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_SLING,oObject))
                    nBaseItemType = BASE_ITEM_SLING;
                break;
            case 33:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_SPEAR,oObject))
                    nBaseItemType = BASE_ITEM_SHORTSPEAR;
                break;
            case 34:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_THROWING_AXE,oObject))
                    nBaseItemType = BASE_ITEM_THROWINGAXE;
                break;
            case 35:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_TWO_BLADED_SWORD,oObject))
                    nBaseItemType = BASE_ITEM_TWOBLADEDSWORD;
                break;
            case 36:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_WAR_HAMMER,oObject))
                    nBaseItemType = BASE_ITEM_WARHAMMER;
				break;
            case 37:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_WHIP,oObject))
                    nBaseItemType = BASE_ITEM_WHIP;
				break;
            case 38:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_PICK,oObject))
                    nBaseItemType = BASE_ITEM_HEAVY_PICK;
				break;
            case 39:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_PICK,oObject))
                    nBaseItemType = BASE_ITEM_LIGHT_PICK;
				break;
            case 40:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_SAI,oObject))
                    nBaseItemType = BASE_ITEM_SAI;
				break;
            case 41:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_NUNCHAKU,oObject))
                    nBaseItemType = BASE_ITEM_NUNCHAKU;
				break;
            case 42:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_FALCHION,oObject))
                    nBaseItemType = BASE_ITEM_FALCHION;
				break;
            case 43:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_SAP,oObject))
                    nBaseItemType = BASE_ITEM_SAP;
				break;
            case 44:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_KATAR,oObject))
                    nBaseItemType = BASE_ITEM_KATAR;
				break;
            case 45:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_MACE,oObject))
                    nBaseItemType = BASE_ITEM_HEAVY_MACE;
				break;
            case 46:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_MAUL,oObject))
                    nBaseItemType = BASE_ITEM_MAUL;				
                break;
            case 47:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_DOUBLE_SCIMITAR,oObject))
                    nBaseItemType = BASE_ITEM_DOUBLE_SCIMITAR;				
                break;
            case 48:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_GOAD,oObject))
                    nBaseItemType = BASE_ITEM_GOAD;				
                break;
            case 49:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_EAGLE_CLAW,oObject))
                    nBaseItemType = BASE_ITEM_EAGLE_CLAW;				
                break;
            case 50:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_ELVEN_LIGHTBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_LIGHTBLADE;				
                break;
            case 51:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_ELVEN_THINBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_THINBLADE;				
                break;
            case 52:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_ELVEN_COURTBLADE,oObject))
                    nBaseItemType = BASE_ITEM_ELVEN_COURTBLADE;				
                break;
            case 53:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_TRIDENT,oObject))
                    nBaseItemType = BASE_ITEM_TRIDENT;				
                break;
            case 54:
                if(GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_LANCE,oObject))
                    nBaseItemType = BASE_ITEM_LIGHT_LANCE;				
                break;					
        }
        if(nBaseItemType == -1)
        {
            nRandom++;
            if(nRandom >=55 )
                nRandom = 0;
            if(nRandom == nStartingPoint
                && bFirst == FALSE)
                nBaseItemType = -2;
        }
        bFirst = FALSE;
    }
    if(nBaseItemType == -2)
        return OBJECT_INVALID;
    object oItem = CreateItemOnObject(GetBaseResRef(nBaseItemType),oObject);
    EquipDebugString(GetName(oObject) + " has WeaponFocus "+GetName(oItem));
    return oItem;
}

int GetCanDualWeild(object oObject)
{
    if(GetHasFeat(FEAT_AMBIDEXTERITY,oObject) == TRUE
        && d4()==1)
        return TRUE;
    if(GetHasFeat(FEAT_TWO_WEAPON_FIGHTING,oObject) == TRUE
        && d4()==1)
        return TRUE;
    if(GetHasFeat(FEAT_IMPROVED_TWO_WEAPON_FIGHTING,oObject) == TRUE
        && d2()==1)
        return TRUE;
    if(GetHasFeat(374,oObject) == TRUE
        && d2()==1)//ranger dual-wielding
        return TRUE;
    return FALSE;
}

int GetIsLeftHandFree(object oObject, object oWeapon)
{
    int nWeaponSize = PrimoGetWeaponSize(oWeapon);
    int nCreatureSize = GetCreatureSize(oObject);
    if(nWeaponSize <= nCreatureSize
        &&GetWeaponRanged(oWeapon)==FALSE)
        return TRUE;
    return FALSE;
}

int IsItemWeapon(object oItem)
{
    int bResult;
    int bBase = GetBaseItemType(oItem);
    if(bBase ==  BASE_ITEM_ARROW
        || bBase == BASE_ITEM_BASTARDSWORD
        || bBase == BASE_ITEM_BATTLEAXE
        || bBase == BASE_ITEM_BOLT
        || bBase == BASE_ITEM_BULLET
        || bBase == BASE_ITEM_CBLUDGWEAPON
        || bBase == BASE_ITEM_CPIERCWEAPON
        || bBase == BASE_ITEM_CLUB
        || bBase == BASE_ITEM_CSLASHWEAPON
        || bBase == BASE_ITEM_CSLSHPRCWEAP
        || bBase == BASE_ITEM_DAGGER
        || bBase == BASE_ITEM_DART
        || bBase == BASE_ITEM_DIREMACE
		|| bBase == BASE_ITEM_DOUBLE_SCIMITAR
        || bBase == BASE_ITEM_DOUBLEAXE
        || bBase == BASE_ITEM_DWARVENWARAXE
		|| bBase == BASE_ITEM_EAGLE_CLAW
		|| bBase == BASE_ITEM_ELVEN_COURTBLADE
		|| bBase == BASE_ITEM_ELVEN_LIGHTBLADE
		|| bBase == BASE_ITEM_ELVEN_THINBLADE
		|| bBase == BASE_ITEM_FALCHION
		|| bBase == BASE_ITEM_GOAD
        || bBase == BASE_ITEM_GREATAXE
        || bBase == BASE_ITEM_GREATSWORD
        || bBase == BASE_ITEM_HALBERD
        || bBase == BASE_ITEM_HANDAXE
		|| bBase == BASE_ITEM_HEAVY_MACE
		|| bBase == BASE_ITEM_HEAVY_PICK
        || bBase == BASE_ITEM_HEAVYCROSSBOW
        || bBase == BASE_ITEM_HEAVYFLAIL
        || bBase == BASE_ITEM_KATANA
		|| bBase == BASE_ITEM_KATAR
        || bBase == BASE_ITEM_KUKRI
		|| bBase == BASE_ITEM_LIGHT_PICK
        || bBase == BASE_ITEM_LIGHTCROSSBOW
        || bBase == BASE_ITEM_LIGHTFLAIL
        || bBase == BASE_ITEM_LIGHTHAMMER
        || bBase == BASE_ITEM_LIGHTMACE
        || bBase == BASE_ITEM_LONGBOW
        || bBase == BASE_ITEM_LONGSWORD
		|| bBase == BASE_ITEM_MAUL
        || bBase == BASE_ITEM_MORNINGSTAR
		|| bBase == BASE_ITEM_NUNCHAKU
        || bBase == BASE_ITEM_QUARTERSTAFF
        || bBase == BASE_ITEM_RAPIER
		|| bBase == BASE_ITEM_SAI
		|| bBase == BASE_ITEM_SAP
        || bBase == BASE_ITEM_SCIMITAR
        || bBase == BASE_ITEM_SCYTHE
        || bBase == BASE_ITEM_SHORTBOW
        || bBase == BASE_ITEM_SHORTSPEAR
        || bBase == BASE_ITEM_SHORTSWORD
        || bBase == BASE_ITEM_SHURIKEN
        || bBase == BASE_ITEM_SICKLE
        || bBase == BASE_ITEM_SLING
        || bBase == BASE_ITEM_THROWINGAXE
		|| bBase == BASE_ITEM_TRIDENT
        || bBase == BASE_ITEM_TWOBLADEDSWORD
        || bBase == BASE_ITEM_WARHAMMER
        || bBase == BASE_ITEM_WHIP  )
        bResult = TRUE;
    return bResult;
}

int PrimoGetWeaponSize(object oItem)
{
    int bResult;
    int bBase = GetBaseItemType(oItem);
    switch(bBase)
    {
        case BASE_ITEM_DIREMACE:
        case BASE_ITEM_DOUBLEAXE:
        case BASE_ITEM_GREATSWORD:
        case BASE_ITEM_HALBERD:
        case BASE_ITEM_HEAVYFLAIL:
        case BASE_ITEM_GREATAXE:
        case BASE_ITEM_LONGBOW:
        case BASE_ITEM_SCYTHE:
        case BASE_ITEM_TWOBLADEDSWORD:
        case BASE_ITEM_QUARTERSTAFF:
        case BASE_ITEM_SHORTSPEAR:
		case BASE_ITEM_DOUBLE_SCIMITAR:
		case BASE_ITEM_MAUL:
		case BASE_ITEM_FALCHION:
		case BASE_ITEM_ELVEN_COURTBLADE:
		case BASE_ITEM_LIGHT_LANCE:
            bResult = CREATURE_SIZE_LARGE;
            break;
        case BASE_ITEM_BATTLEAXE:
        case BASE_ITEM_BASTARDSWORD:
        case BASE_ITEM_CLUB:
        case BASE_ITEM_HEAVYCROSSBOW:
        case BASE_ITEM_DWARVENWARAXE:
        case BASE_ITEM_LIGHTFLAIL:
        case BASE_ITEM_KATANA:
        case BASE_ITEM_MAGICSTAFF:
        case BASE_ITEM_CRAFTED_SCEPTER:		
        case BASE_ITEM_LONGSWORD:
        case BASE_ITEM_TRIDENT:		
        case BASE_ITEM_MORNINGSTAR:
        case BASE_ITEM_RAPIER:
        case BASE_ITEM_SCIMITAR:
        case BASE_ITEM_SHORTBOW:
        case BASE_ITEM_WARHAMMER:
        case BASE_ITEM_WHIP:
        case BASE_ITEM_CPIERCWEAPON:
        case BASE_ITEM_CSLSHPRCWEAP:
        case BASE_ITEM_CSLASHWEAPON:
        case BASE_ITEM_CBLUDGWEAPON:
		case BASE_ITEM_HEAVY_MACE:
		case BASE_ITEM_HEAVY_PICK:
            bResult =  CREATURE_SIZE_MEDIUM ;
            break;
        case BASE_ITEM_THROWINGAXE:
        case BASE_ITEM_LIGHTCROSSBOW:
        case BASE_ITEM_DART:
        case BASE_ITEM_LIGHTHAMMER:
        case BASE_ITEM_HANDAXE:
        case BASE_ITEM_LIGHTMACE:
        case BASE_ITEM_SICKLE:
        case BASE_ITEM_SLING:
        case BASE_ITEM_SHORTSWORD:
        case BASE_ITEM_TORCH:
        case BASE_ITEM_KAMA:
		case BASE_ITEM_EAGLE_CLAW:      
		case BASE_ITEM_ELVEN_LIGHTBLADE:  
		case BASE_ITEM_ELVEN_THINBLADE:             
		case BASE_ITEM_NUNCHAKU:                  
		case BASE_ITEM_LIGHT_PICK:              
		case BASE_ITEM_GOAD:
			bResult = CREATURE_SIZE_SMALL;
			break;
        case BASE_ITEM_KUKRI:
        case BASE_ITEM_DAGGER:
        case BASE_ITEM_SHURIKEN:
		case BASE_ITEM_SAP:
		case BASE_ITEM_SAI:
		case BASE_ITEM_KATAR:		
            bResult = CREATURE_SIZE_TINY;
            break;
        default:
            bResult = 0; //invalid
    }
    return bResult;
}

object EquipHeavyArmor(object oObject)
{
    int nRandom = Random(4);
    object oItem;
    switch(nRandom)
    {
        case 0:
            oItem = CreateItemOnObject("nw_aarcl011",oObject);
            break;
        case 1:
            oItem = CreateItemOnObject("nw_aarcl007",oObject);
            break;
        case 2:
            oItem = CreateItemOnObject("nw_aarcl006",oObject);
            break;
        case 3:
            oItem = CreateItemOnObject("nw_aarcl005",oObject);
            break;
    }
    AssignCommand(oObject, ActionEquipItem(oItem, INVENTORY_SLOT_CHEST));
    return oItem;
}

object EquipMediumArmor(object oObject)
{
    int nRandom = Random(4);
    object oItem;
    switch(nRandom)
    {
        case 0:
            oItem = CreateItemOnObject("nw_aarcl010",oObject);
            break;
        case 1:
            oItem = CreateItemOnObject("nw_aarcl004",oObject);
            break;
        case 2://chain shirt
            oItem = CreateItemOnObject("nw_aarcl012",oObject);
            break;
        case 3:
            oItem = CreateItemOnObject("nw_aarcl003",oObject);
            break;
    }
    AssignCommand(oObject, ActionEquipItem(oItem, INVENTORY_SLOT_CHEST));
    return oItem;
}

object EquipLightArmor(object oObject)
{
    int nRandom = Random(4);
    object oItem;
    switch(nRandom)
    {
         case 0:                                //hide
            oItem = CreateItemOnObject("nw_aarcl008",oObject);
            break;
         case 1:
            oItem = CreateItemOnObject("nw_aarcl001",oObject);
            break;
         case 2:
            oItem = CreateItemOnObject("nw_aarcl009",oObject);
            break;
         case 3:
            oItem = CreateItemOnObject("nw_aarcl002",oObject);
            break;
    }
    AssignCommand(oObject, ActionEquipItem(oItem, INVENTORY_SLOT_CHEST));
    return oItem;
}

object EquipClothes(object oObject)
{
    int nClass = GetClassByPosition(2, oObject);
    if(nClass == CLASS_TYPE_INVALID)
        nClass = GetClassByPosition(1, oObject);
    object oItem;
    switch(nClass)
    {
        case CLASS_TYPE_MONK:
            oItem = CreateItemOnObject("nw_cloth016",oObject);
            break;
        case CLASS_TYPE_SORCERER:
            oItem = CreateItemOnObject("nw_cloth008",oObject);
            break;
        case CLASS_TYPE_WIZARD:
            oItem = CreateItemOnObject("nw_cloth005",oObject);
            break;
        default:
            oItem = CreateItemOnObject("nw_cloth001",oObject);
            break;
    }
    AssignCommand(oObject, ActionEquipItem(oItem, INVENTORY_SLOT_CHEST));
    return oItem;
}

string GetBaseResRef(int nBaseItemType)
{
    string sResRef;
    switch(nBaseItemType)
    {
    case BASE_ITEM_BASTARDSWORD:
        sResRef = "nw_wswbs001";
        break;
    case BASE_ITEM_BATTLEAXE:
        sResRef = "nw_waxbt001";
        break;
    case BASE_ITEM_CLUB:
        sResRef = "nw_wblcl001";
        break;
    case BASE_ITEM_DAGGER:
        sResRef = "nw_wswdg001";
        break;
    case BASE_ITEM_DART:
        sResRef = "nw_wthdt001";
        break;
    case BASE_ITEM_DIREMACE:
        sResRef = "nw_wdbma001";
        break;
    case BASE_ITEM_DOUBLEAXE:
        sResRef = "nw_wdbax001";
        break;
    case BASE_ITEM_DOUBLE_SCIMITAR:
        sResRef = "prc_wxdbsc001";
        break;		
    case BASE_ITEM_DWARVENWARAXE:
        sResRef = "x2_wdwraxe001";
        break;
    case BASE_ITEM_GREATAXE:
        sResRef = "nw_waxgr001";
        break;		
    case BASE_ITEM_EAGLE_CLAW:
        sResRef = "prc_wswec001";
        break;
    case BASE_ITEM_ELVEN_COURTBLADE:
        sResRef = "prc_wspec001";
        break;
    case BASE_ITEM_ELVEN_LIGHTBLADE:
        sResRef = "prc_wspel001";
        break;
    case BASE_ITEM_ELVEN_THINBLADE:
        sResRef = "prc_wspet001";
        break;
    case BASE_ITEM_FALCHION:
        sResRef = "prc_wswfa001";
        break;	
    case BASE_ITEM_GOAD:
        sResRef = "prc_spgd001";
        break;			
    case BASE_ITEM_GREATSWORD:
        sResRef = "nw_wswgs001";
        break;
    case BASE_ITEM_HALBERD:
        sResRef = "nw_wplhb001";
        break;
    case BASE_ITEM_HANDAXE:
        sResRef = "nw_waxhn001";
        break;
    case BASE_ITEM_HEAVYCROSSBOW:
        sResRef = "w_wbwxh001";
        break;
    case BASE_ITEM_HEAVYFLAIL:
        sResRef = "nw_wblfh001";
        break;
    case BASE_ITEM_HEAVY_MACE:
        sResRef = "prc_wxblmh001";
        break;
    case BASE_ITEM_HEAVY_PICK:
        sResRef = "prc_wblph001";
        break;		
    case BASE_ITEM_KAMA:
        sResRef = "nw_wspka001";
        break;
    case BASE_ITEM_KATANA:
        sResRef = "nw_wswka001";
        break;
    case BASE_ITEM_KATAR:
        sResRef = "prc_wswdp001";
        break;		
    case BASE_ITEM_KUKRI:
        sResRef = "nw_wspku001";
        break;
    case BASE_ITEM_LIGHTCROSSBOW:
        sResRef = "nw_wbwxl001";
        break;
    case BASE_ITEM_LIGHTFLAIL:
        sResRef = "nw_wblfl001";
        break;
    case BASE_ITEM_LIGHTHAMMER:
        sResRef = "nw_wblmhl001";
        break;
    case BASE_ITEM_LIGHT_LANCE:
        sResRef = "prc_wpllc001";
        break;		
    case BASE_ITEM_LIGHTMACE:
        sResRef = "w_wblml001";
        break;
    case BASE_ITEM_LIGHT_PICK:
        sResRef = "prc_wblpl001";
        break;		
    case BASE_ITEM_LONGBOW:
        sResRef = "nw_wbwln001";
        break;
    case BASE_ITEM_LONGSWORD:
        sResRef = "nw_wswls001";
        break;
    case BASE_ITEM_MORNINGSTAR:
        sResRef = "nw_wblms001";
        break;        
    case BASE_ITEM_MAUL:
        sResRef = "prc_wxblma001";
        break;
    case BASE_ITEM_NUNCHAKU:
        sResRef = "prc_wblnn001";
        break;		
    case BASE_ITEM_QUARTERSTAFF:
        sResRef = "nw_wdbqs001";
        break;
    case BASE_ITEM_RAPIER:
        sResRef = "nw_wswrp001";
        break;
    case BASE_ITEM_SAI:
        sResRef = "prc_wswsi001";
        break;	
    case BASE_ITEM_SAP:
        sResRef = "prc_wspsp001";
        break;			
    case BASE_ITEM_SCIMITAR:
        sResRef = "nw_wswsc001";
        break;
    case BASE_ITEM_SCYTHE:
        sResRef = "nw_wplsc001";
        break;
    case BASE_ITEM_SHORTBOW:
        sResRef = "nw_wbwsh001";
        break;
    case BASE_ITEM_SHORTSPEAR:
        sResRef = "nw_wplss001";
        break;
    case BASE_ITEM_SHORTSWORD:
        sResRef = "nw_wswss001";
        break;
    case BASE_ITEM_SHURIKEN:
        sResRef = "nw_wthsh001";
        break;
    case BASE_ITEM_SICKLE:
        sResRef = "nw_wspsc001";
        break;
    case BASE_ITEM_SLING:
        sResRef = "nw_wbwsl001";
        break;
    case BASE_ITEM_TRIDENT:
        sResRef = "nw_wpltr001";
        break;		
    case BASE_ITEM_THROWINGAXE:
        sResRef = "nw_wthax001";
        break;
    case BASE_ITEM_TWOBLADEDSWORD:
        sResRef = "nw_wdbsw001";
        break;
    case BASE_ITEM_WARHAMMER:
        sResRef = "nw_wblhw001";
        break;
    }
    return sResRef;
}

void EquipScroll(object oObject)
{
    object oItem;
    int nRandom;
    int nCount = GetLevelByClass(CLASS_TYPE_CLERIC, oObject)
        + GetLevelByClass(CLASS_TYPE_WIZARD, oObject)
        + GetLevelByClass(CLASS_TYPE_DRUID, oObject)
        + GetLevelByClass(CLASS_TYPE_SORCERER, oObject)
        + GetLevelByClass(CLASS_TYPE_BARD, oObject)
        + (GetLevelByClass(CLASS_TYPE_ROGUE, oObject)/3)+ d6() - 3;
    int i;
    for (i=1;i<=nCount;i++)
    {
        nRandom = Random(287)+1;
        switch(nRandom)
        {
        case 1:
            oItem = CreateItemOnObject("x1_it_sparscr002", oObject);
            break;
        case 2:
            oItem = CreateItemOnObject("nw_it_sparscr003", oObject);
            break;
        case 3:
            oItem = CreateItemOnObject("x1_it_sparscr003", oObject);
            break;
        case 4:
            oItem = CreateItemOnObject("x1_it_sparscr001", oObject);
            break;
        case 5:
            oItem = CreateItemOnObject("x1_it_spdvscr001", oObject);
            break;
        case 6:
            oItem = CreateItemOnObject("nw_it_sparscr004", oObject);
            break;
        case 7:
            oItem = CreateItemOnObject("nw_it_sparscr002", oObject);
            break;
        case 8:
            oItem = CreateItemOnObject("nw_it_sparscr001", oObject);
            break;
        case 9:
            oItem = CreateItemOnObject("x2_it_spdvscr001", oObject);
            break;
        case 10:
            oItem = CreateItemOnObject("x2_it_spdvscr002", oObject);
            break;
        case 11:
            oItem = CreateItemOnObject("x1_it_sparscr102", oObject);
            break;
        case 12:
            oItem = CreateItemOnObject("x1_it_spdvscr101", oObject);
            break;
        case 13:
            oItem = CreateItemOnObject("nw_it_sparscr112", oObject);
            break;
        case 14:
            oItem = CreateItemOnObject("x1_it_spdvscr107", oObject);
            break;
        case 15:
            oItem = CreateItemOnObject("nw_it_sparscr107", oObject);
            break;
        case 16:
            oItem = CreateItemOnObject("nw_it_sparscr110", oObject);
            break;
        case 17:
            oItem = CreateItemOnObject("x1_it_spdvscr102", oObject);
            break;
        case 18:
            oItem = CreateItemOnObject("nw_it_sparscr101", oObject);
            break;
        case 19:
            oItem = CreateItemOnObject("x1_it_spdvscr103", oObject);
            break;
        case 20:
            oItem = CreateItemOnObject("x1_it_sparscr101", oObject);
            break;
        case 21:
            oItem = CreateItemOnObject("nw_it_sparscr103", oObject);
            break;
        case 22:
            oItem = CreateItemOnObject("nw_it_sparscr106", oObject);
            break;
        case 23:
            oItem = CreateItemOnObject("x1_it_spdvscr104", oObject);
            break;
        case 24:
            oItem = CreateItemOnObject("nw_it_sparscr104", oObject);
            break;
        case 25:
            oItem = CreateItemOnObject("x1_it_spdvscr106", oObject);
            break;
        case 26:
            oItem = CreateItemOnObject("nw_it_sparscr109", oObject);
            break;
        case 27:
            oItem = CreateItemOnObject("nw_it_sparscr113", oObject);
            break;
        case 28:
            oItem = CreateItemOnObject("nw_it_sparscr102", oObject);
            break;
        case 29:
            oItem = CreateItemOnObject("nw_it_sparscr111", oObject);
            break;
        case 30:
            oItem = CreateItemOnObject("nw_it_sparscr210", oObject);
            break;
        case 31:
            oItem = CreateItemOnObject("x1_it_sparscr103", oObject);
            break;
        case 32:
            oItem = CreateItemOnObject("x1_it_spdvscr105", oObject);
            break;
        case 33:
            oItem = CreateItemOnObject("nw_it_sparscr108", oObject);
            break;
        case 34:
            oItem = CreateItemOnObject("nw_it_sparscr105", oObject);
            break;
        case 35:
            oItem = CreateItemOnObject("x1_it_sparscr104", oObject);
            break;
        case 36:
            oItem = CreateItemOnObject("x2_it_spdvscr103", oObject);
            break;
        case 37:
            oItem = CreateItemOnObject("x2_it_spdvscr102", oObject);
            break;
        case 38:
            oItem = CreateItemOnObject("x2_it_spdvscr104", oObject);
            break;
        case 39:
            oItem = CreateItemOnObject("x2_it_spdvscr101", oObject);
            break;
        case 40:
            oItem = CreateItemOnObject("x2_it_spdvscr105", oObject);
            break;
        case 41:
            oItem = CreateItemOnObject("x2_it_spdvscr106", oObject);
            break;
        case 42:
            oItem = CreateItemOnObject("x2_it_spavscr101", oObject);
            break;
        case 43:
            oItem = CreateItemOnObject("x2_it_spavscr104", oObject);
            break;
        case 44:
            oItem = CreateItemOnObject("x2_it_spavscr102", oObject);
            break;
        case 45:
            oItem = CreateItemOnObject("x2_it_spavscr105", oObject);
            break;
        case 46:
            oItem = CreateItemOnObject("x2_it_sparscral", oObject);
            break;
        case 47:
            oItem = CreateItemOnObject("x2_it_spdvscr107", oObject);
            break;
        case 48:
            oItem = CreateItemOnObject("x2_it_spdvscr108", oObject);
            break;
        case 49:
            oItem = CreateItemOnObject("x2_it_spavscr103", oObject);
            break;
        case 50:
            oItem = CreateItemOnObject("x1_it_spdvscr204", oObject);
            break;
        case 51:
            oItem = CreateItemOnObject("x1_it_sparscr201", oObject);
            break;
        case 52:
            oItem = CreateItemOnObject("nw_it_sparscr211", oObject);
            break;
        case 53:
            oItem = CreateItemOnObject("x1_it_spdvscr202", oObject);
            break;
        case 54:
            oItem = CreateItemOnObject("nw_it_sparscr212", oObject);
            break;
        case 55:
            oItem = CreateItemOnObject("nw_it_sparscr213", oObject);
            break;
        case 56:
            oItem = CreateItemOnObject("nw_it_spdvscr202", oObject);
            break;
        case 57:
            oItem = CreateItemOnObject("x1_it_sparscr301", oObject);
            break;
        case 58:
            oItem = CreateItemOnObject("nw_it_sparscr206", oObject);
            break;
        case 59:
            oItem = CreateItemOnObject("nw_it_sparscr219", oObject);
            break;
        case 60:
            oItem = CreateItemOnObject("nw_it_sparscr215", oObject);
            break;
        case 61:
            oItem = CreateItemOnObject("x1_it_spdvscr205", oObject);
            break;
        case 62:
            oItem = CreateItemOnObject("nw_it_sparscr220", oObject);
            break;
        case 63:
            oItem = CreateItemOnObject("nw_it_sparscr208", oObject);
            break;
        case 64:
            oItem = CreateItemOnObject("nw_it_sparscr209", oObject);
            break;
        case 65:
            oItem = CreateItemOnObject("x1_it_spdvscr201", oObject);
            break;
        case 66:
            oItem = CreateItemOnObject("nw_it_sparscr207", oObject);
            break;
        case 67:
            oItem = CreateItemOnObject("nw_it_sparscr216", oObject);
            break;
        case 68:
            oItem = CreateItemOnObject("nw_it_sparscr218", oObject);
            break;
        case 69:
            oItem = CreateItemOnObject("nw_it_spdvscr201", oObject);
            break;
        case 70:
            oItem = CreateItemOnObject("nw_it_sparscr202", oObject);
            break;
        case 71:
            oItem = CreateItemOnObject("x1_it_spdvscr203", oObject);
            break;
        case 72:
            oItem = CreateItemOnObject("nw_it_sparscr221", oObject);
            break;
        case 73:
            oItem = CreateItemOnObject("nw_it_sparscr201", oObject);
            break;
        case 74:
            oItem = CreateItemOnObject("nw_it_sparscr205", oObject);
            break;
        case 75:
            oItem = CreateItemOnObject("nw_it_spdvscr203", oObject);
            break;
        case 76:
            oItem = CreateItemOnObject("nw_it_spdvscr204", oObject);
            break;
        case 77:
            oItem = CreateItemOnObject("nw_it_sparscr203", oObject);
            break;
        case 78:
            oItem = CreateItemOnObject("x1_it_sparscr202", oObject);
            break;
        case 79:
            oItem = CreateItemOnObject("nw_it_sparscr214", oObject);
            break;
        case 80:
            oItem = CreateItemOnObject("nw_it_sparscr204", oObject);
            break;
        case 81:
            oItem = CreateItemOnObject("x2_it_spdvscr201", oObject);
            break;
        case 82:
            oItem = CreateItemOnObject("x2_it_spdvscr202", oObject);
            break;
        case 83:
            oItem = CreateItemOnObject("x2_it_spavscr207", oObject);
            break;
        case 84:
            oItem = CreateItemOnObject("x2_it_spavscr206", oObject);
            break;
        case 85:
            oItem = CreateItemOnObject("x2_it_spavscr201", oObject);
            break;
        case 86:
            oItem = CreateItemOnObject("x2_it_spdvscr203", oObject);
            break;
        case 87:
            oItem = CreateItemOnObject("x2_it_spavscr201", oObject);
            break;
        case 88:
            oItem = CreateItemOnObject("x2_it_spavscr205", oObject);
            break;
        case 89:
            oItem = CreateItemOnObject("x2_it_spavscr203", oObject);
            break;
        case 90:
            oItem = CreateItemOnObject("x2_it_spdvscr204", oObject);
            break;
        case 91:
            oItem = CreateItemOnObject("x2_it_spdvscr205", oObject);
            break;
        case 92:
            oItem = CreateItemOnObject("x2_it_spavscr204", oObject);
            break;
        case 93:
            oItem = CreateItemOnObject("nw_it_sparscr307", oObject);
            break;
        case 94:
            oItem = CreateItemOnObject("nw_it_sparscr217", oObject);
            break;
        case 95:
            oItem = CreateItemOnObject("nw_it_sparscr301", oObject);
            break;
        case 96:
            oItem = CreateItemOnObject("x1_it_sparscr301", oObject);
            break;
        case 97:
            oItem = CreateItemOnObject("nw_it_sparscr309", oObject);
            break;
        case 98:
            oItem = CreateItemOnObject("nw_it_sparscr304", oObject);
            break;
        case 99:
            oItem = CreateItemOnObject("x1_it_spdvscr303", oObject);
            break;
        case 100:
            oItem = CreateItemOnObject("x1_it_sparscr303", oObject);
            break;
        case 101:
            oItem = CreateItemOnObject("nw_it_sparscr312", oObject);
            break;
        case 102:
            oItem = CreateItemOnObject("nw_it_sparscr308", oObject);
            break;
        case 103:
            oItem = CreateItemOnObject("x1_it_spdvscr302", oObject);
            break;
        case 104:
            oItem = CreateItemOnObject("nw_it_sparscr314", oObject);
            break;
        case 105:
            oItem = CreateItemOnObject("nw_it_sparscr310", oObject);
            break;
        case 106:
            oItem = CreateItemOnObject("nw_it_sparscr302", oObject);
            break;
        case 107:
            oItem = CreateItemOnObject("nw_it_sparscr315", oObject);
            break;
        case 108:
            oItem = CreateItemOnObject("nw_it_sparscr303", oObject);
            break;
        case 109:
            oItem = CreateItemOnObject("x1_it_spdvscr305", oObject);
            break;
        case 110:
            oItem = CreateItemOnObject("nw_it_spdvscr302", oObject);
            break;
        case 111:
            oItem = CreateItemOnObject("nw_it_sparscr313", oObject);
            break;
        case 112:
            oItem = CreateItemOnObject("x1_it_spdvscr304", oObject);
            break;
        case 113:
            oItem = CreateItemOnObject("nw_it_sparscr305", oObject);
            break;
        case 114:
            oItem = CreateItemOnObject("nw_it_sparscr306", oObject);
            break;
        case 115:
            oItem = CreateItemOnObject("nw_it_sparscr311", oObject);
            break;
        case 116:
            oItem = CreateItemOnObject("x1_it_sparscr302", oObject);
            break;
        case 117:
            oItem = CreateItemOnObject("x2_it_spdvscr303", oObject);
            break;
        case 118:
            oItem = CreateItemOnObject("x2_it_spdvscr307", oObject);
            break;
        case 119:
            oItem = CreateItemOnObject("x2_it_spdvscr308", oObject);
            break;
        case 120:
            oItem = CreateItemOnObject("x2_it_spdvscr305", oObject);
            break;
        case 121:
            oItem = CreateItemOnObject("x2_it_spdvscr309", oObject);
            break;
        case 122:
            oItem = CreateItemOnObject("x2_it_spavscr305", oObject);
            break;
        case 123:
            oItem = CreateItemOnObject("x2_it_spdvscr306", oObject);
            break;
        case 124:
            oItem = CreateItemOnObject("x2_it_spavscr304", oObject);
            break;
        case 125:
            oItem = CreateItemOnObject("x2_it_spdvscr302", oObject);
            break;
        case 126:
            oItem = CreateItemOnObject("x2_it_spdvscr301", oObject);
            break;
        case 127:
            oItem = CreateItemOnObject("x2_it_spdvscr310", oObject);
            break;
        case 128:
            oItem = CreateItemOnObject("x2_it_spavscr303", oObject);
            break;
        case 129:
            oItem = CreateItemOnObject("x2_it_sparscrmc", oObject);
            break;
        case 130:
            oItem = CreateItemOnObject("x2_it_spdvscr304", oObject);
            break;
        case 131:
            oItem = CreateItemOnObject("x2_it_spavscr301", oObject);
            break;
        case 132:
            oItem = CreateItemOnObject("x2_it_spdvscr311", oObject);
            break;
        case 133:
            oItem = CreateItemOnObject("x2_it_spdvscr312", oObject);
            break;
        case 134:
            oItem = CreateItemOnObject("x2_it_spavscr302", oObject);
            break;
        case 135:
            oItem = CreateItemOnObject("x2_it_spdvscr313", oObject);
            break;
        case 136:
            oItem = CreateItemOnObject("nw_it_sparscr414", oObject);
            break;
        case 137:
            oItem = CreateItemOnObject("nw_it_sparscr405", oObject);
            break;
        case 138:
            oItem = CreateItemOnObject("nw_it_sparscr406", oObject);
            break;
        case 139:
            oItem = CreateItemOnObject("nw_it_sparscr411", oObject);
            break;
        case 140:
            oItem = CreateItemOnObject("nw_it_sparscr416", oObject);
            break;
        case 141:
            oItem = CreateItemOnObject("nw_it_sparscr412", oObject);
            break;
        case 142:
            oItem = CreateItemOnObject("nw_it_sparscr418", oObject);
            break;
        case 143:
            oItem = CreateItemOnObject("nw_it_sparscr413", oObject);
            break;
        case 144:
            oItem = CreateItemOnObject("nw_it_sparscr408", oObject);
            break;
        case 145:
            oItem = CreateItemOnObject("x1_it_spdvscr401", oObject);
            break;
        case 146:
            oItem = CreateItemOnObject("x1_it_sparscr401", oObject);
            break;
        case 147:
            oItem = CreateItemOnObject("nw_it_sparscr417", oObject);
            break;
        case 148:
            oItem = CreateItemOnObject("x1_it_spdvscr402", oObject);
            break;
        case 149:
            oItem = CreateItemOnObject("nw_it_sparscr401", oObject);
            break;
        case 150:
            oItem = CreateItemOnObject("nw_it_spdvscr402", oObject);
            break;
        case 151:
            oItem = CreateItemOnObject("nw_it_sparscr409", oObject);
            break;
        case 152:
            oItem = CreateItemOnObject("nw_it_sparscr415", oObject);
            break;
        case 153:
            oItem = CreateItemOnObject("nw_it_sparscr402", oObject);
            break;
        case 154:
            oItem = CreateItemOnObject("nw_it_spdvscr401", oObject);
            break;
        case 155:
            oItem = CreateItemOnObject("nw_it_sparscr410", oObject);
            break;
        case 156:
            oItem = CreateItemOnObject("nw_it_sparscr403", oObject);
            break;
        case 157:
            oItem = CreateItemOnObject("nw_it_sparscr404", oObject);
            break;
        case 158:
            oItem = CreateItemOnObject("nw_it_sparscr407", oObject);
            break;
        case 159:
            oItem = CreateItemOnObject("x2_it_spdvscr402", oObject);
            break;
        case 160:
            oItem = CreateItemOnObject("x2_it_spdvscr403", oObject);
            break;
        case 161:
            oItem = CreateItemOnObject("x2_it_spdvscr404", oObject);
            break;
        case 162:
            oItem = CreateItemOnObject("x2_it_spdvscr405", oObject);
            break;
        case 163:
            oItem = CreateItemOnObject("x2_it_spdvscr406", oObject);
            break;
        case 164:
            oItem = CreateItemOnObject("x2_it_spdvscr401", oObject);
            break;
        case 165:
            oItem = CreateItemOnObject("x2_it_spavscr401", oObject);
            break;
        case 166:
            oItem = CreateItemOnObject("x2_it_spdvscr407", oObject);
            break;
        case 167:
            oItem = CreateItemOnObject("nw_it_sparscr509", oObject);
            break;
        case 168:
            oItem = CreateItemOnObject("x1_it_sparscr502", oObject);
            break;
        case 169:
            oItem = CreateItemOnObject("nw_it_sparscr502", oObject);
            break;
        case 170:
            oItem = CreateItemOnObject("nw_it_sparscr507", oObject);
            break;
        case 171:
            oItem = CreateItemOnObject("nw_it_sparscr501", oObject);
            break;
        case 172:
            oItem = CreateItemOnObject("nw_it_sparscr503", oObject);
            break;
        case 173:
            oItem = CreateItemOnObject("nw_it_sparscr504", oObject);
            break;
        case 174:
            oItem = CreateItemOnObject("x1_it_sparscr501", oObject);
            break;
        case 175:
            oItem = CreateItemOnObject("x1_it_spdvscr403", oObject);
            break;
        case 176:
            oItem = CreateItemOnObject("nw_it_sparscr508", oObject);
            break;
        case 177:
            oItem = CreateItemOnObject("nw_it_sparscr505", oObject);
            break;
        case 178:
            oItem = CreateItemOnObject("x1_it_spdvscr501", oObject);
            break;
        case 179:
            oItem = CreateItemOnObject("nw_it_sparscr511", oObject);
            break;
        case 180:
            oItem = CreateItemOnObject("nw_it_sparscr512", oObject);
            break;
        case 181:
            oItem = CreateItemOnObject("nw_it_sparscr513", oObject);
            break;
        case 182:
            oItem = CreateItemOnObject("nw_it_sparscr506", oObject);
            break;
        case 183:
            oItem = CreateItemOnObject("x1_it_spdvscr502", oObject);
            break;
        case 184:
            oItem = CreateItemOnObject("nw_it_spdvscr501", oObject);//raisedead
            break;
        case 185:
            oItem = CreateItemOnObject("nw_it_sparscr510", oObject);
            break;
        case 186:
            oItem = CreateItemOnObject("x2_it_spdvscr508", oObject);
            break;
        case 187:
            oItem = CreateItemOnObject("x2_it_spavscr501", oObject);
            break;
        case 188:
            oItem = CreateItemOnObject("x2_it_spdvscr501", oObject);
            break;
        case 189:
            oItem = CreateItemOnObject("x2_it_spdvscr504", oObject);
            break;
        case 190:
            oItem = CreateItemOnObject("x2_it_spavscr503", oObject);
            break;
        case 191:
            oItem = CreateItemOnObject("x2_it_spdvscr509", oObject);
            break;
        case 192:
            oItem = CreateItemOnObject("x2_it_spdvscr505", oObject);
            break;
        case 193:
            oItem = CreateItemOnObject("x2_it_spavscr502", oObject);
            break;
        case 194:
            oItem = CreateItemOnObject("x2_it_spdvscr502", oObject);
            break;
        case 195:
            oItem = CreateItemOnObject("x2_it_spdvscr506", oObject);
            break;
        case 196:
            oItem = CreateItemOnObject("x2_it_spdvscr507", oObject);
            break;
        case 197:
            oItem = CreateItemOnObject("x2_it_spdvscr503", oObject);
            break;
        case 198:
            oItem = CreateItemOnObject("nw_it_sparscr603", oObject);
            break;
        case 199:
            oItem = CreateItemOnObject("x1_it_sparscr602", oObject);
            break;
        case 200:
            oItem = CreateItemOnObject("nw_it_sparscr607", oObject);
            break;
        case 201:
            oItem = CreateItemOnObject("nw_it_sparscr610", oObject);
            break;
        case 202:
            oItem = CreateItemOnObject("x1_it_sparscr601", oObject);
            break;
        case 203:
            oItem = CreateItemOnObject("x1_it_spdvscr604", oObject);
            break;
        case 204:
            oItem = CreateItemOnObject("nw_it_sparscr608", oObject);
            break;
        case 205:
            oItem = CreateItemOnObject("x1_it_sparscr605", oObject);
            break;
        case 206:
            oItem = CreateItemOnObject("nw_it_sparscr601", oObject);
            break;
        case 207:
            oItem = CreateItemOnObject("nw_it_sparscr602", oObject);
            break;
        case 208:
            oItem = CreateItemOnObject("nw_it_sparscr612", oObject);
            break;
        case 209:
            oItem = CreateItemOnObject("nw_it_sparscr613", oObject);
            break;
        case 210:
            oItem = CreateItemOnObject("x1_it_sparscr603", oObject);
            break;
        case 211:
            oItem = CreateItemOnObject("nw_it_sparscr611", oObject);
            break;
        case 212:
            oItem = CreateItemOnObject("x1_it_spdvscr603", oObject);
            break;
        case 213:
            oItem = CreateItemOnObject("nw_it_sparscr604", oObject);
            break;
        case 214:
            oItem = CreateItemOnObject("nw_it_sparscr609", oObject);
            break;
        case 215:
            oItem = CreateItemOnObject("x1_it_sparscr604", oObject);
            break;
        case 216:
            oItem = CreateItemOnObject("nw_it_sparscr605", oObject);
            break;
        case 217:
            oItem = CreateItemOnObject("nw_it_sparscr614", oObject);
            break;
        case 218:
            oItem = CreateItemOnObject("nw_it_sparscr606", oObject);
            break;
        case 219:
            oItem = CreateItemOnObject("x2_it_spdvscr603", oObject);
            break;
        case 220:
            oItem = CreateItemOnObject("x2_it_spdvscr601", oObject);
            break;
        case 221:
            oItem = CreateItemOnObject("x2_it_spdvscr606", oObject);
            break;
        case 222:
            oItem = CreateItemOnObject("x2_it_spdvscr604", oObject);
            break;
        case 223:
            oItem = CreateItemOnObject("x2_it_spdvscr605", oObject);
            break;
        case 224:
            oItem = CreateItemOnObject("x2_it_spavscr602", oObject);
            break;
        case 225:
            oItem = CreateItemOnObject("x2_it_spdvscr602", oObject);
            break;
        case 226:
            oItem = CreateItemOnObject("x2_it_spavscr601", oObject);
            break;
        case 227:
            oItem = CreateItemOnObject("x1_it_spdvscr701", oObject);
            break;
        case 228:
            oItem = CreateItemOnObject("x1_it_sparscr701", oObject);
            break;
        case 229:
            oItem = CreateItemOnObject("nw_it_sparscr707", oObject);
            break;
        case 230:
            oItem = CreateItemOnObject("x1_it_spdvscr702", oObject);
            break;
        case 231:
            oItem = CreateItemOnObject("nw_it_sparscr704", oObject);
            break;
        case 232:
            oItem = CreateItemOnObject("x1_it_spdvscr703", oObject);
            break;
        case 233:
            oItem = CreateItemOnObject("nw_it_sparscr708", oObject);
            break;
        case 234:
            oItem = CreateItemOnObject("nw_it_spdvscr701", oObject);
            break;
        case 235:
            oItem = CreateItemOnObject("nw_it_sparscr705", oObject);
            break;
        case 236:
            oItem = CreateItemOnObject("nw_it_sparscr702", oObject);
            break;
        case 237:
            oItem = CreateItemOnObject("nw_it_sparscr706", oObject);
            break;
        case 238:
            oItem = CreateItemOnObject("nw_it_sparscr802", oObject);
            break;
        case 239:
            oItem = CreateItemOnObject("nw_it_spdvscr702", oObject);//ressurection
            break;
        case 240:
            oItem = CreateItemOnObject("nw_it_sparscr701", oObject);
            break;
        case 241:
            oItem = CreateItemOnObject("nw_it_sparscr703", oObject);
            break;
        case 242:
            oItem = CreateItemOnObject("x2_it_spavscr701", oObject);
            break;
        case 243:
            oItem = CreateItemOnObject("x2_it_spdvscr702", oObject);
            break;
        case 244:
            oItem = CreateItemOnObject("x2_it_spavscr703", oObject);
            break;
        case 245:
            oItem = CreateItemOnObject("x2_it_spdvscr701", oObject);
            break;
        case 246:
            oItem = CreateItemOnObject("x1_it_sparscr801", oObject);
            break;
        case 247:
            oItem = CreateItemOnObject("x1_it_spdvscr803", oObject);
            break;
        case 248:
            oItem = CreateItemOnObject("x1_it_spdvscr804", oObject);
            break;
        case 249:
            oItem = CreateItemOnObject("x1_it_spdvscr801", oObject);
            break;
        case 250:
            oItem = CreateItemOnObject("x1_it_spdvscr704", oObject);
            break;
        case 251:
            oItem = CreateItemOnObject("nw_it_sparscr803", oObject);
            break;
        case 252:
            oItem = CreateItemOnObject("x1_it_spdvscr602", oObject);
            break;
        case 253:
            oItem = CreateItemOnObject("nw_it_sparscr809", oObject);
            break;
        case 254:
            oItem = CreateItemOnObject("nw_it_sparscr804", oObject);
            break;
        case 255:
            oItem = CreateItemOnObject("nw_it_sparscr807", oObject);
            break;
        case 256:
            oItem = CreateItemOnObject("nw_it_sparscr806", oObject);
            break;
        case 257:
            oItem = CreateItemOnObject("nw_it_sparscr801", oObject);
            break;
        case 258:
            oItem = CreateItemOnObject("nw_it_sparscr808", oObject);
            break;
        case 259:
            oItem = CreateItemOnObject("nw_it_sparscr805", oObject);
            break;
        case 260:
            oItem = CreateItemOnObject("x2_it_spdvscr804", oObject);
            break;
        case 261:
            oItem = CreateItemOnObject("x2_it_spavscr801", oObject);
            break;
        case 262:
            oItem = CreateItemOnObject("x2_it_spdvscr801", oObject);
            break;
        case 263:
            oItem = CreateItemOnObject("x2_it_spdvscr802", oObject);
            break;
        case 264:
            oItem = CreateItemOnObject("x2_it_spdvscr803", oObject);
            break;
        case 265:
            oItem = CreateItemOnObject("x1_it_sparscr901", oObject);
            break;
        case 266:
            oItem = CreateItemOnObject("nw_it_sparscr905", oObject);
            break;
        case 267:
            oItem = CreateItemOnObject("nw_it_sparscr908", oObject);
            break;
        case 268:
            oItem = CreateItemOnObject("nw_it_sparscr902", oObject);
            break;
        case 269:
            oItem = CreateItemOnObject("nw_it_sparscr912", oObject);
            break;
        case 270:
            oItem = CreateItemOnObject("nw_it_sparscr906", oObject);
            break;
        case 271:
            oItem = CreateItemOnObject("nw_it_sparscr901", oObject);
            break;
        case 272:
            oItem = CreateItemOnObject("nw_it_sparscr903", oObject);
            break;
        case 273:
            oItem = CreateItemOnObject("nw_it_sparscr910", oObject);
            break;
        case 274:
            oItem = CreateItemOnObject("nw_it_sparscr904", oObject);
            break;
        case 275:
            oItem = CreateItemOnObject("nw_it_sparscr911", oObject);
            break;
        case 276:
            oItem = CreateItemOnObject("x1_it_spdvscr901", oObject);
            break;
        case 277:
            oItem = CreateItemOnObject("nw_it_sparscr909", oObject);
            break;
        case 278:
            oItem = CreateItemOnObject("nw_it_sparscr907", oObject);
            break;
        case 279:
            oItem = CreateItemOnObject("x2_it_spavscr901", oObject);
            break;
        case 280:
            oItem = CreateItemOnObject("x2_it_spdvscr901", oObject);
            break;
        case 281:
            oItem = CreateItemOnObject("x2_it_spdvscr902", oObject);
            break;
        case 282:
            oItem = CreateItemOnObject("x2_it_spdvscr903", oObject);
            break;
        case 283:
            oItem = CreateItemOnObject("x2_it_spavscr902", oObject);
            break;
        case 284:
            oItem = CreateItemOnObject("nw_it_spdvscr301", oObject);
            break;
        case 285:
            oItem = CreateItemOnObject("x1_it_spdvscr601", oObject);
            break;
        case 286:
            oItem = CreateItemOnObject("x1_it_spdvscr802", oObject);
            break;
        case 287:
            oItem = CreateItemOnObject("x1_it_spdvscr605", oObject);
            break;
        }
        int nLevel = GetHitDice(oObject);
        if(GetGoldPieceValue(oItem)>25*nLevel)
            DestroyObject(oItem);
        if(GetGoldPieceValue(oItem)<5*nLevel)
            DestroyObject(oItem);
    }
}

//:: Test Void Main
//:: void main (){}