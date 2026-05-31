//::///////////////////////////////////////////////
//:: Custom User Defined Event
//:: FileName
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////

void main()
{
    int nUser = GetUserDefinedEventNumber();

    if(nUser == 1002) // PERCEIVE
    {
        object oCreature = GetLastPerceived();
        {

            if (GetLastPerceptionSeen() & GetIsPC(oCreature))
            {
                ClearAllActions();
                SetLocalObject(OBJECT_SELF,"NW_L_TargetOfAttack",oCreature);
                SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_SHOUT);
                PlaySound("sdr_mindhit");
                PlaySound("sdr_mindhit");

            }
            else
                {
                    ClearAllActions();
                }
         }
    }
}

