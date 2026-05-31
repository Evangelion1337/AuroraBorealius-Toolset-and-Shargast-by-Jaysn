//Camo Pit Trap Script

#include "zep_inc_scrptdlg"

void TrapPlayAnim(object oTrap)
{
   AssignCommand(oTrap, PlayAnimation(ANIMATION_PLACEABLE_ACTIVATE));
}

void RollingRockHitPC(object oPC, int nDamage)
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oPC);
    AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_NORMAL), oPC));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectKnockdown(), oPC, 30.0f);
}

void FallingBrickHitPC(object oPC, int nDamage)
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    PlayVoiceChat(VOICE_CHAT_PAIN2,oPC);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oPC);
    AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_NORMAL), oPC));
}

int TrapSave(object oPC, int nDC, int nDamage)
{
    if(!ReflexSave(oPC, nDC, SAVING_THROW_TYPE_TRAP))
    {
        if (GetHasFeat(FEAT_IMPROVED_EVASION, oPC))
            nDamage /= 2;
    }
    else if (GetHasFeat(FEAT_EVASION, oPC) || GetHasFeat(FEAT_IMPROVED_EVASION, oPC))
    {
        nDamage = 0;
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_IMP_REFLEX_SAVE_THROW_USE), oPC);
    }
    else
        nDamage /= 2;

    return nDamage;
}

void RazorWireTrap(object oPC)
{
    int nDC=25;
    int nDamage = d6(2);
    if(GetTrapDetectedBy(OBJECT_SELF, oPC))
        nDC =10;

    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    nDamage = TrapSave(oPC, nDC, nDamage);

    if(nDamage>0)
    {
        PlayVoiceChat(VOICE_CHAT_PAIN1,oPC);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_REG_RED), oPC);
        AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_SLASHING, DAMAGE_POWER_NORMAL), oPC));
        if(nDamage>6)
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectMovementSpeedDecrease(80), oPC, 30.0f);
    }
}

void RollingRockTrap(object oTrap)
{
    AssignCommand(oTrap,PlaySound("as_na_rockcavlg1"));

    int nDC=25;
    int nDamage = d6(2);
    location lEnd;
    vector vVector,vOrigin, vAngle;
    float fFacing;
    object oArea;

    lEnd = GetLocation(oTrap);
    fFacing = GetFacingFromLocation(lEnd);
    vVector = GetPositionFromLocation(lEnd);
    vAngle = AngleToVector(fFacing);
    oArea = GetAreaFromLocation(lEnd);
    lEnd = Location(oArea,Vector(vVector.x+(-20.0*vAngle.x),vVector.y+(-20.0*vAngle.y),vVector.z),-fFacing);

    vOrigin = Vector(vVector.x+(-24.0*vAngle.x),vVector.y+(-24.0*vAngle.y),vVector.z);

    object oPC = GetFirstObjectInShape(SHAPE_SPELLCYLINDER,24.5,lEnd,FALSE,OBJECT_TYPE_CREATURE,vOrigin);
    while(GetIsObjectValid(oPC))
    {
        nDamage = TrapSave(oPC, nDC, nDamage);

        if(nDamage>0)
        {
            DelayCommand(1.5,RollingRockHitPC(oPC,nDamage));
        }
        oPC = GetNextObjectInShape(SHAPE_SPELLCYLINDER,24.5,lEnd,FALSE,OBJECT_TYPE_CREATURE,vOrigin);
    }
}

void WallBladeTrap(object oPC)
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");

    int nDC = 15;
    int nTot = 0;
    int nN, nDamage;
    for(nN=0;nN<4;nN++)
    {
        nDamage = d4(2);

        nDamage = TrapSave(oPC, nDC, nDamage);

        if(nDamage>0)
            AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_PIERCING, DAMAGE_POWER_NORMAL), oPC));

        nTot+=nDamage;
    }
    if(nTot>0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oPC);
        AssignCommand(oPC,PlaySound("cb_ht_metblleth2"));
        PlayVoiceChat(VOICE_CHAT_PAIN1,oPC);
    }
    else
       AssignCommand(oPC,PlaySound("cb_sw_blade2"));
}


void FallingBricksTrap(object oTrap)
{
    int nDC = 15;
    object oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTrap);
    AssignCommand(oPC, PlaySound("as_na_rockfallg1"));//cb_bu_stonelg
    int nDamage,nN;
    while(GetIsObjectValid(oPC)&&(GetDistanceBetween(oTrap,oPC)<2.0))
    {
        nDamage = d6(2);

        nDamage = TrapSave(oPC, nDC, nDamage);

        if(nDamage>0)
        {
            DelayCommand(1.1,FallingBrickHitPC(oPC,nDamage));
        }

        nN++;
        oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTrap, nN);
    }
}

void SwingingRockTrap(object oTriggerer)
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    int nDC =20;
    int nDamage, nN;

    nDamage = TrapSave(oTriggerer, nDC, d6(2));
    if(nDamage>0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oTriggerer);
        AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_NORMAL), oTriggerer));
    }

    object oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTriggerer);
    while(GetIsObjectValid(oPC)&&(GetDistanceBetween(oTriggerer,oPC)<2.0))
    {
        nDamage = d6(2);

        nDamage = TrapSave(oPC, nDC, nDamage);

        if(nDamage>0)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oPC);
            AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_NORMAL), oPC));
        }

        nN++;
        oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTriggerer, nN);
    }
}

void SwingingBladeTrap(object oTriggerer)
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    int nDC =20;
    int nDamage, nN;

    nDamage = TrapSave(oTriggerer, nDC, d12(1));
    if(nDamage>0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oTriggerer);
        AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_SLASHING, DAMAGE_POWER_NORMAL), oTriggerer));
    }

    object oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTriggerer);
    while(GetIsObjectValid(oPC)&&(GetDistanceBetween(oTriggerer,oPC)<2.0))
    {
        nDamage = d12(1);

        nDamage = TrapSave(oPC, nDC, nDamage);

        if(nDamage>0)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oPC);
            AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_SLASHING, DAMAGE_POWER_NORMAL), oPC));
        }

        nN++;
        oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTriggerer, nN);
    }
}

void ResetWhirlingBlades()
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");

    DeleteLocalInt(OBJECT_SELF,"TRP_TRIGGERED");

    if(GetIsObjectValid(oTrap))
    {
        AssignCommand(oTrap, PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
        DestroyObject(oTrap,1.0);
        DeleteLocalInt(OBJECT_SELF,"TRP_PLCBL_SHOW");
    }
}

void Drown(object oPC)
{
    if(GetLocalInt(OBJECT_SELF,"TRP_TRIGGERED")==1)
    {
        int nD = GetLocalInt(oPC,"DROWNING");
        if(nD==4) //Beginning of the 5th round
        {
            DeleteLocalInt(oPC,"DROWNING");
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oPC);
        }
        else
        {
            SetLocalInt(oPC,"DROWNING",nD+1);
            string sMessageToPC=GetStringByStrRef(nZEPDrowning,GENDER_MALE);
            AssignCommand(oPC,SpeakString(sMessageToPC));
            DelayCommand(6.0,Drown(oPC));
        }
    }
    else
    {
        effect eAOE = GetFirstEffect(oPC);
        while (GetIsEffectValid(eAOE))
        {
            if (GetEffectCreator(eAOE) == OBJECT_SELF)
            {
                    RemoveEffect(oPC, eAOE);
            }
            //Get next effect on the target
            eAOE = GetNextEffect(oPC);
        }
        DeleteLocalInt(oPC,"DROWNING");
    }
}

void FloodTrap(object oPC)
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    AssignCommand(oTrap, PlaySound("al_na_fountainlg"));
    location lWater;

    vector v = GetPosition(oTrap);
    vector w = AngleToVector(GetFacing(oTrap));

    lWater = Location(GetArea(oTrap),Vector(v.x+(8.0*w.x),v.y+(8.0*w.y),v.z),GetFacing(oTrap));
    object oDoor = GetNearestObject(OBJECT_TYPE_DOOR);
    AssignCommand(oDoor,ActionCloseDoor(oDoor));
    AssignCommand(oDoor,SetLocked(oDoor,TRUE));

    oPC = GetFirstObjectInShape(SHAPE_CUBE,8.0,lWater,TRUE);
    while(GetIsObjectValid(oPC))
    {
        if(GetLocalInt(oPC,"DROWNING"))
            DeleteLocalInt(oPC,"DROWNING");
        else
        {
            ApplyEffectToObject(DURATION_TYPE_PERMANENT,EffectSlow(),oPC);
            DelayCommand(6.0,Drown(oPC));
        }
        oPC = GetNextObjectInShape(SHAPE_CUBE,8.0,lWater,TRUE);
    }
}

void main()
{
    string sTrap = GetStringLeft(GetTag(OBJECT_SELF),7);
    if(GetLocalInt(OBJECT_SELF,"TRP_TRIGGERED")&&(sTrap!="RWFTrap"))
        return;

    SetLocalInt(OBJECT_SELF,"TRP_TRIGGERED",1);


    object oTrap;

    if((sTrap!="RPFTrap")&&(GetLocalInt(OBJECT_SELF,"TRP_PLCBL_SHOW")==0))
    {
        string sPcbl;
        if(sTrap=="MPFTrap")
            sPcbl = "metalpitpcbl";
        if(sTrap=="RWFTrap")
            sPcbl = "razorwirepcbl";
        if(sTrap=="RRFTrap")
            sPcbl = "rollingrockpcbl";
        if(sTrap=="WSFTrap")
            sPcbl = "wallbladepcbl";
        if(sTrap=="FBFTrap")
            sPcbl = "fallingbrickpcbl";
        if(sTrap=="SRFTrap")
            sPcbl = "swingingrockpcbl";
        if(sTrap=="SBFTrap")
            sPcbl = "swingbladepcbl";
        if(sTrap=="WBFTrap")
            sPcbl = "whirlbladepcbl";
        if(sTrap=="FlFTrap")
            sPcbl = "floodpcbl";

        location lPlcbl = GetLocalLocation(OBJECT_SELF,"TRP_PLCBL_LOC");
        SetLocalInt(OBJECT_SELF,"TRP_PLCBL_SHOW",1);
        oTrap = CreateObject(OBJECT_TYPE_PLACEABLE,sPcbl,lPlcbl);
        SetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ",oTrap);
    }
    else
        oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");


    if(sTrap=="RPFTrap")
    {
        TrapPlayAnim(oTrap);
        ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,EffectAreaOfEffect(38),GetLocation(oTrap),HoursToSeconds(200));
        return;
    }
    else if(sTrap=="MPFTrap")
    {
        AssignCommand(oTrap,DelayCommand(1.0,TrapPlayAnim(oTrap)));
        ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,EffectAreaOfEffect(39),GetLocation(oTrap),HoursToSeconds(200));
        return;
    }
    else if(sTrap=="WBFTrap")
    {
        AssignCommand(oTrap,DelayCommand(1.0,TrapPlayAnim(oTrap)));
        ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,EffectAreaOfEffect(40),GetLocation(oTrap),120.0);
        DelayCommand(120.0, ResetWhirlingBlades());
        return;
    }

    AssignCommand(oTrap,DelayCommand(1.0,TrapPlayAnim(oTrap)));

    int nDC;
    int nDamage;
    object oPC = GetEnteringObject();

    if(sTrap=="RWFTrap")
    {
        RazorWireTrap(oPC);
        return;
    }
    else if(sTrap=="RRFTrap")
    {
        RollingRockTrap(oTrap);
        return;
    }
    else if(sTrap=="WSFTrap")
    {
        WallBladeTrap(oPC);
        return;
    }
    else if(sTrap=="FBFTrap")
    {
        FallingBricksTrap(oTrap);
        return;
    }
    else if(sTrap=="SRFTrap")
    {
        SwingingRockTrap(oPC);
        return;
    }
    else if(sTrap=="SBFTrap")
    {
        SwingingBladeTrap(oPC);
        return;
    }
    else if(sTrap=="FlFTrap")
    {
        FloodTrap(oPC);
        return;
    }


}



