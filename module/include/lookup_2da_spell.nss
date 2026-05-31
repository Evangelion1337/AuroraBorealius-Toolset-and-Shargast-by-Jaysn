/*
** Spell lookup&caching code by DarkGod
** Because the engine sucks so badly ...
*/
#include "inc_2dacache"

//const string PRC_CACHE_SUB_STRING = "NULL";

string
lookup_and_cache_spell_field(int spell_id, string tag_base, string column, object oModule = OBJECT_INVALID)
{
//modifed by Primogenitor to a more general 2da caching system
/*
	// Verify the module
	if (!GetIsObjectValid(oModule))
		oModule = GetModule();

	// Create the tag string
	string tag = tag_base + IntToString(spell_id);

	// lookup the tag in cache
	string val = GetLocalString(oModule, tag);

	// lookup and fill the cache if required
	if (val == "") {
		val = Get2DACache("spells", column, spell_id);

		// Get2DAString() will return "" for invalid fields
		// In order to make our per field cache work, we need to
		// perform a substitution so that non-existant and invalid
		// values are different.  Verify that this constant is indeed
		// unique within the 2da file if this code is reused
		if (val == "")
			val = PRC_CACHE_SUB_STRING;

		SetLocalString(oModule, tag, val);
	}

	// Undo the substitution, see above comments for details
	if (val == PRC_CACHE_SUB_STRING)
		val = "";

	return val;
*/
      return Get2DACache("spells", column, spell_id);
}

string
lookup_spell_name(int spell_id, object oModule = OBJECT_INVALID)
{
	return lookup_and_cache_spell_field(spell_id,
		"PRC_PACK_SPELL_NAME_", "Name", oModule);
}

string
lookup_spell_level(int spell_id, object oModule = OBJECT_INVALID)
{
	return lookup_and_cache_spell_field(spell_id,
		"PRC_PACK_SPELL_LEVEL_", "Wiz_Sorc", oModule);
}

string
lookup_spell_innate(int spell_id, object oModule = OBJECT_INVALID)
{
    string sTemp = lookup_and_cache_spell_field(spell_id, "PRC_PACK_SPELL_INNATE_LEVEL_", "Innate", oModule);
    if(sTemp == "")
    {
        string sMaster = Get2DACache("spells", "Master", spell_id);
        if(sMaster != "")
        {
            sTemp = Get2DACache("spells", "Innate", StringToInt(sMaster));
        }
    }
    return sTemp;
}

string
lookup_spell_druid_level(int spell_id, object oModule = OBJECT_INVALID)
{
	return lookup_and_cache_spell_field(spell_id,
		"PRC_PACK_SPELL_DRUID_LEVEL_", "Druid", oModule);
}

string
lookup_spell_cleric_level(int spell_id, object oModule = OBJECT_INVALID)
{
	return lookup_and_cache_spell_field(spell_id,
		"PRC_PACK_SPELL_CLERIC_LEVEL_", "Cleric", oModule);
}

string
lookup_spell_type(int spell_id, object oModule = OBJECT_INVALID)
{
	return lookup_and_cache_spell_field(spell_id,
		"PRC_PACK_SPELL_TYPE_", "ImmunityType", oModule);
}

string
lookup_spell_vs(int spell_id, object oModule = OBJECT_INVALID)
{
	return lookup_and_cache_spell_field(spell_id,
		"PRC_PACK_SPELL_VS_", "VS", oModule);
}

string
lookup_spell_school(int spell_id, object oModule = OBJECT_INVALID)
{
	return lookup_and_cache_spell_field(spell_id,
		"PRC_PACK_SPELL_SCHOOL_", "School", oModule);
}

void
lookup_spell(int spell_id)
{
    object module = GetModule();
	lookup_spell_level(spell_id, module);
	lookup_spell_cleric_level(spell_id, module);
	lookup_spell_innate(spell_id, module);
	lookup_spell_cleric_level(spell_id, module);
	lookup_spell_type(spell_id, module);
	lookup_spell_vs(spell_id, module);
	lookup_spell_school(spell_id, module);
}
