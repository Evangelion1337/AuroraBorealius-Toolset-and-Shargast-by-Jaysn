//::///////////////////////////////////////////////
//:: Name x2_sp_is_sblue
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Ioun Stone Power: Scarlet Blue
    Gives the user 1 hours worth of +2 Intelligence bonus.
    Cancels any other Ioun stone powers in effect
    on the PC.
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Dec 13/02
//:://////////////////////////////////////////////
/*
Patch 1.70

- script rewrited a bit to use constants/be more efficient
*/

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
effect eVFX = EffectVisualEffect(VFX_DUR_IOUNSTONE_BLUE);
effect eBonus = EffectAbilityIncrease(ABILITY_INTELLIGENCE,2);
effect eLink = EffectLinkEffects(eVFX,eBonus);
//made this effect extraordinary so it won't be dispellable
//eLink = ExtraordinaryEffect(eLink);
ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eLink,oActivator,3600.0);
}
