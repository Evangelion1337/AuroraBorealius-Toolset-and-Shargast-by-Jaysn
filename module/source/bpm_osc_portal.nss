//::///////////////////////////////////////////////
//:: Gatestones 1.6
//:: bpm_osc_portal
//:: Copyright (c) 2006 CarfaxAbbey.net
//:://////////////////////////////////////////////
/*
    To be placed in the OnSpellCastAt Script of the portals.
*/
//:://////////////////////////////////////////////
//:: Created By: Diavlen <diavlen@carfaxabbey.net>
//:: Created On: 3/24/2004
//:: Updated on: 8/11/2006
//:://////////////////////////////////////////////

void main() {
    object oPortalA =   OBJECT_SELF;
    object oPortalB =   GetLocalObject(oPortalA,"DESTPORTAL");
    object oPC      =   GetLastSpellCaster();
    effect eDispel  =   EffectVisualEffect(VFX_IMP_DISPEL_DISJUNCTION);
    int nSpell      =   GetLastSpell();
    int nSpellDC;

    if ((nSpell==SPELL_LESSER_DISPEL)||(nSpell==SPELL_DISPEL_MAGIC)||(nSpell==SPELL_GREATER_DISPELLING)||(nSpell==SPELL_MORDENKAINENS_DISJUNCTION)) {
        switch (nSpell) {
            case SPELL_LESSER_DISPEL:
                nSpellDC=25;
                break;

            case SPELL_DISPEL_MAGIC:
                nSpellDC=20;
                break;

            case SPELL_GREATER_DISPELLING:
                nSpellDC=15;
                break;

            case SPELL_MORDENKAINENS_DISJUNCTION:
                nSpellDC=10;
                break;
        }
        if (FortitudeSave(oPortalA,nSpellDC)==0)    {
            ApplyEffectToObject(DURATION_TYPE_INSTANT,eDispel,oPortalB);
            ApplyEffectToObject(DURATION_TYPE_INSTANT,eDispel,oPortalA);
            AssignCommand(oPortalB,DestroyObject(oPortalB,0.5));
            AssignCommand(oPortalA,DestroyObject(OBJECT_SELF,0.5));
        }
    } else {
        effect eVis     =       EffectVisualEffect(VFX_DUR_GLOBE_INVULNERABILITY);
        effect eDamage  =       EffectDamage( d20(),DAMAGE_TYPE_ELECTRICAL,DAMAGE_POWER_ENERGY);
        effect eBeam    =       EffectBeam(VFX_BEAM_LIGHTNING,oPortalA,BODY_NODE_CHEST);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eVis,oPortalA,10.0);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eBeam,oPC,3.0);
        ApplyEffectToObject(DURATION_TYPE_INSTANT,eDamage,oPC);
        AssignCommand(OBJECT_SELF,ActionCastSpellAtObject(nSpell,oPC,METAMAGIC_QUICKEN,TRUE,0,PROJECTILE_PATH_TYPE_DEFAULT,TRUE));
    }
}
