//::///////////////////////////////////////////////
//:: FileName grant_level
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Script Wizard
//:: Created On: 7/30/2004 7:40:17 PM
//:://////////////////////////////////////////////
void main()
{
object oPC = GetLastUsedBy();
if (!GetIsPC(oPC)) return;
if (!(GetXP(oPC) <= 5001))
   return;
    // Give the speaker some gold
    GiveGoldToCreature(GetPCSpeaker(), 100);
    // Give the speaker some XP
    GiveXPToCreature(GetPCSpeaker(),1000);
ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_STRIKE_HOLY), oPC);
}
