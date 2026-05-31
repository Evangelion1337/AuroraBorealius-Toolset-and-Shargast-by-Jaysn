///////////////////////////////////////////////////
// Beholder Ray: Include file                    //
///////////////////////////////////////////////////
/*
    These are the functions the beholder uses to
    act in it's most evil way... hehe
*/
///////////////////////////////////////////////////
// Created By: Zarathustra217                    //
// Created On: Jan 28. 2003                       //
///////////////////////////////////////////////////
#include "prc_inc_spells"
#include "prc_inc_sp_tch"

// object OBJECT_SELF = OBJECT_SELF;  <- Just here for testing

float ConvAngle(float fAngle)
{
    while(fAngle<0.0)
    {
        fAngle=fAngle+360.0;
    }
    while(fAngle>=360.0)
    {
        fAngle=fAngle-360.0;
    }
    return fAngle;
}
int GetLevel(object oTarget)
{
    int nTemp=1;
    int nLevel=0;
    while(nTemp<9)
    {
        int nClass=GetClassByPosition(nTemp,oTarget);
        nLevel+=GetLevelByPosition(nTemp,oTarget);
        nTemp++;
    }
    return nLevel;
}
int ClassSpellLvl(object oTarget)
{
    int nTemp=1;
    int nSpellLvl=0;
    while(nTemp<9)
    {
        int nClass=GetClassByPosition(nTemp,oTarget);
        if(nClass==CLASS_TYPE_CLERIC||nClass==CLASS_TYPE_DRUID||nClass==CLASS_TYPE_SORCERER||nClass==CLASS_TYPE_WIZARD)
        {
             nSpellLvl+=GetLevelByPosition(nTemp,oTarget);
             nTemp++;
        }
        else
        {
             nTemp++;
        }
    }
    return nSpellLvl;
}
int GetSpellCasterLvl(object oTarget)
{
    if(ClassSpellLvl(oTarget)>0)
    {
        return ClassSpellLvl(oTarget);
    }
    else
    {
    return 0;
    }
}
//Angle relative to beholder calculater
float CalcAngle(object oTarget)
{
    float fBangle=GetFacing(OBJECT_SELF);
    vector vBpos=GetPosition(OBJECT_SELF);
    vector vTpos=GetPosition(oTarget);
    vector vAngelvector=Vector(vTpos.x-vBpos.x,vTpos.y-vBpos.y,0.0);
    float fAngle=fBangle-VectorToAngle(vAngelvector);
    return ConvAngle(fAngle);
}
int CalcArc(object oTarget)
{
    float fTangle=CalcAngle(oTarget);
    if(fTangle>=225.0&&fTangle<=315.0)
    {
        return 4;
    }
    else if(fTangle>=135.0&&fTangle<=225.0)
    {
        return 3;
    }
    else if(fTangle>=45.0&&fTangle<=135.0)
    {
        return 2;
    }
    else if(315.0<fTangle||fTangle<45.0)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}
//Ranged touch <-- Using the PRC's PRCDoRangedTouchAttack instead
/* int RangedTouch(object oTarget,int nBeam)
{
    //Debug String
    //AssignCommand(oTarget,SpeakString(GetName(OBJECT_SELF)+" attemps ranged touch on "+GetName(oTarget)));
    int nDef=10+GetAbilityModifier(ABILITY_DEXTERITY,oTarget);
    int nAtt=GetAbilityModifier(ABILITY_DEXTERITY,OBJECT_SELF)+GetLevelByPosition(1,OBJECT_SELF)+PRCGetCreatureSize(oTarget)-3;
    int nDice=20-Random(20);
    if(nDice==20)
    {
        //Debug String
        //AssignCommand(oTarget,SpeakString("Critical Hit!"+IntToString(nDice)));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectBeam(nBeam,OBJECT_SELF,BODY_NODE_CHEST),oTarget,0.50);
        return 2;
    }
    else if(nDice==1)
    {
        //Debug String
        //AssignCommand(oTarget,SpeakString("Miss!"+IntToString(nDice)));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectBeam(nBeam,OBJECT_SELF,BODY_NODE_CHEST,TRUE),oTarget,0.50);
        return 0;
    }
    else if(nDef<=nAtt+nDice)
    {
        //Debug String
        //AssignCommand(oTarget,SpeakString("Hit!"+IntToString(nDice)));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectBeam(nBeam,OBJECT_SELF,BODY_NODE_CHEST),oTarget,0.50);
        return 1;
    }
    else
    {
        //Debug String
        //AssignCommand(oTarget,SpeakString("Miss!"+IntToString(nDice)));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectBeam(nBeam,OBJECT_SELF,BODY_NODE_CHEST,TRUE),oTarget,0.50);
        return 0;
    }
}
 */

//Charm Person function... Some Leeched from nw_s0_charmper
void CharmPer(object oTarget)
{
//    SetLocalInt(OBJECT_SELF,"CharmPerUsed",1);
    if(PRCDoRangedTouchAttack(oTarget,VFX_BEAM_HOLY)!=0)
    {
        //Declare major variables
        effect eVis = EffectVisualEffect(VFX_IMP_CHARM);
        effect eCharm = EffectCharmed();
        effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
        effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
        //Link persistant effects
        effect eLink = EffectLinkEffects(eMind, eCharm);
        eLink = EffectLinkEffects(eLink, eDur);
        int nCasterLevel = GetLevelByPosition(1,OBJECT_SELF);
        int nDuration = 3 + nCasterLevel/3;
        int nRacial = MyPRCGetRacialType(oTarget);
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_CHARM_PERSON, FALSE));
        //Make SR Check
        if (!PRCDoResistSpell(OBJECT_SELF, oTarget))
        {
            //Verify that the Racial Type is humanoid
            if  ((nRacial == RACIAL_TYPE_DWARF) ||
                (nRacial == RACIAL_TYPE_ELF) ||
                (nRacial == RACIAL_TYPE_GNOME) ||
                (nRacial == RACIAL_TYPE_HUMANOID_GOBLINOID) ||
                (nRacial == RACIAL_TYPE_HALFLING) ||
                (nRacial == RACIAL_TYPE_HUMAN) ||
                (nRacial == RACIAL_TYPE_HALFELF) ||
                (nRacial == RACIAL_TYPE_HALFORC) ||
                (nRacial == RACIAL_TYPE_HUMANOID_MONSTROUS) ||
                (nRacial == RACIAL_TYPE_HUMANOID_ORC) ||
                (nRacial == RACIAL_TYPE_HUMANOID_REPTILIAN))
            {
                //Make a Will Save check
                if (WillSave(oTarget,18,SAVING_THROW_TYPE_MIND_SPELLS)==0)
                {
                    //Apply impact and linked effects
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                }
            }
         }
    }
}

//Charm Monster function... Some Leeched from nw_s0_charmper
void CharmMon(object oTarget)
{
//    SetLocalInt(OBJECT_SELF,"CharmMonUsed",1);
    if(PRCDoRangedTouchAttack(oTarget,VFX_BEAM_HOLY)!=0)
    {
        //Declare major variables
        effect eVis = EffectVisualEffect(VFX_IMP_CHARM);
        effect eCharm = EffectCharmed();
        effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
        effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
        //Link persistant effects
        effect eLink = EffectLinkEffects(eMind, eCharm);
        eLink = EffectLinkEffects(eLink, eDur);
        int nCasterLevel = GetLevelByPosition(1,OBJECT_SELF);
        int nDuration = 3 + nCasterLevel/3;
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_CHARM_PERSON, FALSE));
        //Make SR Check
        if (!PRCDoResistSpell(OBJECT_SELF, oTarget))
        {
            //Make a Will Save check
            if (WillSave(oTarget,18,SAVING_THROW_TYPE_MIND_SPELLS)==0)
            {
                //Apply impact and linked effects
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            }
         }
    }
}

//Sleep... Some Leeched from nw_s0_charmper and nw_s0_sleep
void Sleep(object oTarget)
{
//    SetLocalInt(OBJECT_SELF,"SleepUsed",1);
    if(PRCDoRangedTouchAttack(oTarget,VFX_BEAM_ODD)!=0)
    {
        //Declare major variables
        effect eImpact = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
        effect eSleep =  EffectSleep();
        effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
        effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
        effect eVis = EffectVisualEffect(VFX_IMP_SLEEP);
        effect eLink = EffectLinkEffects(eSleep, eMind);
        eLink = EffectLinkEffects(eLink, eDur);
        eLink = EffectLinkEffects(eLink, eVis);
        int nCasterLevel = GetLevelByPosition(1,OBJECT_SELF);
        int nDuration = 3 + nCasterLevel;
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_SLEEP));
        //Make SR Check
        if (!PRCDoResistSpell(OBJECT_SELF, oTarget))
        {
            //Make a Will Save check
            if (WillSave(oTarget,18,SAVING_THROW_TYPE_MIND_SPELLS)==0)
            {
                //Apply impact and linked effects
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
            }
         }
    }
}

//Flesh To Stone
void FleshToStone(object oTarget)
{
    if(PRCDoRangedTouchAttack(oTarget,VFX_BEAM_ODD)!=0)
    {
        //Declare major variables
        effect eImpact = EffectVisualEffect(VFX_FNF_IMPLOSION);
        effect eDur = EffectVisualEffect(VFX_DUR_PROT_STONESKIN);
        effect eEntangle =EffectEntangle();
        effect eParalyze=EffectParalyze();
        effect eLink = EffectLinkEffects(eImpact, eDur);
        eLink = EffectLinkEffects(eLink, eParalyze);
        eLink = EffectLinkEffects(eLink, eEntangle);
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_MAGIC_MISSILE));
        //Make SR Check
        if (!PRCDoResistSpell(OBJECT_SELF, oTarget))
        {
            //Make a Fortitude Save check
            if (FortitudeSave(oTarget,18)==0)
            {
                //Apply impact and linked effects
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
                SetIsTemporaryNeutral(oTarget,OBJECT_SELF,TRUE,600.0);
                SetIsTemporaryNeutral(OBJECT_SELF,oTarget,TRUE,600.0);
            }
        }
    }
}

void Disintegrate(object oTarget)
{
    if(PRCDoRangedTouchAttack(oTarget,VFX_BEAM_EVIL)!=0)
    {
        //Declare major variables
        effect eSmoke=EffectVisualEffect(VFX_FNF_SMOKE_PUFF);
        effect eDam=EffectDamage(d6(5),DAMAGE_TYPE_BLUDGEONING);
        effect eLink = EffectLinkEffects(eDam, eSmoke);
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_MAGIC_MISSILE));
        //Make SR Check
        if (!PRCDoResistSpell(OBJECT_SELF, oTarget))
        {
            //Make a Fortitude Save check
            int nFort=FortitudeSave(oTarget,18);
            if (nFort==0)
            {
                //Apply impact and linked effects
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eSmoke, GetLocation(oTarget),2.0);
                DestroyObject(oTarget);
            }
            else if(nFort==1)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oTarget);
            }
        }
    }
}

//Fear
void Fear(object oTarget)
{
    if(PRCDoRangedTouchAttack(oTarget,VFX_BEAM_HOLY)!=0)
    {
        //Declare major variables
        effect eImpact = EffectVisualEffect(VFX_IMP_FEAR_S);
        effect eDur = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
        effect eFear =EffectFrightened();
        effect eLink = EffectLinkEffects(eImpact, eDur);
        eLink = EffectLinkEffects(eLink, eFear);
        int nCasterLevel=GetLevelByPosition(1,OBJECT_SELF);
        int nDuration=nCasterLevel;
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_FEAR));
        //Make SR Check
        if (!PRCDoResistSpell(OBJECT_SELF, oTarget))
        {
            //Make a Will Save check
            if (WillSave(oTarget,18,SAVING_THROW_TYPE_MIND_SPELLS)==0)
            {
                //Apply impact and linked effects
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget,RoundsToSeconds(nDuration));
                AssignCommand(oTarget,ClearAllActions());
                AssignCommand(oTarget,ActionMoveAwayFromObject(OBJECT_SELF,TRUE,50.0));
            }
        }
    }
}
//Slow
void Slow(object oTarget)
{
    if(PRCDoRangedTouchAttack(oTarget,VFX_BEAM_HOLY)!=0)
    {
        //Declare major variables
        effect eImpact = EffectVisualEffect(VFX_IMP_SLOW);
        effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
        effect eSlow =EffectSlow();
        effect eLink = EffectLinkEffects(eImpact, eDur);
        eLink = EffectLinkEffects(eLink, eSlow);
        int nCasterLevel=PRCGetCasterLevel(OBJECT_SELF);
        int nDuration=nCasterLevel;
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_SLOW));
        //Make SR Check
        if (!PRCDoResistSpell(OBJECT_SELF, oTarget))
        {
            //Make a Will Save check
            if (WillSave(oTarget,18)==0)
            {
                //Apply impact and linked effects
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget,RoundsToSeconds(nDuration));
            }
        }
    }
}

//Inflict moderate wounds
void InflictModerateWounds(object oTarget)
{
    //if(RangedTouch(oTarget,VFX_BEAM_FIRE)!=0)
	if(PRCDoRangedTouchAttack(oTarget,VFX_BEAM_FIRE)!=0)
    {
        //Declare major variables
        effect eNeg=EffectVisualEffect(VFX_COM_HIT_NEGATIVE);
        effect eDam=EffectDamage(d8(2)+10,DAMAGE_TYPE_MAGICAL);
        effect eDam2=EffectDamage((d8(2)+10)/2,DAMAGE_TYPE_MAGICAL);
        effect eLink = EffectLinkEffects(eDam, eNeg);
        effect eLink2 = EffectLinkEffects(eDam2, eNeg);
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_MAGIC_MISSILE));
        //Make SR Check
        if (!ResistSpell(OBJECT_SELF, oTarget))
        {
            //Make a Will Save check
            int nWill=WillSave(oTarget,18);
            if (nWill==0)
            {
                //Apply impact and linked effects
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oTarget);
            }
            else if(nWill==1)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink2, oTarget);
            }
        }
    }
}

//Finger of death
void FingerOfDeath(object oTarget)
{
    if(PRCDoRangedTouchAttack(oTarget,VFX_BEAM_COLD)!=0)
    {
        //Declare major variables
        effect eNeg=EffectVisualEffect(VFX_COM_HIT_NEGATIVE);
        effect eDeath=EffectDeath(TRUE);
        effect eDam=EffectDamage(d6(3)+13,DAMAGE_TYPE_MAGICAL);
        effect eLink = EffectLinkEffects(eDeath, eNeg);
        effect eLink2 = EffectLinkEffects(eDam, eNeg);
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_FINGER_OF_DEATH));
        //Make SR Check
        if (!ResistSpell(OBJECT_SELF, oTarget))
        {
            //Make a Fortitude Save check
            int nFort=FortitudeSave(oTarget,18);
            if (nFort==0)
            {
                //Apply impact and linked effects
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oTarget);
            }
            else if(nFort==1)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink2, oTarget);
            }
        }
    }
}

//Telekinesis
void Telekinesis(object oTarget)
{
//    SetLocalInt(OBJECT_SELF,"TelekinesisUsed",1);
    if(PRCDoRangedTouchAttack(oTarget,VFX_BEAM_ODD)!=0)
    {
        //Declare major variables
        effect eVFX=EffectVisualEffect(VFX_FNF_SCREEN_BUMP);
        effect eFall=EffectKnockdown();
        effect eParalyze=EffectParalyze();
        effect eDam=EffectDamage(d4(2),DAMAGE_TYPE_BLUDGEONING);
        effect eLink = EffectLinkEffects(eVFX, eDam);
        eLink=EffectLinkEffects(eLink, eParalyze);
        eLink=EffectLinkEffects(eLink, eFall);
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_MAGIC_MISSILE));
        //Make SR Check
        if (!ResistSpell(OBJECT_SELF, oTarget))
        {
            //Make a Will Save check
            if (WillSave(oTarget,18)==0)
            {
                //Apply impact and linked effects
                AssignCommand(oTarget,ClearAllActions());
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget,5.0);
            }
        }
    }
}

void CentalEyeRay(object oTarget)
{
    if(CalcArc(oTarget)==1)
    {
        //Declares the silence effect. Some leeched from the silence AOE script.
        effect eDur=EffectVisualEffect(VFX_IMP_SILENCE);
        effect eDispel=EffectVisualEffect(VFX_IMP_DISPEL);
        effect eSilence=EffectSilence();
        effect eLink=EffectLinkEffects(eDur, eSilence);
        //Removes all temporary effects from target.
        effect eTemp=GetFirstEffect(oTarget);
        while(GetIsEffectValid(eTemp))
        {
            if(GetEffectDurationType(eTemp)==DURATION_TYPE_TEMPORARY||GetEffectSubType(eTemp)==(SUBTYPE_MAGICAL||SUBTYPE_SUPERNATURAL))
            {
                //Debug String
                //AssignCommand(oTarget, SpeakString("Removing effects"));
                RemoveEffect(oTarget,eTemp);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDispel, oTarget);
            }
            eTemp=GetNextEffect(oTarget);
        }
        //Applies the effects
        if(!GetIsFriend(oTarget,OBJECT_SELF))
        {
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_SILENCE));
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
        }
        else
        {
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_SILENCE, FALSE));
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
        }
    }
    else
    {
        int bValid = FALSE;
        effect eAOE;
        eAOE = GetFirstEffect(oTarget);
        while (GetIsEffectValid(eAOE))
        {
            //Debug String
            //AssignCommand(oTarget, SpeakString("Effect is valid"));
            if (GetEffectCreator(eAOE) == GetAreaOfEffectCreator())
            {
                //Debug String
                //AssignCommand(oTarget, SpeakString("Effect creator is true"));
                if(GetEffectType(eAOE) == EFFECT_TYPE_SILENCE)
                {
                    //Debug String
                    //AssignCommand(oTarget, SpeakString("Effect type is silence"));
                    //AssignCommand(oTarget, SpeakString("Removing effects"));
                    RemoveEffect(oTarget, eAOE);
                }
            }
            eAOE = GetNextEffect(oTarget);
        }
    }
}

void AssignBestAction()
{
    //Get threat of near enemies.
    object oNearestE=GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,OBJECT_SELF,1,CREATURE_TYPE_IS_ALIVE,TRUE);
    object oTemp=oNearestE;
    object oFacing=GetLocalObject(OBJECT_SELF,"Facing");
    int nCount=1;
    int nCloseEnemy=0;
    float fPrefDist=10.0;
    while(GetDistanceBetween(OBJECT_SELF,oTemp)<fPrefDist&&oTemp!=OBJECT_INVALID)
    {
        nCloseEnemy+=(GetLevel(oTemp)-GetSpellCasterLvl(oTemp));
        nCount++;
        oTemp=GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,OBJECT_SELF,nCount,CREATURE_TYPE_IS_ALIVE,TRUE);
    }
    //Assign what to do.
    if(nCloseEnemy<GetLevel(OBJECT_SELF))
    {
        if(GetLocalInt(OBJECT_SELF,"EyeOpen"))
        {
            if(GetDistanceBetween(OBJECT_SELF,oFacing)>3.0)
            {
                //Debug String
                //AssignCommand(OBJECT_SELF,SpeakString("This position is good!"));
                //ID:1
                if(GetLocalInt(OBJECT_SELF,"CurrentAction")!=1)
                {
                    SetLocalInt(OBJECT_SELF,"CurrentAction",1);
                    AssignCommand(OBJECT_SELF,ClearAllActions());
                    AssignCommand(OBJECT_SELF,SetFacingPoint(GetPosition(oFacing)));
                    AssignCommand(OBJECT_SELF,ActionAttack(oFacing,TRUE));
                }
                else
                {
                    AssignCommand(OBJECT_SELF,ActionAttack(oFacing,TRUE));
                }
            }
            else
            {
                //Debug String
                //AssignCommand(OBJECT_SELF,SpeakString("This position is ok!"));
                //ID:2
                if(GetLocalInt(OBJECT_SELF,"CurrentAction")!=2)
                {
                    SetLocalInt(OBJECT_SELF,"CurrentAction",2);
                    AssignCommand(OBJECT_SELF,ClearAllActions());
                    AssignCommand(OBJECT_SELF,ActionAttack(oFacing,FALSE));
                }
                else
                {
                    AssignCommand(OBJECT_SELF,ActionAttack(oFacing,FALSE));
                }
            }
            //AssignCommand(OBJECT_SELF,ActionAttack(oFacing,TRUE));
        }
        else
        {
            //Debug String
            //AssignCommand(OBJECT_SELF,SpeakString("I'll just eat you!"));
            //ID:3
            if(GetLocalInt(OBJECT_SELF,"CurrentAction")!=3)
            {
                SetLocalInt(OBJECT_SELF,"CurrentAction",3);
                AssignCommand(OBJECT_SELF,ClearAllActions());
                AssignCommand(OBJECT_SELF,ActionAttack(oNearestE,FALSE));
            }
            else
            {
                AssignCommand(OBJECT_SELF,ActionAttack(oNearestE,FALSE));
            }
        }
    }
    else
    {
        //Debug String
        //AssignCommand(OBJECT_SELF,SpeakString("This position is bad!"));
        //ID:4
        if(GetLocalInt(OBJECT_SELF,"CurrentAction")!=4||GetCurrentAction(OBJECT_SELF)!=ACTION_MOVETOPOINT)
        {
            SetLocalInt(OBJECT_SELF,"CurrentAction",4);
            AssignCommand(OBJECT_SELF,ClearAllActions());
            if(GetDistanceBetween(OBJECT_SELF,oFacing)>fPrefDist)
            {
                AssignCommand(OBJECT_SELF,ActionAttack(oFacing,FALSE));
            }
            else
            {
                AssignCommand(OBJECT_SELF,ActionMoveAwayFromObject(oNearestE,TRUE,1.5*fPrefDist));
            }
        }
        else
        {
            if(GetDistanceBetween(OBJECT_SELF,oFacing)>fPrefDist)
            {
                AssignCommand(OBJECT_SELF,ActionAttack(oFacing,FALSE));
            }
            else
            {
                AssignCommand(OBJECT_SELF,ActionMoveAwayFromObject(oNearestE,TRUE,1.5*fPrefDist));
            }
        }
    }
}

//:: void main (){}