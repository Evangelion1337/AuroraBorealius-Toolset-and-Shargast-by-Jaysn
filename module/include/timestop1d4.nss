//::///////////////////////////////////////////////
//:: Time Stop
//:: NW_S0_TimeStop.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All persons in the Area are frozen in time
    except the caster.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////

/*This is a modified version of kaltors PW friendly time stop script
It has been modified to do several new functions

--It not will not dominate summoned units, to prevent them from becomine masterless
--It follows standard 9.0 second timestop with a .75 delay
--It applies a small visual affect to all units to show a timestop in effect
--It applies a knockdown effect to summoned units to prevent them doing anything(no summoned unit has
  immune to knockdown to my knowledge
--it applies a Immobilize effect to prevent units from moving (an occasional bug with big PW's on high CPU load).
*/

void main()
{
    object oArea = GetArea(OBJECT_SELF);
    location lLocation = GetLocation(OBJECT_SELF);
    object oTG = GetFirstObjectInArea(oArea);

    while (oTG != OBJECT_INVALID)
    {
        if(GetObjectType(oTG) == OBJECT_TYPE_CREATURE && oTG != OBJECT_SELF && !GetIsDM(oTG)){
            if(!GetIsObjectValid(GetMaster(oTG))){
                DelayCommand(0.75f, AssignCommand(GetModule(),ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectCutsceneDominated(), oTG, 9.0f)));
            }
            else{
                DelayCommand(0.75f, AssignCommand(GetModule(),ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectKnockdown(), oTG, 9.0f)));
            }
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_BLUR), oTG, 9.75f);
            DelayCommand(0.75f, AssignCommand(GetModule(),ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectCutsceneImmobilize(), oTG, 9.75f)));
        }
        oTG = GetNextObjectInArea(oArea);
    }
    SignalEvent(OBJECT_SELF, EventSpellCastAt(OBJECT_SELF, SPELL_TIME_STOP, FALSE));

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_TIME_STOP), lLocation);
}
