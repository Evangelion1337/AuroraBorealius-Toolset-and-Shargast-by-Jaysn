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
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Take strenth, child of the Forge!'");
            ActionCastSpellAtObject(SPELL_AID, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 2://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'You gain knowledge, child of the Forge!'");
            GiveXPToCreature(oPC, 121);
            break;
        case 3://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'To war, child of the Forge!'");
            ActionCastSpellAtObject(SPELL_BATTLETIDE, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 4://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Forget all your woes, child of the Forge!'");
            ActionCastSpellAtObject(SPELL_BLESS, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 5://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'See things as they are, child of the Forge!'");
            ActionCastSpellAtObject(SPELL_CLARITY, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 6://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'You are wise, child of the Forge!'");
            ActionCastSpellAtObject(SPELL_OWLS_WISDOM, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 7://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Be under my protection, child of the Forge!'");
            ActionCastSpellAtObject(SPELL_DEATH_ARMOR, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 8://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'May you run with strength, child of the Forge!'");
            ActionCastSpellAtObject(SPELL_ENDURANCE, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 9://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'A taste of Power, child of the Forge!'");
            ActionCastSpellAtObject(SPELL_ENDURE_ELEMENTS, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 10://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Amazing grace, child of the Forge!'");
            ActionCastSpellAtObject(SPELL_CATS_GRACE, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 11://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'The power of the wood, child of the Forge!'");
            ActionCastSpellAtObject(SPELL_BARKSKIN, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 12://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Energy of Intelligence, child of the Forge!'");
            ActionCastSpellAtObject(SPELL_FOXS_CUNNING, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 13://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Vox Rectum, child of the Forge!'");
            ActionCastSpellAtObject(SPELL_ETHEREAL_VISAGE, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 14://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Granit to you, child of the Forge!'");
            ActionCastSpellAtObject(SPELL_GREATER_STONESKIN, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 15://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'You are protected, child of the Forge!'");
            ActionCastSpellAtObject(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 16://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind 'My blessings, child of the Forge!'");
            ActionCastSpellAtObject(SPELL_PRAYER, oPC, METAMAGIC_NONE, TRUE);
            break;
        case 17://Tested
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Give me your power, child of the Forge!'");
            ActionCastSpellAtObject(SPELL_PROTECTION_FROM_EVIL, oPC, METAMAGIC_NONE, TRUE);
            break;
        default:
            SendMessageToPC(oPC, "A soft voice whispers in your mind: 'Feel refreshed, child of the Forge!'");
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(7), oPC);
            break;
     }
    }
}

