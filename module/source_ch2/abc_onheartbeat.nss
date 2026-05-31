// Tracks the heartbeat for each feat
void TrackFeat(int iFeat, string sFeat, int tFeat, int maxFeat, object oPC=OBJECT_SELF);

void main()
{
    //get person
    object oPC = GetFirstPC();

    //get the arcane archer class
    if (GetLevelByClass(CLASS_TYPE_ARCANE_ARCHER, oPC) < 1)
        return;

    int iFeat;
    string sFeat;
    int tFeat;
    int maxFeat;

    //==========================================
    //CHECK ARROW OF DEATH (5HB)
    //==========================================
    iFeat       =   FEAT_PRESTIGE_ARROW_OF_DEATH;
    sFeat       =   "RESTORE_FEAT_PRESTIGE_ARROW_OF_DEATH";
    tFeat       =   5;
    maxFeat     =   1;
    TrackFeat(iFeat, sFeat, tFeat, maxFeat, oPC);

    //==========================================
    //CHECK HAIL OF ARROWS (3HB)
    //==========================================
    iFeat       =   FEAT_PRESTIGE_HAIL_OF_ARROWS;
    sFeat       =   "RESTORE_FEAT_PRESTIGE_HAIL_OF_ARROWS";
    tFeat       =   3;
    maxFeat     =   1;
    TrackFeat(iFeat, sFeat, tFeat, maxFeat, oPC);

    //==========================================
    //CHECK IMBUE ARROW (2HB)
    //==========================================
    iFeat       =   FEAT_PRESTIGE_IMBUE_ARROW;
    sFeat       =   "RESTORE_FEAT_PRESTIGE_IMBUE_ARROW";
    tFeat       =   2;
    maxFeat     =   3;
    TrackFeat(iFeat, sFeat, tFeat, maxFeat, oPC);


    //==========================================
    //CHECK SEEKER ARROW 1 (1HB)
    //==========================================
    iFeat       =   FEAT_PRESTIGE_SEEKER_ARROW_1;
    sFeat       =   "RESTORE_FEAT_PRESTIGE_SEEKER_ARROW_1";
    tFeat       =   1;
    maxFeat     =   1;
    TrackFeat(iFeat, sFeat, tFeat, maxFeat, oPC);

    //==========================================
    //CHECK SEEKER ARROW 2 (1HB)
    //==========================================
    iFeat       =   FEAT_PRESTIGE_SEEKER_ARROW_2;
    sFeat       =   "RESTORE_FEAT_PRESTIGE_SEEKER_ARROW_2";
    tFeat       =   1;
    maxFeat     =   2;
    TrackFeat(iFeat, sFeat, tFeat, maxFeat, oPC);
}


void TrackFeat(
    int iFeat,
    string sFeat,
    int tFeat,
    int maxFeat,
    object oPC=OBJECT_SELF)
    {
    // No feat, return
    if (GetHasFeat(iFeat, oPC)==0) return;

    if (GetFeatRemainingUses(iFeat, oPC) < maxFeat)
    {
        // increment the tick
        int nTick = GetLocalInt(oPC, sFeat);
        nTick++;

        // set the tick increment
        if (nTick < 10)
        {
            SetLocalInt(oPC, sFeat, nTick);
            // skip the heartbeat
            return;
        }

        // Reset counter, restore feat
        SetLocalInt(oPC, sFeat, 0);
        IncrementRemainingFeatUses(oPC, iFeat);
    }
    else DeleteLocalInt(oPC, sFeat);

    return;
}
