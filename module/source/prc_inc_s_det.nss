//::///////////////////////////////////////////////
//:: Include file for Detect Alignment spells
//:: prc_inc_s_det
//:://////////////////////////////////////////////
/** @file

This file handles the Detect Evil/Law/Chaos/Good series of spells
If there are other detect spells, they can probably be put in here too.

    @author Primogenitor
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


#include "prc_inc_spells"
#include "prc_add_spell_dc"
//#include "inc_draw"    Provided by inc_utility
//#include "inc_utility" Provided by prc_alterations

//this is the main detection function
void DetectAlignmentRound(int nRound, location lLoc, int nGoodEvil, int nLawChaos, string sAura, int nBeamVFX);

// Detect Magic
void DetectMagicAura(int nRound, location lLoc, int nBeamVFX, float fDist);

const int AURA_STRENGTH_DIM          = 1;
const int AURA_STRENGTH_FAINT        = 2;
const int AURA_STRENGTH_MODERATE     = 3;
const int AURA_STRENGTH_STRONG       = 4;
const int AURA_STRENGTH_OVERWHELMING = 5;

int GetIsUndetectable(object oTarget, object oCaster)//fix this
{
    int nUndetectable = FALSE;
    if(GetHasSpellEffect(SPELL_UNDETECTABLE_ALINGMENT, oTarget) ||
    GetHasSpellEffect(SPELL_NONDETECTION, oTarget) ||
    GetLevelByClass(CLASS_TYPE_WILD_MAGE, oTarget) >= 6 ||
    GetLevelByClass(CLASS_TYPE_UNSEEN_SEER, oTarget) >= 5 ||
    GetHasSpellEffect(MELD_ENIGMA_HELM, oTarget) ||
    GetRacialType(oTarget) == RACIAL_TYPE_SKULK) // MELD_ENIGMA_HELM
    {
        int nDC = PRCGetSaveDC(OBJECT_SELF, oTarget, SPELL_UNDETECTABLE_ALINGMENT);
        //if you dont beat the saving throw of the spell, you cant detect them
        if(!PRCMySavingThrow(SAVING_THROW_WILL, oCaster, nDC, SAVING_THROW_TYPE_NONE))
            nUndetectable = TRUE;
    }
    return nUndetectable;
}

string AlignmentAuraLocal(int nGoodEvil, int nLawChaos)
{
    if      (nGoodEvil == ALIGNMENT_GOOD)    return "PRC_AURA_GOOD";
    else if(nGoodEvil == ALIGNMENT_EVIL)    return "PRC_AURA_EVIL";
    else if(nLawChaos == ALIGNMENT_LAWFUL)  return "PRC_AURA_LAW";
    else if(nLawChaos == ALIGNMENT_CHAOTIC) return "PRC_AURA_CHAOS";

    return "";
}

int GetAuraStrength(object oTarget, int nGoodEvil, int nLawChaos)//add new classes
{
    int nPower = GetLocalInt(oTarget, AlignmentAuraLocal(nGoodEvil, nLawChaos));

    // Only creatures proceed past this point.
    if (GetObjectType(oTarget) != OBJECT_TYPE_CREATURE)
        return nPower;

    int nRace = MyPRCGetRacialType(oTarget);
    if(nRace == RACIAL_TYPE_OUTSIDER)
        nPower = GetHitDice(oTarget);
    else if((nRace == RACIAL_TYPE_UNDEAD && nGoodEvil==ALIGNMENT_EVIL)//undead only for evils
        || nRace == RACIAL_TYPE_ELEMENTAL)
        nPower = GetHitDice(oTarget)/2;
    else
        nPower = GetHitDice(oTarget)/5;
    if(GetPrCAdjustedCasterLevel(CLASS_TYPE_CLERIC, oTarget) > nPower)
        nPower = GetPrCAdjustedCasterLevel(CLASS_TYPE_CLERIC, oTarget);
    if(GetPrCAdjustedCasterLevel(CLASS_TYPE_ANTI_PALADIN, oTarget) > nPower)
        nPower = GetPrCAdjustedCasterLevel(CLASS_TYPE_ANTI_PALADIN, oTarget);

/*CLASS_TYPE_CLERIC
CLASS_TYPE_ANTI_PALADIN
Dragon shaman
blackguard*/
    return nPower;
}

string GetNounForStrength(int nStrength)
{
    switch(nStrength)
    {
        case AURA_STRENGTH_DIM:          return GetStringByStrRef(16832039); //"dimly"
        case AURA_STRENGTH_FAINT:        return GetStringByStrRef(16832040); //"faintly"
        case AURA_STRENGTH_MODERATE:     return GetStringByStrRef(16832041); //"moderately"
        case AURA_STRENGTH_STRONG:       return GetStringByStrRef(16832042); //"strongly"
        case AURA_STRENGTH_OVERWHELMING: return GetStringByStrRef(16832043); //"overwhelmingly"
    }
    return "";
}

void ApplyEffectDetectAuraOnObject(int nStrength, object oTarget, int nVFX)
{
    location lLoc = GetLocation(oTarget);
    //float fRadius = (IntToFloat(GetCreatureSize(oTarget))*0.5)+0.5; //this is graphics related, not rules
    float fRadius = StringToFloat(Get2DACache("appearance", "CREPERSPACE", GetAppearanceType(oTarget)));
    location lCenter;
    vector vCenter = GetPositionFromLocation(lLoc);
    switch(nStrength)
    {
        //yes fallthroughs here
        case AURA_STRENGTH_OVERWHELMING:
            vCenter.z += (fRadius/2.0);
            lCenter = Location(GetAreaFromLocation(lLoc), vCenter, 0.0);
            BeamPentacle(DURATION_TYPE_TEMPORARY, nVFX, lCenter, fRadius, 6.2f, "", 1.0f, 0.0f);
        case AURA_STRENGTH_STRONG:
            vCenter.z += (fRadius/2.0);
            lCenter = Location(GetAreaFromLocation(lLoc), vCenter, 0.0);
            BeamPentacle(DURATION_TYPE_TEMPORARY, nVFX, lCenter, fRadius, 6.2f, "", 1.0f, 0.0f);
        case AURA_STRENGTH_MODERATE:
            vCenter.z += (fRadius/2.0);
            lCenter = Location(GetAreaFromLocation(lLoc), vCenter, 0.0);
            BeamPentacle(DURATION_TYPE_TEMPORARY, nVFX, lCenter, fRadius, 6.2f, "", 1.0f, 0.0f);
        case AURA_STRENGTH_FAINT:
            vCenter.z += (fRadius/2.0);
            lCenter = Location(GetAreaFromLocation(lLoc), vCenter, 0.0);
            BeamPentacle(DURATION_TYPE_TEMPORARY, nVFX, lCenter, fRadius, 6.2f, "", 1.0f, 0.0f);
        case AURA_STRENGTH_DIM:
            vCenter.z += (fRadius/2.0);
            lCenter = Location(GetAreaFromLocation(lLoc), vCenter, 0.0);
            BeamPentacle(DURATION_TYPE_TEMPORARY, nVFX, lCenter, fRadius, 6.2f, "", 1.0f, 0.0f);
    }
}

void DetectAlignmentRound(int nRound, location lLoc, int nGoodEvil, int nLawChaos, string sAura, int nBeamVFX)
{
    object oCaster = OBJECT_SELF;
    int nSpellID = GetSpellId();

    if(!GetHasSpellEffect(nSpellID, oCaster))
        return;

    //if concentration is broken, abort
    if(GetBreakConcentrationCheck(oCaster) && nRound != 0)
    {
        FloatingTextStringOnCreature(GetStringByStrRef(16832000)/*"Concentration broken."*/, oCaster, FALSE);
        PRCRemoveEffectsFromSpell(oCaster, nSpellID);
        return;
    }

    location lNew = GetLocation(oCaster);

    //if you move/turn, restart the process / abort if moved more than 2 m
    if(lLoc != lNew)
    {
        if(GetDistanceBetweenLocations(lLoc, lNew) > 2.0)
        {
            PRCRemoveEffectsFromSpell(oCaster, nSpellID);
            FloatingTextStringOnCreature("You have moved too far, ending Detection", oCaster, FALSE);
            return;
        }
        else
            nRound = 1;
    }
    if(nRound < 0)
        nRound = 1;
    //sanity check
    if(nRound > 4)
        nRound = 4;

    // Generate a target location in front of us.
    float fFacing = GetFacing(oCaster);
    vector vPos = GetPosition(oCaster);
    location lTarget = Location(GetArea(oCaster),
                       Vector(vPos.x + cos(fFacing), vPos.y + sin(fFacing), vPos.z),
                       fFacing);

    object oTest = GetFirstObjectInShape(SHAPE_SPELLCONE, 20.0, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_ITEM | OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_AREA_OF_EFFECT);
    int nStrongestAura;
    int nAuraCount;
    while(GetIsObjectValid(oTest))
    {
        if(DEBUG) DoDebug("DetectAlignmentRound() : Round = "+IntToString(nRound)+"from "+GetName(oCaster)+" of "+GetName(oTest));

        int nUndetectable = GetIsUndetectable(oTest, oCaster); //you cannot be detected if this is true
        if((GetAlignmentGoodEvil(oTest) == nGoodEvil || nGoodEvil == -1)
            && (GetAlignmentLawChaos(oTest) == nLawChaos || nLawChaos == -1)
            && ((sAura == GetStringByStrRef(5018)) ? MyPRCGetRacialType(oTest) == RACIAL_TYPE_UNDEAD : TRUE)
            && oTest != oCaster
            && !nUndetectable)
        {
            if(nRound == 1)
            {
                //presence/absence
                //ApplyEffectDetectAuraOnObject(AURA_STRENGTH_MODERATE, oCaster, nBeamVFX);
                FloatingTextStringOnCreature(PRCGetRGB(15,5,5) + GetStringByStrRef(16832001)// "You detect the presense of"
                                             + " " + (nLawChaos != -1 ? // "good" and "evil" work as both substantives and adjectives, but not so for "lawful" and "chaotic"
                                                      (nLawChaos == ALIGNMENT_LAWFUL ?
                                                       GetStringByStrRef(4957)   // "law"
                                                       : GetStringByStrRef(4958) // "chaos"
                                                       )
                                                      : sAura
                                                      )
                                              + ".",
                                             oCaster, FALSE);
                break;//end while loop
            }

            int nStrength;
            int nRawStrength = GetAuraStrength(oTest, nGoodEvil, nLawChaos);

            if(nRawStrength == 0)
                nStrength = AURA_STRENGTH_DIM;
            else if(nRawStrength == 1)
                nStrength = AURA_STRENGTH_FAINT;
            else if(nRawStrength >= 2 && nRawStrength <= 4)
                nStrength = AURA_STRENGTH_MODERATE;
            else if(nRawStrength >= 5 && nRawStrength <= 10)
                nStrength = AURA_STRENGTH_STRONG;
            else if(nRawStrength >= 11)
                nStrength = AURA_STRENGTH_OVERWHELMING;

            if(nRound == 2)
            {
                //number & strongest
                nAuraCount++;
                if(nStrength > nStrongestAura)
                    nStrongestAura = nStrength;
                //if overwhelming then can stun
                int nOpposingGoodEvil;
                if(nGoodEvil == ALIGNMENT_EVIL)
                    nOpposingGoodEvil = ALIGNMENT_GOOD;
                else if(nGoodEvil == ALIGNMENT_GOOD)
                    nOpposingGoodEvil = ALIGNMENT_EVIL;
                else
                    nOpposingGoodEvil = -1;
                int nOpposingLawChaos;
                if(nLawChaos == ALIGNMENT_CHAOTIC)
                    nOpposingLawChaos = ALIGNMENT_LAWFUL;
                else if(nLawChaos == ALIGNMENT_LAWFUL)
                    nOpposingLawChaos = ALIGNMENT_CHAOTIC;
                else
                    nOpposingLawChaos = -1;

                if(nStrength == AURA_STRENGTH_OVERWHELMING
                    && (GetAlignmentGoodEvil(oCaster)==nOpposingGoodEvil || nOpposingGoodEvil == -1)
                    && (GetAlignmentLawChaos(oCaster)==nOpposingLawChaos || nOpposingLawChaos == -1)
                    && nRawStrength > GetHitDice(oCaster)*2)
                {
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectStunned(), oCaster, 6.0);
                }
            }
            else if(nRound >= 3)
            {
                if(nRound == 3)
                    ActionDoCommand(FloatingTextStringOnCreature(PRCGetRGB(15,16-(nStrength*3),16-(nStrength*3)) + GetName(oTest) + " " + GetStringByStrRef(16832044)/*"feels"*/ + " "+GetNounForStrength(nStrength)+" "+sAura+".", oCaster, FALSE));
                //strength & location
                ActionDoCommand(ApplyEffectDetectAuraOnObject(nStrength, oTest, nBeamVFX));
            }
        }
        oTest = GetNextObjectInShape(SHAPE_SPELLCONE, 20.0, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_ITEM | OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_AREA_OF_EFFECT);
    }
    if(nRound == 2)
    {
        //reporting
        //ApplyEffectDetectAuraOnObject(nStrongestAura, oCaster, nBeamVFX);
        FloatingTextStringOnCreature(PRCGetRGB(15,16-(nStrongestAura*3),16-(nStrongestAura*3)) + GetStringByStrRef(16832045)/*"You detected"*/ + " " + IntToString(nAuraCount) + " " + GetNounForStrength(nStrongestAura) + " " + sAura + " " + GetStringByStrRef(16832046)/*"auras"*/ + ".", oCaster, FALSE);
    }

    //ActionPlayAnimation(ANIMATION_LOOPING_MEDITATE, 1.0, 6.0);
    nRound++;

    DelayCommand(6.0f, ActionDoCommand(DetectAlignmentRound(nRound, lNew, nGoodEvil, nLawChaos, sAura, nBeamVFX)));
}

int GetMagicAuraStrength(object oTarget)
{
	int nPower;
    effect eLook = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eLook))
    {
    	int nSpellLvl = PRCGetSpellLevelForClass(GetEffectSpellId(eLook), CLASS_TYPE_INVALID);
		if (nSpellLvl > nPower) nPower = nSpellLvl;

      	eLook = GetNextEffect(oTarget);
    }	
	
    return nPower;
}

void DetectMagicAura(int nRound, location lLoc, int nBeamVFX, float fDist)
{
    object oCaster = OBJECT_SELF;
    int nSpellID = GetSpellId();

    if(!GetHasSpellEffect(nSpellID, oCaster))
        return;

    //if concentration is broken, abort
    if(GetBreakConcentrationCheck(oCaster) && nRound != 0)
    {
        FloatingTextStringOnCreature(GetStringByStrRef(16832000)/*"Concentration broken."*/, oCaster, FALSE);
        PRCRemoveEffectsFromSpell(oCaster, nSpellID);
        return;
    }

    location lNew = GetLocation(oCaster);

    //if you move/turn, restart the process / abort if moved more than 2 m
    if(lLoc != lNew)
    {
        if(GetDistanceBetweenLocations(lLoc, lNew) > 2.0)
        {
            PRCRemoveEffectsFromSpell(oCaster, nSpellID);
            FloatingTextStringOnCreature("You have moved too far, ending Detection", oCaster, FALSE);
            return;
        }
        else
            nRound = 1;
    }
    if(nRound < 0)
        nRound = 1;
    //sanity check
    if(nRound > 4)
        nRound = 4;

    // Generate a target location in front of us.
    float fFacing = GetFacing(oCaster);
    vector vPos = GetPosition(oCaster);
    location lTarget = Location(GetArea(oCaster),
                       Vector(vPos.x + cos(fFacing), vPos.y + sin(fFacing), vPos.z),
                       fFacing);

    object oTest = GetFirstObjectInShape(SHAPE_SPELLCONE, fDist, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    int nStrongestAura;
    int nAuraCount;
    while(GetIsObjectValid(oTest))
    {
        if(DEBUG) DoDebug("DetectMagicAura() : Round = "+IntToString(nRound)+"from "+GetName(oCaster)+" of "+GetName(oTest));

		// You cannot be detected if this is true
        if(!GetIsUndetectable(oTest, oCaster))
        {
            if(nRound == 1)
            {
                FloatingTextStringOnCreature("You detect the presence of magic.", oCaster, FALSE);
                break;//end while loop
            }

            int nStrength;
            int nRawStrength = GetMagicAuraStrength(oTest);

            if(nRawStrength == 0)
                nStrength = AURA_STRENGTH_DIM;
            else if(nRawStrength >= 1 && nRawStrength <= 3)
                nStrength = AURA_STRENGTH_FAINT;
            else if(nRawStrength >= 4 && nRawStrength <= 6)
                nStrength = AURA_STRENGTH_MODERATE;
            else if(nRawStrength >= 7 && nRawStrength <= 9)
                nStrength = AURA_STRENGTH_STRONG;
            else if(nRawStrength >= 10)
                nStrength = AURA_STRENGTH_OVERWHELMING;

            if(nRound == 2)
            {
                //number & strongest
                nAuraCount++;
                if(nStrength > nStrongestAura)
                    nStrongestAura = nStrength;
            }
            else if(nRound >= 3)
            {
                if(nRound == 3)
                    ActionDoCommand(FloatingTextStringOnCreature(PRCGetRGB(15,16-(nStrength*3),16-(nStrength*3)) + GetName(oTest) + " feels affected by "+GetNounForStrength(nStrength)+" magic.", oCaster, FALSE));
                //strength & location
                ActionDoCommand(ApplyEffectDetectAuraOnObject(nStrength, oTest, nBeamVFX));
            }
        }
        oTest = GetNextObjectInShape(SHAPE_SPELLCONE, fDist, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    }
    if(nRound == 2)
    {
        //reporting
        //ApplyEffectDetectAuraOnObject(nStrongestAura, oCaster, nBeamVFX);
        FloatingTextStringOnCreature(PRCGetRGB(15,16-(nStrongestAura*3),16-(nStrongestAura*3)) + GetStringByStrRef(16832045)/*"You detected"*/ + " " + IntToString(nAuraCount) + " " + GetNounForStrength(nStrongestAura) + " magical " + GetStringByStrRef(16832046)/*"auras"*/ + ".", oCaster, FALSE);
    }

    //ActionPlayAnimation(ANIMATION_LOOPING_MEDITATE, 1.0, 6.0);
    nRound++;

    DelayCommand(6.0f, ActionDoCommand(DetectMagicAura(nRound, lNew, nBeamVFX, fDist)));
}

void DetectRaceAura(int nRound, int nRace, location lLoc, int nBeamVFX, float fDist)
{
    object oCaster = OBJECT_SELF;
    int nSpellID = GetSpellId();

    if(!GetHasSpellEffect(nSpellID, oCaster))
        return;

    //if concentration is broken, abort
    if(GetBreakConcentrationCheck(oCaster) && nRound != 0)
    {
        FloatingTextStringOnCreature(GetStringByStrRef(16832000)/*"Concentration broken."*/, oCaster, FALSE);
        PRCRemoveEffectsFromSpell(oCaster, nSpellID);
        return;
    }

    location lNew = GetLocation(oCaster);

    //if you move/turn, restart the process / abort if moved more than 2 m
    if(lLoc != lNew)
    {
        if(GetDistanceBetweenLocations(lLoc, lNew) > 2.0)
        {
            PRCRemoveEffectsFromSpell(oCaster, nSpellID);
            FloatingTextStringOnCreature("You have moved too far, ending Detection", oCaster, FALSE);
            return;
        }
        else
            nRound = 1;
    }
    if(nRound < 0)
        nRound = 1;
    //sanity check
    if(nRound > 4)
        nRound = 4;

    // Generate a target location in front of us.
    float fFacing = GetFacing(oCaster);
    vector vPos = GetPosition(oCaster);
    location lTarget = Location(GetArea(oCaster),
                       Vector(vPos.x + cos(fFacing), vPos.y + sin(fFacing), vPos.z),
                       fFacing);

    object oTest = GetFirstObjectInShape(SHAPE_SPELLCONE, fDist, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    int nStrongestAura;
    int nAuraCount;
    while(GetIsObjectValid(oTest))
    {
        if(DEBUG) DoDebug("DetectMagicAura() : Round = "+IntToString(nRound)+"from "+GetName(oCaster)+" of "+GetName(oTest));

		// You cannot be detected if this is true
        if(!GetIsUndetectable(oTest, oCaster) && GetObjectType(oTest) == OBJECT_TYPE_CREATURE)
        {
            if(nRound == 1)
            {
                FloatingTextStringOnCreature("You detect the presence of the chosen race.", oCaster, FALSE);
                break;//end while loop
            }

            int nStrength, nRawStrength;
            int nCheck = MyPRCGetRacialType(oTest);
            // Detect Living is -1
    		if(nRace == nCheck || (nRace == -1 && PRCGetIsAliveCreature(oTest)))
        		nRawStrength = GetHitDice(oTest);            

            if(nRawStrength >= 0 && nRawStrength <= 1)
                nStrength = AURA_STRENGTH_FAINT;
            else if(nRawStrength >= 2 && nRawStrength <= 4)
                nStrength = AURA_STRENGTH_MODERATE;
            else if(nRawStrength >= 5 && nRawStrength <= 10)
                nStrength = AURA_STRENGTH_STRONG;
            else if(nRawStrength >= 11)
                nStrength = AURA_STRENGTH_OVERWHELMING;

            if(nRound == 2)
            {
                //number & strongest
                nAuraCount++;
                if(nStrength > nStrongestAura)
                    nStrongestAura = nStrength;
            }
            else if(nRound >= 3)
            {
                if(nRound == 3)
                    ActionDoCommand(FloatingTextStringOnCreature(PRCGetRGB(15,16-(nStrength*3),16-(nStrength*3)) + GetName(oTest) + " finds the greatest aura is "+GetNounForStrength(nStrength)+".", oCaster, FALSE));
                //strength & location
                ActionDoCommand(ApplyEffectDetectAuraOnObject(nStrength, oTest, nBeamVFX));
            }
        }
        oTest = GetNextObjectInShape(SHAPE_SPELLCONE, fDist, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    }
    if(nRound == 2)
    {
        //reporting
        //ApplyEffectDetectAuraOnObject(nStrongestAura, oCaster, nBeamVFX);
        FloatingTextStringOnCreature(PRCGetRGB(15,16-(nStrongestAura*3),16-(nStrongestAura*3)) + GetStringByStrRef(16832045)/*"You detected"*/ + " " + IntToString(nAuraCount) + " " + GetNounForStrength(nStrongestAura) + " racial " + GetStringByStrRef(16832046)/*"auras"*/ + ".", oCaster, FALSE);
    }

    //ActionPlayAnimation(ANIMATION_LOOPING_MEDITATE, 1.0, 6.0);
    nRound++;

    DelayCommand(6.0f, ActionDoCommand(DetectRaceAura(nRound, nRace, lNew, nBeamVFX, fDist)));
}