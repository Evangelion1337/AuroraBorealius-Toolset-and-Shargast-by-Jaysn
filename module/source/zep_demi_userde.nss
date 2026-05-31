//::///////////////////////////////////////////////
//:: Custom User Defined Event
//:: FileName
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// Place in the UserDefined of the Demilich creature
*/
//:://////////////////////////////////////////////
//:: Created By: Demigog
//:: Created On:
//:://////////////////////////////////////////////
#include "NW_O2_CONINCLUDE"
#include "NW_I0_SPELLS"
#include "NW_I0_GENERIC"
void CreatePlaceable(string sTemplate,location lLoc)
{
    CreateObject(OBJECT_TYPE_PLACEABLE,sTemplate,lLoc);
}
void main()
{
    int nUser = GetUserDefinedEventNumber();
    object oCaster = OBJECT_SELF;
    object oSpellTarget = GetLastSpellCaster();
    object oCreature = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
    int nDamage;
    float fDelay;
    effect eExplode = EffectVisualEffect(VFX_FNF_PWKILL);
    effect eDam;
    location lTarget = GetLocation(oCreature);
    location lLoc = GetLocation(GetObjectByTag("demi_lich_01"));

    if(nUser == 1001) //HEARTBEAT    (Demilich Idle)
    {
     location lLoc = GetLocation(OBJECT_SELF);
     if(!GetIsInCombat(oCreature) && GetDistanceToObject(oCreature) > 20.0 || !GetIsFighting(oCreature) && GetDistanceToObject(oCreature) > 20.0 || !GetIsFighting(oSpellTarget) && GetDistanceToObject(oCreature) > 20.0 ||  (GetIsObjectValid(oCreature) == TRUE && GetDistanceToObject(oCreature) > 20.0) &&  (!GetIsFighting(oCreature)))
     {
     ClearAllActions();
     DelayCommand(20.0,CreatePlaceable("demi_lich_bones", lLoc));
     DelayCommand(20.0,CreatePlaceable("demi_lich_dust", lLoc));
     ActionDoCommand(DestroyObject(OBJECT_SELF,20.1));
     }
    }
    else if(nUser == 1002) // PERCEIVE (AoE Death Spell)
    {
      if (GetLocalInt (OBJECT_SELF, "Fired") == 0)

   {
      ClearAllActions();
    //Apply the fireball explosion at the location captured above.
    {
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, lTarget);
    }
    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
       //Fire cast spell at event for the specified target
   SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_FINGER_OF_DEATH));
        //Get the distance between the explosion and the target to calculate delay
    fDelay = GetDistanceBetweenLocations(lTarget, GetLocation(oTarget))/20;
            if (FortitudeSave(oTarget,15,SAVING_THROW_TYPE_DEATH, oTarget)==0)
             {
            //Set the effect to KILL!!
            eDam = EffectDamage(1500, DAMAGE_TYPE_MAGICAL,DAMAGE_POWER_ENERGY);
             if(!GetIsReactionTypeFriendly(oTarget) && !GetIsFriend(oTarget) && oTarget != OBJECT_SELF)

            {
                // Apply effects to the currently selected target.
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eExplode, oTarget));
            }
         }
       //Select the next target within the spell shape.
       oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR);
    }
     SetLocalInt (OBJECT_SELF, "Fired", 1);
     SetLocalInt(oTarget,"trappedsoul",0);
   }
    else if(nUser == 1003) // END OF COMBAT
    {
   //  {
   //  SpeakString("END OF COMBAT ROUND");
   //  }
    }
    else if(nUser == 1004) // ON DIALOGUE
    {

  //  }
  //  else if(nUser == 1005) // ATTACKED
  //  {
   //  {
   //  SpeakString("I AM ATTACKED");
    // }
    }
    else if(nUser == 1006) // DAMAGED
    {
   //  {
   //  SpeakString("I AM DAMAGED");
    // }
//    }
//    else if(nUser == 1007) // DEATH
//    {
    }
    else if(nUser == 1008) // DISTURBED
    {
     {
     SpeakString("I AM DISTURBED");
     }
    }
}
 return;
}








