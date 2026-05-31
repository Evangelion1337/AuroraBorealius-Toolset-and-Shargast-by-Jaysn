///////////////////////////////////////////////////
// Beholder Ray: On enter                        //
///////////////////////////////////////////////////
/*
    The beholder has a frontal arc, which dispels all magic.
    In addition each smaller eye also have functions,
    and luckly these have the same range as the frontal arc.
*/
///////////////////////////////////////////////////
// Created By: Zarathustra217                    //
// Created On: Okt 7. 2002                       //
///////////////////////////////////////////////////
#include "z217_behold"
void main()
{
    object oTarget=GetEnteringObject();
    object oBeholder=GetAreaOfEffectCreator();
    if(oTarget!=oBeholder&&(GetIsInCombat(oBeholder)||(GetIsEnemy(oTarget,oBeholder)&&GetObjectSeen(oTarget,oBeholder))))
    {
        if(GetLocalInt(oBeholder,"ArcTargetsDone")==0)
        {
            //Area Array
            int nCreatureCount=0;
            int nCreatureCountE=0;
            int nCreatureCountESC=0;
            int nCreatureCountF=0;
            int nCreatureCountFSC=0;
            object oTemp=GetFirstInPersistentObject();
            while(oTemp!=OBJECT_INVALID)
            {
                if(oTemp!=oBeholder)
                {
                    nCreatureCount++;
                    SetLocalObject(OBJECT_SELF,"AreaArray"+IntToString(nCreatureCount),oTemp);
                    if(GetIsEnemy(oTemp,oBeholder))
                    {
                        nCreatureCountE++;
                        SetLocalObject(OBJECT_SELF,"AreaArrayE"+IntToString(nCreatureCountE),oTemp);
                        if(GetSpellCasterLvl(oTemp)>0)
                        {
                            nCreatureCountESC++;
                            SetLocalObject(OBJECT_SELF,"AreaArrayESC"+IntToString(nCreatureCountESC),oTemp);
                        }
                    }
                    else if(GetIsFriend(oTemp,oBeholder))
                    {
                        nCreatureCountF++;
                        SetLocalObject(OBJECT_SELF,"AreaArrayF"+IntToString(nCreatureCountF),oTemp);
                        if(GetSpellCasterLvl(oTemp)>0)
                        {
                            nCreatureCountFSC++;
                            SetLocalObject(OBJECT_SELF,"AreaArrayFSC"+IntToString(nCreatureCountFSC),oTemp);
                        }
                    }
                    //Debug String
                    //AssignCommand(oBeholder,SpeakString(GetName(oTemp)+" is in array."));
                    //AssignCommand(oBeholder,SpeakString(GetName(oTemp)+"'s spellcasterlevel is "+IntToString(GetSpellCasterLvl(oTemp))));
                }
                oTemp=GetNextInPersistentObject();
            }
            //Debug String
            //AssignCommand(oBeholder,SpeakString(GetName(oBeholder)+"'s Area Array done."));
            //Calculate best facing of Beholder
            int nCount=1;
            int nMaxPriority=0;
            int nPriority=0;
            int nESCInArc=0;
            int nBestESCInArc=0;
            object oFacing=oTarget;
            oTemp=GetLocalObject(OBJECT_SELF,"AreaArrayESC"+IntToString(nCount));
            while(oTemp!=OBJECT_INVALID)
            {
                //Debug String
                //AssignCommand(oBeholder,SpeakString("Checks to see if "+GetName(oTemp)+" is a good creature to face."));
                int nCount2=1;
                object oTemp2=GetLocalObject(OBJECT_SELF,"AreaArrayESC"+IntToString(nCount2));
                while(oTemp2!=OBJECT_INVALID)
                {
                    float fAngle=ConvAngle(CalcAngle(oTemp2)-CalcAngle(oTemp));
                    if(fAngle<45.0||fAngle>315.0)
                    {
                        nPriority+=GetSpellCasterLvl(oTemp2);
                        nESCInArc++;
                    }
                    nCount2++;
                    oTemp2=GetLocalObject(OBJECT_SELF,"AreaArrayESC"+IntToString(nCount2));
                }
                nCount2=1;
                oTemp2=GetLocalObject(OBJECT_SELF,"AreaArrayFSC"+IntToString(nCount2));
                while(oTemp2!=OBJECT_INVALID)
                {
                    float fAngle=ConvAngle(CalcAngle(oTemp2)-CalcAngle(oTemp));
                    if(fAngle<45.0||fAngle>315.0)
                    {
                        nPriority-=GetSpellCasterLvl(oTemp2);
                    }
                    nCount2++;
                    oTemp2=GetLocalObject(OBJECT_SELF,"AreaArrayFSC"+IntToString(nCount2));
                }
                //Debug String
                //AssignCommand(oBeholder,SpeakString(GetName(oTemp)+"'s Priority is "+IntToString(nPriority)+"."));

                if(nPriority>nMaxPriority)
                {
                    oFacing=oTemp;
                    nMaxPriority=nPriority;
                    nBestESCInArc=nESCInArc;
                }
                nCount++;
                oTemp=GetLocalObject(OBJECT_SELF,"AreaArrayESC"+IntToString(nCount));
            }
            if(nMaxPriority>0)
            {
                SetLocalInt(OBJECT_SELF,"EyeOpen",1);
            }
            SetLocalInt(OBJECT_SELF,"SpellCastersInFacingArc",nBestESCInArc);
            SetLocalObject(OBJECT_SELF,"Facing",oFacing);
            AssignCommand(oBeholder,ClearAllActions());
            AssignCommand(oBeholder,SetFacingPoint(GetPosition(oFacing)));
            if(GetIsEnemy(oFacing,oBeholder))
            {
                if(nBestESCInArc>1&&GetDistanceBetween(oBeholder,oFacing)>5.0&&GetLocalInt(OBJECT_SELF,"EyeOpen"))
                {
                    AssignCommand(oBeholder,ActionAttack(oFacing,TRUE));
                }
                else
                {
                    AssignCommand(oBeholder,ActionAttack(oFacing,FALSE));
                }
            }
            //Calculate arc targets
            nCount=1;
            oTemp=GetLocalObject(OBJECT_SELF,"AreaArrayE"+IntToString(nCount));
            while (oTemp!=OBJECT_INVALID)
            {
                int nArc=CalcArc(oTemp);
                SetLocalInt(OBJECT_SELF,"ArcTargets"+IntToString(nArc),nCount);
                nCount++;
                oTemp=GetLocalObject(OBJECT_SELF,"AreaArrayE"+IntToString(nCount));
            }
            if(GetLocalInt(OBJECT_SELF,"EyeOpen"))
            {
                AssignCommand(oBeholder,SpeakString(GetName(oBeholder)+" uses it's central eye ray this round."));
            }
            else
            {
                AssignCommand(oBeholder,SpeakString(GetName(oBeholder)+" doesn't use it's central eye ray this round."));
            }
            SetLocalInt(oBeholder,"ArcTargetsDone",1);
        }
        //Rays
        if(CalcArc(oTarget)==3&&GetIsEnemy(oTarget,oBeholder))
        {
            int nArcTargets=GetLocalInt(OBJECT_SELF,"ArcTargets3");
            int nRaysToBeUsed=4;
            int nRaysLeft=4-GetLocalInt(OBJECT_SELF,"CharmPerUsed")-GetLocalInt(OBJECT_SELF,"CharmMonUsed")-GetLocalInt(OBJECT_SELF,"InflictModerateWoundsUsed")-GetLocalInt(OBJECT_SELF,"FleshToStoneUsed");
            if(nArcTargets==2||nArcTargets==3)
            {
                nRaysToBeUsed=2;
            }
            else if(nArcTargets>3)
            {
                nRaysToBeUsed=1;
            }
            if(nRaysToBeUsed>nRaysLeft)
            {
                nRaysToBeUsed=nRaysLeft;
            }
            int nRandom=d4();
            int nDebug=0;
            while(nRaysToBeUsed>0&&nDebug<4)
            {
                if(nRandom>4)
                {
                    nRandom=1;
                }
                if(nRandom==4)
                {
                    if(!GetLocalInt(OBJECT_SELF,"CharmPerUsed"))
                    {
                        SetLocalInt(OBJECT_SELF,"CharmPerUsed",1);
                        float fCurrentDelay=GetLocalFloat(OBJECT_SELF,"RayDelay");
                        DelayCommand(fCurrentDelay,CharmPer(oTarget));
                        nRaysToBeUsed--;
                        nRandom++;
                        fCurrentDelay=fCurrentDelay+0.2;
                        SetLocalFloat(OBJECT_SELF,"RayDelay",fCurrentDelay);
                    }
                }
                else if(nRandom==3)
                {
                    if(!GetLocalInt(OBJECT_SELF,"CharmMonUsed"))
                    {
                        SetLocalInt(OBJECT_SELF,"CharmMonUsed",1);
                        float fCurrentDelay=GetLocalFloat(OBJECT_SELF,"RayDelay");
                        DelayCommand(fCurrentDelay,CharmMon(oTarget));
                        nRaysToBeUsed--;
                        nRandom++;
                        fCurrentDelay=fCurrentDelay+0.2;
                        SetLocalFloat(OBJECT_SELF,"RayDelay",fCurrentDelay);
                    }
                }
                else if(nRandom==2)
                {
                    if(!GetLocalInt(OBJECT_SELF,"InflictModerateWoundsUsed"))
                    {
                        SetLocalInt(OBJECT_SELF,"InflictModerateWoundsUsed",1);
                        float fCurrentDelay=GetLocalFloat(OBJECT_SELF,"RayDelay");
                        DelayCommand(fCurrentDelay,InflictModerateWounds(oTarget));
                        nRaysToBeUsed--;
                        nRandom++;
                        fCurrentDelay=fCurrentDelay+0.2;
                        SetLocalFloat(OBJECT_SELF,"RayDelay",fCurrentDelay);
                    }
                }
                else if(nRandom==1)
                {
                    if(!GetLocalInt(OBJECT_SELF,"FleshToStoneUsed"))
                    {
                        SetLocalInt(OBJECT_SELF,"FleshToStoneUsed",1);
                        float fCurrentDelay=GetLocalFloat(OBJECT_SELF,"RayDelay");
                        DelayCommand(fCurrentDelay,FleshToStone(oTarget));
                        nRaysToBeUsed--;
                        nRandom++;
                        fCurrentDelay=fCurrentDelay+0.2;
                        SetLocalFloat(OBJECT_SELF,"RayDelay",fCurrentDelay);
                    }
                }
                nDebug++;
            }
        }
        else if(CalcArc(oTarget)==4&&GetIsEnemy(oTarget,oBeholder))
        {
            int nArcTargets=GetLocalInt(OBJECT_SELF,"ArcTargets4");
            int nRaysToBeUsed=3;
            int nRaysLeft=3-GetLocalInt(OBJECT_SELF,"FingerOfDeathUsed")-GetLocalInt(OBJECT_SELF,"FearUsed")-GetLocalInt(OBJECT_SELF,"InflictModerateWoundsUsed");
            if(nArcTargets==2)
            {
                nRaysToBeUsed=2;
            }
            else if(nArcTargets>2)
            {
                nRaysToBeUsed=1;
            }
            if(nRaysToBeUsed>nRaysLeft)
            {
                nRaysToBeUsed=nRaysLeft;
            }
            int nRandom=d3();
            int nDebug=0;
            while(nRaysToBeUsed>0&&nDebug<3)
            {
                if(nRandom>3)
                {
                    nRandom=1;
                }
                if(nRandom==3)
                {
                    if(!GetLocalInt(OBJECT_SELF,"FingerOfDeathUsed"))
                    {
                        SetLocalInt(OBJECT_SELF,"FingerOfDeathUsed",1);
                        float fCurrentDelay=GetLocalFloat(OBJECT_SELF,"RayDelay");
                        DelayCommand(fCurrentDelay,FingerOfDeath(oTarget));
                        nRaysToBeUsed--;
                        nRandom++;
                        fCurrentDelay=fCurrentDelay+0.2;
                        SetLocalFloat(OBJECT_SELF,"RayDelay",fCurrentDelay);
                    }
                }
                else if(nRandom==2)
                {
                    if(!GetLocalInt(OBJECT_SELF,"InflictModerateWoundsUsed"))
                    {
                        SetLocalInt(OBJECT_SELF,"InflictModerateWoundsUsed",1);
                        float fCurrentDelay=GetLocalFloat(OBJECT_SELF,"RayDelay");
                        DelayCommand(fCurrentDelay,InflictModerateWounds(oTarget));
                        nRaysToBeUsed--;
                        nRandom++;
                        fCurrentDelay=fCurrentDelay+0.2;
                        SetLocalFloat(OBJECT_SELF,"RayDelay",fCurrentDelay);
                    }
                }
                else if(nRandom==1)
                {
                    if(!GetLocalInt(OBJECT_SELF,"FearUsed"))
                    {
                        SetLocalInt(OBJECT_SELF,"FearUsed",1);
                        float fCurrentDelay=GetLocalFloat(OBJECT_SELF,"RayDelay");
                        DelayCommand(fCurrentDelay,Fear(oTarget));
                        nRaysToBeUsed--;
                        nRandom++;
                        fCurrentDelay=fCurrentDelay+0.2;
                        SetLocalFloat(OBJECT_SELF,"RayDelay",fCurrentDelay);
                    }
                }
                nDebug++;
            }
        }
        else if(CalcArc(oTarget)==2&&GetIsEnemy(oTarget,oBeholder))
        {
            int nArcTargets=GetLocalInt(OBJECT_SELF,"ArcTargets2");
            int nRaysToBeUsed=3;
            int nRaysLeft=3-GetLocalInt(OBJECT_SELF,"FleshToStoneUsed")-GetLocalInt(OBJECT_SELF,"TelekinesisUsed")-GetLocalInt(OBJECT_SELF,"DisintegrateUsed");
            if(nArcTargets==2)
            {
                nRaysToBeUsed=2;
            }
            else if(nArcTargets>2)
            {
                nRaysToBeUsed=1;
            }
            if(nRaysToBeUsed>nRaysLeft)
            {
                nRaysToBeUsed=nRaysLeft;
            }
            int nRandom=d3();
            int nDebug=0;
            while(nRaysToBeUsed>0&&nDebug<3)
            {
                if(nRandom>3)
                {
                    nRandom=1;
                }
                if(nRandom==3)
                {
                    if(!GetLocalInt(OBJECT_SELF,"FleshToStoneUsed"))
                    {
                        SetLocalInt(OBJECT_SELF,"FleshToStoneUsed",1);
                        float fCurrentDelay=GetLocalFloat(OBJECT_SELF,"RayDelay");
                        DelayCommand(fCurrentDelay,FleshToStone(oTarget));
                        nRaysToBeUsed--;
                        nRandom++;
                        fCurrentDelay=fCurrentDelay+0.2;
                        SetLocalFloat(OBJECT_SELF,"RayDelay",fCurrentDelay);
                    }
                }
                else if(nRandom==2)
                {
                    if(!GetLocalInt(OBJECT_SELF,"TelekinesisUsed"))
                    {
                        SetLocalInt(OBJECT_SELF,"TelekinesisUsed",1);
                        float fCurrentDelay=GetLocalFloat(OBJECT_SELF,"RayDelay");
                        DelayCommand(fCurrentDelay,Telekinesis(oTarget));
                        nRaysToBeUsed--;
                        nRandom++;
                        fCurrentDelay=fCurrentDelay+0.2;
                        SetLocalFloat(OBJECT_SELF,"RayDelay",fCurrentDelay);
                    }
                }
                else if(nRandom==1)
                {
                    if(!GetLocalInt(OBJECT_SELF,"DisintegrateUsed"))
                    {
                        SetLocalInt(OBJECT_SELF,"DisintegrateUsed",1);
                        float fCurrentDelay=GetLocalFloat(OBJECT_SELF,"RayDelay");
                        DelayCommand(fCurrentDelay,Disintegrate(oTarget));
                        nRaysToBeUsed--;
                        nRandom++;
                        fCurrentDelay=fCurrentDelay+0.2;
                        SetLocalFloat(OBJECT_SELF,"RayDelay",fCurrentDelay);
                    }
                }
                nDebug++;
            }
        }
        else if(CalcArc(oTarget)==1&&!GetLocalInt(OBJECT_SELF,"EyeOpen")&&GetIsEnemy(oTarget,oBeholder))
        {
            int nArcTargets=GetLocalInt(OBJECT_SELF,"ArcTargets1");
            int nRaysToBeUsed=4;
            int nRaysLeft=4-GetLocalInt(OBJECT_SELF,"DisintegrateUsed")-GetLocalInt(OBJECT_SELF,"FigerOfDeathUsed")-GetLocalInt(OBJECT_SELF,"SleepUsed")-GetLocalInt(OBJECT_SELF,"SlowUsed");
            if(nArcTargets==2||nArcTargets==3)
            {
                nRaysToBeUsed=2;
            }
            else if(nArcTargets>3)
            {
                nRaysToBeUsed=1;
            }
            if(nRaysToBeUsed>nRaysLeft)
            {
                nRaysToBeUsed=nRaysLeft;
            }
            int nRandom=d4();
            int nDebug=0;
            while(nRaysToBeUsed>0&&nDebug<4)
            {
                if(nRandom>4)
                {
                    nRandom=1;
                }
                if(nRandom==4)
                {
                    if(!GetLocalInt(OBJECT_SELF,"DisintegrateUsed"))
                    {
                        SetLocalInt(OBJECT_SELF,"DisintegrateUsed",1);
                        float fCurrentDelay=GetLocalFloat(OBJECT_SELF,"RayDelay");
                        DelayCommand(fCurrentDelay,Disintegrate(oTarget));
                        nRaysToBeUsed--;
                        nRandom++;
                        fCurrentDelay=fCurrentDelay+0.2;
                        SetLocalFloat(OBJECT_SELF,"RayDelay",fCurrentDelay);
                    }
                }
                else if(nRandom==3)
                {
                    if(!GetLocalInt(OBJECT_SELF,"FingerOfDeathUsed"))
                    {
                        SetLocalInt(OBJECT_SELF,"FingerOfDeathUsed",1);
                        float fCurrentDelay=GetLocalFloat(OBJECT_SELF,"RayDelay");
                        DelayCommand(fCurrentDelay,FingerOfDeath(oTarget));
                        nRaysToBeUsed--;
                        nRandom++;
                        fCurrentDelay=fCurrentDelay+0.2;
                        SetLocalFloat(OBJECT_SELF,"RayDelay",fCurrentDelay);
                    }
                }
                else if(nRandom==2)
                {
                    if(!GetLocalInt(OBJECT_SELF,"SleepUsed"))
                    {
                        SetLocalInt(OBJECT_SELF,"SleepUsed",1);
                        float fCurrentDelay=GetLocalFloat(OBJECT_SELF,"RayDelay");
                        DelayCommand(fCurrentDelay,Sleep(oTarget));
                        nRaysToBeUsed--;
                        nRandom++;
                        fCurrentDelay=fCurrentDelay+0.2;
                        SetLocalFloat(OBJECT_SELF,"RayDelay",fCurrentDelay);
                    }
                }
                else if(nRandom==1)
                {
                    if(!GetLocalInt(OBJECT_SELF,"SlowUsed"))
                    {
                        SetLocalInt(OBJECT_SELF,"SlowUsed",1);
                        float fCurrentDelay=GetLocalFloat(OBJECT_SELF,"RayDelay");
                        DelayCommand(fCurrentDelay,Slow(oTarget));
                        nRaysToBeUsed--;
                        nRandom++;
                        fCurrentDelay=fCurrentDelay+0.2;
                        SetLocalFloat(OBJECT_SELF,"RayDelay",fCurrentDelay);
                    }
                }
                nDebug++;
            }
        }
        //Central eye ray
        if(GetLocalInt(OBJECT_SELF,"EyeOpen"))
        {
            CentalEyeRay(oTarget);
            DelayCommand(0.5,CentalEyeRay(oTarget));
            DelayCommand(1.0,CentalEyeRay(oTarget));
            DelayCommand(1.5,CentalEyeRay(oTarget));
            DelayCommand(2.0,CentalEyeRay(oTarget));
            DelayCommand(2.5,CentalEyeRay(oTarget));
            DelayCommand(3.0,CentalEyeRay(oTarget));
            DelayCommand(3.5,CentalEyeRay(oTarget));
            DelayCommand(4.0,CentalEyeRay(oTarget));
            DelayCommand(4.5,CentalEyeRay(oTarget));
            DelayCommand(5.0,CentalEyeRay(oTarget));
        }
    }
}

