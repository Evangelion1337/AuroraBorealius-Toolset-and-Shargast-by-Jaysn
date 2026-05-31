#include "nwnx"
#include "nwnx_sql"

void main()
{
    int nCount;
    object oPC;
    string sCDKey;
    string sChar;
    object oArea;
    string sAreaTag;
    string sAreaName;
    string sModule;
    string sServer;
    int nLevel;
    int nStr;
    int nDex;
    int nCon;
    int nInt;
    int nWis;
    int nCha;
    int nFort;
    int nRef;
    int nWill;
    int nAC;
    int nGoodEvil;
    int nLawChaos;
    int nXP;
    int nGold;
    int nCurHP;
    int nMaxHP;
    int nRace;
    int nGender;
    string sGender;
    string sRace;

    nCount = GetLocalInt(GetModule(), "HIF_LOC_TRACK_COUNT");
    nCount++;
    if (nCount < 5)
    {
        SetLocalInt(GetModule(), "HIF_LOC_TRACK_COUNT", nCount);
        return;
    }
    SetLocalInt(GetModule(), "HIF_LOC_TRACK_COUNT", 0);

    oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        sCDKey = GetPCPublicCDKey(oPC);
        sChar = GetName(oPC);
        oArea = GetArea(oPC);
        sAreaTag = GetTag(oArea);
        sAreaName = GetName(oArea);
        sModule = GetModuleName();
        nLevel = GetHitDice(oPC);
        nStr = GetAbilityScore(oPC, ABILITY_STRENGTH);
        nDex = GetAbilityScore(oPC, ABILITY_DEXTERITY);
        nCon = GetAbilityScore(oPC, ABILITY_CONSTITUTION);
        nInt = GetAbilityScore(oPC, ABILITY_INTELLIGENCE);
        nWis = GetAbilityScore(oPC, ABILITY_WISDOM);
        nCha = GetAbilityScore(oPC, ABILITY_CHARISMA);
        nFort = GetFortitudeSavingThrow(oPC);
        nRef = GetReflexSavingThrow(oPC);
        nWill = GetWillSavingThrow(oPC);
        nAC = GetAC(oPC);
        nGoodEvil = GetAlignmentGoodEvil(oPC);
        nLawChaos = GetAlignmentLawChaos(oPC);
        nXP = GetXP(oPC);
        nGold = GetGold(oPC);
        nCurHP = GetCurrentHitPoints(oPC);
        nMaxHP = GetMaxHitPoints(oPC);
        nRace = GetRacialType(oPC);
        nGender = GetGender(oPC);

        if (nGender == GENDER_MALE) sGender = "Male";
        else if (nGender == GENDER_FEMALE) sGender = "Female";
        else sGender = "Other";

        sRace = IntToString(nRace);

        sServer = "ch1";
        if (sModule == "HOPE_Shargast_CH2") sServer = "ch2";

        NWNX_SQL_PrepareQuery("INSERT INTO player_locations (cdkey, charname, area_tag, area_name, server_name, last_seen) VALUES (?, ?, ?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE area_tag=VALUES(area_tag), area_name=VALUES(area_name), server_name=VALUES(server_name), last_seen=NOW()");
        NWNX_SQL_PreparedString(0, sCDKey);
        NWNX_SQL_PreparedString(1, sChar);
        NWNX_SQL_PreparedString(2, sAreaTag);
        NWNX_SQL_PreparedString(3, sAreaName);
        NWNX_SQL_PreparedString(4, sServer);
        NWNX_SQL_ExecutePreparedQuery();
        NWNX_SQL_DestroyPreparedQuery();

        NWNX_SQL_PrepareQuery("INSERT INTO nwn_website.characters (player_name, charname, race, gender, level, str, dex, con, `int`, wis, cha, fort, ref, will, ac, good_evil, law_chaos, xp, gold, current_hp, max_hp, server_name, last_seen) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE race=VALUES(race), gender=VALUES(gender), level=VALUES(level), str=VALUES(str), dex=VALUES(dex), con=VALUES(con), `int`=VALUES(`int`), wis=VALUES(wis), cha=VALUES(cha), fort=VALUES(fort), ref=VALUES(ref), will=VALUES(will), ac=VALUES(ac), good_evil=VALUES(good_evil), law_chaos=VALUES(law_chaos), xp=VALUES(xp), gold=VALUES(gold), current_hp=VALUES(current_hp), max_hp=VALUES(max_hp), server_name=VALUES(server_name), last_seen=NOW()");
        NWNX_SQL_PreparedString(0, sCDKey);
        NWNX_SQL_PreparedString(1, sChar);
        NWNX_SQL_PreparedString(2, sRace);
        NWNX_SQL_PreparedString(3, sGender);
        NWNX_SQL_PreparedInt(4, nLevel);
        NWNX_SQL_PreparedInt(5, nStr);
        NWNX_SQL_PreparedInt(6, nDex);
        NWNX_SQL_PreparedInt(7, nCon);
        NWNX_SQL_PreparedInt(8, nInt);
        NWNX_SQL_PreparedInt(9, nWis);
        NWNX_SQL_PreparedInt(10, nCha);
        NWNX_SQL_PreparedInt(11, nFort);
        NWNX_SQL_PreparedInt(12, nRef);
        NWNX_SQL_PreparedInt(13, nWill);
        NWNX_SQL_PreparedInt(14, nAC);
        NWNX_SQL_PreparedInt(15, nGoodEvil);
        NWNX_SQL_PreparedInt(16, nLawChaos);
        NWNX_SQL_PreparedInt(17, nXP);
        NWNX_SQL_PreparedInt(18, nGold);
        NWNX_SQL_PreparedInt(19, nCurHP);
        NWNX_SQL_PreparedInt(20, nMaxHP);
        NWNX_SQL_PreparedString(21, sServer);
        NWNX_SQL_ExecutePreparedQuery();
        NWNX_SQL_DestroyPreparedQuery();

        oPC = GetNextPC();
    }
}
