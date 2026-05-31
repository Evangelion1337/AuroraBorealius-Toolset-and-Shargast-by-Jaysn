//::///////////////////////////////////////////////
//:: Name x2_sp_is_drose
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Ioun Stone Power: Dusty Rose
    Gives the user 1 hours worth of +1 AC bonus,
    Deflection
    Cancels any other Ioun stone powers in effect
    on the PC.
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Dec 13/02
//:://////////////////////////////////////////////
/*
Patch 1.71

- AC class changed to dodge
- script rewrited a bit to use constants/be more efficient
*/


#include "x2_inc_switches"

void main()
{
//variables
object oActivator = OBJECT_SELF;
int nID;
effect eEffect = GetFirstEffect(oActivator);

 while(GetIsEffectValid(eEffect))//this loop will remove any other ioun stone effect
 {
 nID = GetEffectSpellId(eEffect);
  if(nID > 553 && nID < 561)
  {
  RemoveEffect(oActivator,eEffect);
  }
 eEffect = GetNextEffect(oActivator);
 }

//Apply new ioun stone effect
effect eVFX = EffectVisualEffect(VFX_DUR_IOUNSTONE_YELLOW);
effect eBonus = EffectACIncrease(1,AC_DODGE_BONUS);
effect eLink = EffectLinkEffects(eVFX,eBonus);
//made this effect extraordinary so it won't be dispellable
//eLink = ExtraordinaryEffect(eLink);
ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eLink,oActivator,3600.0);
}
