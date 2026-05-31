#include "x2_inc_switches"
#include "prc_inc_teleport"
#include "prc_inc_leadersh"
#include "prc_inc_domain"
#include "prc_inc_shifting"
#include "true_inc_trufunc"
#include "prc_craft_inc"
#include "prc_inc_dragsham"
#include "shd_inc_myst"
#include "prc_inc_template"

/**
 * Reads the 2da file onenter_locals.2da and sets local variables
 * on the entering PC accordingly. 2da format same as personal_switches.2da,
 * see prc_inc_switches header comment for details.
 *
 * @param oPC The PC that just entered the module
 */
void DoAutoLocals(object oPC)
{
    int i = 0;
    string sSwitchName, sSwitchType, sSwitchValue;
    // Use Get2DAString() instead of Get2DACache() to avoid caching.
    while((sSwitchName = Get2DAString("onenter_locals", "SwitchName", i)) != "")
    {
        // Read rest of the line
        sSwitchType  = Get2DAString("onenter_locals", "SwitchType",  i);
        sSwitchValue = Get2DAString("onenter_locals", "SwitchValue", i);

        // Determine switch type and set the var
        if     (sSwitchType == "float")
            SetLocalFloat(oPC, sSwitchName, StringToFloat(sSwitchValue));
        else if(sSwitchType == "int")
            SetLocalInt(oPC, sSwitchName, StringToInt(sSwitchValue));
        else if(sSwitchType == "string")
            SetLocalString(oPC, sSwitchName, sSwitchValue);

        // Increment loop counter
        i += 1;
    }
}

//Restore appearance
void RestoreAppearance(object oCreature)
{
    if(!RestoreTrueAppearance(oCreature) && DEBUG)
        DoDebug("prc_onenter: RestoreAppearance failed");
}

void CopyAMSArray(object oHideToken, object oAMSToken, int nClass, string sArray, int nMin, int nMax, int nLoopSize = 100)
{
    int i = nMin;
    while(i < nMin + nLoopSize && i < nMax)
    {
        int nSpell = array_get_int(oAMSToken, sArray, i);
        int nSpellbookID = RealSpellToSpellbookID(nClass, nSpell);
        if(nSpellbookID)
            array_set_int(oHideToken, sArray, i, nSpellbookID);
        i++;
    }
    if(i < nMax)
        DelayCommand(0.0, CopyAMSArray(oHideToken, oAMSToken, nClass, sArray, i, nMax));
}

void DoRestoreAMS(object oPC, int nClass, object oHideToken, object oAMSToken)
{
    string sSpellbook;
    int nSpellbookType = GetSpellbookTypeForClass(nClass);
    if(nSpellbookType == SPELLBOOK_TYPE_SPONTANEOUS)
    {
        sSpellbook = "Spellbook"+IntToString(nClass);
        if(DEBUG) DoDebug("DoRestoreAMS: "+sSpellbook);
        if(persistant_array_exists(oPC, sSpellbook))
            array_delete(oHideToken, sSpellbook);
        array_create(oHideToken, sSpellbook);
        int nSize = array_get_size(oAMSToken, sSpellbook);
        if(DEBUG) DoDebug("DoRestoreAMS: array size = "+IntToString(nSize));
        if(nSize)
            DelayCommand(0.0, CopyAMSArray(oHideToken, oAMSToken, nClass, sSpellbook, 0, nSize));
    }
    else if(nSpellbookType == SPELLBOOK_TYPE_PREPARED)
    {
        int i;
        for(i = 0; i <= 9; i++)
        {
            sSpellbook = "Spellbook_Known_"+IntToString(nClass)+"_"+IntToString(i);
            if(DEBUG) DoDebug("DoRestoreAMS: "+sSpellbook);
            if(array_exists(oHideToken, sSpellbook))
                array_delete(oHideToken, sSpellbook);
            array_create(oHideToken, sSpellbook);
            int nSize = array_get_size(oAMSToken, sSpellbook);
            if(DEBUG) DoDebug("DoRestoreAMS: array size = "+IntToString(nSize));
            if(nSize)
                DelayCommand(0.0, CopyAMSArray(oHideToken, oAMSToken, nClass, sSpellbook, 0, nSize));
            array_delete(oHideToken, "Spellbook"+IntToString(i)+"_"+IntToString(nClass));
            array_delete(oHideToken, "NewSpellbookMem_"+IntToString(nClass));
        }
    }
}

void OnEnter_AMSCompatibilityCheck(object oPC)
{
    object oAMSToken = GetHideToken(oPC, TRUE);
    object oHideToken = GetHideToken(oPC);

    //check PRC version
    string sVersion = GetLocalString(oAMSToken, "ams_version");
    //DoDebug("AMS version = "+sVersion);
    if(sVersion != AMS_VERSION)
    {
        SetLocalInt(oPC, "AMS_RESTORE", 1);
        int i;
        for(i = 1; i <= 8; i++)
        {
            int nClass = GetClassByPosition(i, oPC);
            DelayCommand(0.2, DoRestoreAMS(oPC, nClass, oHideToken, oAMSToken));
        }
        DelayCommand(2.0, WipeSpellbookHideFeats(oPC));
        SetLocalString(oAMSToken, "ams_version", AMS_VERSION);
        DelayCommand(5.0, DeleteLocalInt(oPC, "AMS_RESTORE"));
    }
}

void main()
{
    //The composite properties system gets confused when an exported
    //character re-enters.  Local Variables are lost and most properties
    //get re-added, sometimes resulting in larger than normal bonuses.
    //The only real solution is to wipe the skin on entry.  This will
    //mess up the lich, but only until I hook it into the EvalPRC event -
    //hopefully in the next update
    //  -Aaon Graywolf
    object oPC = GetEnteringObject();

    //FloatingTextStringOnCreature("PRC on enter was called", oPC, FALSE);

    // Since OnEnter event fires for the PC when loading a saved game (no idea why,
    // since it makes saving and reloading change the state of the module),
    // make sure that the event gets run only once
    // but not in MP games, so check if it's single player or not!!
    if(GetLocalInt(oPC, "PRC_ModuleOnEnterDone") && (GetPCPublicCDKey(oPC) == ""))
        return;
    // Use a local integer to mark the event as done for the PC, so that it gets
    // cleared when the character is saved.
    else
        SetLocalInt(oPC, "PRC_ModuleOnEnterDone", TRUE);

    //if server is loading, boot player
    if(GetLocalInt(GetModule(), PRC_PW_LOGON_DELAY+"_TIMER"))
    {
        BootPC(oPC);
        return;
    }

    DoDebug("Running modified prc_onenter with PW CD check");
    // Verify players CD key
    if(GetPRCSwitch(PRC_PW_SECURITY_CD_CHECK))
    {
        DoDebug("PRC_PW_SECURITY_CD_CHECK switch set on the module");
        if(ExecuteScriptAndReturnInt("prc_onenter_cd", oPC))
            return;
    }
    DoDebug("CD-check OK - continue executing prc_onenter");


    // Prevent Items on area creation from trigering the GetPCSkin script
    if (GetObjectType(oPC) != OBJECT_TYPE_CREATURE)
        return;

    // return here for DMs as they don't need all this stuff
    if(GetIsDM(oPC))
        return;

    // Setup class info for EvalPRCFeats()
    SetupCharacterData(oPC);

    // ebonfowl: taking a risk here and commenting this out, it seems obsolete and it is very hard to fix without having an AMS token
    //check spellbooks for compatibility with other PRC versions
    //DelayCommand(10.0f, OnEnter_AMSCompatibilityCheck(oPC));

    object oSkin = GetPCSkin(oPC);
    ScrubPCSkin(oPC, oSkin);
    DeletePRCLocalInts(oSkin);

    // Gives people the proper spells from their bonus domains
    // This should run before EvalPRCFeats, because it sets a variable
    DelayCommand(0.0, CheckBonusDomains(oPC));
    // Set the uses per day for domains
    DelayCommand(0.0, BonusDomainRest(oPC));
    // Clear old variables for AMS
    DelayCommand(0.0, ClearLawLocalVars(oPC));
    DelayCommand(0.0, ClearMystLocalVars(oPC));
    DelayCommand(0.0, ClearLegacyUses(oPC));
    DelayCommand(0.0, DeleteLocalInt(oPC, "RestTimer"));

    //remove effects from hides, can stack otherwise
    effect eTest=GetFirstEffect(oPC);

    while (GetIsEffectValid(eTest))
    {
        if(GetEffectSubType(eTest) == SUBTYPE_SUPERNATURAL
            && (GetEffectType(eTest) == EFFECT_TYPE_MOVEMENT_SPEED_DECREASE
                || GetEffectType(eTest) == EFFECT_TYPE_MOVEMENT_SPEED_INCREASE
                //add other types here
                )
            && !GetIsObjectValid(GetEffectCreator(eTest))
            )
            RemoveEffect(oPC, eTest);
        eTest=GetNextEffect(oPC);
    }

    SetLocalInt(oPC,"ONENTER",1);
    // Make sure we reapply any bonuses before the player notices they are gone.
    DelayCommand(0.1, EvalPRCFeats(oPC));
    DelayCommand(0.1, FeatSpecialUsePerDay(oPC));
    // Check to see which special prc requirements (i.e. those that can't be done)
    // through the .2da's, the entering player already meets.
    ExecuteScript("prc_prereq", oPC);
    ExecuteScript("prc_psi_ppoints", oPC);
    if (GetHasFeat(FEAT_VOWOFPOVERTY, oPC) == TRUE)
    {
        ExecuteScript("prc_vop_feats_oe", oPC);
    }

    ResetTouchOfVitality(oPC);
    DelayCommand(0.15, DeleteLocalInt(oPC,"ONENTER"));

    //:: PW tracking starts here
    if(GetPRCSwitch(PRC_PNP_DEATH_ENABLE))
    {
        //cleanup.
        int nStatus = GetPersistantLocalInt(oPC, "STATUS");
        if (nStatus != ALIVE)
            AddEventScript(oPC, EVENT_ONHEARTBEAT, "prc_timer_dying", TRUE, FALSE);
        // Make us fall over if we should be on the floor.
        if (nStatus == BLEEDING || STABLE || DEAD)
            AssignCommand(oPC, DelayCommand(0.03, PlayAnimation(ANIMATION_LOOPING_DEAD_BACK, 1.0, 4.0)));
        // If PRC Death is enabled we require HP tracking too
        SetPRCSwitch(PRC_PW_HP_TRACKING, TRUE);
    }
    if(GetPRCSwitch(PRC_PW_HP_TRACKING))
    {
        // Make sure we actually have stored HP data to read
        if(GetPersistantLocalInt(oPC, "persist_HP_stored") == -1)
        {
            // Read the stored level and set accordingly.
        int nHP = GetPersistantLocalInt(oPC, "persist_HP");
            int nDamage = GetCurrentHitPoints(oPC)-nHP;

            if (nDamage >= 1) ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_MAGICAL), oPC);
        }

    }
    if(GetPRCSwitch(PRC_PW_TIME))
    {
        struct time tTime = GetPersistantLocalTime(oPC, "persist_Time");
            //first pc logging on
        if(GetIsObjectValid(GetFirstPC())
            && !GetIsObjectValid(GetNextPC()))
        {
            SetTimeAndDate(tTime);
        }
        RecalculateTime();
    }
    if(GetPRCSwitch(PRC_PW_LOCATION_TRACKING))
    {
        struct metalocation lLoc = GetPersistantLocalMetalocation(oPC, "persist_loc");
        DelayCommand(6.0, AssignCommand(oPC, JumpToLocation(MetalocationToLocation(lLoc))));
    }
    if(GetPRCSwitch(PRC_PW_MAPPIN_TRACKING)
        && !GetLocalInt(oPC, "PRC_PW_MAPPIN_TRACKING_Done"))
    {
        //this local is set so that this is only done once per server session
        SetLocalInt(oPC, "PRC_PW_MAPPIN_TRACKING_Done", TRUE);
        int nCount = GetPersistantLocalInt(oPC, "MapPinCount");
        int i;
        for(i=1; i<=nCount; i++)
        {
            struct metalocation mlocLoc = GetPersistantLocalMetalocation(oPC, "MapPin_"+IntToString(i));
            CreateMapPinFromMetalocation(mlocLoc, oPC);
        }
    }
    if(GetPRCSwitch(PRC_PW_DEATH_TRACKING))
    {
        if(GetPersistantLocalInt(oPC, "persist_dead"))
        {
            int nDamage=9999;
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(DAMAGE_TYPE_MAGICAL, nDamage), oPC);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oPC);
        }
    }
    if(GetPRCSwitch(PRC_PW_SPELL_TRACKING))
    {
        string sSpellList = GetPersistantLocalString(oPC, "persist_spells");
        string sTest;
        string sChar;
        while(GetStringLength(sSpellList))
        {
            sChar = GetStringLeft(sSpellList,1);
            if(sChar == "|")
            {
                int nSpell = StringToInt(sTest);
                DecrementRemainingSpellUses(oPC, nSpell);
                sTest == "";
            }
            else
                sTest += sChar;
            sSpellList = GetStringRight(sSpellList, GetStringLength(sSpellList)-1);
        }
    }
    //check for persistant golems
    if(persistant_array_exists(oPC, "GolemList"))
    {
        MultisummonPreSummon(oPC, TRUE);
        int i;
        for(i=1;i<persistant_array_get_size(oPC, "GolemList");i++)
        {
            string sResRef = persistant_array_get_string(oPC, "GolemList",i);
            effect eSummon = SupernaturalEffect(EffectSummonCreature(sResRef));
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eSummon, oPC);
        }
    }

    if(GetPRCSwitch(PRC_PNP_ANIMATE_DEAD) || GetPRCSwitch(PRC_MULTISUMMON))
    {
        MultisummonPreSummon(oPC, TRUE);
    }

    // Create map pins from marked teleport locations if the PC has requested that such be done.
    if(GetLocalInt(oPC, PRC_TELEPORT_CREATE_MAP_PINS))
        DelayCommand(10.0f, TeleportLocationsToMapPins(oPC));

    if(GetPRCSwitch(PRC_XP_USE_SIMPLE_RACIAL_HD)
        && !GetXP(oPC))
    {
        int nRealRace = GetRacialType(oPC);
        int nRacialHD = StringToInt(Get2DACache("ECL", "RaceHD", nRealRace));
        int nRacialClass = StringToInt(Get2DACache("ECL", "RaceClass", nRealRace));
        if(nRacialHD)
        {
            if(!GetPRCSwitch(PRC_XP_USE_SIMPLE_RACIAL_HD_NO_FREE_XP))
            {
                int nNewXP = nRacialHD*(nRacialHD+1)*500; //+1 for the original class level
                SetXP(oPC, nNewXP);
                if(GetPRCSwitch(PRC_XP_USE_SIMPLE_LA))
                    DelayCommand(1.0, SetPersistantLocalInt(oPC, sXP_AT_LAST_HEARTBEAT, nNewXP));
            }
            if(GetPRCSwitch(PRC_XP_USE_SIMPLE_RACIAL_HD_NO_SELECTION))
            {
                int i;
                for(i=0;i<nRacialHD;i++)
                {
                    LevelUpHenchman(oPC, nRacialClass, TRUE);
                }
            }
        }
    }

    // Insert various debug things here
    if(DEBUG)
    {
        // Duplicate PRCItemPropertyBonusFeat monitor
        SpawnNewThread("PRC_Duplicate_IPBFeat_Mon", "prc_debug_hfeatm", 30.0f, oPC);
    }

    if(GetHasFeat(FEAT_SPELLFIRE_WIELDER, oPC))
        SpawnNewThread("PRC_Spellfire", "prc_spellfire_hb", 6.0f, oPC);

    //if the player logged off while being registered as a cohort
    if(GetPersistantLocalInt(oPC, "RegisteringAsCohort"))
        AssignCommand(GetModule(), CheckHB(oPC));

    // If the PC logs in shifted, unshift them
    if(GetPersistantLocalInt(oPC, SHIFTER_ISSHIFTED_MARKER))
        UnShift(oPC);
    if(GetPRCSwitch(PRC_ON_ENTER_RESTORE_APPEARANCE))
        DelayCommand(2.0f, RestoreAppearance(oPC));

    // Set up local variables based on a 2da file
    DelayCommand(1.0 ,DoAutoLocals(oPC));

    ExecuteScript("tob_evnt_recover", oPC);

    // This prevents the LA function from eating XP on login
    SetLocalInt(oPC, "PRC_ECL_Delay", TRUE);
    SetPersistantLocalInt(oPC, sXP_AT_LAST_HEARTBEAT, GetXP(oPC));
    DelayCommand(10.0, DeleteLocalInt(oPC, "PRC_ECL_Delay"));

    // Execute scripts hooked to this event for the player triggering it
    //How can this work? The PC isnt a valid object before this. - Primogenitor
    //Some stuff may have gone "When this PC next logs in, run script X" - Ornedan
    ExecuteAllScriptsHookedToEvent(oPC, EVENT_ONCLIENTENTER);

    // Start the PC HeartBeat for PC's
    if(GetIsPC(oPC))
        AssignCommand(GetModule(), ExecuteScript("prc_onhb_indiv", oPC));
}
