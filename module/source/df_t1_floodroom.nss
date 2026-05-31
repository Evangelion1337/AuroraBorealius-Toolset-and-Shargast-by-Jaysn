void TrapPlayAnim(object oTrap)
{
   AssignCommand(oTrap, PlayAnimation(ANIMATION_PLACEABLE_ACTIVATE));
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
            AssignCommand(oPC,SpeakString("Blub!  Glug!"));
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

void main()
{
    if(GetLocalInt(OBJECT_SELF,"TRP_TRIGGERED"))
        return;

    SetLocalInt(OBJECT_SELF,"TRP_TRIGGERED",1);


    object oTrap;

    if(GetLocalInt(OBJECT_SELF,"TRP_PLCBL_SHOW")==0)
    {
        location lPlcbl = GetLocalLocation(OBJECT_SELF,"TRP_PLCBL_LOC");
        SetLocalInt(OBJECT_SELF,"TRP_PLCBL_SHOW",1);
        oTrap = CreateObject(OBJECT_TYPE_PLACEABLE,"floodpcbl",lPlcbl);
        SetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ",oTrap);
    }
    else
        oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");


AssignCommand(oTrap, PlaySound("al_na_fountainlg"));
    AssignCommand(oTrap,DelayCommand(1.0,TrapPlayAnim(oTrap)));

    location lWater;

    vector v = GetPosition(oTrap);
    vector w = AngleToVector(GetFacing(oTrap));

    lWater = Location(GetArea(oTrap),Vector(v.x+(8.0*w.x),v.y+(8.0*w.y),v.z),GetFacing(oTrap));
    object oDoor = GetNearestObject(OBJECT_TYPE_DOOR);
    AssignCommand(oDoor,ActionCloseDoor(oDoor));
    AssignCommand(oDoor,SetLocked(oDoor,TRUE));

    object oPC = GetFirstObjectInShape(SHAPE_CUBE,8.0,lWater,TRUE);
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
