#include "inc_utility"
#include "inc_sql"
#include "prc_inc_chat"

const string XCHST_PLC  = "xchst_plc";
const string XCHST_CONT = "xchst_cont";
//const string XCHST_DB   = "xchst_db";
const string XCHST_OWN  = "xchst_owner";
const string XCHST_ID   = "xchst_id";

// return database ID from oTarget
string GetOwnerID(object oPC)
{
  string sID = GetPCPublicCDKey(oPC, TRUE);
         sID += "#" + GetName(oPC);
  return GetSubString(sID, 0, 20);
}

location MoveLocation(location lCurrent,float fDirection,float fDistance,float fOffFacing = 0.0,float fOffZ = 0.0f)
{
    vector vPos = GetPositionFromLocation(lCurrent);
    float fFace = GetFacingFromLocation(lCurrent);
    float fNewX = vPos.x + (fDistance * cos(fFace + fDirection));
    float fNewY = vPos.y + (fDistance * sin(fFace + fDirection));
    float fNewZ = vPos.z + (fOffZ);
    vector vNewPos = Vector(fNewX,fNewY,fNewZ);
    location lNewLoc = Location(GetAreaFromLocation(lCurrent),vNewPos,fFace + fOffFacing);
    return lNewLoc;
}

object CreateChest(object oOwner, location lTarget, string sID)
{
    //Create the item container first
    object oChest;
    if(GetPRCSwitch(PRC_USE_DATABASE))
        oChest = PRC_GetPersistentObject(oOwner, sID, OBJECT_INVALID, XCHST_DB);
    else
        oChest = RetrieveCampaignObject(XCHST_DB, sID, lTarget);

    if(!GetIsObjectValid(oChest))
        oChest = CreateObject(OBJECT_TYPE_CREATURE, XCHST_CONT, lTarget, FALSE);

    effect eLink = EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY);
           eLink = EffectLinkEffects(eLink, EffectCutsceneImmobilize());
           eLink = EffectLinkEffects(eLink, EffectCutsceneGhost());
           eLink = EffectLinkEffects(eLink, EffectAreaOfEffect(185, "", "", "xchst_exit"));
           eLink = SupernaturalEffect(eLink);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oChest);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectEthereal()), oChest);

    //now the placeable
    object oPLC = CreateObject(OBJECT_TYPE_PLACEABLE, XCHST_PLC, lTarget, FALSE);
    effect eVis = SupernaturalEffect(EffectVisualEffect(VFX_DUR_PROT_SHADOW_ARMOR));
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eVis, oPLC);

    SetLocalObject(oChest, XCHST_PLC, oPLC);
    SetLocalObject(oChest, XCHST_OWN, oOwner);
    SetLocalString(oChest, XCHST_ID, sID);
    //bind the chest to pc and placeable object
    SetLocalObject(oOwner, XCHST_CONT, oChest);
    SetLocalObject(oPLC, XCHST_CONT, oChest);

    return oChest;
}

void SummonChest(object oPC)
{
    location lNewLoc = MoveLocation(GetLocation(oPC), 0.0, 1.5, 0.0, 0.0);
    CreateChest(oPC, lNewLoc, GetOwnerID(oPC));
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_3), lNewLoc);
}

void DismissChest(object oChest)
{
    object oPC = GetLocalObject(oChest, XCHST_OWN);
    object oPLC = GetLocalObject(oChest, XCHST_PLC);
    string sOwnerID = GetLocalString(oChest, XCHST_ID);

    AssignCommand(oChest, ClearAllActions(TRUE));
    RemoveHenchman(oPC, oChest);
    DeleteLocalObject(oPC, XCHST_CONT);

    if(GetPRCSwitch(PRC_USE_DATABASE))
        PRC_SetPersistentObject(oPC, sOwnerID, oChest, 0, XCHST_DB);
    else
        StoreCampaignObject(XCHST_DB, sOwnerID, oChest);

    // if not in single player mode - export character
    if(GetPCPublicCDKey(oPC) != "")
        ExportSingleCharacter(oPC);

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_UNSUMMON), GetLocation(oPLC));
    MyDestroyObject(oChest);
    MyDestroyObject(oPLC);
}