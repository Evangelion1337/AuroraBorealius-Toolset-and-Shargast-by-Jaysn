/*
   ----------------
   prc_inc_onhit.nss
   ----------------

  functions for instant spell casting
  and onhitcasting

  created April 15, 2007 by motu99  
   */


/**
 * new functions for a highly flexible onhitcast system
 * and for instant spell casting (without having to assign an action)
 * added by motu99; April 15, 2007
 *
 * most of this has been tested; some is still beta
 *
 * In principle these functions should allow us to
 *     i)  instantly cast *any* type of spell listed in spells.2da
 *     ii) put any conceivable spell (and as many as we like) on an item
 *
 *  i) instant spell casting
 * The new functions CastSpellAtObject() and CastSpellAtLocation() will cast any spell listed in spells.2da
 * instantaneously, without having to insert the spell into the action queue of the caster
 * (and thus not knowing when the spell actually will be done, if ever).
 *
 * ii) onhit casting
 * We can now "convert" any type of spell (listed in spells.2da) to an onhitcast spell
 * we can put as many onhitcast spells on an item as we want
 * all onhitcast spells on an item will be cast automatically, when the bearer of the item
 * has scored a hit (item = weapon) or has received a hit (item= armor)
 */

/**
 * Making your spells compatible with PRC instant spell casting
 * using the provided functions CastSpellAtObject() and CastSpellAtLocation()
 *
 * What you have to do:
 *
 *  Insert PRC wrappers into the spell script
 *
 * How do you do it?
 *
 * Edit your spell script, replacing all calls to the spell "information" functions
 *    - GetSpellCastItem,
 *    - GetSpellTargetObject,
 *    - GetSpellTargetLocation,
 *    - GetMetaMagicFeat,
 *    - GetCasterLevel,
 *    - GetSpellID
 *    - GetLastSpellCastClass,
*    - etc.
 * with the respective PRC wrappers
 * [just add "PRC" to the left of the name of the respective "information" function]
 *
 * Nothing else needs to be done
 *
 * However, you might want to check, whether you should use PRC functions for other things,
 * as the Bioware functions don't take the special abilities of the PRC-classes into account.
 * For instance you might want to use:
 *   - PRCDoResistSpell
 *   - PRCMySavingThrow
 *   - PRCGetHasSpell
 *   - PRCGetSpellLevel
 *   - MyFirstObjectInShape
 *   - MyNextObjectInShape
 *   - PRCGetSaveDC
 *   - PRCGetSaveDC
 *   - PRCDoResistSpell
 *   - PRCGetSpellResistance
 *   - etc.
 *
 */

/**
 * Making your onhitcast spells compatible with PRC onhitcast:
 *
 * What you have to do:
 *   i) insert PRC wrappers into the impact spell script
 *   ii) route the impact script through prc_onhitcast
 *   iii) register your onhitcast spell in the (two) 2das
 *   iv) provide a way to place your onhitcast spells on the item
 *   v) provide a way to retrieve the caster level, save dc, etc. from the item
 *
 * How do you do it?
 *
 * i) insert PRC wrappers into the impact spell script
 *     see the isntructions for instant spell casting
 *
 * ii) route the impact script through prc_onhitcast
 * [do this only for onhitcast spells! Not for "normal" spells!]
 *
 * if you want to convert a "normal" spell to an onhitcast spell,
 * it is strongly advised to make a new spell script
 *
 * In order to circumvent the bioware bug, according to
 * which only the first onhitcast spell on an item is executed,
 * we must route all onhitcast spells through prc_onhitcast.
 *
 * This is done very conveniently by placing the following code
 * into the body of the main function of your onhitcast impact spell script:
 *
 *	if(!ContinueOnHitCastSpell()) return;
 *
 * Put this at the very beginning of the main()
 * See "x2_s3_flamingd" for an example
 *
 * iii) register your spell in the 2das
 * [if your spell is operational, you probably have done this before]
 *
 * add a line in the two 2da files
 *  - spells.2da
 *  - iprp_onhitspell.2da
 * look up some onhitcast spells in the 2das to see what must be done
 * see the instructions under iv) for further explanation
 *
 * iv) provide a way to place your onhitcast spells on the item
 * [if your spell is operational you might have done this before]
 *
 * usually the placement of an onhitcast spell on an item is done by a "normal" spell.
 * For instance the "normal" Flame Weapon spell will put a special onhitcast
 * item property on the weapon you targeted with the "normal" spell. The item property
 * has an integer valued subtye, that defines what spell is to be called on a hit.
 * See "x2_s0_enhweap" for an example how to put the onhitcast spell item property
 * on an item.
 *
 * How does the engine find the spell, that it is supposed to call on a hit,
  * from the item property?
 *
 * The integer valued item property subtype specifies a line in iprp_onhitspell.2da.
 * For the flame weapon spell it is line # 124. The column "SpellIndex" in
 * iprp_onhitspell.2da points contains the spellID of the Impact Spell Script. This
 * is the spell script that will be executed on a hit. For the flame weapon spell it is # 696.
* That number specifies a line in spells.2da. This line contains all information about
 * the spell, in particular the name of the spell script that should be executed to actually
 * apply the spell's onhit effects. You find the script's name in the column "ImpactScript".
 * [Note that the flame weapon spell itself occupies a different line # 542 in spells.2da]
 * The impact script for the "onhit" part of the flame weapon spell, as can be read
 * off from the column "ImpactScript" on line #696 of spells.2da is "X2_S3_FlamingD"
 * This is the string we must pass to ExecuteScript() in order to apply the onhitcast spell.
 * [Note that the script name does not distinguish between lower and higher case letters]
 *
 * v) provide a way to retrieve the caster level, save dc, etc. from the item
 * A "problem" in onhit casting is, that the item from which a spell is cast, must not
 * necessarily be in the possession of the caster, who put the spell on the item.
 * It might even be that the caster is not there any more (dead, exited the module)
 * Therefore we must provide a way to retrieve important information about the
 * spell (such as caster level, save DC, metamagics, etc.) from the item. This can
 * be done (in a more or less standard way) via item properties, or (in a non-standard)
 * way by storing the required information in local ints / objects attached to the item.
 * If you place the relevant information as item properties on the item, you can retrieve
 * the information with the standard PRC wrappers PRCGetCasterLevel, PRCGetMetaMagicFeat etc.
 * in the impact spell script. If you place the relevant information in local ints / objects
 * stored on the item, you must set up your impact spell script in a "non-standard" way,
 * so that it retrieves the necessary information via the local variables on the item.
 * The second route has been used for the flame weapon and darkfire impact spell
 * scripts (x2_s3_flamingd, x2_s3_darkfire). The first route might be preferrable
 * when you want to put a "normal" already existing spell on an item and don't want
 * to modify the impact spell script extensively.
*/

//////////////////////////////////////////////////
/* Function Prototypes                          */
//////////////////////////////////////////////////

/**
 * ExecuteSpellScript:
 *
 * instantly executes the spell script sScript via ExecuteScript in the context of oCaster
 * (meaning that oCaster is considered to be the caster)
 * does not perform any checks, whether oCaster can actually cast the spell
 * [You can do the checks in the spell script, for instance by calling X2PreSpellCastCode]
 *
 * Remark motu99:
 * no prespell code, no caster checks: This appears to be the general behavior of most onhitcast spells:
 * As far as I could tell, the onhitcast spells on weapon and armor generally do not call X2PreSpellCastCode
 * and - of course - the caster (or rather the item possessor) must not necessarily have to ability to cast spells
 * (a fighter can use a weapon with "flame weapon" on hit, although it was not *he* who originally
 * put the spell on the weapon) 
 *
 * ExecuteSpellScript sets local override ints/objects/locations on oCaster just before execution 
 * and deletes them immediately after execution.
 * Overrides are generally required, so that the PRC-wrapper functions in the spell scripts can determine
 *   - the target oTarget of the spell (accessed in the spell script via PRCGetSpellTargetObject),
 *   - the location lLocation for an AoE spell (accessed in the spell script via PRCGetSpellTargetLocation)
 *   - the metamagic feat of the spell nMetamagic (accessed in the spell script via PRCGetMetaMagicFeat)
 *   - the casterlevel nCasterLevel (accessed in the spell script via PRCGetCasterLevel)
 *   - the spell cast item oItem (accessed in the spell script via PRCGetSpellCastItem)
 *   - etc.
 *
 * If default values for the parameters oTarget, nMetaMagic, nCasterLevel, oItem etc. are passed to ExecuteSpellScript,
 * it does not set any overrides for the PRC-wrapper functions. In this case you have to rely on the "standard" logic in
 * the PRC wrapper functions to properly determine the correct values.
 * The standard logic generally works fine for nCasterLevel, but might not work as expected for oTarget, nMetaMagic
 * and oItem - depending from where you call ExecuteSpellScript.
 * If you call ExecuteSpellScript from *within a spell script* (so that the PRC - or Bioware's - initialization
 * codes had a chance to set up things nicely) then the spell "information" functions PRCGetSpellTargetObject,
 * PRCGetMetaMagicFeat etc. will most likely return sensible values. (even the Bioware functions might return useful info) 
 * However, if you call ExecuteSpellScript *outside of a spell script*, nobody will have done any setup for you.
 * In that case you are strongly advised to setup things manually, e.g. determine oTarget, nMetaMagic, nCasterLevel,
 * oItem, etc.  on your own and pass them to ExecuteSpellScript without relying on the "standard" logic to do the guessing for you.
 *
 * In principle ExecuteSpellScript(), in combination with the PRC-wrappers, is the only functions you really need for instantaneous spell casting.
 * Most other functions, such as CastSpellAtObject, CastSpellAtLocation are provided as a convenience.
 * They mimic the behavior of Bioware's ActionCastSpell* commands. They all eventually call ExecuteSpellScript
 */
void ExecuteSpellScript(string sScript, location lTargetLocation, object oTarget = OBJECT_INVALID, int nSpellID = 0, int nMetaMagic = METAMAGIC_ANY, int nCasterLevel = 0, int nCasterClass = 0, int nSaveDC = 0, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF);

/**
 * CastSpellAtObject:
 *
 * similar to Bioware's ActionCastSpellAtObject
 *
 * Will instantaneously cast the spell with index iSpellNr at oTarget
 * The spell is not inserted into the action queue of oCaster, no checks whether oCaster can actually cast the spell
 * oTarget is the spell's target, oItem (if required) the item from which the spell is cast, oCaster (or OBJECT_SELF) is considered to be the caster
 * tested for flame weapon and darkfire impact spell scripts, but should eventually work for all spells (see below)
 *
 * in order to work, the spell scripts associated with iSpellNr (via spells.2da) must  use the PRC-wrapper functions!!!
 * Besides the established wrappers (PRCGetSpellTargetObject, PRCGetCasterLevel, PRCGetMetaMagicFeat, PRCGetSpellId etc.)
 * we need a new PRC-wrapper function to replace SpellCastItem(). Not surprising the wrapper is named PRCGetSpellCastItem()
 * It would be a good idea for any spell coder, who wants to remain compatible with the PRC, to check his spell scripts,
 * whether all calls to Bioware's spell information functions have been replaced by the respective PRC wrapper functions.
 * [As far as I could tell, this is not done consistently]
 *
 * If default values for oTarget, nMetaMagic, nCasterLevel and oItem are supplied, no override variables are set
 * In this case the PRC-wrapper functions (or Bioware's original functions) must determine the SpellTargetObject,
 * the SpellCastItem etc. through their "standard" logic. This might or might not work.
 * For more information see the description in ExecuteSpellScript()
 */
void CastSpellAtObject(int nSpellID, object oTarget = OBJECT_INVALID, int nMetaMagic = METAMAGIC_ANY, int nCasterLevel = 0, int nCasterClass = 0, int nSaveDC = 0, object oItem = OBJECT_INVALID, object oCaster = OBJECT_SELF);

// instantaneously casts an area of effect spell at location lTargetLocation
// works similar to ActionCastSpellAtLocation, but casts the spell instantly
// See the description of CastSpellAtObject, how instant spell casting work
void CastSpellAtLocation(int nSpellID, location lTargetLocation, int nMetaMagic = METAMAGIC_ANY, int nCasterLevel = 0, int nCasterClass = 0, int nSaveDC = 0, object oItem = OBJECT_INVALID, object oCaster = OBJECT_SELF);

// applies the onhitcast spell with subtype iSubType (situated on oItem ) to oTarget
// will look up the spell script that must be executed through "iprp_onhitspell.2da" and "spells.2da"
// if default values for oTarget, oItem are supplied, no override variables are set
// for more information see the description in ExecuteSpellScript()
void ApplyOnHitCastSpellSubType(int iSubType, object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF);

// applies the onhitcast spell darkdire (situated on oItem) to oTarget
// will look up the spell script that must be executed through "iprp_onhitspell.2da" and "spells.2da"
// if default values for oTarget, oItem are supplied, no override variables are set
// for more information see the description in ExecuteSpellScript()
void ApplyOnHitDarkfire(object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF);

// applies the onhitcast spell flame weapon (situated on oItem) to oTarget
// will look up the spell script that must be executed through "iprp_onhitspell.2da" and "spells.2da"
// if default values for oTarget, oItem are supplied, no override variables are set
// for more information see the description in ExecuteSpellScript()
void ApplyOnHitFlameWeapon(object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF);

// applies the onhitcast spell unique power (situated on oItem) to oTarget
// actually this will call the script "prc_onhitcast" (hardcoded), e.g. it will *not* look up the 2das (as the other functions do)
// if default values for oTarget, oItem are supplied, no override variables are set
// for more information see the description in ExecuteSpellScript()
void ApplyOnHitUniquePower(object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF);

// applies all on hit cast spells on oItem to oTarget
// will look up the spell scripts that must be executed in "iprp_onhitspell.2da" and "spells.2da"
// Uses a "safe" to cycle through the item properties, without interfering with any other loops
// over item properties (that for instance could be initiated in the spell scripts)
// Always use this function to cycle through and execute several onhitcast spells on an item!!
// If default values for oTarget, oItem are supplied, no override variables are set
// for more information see the description in ExecuteSpellScript()
void ApplyAllOnHitCastSpellsOnItem(object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF);

// applies all on hit cast spells on oItem, excluding any spell-subtype given in iExcludeSubType, to oTarget
// will look up the spell script that must be executed in "iprp_onhitspell.2da" and "spells.2da"
// Uses a "safe" to cycle through the item properties, without interfering with any other loops
// over item properties (that for instance could be initiated in the spell scripts)
// Always use this function to cycle through and execute several onhitcast spells on an item!!
// if default values for oTarget, oItem are supplied, no override variables are set
// for more information see the description in ExecuteSpellScript()
void ApplyAllOnHitCastSpellsOnItemExcludingSubType(int iExcludeSubType, object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF);

// returns True, if oItem has at least one onhitcast spell on it (can be any subtype)
int GetHasOnHitCastSpell(object oItem);

// returns True, if the oItem has an onhitcast spell with the given subtype
int GetHasOnHitCastSpellSubType(int iSubType, object oItem);

// returns True, if we have the onhit flame weapon spell on oItem
int GetHasOnHitFlameWeapon(object oItem);

// returns True, if we have the onhit darkfire spell on oItem
int GetHasOnHitDarkfire(object oItem);

// returns True, if we have the onhit unique power spell on oItem
int GetHasOnHitUniquePower(object oItem);

// returns true, when prc_onhitcast is running, e.g. the spell script is called from there
int GetIsPrcOnhitcastRunning(object oSpellOrigin = OBJECT_SELF);

// to be used ONLY in "pure" on-hit cast spell scripts, in order to route all
// onhitcast spells through the unique power script (prc_onhitcast)
// This function should be placed at the beginning of any pure onhitcast spell script
// If the onhitcast spell script contains a call to X2PreSpellCastCode(), replace that call with a call to ContinueOnHitCastSpell()
// This code needs to be in the spell script, in order to neutralize a Biobug
// (Bioware only executes the first onhitcast spell found on an item)
// Checks the local int "prc_ohc"; if it does not find the int, it assumes the spell script was called
// directly by the aurora engine. In that case it will call prc_onhitcast and return FALSE,
// FALSE meaning that the spell script should be aborted
// if the function returns TRUE; the spell script was called from prc_onhitcast. In this case prc_onhitcast
// guarantees the execution of all onhitcast spells on an item, so the spell script should continue to run
/**
 * Remark motu99:
 * The behavior of ContinueOnHitCastSpell is very similar to that of X2PreSpellCastCode()
 * In fact, it should replace any instances of  X2PreSpellCastCode() for "pure" onhitcast spells.
 * 
 * For spells that are not exclusively onhitcast spells (e.g. normal spells that some mages
 * can put on a weapon), we should not use ContinueOnHitCastSpell, but rather call X2PreSpellCastCode.
 * In this case  X2PreSpellCastCode (in x2_inc_spellhook) will have to check, whether the spell script was
 * called via an onhitcast event connected to a successful physical attack and route to prc_onhitcast in such a case
 * (Such a general check from X2PreSpellCastCode is not 100% reliable, because of Biowares buggy implementation.
 * However, the function GetIsOnHitCastSpell() provided here will do a very good job at guessing.)
 *
 * For pure onhitcast spells it is safer and much more efficient to use ContinueOnHitCastSpell instead
 * of X2PreSpellCastCode.
 */
int ContinueOnHitCastSpell(object oSpellOrigin = OBJECT_SELF);

// Checks, whether the spell just running is an onhitcast spell, cast from an item
// Function is to be used in X2PreSpellCastCode() for any onhitcast specific modifications
// (its main use is to fix the Bioware bug, that runs only the first onhitcast spell on a weapon or armor)
// The check is not 100% reliable, because Bioware does not delete the spellcastitem after a spell code has finished.
// So if GetSpellCastItem returns a valid item, we still don't know if we are running an onhitcast event,
// even if the item is a weapon or armor. The item could be an old item used in a previous spell script.
// (for instance, sequencer's robes count as armor)
// In order to find out, whether the spell was actually cast from a weapon/armor in a physical attack action
// we check whether the current action is ACTION_ATTACKOBJECT and whether the attempted attack
// target is equal to the spell's target
int GetIsOnHitCastSpell(object oSpellTarget = OBJECT_INVALID, object oSpellCastItem = OBJECT_SELF, object oSpellOrigin = OBJECT_SELF);

// this will force the instantaneous execution of any onhitcast spell script, even if it is set up to be
// routed through prc_onhitcast (for more info on forced execution look at the code of ContinueOnHitCastSpell)
// For more info on functionality, see the description/code of ExecuteSpellScript()
void ForceExecuteSpellScript(string sScript, location lTargetLocation, object oTarget = OBJECT_INVALID, int nSpellID = 0, int nMetaMagic = METAMAGIC_ANY, int nCasterLevel = 0, int nCasterClass = 0, int nSaveDC = 0, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF);

// this will force the instantaneous execution of any onhitcast spell script with iSpellNr, as given in spells.2da
// The spell script will be executed, even if it has been set up to be routed through prc_onhitcast
// (for more info on forced execution look at the code of ContinueOnHitCastSpell)
// for more info on functionality, see the description/code of CastSpellAtObject
void ForceCastSpellAtObject(int nSpellID, object oTarget = OBJECT_INVALID, int nMetaMagic = METAMAGIC_ANY, int nCasterLevel = 0, int nCasterClass = 0, int nSaveDC = 0, object oItem = OBJECT_INVALID, object oCaster = OBJECT_SELF);
void ForceCastSpellAtLocation(int nSpellID, location lTargetLocation, int nMetaMagic = METAMAGIC_ANY, int nCasterLevel = 0, int nCasterClass = 0, int nSaveDC = 0, object oItem = OBJECT_INVALID, object oCaster = OBJECT_SELF);

// forces the instantaneous application of the onhitcast spell with subtype iSubType (situated on oItem) to oTarget
// will force apply the spell scripts even if they have internally been set up to be routed through prc_onhitcast
// (for more info on forced execution look at the code of ContinueOnHitCastSpell)
// for more info on functionality, see the description/code of ApplyOnHitCastSpellSubType
void ForceApplyOnHitCastSpellSubType(int iSubType, object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF);

// instantaneously applies all on hit cast spells on oItem to oTarget
// will force apply the spell scripts even if they have internally been set up to be routed through prc_onhitcast
// (for more info on forced execution look at the code of ContinueOnHitCastSpell)
// for more info on functionality, see the description/code of ApplyAllOnHitCastSpellsOnItem
// This is the safe way to loop through the item properties, without interfering with any other loops over item properties in the spell scripts
void ForceApplyAllOnHitCastSpellsOnItem(object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF);

// most likely we will never need the following function:
// instantaneously applies all on hit cast spells on oItem, excluding any spell-subtype given in iExcludeSubType, to oTarget
// will force apply the spell scripts even if they have internally been set up to be routed through prc_onhitcast
// (for more info on forced execution look at the code of ContinueOnHitCastSpell)
// for more info on functionality, see the description/code of ApplyAllOnHitCastSpellsOnItemExcludingSubType
// Uses a "safe" way to loop through the item properties, without interfering with any other loops over item properties in the spell scripts
void ForceApplyAllOnHitCastSpellsOnItemExcludingSubType(int iExcludeSubType, object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF);

//////////////////////////////////////////////////
/* Includes                                     */
//////////////////////////////////////////////////

#include "inc_abil_damage"


//////////////////////////////////////////////////
/* Function Definitions                         */
//////////////////////////////////////////////////

/**
 * ExecuteSpellScript
 * executes the spell script sScript via ExecuteScript in the context of oCaster
 * sets local override ints/objects on oCaster before execution (and deletes them immediately after execution)
 * oTarget, nMetaMagic, nCasterLevel, oItem, nSpellID, nCasterClass, lTargetLocation
 * can be accessed in the spell script via PRC-wrappers
 *
 * known caveats:
 * Using calls to PRCGetMetaMagicFeat() in onhitcast spells can be dangerous, because PRCGetMetaMagicFeat()
 * will cycle through the item properties in order to find out whether there are any properties
 * of the type ITEM_PROPERTY_CAST_SPELL_METAMAGIC. This is problematic, because prc_onhitcast must also
 * cycle through the item properties, in order to find out what onhitcast spells are on the item.
 * If we are not careful, we might find ourselves with two nested loops over item properties. But the current implementation
 * of GetFirstItemProperty and GetNextItemProperty does not allow nested loops. Nested loops generally result
 * in unpredictable behavior (such as infinitely returning the same item property on GetNextItemProperty)
 *
 * Remark motu99:
 * The above described problem ALWAYS occurs when there are nested loops over item properties or effects.
 * Therefore generally it is a bad idea to call anything complicated (e.g. a spell script!) within a loop over item properties
 * or effects, in particular if you don't know every detail of the so called function. If the called function contains just
 * one single call to GetFirst* or GetNext* (this could happen deep in the function's code - possibly in a utility function
 * several calling levels deeper), this will mess up your next call to GetNext*.
 * I provided a "safe" way to cycle through all onhitcast spells on an item: ApplyAllOnHitCastSpellsOnItem
 *
 * known limitations:
 * some spell scripts need the cast class (e.g. did we cast the spell as a cleric, a wizard, a druid etc.)
 * in instantaneous casting we do not select the spell from a spellbook (which is always tied to a certain class), so that the aurora
 * engine cannot set a sensible value for GetLastSpellCastClass(). Thus, if the spell script needs it, we must determine the cast
 * class ourselves, pass it to ExecuteSpellScript and make sure we call the PRC wrapper PRCGetLastSpellCastClass in the spell script
 *
 * In the current implementation the spell's save DC is not calculated correctly. It generally returns the minimum DC.
 * The reason is, that PRCGetSaveDC (in prc_add_spell_dc.nss) has not yet been updated to handle instant spell casting.
 * In particular, PRCGetSaveDC calls Biowares GetSpellDC(), which returns the minimum DC when called *outside* a
 * spell script. As instant spellcasting is usually called from outside a spell script, we get only get the minimum DC.
 * @TODO: In order to determine the correct DC, we need to know the casting class [this will anable us to select the
 * correct ability adjustments - for instance INT for Wizards, CHA for sorcerers, etc.]. So whenever there is a
 * cast class override, we should not call Bioware's GetSpellDC, but rather calculate the DC directly.
 * 
 * some spell scripts need the spell ID. It is automatically set by CastSpellAtObject or CastSpellAtLocation. We can set it in
 * ExecuteSpellScript as well.
 *
 * some spell scripts make calls to GetLastSpell(). We might need a PRC wrapper to catch those.
 * In any case, PRCGetSpellId will give us the correct spell ID. GetLastSpell seems to be used in OnSpellCastAt events
 * From the NWNLexicon: GetLastSpell is for use in OnSpellCastAt script, it gets the ID (SPELL_*) of the spell that was cast.
 * It will not return the true spell value, but whatever value is put into the EventSpellCastAt() - therefore, sub-dial spells like
 * Polymorph will mearly return SPELL_POLYMORPH not the sub spell number
 *
 * some spell scripts make calls to GetLastSpellCaster(). In a spell script OBJECT_SELF should be the caster. Its not clear
 * what a call to GetLastSpellCaster() will return. Might have to look into this
 *
 */
void ExecuteSpellScript(string sScript, location lTargetLocation, object oTarget = OBJECT_INVALID, int nSpellID = 0, int nMetaMagic = METAMAGIC_ANY, int nCasterLevel = 0, int nCasterClass = 0, int nSaveDC = 0, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF)
{
	if(DEBUG) DoDebug("ExecuteSpellScript: executing script "+sScript);

	// create an invalid location by not assigning anything to it (hope this works)
	location lInvalid;

	// tell the impact spell script where the target area is
	if (lTargetLocation != lInvalid)
	{
		SetLocalInt(oCaster, PRC_SPELL_TARGET_LOCATION_OVERRIDE, TRUE);
		SetLocalLocation(oCaster, PRC_SPELL_TARGET_LOCATION_OVERRIDE, lTargetLocation);
	}

	// tell the impact spell script who the target is
	if (oTarget != OBJECT_INVALID)
		SetLocalObject(oCaster, PRC_SPELL_TARGET_OBJECT_OVERRIDE, oTarget);

	// tell the impact spell script what the spell cast item is
	if (oItem != OBJECT_SELF)
	{
//DoDebug("ExecuteSpellScript: setting override spell cast item = "+GetName(oItem));
		if (oItem == OBJECT_INVALID)
			SetLocalObject(oCaster, PRC_SPELLCASTITEM_OVERRIDE, oCaster);
		else
			SetLocalObject(oCaster, PRC_SPELLCASTITEM_OVERRIDE, oItem);
	}
		
	// override the caster level, but only if necessary
	if (nCasterLevel)
		SetLocalInt(oCaster, PRC_CASTERLEVEL_OVERRIDE, nCasterLevel);

	// tell the impact spell script the metamagic we want to use
	if (nMetaMagic != METAMAGIC_ANY)
		SetLocalInt(oCaster, PRC_METAMAGIC_OVERRIDE, nMetaMagic);

	// tell the impact spell script the spellID we want to use
	// check for zero is problematic becauseSPELL_ACID_FOG == 0
	if (nSpellID)
		SetLocalInt(oCaster, PRC_SPELLID_OVERRIDE, nSpellID);

	// tell the impact spell script the caster class we want to use
	// check for zero is problematic, because CLASS_TYPE_BARBARIAN == 0
	// But Barbarians cannot cast spells (UMD? SPA?), so this should work
	if (nCasterClass)
		SetLocalInt(oCaster, PRC_CASTERCLASS_OVERRIDE, nCasterClass);

	if (nSaveDC)
		SetLocalInt(oCaster, PRC_SAVEDC_OVERRIDE, nSaveDC);
	
	// execute the impact spell script in the context of oCaster
	ExecuteScript(sScript, oCaster);

/**
 * motu99: If we were paranoid, we could delete all local ints and objects, regardless if we set them beforehand,
 * as a "countermeasure" against any future scripter, who might disregard the given advise, set the overrides manually
 * and then forget to delete them.
 * However, as long as scripters follow the advise, and use ExecuteSpellScript and the other functions provided here,
 * never manually setting the overrides, we can be sure, that these variables are not misused.
 * In the unlikely case that somebody did not play by the rules, and managed to break "normal" spell casting by improperly
 * using the overrides, and we cannot locate where and what he did, we might have to resort to the last measure, deleting
 * all overrides on every call to ExecuteSpellScript() and ExecuteAoESpellScript()
 * If we delete the overrides indiscriminately, we MUST ALWAYS call ExecuteSpellScript with NON-DEFAULT values.
 * Otherwise we are in trouble when we do multiple calls to ExecuteScript from a loop: We might accidentally delete
 * any overrides that we set on some previous call to ExecuteSpellScript. At that point we are at the mercy of
 * Bioware's functions to provide the correct values, which does not always work (to put it mildly)
 * Note that some measure of safety is provided through the fact, that we set the overrides on oCaster, and not on the module
*/
	// cleanup (we only delete those locals that we set before)
	if (lTargetLocation != lInvalid)
	{
		DeleteLocalInt(oCaster, PRC_SPELL_TARGET_LOCATION_OVERRIDE);
		// DeleteLocalLocation(oCaster, PRC_SPELL_TARGET_LOCATION_OVERRIDE);
	}

	if (oItem != OBJECT_SELF)
		DeleteLocalObject(oCaster, PRC_SPELLCASTITEM_OVERRIDE);

	if (oTarget != OBJECT_INVALID)
		DeleteLocalObject(oCaster, PRC_SPELL_TARGET_OBJECT_OVERRIDE);

	if (nMetaMagic != METAMAGIC_ANY)
		DeleteLocalInt(oCaster, PRC_METAMAGIC_OVERRIDE);

	if (nCasterLevel)
		DeleteLocalInt(oCaster, PRC_CASTERLEVEL_OVERRIDE);

	if (nSpellID)
		DeleteLocalInt(oCaster, PRC_SPELLID_OVERRIDE);

	if (nCasterClass)
		DeleteLocalInt(oCaster, PRC_CASTERCLASS_OVERRIDE);

	if (nSaveDC)
		DeleteLocalInt(oCaster, PRC_SAVEDC_OVERRIDE);

	if (DEBUG) DoDebug("ExecuteSpellScript: done executing script "+sScript);
}

// ExecuteSpellScript will set PRC_SPELLID_OVERRIDE, so that we know what spell we are casting
// However, SPELL_ACID_FOG has a SpellID of zero, so we might have problems with this particular spell
void CastSpellAtObject(int nSpellID, object oTarget = OBJECT_INVALID, int nMetaMagic = METAMAGIC_ANY, int nCasterLevel = 0, int nCasterClass = 0, int nSaveDC = 0, object oItem = OBJECT_INVALID, object oCaster = OBJECT_SELF)
{
	// get the name of the impact spell script (for ExecuteScript)
	// nSpellID points to a row in spells.2da
	string sScript = Get2DACache("spells", "ImpactScript", nSpellID);

	if(sScript == "" || sScript == "****")
		return;

	// create an invalid location
	location lInvalid;
	
	// execute the spell script
	ExecuteSpellScript(sScript, lInvalid, oTarget, nSpellID, nMetaMagic, nCasterLevel, nCasterClass, nSaveDC, oItem, oCaster);
}

// works similar to ActionCastSpellAtLocation, only casts spell instantly (without saving throw etc.
// See description of CastSpellAtObject, how instant spells work
void CastSpellAtLocation(int nSpellID, location lTargetLocation, int nMetaMagic = METAMAGIC_ANY, int nCasterLevel = 0, int nCasterClass = 0, int nSaveDC = 0, object oItem = OBJECT_INVALID, object oCaster = OBJECT_SELF)
{
	// get the name of the impact spell script (for ExecuteScript)
	string sScript = Get2DACache("spells", "ImpactScript", nSpellID);

	if(sScript == "" || sScript == "****")
		return;

	// execute the spell script
	ExecuteSpellScript(sScript, lTargetLocation, OBJECT_INVALID, nSpellID, nMetaMagic, nCasterLevel, nCasterClass, nSaveDC, oItem, oCaster);
}

void ApplyOnHitCastSpellSubType(int iSubType, object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF)
{
	// get the spellID of the onhitspell
	int iSpellID = StringToInt( Get2DACache("iprp_onhitspell", "SpellIndex", iSubType) );

	// now execute the impact spell script
	CastSpellAtObject(iSpellID, oTarget, METAMAGIC_ANY, 0, 0, 0, oItem, oCaster);
}

void ApplyOnHitDarkfire(object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF)
{
	ApplyOnHitCastSpellSubType(IP_CONST_ONHIT_CASTSPELL_ONHIT_DARKFIRE, oTarget, oItem, oCaster);
}

void ApplyOnHitFlameWeapon(object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF)
{
	ApplyOnHitCastSpellSubType(IP_CONST_ONHIT_CASTSPELL_ONHIT_FIREDAMAGE, oTarget, oItem, oCaster);
}

void ApplyOnHitUniquePower(object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF)
{
	location lInvalid;
	// ApplyOnHitCastSpellSubType(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, oTarget, METAMAGIC_ANY, 0, oItem, oCaster);
	// unique power hardwired to "prc_onhitcast". If we want to go through the 2das, we should revert to the commented out line of code above
	ExecuteSpellScript("prc_onhitcast", lInvalid, oTarget, 0, METAMAGIC_ANY, 0, 0, 0, oItem, oCaster);
}

void ApplyAllOnHitCastSpellsOnItem(object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF)
{
	int iSubType;
	int iNr = 0;
    if(!array_exists(oCaster, "ohspl"))
        array_create(oCaster, "ohspl");

	// remember the item that was passed to the function (in case it is invalid we simply pass it through to the function that does the spells)
	object oItemPassed = oItem;
	
	// we need an item in order to cycle over item properties
	// if OBJECT_INVALID  was given, we must use the "standard" logic in PRCGetSpellCastItem to determine the item
	if (oItem == OBJECT_SELF)
		oItem = PRCGetSpellCastItem(oCaster);

	itemproperty ip = GetFirstItemProperty(oItem);

	while(GetIsItemPropertyValid(ip))
	{
// DoDebug("ApplyAllOnHitCastSpellsExcludingSubType: found " + DebugIProp2Str(ip));
		if (GetItemPropertyType(ip) ==ITEM_PROPERTY_ONHITCASTSPELL)
		{
			// retrieve the spell ID
			iSubType = GetItemPropertySubType(ip);
			// we found a new onhit spell, so increment iNr
			iNr++;
			// store the spell ID in an array and execute the spell later, this is safer than trying to execute the spell script directly
			// lets hope that nobody else uses our name "ohspl" for the array
			array_set_int(oCaster, "ohspl", iNr, iSubType);
		}
		ip = GetNextItemProperty(oItem);
	}
	
	// now execute the spell scripts (note that the local array will not be deleted) 
	while (iNr)
	{
		iSubType = array_get_int(oCaster, "ohspl", iNr);
//DoDebug("ApplyAllOnHitCastSpellsExcludingSubType: executing onhitcastspell subtype # " + IntToString(iSubType));
		ApplyOnHitCastSpellSubType(iSubType, oTarget, oItemPassed, oCaster);
		iNr--;
	}	
    array_delete(oCaster, "ohspl");
}

void ApplyAllOnHitCastSpellsOnItemExcludingSubType(int iExcludeSubType, object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF)
{
	int iSubType;
	int iNr = 0;
    if(!array_exists(oCaster, "ohspl"))
        array_create(oCaster, "ohspl");

	// remember the item that was passed to the function (in case it is invalid we pass it through to the spell cast functions)
	object oItemPassed = oItem;
	
	if (oItem == OBJECT_SELF)
	{
		oItem = PRCGetSpellCastItem(oCaster);
//DoDebug("ApplyAllOnHitCastSpellsOnItemExcludingSubType: item = OBJECT_SELF, determining item by standard logic, item = " +GetName(oItem));
	}

	itemproperty ip = GetFirstItemProperty(oItem);

	while(GetIsItemPropertyValid(ip))
	{
// DoDebug("ApplyAllOnHitCastSpellsExcludingSubType: found " + DebugIProp2Str(ip));
		if (GetItemPropertyType(ip) ==ITEM_PROPERTY_ONHITCASTSPELL)
		{
			iSubType = GetItemPropertySubType(ip);
			if(iSubType == iExcludeSubType) // if(iSubType ==IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER) // == 125
            {
                ip = GetNextItemProperty(oItem);
                continue; //skip over OnHit:CastSpell:UniquePower otherwise it would TMI.
            }
			// we found a new onhit spell, so increment iNr
			iNr++;
			// store the spell ID in an array and execute the spell later, this is safer than trying to execute the spell script directly
			// lets hope that nobody else uses our name "ohspl" for the array
			array_set_int(oCaster, "ohspl", iNr, iSubType);
		}
		ip = GetNextItemProperty(oItem);
	}
	
	// now execute the spell scripts (note that the local array will not be deleted) 
	while (iNr)
	{
		iSubType = array_get_int(oCaster, "ohspl", iNr);
//DoDebug("ApplyAllOnHitCastSpellsExcludingSubType: executing onhitcastspell subtype # " + IntToString(iSubType));
		ApplyOnHitCastSpellSubType(iSubType, oTarget, oItemPassed, oCaster);
		iNr--;
	}	
    array_delete(oCaster, "ohspl");
}

// returns true, if oItem has at least one onhitcast spell (of any subtype)
int GetHasOnHitCastSpell(object oItem)
{	
	itemproperty ip = GetFirstItemProperty(oItem);

	while(GetIsItemPropertyValid(ip))
	{
		if (GetItemPropertyType(ip) ==ITEM_PROPERTY_ONHITCASTSPELL)
		{
				return TRUE;
		}
		ip = GetNextItemProperty(oItem);
	}
	return FALSE;
}

// returns true, if oItem has an onhitcast spell with the given subtype
int GetHasOnHitCastSpellSubType(int iSubType, object oItem)
{	
	itemproperty ip = GetFirstItemProperty(oItem);

	while(GetIsItemPropertyValid(ip))
	{

		if (GetItemPropertyType(ip) ==ITEM_PROPERTY_ONHITCASTSPELL
			&& GetItemPropertySubType(ip) == iSubType)
		{
				return TRUE;
		}
		ip = GetNextItemProperty(oItem);
	}
	return FALSE;
}

// returns True, if we have the onhit flame weapon spell on the item
int GetHasOnHitFlameWeapon(object oItem)
{
	return GetHasOnHitCastSpellSubType(IP_CONST_ONHIT_CASTSPELL_ONHIT_FIREDAMAGE, oItem);
}

// returns True, if we have the onhit darkfire spell on the item
int GetHasOnHitDarkfire(object oItem)
{
	return GetHasOnHitCastSpellSubType(IP_CONST_ONHIT_CASTSPELL_ONHIT_DARKFIRE, oItem);
}

// returns True, if we have the onhit unique power spell on the item
int GetHasOnHitUniquePower(object oItem)
{
	return GetHasOnHitCastSpellSubType(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, oItem);
}


int GetIsPrcOnhitcastRunning(object oSpellOrigin = OBJECT_SELF)
{
	return GetLocalInt(oSpellOrigin, "prc_ohc");
}


// to be used only in on-hit cast spell scripts, in order to route the spell through the unique power script (prc_onhitcast)
int ContinueOnHitCastSpell(object oSpellOrigin = OBJECT_SELF)
{
	// if the local int "frc_ohc" is on, then we never route the spell through prc_onhitcast
	// rather we continue the execution of the onhitcast script; so return True in this case
	if (GetLocalInt(oSpellOrigin, "frc_ohc"))
	{
		// signal to caller that it can continue execution (no rerouting to prc_onhitcast)
		return TRUE;
	}

	// now check whether we were called from prc_onhitcast
	int bCalledByPRC = GetIsPrcOnhitcastRunning(oSpellOrigin);

	// if not, call prc_onhitcast
	if (!bCalledByPRC)
	{
		if (DEBUG) DoDebug("onhitcast spell script not called through prc_onhitcast - now routing to prc_onhitcast");
		ExecuteScript("prc_onhitcast", oSpellOrigin);
	}
	// signal to calling function, whether it should terminate execution, because we rerouted the call (e.g. bCalledByPRC=FALSE)
	// or whether it should continue execution, because we were called from prc_onhitcast (e.g. bCalledByPRC=TRUE)
	return bCalledByPRC;
}


// Checks, whether the spell just running is an onhitcast spell, cast from  an item (weapon or armor) during an attack action
// Due to Biowares buggy implementation the check is not 100% reliable
int GetIsOnHitCastSpell(object oSpellTarget = OBJECT_INVALID, object oSpellCastItem = OBJECT_SELF, object oSpellOrigin = OBJECT_SELF)
{
	// determine spell cast item (if not already given) 
	if (oSpellCastItem == OBJECT_SELF)
		oSpellCastItem = PRCGetSpellCastItem(oSpellOrigin);
	
	// spell cast item must be valid (but it could still be an item from a previous item spell)
	if (!GetIsObjectValid(oSpellCastItem))
	{
		if (DEBUG) DoDebug("GetIsOnHitCastSpell: no valid spell cast item, returning FALSE");
		return FALSE;
	}

	// onhitcasting affects weapons and armor; find out which
	int iBaseType = GetBaseItemType(oSpellCastItem);

	object oAttacker;
	object oDefender;
	int iWeaponType;
	
	// is the spellcast item an armor?
	// Then it could be  an onhitcast event from the armor of the defender
	// the aurora engine executes the onhitcast spell in the context of the bearer of the armor, e.g. the defender
	if (iBaseType == BASE_ITEM_ARMOR)
	{
		
		// find the target, if not already given
		if (oSpellTarget == OBJECT_INVALID)
			oSpellTarget = PRCGetSpellTargetObject(oSpellOrigin);

		// the spell target of the armor onhitspell is the melee attacker (e.g. oSpellTarget = melee attacker).
		// The aurora engine exeutes the onhit spell in the context of the melee defender (e.g. oSpellOrigin = melee defender)
		oAttacker = oSpellTarget;
		oDefender = oSpellOrigin;		

		if (DEBUG) DoDebug("GetIsOnHitCastSpell: item "+GetName(oSpellCastItem)+" is armor; attacker = "+GetName(oAttacker)+", defender = "+GetName(oDefender));
	}
	// is the spell type item a weapon?
	int nWT = StringToInt(Get2DACache("baseitems", "WeaponType", iBaseType));
	if (nWT > 0)
	{
		if (oSpellTarget == OBJECT_INVALID)
			oSpellTarget = PRCGetSpellTargetObject(oSpellOrigin);

		oAttacker = oSpellOrigin;
		oDefender = oSpellTarget;

		if (DEBUG) DoDebug("GetIsOnHitCastSpell: item "+GetName(oSpellCastItem)+" is weapon [WT="+IntToString(nWT)+"]; attacker="+GetName(oAttacker)+", defender="+GetName(oDefender));
	}
	else
	{
		if (DEBUG) DoDebug("GetIsOnHitCastSpell: item "+GetName(oSpellCastItem)+" is neither weapon nor armor; returning FALSE");
		return FALSE;
	}
		
/* 	else if (iWeaponType == StringToInt(Get2DACache("baseitems", "WeaponType", iBaseType)))
	{		
		// determine the target, if not already given
		if (oSpellTarget == OBJECT_INVALID)
			oSpellTarget = PRCGetSpellTargetObject(oSpellOrigin);

		oAttacker = oSpellOrigin;
		oDefender = oSpellTarget;

		if (DEBUG) DoDebug("GetIsOnHitCastSpell: item "+GetName(oSpellCastItem)+" is weapon [#"+IntToString(iWeaponType)+"]; attacker = "+GetName(oAttacker)+", defender = "+GetName(oDefender));		
	}
	else
	{
		if (DEBUG) DoDebug("GetIsOnHitCastSpell: item "+GetName(oSpellCastItem)+" is neither weapon nor armor; returning FALSE");		
		return FALSE;
	} */


	// the spell origin must possess the item that cast the spell (at least for the aurora engine, in prc_inc_combat that may differ)
	if (GetItemPossessor(oSpellCastItem) != oSpellOrigin)
	{
		if (DEBUG) DoDebug("GetIsOnHitCastSpell: the spell cast item is not in the possession of the creature in which context the spell is executed");
		return FALSE;
	}

	// the attacker must be physically attacking (only then onhitcasting makes sense)
	// however, Bioware seems to set the action to ACTION_INVALID during the spell script
	int iAction = GetCurrentAction(oAttacker);
	if (DEBUG) DoDebug("GetIsOnHitCastSpell: current action of attacker = "+IntToString(GetCurrentAction(oAttacker)));

	if (iAction	!= ACTION_INVALID && iAction != ACTION_ATTACKOBJECT)
	{
		if (DEBUG) DoDebug("GetIsOnHitCastSpell: current action of attacker = "+IntToString(GetCurrentAction(oAttacker))+" is not compatible with onhitcasting, return FALSE");
		return FALSE;
	}

	// the attacker should actually be (melee) attacking the defender
	if (GetAttackTarget(oAttacker) != oDefender)
	{
		if (DEBUG) DoDebug("GetIsOnHitCastSpell: melee attacker of onhitcast spell is not attacking the melee defender, return FALSE");
		return FALSE;
	}

	// if we made it here, it is an onhitcast spell
	return TRUE;
}

// this will force the execution of any onhitcast spell script, even if it is set up to be
// routed through prc_onhitcast (see the description for the function ContinueOnHitCastSpell)
void ForceExecuteSpellScript(string sScript, location lTargetLocation, object oTarget = OBJECT_INVALID, int nSpellID = 0, int nMetaMagic = METAMAGIC_ANY, int nCasterLevel = 0, int nCasterClass = 0, int nSaveDC = 0, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF)
{
	// set the local int, that tells the spell script that we want to force its execution
	SetLocalInt(oCaster, "frc_ohc", TRUE);

	// now call the spell script
	ExecuteSpellScript(sScript, lTargetLocation, oTarget, nSpellID, nMetaMagic, nCasterLevel, nCasterClass, nSaveDC, oItem, oCaster);

	// delete the local int for forced execution
	DeleteLocalInt(oCaster, "frc_ohc");
}

// this will force the instant execution of any onhitcast spell script with nSpellID, as given in spells.2da
// The spell script will be executed, even if it has been set up to be routed through prc_onhitcast
// (for more info, see the description of the function ContinueOnHitCastSpell)
void ForceCastSpellAtObject(int nSpellID, object oTarget = OBJECT_INVALID, int nMetaMagic = METAMAGIC_ANY, int nCasterLevel = 0, int nCasterClass = 0, int nSaveDC = 0, object oItem = OBJECT_INVALID, object oCaster = OBJECT_SELF)
{
	// get the name of the impact spell script (for ExecuteSpellScript)
	string sScript = Get2DACache("spells", "ImpactScript", nSpellID);

	if(sScript == "" || sScript == "****")
		return;

	// create an invalid location
	location lInvalid;

	// now force-execute the spell script
	ForceExecuteSpellScript(sScript, lInvalid, oTarget, nSpellID, nMetaMagic, nCasterLevel, nCasterClass, nSaveDC, oItem, oCaster);

}

// this will force the instant execution of any AoE onhitcast spell script with nSpellID, as given in spells.2da
// The spell script will be executed, even if it has been set up to be routed through prc_onhitcast
// (for more info, see the description of the function ContinueOnHitCastSpell)
void ForceCastSpellAtLocation(int nSpellID, location lTargetLocation, int nMetaMagic = METAMAGIC_ANY, int nCasterLevel = 0, int nCasterClass = 0, int nSaveDC = 0, object oItem = OBJECT_INVALID, object oCaster = OBJECT_SELF)
{
	// get the name of the impact spell script (for ExecuteSpellScript)
	string sScript = Get2DACache("spells", "ImpactScript", nSpellID);

	if(sScript == "" || sScript == "****")
		return;

	// now force-execute the spell script
	ForceExecuteSpellScript(sScript, lTargetLocation, OBJECT_INVALID, nSpellID, nMetaMagic, nCasterLevel, nCasterClass, nSaveDC, oItem, oCaster);

}

// forces the application of the onhitcast spell (situated on oItem) with subtype iSubType to oTarget,  in the context of oCaster
void ForceApplyOnHitCastSpellSubType(int iSubType, object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF)
{
	// get the spellID of the onhitspell
	int iSpellID = StringToInt( Get2DACache("iprp_onhitspell", "SpellIndex", iSubType) );

	// now force-execute the impact spell script
	ForceCastSpellAtObject(iSpellID, oTarget, METAMAGIC_ANY, 0, 0, 0, oItem, oCaster);
}

// applies all on hit cast spells on oItem to oTarget in the context of oCaster
// will force apply the spell scripts even if they have internally been set up to be routed through prc_onhitcast
// (for more info, see the description of the function ContinueOnHitCastSpell)
// This is the safe way to do this, without interfering with any other loops over item properties in the spell scripts that are called
void ForceApplyAllOnHitCastSpellsOnItem(object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF)
{
	// set the local int, that tells the spell scripts that we want to force their execution
	SetLocalInt(oCaster, "frc_ohc", TRUE);

	// now apply all onhitcast spells on the item
	ApplyAllOnHitCastSpellsOnItem(oTarget, oItem, oCaster);

	// delete the local int for forced execution
	DeleteLocalInt(oCaster, "frc_ohc");	
}

// applies all on hit cast spells on oItem, excluding any spell-subtype given in iExcludeSubType, to oTarget in the context of oCaster
// will force apply the spell scripts even if they have internally been set up to be routed through prc_onhitcast
// (for more info, see the description of the function ContinueOnHitCastSpell)
// This is the safe way to do this, without interfering with any other loops over item properties in the spell scripts that are called
void ForceApplyAllOnHitCastSpellsOnItemExcludingSubType(int iExcludeSubType, object oTarget = OBJECT_INVALID, object oItem = OBJECT_SELF, object oCaster = OBJECT_SELF)
{
	// set the local int, that tells the spell scripts that we want to force their execution
	SetLocalInt(oCaster, "frc_ohc", TRUE);

	// now apply all onhitcast spells on the item
	ApplyAllOnHitCastSpellsOnItemExcludingSubType(iExcludeSubType, oTarget, oItem, oCaster);

	// delete the local int for forced execution
	DeleteLocalInt(oCaster, "frc_ohc");	
}

const string PRC_CUSTOM_ONHIT_USECOUNT = "prc_custom_onhit_usecount";
const string PRC_CUSTOM_ONHIT_DONOTREMOVE = "prc_custom_onhit_donotremove";
const string PRC_CUSTOM_ONHIT_SIGNATURE = "prc_custom_onhit_signature_";

int HasOnHitUniquePowerOnHit(object oItem)
{
    int bFound = FALSE;
    itemproperty iProperty = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(iProperty))
    {
        if (GetItemPropertyType(iProperty) == ITEM_PROPERTY_ONHITCASTSPELL && 
            GetItemPropertySubType(iProperty) == IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER &&
            GetItemPropertyDurationType(iProperty) == DURATION_TYPE_PERMANENT
           )
        {
            bFound = TRUE;
            break;
        }
        iProperty = GetNextItemProperty(oItem);
    }
    return FALSE;
}

void Add_OnHitUniquePower(object oItem, string sCallerSignature)
{
    int nUseCount;
    itemproperty iProperty;
    
    if (!GetLocalInt(oItem, PRC_CUSTOM_ONHIT_SIGNATURE + sCallerSignature)) //Prevent double-add by same caller
    {
        nUseCount = GetLocalInt(oItem, PRC_CUSTOM_ONHIT_USECOUNT);
        SetLocalInt(oItem, PRC_CUSTOM_ONHIT_USECOUNT, nUseCount+1);
        if (!nUseCount && HasOnHitUniquePowerOnHit(oItem))
            SetLocalInt(oItem, PRC_CUSTOM_ONHIT_DONOTREMOVE, TRUE);

        //To work properly, all other OnHit properties must be added a after the OnHit: Unique Power property--
        //Make sure this is the case by removing all of them and adding them back properly.
        //This is necessary because only the first OnHit property actually fires;
        //ours will fire the others, but the others won't allow ours to fire unless ours is first.
    
        iProperty = GetFirstItemProperty(oItem);
        while(GetIsItemPropertyValid(iProperty))
        {
            if (GetItemPropertyType(iProperty) == ITEM_PROPERTY_ONHITCASTSPELL && 
                GetItemPropertyDurationType(iProperty) == DURATION_TYPE_PERMANENT
               )
            {
                RemoveItemProperty(oItem, iProperty);
                if (GetItemPropertySubType(iProperty) != IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER)
                    DelayCommand(0.0, AddItemProperty(GetItemPropertyDurationType(iProperty), iProperty, oItem));
            }
            iProperty = GetNextItemProperty(oItem);
        }

        //Add our On Hit Cast Spell: Unique Power property (which will fire the others as well)

        iProperty = ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER, 1);
        IPSafeAddItemProperty(oItem, iProperty);

        SetLocalInt(oItem, PRC_CUSTOM_ONHIT_SIGNATURE + sCallerSignature, TRUE);
    }
}

void Remove_OnHitUniquePower(object oItem, string sCallerSignature)
{
    int nUseCount;
    itemproperty iProperty;
    
    if (GetLocalInt(oItem, PRC_CUSTOM_ONHIT_SIGNATURE + sCallerSignature)) //Prevent remove for caller that didn't add
    {
        nUseCount = GetLocalInt(oItem, PRC_CUSTOM_ONHIT_USECOUNT);
        SetLocalInt(oItem, PRC_CUSTOM_ONHIT_USECOUNT, nUseCount-1);
        if (nUseCount == 1 && !GetLocalInt(oItem, PRC_CUSTOM_ONHIT_DONOTREMOVE))
        {
            iProperty = GetFirstItemProperty(oItem);
            while(GetIsItemPropertyValid(iProperty))
            {
                if (GetItemPropertyType(iProperty) == ITEM_PROPERTY_ONHITCASTSPELL && 
                    GetItemPropertySubType(iProperty) == IP_CONST_ONHIT_CASTSPELL_ONHIT_UNIQUEPOWER &&
                    GetItemPropertyDurationType(iProperty) == DURATION_TYPE_PERMANENT
                   )
                    RemoveItemProperty(oItem, iProperty);
                iProperty = GetNextItemProperty(oItem);
            }
        }

        SetLocalInt(oItem, PRC_CUSTOM_ONHIT_SIGNATURE + sCallerSignature, FALSE);
    }
}
