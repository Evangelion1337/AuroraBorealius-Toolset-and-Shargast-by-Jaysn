//::///////////////////////////////////////////////
//:: [Spiritual Weapon]
//:: [inc_spirit_weapn.nss]
//:: [Jaysyn 2024-08-23 07:58:14]
//::
//:: Include script for Spiritual Weapon
//::
//::///////////////////////////////////////////////
/**@  Spiritual Weapon
(Player's Handbook v.3.5, p. 283)

Evocation [Force]
Level: Cleric 2, Knight of the Chalice 2, War 2, Mysticism 2,
Components: V, S, DF,
Casting Time: 1 standard action
Range: Medium (100 ft. + 10 ft./level)
Effect: Magic weapon of force
Duration: 1 round/level (D)
Saving Throw: None
Spell Resistance: Yes

A weapon made of pure force springs into existence and attacks
opponents at a distance, as you direct it, dealing 1d8 force 
damage per hit, +1 point per three caster levels (maximum +5 
at 15th level). The weapon takes the shape of a weapon 
favored by your deity or a weapon with some spiritual 
significance or symbolism to you (see below) and has the 
same threat range and critical multipliers as a real weapon 
of its form. It strikes the opponent you designate, starting 
with one attack in the round the spell is cast and continuing 
each round thereafter on your turn. It uses your base attack 
bonus (possibly allowing it multiple attacks per round in 
subsequent rounds) plus your Wisdom modifier as its attack 
bonus. It strikes as a spell, not as a weapon, so, for 
example, it can damage creatures that have damage 
reduction. As a force effect, it can strike incorporeal 
creatures without the normal miss chance associated with 
incorporeality. The weapon always strikes from your 
direction. It does not get a flanking bonus or help a 
combatant get one. Your feats (such as Weapon Focus) 
or combat actions (such as charge) do not affect the 
weapon. If the weapon goes beyond the spell range, if 
it goes out of your sight, or if you are not directing 
it, the weapon returns to you and hovers.

Each round after the first, you can use a move action to
 redirect the weapon to a new target. If you do not, 
 the weapon continues to attack the previous round's 
 target. On any round that the weapon switches targets, 
 it gets one attack. Subsequent rounds of attacking that 
 target allow the weapon to make multiple attacks if your 
 base attack bonus would allow it to. Even if the spiritual 
 weapon is a ranged weapon, use the spell's range, not the 
 weapon's normal range increment, and switching targets 
 still is a move action.

A spiritual weapon cannot be attacked or harmed by 
physical attacks, but dispel magic, disintegrate, a 
sphere of annihilation, or a rod of cancellation affects it. 
A spiritual weapon's AC against touch attacks is 12 (10 + 
size bonus for Tiny object).

If an attacked creature has spell resistance, you make a 
caster level check (1d20 + caster level) against that 
spell resistance the first time the spiritual weapon 
strikes it. If the weapon is successfully resisted, the 
spell is dispelled. If not, the weapon has its normal 
full effect on that creature for the duration of the spell.
*///////////////////////////////////////////////////////////
#include "inc_rand_equip"
#include "prc_inc_spells"


void NullifyAppearance(object oSummon, int nThrowHands = FALSE)
{
	// Ensure the object is valid and is not a player or DM
	if (!GetIsObjectValid(oSummon) || GetIsPC(oSummon) || GetIsDM(oSummon))
	{
		return;
	}

    // Nullify all body parts
    SetCreatureBodyPart(CREATURE_PART_HEAD, 0, oSummon);
    SetCreatureBodyPart(CREATURE_PART_TORSO, 0, oSummon);
	SetCreatureBodyPart(CREATURE_PART_BELT, 0, oSummon);
    SetCreatureBodyPart(CREATURE_PART_PELVIS, 0, oSummon);
    SetCreatureBodyPart(CREATURE_PART_RIGHT_THIGH, 0, oSummon);
    SetCreatureBodyPart(CREATURE_PART_LEFT_THIGH, 0, oSummon);
    SetCreatureBodyPart(CREATURE_PART_RIGHT_FOOT, 0, oSummon);
    SetCreatureBodyPart(CREATURE_PART_LEFT_FOOT, 0, oSummon);
	SetCreatureBodyPart(CREATURE_PART_RIGHT_FOREARM, 0, oSummon);
	SetCreatureBodyPart(CREATURE_PART_LEFT_FOREARM, 0, oSummon);
	SetCreatureBodyPart(CREATURE_PART_RIGHT_HAND, 0, oSummon);
	SetCreatureBodyPart(CREATURE_PART_LEFT_HAND, 0, oSummon);

	if(nThrowHands)
	{
	// Keep hands and forearms visible
		SetCreatureBodyPart(CREATURE_PART_RIGHT_FOREARM, 1, oSummon);
		SetCreatureBodyPart(CREATURE_PART_LEFT_FOREARM, 1, oSummon);
		SetCreatureBodyPart(CREATURE_PART_RIGHT_HAND, 1, oSummon);
		SetCreatureBodyPart(CREATURE_PART_LEFT_HAND, 1, oSummon);
	}
}

void RegisterSummonEvents(object oCreature)
{
    // Explicitly re-register the event for the next spell cast at the summon.
    AddEventScript(oCreature, EVENT_NPC_ONSPELLCASTAT, "sp_spiritweapon", TRUE);
	AddEventScript(oCreature, EVENT_NPC_ONSPELLCASTAT, "sp_spiritweapon", TRUE);
    SendMessageToPC(GetFirstPC(), "inc_spirit_weapn: Event re-registered for next spell cast.");
}

// Returns the alignment component with the most points towards it.
// Possible returns: ALIGNMENT_LAWFUL, ALIGNMENT_CHAOTIC, ALIGNMENT_GOOD, ALIGNMENT_EVIL, or ALIGNMENT_NEUTRAL.
int GetDominantAlignment(object oCreature)
{
    int nLawChaos = GetLawChaosValue(oCreature);
    int nGoodEvil = GetGoodEvilValue(oCreature);

    int nDominant = ALIGNMENT_NEUTRAL;

    // Check Law vs Chaos
    if (nLawChaos > 50)
    {
        nDominant = ALIGNMENT_LAWFUL;
    }
    else if (nLawChaos < 50)
    {
        nDominant = ALIGNMENT_CHAOTIC;
    }

    // Check Good vs Evil
    if (nGoodEvil > 50)
    {
        if (nLawChaos == 50 || nGoodEvil > nLawChaos) // Tie or Good is stronger
        {
            nDominant = ALIGNMENT_GOOD;
        }
    }
    else if (nGoodEvil < 50)
    {
        if (nLawChaos == 50 || nGoodEvil < nLawChaos) // Tie or Evil is stronger
        {
            nDominant = ALIGNMENT_EVIL;
        }
    }

    return nDominant;
}

void SetDeityByClass(object oCreature)
{
	if(GetLevelByClass(CLASS_TYPE_RAVAGER, oCreature) > 0) SetDeity(oCreature, "Erythnul");
	
	if(GetLevelByClass(CLASS_TYPE_TEMPUS, oCreature) > 0) SetDeity(oCreature, "Tempus");
	
	if(GetLevelByClass(CLASS_TYPE_BLACK_BLOOD_CULTIST, oCreature) > 0) SetDeity(oCreature, "Malar");
	
	if(GetLevelByClass(CLASS_TYPE_CELEBRANT_SHARESS, oCreature) > 0) SetDeity(oCreature, "Sharess");
	
	if(GetLevelByClass(CLASS_TYPE_COC, oCreature) > 0) SetDeity(oCreature, "Corellon Larethian");
	
	if(GetLevelByClass(CLASS_TYPE_VASSAL, oCreature) > 0) SetDeity(oCreature, "Bahamut");
	
	if(GetLevelByClass(CLASS_TYPE_ORCUS, oCreature) > 0 ) SetDeity(oCreature, "Orcus");	
	
	if(GetLevelByClass(CLASS_TYPE_BLIGHTLORD, oCreature) > 0 ) SetDeity(oCreature, "Talona");
	
	if(GetLevelByClass(CLASS_TYPE_STORMLORD, oCreature) > 0 ) SetDeity(oCreature, "Talos");
	
	if(GetLevelByClass(CLASS_TYPE_TALON_OF_TIAMAT, oCreature) > 0 ) SetDeity(oCreature, "Tiamat");
	
	if(GetLevelByClass(CLASS_TYPE_SOLDIER_OF_LIGHT, oCreature) > 0 ) SetDeity(oCreature, "Elishar");
	
	if(GetLevelByClass(CLASS_TYPE_SLAYER_OF_DOMIEL, oCreature) > 0 ) SetDeity(oCreature, "Domiel");
	
	if(GetLevelByClass(CLASS_TYPE_SHINING_BLADE, oCreature) > 0 ) SetDeity(oCreature, "Heironeous");
	
	if(GetLevelByClass(CLASS_TYPE_RUBY_VINDICATOR, oCreature) > 0 ) SetDeity(oCreature, "Wee Jas");
	
	if(GetLevelByClass(CLASS_TYPE_MORNINGLORD, oCreature) > 0 ) SetDeity(oCreature, "Lathander");
	
	if(GetLevelByClass(CLASS_TYPE_MIGHTY_CONTENDER_KORD, oCreature) > 0 ) SetDeity(oCreature, "Kord");	

	if(GetLevelByClass(CLASS_TYPE_HEARTWARDER, oCreature) > 0 ) SetDeity(oCreature, "Sune");	
	
	if(GetLevelByClass(CLASS_TYPE_HEXTOR, oCreature) > 0 ) SetDeity(oCreature, "Hextor");
	
	if(GetLevelByClass(CLASS_TYPE_PRC_EYE_OF_GRUUMSH, oCreature) > 0 ) SetDeity(oCreature, "Gruumsh");
	
	//if(GetLevelByClass(CLASS_TYPE_JUDICATOR, oCreature) > 0 ) SetDeity(oCreature, "Selvetarm");	
	
	if(GetLevelByClass(CLASS_TYPE_JUDICATOR, oCreature) > 0 ) SetDeity(oCreature, "Lolth");
	
	if(GetLevelByClass(CLASS_TYPE_OCULAR, oCreature) > 0 ) SetDeity(oCreature, "Great Mother");
	
	if(GetLevelByClass(CLASS_TYPE_KNIGHT_WEAVE, oCreature) > 0 ) SetDeity(oCreature, "Mystra");
}	

string GetSpiritualWeaponTypeByDeity(object oCreature)
{
	SetDeityByClass(oCreature);
	
	string sDeity = GetStringLowerCase(GetDeity(oCreature));
    string sResRef;
	
	int nDomAlignment = GetDominantAlignment(oCreature);
	
    if(GetStringRight(sDeity, 12) == GetStringLowerCase("glittergold") || GetStringRight(sDeity, 5) == GetStringLowerCase("auril") 
	|| GetStringRight(sDeity, 7) == GetStringLowerCase("balinor") || GetStringRight(sDeity, 11) == GetStringLowerCase("smoothhands") 
	|| GetStringRight(sDeity, 11) == GetStringLowerCase("silverbeard") || GetStringRight(sDeity, 6) == GetStringLowerCase("duerra") 
	|| GetStringRight(sDeity, 7) == GetStringLowerCase("gulthyn") || GetStringRight(sDeity, 8) == GetStringLowerCase("iallanis") 
	|| GetStringRight(sDeity, 5) == GetStringLowerCase("llerg") || GetStringRight(sDeity, 10) == GetStringLowerCase("maglubiyet")	
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("tempus") || GetStringRight(sDeity, 6) == GetStringLowerCase("uthgar")	
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("valkar") || GetStringRight(sDeity, 5) == GetStringLowerCase("vatun"))
        sResRef = "nw_waxbt001";  //:: Battleaxe	
	
    else if(GetStringRight(sDeity, 6) == GetStringLowerCase("boccob") || GetStringRight(sDeity, 10) == GetStringLowerCase("fharlanghn") 
	|| GetStringRight(sDeity, 3) == GetStringLowerCase("hai")  || GetStringRight(sDeity, 6) == GetStringLowerCase("faenya") 
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("aureon")  || GetStringRight(sDeity, 5) == GetStringLowerCase("azuth") 
	|| GetStringRight(sDeity, 5) == GetStringLowerCase("bralm")  || GetStringRight(sDeity, 11) == GetStringLowerCase("cyrrollalee") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("liothiel")  || GetStringRight(sDeity, 9) == GetStringLowerCase("incabulos") 
	|| GetStringRight(sDeity, 3) == GetStringLowerCase("geb")  || GetStringRight(sDeity, 7) == GetStringLowerCase("enoreth") 
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("joramy")  || GetStringRight(sDeity, 9) == GetStringLowerCase("panzuriel") 
	|| GetStringRight(sDeity, 9) == GetStringLowerCase("rallathil")  || GetStringRight(sDeity, 7) == GetStringLowerCase("pholtus") 
	|| GetStringRight(sDeity, 3) == GetStringLowerCase("hai")  || GetStringRight(sDeity, 10) == GetStringLowerCase("fharlanghn") 
	|| GetStringRight(sDeity, 7) == GetStringLowerCase("moonbow") || GetStringRight(sDeity, 8) == GetStringLowerCase("shiallia") 
	|| GetStringRight(sDeity, 7) == GetStringLowerCase("solanil") || GetStringRight(sDeity, 7) == GetStringLowerCase("tarmuid") 
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("shadow") || GetStringRight(sDeity, 5) == GetStringLowerCase("thoth") 
	|| GetStringRight(sDeity, 10) == GetStringLowerCase("velsharoon") || GetStringRight(sDeity, 7) == GetStringLowerCase("ventila"))
        sResRef = "nw_wdbqs001";  //:: Quarterstaff	
	
    else if(GetStringRight(sDeity, 9) == GetStringLowerCase("larethian") || GetStringRight(sDeity, 7) == GetStringLowerCase("ehlonna") 
	|| GetStringRight(sDeity, 10) == GetStringLowerCase("heironeous") || GetStringRight(sDeity, 5) == GetStringLowerCase("altua") 
	|| GetStringRight(sDeity, 9) == GetStringLowerCase("barachiel") || GetStringRight(sDeity, 10) == GetStringLowerCase("heironeous") 
	|| GetStringRight(sDeity, 5) == GetStringLowerCase("cyric") || GetStringRight(sDeity, 4) == GetStringLowerCase("dorn") 
	|| GetStringRight(sDeity, 7) == GetStringLowerCase("garagos") || GetStringRight(sDeity, 7) == GetStringLowerCase("glautru") 
	|| GetStringRight(sDeity, 7) == GetStringLowerCase("ilneval") || GetStringRight(sDeity, 6) == GetStringLowerCase("lendys") 
	|| GetStringRight(sDeity, 4) == GetStringLowerCase("mask") || GetStringRight(sDeity, 10) == GetStringLowerCase("merrshaulk") 
	|| GetStringRight(sDeity, 5) == GetStringLowerCase("oghma") || GetStringRight(sDeity, 8) == GetStringLowerCase("pyremius") 
	|| GetStringRight(sDeity, 10) == GetStringLowerCase("red knight") || GetStringRight(sDeity, 3) == GetStringLowerCase("tyr") 
	|| GetStringRight(sDeity, 9) == GetStringLowerCase("vergadain") || GetStringRight(sDeity, 7) == GetStringLowerCase("elishar"))
        sResRef = "nw_wswls001";  //:: Longsword		

    else if(GetStringRight(sDeity, 8) == GetStringLowerCase("erythnul") || GetStringRight(sDeity, 6) == GetStringLowerCase("arawai") 
	|| GetStringRight(sDeity, 4) == GetStringLowerCase("bane") || GetStringRight(sDeity, 7) == GetStringLowerCase("hruggek") 
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("ngatha") || GetStringRight(sDeity, 6) == GetStringLowerCase("memnor") 
	|| GetStringRight(sDeity, 7) == GetStringLowerCase("wathaku"))
        sResRef = "nw_wblms001";  //:: Morningstar

    else if(GetStringRight(sDeity, 8) == GetStringLowerCase("gruumsh") || GetStringRight(sDeity, 10) == GetStringLowerCase("angharradh") 
	|| GetStringRight(sDeity, 5) == GetStringLowerCase("annam") || GetStringRight(sDeity, 10) == GetStringLowerCase("aventernus") 
	|| GetStringRight(sDeity, 13) == GetStringLowerCase("wildwanderer") || GetStringRight(sDeity, 7) == GetStringLowerCase("boldrei") 
	|| GetStringRight(sDeity, 9) == GetStringLowerCase("celestian") || GetStringRight(sDeity, 5) == GetStringLowerCase("eadro") 
	|| GetStringRight(sDeity, 7) == GetStringLowerCase("geshtai") || GetStringRight(sDeity, 6) == GetStringLowerCase("hiatea") 
	|| GetStringRight(sDeity, 10) == GetStringLowerCase("kaelthiere") || GetStringRight(sDeity, 6) == GetStringLowerCase("kithin") 
	|| GetStringRight(sDeity, 9) == GetStringLowerCase("kurtulmak") || GetStringRight(sDeity, 5) == GetStringLowerCase("lurue") 
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("procan") || GetStringRight(sDeity, 5) == GetStringLowerCase("sebek")
	|| GetStringRight(sDeity, 3) == GetStringLowerCase("set") || GetStringRight(sDeity, 7) == GetStringLowerCase("skerrit")
	|| GetStringRight(sDeity, 5) == GetStringLowerCase("talos") || GetStringRight(sDeity, 7) == GetStringLowerCase("telchur")
	|| GetStringRight(sDeity, 10) == GetStringLowerCase("trithereon") || GetStringRight(sDeity, 6) == GetStringLowerCase("ulutiu"))
        sResRef = "nw_wplss001";  //:: Spear		

    else if(GetStringRight(sDeity, 6) == GetStringLowerCase("hextor") || GetStringRight(sDeity, 11) == GetStringLowerCase("patient one"))
        sResRef = "nw_wblfl001";  //:: Light Flail

    else if(GetStringRight(sDeity, 5) == GetStringLowerCase("akadi") || GetStringRight(sDeity, 8) == GetStringLowerCase("lliendil") 
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("osiris") 	|| GetStringRight(sDeity, 8) == GetStringLowerCase("urogalan"))
        sResRef = "nw_wblfh001";  //:: Heavy Flail	
	
    else if(GetStringRight(sDeity, 6) == GetStringLowerCase("domiel") || GetStringRight(sDeity, 9) == GetStringLowerCase("windstrom") 
	|| GetStringRight(sDeity, 9) == GetStringLowerCase("brightaxe") || GetStringRight(sDeity, 3) == GetStringLowerCase("iuz") 
	|| GetStringRight(sDeity, 4) == GetStringLowerCase("kord") || GetStringRight(sDeity, 10) == GetStringLowerCase("shaundakul") 
	|| GetStringRight(sDeity, 5) == GetStringLowerCase("surtr") || GetStringRight(sDeity, 14) == GetStringLowerCase("lord of blades") 
	|| GetStringRight(sDeity, 4) == GetStringLowerCase("torm") || GetStringRight(sDeity, 6) == GetStringLowerCase("typhos") 	
	|| GetStringRight(sDeity, 5) == GetStringLowerCase("zarus"))
        sResRef = "nw_wswgs001";  //:: Greatsword	
	
    else if(GetStringRight(sDeity, 7) == GetStringLowerCase("aulasha") || GetStringRight(sDeity, 9) == GetStringLowerCase("steelskin") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("ironhand") || GetStringRight(sDeity, 7) == GetStringLowerCase("grumbar") 
	|| GetStringRight(sDeity, 4) == GetStringLowerCase("gond") || GetStringRight(sDeity, 8) == GetStringLowerCase("istishia") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("laduguer") || GetStringRight(sDeity, 5) == GetStringLowerCase("lyris") 
	|| GetStringRight(sDeity, 7) == GetStringLowerCase("moradin") || GetStringRight(sDeity, 6) == GetStringLowerCase("onatar") 	
	|| GetStringRight(sDeity, 10) == GetStringLowerCase("stonebones") || GetStringRight(sDeity, 9) == GetStringLowerCase("stronmaus"))
        sResRef = "nw_wblhw001";  //:: Warhammer	

    else if(GetStringRight(sDeity, 8) == GetStringLowerCase("chauntea") || GetStringRight(sDeity, 11) == GetStringLowerCase("chronepsis") 
	|| GetStringRight(sDeity, 7) == GetStringLowerCase("duthila") || GetStringRight(sDeity, 8) == GetStringLowerCase("iborighu") 
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("jergal") || GetStringRight(sDeity, 6) == GetStringLowerCase("nerull") 
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("keeper") || GetStringRight(sDeity, 5) == GetStringLowerCase("zuggtmoy"))
        sResRef = "nw_wplsc001";  //:: Scythe	
		
    else if(GetStringRight(sDeity, 6) == GetStringLowerCase("halmyr") || GetStringRight(sDeity, 6) == GetStringLowerCase("halmyr") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("levistus") || GetStringRight(sDeity, 4) == GetStringLowerCase("lirr") 
	|| GetStringRight(sDeity, 5) == GetStringLowerCase("milil") || GetStringRight(sDeity, 10) == GetStringLowerCase("olidammara") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("the fury"))
        sResRef = "nw_wswrp001";  //:: Rapier		
		
    else if(GetStringRight(sDeity, 8) == GetStringLowerCase("cuthbert") || GetStringRight(sDeity, 5) == GetStringLowerCase("pelor") 
	|| GetStringRight(sDeity, 10) == GetStringLowerCase("truesilver") || GetStringRight(sDeity, 8) == GetStringLowerCase("kikanuti") 
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("korran") || GetStringRight(sDeity, 9) == GetStringLowerCase("lathander") 
	|| GetStringRight(sDeity, 4) == GetStringLowerCase("duin") || GetStringRight(sDeity, 5) == GetStringLowerCase("orcus") 
	|| GetStringRight(sDeity, 11) == GetStringLowerCase("earthcaller") || GetStringRight(sDeity, 6) == GetStringLowerCase("selune") 
	|| GetStringRight(sDeity, 9) == GetStringLowerCase("selvetarm") || GetStringRight(sDeity, 6) == GetStringLowerCase("syeret")	
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("syreth") || GetStringRight(sDeity, 7) == GetStringLowerCase("urbanus"))
       sResRef = "prc_wxblmh001";  //:: Heavy Mace		

    else if(GetStringRight(sDeity, 3) == GetStringLowerCase("rao") || GetStringRight(sDeity, 9) == GetStringLowerCase("siamorphe"))
       sResRef = "nw_wblml001";  //:: Light Mace	

    else if(GetStringRight(sDeity, 3) == GetStringLowerCase("jas") || GetStringRight(sDeity, 5) == GetStringLowerCase("vecna") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("lorfiril") || GetStringRight(sDeity, 11) == GetStringLowerCase("cloakshadow") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("abbathor") || GetStringRight(sDeity, 11) == GetStringLowerCase("brandobaris") 
	|| GetStringRight(sDeity, 5) == GetStringLowerCase("thaun") || GetStringRight(sDeity, 6) == GetStringLowerCase("deneir") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("diirinka") || GetStringRight(sDeity, 5) == GetStringLowerCase("glory") 
	|| GetStringRight(sDeity, 9) == GetStringLowerCase("mestarine") || GetStringRight(sDeity, 8) == GetStringLowerCase("gargauth") 
	|| GetStringRight(sDeity, 7) == GetStringLowerCase("celanil") || GetStringRight(sDeity, 5) == GetStringLowerCase("istus") 
	|| GetStringRight(sDeity, 11) == GetStringLowerCase("kiaransalee") || GetStringRight(sDeity, 6) == GetStringLowerCase("savras") 
	|| GetStringRight(sDeity, 11) == GetStringLowerCase("shekinester") || GetStringRight(sDeity, 9) == GetStringLowerCase("tharizdun") 
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("of vol") || GetStringRight(sDeity, 5) == GetStringLowerCase("zagyg"))
		sResRef = "nw_wswdg001";  //:: Dagger
	
    else if(GetStringRight(sDeity, 6) == GetStringLowerCase("afflux") || GetStringRight(sDeity, 8) == GetStringLowerCase("arvoreen") 
	|| GetStringRight(sDeity, 12) == GetStringLowerCase("brightmantle") || GetStringRight(sDeity, 7) == GetStringLowerCase("ilesere") 
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("hathor") || GetStringRight(sDeity, 4) == GetStringLowerCase("hlal") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("nadirech") || GetStringRight(sDeity, 8) == GetStringLowerCase("shargaas") 
	|| GetStringRight(sDeity, 5) == GetStringLowerCase("sixin") || GetStringRight(sDeity, 8) == GetStringLowerCase("vhaeraun") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("yondalla"))
		sResRef = "nw_wswss001";  //:: Shortsword	
		
    else if(GetStringRight(sDeity, 8) == GetStringLowerCase("kelemvor") || GetStringRight(sDeity, 4) == GetStringLowerCase("helm") 
	|| GetStringRight(sDeity, 10) == GetStringLowerCase("wyvernspur") || GetStringRight(sDeity, 10) == GetStringLowerCase("eilistraee") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("aengrist"))
		sResRef = "nw_wswbs001";  //:: Bastard Sword	
		
    else if(GetStringRight(sDeity, 11) == GetStringLowerCase("aasterinian") || GetStringRight(sDeity, 9) == GetStringLowerCase("astilabor") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("doresain") || GetStringRight(sDeity, 8) == GetStringLowerCase("falazure") 
	|| GetStringRight(sDeity, 4) == GetStringLowerCase("haku") || GetStringRight(sDeity, 8) == GetStringLowerCase("mielikki") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("nilthina") || GetStringRight(sDeity, 8) == GetStringLowerCase("soorinek") 
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("tamara") || GetStringRight(sDeity, 8) == GetStringLowerCase("traveler") 
	|| GetStringRight(sDeity, 13) == GetStringLowerCase("undying court"))
		sResRef = "nw_wswsc001";  //:: Scimitar
		
    else if(GetStringRight(sDeity, 19) == GetStringLowerCase("spirits of the past"))
       sResRef = "prc_wxdbsc001";  //:: Double Scimitar
   
    else if(GetStringRight(sDeity, 6) == GetStringLowerCase("mouqol"))
       sResRef = "nw_wbwxl001";  //:: Light Crossbow   

    else if(GetStringRight(sDeity, 6) == GetStringLowerCase("cyndor"))
       sResRef = "nw_wbwsl001";  //:: Sling  
   
    else if(GetStringRight(sDeity, 4) == GetStringLowerCase("isis"))
       sResRef = "prc_wswdp001";  //:: Katar (punching dagger)  

    else if(GetStringRight(sDeity, 5) == GetStringLowerCase("arrah"))
       sResRef = "nw_wplhb001";  //:: Halberd
 
    else if(GetStringRight(sDeity, 5) == GetStringLowerCase("delleb"))
       sResRef = "nw_wthdt001";  //:: Dart 
   
    else if(GetStringRight(sDeity, 12) == GetStringLowerCase("great mother") || GetStringRight(sDeity, 8) == GetStringLowerCase("sulerian") 
	|| GetStringRight(sDeity, 5) == GetStringLowerCase("thrym"))
		sResRef = "nw_waxgr001";  //:: Greataxe	

    else if(GetStringRight(sDeity, 9) == GetStringLowerCase("tem-et-nu") || GetStringRight(sDeity, 7) == GetStringLowerCase("mockery"))
		sResRef = "nw_wspka001";  //:: Kama	
	
    else if(GetStringRight(sDeity, 9) == GetStringLowerCase("dumathoin") || GetStringRight(sDeity, 8) == GetStringLowerCase("silvanus"))
		sResRef = "prc_wxblma001";  //:: Maul		

    else if(GetStringRight(sDeity, 9) == GetStringLowerCase("shevarash") || GetStringRight(sDeity, 10) == GetStringLowerCase("thelandira") 
	|| GetStringRight(sDeity, 12) == GetStringLowerCase("silver flame") || GetStringRight(sDeity, 10) == GetStringLowerCase("gilmadrith"))
		sResRef = "nw_wbwln001";  //:: Long Bow	
		
    else if(GetStringRight(sDeity, 11) == GetStringLowerCase("cyrrollalee") || GetStringRight(sDeity, 9) == GetStringLowerCase("grolantor") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("konkresh") || GetStringRight(sDeity, 5) == GetStringLowerCase("kyuss") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("semuanya") || GetStringRight(sDeity, 6) == GetStringLowerCase("vaprak") 
	|| GetStringRight(sDeity, 12) == GetStringLowerCase("whale mother"))
		sResRef = "nw_wblcl001";  //:: Club

    else if(GetStringRight(sDeity, 6) == GetStringLowerCase("ishtus") || GetStringRight(sDeity, 4) == GetStringLowerCase("azul") 
	|| GetStringRight(sDeity, 5) == GetStringLowerCase("lolth") || GetStringRight(sDeity, 8) == GetStringLowerCase("nephthys") 
	|| GetStringRight(sDeity, 10) == GetStringLowerCase("sharindlar") || GetStringRight(sDeity, 6) == GetStringLowerCase("sune"))
		sResRef = "x2_it_wpwhip";  //:: Whip		

    else if(GetStringRight(sDeity, 7) == GetStringLowerCase("bahamut") || GetStringRight(sDeity, 8) == GetStringLowerCase("nobanion") 
	|| GetStringRight(sDeity, 12) == GetStringLowerCase("dragon below") || GetStringRight(sDeity, 6) == GetStringLowerCase("tiamat") 
	|| GetStringRight(sDeity, 5) == GetStringLowerCase("ubtao"))
		sResRef = "prc_wblph001";  //:: Heavy Pick	

    else if(GetStringRight(sDeity, 9) == GetStringLowerCase("waukeen") || GetStringRight(sDeity, 6) == GetStringLowerCase("zouken"))
		sResRef = "prc_wblnn001";  //:: Nunchaku	

    else if(GetStringRight(sDeity, 5) == GetStringLowerCase("garyx") || GetStringRight(sDeity, 7) == GetStringLowerCase("olladra") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("peryroyl"))
		sResRef = "nw_wspsc001";  //:: Sickle	
		
    else if(GetStringRight(sDeity, 6) == GetStringLowerCase("lliira") || GetStringRight(sDeity, 6) == GetStringLowerCase("mystra") 
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("tymora"))
		sResRef = "nw_wthsh001";  //:: Throwing Stars	

    else if(GetStringRight(sDeity, 8) == GetStringLowerCase("sashelas") || GetStringRight(sDeity, 5) == GetStringLowerCase("hleid") 
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("osprem") || GetStringRight(sDeity, 8) == GetStringLowerCase("sekolah") 
	|| GetStringRight(sDeity, 8) == GetStringLowerCase("devourer") || GetStringRight(sDeity, 8) == GetStringLowerCase("umberlee") 
	|| GetStringRight(sDeity, 7) == GetStringLowerCase("yeathan"))
		sResRef = "nw_wpltr001";  //:: Trident

    else if(GetStringRight(sDeity, 7) == GetStringLowerCase("ilmater") || GetStringRight(sDeity, 9) == GetStringLowerCase("ilsensine") 
	|| GetStringRight(sDeity, 6) == GetStringLowerCase("sophia") || GetStringRight(sDeity, 6) == GetStringLowerCase("talona") 
	|| GetStringRight(sDeity, 13) == GetStringLowerCase("path of light") || GetStringRight(sDeity, 7) == GetStringLowerCase("yurtrus")
	|| GetStringRight(sDeity, 7) == GetStringLowerCase("sharess") || GetStringRight(sDeity, 7) == GetStringLowerCase("malar"))
	{	//sResRef = "nw_wpltr001";
		sResRef = "prc_sprtwpn_slam"; //:: Unarmed Strike
	}	
		
	else if(sDeity == "" && nDomAlignment == ALIGNMENT_EVIL)
		sResRef = "nw_wblfl001";  //:: Light Flail
 
 	else if(sDeity == "" && nDomAlignment == ALIGNMENT_CHAOTIC)
		sResRef = "nw_waxbt001";  //:: Battleaxe
	
	else if(sDeity == "" && nDomAlignment == ALIGNMENT_GOOD)
		sResRef = "nw_wblhw001";  //:: Warhammer
	
	else if(sDeity == "" && nDomAlignment == ALIGNMENT_LAWFUL)
		sResRef = "nw_wswgs001";  //:: Greatsword	
	
	else if(sDeity == "" && nDomAlignment == ALIGNMENT_NEUTRAL)
		sResRef = "nw_wswsc001";  //:: Scimitar		
	
    return sResRef;
}

object CreateDeityWeapon(object oCreature)
{
	string sWeapon	= GetSpiritualWeaponTypeByDeity(oCreature);
	
	if(sWeapon == "")
        return OBJECT_INVALID;
	
	object oWeapon = CreateItemOnObject(sWeapon, oCreature);
	
    EquipDebugString(GetName(oCreature) + " has Deity weapon "+GetName(oWeapon));
    return oWeapon;	
}
	
//:: Creates the weapon that the creature will be using.
void CreateSpiritualWeapon(object oCaster, float fDuration, int nClass)
{
//:: Declare major variables
	int iCasterLvL	= PRCGetCasterLevel(oCaster);
	int nBAB		= GetBaseAttackBonus(oCaster);	
	int nAttNumber	= 1+(nBAB / 4);
	int nDamBonus	= PRCMin(5, iCasterLvL / 3);
	int nPenetr 	= iCasterLvL + SPGetPenetr();
	int nStat		= nClass == CLASS_TYPE_INVALID ?
						GetAbilityModifier(ABILITY_CHARISMA, oCaster) ://:: if cast from items use charisma by default
						GetDCAbilityModForClass(nClass, oCaster);	
	
    object oWeapon;
	object oArmor;
	object oAmmo1;
	object oAmmo2;
	
    string sWeapon = GetSpiritualWeaponTypeByDeity(oCaster);
    object oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oCaster);
	SendMessageToPC(oCaster, "inc_spirit_weapn: Hooking Event.");
	
	RegisterSummonEvents(oSummon);
	
    int i = 1;
    while(GetIsObjectValid(oSummon) && !GetIsPC(oSummon) && ! GetIsDM(oSummon))
    {
		NullifyAppearance(oSummon);
		
        if(GetResRef(oSummon) == "prc_spirit_weapn")  //:: Unarmed / "Claw Bracer"
        {
            SetBaseAttackBonus(nAttNumber, oSummon);
			SendMessageToPC(oCaster, "inc_spirit_weapn:" +GetName(oCaster)+"'s BAB is: "+IntToString(nBAB));
			//EffectModifyAttacks(nAttNumber);
			SendMessageToPC(oCaster, "inc_spirit_weapn: Adding "+IntToString(nAttNumber)+" attacks / round.");
			SetLocalInt(oSummon, "X2_L_NUMBER_OF_ATTACKS", nAttNumber);
			SendMessageToPC(oCaster, "inc_spirit_weapn: Storing caster as: " + GetName(oCaster));
			DelayCommand(0.0f, SetLocalObject(oSummon, "MY_CASTER", oCaster));
			ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_GHOST_SMOKE_2), oSummon);
			ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_GHOST_TRANSPARENT), oSummon);
			ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectAttackIncrease(nBAB+nStat), oSummon);
			
			if(!GetIsObjectValid(GetItemPossessedBy(oSummon, sWeapon)))
            {
                //Create item on the creature, equip it and add properties.
                oWeapon = CreateItemOnObject(sWeapon, oSummon);
								
				//Add event scripts
				AddEventScript(oWeapon, EVENT_ITEM_ONHIT, "prc_evnt_spirwep", TRUE, FALSE);
				SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onHit event script on weapon");
				AddEventScript(oWeapon, EVENT_ONHIT, "prc_evnt_spirwep", TRUE, FALSE);
				SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onHit event script on weapon");				
				AddEventScript(oWeapon, EVENT_ITEM_ONUNAQUIREITEM, "prc_evnt_spirwep", TRUE, FALSE);
				SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onUnacquire event script on weapon");
				AddEventScript(oWeapon, EVENT_ITEM_ONPLAYERUNEQUIPITEM, "prc_evnt_spirwep", TRUE, FALSE);
				SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onUnequip event script on weapon");				
	
                // GZ: Fix for weapon being dropped when killed
                SetDroppableFlag(oWeapon, FALSE);
				SetItemCursedFlag(oWeapon, TRUE);
		
				if(sWeapon == "prc_sprtwpn_slam")				
				{
					NullifyAppearance(oSummon, TRUE);
					oArmor = CreateItemOnObject("prc_sprtwp_armor", oSummon);
					ForceEquip(oSummon, oWeapon, INVENTORY_SLOT_CWEAPON_R);
					ForceEquip(oSummon, oArmor, INVENTORY_SLOT_CHEST);
					SetItemCursedFlag(oArmor, TRUE);
					
					ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_GLOW_WHITE), oSummon);
					
					ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDamageIncrease(nDamBonus, DAMAGE_TYPE_MAGICAL), oSummon);
					
					itemproperty ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oWeapon, ipDamage, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
                
					itemproperty ipHit = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipHit, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
							
				}
				else if(sWeapon == "nw_wbwln001") //:: Longbow
				{
					NullifyAppearance(oSummon);
					oAmmo1 = CreateItemOnObject("nw_wambo001", oSummon);
					SetItemStackSize(oAmmo1, 99);
					SetDroppableFlag(oAmmo1, FALSE);
					SetItemCursedFlag(oAmmo1, TRUE);

					AddEventScript(oAmmo1, EVENT_ITEM_ONHIT, "prc_evnt_spirwep", TRUE, FALSE);
					SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onHit event script on ammo");						
					
					oAmmo2 = CreateItemOnObject("nw_wambo001", oSummon);
					SetItemStackSize(oAmmo2, 99);
					SetDroppableFlag(oAmmo2, FALSE);
					SetItemCursedFlag(oAmmo2, TRUE);

					AddEventScript(oAmmo2, EVENT_ITEM_ONHIT, "prc_evnt_spirwep", TRUE, FALSE);
					SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onHit event script on ammo");		
					
					ForceEquip(oSummon, oAmmo1, INVENTORY_SLOT_ARROWS);
					ForceEquip(oSummon, oWeapon, INVENTORY_SLOT_RIGHTHAND);
					
					ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDamageIncrease(nDamBonus, DAMAGE_TYPE_MAGICAL), oSummon);
					
					itemproperty ipDamage1 = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oAmmo1, ipDamage1, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipViz1 = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo1, ipViz1, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipHit1 = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo1, ipHit1, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					itemproperty ipNoDam1 = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo1, ipNoDam1, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));					
					
					itemproperty ipDamage2 = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oAmmo2, ipDamage2, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipHit2 = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo2, ipHit2, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipViz2 = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo2, ipViz2, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					itemproperty ipNoDam2 = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo2, ipNoDam2, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));

					itemproperty ipHit3 = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipHit3, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipViz3 = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipViz3, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					itemproperty ipNoDam3 = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipNoDam3, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
				}
				else if(sWeapon == "nw_wbwxl001")  //:: Light crossbow
				{
					NullifyAppearance(oSummon);
					oAmmo1 = CreateItemOnObject("nw_wambo001", oSummon);
					SetItemStackSize(oAmmo1, 99);
					SetDroppableFlag(oAmmo1, FALSE);
					SetItemCursedFlag(oAmmo1, TRUE);

					AddEventScript(oAmmo1, EVENT_ITEM_ONHIT, "prc_evnt_spirwep", TRUE, FALSE);
					SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onHit event script on ammo");						
					
					oAmmo2 = CreateItemOnObject("nw_wambo001", oSummon);
					SetItemStackSize(oAmmo2, 99);
					SetDroppableFlag(oAmmo2, FALSE);
					SetItemCursedFlag(oAmmo2, TRUE);

					AddEventScript(oAmmo2, EVENT_ITEM_ONHIT, "prc_evnt_spirwep", TRUE, FALSE);
					SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onHit event script on ammo");					
					
					ForceEquip(oSummon, oAmmo1, INVENTORY_SLOT_BOLTS);
					ForceEquip(oSummon, oWeapon, INVENTORY_SLOT_RIGHTHAND);
					
					ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDamageIncrease(nDamBonus, DAMAGE_TYPE_MAGICAL), oSummon);
					
					itemproperty ipDamage1 = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oAmmo1, ipDamage1, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipViz1 = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo1, ipViz1, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipHit1 = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo1, ipHit1, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					itemproperty ipNoDam1 = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo1, ipNoDam1, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));					
					
					itemproperty ipDamage2 = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oAmmo2, ipDamage2, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipHit2 = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo2, ipHit2, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipViz2 = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo2, ipViz2, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					itemproperty ipNoDam2 = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo2, ipNoDam2, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));

					itemproperty ipHit3 = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipHit3, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipViz3 = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipViz3, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					itemproperty ipNoDam3 = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipNoDam3, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
				}
				else if(sWeapon == "nw_wthsh001")  //:: Throwing Stars
				{
					NullifyAppearance(oSummon);
					SetItemStackSize(oWeapon, 50);
					SetDroppableFlag(oWeapon, FALSE);
					SetItemCursedFlag(oWeapon, TRUE);	
					
					AddEventScript(oWeapon, EVENT_ITEM_ONHIT, "prc_evnt_spirwep", TRUE, FALSE);
					SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onHit event script on weapon");
					
					object oWeapon2 = CreateItemOnObject("nw_wthsh001", oSummon);
					SetItemStackSize(oWeapon2, 50);
					SetDroppableFlag(oWeapon2, FALSE);
					SetItemCursedFlag(oWeapon2, TRUE);

					AddEventScript(oWeapon2, EVENT_ITEM_ONHIT, "prc_evnt_spirwep", TRUE, FALSE);
					SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onHit event script on weapon");					

					object oWeapon3 = CreateItemOnObject("nw_wthsh001", oSummon);
					SetItemStackSize(oWeapon3, 50);
					SetDroppableFlag(oWeapon3, FALSE);
					SetItemCursedFlag(oWeapon3, TRUE);						
					
					AddEventScript(oWeapon3, EVENT_ITEM_ONHIT, "prc_evnt_spirwep", TRUE, FALSE);
					SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onHit event script on weapon");		
					
					ForceEquip(oSummon, oWeapon, INVENTORY_SLOT_RIGHTHAND);
					
					ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDamageIncrease(nDamBonus, DAMAGE_TYPE_MAGICAL), oSummon);
					
					itemproperty ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oWeapon, ipDamage, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipViz = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipViz, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipHit = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipHit, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					itemproperty ipNoDam = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipNoDam, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));					
					
					ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oWeapon2, ipDamage, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipHit = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon2, ipHit, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipViz = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon2, ipViz, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					ipNoDam = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon2, ipNoDam, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
				}				
				else if(sWeapon == "nw_wthdt001")  //:: Darts
				{
					NullifyAppearance(oSummon);
					SetItemStackSize(oWeapon, 50);
					SetDroppableFlag(oWeapon, FALSE);
					SetItemCursedFlag(oWeapon, TRUE);	
					
					AddEventScript(oWeapon, EVENT_ITEM_ONHIT, "prc_evnt_spirwep", TRUE, FALSE);
					SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onHit event script on weapon");
					
					object oWeapon2 = CreateItemOnObject("nw_wthdt001", oSummon);
					SetItemStackSize(oWeapon2, 50);
					SetDroppableFlag(oWeapon2, FALSE);
					SetItemCursedFlag(oWeapon2, TRUE);

					AddEventScript(oWeapon2, EVENT_ITEM_ONHIT, "prc_evnt_spirwep", TRUE, FALSE);
					SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onHit event script on weapon");					

					object oWeapon3 = CreateItemOnObject("nw_wthdt001", oSummon);
					SetItemStackSize(oWeapon3, 50);
					SetDroppableFlag(oWeapon3, FALSE);
					SetItemCursedFlag(oWeapon3, TRUE);						
					
					AddEventScript(oWeapon3, EVENT_ITEM_ONHIT, "prc_evnt_spirwep", TRUE, FALSE);
					SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onHit event script on weapon");
					
					ForceEquip(oSummon, oWeapon, INVENTORY_SLOT_RIGHTHAND);
					
					ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDamageIncrease(nDamBonus, DAMAGE_TYPE_MAGICAL), oSummon);
					
					itemproperty ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oWeapon, ipDamage, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipViz = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipViz, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipHit = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipHit, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					itemproperty ipNoDam = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipNoDam, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));					
					
					ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oWeapon2, ipDamage, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipHit = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon2, ipHit, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipViz = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon2, ipViz, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					ipNoDam = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon2, ipNoDam, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oWeapon3, ipDamage, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipHit = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon3, ipHit, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipViz = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon3, ipViz, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					ipNoDam = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon3, ipNoDam, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));					
				}				
				else  //:: Covers all other weapons
				{
					NullifyAppearance(oSummon);
					ForceEquip(oSummon, oWeapon, INVENTORY_SLOT_RIGHTHAND);
					
					ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDamageIncrease(nDamBonus, DAMAGE_TYPE_MAGICAL), oSummon);
					
					itemproperty ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oWeapon, ipDamage, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
				
					itemproperty ipViz = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipViz, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
                
					itemproperty ipHit = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipHit, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
				
					itemproperty ipNoDam = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipNoDam, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
				}
				
            }
        }
        i++;
        oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oCaster, i);
    }
}

void HandleSpiritualWeaponUnequipEvent()
{
    // Get the creature who unequipped the item
	object oSummon = GetPCItemLastUnequippedBy();
	object oCaster = GetLocalObject(oSummon, "MY_CASTER");
        
	// Get the item that was unequipped
	object oWeapon = GetPCItemLastUnequipped();
	
	if(GetIsPC(oSummon) == TRUE)
	{
		return;
	}
		
	int nCasterLevel	= PRCGetCasterLevel(oCaster);
	int nDuration		= nCasterLevel;
	int nPenetr			= nCasterLevel + SPGetPenetr();
	int nDamBonus		= PRCMin(5, nCasterLevel / 3);		
	float fDuration 	= IntToFloat(nDuration);
        
	// Log the event for debugging
	SendMessageToPC(oCaster, "prc_spirweap_tbs: Item OnUnEquip Event running.");

	// Check if the item is valid
	if (GetIsObjectValid(oWeapon))
	{
	// Log the item destruction for debugging
		SendMessageToPC(oCaster, "prc_spirweap_tbs: Unequipped item detected. Destroying item.");
            
	// Destroy the unequipped item
		DestroyObject(oWeapon);
			
		string sWeapon = GetSpiritualWeaponTypeByDeity(oCaster);
		object oArmor;
			
		if(!GetIsObjectValid(GetItemPossessedBy(oSummon, sWeapon)))
		{
		//Create item on the creature, equip it and add properties.
			oWeapon = CreateItemOnObject(sWeapon, oSummon);
			
			//Add event scripts
			AddEventScript(oWeapon, EVENT_ITEM_ONHIT, "prc_evnt_spirwep", TRUE, FALSE);
			SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onHit event script on weapon");
			AddEventScript(oWeapon, EVENT_ONHIT, "prc_evnt_spirwep", TRUE, FALSE);
			SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onHit event script on weapon");				
			AddEventScript(oWeapon, EVENT_ITEM_ONUNAQUIREITEM, "prc_evnt_spirwep", TRUE, FALSE);
			SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onUnacquire event script on weapon");
			AddEventScript(oWeapon, EVENT_ITEM_ONPLAYERUNEQUIPITEM, "prc_evnt_spirwep", TRUE, FALSE);
			SendMessageToPC(oCaster, "inc_spirit_weapn: Setting onUnequip event script on weapon");			
				
			// GZ: Fix for weapon being dropped when killed
			SetDroppableFlag(oWeapon, FALSE);
			SetItemCursedFlag(oWeapon, TRUE);
			
			if(sWeapon == "prc_sprtwpn_slam")				
				{
					NullifyAppearance(oSummon, TRUE);
					oArmor = CreateItemOnObject("prc_sprtwp_armor", oSummon);
					ForceEquip(oSummon, oWeapon, INVENTORY_SLOT_CWEAPON_R);
					ForceEquip(oSummon, oArmor, INVENTORY_SLOT_CHEST);
					SetItemCursedFlag(oArmor, TRUE);
					
					ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_GLOW_WHITE), oSummon);
					
					ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDamageIncrease(nDamBonus, DAMAGE_TYPE_MAGICAL), oSummon);
					
					itemproperty ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oWeapon, ipDamage, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
                
					itemproperty ipHit = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipHit, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
							
				}
				else if(sWeapon == "nw_wbwln001") //:: Longbow
				{
					NullifyAppearance(oSummon);
					object oAmmo1 = CreateItemOnObject("nw_wamar001", oSummon);
					SetItemStackSize(oAmmo1, 99);
					SetDroppableFlag(oAmmo1, FALSE);
					SetItemCursedFlag(oAmmo1, TRUE);	
					
					object oAmmo2 = CreateItemOnObject("nw_wamar001", oSummon);
					SetItemStackSize(oAmmo2, 99);
					SetDroppableFlag(oAmmo2, FALSE);
					SetItemCursedFlag(oAmmo2, TRUE);		
					
					ForceEquip(oSummon, oAmmo1, INVENTORY_SLOT_ARROWS);
					ForceEquip(oSummon, oWeapon, INVENTORY_SLOT_RIGHTHAND);
					
					ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDamageIncrease(nDamBonus, DAMAGE_TYPE_MAGICAL), oSummon);
					
					itemproperty ipDamage1 = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oAmmo1, ipDamage1, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipViz1 = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo1, ipViz1, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipHit1 = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo1, ipHit1, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					itemproperty ipNoDam1 = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo1, ipNoDam1, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));					
					
					itemproperty ipDamage2 = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oAmmo2, ipDamage2, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipHit2 = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo2, ipHit2, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipViz2 = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo2, ipViz2, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					itemproperty ipNoDam2 = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo2, ipNoDam2, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));

					itemproperty ipHit3 = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipHit3, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipViz3 = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipViz3, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					itemproperty ipNoDam3 = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipNoDam3, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
				}
				else if(sWeapon == "nw_wbwxl001")  //:: Light crossbow
				{
					NullifyAppearance(oSummon);
					object oAmmo1 = CreateItemOnObject("nw_wambo001", oSummon);
					SetItemStackSize(oAmmo1, 99);
					SetDroppableFlag(oAmmo1, FALSE);
					SetItemCursedFlag(oAmmo1, TRUE);	
					
					object oAmmo2 = CreateItemOnObject("nw_wambo001", oSummon);
					SetItemStackSize(oAmmo2, 99);
					SetDroppableFlag(oAmmo2, FALSE);
					SetItemCursedFlag(oAmmo2, TRUE);		
					
					ForceEquip(oSummon, oAmmo1, INVENTORY_SLOT_BOLTS);
					ForceEquip(oSummon, oWeapon, INVENTORY_SLOT_RIGHTHAND);
					
					ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDamageIncrease(nDamBonus, DAMAGE_TYPE_MAGICAL), oSummon);
					
					itemproperty ipDamage1 = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oAmmo1, ipDamage1, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipViz1 = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo1, ipViz1, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipHit1 = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo1, ipHit1, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					itemproperty ipNoDam1 = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo1, ipNoDam1, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));					
					
					itemproperty ipDamage2 = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oAmmo2, ipDamage2, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipHit2 = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo2, ipHit2, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipViz2 = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo2, ipViz2, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					itemproperty ipNoDam2 = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oAmmo2, ipNoDam2, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));

					itemproperty ipHit3 = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipHit3, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipViz3 = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipViz3, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					itemproperty ipNoDam3 = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipNoDam3, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
				}
				else if(sWeapon == "nw_wthsh001")  //:: Throwing Stars
				{
					NullifyAppearance(oSummon);
					SetItemStackSize(oWeapon, 50);
					SetDroppableFlag(oWeapon, FALSE);
					SetItemCursedFlag(oWeapon, TRUE);	
					
					object oWeapon2 = CreateItemOnObject("nw_wthsh001", oSummon);
					SetItemStackSize(oWeapon2, 50);
					SetDroppableFlag(oWeapon2, FALSE);
					SetItemCursedFlag(oWeapon2, TRUE);	
					
					object oWeapon3 = CreateItemOnObject("nw_wthsh001", oSummon);
					SetItemStackSize(oWeapon3, 50);
					SetDroppableFlag(oWeapon3, FALSE);
					SetItemCursedFlag(oWeapon3, TRUE);
					
					ForceEquip(oSummon, oWeapon, INVENTORY_SLOT_RIGHTHAND);
					
					ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDamageIncrease(nDamBonus, DAMAGE_TYPE_MAGICAL), oSummon);
					
					itemproperty ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oWeapon, ipDamage, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipViz = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipViz, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipHit = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipHit, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					itemproperty ipNoDam = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipNoDam, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));					
					
					ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oWeapon2, ipDamage, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipHit = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon2, ipHit, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipViz = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon2, ipViz, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					ipNoDam = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon2, ipNoDam, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oWeapon3, ipDamage, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipHit = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon3, ipHit, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipViz = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon3, ipViz, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					ipNoDam = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon3, ipNoDam, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));					
				}				
				else if(sWeapon == "nw_wthdt001")  //:: Darts
				{
					NullifyAppearance(oSummon);
					SetItemStackSize(oWeapon, 50);
					SetDroppableFlag(oWeapon, FALSE);
					SetItemCursedFlag(oWeapon, TRUE);	
					
					object oWeapon2 = CreateItemOnObject("nw_wthdt001", oSummon);
					SetItemStackSize(oWeapon2, 50);
					SetDroppableFlag(oWeapon2, FALSE);
					SetItemCursedFlag(oWeapon2, TRUE);		

					object oWeapon3 = CreateItemOnObject("nw_wthdt001", oSummon);
					SetItemStackSize(oWeapon3, 50);
					SetDroppableFlag(oWeapon3, FALSE);
					SetItemCursedFlag(oWeapon3, TRUE);	
					
					ForceEquip(oSummon, oWeapon, INVENTORY_SLOT_RIGHTHAND);
					
					ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDamageIncrease(nDamBonus, DAMAGE_TYPE_MAGICAL), oSummon);
					
					itemproperty ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oWeapon, ipDamage, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipViz = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipViz, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					itemproperty ipHit = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipHit, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					itemproperty ipNoDam = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipNoDam, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));					
					
					ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oWeapon2, ipDamage, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipHit = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon2, ipHit, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipViz = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon2, ipViz, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					ipNoDam = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon2, ipNoDam, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oWeapon3, ipDamage, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipHit = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon3, ipHit, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
					
					ipViz = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon3, ipViz, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));	

					ipNoDam = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon3, ipNoDam, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));						
				}				
				else  //:: Covers all other weapons
				{
					NullifyAppearance(oSummon);
					ForceEquip(oSummon, oWeapon, INVENTORY_SLOT_RIGHTHAND);
					
					ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDamageIncrease(nDamBonus, DAMAGE_TYPE_MAGICAL), oSummon);
					
					itemproperty ipDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, IP_CONST_DAMAGEBONUS_1d8);
					DelayCommand(0.0f, IPSafeAddItemProperty(oWeapon, ipDamage, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
				
					itemproperty ipViz = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipViz, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
                
					itemproperty ipHit = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, nPenetr);
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipHit, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
				
					itemproperty ipNoDam = ItemPropertyNoDamage();
					DelayCommand(0.0f,IPSafeAddItemProperty(oWeapon, ipNoDam, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING));
				}
		}			
		else
		{
			SendMessageToPC(oCaster, "prc_spirweap_tbs: No valid item to destroy.");
		}
        
	return;
    }
}

//:: void main(){}