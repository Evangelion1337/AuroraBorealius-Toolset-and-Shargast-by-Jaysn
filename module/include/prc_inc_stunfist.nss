/////////////////////////////////////////////////////////////////
// notes:
//   "normal" stunning fist uses are what is normally given, not taking into account the PrC
//   "extra" stunning fist uses are what uses that come from PrC classes, they can be converted into "normal" uses and dont do anything by themselves
//		this is to work around the hardcoded limit of the "normal" stunning fist uses

// Try to expend a number of stunning fist uses, returns true if succesfull
int ExpendStunfistUses(object oPC, int nUses);

// Reset extra stunning fist uses to the extra uses/day a character has (use on rest)
void ResetExtraStunfistUses(object oPC);

// Get remaining "normal" stunning fist uses
int GetNormalRemainingStunfistUses(object oPC);

// Get remaining "extra" stunning fist uses
int GetExtraRemainingStunfistUses(object oPC);

// Get total remaining stunning fist uses
int GetTotalRemainingStunfistUses(object oPC);

// Get amount of "normal" stunning fist uses/day a character has
int GetNormalStunfistUsesPerDay(object oPC);

// Get amount of "extra" stunning fist uses/day a character has
int GetExtraStunfistUsesPerDay(object oPC);

// Get total amount of stunning fist uses/day a character has
int GetTotalStunFistUsesPerDay(object oPC);

// Set remaining "normal" stunning fist uses
void SetNormalRemainingStunfistUses(object oPC, int nUses);

// Set remaining "extra" stunning fist uses
void SetExtraRemainingStunfistUses(object oPC, int nUses);

// Convert "extra" stunning fist uses to "normal" (BW) stunning fist uses
void ConvertStunFistUses(object oPC);

//================================

// Minimalist includes

#include "prc_feat_const"
#include "prc_class_const"
#include "inc_item_props"
#include "prc_ipfeat_const"
//#include "prc_alterations"

// Try to expend a number of stunning fist uses, returns true if succesfull
int ExpendStunfistUses(object oPC, int nUses)
{
	if (GetTotalRemainingStunfistUses(oPC) < nUses)
	{
		SendMessageToPC(oPC, "You don't have enough uses for this feat!");
		return FALSE;
	}

	ConvertStunFistUses(oPC);

	while (nUses)
	{
		nUses--;
		DecrementRemainingFeatUses(oPC, FEAT_STUNNING_FIST);
		ConvertStunFistUses(oPC);
	}

	return TRUE;
}

// Reset extra stunning fist uses to the extra uses/day a character has (use on rest)
void ResetExtraStunfistUses(object oPC)
{
	object oSkin = GetPCSkin(oPC);
	int nUses = GetExtraStunfistUsesPerDay(oPC);

	if (nUses && !GetLocalInt(oPC, "PRCExtraStunningMessage"))
	{
		SetLocalInt(oPC, "PRCExtraStunningMessage", TRUE);
		DelayCommand(3.001f, SendMessageToPC(oPC, "You gained extra stunning fist uses per day, use the feat 'PrC Extra Stunning'"));
		DelayCommand(3.002f, SendMessageToPC(oPC, "to convert those uses into normal stunning fist uses"));
	}

	SetExtraRemainingStunfistUses(oPC, nUses);
}

void ConvertStunFistUses(object oPC)
{
	while (GetNormalRemainingStunfistUses(oPC) < GetNormalStunfistUsesPerDay(oPC) && GetHasFeat(FEAT_PRC_EXTRA_STUNNING, oPC))
	{
		IncrementRemainingFeatUses(oPC, FEAT_STUNNING_FIST);
		DecrementRemainingFeatUses(oPC, FEAT_PRC_EXTRA_STUNNING);
	}
}

// Get remaining "normal" stunning fist uses
int GetNormalRemainingStunfistUses(object oPC)
{
	int nUses = 0;
	while (GetHasFeat(FEAT_STUNNING_FIST, oPC))
	{
		nUses++;
		DecrementRemainingFeatUses(oPC, FEAT_STUNNING_FIST);
	}

	SetNormalRemainingStunfistUses(oPC, nUses);
	return nUses;
}

// Get remaining "extra" stunning fist uses
int GetExtraRemainingStunfistUses(object oPC)
{
	int nUses = 0;
	while (GetHasFeat(FEAT_PRC_EXTRA_STUNNING, oPC))
	{
		nUses++;
		DecrementRemainingFeatUses(oPC, FEAT_PRC_EXTRA_STUNNING);
	}

	SetExtraRemainingStunfistUses(oPC, nUses);

	return nUses;
}

// Get total remaining stunning fist uses
int GetTotalRemainingStunfistUses(object oPC)
{
	return GetNormalRemainingStunfistUses(oPC) + GetExtraRemainingStunfistUses(oPC);
}

// Get amount of "normal" stunning fist uses/day a character has
int GetNormalStunfistUsesPerDay(object oPC)
{
	int nUses = GetNormalRemainingStunfistUses(oPC);
	int nMaxUses = nUses;
	while (nMaxUses == GetNormalRemainingStunfistUses(oPC))
	{
		IncrementRemainingFeatUses(oPC, FEAT_STUNNING_FIST);
		nMaxUses++;
	}
	nMaxUses--;
	SetNormalRemainingStunfistUses(oPC, nUses);
	return nMaxUses;
}

// Get amount of "extra" stunning fist uses/day a character has
int GetExtraStunfistUsesPerDay(object oPC)
{
	int nUses = 0;

	// classes/effects which give extra stunning fist uses/day should be added here
	nUses += GetLevelByClass(CLASS_TYPE_ENLIGHTENEDFIST, oPC);
	nUses += GetLevelByClass(CLASS_TYPE_SHADOW_SUN_NINJA, oPC);
	nUses += GetLocalInt(oPC, "LiPengStun");

	return nUses;
}

// Get total amount of stunning fist uses/day a character has
int GetTotalStunFistUsesPerDay(object oPC)
{
	return GetNormalStunfistUsesPerDay(oPC) + GetExtraStunfistUsesPerDay(oPC);
}

// Set remaining "normal" stunning fist uses
void SetNormalRemainingStunfistUses(object oPC, int nUses)
{
	while (GetHasFeat(FEAT_STUNNING_FIST, oPC))
	{
		DecrementRemainingFeatUses(oPC, FEAT_STUNNING_FIST);
	}

	while (nUses--)
	{
		IncrementRemainingFeatUses(oPC, FEAT_STUNNING_FIST);
	}
}

// Set remaining "extra" stunning fist uses
void SetExtraRemainingStunfistUses(object oPC, int nUses)
{
	while (GetHasFeat(FEAT_PRC_EXTRA_STUNNING, oPC))
	{
		DecrementRemainingFeatUses(oPC, FEAT_PRC_EXTRA_STUNNING);
	}

	while (nUses--)
	{
		IncrementRemainingFeatUses(oPC, FEAT_PRC_EXTRA_STUNNING);
	}
}