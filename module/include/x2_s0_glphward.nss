//::///////////////////////////////////////////////
//:: Glyph of Warding
//:: X2_S0_GlphWard
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The caster creates a trapped area which detects
    the entrance of enemy creatures into 3 m area
    around the spell location.  When tripped it
    causes a sonic explosion that does 1d8 per
    two caster levels up to a max of 5d8 damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Dec 04, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- DC for this spell was always 14
- this spell doesn't allowed spellcraft saving throw bonus
- will vanish after rest
*/

#include "70_inc_spells"
#include "x2_inc_spellhook"

void main()
{
/*
  Spellcast Hook Code
  Added 2003-07-07 by Georg Zoeller
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more

*/

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

// End of Spell Cast Hook

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(AOE_PER_GLYPH_OF_WARDING,"x2_s0_glphwarda");
    object oGlyph;
    int nTh = 2;
    int nDuration = spell.Level/2;
    if(nDuration < 1)
    {
        nDuration = 1;
    }
    if(spell.Meta == METAMAGIC_EXTEND)
    {
        nDuration *= 2;
    }
    //disallow player to stack multiple aoes at the same position
    object oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, spell.Loc);
    while(GetIsObjectValid(oAOE) && GetDistanceBetweenLocations(GetLocation(oAOE), spell.Loc) < 4.75)
    {                                                                                   //lets be a little tolerant
        if(GetTag(oAOE) == "VFX_PER_GLYPH")
        {
            //there is already this AoE in near the spell location, the spell thus ends there
            FloatingTextStrRefOnCreature(84612, spell.Caster);
            return;
        }
        oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, spell.Loc, nTh++);
    }
    //should be glyph invisible or not?
    if(!GetLocalInt(GetModule(),"X2_SWITCH_GLYPH_OF_WARDING_INVISIBLE"))
    {
        //ok it shouldn't, placeable workaround have to be used then :/
        oGlyph = CreateObject(OBJECT_TYPE_PLACEABLE,"x2_plc_glyph",spell.Loc);
        effect eVis = EffectVisualEffect(VFX_DUR_GLYPH_OF_WARDING);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eVis,oGlyph,TurnsToSeconds(nDuration));
    }
    else
    {
        //it should, so let the VFX appear only for a short while like in original script
        eAOE = EffectLinkEffects(eAOE,EffectVisualEffect(VFX_DUR_GLYPH_OF_WARDING));
    }
    //lets make the AOE
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,eAOE,spell.Loc,TurnsToSeconds(nDuration));
    //if the placeable VFX holder was created, it must be set up on the new AOE object in order to destroy it later
    nTh = 2;
    oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT,spell.Loc);
    while(GetIsObjectValid(oAOE) && GetDistanceBetweenLocations(GetLocation(oAOE), spell.Loc) < 5.0)
    {
        if(GetTag(oAOE) == "VFX_PER_GLYPH" && GetLocalObject(oAOE,"VFX_OWNER") == OBJECT_INVALID)
        {
            //got it
            SetLocalObject(oAOE,"AOE_OWNER",spell.Caster);
            SetLocalInt(oAOE,"AOE_DC",spell.DC);
            SetLocalInt(oAOE,"AOE_META",spell.Meta+1);
            SetLocalInt(oAOE,"AOE_LEVEL",spell.Level);
            if(oGlyph != OBJECT_INVALID)
            {
                SetLocalObject(oAOE,"VFX_PLACEABLE",oGlyph);
                SetLocalObject(oGlyph,"AOE",oAOE);
            }
            break;
        }
        oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT,spell.Loc,nTh++);
    }
/* original code
   object oGlyph = CreateObject(OBJECT_TYPE_PLACEABLE,"x2_plc_glyph",GetSpellTargetLocation());
   object  oTest = GetNearestObjectByTag("X2_PLC_GLYPH",oGlyph);

    if (GetIsObjectValid(oTest) && GetDistanceBetween(oGlyph, oTest) <5.0f)
    {
        FloatingTextStrRefOnCreature(84612,OBJECT_SELF);
        DestroyObject(oGlyph);
        return;
    }


   // Store the caster
   SetLocalObject(oGlyph,"X2_PLC_GLYPH_CASTER", spell.Caster);

   // Store the caster level
   SetLocalInt  (oGlyph,"X2_PLC_GLYPH_CASTER_LEVEL", spell.Level);

   // Store Meta Magic
   SetLocalInt (oGlyph,"X2_PLC_GLYPH_CASTER_METAMAGIC", spell.Meta);

   SetLocalInt(oGlyph, "X2_PLC_GLYPH_DC", spell.DC);

   // This spell (default = line 768 in spells.2da) will run when someone enters the glyph
   SetLocalInt(oGlyph,"X2_PLC_GLYPH_SPELL", spell.Id);

   // Tell the system that this glyph was player and not toolset created
   SetLocalInt (oGlyph,"X2_PLC_GLYPH_PLAYERCREATED",TRUE);

   // Tell the game the glyph is not a permanent one
   DeleteLocalInt(oGlyph,"X2_PLC_GLYPH_PERMANENT");

   // Force first hb
   ExecuteScript("x2_o0_glyphhb",oGlyph);
*/
}
