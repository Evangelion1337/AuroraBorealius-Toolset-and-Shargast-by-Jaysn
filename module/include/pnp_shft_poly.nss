// Used to polymorph characters to lycanthrope shapes
// Merges Weapons, Armors, Items if told to by 2da.
// - object oPC: Player to Polymorph
// - int nPoly: POLYMORPH_TYPE_* Constant
void LycanthropePoly(object oPC, int nPoly);

void DoDisguise(int nRace, object oTarget = OBJECT_SELF);
void ShifterCheck(object oPC);

#include "pnp_shft_main"
#include "prc_inc_shifting"

//::////////////////Begin Werewolf//////////////////
const string PRC_PNP_SHIFTING = "PRC_Shift";

void LycanthropePoly(object oPC, int nPoly)
{
    effect eVis = EffectVisualEffect(VFX_IMP_POLYMORPH);
    effect ePoly = SupernaturalEffect(EffectPolymorph(nPoly));

    int bMonkGloves      = GetLocalInt(oPC, "WEARING_MONK_GLOVES");
    int bArmsSlotAllowed = GetPRCSwitch(PRC_WILDSHAPE_ALLOWS_ARMS_SLOT);

    int bWeapon = StringToInt(Get2DACache("polymorph","MergeW",nPoly)) == 1;
    int bArmor  = StringToInt(Get2DACache("polymorph","MergeA",nPoly)) == 1;
    int bItems  = StringToInt(Get2DACache("polymorph","MergeI",nPoly)) == 1;

    object oWeaponOld = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    object oArmorOld  = GetItemInSlot(INVENTORY_SLOT_CHEST,oPC);
    object oRing1Old  = GetItemInSlot(INVENTORY_SLOT_LEFTRING,oPC);
    object oRing2Old  = GetItemInSlot(INVENTORY_SLOT_RIGHTRING,oPC);
    object oAmuletOld = GetItemInSlot(INVENTORY_SLOT_NECK,oPC);
    object oCloakOld  = GetItemInSlot(INVENTORY_SLOT_CLOAK,oPC);
    object oBootsOld  = GetItemInSlot(INVENTORY_SLOT_BOOTS,oPC);
    object oBeltOld   = GetItemInSlot(INVENTORY_SLOT_BELT,oPC);
    object oHelmetOld = GetItemInSlot(INVENTORY_SLOT_HEAD,oPC);
    object oShield    = GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oPC);
    object oGlovesOld = GetItemInSlot(INVENTORY_SLOT_ARMS,oPC);

    if (GetIsObjectValid(oShield))
    {
        int nShieldType = GetBaseItemType(oShield);
        if (nShieldType != BASE_ITEM_LARGESHIELD &&
            nShieldType != BASE_ITEM_SMALLSHIELD &&
            nShieldType != BASE_ITEM_TOWERSHIELD)
        {
            oShield = OBJECT_INVALID;
        }
    }

    ShifterCheck(oPC);
    ClearAllActions();

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPC);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePoly, oPC);

    object oWeaponNewRight = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R,oPC);
    object oWeaponNewLeft  = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L,oPC);
    object oWeaponNewBite  = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B,oPC);
    object oArmorNew       = GetItemInSlot(INVENTORY_SLOT_CARMOUR,oPC);

    //:: Weapon & Armor merge block
    object oMergeWeaponSource = OBJECT_INVALID;
    object oMergeArmorSource  = OBJECT_INVALID;

    //:: Determine Weapon Merge Source
    if (bWeapon)
    {
        if (bMonkGloves)
        {
            if (GetIsObjectValid(oGlovesOld))
                oMergeWeaponSource = oGlovesOld;
        }
        else
        {
            //:: Always attempt to merge melee weapon to creature weapon
            oMergeWeaponSource = oWeaponOld; // even if empty, ensures proper state
        }
    }
    else
    {
        //:: Weapon not requested, but arms-slot allowed monk gloves can merge via armor branch
        if (bMonkGloves && bArmsSlotAllowed && GetIsObjectValid(oGlovesOld))
            oMergeWeaponSource = oGlovesOld;
    }

    //:: Determine Armor Merge Source
    if (bArmor && GetIsObjectValid(oArmorNew))
    {
        if (!bMonkGloves)
        {
            if (bArmsSlotAllowed && GetIsObjectValid(oGlovesOld))
                oMergeArmorSource = oGlovesOld;

            if (GetIsObjectValid(oShield))    IPWildShapeCopyItemProperties(oShield, oArmorNew);
            if (GetIsObjectValid(oHelmetOld)) IPWildShapeCopyItemProperties(oHelmetOld, oArmorNew);
            if (GetIsObjectValid(oArmorOld))  IPWildShapeCopyItemProperties(oArmorOld, oArmorNew);
        }
        else
        {
            if (GetIsObjectValid(oShield))    IPWildShapeCopyItemProperties(oShield, oArmorNew);
            if (GetIsObjectValid(oHelmetOld)) IPWildShapeCopyItemProperties(oHelmetOld, oArmorNew);
            if (GetIsObjectValid(oArmorOld))  IPWildShapeCopyItemProperties(oArmorOld, oArmorNew);
        }
    }
    else if (bArmor && !GetIsObjectValid(oArmorNew) && DEBUG)
    {
        DoDebug("LycanthropePoly: MergeA set, but oArmorNew invalid.");
    }

    //:: Apply Weapon Merge
    if (GetIsObjectValid(oMergeWeaponSource) || bWeapon)
    {
        //:: Always attempt to merge weapon properties even if source is OBJECT_INVALID
        if (GetIsObjectValid(oWeaponNewLeft))  IPWildShapeCopyItemProperties(oMergeWeaponSource, oWeaponNewLeft, TRUE);
        if (GetIsObjectValid(oWeaponNewRight)) IPWildShapeCopyItemProperties(oMergeWeaponSource, oWeaponNewRight, TRUE);
        if (GetIsObjectValid(oWeaponNewBite))  IPWildShapeCopyItemProperties(oMergeWeaponSource, oWeaponNewBite, TRUE);
    }

    //:: Apply Armor Merge
    if (GetIsObjectValid(oMergeArmorSource))
    {
        if (GetIsObjectValid(oArmorNew)) IPWildShapeCopyItemProperties(oMergeArmorSource, oArmorNew);
    }

    //:: General item merge block
    if (bItems && GetIsObjectValid(oArmorNew))
    {
        if (GetIsObjectValid(oRing1Old))  IPWildShapeCopyItemProperties(oRing1Old, oArmorNew);
        if (GetIsObjectValid(oRing2Old))  IPWildShapeCopyItemProperties(oRing2Old, oArmorNew);
        if (GetIsObjectValid(oAmuletOld)) IPWildShapeCopyItemProperties(oAmuletOld, oArmorNew);
        if (GetIsObjectValid(oCloakOld))  IPWildShapeCopyItemProperties(oCloakOld, oArmorNew);
        if (GetIsObjectValid(oBootsOld))  IPWildShapeCopyItemProperties(oBootsOld, oArmorNew);
        if (GetIsObjectValid(oBeltOld))   IPWildShapeCopyItemProperties(oBeltOld, oArmorNew);
    }
}
//::////////////////End Werewolf//////////////////


/* //::////////////////Begin Werewolf//////////////////
const string PRC_PNP_SHIFTING = "PRC_Shift";

void LycanthropePoly(object oPC, int nPoly)
{
    effect eVis = EffectVisualEffect(VFX_IMP_POLYMORPH);
    effect ePoly = SupernaturalEffect(EffectPolymorph(nPoly));

    int bMonkGloves = GetLocalInt(oPC, "WEARING_MONK_GLOVES");
    int bArmsSlotAllowed = GetPRCSwitch(PRC_WILDSHAPE_ALLOWS_ARMS_SLOT);

    int bWeapon = StringToInt(Get2DACache("polymorph","MergeW",nPoly)) == 1;
    int bArmor  = StringToInt(Get2DACache("polymorph","MergeA",nPoly)) == 1;
    int bItems  = StringToInt(Get2DACache("polymorph","MergeI",nPoly)) == 1;

    object oWeaponOld = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    object oArmorOld = GetItemInSlot(INVENTORY_SLOT_CHEST,oPC);
    object oRing1Old = GetItemInSlot(INVENTORY_SLOT_LEFTRING,oPC);
    object oRing2Old = GetItemInSlot(INVENTORY_SLOT_RIGHTRING,oPC);
    object oAmuletOld = GetItemInSlot(INVENTORY_SLOT_NECK,oPC);
    object oCloakOld  = GetItemInSlot(INVENTORY_SLOT_CLOAK,oPC);
    object oBootsOld  = GetItemInSlot(INVENTORY_SLOT_BOOTS,oPC);
    object oBeltOld   = GetItemInSlot(INVENTORY_SLOT_BELT,oPC);
    object oHelmetOld = GetItemInSlot(INVENTORY_SLOT_HEAD,oPC);
    object oShield    = GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oPC);
    object oGlovesOld = GetItemInSlot(INVENTORY_SLOT_ARMS,oPC);

    if (GetIsObjectValid(oShield))
    {
        int nShieldType = GetBaseItemType(oShield);
        if (nShieldType != BASE_ITEM_LARGESHIELD &&
            nShieldType != BASE_ITEM_SMALLSHIELD &&
            nShieldType != BASE_ITEM_TOWERSHIELD)
        {
            oShield = OBJECT_INVALID;
        }
    }

    ShifterCheck(oPC);
    ClearAllActions();

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPC);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePoly, oPC);

    object oWeaponNewRight = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R,oPC);
    object oWeaponNewLeft  = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L,oPC);
    object oWeaponNewBite  = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B,oPC);
    object oArmorNew       = GetItemInSlot(INVENTORY_SLOT_CARMOUR,oPC);

    //:: Weapon & Armor merge block
    object oMergeWeaponSource = OBJECT_INVALID;
    object oMergeArmorSource  = OBJECT_INVALID;

    // ---- Determine Weapon Merge Source ----
    if (bWeapon)
    {
        if (bMonkGloves)
        {
            if (GetIsObjectValid(oGlovesOld))
                oMergeWeaponSource = oGlovesOld;
        }
        else
        {
            if (GetIsObjectValid(oWeaponOld))
                oMergeWeaponSource = oWeaponOld;
        }
    }
    else
    {
        if (bMonkGloves && bArmsSlotAllowed && GetIsObjectValid(oGlovesOld))
            oMergeWeaponSource = oGlovesOld;
    }

    // ---- Determine Armor Merge Source ----
    if (bArmor && GetIsObjectValid(oArmorNew))
    {
        if (!bMonkGloves)
        {
            if (bArmsSlotAllowed && GetIsObjectValid(oGlovesOld))
                oMergeArmorSource = oGlovesOld;

            if (GetIsObjectValid(oShield))      IPWildShapeCopyItemProperties(oShield, oArmorNew);
            if (GetIsObjectValid(oHelmetOld))   IPWildShapeCopyItemProperties(oHelmetOld, oArmorNew);
            if (GetIsObjectValid(oArmorOld))    IPWildShapeCopyItemProperties(oArmorOld, oArmorNew);
        }
        else
        {
            if (GetIsObjectValid(oShield))      IPWildShapeCopyItemProperties(oShield, oArmorNew);
            if (GetIsObjectValid(oHelmetOld))   IPWildShapeCopyItemProperties(oHelmetOld, oArmorNew);
            if (GetIsObjectValid(oArmorOld))    IPWildShapeCopyItemProperties(oArmorOld, oArmorNew);
        }
    }
    else if (bArmor && !GetIsObjectValid(oArmorNew) && DEBUG)
    {
        DoDebug("LycanthropePoly: MergeA set, but oArmorNew invalid.");
    }

    // ---- Apply Weapon Merge ----
    if (GetIsObjectValid(oMergeWeaponSource))
    {
        if (GetIsObjectValid(oWeaponNewLeft))  IPWildShapeCopyItemProperties(oMergeWeaponSource, oWeaponNewLeft, TRUE);
        if (GetIsObjectValid(oWeaponNewRight)) IPWildShapeCopyItemProperties(oMergeWeaponSource, oWeaponNewRight, TRUE);
        if (GetIsObjectValid(oWeaponNewBite))  IPWildShapeCopyItemProperties(oMergeWeaponSource, oWeaponNewBite, TRUE);
    }

    // ---- Apply Armor Merge ----
    if (GetIsObjectValid(oMergeArmorSource))
    {
        if (GetIsObjectValid(oArmorNew)) IPWildShapeCopyItemProperties(oMergeArmorSource, oArmorNew);
    }

    //:: General item merge block
    if (bItems && GetIsObjectValid(oArmorNew))
    {
        if (GetIsObjectValid(oRing1Old)) IPWildShapeCopyItemProperties(oRing1Old, oArmorNew);
        if (GetIsObjectValid(oRing2Old)) IPWildShapeCopyItemProperties(oRing2Old, oArmorNew);
        if (GetIsObjectValid(oAmuletOld)) IPWildShapeCopyItemProperties(oAmuletOld, oArmorNew);
        if (GetIsObjectValid(oCloakOld)) IPWildShapeCopyItemProperties(oCloakOld, oArmorNew);
        if (GetIsObjectValid(oBootsOld)) IPWildShapeCopyItemProperties(oBootsOld, oArmorNew);
        if (GetIsObjectValid(oBeltOld))  IPWildShapeCopyItemProperties(oBeltOld, oArmorNew);
    }
}
//::////////////////End Werewolf////////////////// */


/* //::////////////////Begin Werewolf//////////////////
const string PRC_PNP_SHIFTING = "PRC_Shift";

void LycanthropePoly(object oPC, int nPoly)
{
    effect eVis = EffectVisualEffect(VFX_IMP_POLYMORPH);
    effect ePoly = SupernaturalEffect(EffectPolymorph(nPoly));

    int bMonkGloves = GetLocalInt(oPC, "WEARING_MONK_GLOVES");
    int bArmsSlotAllowed = GetPRCSwitch(PRC_WILDSHAPE_ALLOWS_ARMS_SLOT);

    int bWeapon = StringToInt(Get2DACache("polymorph","MergeW",nPoly)) == 1;
    int bArmor  = StringToInt(Get2DACache("polymorph","MergeA",nPoly)) == 1;
    int bItems  = StringToInt(Get2DACache("polymorph","MergeI",nPoly)) == 1;

    object oWeaponOld = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    object oArmorOld = GetItemInSlot(INVENTORY_SLOT_CHEST,oPC);
    object oRing1Old = GetItemInSlot(INVENTORY_SLOT_LEFTRING,oPC);
    object oRing2Old = GetItemInSlot(INVENTORY_SLOT_RIGHTRING,oPC);
    object oAmuletOld = GetItemInSlot(INVENTORY_SLOT_NECK,oPC);
    object oCloakOld  = GetItemInSlot(INVENTORY_SLOT_CLOAK,oPC);
    object oBootsOld  = GetItemInSlot(INVENTORY_SLOT_BOOTS,oPC);
    object oBeltOld   = GetItemInSlot(INVENTORY_SLOT_BELT,oPC);
    object oHelmetOld = GetItemInSlot(INVENTORY_SLOT_HEAD,oPC);
    object oShield    = GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oPC);
    object oGlovesOld = GetItemInSlot(INVENTORY_SLOT_ARMS,oPC);

    if (GetIsObjectValid(oShield))
    {
        int nShieldType = GetBaseItemType(oShield);
        if (nShieldType != BASE_ITEM_LARGESHIELD &&
            nShieldType != BASE_ITEM_SMALLSHIELD &&
            nShieldType != BASE_ITEM_TOWERSHIELD)
        {
            oShield = OBJECT_INVALID;
        }
    }

    ShifterCheck(oPC);
    ClearAllActions();

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPC);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePoly, oPC);

    object oWeaponNewRight = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R,oPC);
    object oWeaponNewLeft  = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L,oPC);
    object oWeaponNewBite  = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B,oPC);
    object oArmorNew       = GetItemInSlot(INVENTORY_SLOT_CARMOUR,oPC);

	//:: Weapon merge block
	if (bWeapon)
	{
		object oMergeSource = OBJECT_INVALID;

		// Priority: monk gloves override if worn and arms-slot not allowed
		if (bMonkGloves && !bArmsSlotAllowed)
		{
			if (GetIsObjectValid(oGlovesOld))
				oMergeSource = oGlovesOld;
		}
		else
		{
			// Otherwise use main-hand weapon if it exists
			if (GetIsObjectValid(oWeaponOld))
				oMergeSource = oWeaponOld;
		}

		// Apply merge to creature weapons if we have a source
		if (GetIsObjectValid(oMergeSource))
		{
			if (GetIsObjectValid(oWeaponNewLeft))  IPWildShapeCopyItemProperties(oMergeSource, oWeaponNewLeft, TRUE);
			if (GetIsObjectValid(oWeaponNewRight)) IPWildShapeCopyItemProperties(oMergeSource, oWeaponNewRight, TRUE);
			if (GetIsObjectValid(oWeaponNewBite))  IPWildShapeCopyItemProperties(oMergeSource, oWeaponNewBite, TRUE);
		}
	}

    //:: Armor merge block
    if (bArmor && GetIsObjectValid(oArmorNew))
    {
        if (GetIsObjectValid(oShield))      IPWildShapeCopyItemProperties(oShield, oArmorNew);
        if (GetIsObjectValid(oHelmetOld))   IPWildShapeCopyItemProperties(oHelmetOld, oArmorNew);
        if (GetIsObjectValid(oArmorOld))    IPWildShapeCopyItemProperties(oArmorOld, oArmorNew);

        // Arms-slot allowed -> apply gloves & bracers to creature weapons
        if (bArmsSlotAllowed && GetIsObjectValid(oGlovesOld))
        {
            if (DEBUG) DoDebug("LycanthropePoly: Arms-slot allowed -> applying gloves/bracers to creature weapons from armor branch.");
            if (GetIsObjectValid(oWeaponNewLeft))  IPWildShapeCopyItemProperties(oGlovesOld, oWeaponNewLeft, TRUE);
            if (GetIsObjectValid(oWeaponNewRight)) IPWildShapeCopyItemProperties(oGlovesOld, oWeaponNewRight, TRUE);
            if (GetIsObjectValid(oWeaponNewBite))  IPWildShapeCopyItemProperties(oGlovesOld, oWeaponNewBite, TRUE);
        }
    }
    else if (bArmor && !GetIsObjectValid(oArmorNew) && DEBUG)
    {
        DoDebug("LycanthropePoly: MergeA set, but oArmorNew invalid.");
    }

    //:: General item merge block
    if (bItems && GetIsObjectValid(oArmorNew))
    {
        if (GetIsObjectValid(oRing1Old)) IPWildShapeCopyItemProperties(oRing1Old, oArmorNew);
        if (GetIsObjectValid(oRing2Old)) IPWildShapeCopyItemProperties(oRing2Old, oArmorNew);
        if (GetIsObjectValid(oAmuletOld)) IPWildShapeCopyItemProperties(oAmuletOld, oArmorNew);
        if (GetIsObjectValid(oCloakOld)) IPWildShapeCopyItemProperties(oCloakOld, oArmorNew);
        if (GetIsObjectValid(oBootsOld)) IPWildShapeCopyItemProperties(oBootsOld, oArmorNew);
        if (GetIsObjectValid(oBeltOld))  IPWildShapeCopyItemProperties(oBeltOld, oArmorNew);
    }
}
//::////////////////End Werewolf//////////////////
 */

/* //::////////////////Begin Werewolf//////////////////
const string PRC_PNP_SHIFTING = "PRC_Shift";

void LycanthropePoly(object oPC, int nPoly)
{
    effect eVis = EffectVisualEffect(VFX_IMP_POLYMORPH);
    effect ePoly = SupernaturalEffect(EffectPolymorph(nPoly));

    int bMonkGloves = GetLocalInt(oPC, "WEARING_MONK_GLOVES");
    int bArmsSlotAllowed = GetPRCSwitch(PRC_WILDSHAPE_ALLOWS_ARMS_SLOT);

    int bWeapon = StringToInt(Get2DACache("polymorph","MergeW",nPoly)) == 1;
    int bArmor  = StringToInt(Get2DACache("polymorph","MergeA",nPoly)) == 1;
    int bItems  = StringToInt(Get2DACache("polymorph","MergeI",nPoly)) == 1;

    object oWeaponOld = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    object oArmorOld = GetItemInSlot(INVENTORY_SLOT_CHEST,oPC);
    object oRing1Old = GetItemInSlot(INVENTORY_SLOT_LEFTRING,oPC);
    object oRing2Old = GetItemInSlot(INVENTORY_SLOT_RIGHTRING,oPC);
    object oAmuletOld = GetItemInSlot(INVENTORY_SLOT_NECK,oPC);
    object oCloakOld  = GetItemInSlot(INVENTORY_SLOT_CLOAK,oPC);
    object oBootsOld  = GetItemInSlot(INVENTORY_SLOT_BOOTS,oPC);
    object oBeltOld   = GetItemInSlot(INVENTORY_SLOT_BELT,oPC);
    object oHelmetOld = GetItemInSlot(INVENTORY_SLOT_HEAD,oPC);
    object oShield    = GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oPC);
    object oGlovesOld = GetItemInSlot(INVENTORY_SLOT_ARMS,oPC);

    if (GetIsObjectValid(oShield))
    {
        int nShieldType = GetBaseItemType(oShield);
        if (nShieldType != BASE_ITEM_LARGESHIELD &&
            nShieldType != BASE_ITEM_SMALLSHIELD &&
            nShieldType != BASE_ITEM_TOWERSHIELD)
        {
            oShield = OBJECT_INVALID;
        }
    }

    ShifterCheck(oPC);
    ClearAllActions();

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPC);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePoly, oPC);

    object oWeaponNewRight = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R,oPC);
    object oWeaponNewLeft  = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L,oPC);
    object oWeaponNewBite  = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B,oPC);
    object oArmorNew       = GetItemInSlot(INVENTORY_SLOT_CARMOUR,oPC);

	//::   Weapon merge block
	//::  Only blocked if monk gloves are equipped AND arms-slot merge is NOT allowed
    if (bWeapon && !bMonkGloves)
    {
        if (GetIsObjectValid(oWeaponOld))
        {
            if (GetIsObjectValid(oWeaponNewLeft))  IPWildShapeCopyItemProperties(oWeaponOld, oWeaponNewLeft, TRUE);
            if (GetIsObjectValid(oWeaponNewRight)) IPWildShapeCopyItemProperties(oWeaponOld, oWeaponNewRight, TRUE);
            if (GetIsObjectValid(oWeaponNewBite))  IPWildShapeCopyItemProperties(oWeaponOld, oWeaponNewBite, TRUE);
        }
    }
    else if (bWeapon && bMonkGloves && !bArmsSlotAllowed)
    {
        if (DEBUG) DoDebug("LycanthropePoly: Monk gloves overriding weapon merge (arms slot NOT allowed).");
        if (GetIsObjectValid(oGlovesOld))
        {
            if (GetIsObjectValid(oWeaponNewLeft))  IPWildShapeCopyItemProperties(oGlovesOld, oWeaponNewLeft, TRUE);
            if (GetIsObjectValid(oWeaponNewRight)) IPWildShapeCopyItemProperties(oGlovesOld, oWeaponNewRight, TRUE);
            if (GetIsObjectValid(oWeaponNewBite))  IPWildShapeCopyItemProperties(oGlovesOld, oWeaponNewBite, TRUE);
        }
    }


	//:: Armor merge block
	//:: Apply armor and gloves (if arms-slot allowed)

    if (bArmor && GetIsObjectValid(oArmorNew))
    {
        if (GetIsObjectValid(oShield))      IPWildShapeCopyItemProperties(oShield, oArmorNew);
        if (GetIsObjectValid(oHelmetOld))   IPWildShapeCopyItemProperties(oHelmetOld, oArmorNew);
        if (GetIsObjectValid(oArmorOld))    IPWildShapeCopyItemProperties(oArmorOld, oArmorNew);

        if (bArmsSlotAllowed && bMonkGloves && GetIsObjectValid(oGlovesOld))
        {
            if (DEBUG) DoDebug("LycanthropePoly: Arms-slot allowed -> applying gloves to creature weapons from armor branch.");
            if (GetIsObjectValid(oWeaponNewLeft))  IPWildShapeCopyItemProperties(oGlovesOld, oWeaponNewLeft, TRUE);
            if (GetIsObjectValid(oWeaponNewRight)) IPWildShapeCopyItemProperties(oGlovesOld, oWeaponNewRight, TRUE);
            if (GetIsObjectValid(oWeaponNewBite))  IPWildShapeCopyItemProperties(oGlovesOld, oWeaponNewBite, TRUE);
        }
    }
    else if (bArmor && !GetIsObjectValid(oArmorNew) && DEBUG)
    {
        DoDebug("LycanthropePoly: MergeA set, but oArmorNew invalid.");
    }

    //::   General item merge block
    if (bItems && GetIsObjectValid(oArmorNew))
    {
        if (GetIsObjectValid(oRing1Old)) IPWildShapeCopyItemProperties(oRing1Old, oArmorNew);
        if (GetIsObjectValid(oRing2Old)) IPWildShapeCopyItemProperties(oRing2Old, oArmorNew);
        if (GetIsObjectValid(oAmuletOld)) IPWildShapeCopyItemProperties(oAmuletOld, oArmorNew);
        if (GetIsObjectValid(oCloakOld)) IPWildShapeCopyItemProperties(oCloakOld, oArmorNew);
        if (GetIsObjectValid(oBootsOld)) IPWildShapeCopyItemProperties(oBootsOld, oArmorNew);
        if (GetIsObjectValid(oBeltOld))  IPWildShapeCopyItemProperties(oBeltOld, oArmorNew);
    }
}
//::////////////////End Werewolf////////////////// */


/* //::////////////////Begin Werewolf//////////////////
const string PRC_PNP_SHIFTING = "PRC_Shift";

void LycanthropePoly(object oPC, int nPoly)
{
    effect eVis = EffectVisualEffect(VFX_IMP_POLYMORPH);
    effect ePoly = SupernaturalEffect(EffectPolymorph(nPoly));

    int bMonkGloves = GetLocalInt(oPC, "WEARING_MONK_GLOVES");
    int bArmsSlotAllowed = GetPRCSwitch(PRC_WILDSHAPE_ALLOWS_ARMS_SLOT);

    int bWeapon = StringToInt(Get2DACache("polymorph","MergeW",nPoly)) == 1;
    int bArmor  = StringToInt(Get2DACache("polymorph","MergeA",nPoly)) == 1;
    int bItems  = StringToInt(Get2DACache("polymorph","MergeI",nPoly)) == 1;

    object oWeaponOld = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    object oArmorOld = GetItemInSlot(INVENTORY_SLOT_CHEST,oPC);
    object oRing1Old = GetItemInSlot(INVENTORY_SLOT_LEFTRING,oPC);
    object oRing2Old = GetItemInSlot(INVENTORY_SLOT_RIGHTRING,oPC);
    object oAmuletOld = GetItemInSlot(INVENTORY_SLOT_NECK,oPC);
    object oCloakOld  = GetItemInSlot(INVENTORY_SLOT_CLOAK,oPC);
    object oBootsOld  = GetItemInSlot(INVENTORY_SLOT_BOOTS,oPC);
    object oBeltOld   = GetItemInSlot(INVENTORY_SLOT_BELT,oPC);
    object oHelmetOld = GetItemInSlot(INVENTORY_SLOT_HEAD,oPC);
    object oShield    = GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oPC);
    object oGlovesOld = GetItemInSlot(INVENTORY_SLOT_ARMS,oPC);

    if (GetIsObjectValid(oShield))
    {
        int nShieldType = GetBaseItemType(oShield);
        if (nShieldType != BASE_ITEM_LARGESHIELD &&
            nShieldType != BASE_ITEM_SMALLSHIELD &&
            nShieldType != BASE_ITEM_TOWERSHIELD)
        {
            oShield = OBJECT_INVALID;
        }
    }

    ShifterCheck(oPC);
    ClearAllActions();

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPC);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePoly, oPC);

    object oWeaponNewRight = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R,oPC);
    object oWeaponNewLeft  = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L,oPC);
    object oWeaponNewBite  = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B,oPC);
    object oArmorNew       = GetItemInSlot(INVENTORY_SLOT_CARMOUR,oPC);

	//::   Weapon merge block
	//::  Only blocked if monk gloves are equipped AND arms-slot merge is NOT allowed
    if (bWeapon && !bMonkGloves)
    {
        if (GetIsObjectValid(oWeaponOld))
        {
            if (GetIsObjectValid(oWeaponNewLeft))  IPWildShapeCopyItemProperties(oWeaponOld, oWeaponNewLeft, TRUE);
            if (GetIsObjectValid(oWeaponNewRight)) IPWildShapeCopyItemProperties(oWeaponOld, oWeaponNewRight, TRUE);
            if (GetIsObjectValid(oWeaponNewBite))  IPWildShapeCopyItemProperties(oWeaponOld, oWeaponNewBite, TRUE);
        }
    }
    else if (bWeapon && bMonkGloves && !bArmsSlotAllowed)
    {
        if (DEBUG) DoDebug("LycanthropePoly: Monk gloves overriding weapon merge (arms slot NOT allowed).");
        if (GetIsObjectValid(oGlovesOld))
        {
            if (GetIsObjectValid(oWeaponNewLeft))  IPWildShapeCopyItemProperties(oGlovesOld, oWeaponNewLeft, TRUE);
            if (GetIsObjectValid(oWeaponNewRight)) IPWildShapeCopyItemProperties(oGlovesOld, oWeaponNewRight, TRUE);
            if (GetIsObjectValid(oWeaponNewBite))  IPWildShapeCopyItemProperties(oGlovesOld, oWeaponNewBite, TRUE);
        }
    }


	//:: Armor merge block
	//:: Apply armor and gloves (if arms-slot allowed)

    if (bArmor && GetIsObjectValid(oArmorNew))
    {
        if (GetIsObjectValid(oShield))      IPWildShapeCopyItemProperties(oShield, oArmorNew);
        if (GetIsObjectValid(oHelmetOld))   IPWildShapeCopyItemProperties(oHelmetOld, oArmorNew);
        if (GetIsObjectValid(oArmorOld))    IPWildShapeCopyItemProperties(oArmorOld, oArmorNew);

        if (bArmsSlotAllowed && bMonkGloves && GetIsObjectValid(oGlovesOld))
        {
            if (DEBUG) DoDebug("LycanthropePoly: Arms-slot allowed -> applying gloves to creature weapons from armor branch.");
            if (GetIsObjectValid(oWeaponNewLeft))  IPWildShapeCopyItemProperties(oGlovesOld, oWeaponNewLeft, TRUE);
            if (GetIsObjectValid(oWeaponNewRight)) IPWildShapeCopyItemProperties(oGlovesOld, oWeaponNewRight, TRUE);
            if (GetIsObjectValid(oWeaponNewBite))  IPWildShapeCopyItemProperties(oGlovesOld, oWeaponNewBite, TRUE);
        }
    }
    else if (bArmor && !GetIsObjectValid(oArmorNew) && DEBUG)
    {
        DoDebug("LycanthropePoly: MergeA set, but oArmorNew invalid.");
    }

    //::   General item merge block
    if (bItems && GetIsObjectValid(oArmorNew))
    {
        if (GetIsObjectValid(oRing1Old)) IPWildShapeCopyItemProperties(oRing1Old, oArmorNew);
        if (GetIsObjectValid(oRing2Old)) IPWildShapeCopyItemProperties(oRing2Old, oArmorNew);
        if (GetIsObjectValid(oAmuletOld)) IPWildShapeCopyItemProperties(oAmuletOld, oArmorNew);
        if (GetIsObjectValid(oCloakOld)) IPWildShapeCopyItemProperties(oCloakOld, oArmorNew);
        if (GetIsObjectValid(oBootsOld)) IPWildShapeCopyItemProperties(oBootsOld, oArmorNew);
        if (GetIsObjectValid(oBeltOld))  IPWildShapeCopyItemProperties(oBeltOld, oArmorNew);
    }
}
//::////////////////End Werewolf////////////////// */


/* ////////////////Begin Werewolf//////////////////

void LycanthropePoly(object oPC, int nPoly)
{
    effect eVis = EffectVisualEffect(VFX_IMP_POLYMORPH);
    effect ePoly;

    ePoly = EffectPolymorph(nPoly);
    ePoly = SupernaturalEffect(ePoly);

    int bWeapon = StringToInt(Get2DACache("polymorph","MergeW",nPoly)) == 1;
    int bArmor  = StringToInt(Get2DACache("polymorph","MergeA",nPoly)) == 1;
    int bItems  = StringToInt(Get2DACache("polymorph","MergeI",nPoly)) == 1;

    object oWeaponOld = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    object oArmorOld = GetItemInSlot(INVENTORY_SLOT_CHEST,oPC);
    object oRing1Old = GetItemInSlot(INVENTORY_SLOT_LEFTRING,oPC);
    object oRing2Old = GetItemInSlot(INVENTORY_SLOT_RIGHTRING,oPC);
    object oAmuletOld = GetItemInSlot(INVENTORY_SLOT_NECK,oPC);
    object oCloakOld  = GetItemInSlot(INVENTORY_SLOT_CLOAK,oPC);
    object oBootsOld  = GetItemInSlot(INVENTORY_SLOT_BOOTS,oPC);
    object oBeltOld = GetItemInSlot(INVENTORY_SLOT_BELT,oPC);
    object oHelmetOld = GetItemInSlot(INVENTORY_SLOT_HEAD,oPC);
    object oShield    = GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oPC);
    if (GetIsObjectValid(oShield))
    {
        if (GetBaseItemType(oShield) !=BASE_ITEM_LARGESHIELD &&
            GetBaseItemType(oShield) !=BASE_ITEM_SMALLSHIELD &&
            GetBaseItemType(oShield) !=BASE_ITEM_TOWERSHIELD)
        {
            oShield = OBJECT_INVALID;
        }
    }

    //check if a shifter and if shifted then unshift
    ShifterCheck(oPC);

    ClearAllActions(); // prevents an exploit

    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPC);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePoly, oPC);

    object oWeaponNewRight = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R,oPC);
    object oWeaponNewLeft = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L,oPC);
    object oWeaponNewBite = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B,oPC);
    object oArmorNew = GetItemInSlot(INVENTORY_SLOT_CARMOUR,oPC);

    if (bWeapon)
    {
        IPWildShapeCopyItemProperties(oWeaponOld,oWeaponNewLeft, TRUE);
        IPWildShapeCopyItemProperties(oWeaponOld,oWeaponNewRight, TRUE);
        IPWildShapeCopyItemProperties(oWeaponOld,oWeaponNewBite, TRUE);
    }
    if (bArmor)
    {
        IPWildShapeCopyItemProperties(oShield,oArmorNew);
        IPWildShapeCopyItemProperties(oHelmetOld,oArmorNew);
        IPWildShapeCopyItemProperties(oArmorOld,oArmorNew);
    }
    if (bItems)
    {
        IPWildShapeCopyItemProperties(oRing1Old,oArmorNew);
        IPWildShapeCopyItemProperties(oRing2Old,oArmorNew);
        IPWildShapeCopyItemProperties(oAmuletOld,oArmorNew);
        IPWildShapeCopyItemProperties(oCloakOld,oArmorNew);
        IPWildShapeCopyItemProperties(oBootsOld,oArmorNew);
        IPWildShapeCopyItemProperties(oBeltOld,oArmorNew);
    }

}

////////////////End Werewolf////////////////// */

void ShifterCheck(object oPC)
{
    if (!GetIsPC(oPC))
        return;
    //int iShifterLevels = GetLevelByClass(CLASS_TYPE_PNP_SHIFTER,oPC);
    //if (iShifterLevels>0)
    //{
        int iTemp = GetPersistantLocalInt(oPC,"nPCShifted");

        if (iTemp)
        {
        DoDebug("ShifterCheck(): calling UnShift()");
        //SetShiftTrueForm(oPC);
        UnShift(oPC, TRUE);
        }
    //}
}


//changes portrait, head, and appearance
//based on the target race with a degree of randomization.
void DoDisguise(int nRace, object oTarget = OBJECT_SELF)
{
    //store current appearance to be safe
    StoreAppearance(oTarget);
    int nAppearance; //appearance to change into
    int nHeadMax;    //max head ID, changed to random 1-max
    int nGender = GetGender(oTarget);
    int nPortraitMin;//minimum row in portraits.2da
    int nPortraitMax;//maximum row in portraits.2da
    switch(nRace)
    {
        case RACIAL_TYPE_DWARF:
            nAppearance = APPEARANCE_TYPE_DWARF;
            if(nGender == GENDER_MALE)
            {   nHeadMax = 10; nPortraitMin =   9;  nPortraitMax =  17; }
            else
            {   nHeadMax = 12; nPortraitMin =   1;  nPortraitMax =   8; }
            break;
        case RACIAL_TYPE_ELF:
            nAppearance = APPEARANCE_TYPE_ELF;
            if(nGender == GENDER_MALE)
            {   nHeadMax = 10; nPortraitMin =  31;  nPortraitMax =  40; }
            else
            {   nHeadMax = 16; nPortraitMin =  18;  nPortraitMax =  30; }
            break;
        case RACIAL_TYPE_HALFELF:
            nAppearance = APPEARANCE_TYPE_HALF_ELF;
            if(nGender == GENDER_MALE)
            {   nHeadMax = 18; nPortraitMin =  93;  nPortraitMax = 112; }
            else
            {   nHeadMax = 15; nPortraitMin =  67;  nPortraitMax = 92;  }
            break;
        case RACIAL_TYPE_HALFORC:
            nAppearance = APPEARANCE_TYPE_HALF_ORC;
            if(nGender == GENDER_MALE)
            {   nHeadMax = 11; nPortraitMin = 134;  nPortraitMax = 139; }
            else
            {   nHeadMax = 1;  nPortraitMin = 130;  nPortraitMax = 133; }
            break;
        case RACIAL_TYPE_HUMAN:
            nAppearance = APPEARANCE_TYPE_HUMAN;
            if(nGender == GENDER_MALE)
            {   nHeadMax = 18; nPortraitMin = 93;   nPortraitMax = 112; }
            else
            {   nHeadMax = 15; nPortraitMin = 67;   nPortraitMax = 92;  }
            break;
        case RACIAL_TYPE_HALFLING:
            nAppearance = APPEARANCE_TYPE_HALFLING;
            if(nGender == GENDER_MALE)
            {   nHeadMax =  8; nPortraitMin = 61;   nPortraitMax = 66; }
            else
            {   nHeadMax = 11; nPortraitMin = 54;   nPortraitMax = 59;  }
            break;
        case RACIAL_TYPE_GNOME:
            nAppearance = APPEARANCE_TYPE_GNOME;
            if(nGender == GENDER_MALE)
            {   nHeadMax = 11; nPortraitMin = 47;   nPortraitMax = 53; }
            else
            {   nHeadMax =  9; nPortraitMin = 41;   nPortraitMax = 46;  }
            break;
        default: //not a normal race, abort
            return;
    }
    //change the appearance
    SetCreatureAppearanceType(oTarget, nAppearance);

    //need to be delayed a bit otherwise you get "supergnome" and "exploded elf" effects
    DelayCommand(1.1, SetCreatureBodyPart(CREATURE_PART_RIGHT_SHIN,       d2(), oTarget));
    DelayCommand(1.2, SetCreatureBodyPart(CREATURE_PART_LEFT_SHIN,        d2(), oTarget));
    DelayCommand(1.3, SetCreatureBodyPart(CREATURE_PART_RIGHT_THIGH,      d2(), oTarget));
    DelayCommand(1.4, SetCreatureBodyPart(CREATURE_PART_LEFT_THIGH,       d2(), oTarget));
    DelayCommand(1.5, SetCreatureBodyPart(CREATURE_PART_TORSO,            d2(), oTarget));
    DelayCommand(1.6, SetCreatureBodyPart(CREATURE_PART_RIGHT_FOREARM,    d2(), oTarget));
    DelayCommand(1.7, SetCreatureBodyPart(CREATURE_PART_LEFT_FOREARM,     d2(), oTarget));
    DelayCommand(1.8, SetCreatureBodyPart(CREATURE_PART_RIGHT_BICEP,      d2(), oTarget));
    DelayCommand(1.9, SetCreatureBodyPart(CREATURE_PART_LEFT_BICEP,       d2(), oTarget));
    
    //dont do these body parts, they dont have tattoos and weird things could happen
    //SetCreatureBodyPart(CREATURE_PART_BELT,             d2(), oTarget);
    //SetCreatureBodyPart(CREATURE_PART_NECK,             d2(), oTarget);
    //SetCreatureBodyPart(CREATURE_PART_RIGHT_SHOULDER,   d2(), oTarget);
    //SetCreatureBodyPart(CREATURE_PART_LEFT_SHOULDER,    d2(), oTarget);
    //SetCreatureBodyPart(CREATURE_PART_RIGHT_HAND,       d2(), oTarget);
    //SetCreatureBodyPart(CREATURE_PART_LEFT_HAND,        d2(), oTarget);
    //SetCreatureBodyPart(CREATURE_PART_PELVIS,           d2(), oTarget);
    //SetCreatureBodyPart(CREATURE_PART_RIGHT_FOOT,       d2(), oTarget);
    //SetCreatureBodyPart(CREATURE_PART_LEFT_FOOT,        d2(), oTarget);
    //randomise the head
    DelayCommand(2.0, SetCreatureBodyPart(CREATURE_PART_HEAD, Random(nHeadMax)+1, oTarget));
    
    //remove any wings/tails
    SetCreatureWingType(CREATURE_WING_TYPE_NONE, oTarget);
    SetCreatureTailType(CREATURE_TAIL_TYPE_NONE, oTarget);

    int nPortraitID = Random(nPortraitMax-nPortraitMin+1)+nPortraitMin;
    string sPortraitResRef = Get2DACache("portraits", "BaseResRef", nPortraitID);
    sPortraitResRef = GetStringLeft(sPortraitResRef, GetStringLength(sPortraitResRef)-1); //trim the trailing _
    SetPortraitResRef(oTarget, sPortraitResRef);
    SetPortraitId(oTarget, nPortraitID);
}

//utility functions to make sure characters that gain wings/tails permanently
//interact with the polymorph system by overwriting the default form


void DoWings(object oPC, int nWingType)
{
    //wing invalid, abort
    if(nWingType <= 0) 
        return;
    //already has wings, keep them
    if(GetCreatureWingType(oPC) != CREATURE_WING_TYPE_NONE) 
        return;   
    //already has a default wings, keep them   
    if(GetPersistantLocalInt(oPC,    "AppearanceStoredWing"))
        return;
    //if polymorphed or shifted, dont do the real change
    if(!GetIsPolyMorphedOrShifted(oPC)) 
        SetCreatureWingType(nWingType, oPC);
    //override any stored default appearance
    SetPersistantLocalInt(oPC,    "AppearanceStoredWing", nWingType);    
}

void DoTail(object oPC, int nTailType)
{
    //tail invalid, use current
    if(nTailType == -1) 
        return;
    //already has tail, keep it
    if(GetCreatureTailType(oPC)) 
        return;
    //already has a default tail, keep it   
    if(GetPersistantLocalInt(oPC,    "AppearanceStoredTail"))
        return;
    //if polymorphed or shifted, dont do the real change
    if(!GetIsPolyMorphedOrShifted(oPC)) 
        SetCreatureTailType(nTailType, oPC);
    //override any stored default appearance
    SetPersistantLocalInt(oPC,    "AppearanceStoredTail", nTailType);
}

//::void main (){}