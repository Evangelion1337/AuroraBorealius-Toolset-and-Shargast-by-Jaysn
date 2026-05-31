//include file for new polymorph like functions using the pnp shifters shifting code
//created by paradox_42 - 2005/07/01


// used to shift by resref
// oPC = PC to shift/polymorph
// sResRef = ResRef of Target to shift/polymorph into
// iExtraAbilitys = gives epic shifter orb with target spell-like abilitys on it (TRUE = extra; FALSE = non)
int PRC_Polymorph_ResRef(object oPC, string sResRef, int iExtraAbilitys);

// used to shift by Object
// oPC = PC to shift/polymorph
// oTarget = Target object to shift/polymorph into
// iExtraAbilitys = gives epic shifter orb with target spell-like abilitys on it (TRUE = extra; FALSE = non)
// iDeleteTarget = delete the target object after shift done (TRUE = delete; FALSE = leave)
// iUseClone = use the ResRef of the target object to create a clone to shift into (TRUE = use clone; FALSE = use target object)
int PRC_Polymorph_Object(object oPC, object oTarget, int iExtraAbilitys, int iDeleteTarget, int iUseClone);

// used to check for shifted
// oPC = PC to check if shifted or not
// returns TRUE if shifted
int PRC_Polymorph_Check(object oPC);

// used to unshift the PC
// oPC = PC to unshift/unpolymorph
void PRC_UnPolymorph(object oPC);

#include "pnp_shft_main"



int PRC_Polymorph_ResRef(object oPC, string sResRef, int iExtraAbilitys)
{
    StoreAppearance(oPC);
    if (!CanShift(oPC))
    {
        return FALSE;
    }
    int i = 0;
    object oLimbo = GetObjectByTag("Limbo", i);
    location lLimbo;
    while (i < 100)
    {
        if (GetIsObjectValid(oLimbo))
        {
            if (GetName(oLimbo) == "Limbo")
            {
                i = 2000;
                vector vLimbo = Vector(0.0f, 0.0f, 0.0f);
                lLimbo = Location(oLimbo, vLimbo, 0.0f);
            }
        }
        i++;
        object oLimbo = GetObjectByTag("Limbo", i);
    }
    object oTarget;
    if (i>=2000)
    {
        oTarget = CreateObject(OBJECT_TYPE_CREATURE,sResRef,lLimbo);
    }
    else
    {
        oTarget = CreateObject(OBJECT_TYPE_CREATURE,sResRef,GetLocation(oPC));
    }
    if (!GetIsObjectValid(oTarget))
    {
        SendMessageToPC(oPC, "Not a valid creature.");
        // Remove the temporary creature
        AssignCommand(oTarget,SetIsDestroyable(TRUE,FALSE,FALSE));
        SetPlotFlag(oTarget,FALSE);
        SetImmortal(oTarget,FALSE);
        DestroyObject(oTarget);
        return FALSE;
    }
    else
    {
        //get the appearance before changing it
        SetLocalInt(oTarget,"Appearance",GetAppearanceType(oTarget));
        //set appearance to invis so it dont show up when scripts run thro
        SetCreatureAppearanceType(oTarget,APPEARANCE_TYPE_INVISIBLE_HUMAN_MALE);
        //set oTarget for deletion
        SetLocalInt(oTarget,"pnp_shifter_deleteme",1);
        //Shift the PC to it
        if (iExtraAbilitys == TRUE)
            SetShiftEpic(oPC, oTarget);
        else
            SetShift(oPC, oTarget);
        return TRUE;
    }
}

int PRC_Polymorph_Object(object oPC, object oTarget, int iExtraAbilitys, int iDeleteTarget, int iUseClone)
{
    StoreAppearance(oPC);
    if (!CanShift(oPC))
    {
        return FALSE;
    }
    if (iUseClone == TRUE)
    {
        string sResRef = GetResRef(oTarget);
        int i = 0;
        object oLimbo = GetObjectByTag("Limbo", i);
        location lLimbo;
        while (i < 100)
        {
            if (GetIsObjectValid(oLimbo))
            {
                if (GetName(oLimbo) == "Limbo")
                {
                    i = 2000;
                    vector vLimbo = Vector(0.0f, 0.0f, 0.0f);
                    lLimbo = Location(oLimbo, vLimbo, 0.0f);
                }
            }
            i++;
            object oLimbo = GetObjectByTag("Limbo", i);
        }
        if (i>=2000)
        {
            oTarget = CreateObject(OBJECT_TYPE_CREATURE,sResRef,lLimbo);
        }
        else
        {
            oTarget = CreateObject(OBJECT_TYPE_CREATURE,sResRef,GetLocation(oPC));
        }
    }
    if (!GetIsObjectValid(oTarget))
    {
        SendMessageToPC(oPC, "Not a valid creature.");
        // Remove the temporary creature
        AssignCommand(oTarget,SetIsDestroyable(TRUE,FALSE,FALSE));
        SetPlotFlag(oTarget,FALSE);
        SetImmortal(oTarget,FALSE);
        DestroyObject(oTarget);
        return FALSE;
    }
    else
    {
        SetLocalInt(oTarget,"Appearance",GetAppearanceType(oTarget));
        if (iDeleteTarget == TRUE)
        {
            //set oTarget for deletion
            SetLocalInt(oTarget,"pnp_shifter_deleteme",1);
        }
        //Shift the PC to it
        if (iExtraAbilitys == TRUE)
            SetShiftEpic(oPC, oTarget);
        else
            SetShift(oPC, oTarget);
        return TRUE;
    }
}

int PRC_Polymorph_Check(object oPC)
{
    return GetPersistantLocalInt(oPC, "nPCShifted");
}

void PRC_UnPolymorph(object oPC)
{
    ExecuteScript("pnp_shft_true", oPC);
}


// Test main
//void main(){}
