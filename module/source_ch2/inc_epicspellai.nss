
/*
for reference
SpellRngPers       0
SpellRngTouch      2.25
SpellRngShrt       8
SpellRngMed        20
SpellRngLng        40
*/

void DoEpicSpellcasterSpawn();
int DoEpicSpells();
int TestConditions(int nSpellID);
object GetSuitableTaget(int nSpellID);
void MakeEpicSpellsKnownAIList();

#include "inc_epicspells"
//#include "inc_epicspelldef"
//#include "inc_epicspellfnc"
#include "inc_utility"

//returns True if it casts something
int DoEpicSpells()
{
    //checks for able to cast anything epic
    if(!GetIsEpicSpellcaster(OBJECT_SELF))
        return FALSE;
    if(GetSpellSlots(OBJECT_SELF) < 1)
        return FALSE;

//    DoDebug("Checking for EpicSpells");
    int nSpellID;
    int bTest;
    int i;
    object oTarget;

    //sanity test
    if(!array_exists(OBJECT_SELF,"AI_KnownEpicSpells"))
    {
        if(DEBUG) DoDebug("ERROR: DoEpicSpells: AI_KnownEpicSpells array does not exist, creating");
        MakeEpicSpellsKnownAIList();
    }
    //do specific conditon tests first
    //non implemented at moment
    //test all spells in known spell array setup on spawn
    for(i=0; i<array_get_size(OBJECT_SELF,"AI_KnownEpicSpells");i++)
    {
        nSpellID = array_get_int(OBJECT_SELF,"AI_KnownEpicSpells", i);
        oTarget = GetSuitableTaget(nSpellID);
        if(GetIsObjectValid(oTarget)
            && TestConditions(nSpellID)
            && GetCanCastSpell(OBJECT_SELF, nSpellID))
        {
            ClearAllActions();
            int nRealSpellID = StringToInt(Get2DACache("feats", "SpellID",
                StringToInt(Get2DACache("EpicSpells", "SpellFeatID", nSpellID))));
            ActionCastSpellAtObject(nRealSpellID,oTarget, METAMAGIC_NONE, TRUE);
            return TRUE;
        }
    }
    //if no epic spell can be cast, go through normal tests
    return FALSE;
}

int TestConditions(int nSpellID)
{
    int i;
    float fDist;
    switch(nSpellID)
    {
        //personal buffs have no extra checks
        //gethasspelleffect is automatically done
        case SPELL_EPIC_ACHHEEL:
        case SPELL_EPIC_EP_WARD:
        case SPELL_EPIC_WHIP_SH:
        case SPELL_EPIC_CON_RES:
            return TRUE;
            break;
        //not sure what or how to test at the moment
        case SPELL_EPIC_ARMY_UN:
        case SPELL_EPIC_PATHS_B:
        case SPELL_EPIC_GEMCAGE:
            return FALSE;
            break;
        //timestop checks if already cast
        case SPELL_EPIC_GR_TIME:
            if(GetHasSpellEffect(
                StringToInt(Get2DACache("feats", "SpellID",
                    StringToInt(Get2DACache("EpicSpells", "SpellFeatID", nSpellID)))
                    ))
                )
                return FALSE;
            else
                return TRUE;
            break;
        //summons check if a summon already exists
        case SPELL_EPIC_UNHOLYD:
        case SPELL_EPIC_SUMABER:
        case SPELL_EPIC_TWINF:
        case SPELL_EPIC_MUMDUST:
        case SPELL_EPIC_DRG_KNI:
            if(GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_SUMMONED))
                && !GetPRCSwitch(PRC_MULTISUMMON))
                return FALSE;
            else
                return TRUE;
            break;
        //leechfield checks if enemy undead nearby (25m)
        case SPELL_EPIC_LEECH_F:
            fDist = GetDistanceToObject(GetNearestCreature(CREATURE_TYPE_REPUTATION,
                REPUTATION_TYPE_ENEMY,OBJECT_SELF, 1, CREATURE_TYPE_RACIAL_TYPE,
                RACIAL_TYPE_UNDEAD));
            if(fDist == -1.0 || fDist > 25.0)
                return TRUE;
            else
                return FALSE;
        //Order Restored is alignment sensitive. Only castable by lawful
        case SPELL_EPIC_ORDER_R:
            if(GetAlignmentLawChaos(OBJECT_SELF) == ALIGNMENT_LAWFUL
                && GetAlignmentLawChaos(GetNearestCreature(
                    CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY)) == ALIGNMENT_CHAOTIC)
                return TRUE;
            else
                return FALSE;

        //Anarchy's Call is alignment sensitive. Only castable by Chaotic
        case SPELL_EPIC_ANARCHY:
            if(GetAlignmentLawChaos(OBJECT_SELF) == ALIGNMENT_CHAOTIC
                && GetAlignmentLawChaos(GetNearestCreature(
                    CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY)) == ALIGNMENT_LAWFUL)
                return TRUE;
            else
                return FALSE;
        //touchbuffs pass automatically because of target selection checks
        case SPELL_EPIC_HERCALL:
        case SPELL_EPIC_CHAMP_V:
        case SPELL_EPIC_DEADEYE:
        case SPELL_EPIC_DULBLAD:
        case SPELL_EPIC_EP_M_AR:
        case SPELL_EPIC_EP_SP_R:
        case SPELL_EPIC_ET_FREE:
        case SPELL_EPIC_FLEETNS:
        case SPELL_EPIC_GR_SP_RE:
        case SPELL_EPIC_HERCEMP:
        case SPELL_EPIC_IMPENET:
        case SPELL_EPIC_TRANVIT:
        case SPELL_EPIC_UNIMPIN:
        case SPELL_EPIC_AL_MART:
            return TRUE;
            break;
        //single hostile spells
        case SPELL_EPIC_GR_RUIN:
        case SPELL_EPIC_RUINN:
        case SPELL_EPIC_GODSMIT:
        case SPELL_EPIC_NAILSKY:
        case SPELL_EPIC_ENSLAVE:
        case SPELL_EPIC_MORI:
        case SPELL_EPIC_THEWITH:
        case SPELL_EPIC_PSION_S:
        case SPELL_EPIC_DWEO_TH:
        case SPELL_EPIC_SP_WORM:
        case SPELL_EPIC_SINGSUN:
            return TRUE;
            break;

        //aoe hostile spells
        case SPELL_EPIC_ANBLAST:
        case SPELL_EPIC_ANBLIZZ:
        case SPELL_EPIC_A_STONE:
        case SPELL_EPIC_MASSPEN:
        case SPELL_EPIC_HELBALL:
        case SPELL_EPIC_MAGMA_B:
        case SPELL_EPIC_TOLO_KW:
            return TRUE;
            break;

        //fail spells that tha AI cant work with anyway
        case SPELL_EPIC_CELCOUN:
        case SPELL_EPIC_CON_REU:
        case SPELL_EPIC_DREAMSC:
        case SPELL_EPIC_EP_RPLS:
        case SPELL_EPIC_FIEND_W:
        case SPELL_EPIC_HELSEND:
        case SPELL_EPIC_LEG_ART:
        case SPELL_EPIC_PIOUS_P:
        case SPELL_EPIC_PLANCEL:
        case SPELL_EPIC_RISEN_R:
        case SPELL_EPIC_UNSEENW:
            return FALSE;

        //fail spells that dont work at the moment
        case SPELL_EPIC_BATTLEB:
        case SPELL_EPIC_DTHMARK:
//        case SPELL_EPIC_HELSEND:
//        case SPELL_EPIC_EP_RPLS:
//        case SPELL_EPIC_LEG_ART:
        case SPELL_EPIC_LIFE_FT:
        case SPELL_EPIC_NIGHTSU:
        case SPELL_EPIC_PEERPEN:
//        case SPELL_EPIC_RISEN_R:
        case SPELL_EPIC_SYMRUST:
            return FALSE;
    }
    return FALSE;
}
object GetSuitableTaget(int nSpellID)
{
    object oTarget;
    object oTest;
    int i;
    float fDist;
    int nRealSpellID = StringToInt(Get2DACache("feats", "SpellID",
        StringToInt(Get2DACache("EpicSpells", "SpellFeatID", nSpellID))));
    switch(nSpellID)
    {
        //personal spells always target self
        case SPELL_EPIC_ACHHEEL:
        case SPELL_EPIC_ALLHOPE:
        case SPELL_EPIC_ANARCHY:
        case SPELL_EPIC_ARMY_UN:
        case SPELL_EPIC_BATTLEB:
        case SPELL_EPIC_CELCOUN:
        case SPELL_EPIC_DIREWIN:
        case SPELL_EPIC_DREAMSC:
        case SPELL_EPIC_EP_WARD:
        case SPELL_EPIC_FIEND_W:
        case SPELL_EPIC_GR_TIME:
        case SPELL_EPIC_HELSEND:
        case SPELL_EPIC_LEG_ART:
        case SPELL_EPIC_ORDER_R:
        case SPELL_EPIC_PATHS_B:
        case SPELL_EPIC_PEERPEN:
        case SPELL_EPIC_PESTIL:
        case SPELL_EPIC_PIOUS_P:
        case SPELL_EPIC_RAINFIR:
        case SPELL_EPIC_RISEN_R:
        case SPELL_EPIC_WHIP_SH:
            return OBJECT_SELF;
            break;
        //summons target nearest enemy, or self if enemies over short range
        case SPELL_EPIC_UNHOLYD:
        case SPELL_EPIC_SUMABER:
        case SPELL_EPIC_TWINF:
        case SPELL_EPIC_MUMDUST:
        case SPELL_EPIC_DRG_KNI:
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                REPUTATION_TYPE_ENEMY,OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
            if(GetDistanceToObject(oTarget) > RADIUS_SIZE_SMALL)//assuming radius size is the same as range
                return OBJECT_SELF;
            else
                return oTarget;
            break;
        //touchbuffs target self, or nearest ally without the effect
        //maximum 5m distance, dont want to wander too far
        //will separate those best cast on others laters
        case SPELL_EPIC_HERCALL:
        case SPELL_EPIC_CHAMP_V:
        case SPELL_EPIC_DEADEYE:
        case SPELL_EPIC_DULBLAD:
        case SPELL_EPIC_EP_M_AR:
        case SPELL_EPIC_EP_RPLS:
        case SPELL_EPIC_EP_SP_R:
        case SPELL_EPIC_ET_FREE:
        case SPELL_EPIC_FLEETNS:
        case SPELL_EPIC_GR_SP_RE:
        case SPELL_EPIC_HERCEMP:
        case SPELL_EPIC_IMPENET:
        case SPELL_EPIC_TRANVIT:
        case SPELL_EPIC_UNIMPIN:
        case SPELL_EPIC_UNSEENW:
        case SPELL_EPIC_CON_RES:
            fDist = 5.0;
            if(!GetHasSpellEffect(nRealSpellID))
                return OBJECT_SELF;
            else
            {
                oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                    REPUTATION_TYPE_FRIEND,OBJECT_SELF, i);
                while(!GetHasSpellEffect(nRealSpellID, oTarget)
                    && GetDistanceToObject(oTarget) < fDist
                    && i < 10)
                {
                    i++;
                    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                        REPUTATION_TYPE_FRIEND,OBJECT_SELF, i);
                }
                if(GetDistanceToObject(oTarget) >= fDist
                    || i >= 10)
                    return OBJECT_INVALID; //no suitable targets
                else
                    return oTarget;
            }
            break;

        case SPELL_EPIC_AL_MART:
            fDist = 5.0;
                oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                    REPUTATION_TYPE_FRIEND,OBJECT_SELF, i);
                while(!GetHasSpellEffect(nRealSpellID, oTarget)
                    && GetCurrentHitPoints(oTarget) > GetCurrentHitPoints(OBJECT_SELF)
                    && GetDistanceToObject(oTarget) < fDist
                    && i < 10)
                {
                    i++;
                    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                        REPUTATION_TYPE_FRIEND,OBJECT_SELF, i);
                }
                if(GetDistanceToObject(oTarget) >= fDist
                    || i >= 10)
                    return OBJECT_INVALID; //no suitable targets
                else
                {
                    oTest = GetLocalObject(OBJECT_SELF, "oAILastMart");
                    if(GetIsObjectValid(oTest)
                        && !GetIsDead(oTest)
                        && GetCurrentHitPoints(oTest) > GetMaxHitPoints(oTest)/10)
                        return OBJECT_INVALID;
                    return oTarget;
                }
            break;
        //hostile spells
        //area effect descriminants
        case SPELL_EPIC_ANBLAST:
            fDist = 40.0;
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                    REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                while(GetCurrentHitPoints(oTarget) > 35
                    && GetDistanceToObject(oTarget) < fDist
                    && i < 10)
                {
                    i++;
                    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                        REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                }
                if(GetDistanceToObject(oTarget) >= fDist
                    || i >= 10)
                    return OBJECT_INVALID; //no suitable targets
                else
                    return oTarget;
                break;
        case SPELL_EPIC_ANBLIZZ:
            fDist = 40.0;
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                    REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                while(GetCurrentHitPoints(oTarget) > 70
                    && GetDistanceToObject(oTarget) < fDist
                    && i < 10)
                {
                    i++;
                    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                        REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                }
                if(GetDistanceToObject(oTarget) >= fDist
                    || i >= 10)
                    return OBJECT_INVALID; //no suitable targets
                else
                    return oTarget;
                break;
        case SPELL_EPIC_A_STONE:
            fDist = 20.0;
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                    REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                while(GetFortitudeSavingThrow(oTarget)+10 >
                        GetEpicSpellSaveDC(OBJECT_SELF, oTarget, nSpellID)
                    && GetDistanceToObject(oTarget) < fDist
                    && i < 10)
                {
                    i++;
                    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                        REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                }
                if(GetDistanceToObject(oTarget) >= fDist
                    || i >= 10)
                    return OBJECT_INVALID; //no suitable targets
                else
                    return oTarget;
                break;

        case SPELL_EPIC_MASSPEN:
            fDist = 40.0;
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                    REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                while(GetFortitudeSavingThrow(oTarget)+10 >
                        GetEpicSpellSaveDC(OBJECT_SELF, oTarget, nSpellID)
                    && GetDistanceToObject(oTarget) < fDist
                    && i < 10)
                {
                    i++;
                    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                        REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                }
                if(GetDistanceToObject(oTarget) > fDist
                    || i >= 10)
                    return OBJECT_INVALID;
                else
                    return oTarget; //no suitable targets
                break;
        //singe target
        case SPELL_EPIC_ENSLAVE:
            fDist = 80.0;
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                    REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                while(GetWillSavingThrow(oTarget)+10 >
                        GetEpicSpellSaveDC(OBJECT_SELF, oTarget, nSpellID)
                    && GetDistanceToObject(oTarget) < fDist
                    && i < 10)
                {
                    i++;
                    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                        REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                }
                if(GetDistanceToObject(oTarget) > fDist
                    || i >= 10)
                    return OBJECT_INVALID;
                else
                    return oTarget; //no suitable targets
                break;
        case SPELL_EPIC_NAILSKY:
            fDist = 20.0;
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                    REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                while(GetWillSavingThrow(oTarget)+10 >
                        GetEpicSpellSaveDC(OBJECT_SELF, oTarget, nSpellID)
                    && GetDistanceToObject(oTarget) < fDist
                    && i < 10)
                {
                    i++;
                    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                        REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                }
                if(GetDistanceToObject(oTarget) > fDist
                    || i >= 10)
                    return OBJECT_INVALID;
                else
                    return oTarget; //no suitable targets
                break;
        case SPELL_EPIC_GR_RUIN:
        case SPELL_EPIC_RUINN:
        case SPELL_EPIC_DTHMARK:
        case SPELL_EPIC_GODSMIT:
        case SPELL_EPIC_SINGSUN:
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                REPUTATION_TYPE_ENEMY,OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
            return oTarget;
            break;

        //area effect indescriminants
        case SPELL_EPIC_HELBALL:
        case SPELL_EPIC_MAGMA_B:
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                REPUTATION_TYPE_ENEMY,OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
            return oTarget;
            break;

        case SPELL_EPIC_LEECH_F:
            fDist = 40.0;
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                    REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                while(GetWillSavingThrow(oTarget)+10 >
                        GetEpicSpellSaveDC(OBJECT_SELF, oTarget, nSpellID)
                    && GetDistanceToObject(oTarget) < fDist
                    && GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD
                    && i < 10)
                {
                    i++;
                    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                        REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                }
                if(GetDistanceToObject(oTarget) > fDist
                    || i >= 10)
                    return OBJECT_INVALID;
                else
                    return oTarget; //no suitable targets
                break;
        //check to not target those immune to insta-death
        case SPELL_EPIC_TOLO_KW:
            fDist = 40.0;
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                    REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                while(GetIsImmune(oTarget,IMMUNITY_TYPE_DEATH)
                    && GetDistanceToObject(oTarget) < fDist
                    && i < 10)
                {
                    i++;
                    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                        REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                }
                if(GetDistanceToObject(oTarget) >= fDist
                    || i >= 10)
                    return OBJECT_INVALID; //no suitable targets
                else
                    return oTarget;
                break;
        case SPELL_EPIC_MORI:
            fDist = 20.0;
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                    REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                while(GetIsImmune(oTarget,IMMUNITY_TYPE_DEATH)
                    && GetDistanceToObject(oTarget) < fDist
                    && i < 10)
                {
                    i++;
                    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                        REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                }
                if(GetDistanceToObject(oTarget) >= fDist
                    || i >= 10)
                    return OBJECT_INVALID; //no suitable targets
                else
                    return oTarget;
            break;
        //check to not target those immune to ability lowering
        case SPELL_EPIC_THEWITH:
            fDist = 20.0;
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                    REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                while(GetIsImmune(oTarget,IMMUNITY_TYPE_ABILITY_DECREASE)
                    && GetDistanceToObject(oTarget) < fDist
                    && i < 10
                    && GetFortitudeSavingThrow(oTarget)+10 >
                        GetEpicSpellSaveDC(OBJECT_SELF, oTarget, nSpellID))
                {
                    i++;
                    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                        REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                }
                if(GetDistanceToObject(oTarget) > fDist
                    || i >= 10)
                    return OBJECT_INVALID;
                else
                    return oTarget; //no suitable targets
            break;
            //aslo willcheck
        case SPELL_EPIC_PSION_S:
            fDist = 20.0;
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                    REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                while(GetIsImmune(oTarget,IMMUNITY_TYPE_ABILITY_DECREASE)
                    && GetDistanceToObject(oTarget) < fDist
                    && i < 10
                    && GetWillSavingThrow(oTarget)+10 >
                        GetEpicSpellSaveDC(OBJECT_SELF, oTarget, nSpellID))
                {
                    i++;
                    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                        REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                }
                if(GetDistanceToObject(oTarget) > fDist
                    || i >= 10)
                    return OBJECT_INVALID;
                else
                    return oTarget; //no suitable targets
            break;
        //target spellcasters
        //just gets last spellcaster
        //or those with classes in spellcasting
        case SPELL_EPIC_DWEO_TH:
            fDist = 20.0;

            oTarget = GetLastSpellCaster();
            if(GetDistanceToObject(oTarget) < fDist
                && i < 10
                && GetIsEnemy(oTarget))
                return oTarget;
            else
            {
                oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                    REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                while(GetLevelByClass(CLASS_TYPE_CLERIC) ==0
                    && GetLevelByClass(CLASS_TYPE_DRUID) ==0
                    && GetLevelByClass(CLASS_TYPE_WIZARD) ==0
                    && GetLevelByClass(CLASS_TYPE_SORCERER) ==0
                    && GetDistanceToObject(oTarget) < fDist
                    && i < 10)
                {
                    i++;
                    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                        REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                }
                if(GetDistanceToObject(oTarget) > fDist
                    || i >= 10)
                    return OBJECT_INVALID;  //no suitable targets
                else
                    return oTarget;
            }
            break;
        //target spellcasters
        //just gets last spellcaster
        //or those with classes in spellcasting
        //also checks will fail will test
        case SPELL_EPIC_SP_WORM:
            fDist = 8.0;
            oTarget = GetLastSpellCaster();
            if(GetDistanceToObject(oTarget) < fDist
                && i < 10
                && GetIsEnemy(oTarget)
                && GetWillSavingThrow(oTarget)+10 >
                    GetEpicSpellSaveDC(OBJECT_SELF) +
                        GetEpicSpellSaveDC(OBJECT_SELF, oTarget, nSpellID))
                return oTarget;
            else
            {
                oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                    REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                while(GetLevelByClass(CLASS_TYPE_CLERIC) ==0
                    && GetLevelByClass(CLASS_TYPE_DRUID) ==0
                    && GetLevelByClass(CLASS_TYPE_WIZARD) ==0
                    && GetLevelByClass(CLASS_TYPE_SORCERER) ==0
                    && GetDistanceToObject(oTarget) < fDist
                    && i < 10
                    && GetWillSavingThrow(oTarget)+10 >
                        GetEpicSpellSaveDC(OBJECT_SELF, oTarget, nSpellID))
                {
                    i++;
                    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                        REPUTATION_TYPE_ENEMY,OBJECT_SELF, i);
                }
                if(GetDistanceToObject(oTarget) > fDist
                    || i >= 10)
                    return OBJECT_INVALID;
                else
                    return oTarget; //no suitable targets
            }
            break;

    }
    return OBJECT_INVALID;
}

void DoEpicSpellcasterSpawn()
{
    //checks for able to cast anything epic
    if(!GetIsEpicSpellcaster(OBJECT_SELF))
        return;
    int nLevel = GetHitDice(OBJECT_SELF);
    //give pseudoXP if not already given
    if(!GetXP(OBJECT_SELF))
    {
        int nXP =(nLevel*(nLevel-1))*500;
        nXP = nXP + FloatToInt(IntToFloat(nLevel)*1000.0*((IntToFloat(Random(51))+25.0)/100.0));
        SetXP(OBJECT_SELF, nXP);
    }
    //fill slots
    ReplenishSlots(OBJECT_SELF);
    //TEMP
    //This stuff gives them some Epic Spells for free
    if(!GetCastableFeatCount(OBJECT_SELF))
    {
        int nSlots = GetEpicSpellSlotLimit(OBJECT_SELF)+3;
        int i;
        for(i=0;i<nSlots;i++)
        {
            GiveFeat(OBJECT_SELF, Random(71)+429);
        }
    }
    //setup AI list
    DelayCommand(1.0, ActionDoCommand(MakeEpicSpellsKnownAIList()));
}

void MakeEpicSpellsKnownAIList()
{
//    DoDebug("Building EpicSpells Known list");
    int nTemp;
    int nHighestDC;
    int nHighestDCID;
    int j;
    int i;
    array_create(OBJECT_SELF, "AI_KnownEpicSpells");
    //record what spells in an array
//    array_create(OBJECT_SELF, "AI_KnownEpicSpells");
    string sLabel = Get2DACache("epicspellseeds", "LABEL", i);
    while(sLabel != "")
    {
        if(GetHasFeat(GetFeatForSpell(i)))
        {
            array_set_int(OBJECT_SELF, "AI_KnownEpicSpells",array_get_size(OBJECT_SELF, "AI_KnownEpicSpells") ,i);
        }
        i++;
        sLabel = Get2DACache("epicspellseeds", "LABEL", i);
    }
//    DoDebug("Finished recording known spells");
    //sort spells into descending DC order
    //move starting point down list
    for (j=0;j<array_get_size(OBJECT_SELF, "AI_KnownEpicSpells");j++)
    {
        //for each start get the first spells DC + position
        nHighestDC = GetDCForSpell(array_get_int(OBJECT_SELF, "AI_KnownEpicSpells",j));
        nHighestDCID = j;
        //check each spell lower on the list for higher DC
        for (i=j;i<array_get_size(OBJECT_SELF, "AI_KnownEpicSpells");i++)
        {
            //if so, mark highest to that spell
            if(GetDCForSpell(array_get_int(OBJECT_SELF, "AI_KnownEpicSpells",i)) > nHighestDC)
            {
                nHighestDC = GetDCForSpell(array_get_int(OBJECT_SELF, "AI_KnownEpicSpells",i));
                nHighestDCID = i;
            }
        }
        //once you have checked all spells lower, swap the top one with the highest DC
        nTemp = array_get_int(OBJECT_SELF, "AI_KnownEpicSpells",j);
        array_set_int(OBJECT_SELF, "AI_KnownEpicSpells",j,array_get_int(OBJECT_SELF, "AI_KnownEpicSpells",nHighestDCID));
        array_set_int(OBJECT_SELF, "AI_KnownEpicSpells",nHighestDCID, nTemp);
    }
//    DoDebug("Finished sorting known spells");
}

// Test main
//void main(){}
