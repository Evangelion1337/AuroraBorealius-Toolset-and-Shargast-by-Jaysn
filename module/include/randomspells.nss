//: Magical Pool of Wonder
//: By Thorbone, July 4, 2002.
//: Inspired by a script by NWN Community member Weishaar
#include "nw_i0_tool"
void main()
{
    object oPC = GetLastUsedBy();
    if (GetIsPC(oPC)) {
        effect eObject = EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_2, FALSE);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eObject, oPC, 1.0f);
        int chanceWheel = Random(20);
        switch(chanceWheel)
        {
       case 1://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Rest, my child!'");
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSleep(), oPC, 14.0f);
            break;
        case 2://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'You gain knowledge, my child!'");
            GiveXPToCreature(oPC, 121);
            break;
        case 3://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Stand still, my child!'");
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectParalyze(), oPC, 14.0f);
            break;
        case 4://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Forget all your woes, my child!'");
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDazed(), oPC, 14.0f);
            break;
        case 5://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Have a scratch, my child!'");
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(7, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_NORMAL), oPC);
            break;
        case 6://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'You are wise, my child!'");
            ActionCastSpellAtObject(SPELL_OWLS_WISDOM, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 7://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Squeal like a pig, my child!'");
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectPolymorph(POLYMORPH_TYPE_BOAR), oPC, 45.0);
            break;
        case 8://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Meet your power animal, my child!'");
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectPolymorph(POLYMORPH_TYPE_PENGUIN), oPC, 45.0);
            break;
        case 9://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'A taste of Power, my child!'");
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectPolymorph(POLYMORPH_TYPE_RED_DRAGON), oPC, 45.0);
            break;
        case 10://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Amazing grace, my child!'");
            ActionCastSpellAtObject(SPELL_CATS_GRACE, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 11://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'The power of the wood, my child!'");
            ActionCastSpellAtObject(SPELL_BARKSKIN, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 12://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Energy of Intelligence, my child!'");
            ActionCastSpellAtObject(SPELL_FOXS_CUNNING, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 13://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Vox Rectum, my child!'");
            ActionCastSpellAtObject(SPELL_STINKING_CLOUD, oPC, METAMAGIC_NONE, TRUE);
            eObject = EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_NATURE, FALSE);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eObject, oPC, 3.0f);
            break;
        case 14://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'A fire in your heart, my child!'");
            ActionCastSpellAtObject(SPELL_BURNING_HANDS, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 15://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Relax, my child!'");
            ActionCastSpellAtObject(SPELL_SLOW, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 16://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind ......... 'BOOH!'");
            ActionCastSpellAtObject(SPELL_FEAR, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 17://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Give me your power, my child!'");
            ActionCastSpellAtObject(SPELL_ENERGY_DRAIN, oPC, METAMAGIC_NONE, TRUE);
            break;
        default:
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Feel refreshed, my child!'");
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(7), oPC);
            break;
     }
    }
}
