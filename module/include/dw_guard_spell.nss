//::///////////////////////////////////////////////
//:: FileName dw_guard_spell
//:://////////////////////////////////////////////
/*
    When the object this script is attached to is has a spell cast at it, the script finds the nearest
    creature of the same faction and gets them to attack the caster.
*/
//:://////////////////////////////////////////////
//:: Created By: Olav Handeland & Oystein Sande - modified by Dreamwarder
//:: Created On: 02.07.03 - modified by Dreamwarder 1/6/04
//:://////////////////////////////////////////////

void main()
{
object Player1 = GetLastSpellCaster();
float DistanceRef = 31.0;
int i;
float DistanceMin = 0.0;
object DoorGuard0;

//Uses the (not entirely bug-free) GetFirstObjectInShape function and finds the first creature in that shape.
object DoorGuard = GetFirstObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);

//This long "for"-sentance ultimately finds the closest creature of the same faction of the chest/door.
for (i=0; i<=19; i++)
{
    if (i==0)
    {
        if ( GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance0 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            DistanceMin = DistanceRef - Distance0;
            DoorGuard0 = DoorGuard;
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==1)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance1 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance1 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance1;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==2)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance2 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance2 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance2;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==3)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance3 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance3 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance3;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==4)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance4 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance4 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance4;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==5)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance5 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance5 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance5;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==6)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance6 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance6 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance6;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==7)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance7 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance7 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance7;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==8)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance8 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance8 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance8;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==9)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance9 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance9 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance9;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==10)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance10 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance10 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance10;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==11)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance11 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance11 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance11;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==12)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance12 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance12 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance12;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==13)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance13 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance13 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance13;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==14)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance14 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance14 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance14;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==15)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance15 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance15 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance15;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==16)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance16 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance16 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance16;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==17)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance17 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance17 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance17;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==18)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance18 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance18 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance18;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

     if (i==19)
     {
        if (GetFactionEqual(DoorGuard, OBJECT_SELF) == TRUE)
        {
            float Distance19 = GetDistanceBetween(DoorGuard, OBJECT_SELF);
            if (DistanceRef - Distance19 > DistanceMin)
            {
                DistanceMin = DistanceRef - Distance19;
                DoorGuard0 = DoorGuard;
            }
        }
    DoorGuard = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_CREATURE);
    }

}

//Player is attacked if they cast a spell at the object
        if (GetLocalInt(OBJECT_SELF, "GenericDoorGuard1") == 3 )
        {
        AssignCommand(DoorGuard0, SpeakString("Get away from that!", TALKVOLUME_TALK));
        }

        if (GetLocalInt(OBJECT_SELF, "GenericDoorGuard1") == 0 )
        {
        AssignCommand(DoorGuard0, SpeakString("Get away from that!", TALKVOLUME_TALK));
        SetIsTemporaryEnemy(Player1, DoorGuard0, TRUE);
        AssignCommand(DoorGuard0, ActionAttack(Player1));
        AdjustAlignment(Player1, ALIGNMENT_CHAOTIC, 3);
        SetLocalInt(OBJECT_SELF, "GenericDoorGuard1", 3);
        }

}

