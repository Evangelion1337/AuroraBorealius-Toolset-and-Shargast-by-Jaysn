/**
 * PRC spellhook code for non-AMS spells. The actual work is done in
 * prc_prespell.nss
 * @author fluffyamoeba
 * @date 2008-4-24
 */
 
 
// This function holds all functions that are supposed to run before the actual
// spellscript gets run. If this functions returns FALSE, the spell is aborted
// and the spellscript will not run
int X2PreSpellCastCode();
 
// this will execute the prespellcastcode, whose full functionality is incoded in X2PreSpellCastCode2(),
// as a script, to save loading time for spells scripts and reduce memory usage of NWN
// the prespellcode takes up roughly 250 kByte compiled code, meaning that every spell script that
// calls it directly as a function (e.g.: X2PreSpellCastCode2) will be between 100 kByte to 250 kByte
// larger, than a spell script calling the prespellcode via ExecuteScript (e.g. X2PreSpellCastCode)
// Although ExecuteScript is slightly slower than a direct function call, quite likely overall performance is
// increased, because for every new spell 100-250 kByte less code need to be loaded into memory
// and NWN has more free memory available to keep more spells scripts (and other crucial scripts)
//in RAM

int X2PreSpellCastCode()
{
    object oCaster = OBJECT_SELF;

        // SetLocalInt(oCaster, "PSCC_Ret", 0);
        ExecuteScript("prc_prespell", oCaster);

        int nReturn = GetLocalInt(oCaster, "PSCC_Ret");
        // DeleteLocalInt(oCaster, "PSCC_Ret");

        return nReturn;
}
