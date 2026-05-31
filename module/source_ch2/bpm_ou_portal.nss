//::///////////////////////////////////////////////
//:: Gatestones 1.6
//:: bpm_ou_portal
//:: Copyright (c) 2006 CarfaxAbbey.net
//:://////////////////////////////////////////////
/*
    To be placed in the OnUsed Script of the portals.
*/
//:://////////////////////////////////////////////
//:: Created By: Diavlen <diavlen@carfaxabbey.net>
//:: Created On: 3/24/2004
//:: Updated on: 8/11/2006
//:://////////////////////////////////////////////

void main()
{
    object oPC          =   GetLastUsedBy();
    object oMonster;
    object oDestPortal  =   GetLocalObject(OBJECT_SELF,"DESTPORTAL");
    int nMod, nDC, nRoll;
    effect eWard        =   EffectVisualEffect(VFX_IMP_DEATH_WARD);
    AssignCommand(oPC, JumpToObject(oDestPortal));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eWard,oDestPortal,10.0);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eWard,OBJECT_SELF,10.0);
    SendMessageToAllDMs(GetName(oPC) + " Ported to " + GetName(GetArea(oDestPortal)));
    WriteTimestampedLogEntry(GetName(oPC) + " Ported to " + GetName(GetArea(oDestPortal)));

    oMonster        =   GetFirstObjectInShape(SHAPE_SPHERE,60.0,GetLocation(OBJECT_SELF),TRUE,OBJECT_TYPE_CREATURE);
    while (oMonster!=OBJECT_INVALID)    {
        if(GetIsEnemy(oMonster,oPC))    {
            nMod=GetAbilityModifier(ABILITY_INTELLIGENCE,oMonster);
            nRoll=d20()+nMod;
            nDC=15;
            if ((nRoll >= nDC)&& (nRoll < nDC+10))   {
                SendMessageToAllDMs(GetName(oMonster) + " Ported to " + GetName(GetArea(oDestPortal)));
                WriteTimestampedLogEntry(GetName(oMonster) + " Ported to " + GetName(GetArea(oDestPortal)));
                ApplyEffectToObject(DURATION_TYPE_INSTANT,eWard,oDestPortal);
                AssignCommand(oMonster,JumpToObject(oDestPortal));
            }
        }
        oMonster=GetNextObjectInShape(SHAPE_SPHERE,60.0,GetLocation(OBJECT_SELF),TRUE,OBJECT_TYPE_CREATURE);
    }
}
