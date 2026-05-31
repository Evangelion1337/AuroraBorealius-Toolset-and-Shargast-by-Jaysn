//::///////////////////////////////////////////////
//:: Death Database Naming
//:: death_db_name
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//::    Constants
//:://////////////////////////////////////////////

// The strDeathDatabaseName string variable indicates the
// the name of the database for persistant storage of
// flags to catch "cheaters" and to save exp buy back cost
const string strDeathDatabaseName = "ModuleDeathDatabase";

//:://////////////////////////////////////////////
//::     Method:    dhDeathGetDatabaseName
//:: Created By:    Dauvis
//:: Created On:    7/13/03
//::
//:: This function returns the campaign name to where
//:: player's death information should be stored.  This should
//:: allow the build more control.
//:://////////////////////////////////////////////
string dhDeathGetDatabaseName(object oPlayer)
{
    return strDeathDatabaseName;
}

