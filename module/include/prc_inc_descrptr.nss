//::///////////////////////////////////////////////
//:: Magic descriptors and subschools include
//:: prc_inc_descrptr
//::///////////////////////////////////////////////
/** @file prc_inc_descrptr
    A set of constants and functions for managing
    spell's / power's / other stuffs's descriptors
    and sub{school|discipline|whatever}s.

    The functions SetDescriptor() and SetSubschool()
    should be called at the beginning of the
    spellscript, before spellhook or equivalent.

    The values are stored on the module object and
    are automatically cleaned up after script
    execution terminates (ie, DelayCommand(0.0f)).
    This is a potential gotcha, as the descriptor
    and subschool data will no longer be available
    during the spell's delayed operations. An
    ugly workaround would be to set the descriptor
    values again in such cases.
    If you come up with an elegant solution, please
    try to generalise it and change this as needed.


    @author Ornedan
    @date   Created - 2006.06.30
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/*                 Constants                    */
//////////////////////////////////////////////////

// The descriptor and subschool constants are bit flags for easy combination and lookup
const int DESCRIPTOR_ACID              = 0x00001;
const int DESCRIPTOR_AIR               = 0x00002;
const int DESCRIPTOR_CHAOTIC           = 0x00004;
const int DESCRIPTOR_COLD              = 0x00008;
const int DESCRIPTOR_DARKNESS          = 0x00010;
const int DESCRIPTOR_DEATH             = 0x00020;
const int DESCRIPTOR_EARTH             = 0x00040;
const int DESCRIPTOR_ELECTRICITY       = 0x00080;
const int DESCRIPTOR_EVIL              = 0x00100;
const int DESCRIPTOR_FEAR              = 0x00200;
const int DESCRIPTOR_FIRE              = 0x00400;
const int DESCRIPTOR_FORCE             = 0x00800;
const int DESCRIPTOR_GOOD              = 0x01000;
const int DESCRIPTOR_LANGUAGEDEPENDENT = 0x02000;
const int DESCRIPTOR_LAWFUL            = 0x04000;
const int DESCRIPTOR_LIGHT             = 0x08000;
const int DESCRIPTOR_MINDAFFECTING     = 0x10000;
const int DESCRIPTOR_SONIC             = 0x20000;
const int DESCRIPTOR_WATER             = 0x40000;
// update if any of elemental descriptors change!
// int DESCRIPTOR_ELEMENTAL = DESCRIPTOR_ACID | DESCRIPTOR_COLD | DESCRIPTOR_ELECTRICITY | DESCRIPTOR_FIRE | DESCRIPTOR_SONIC;
const int DESCRIPTOR_ELEMENTAL         = 0x20489;

const int SUBSCHOOL_CALLING            = 0x00001;
const int SUBSCHOOL_CHARM              = 0x00002;
const int SUBSCHOOL_COMPULSION         = 0x00004;
const int SUBSCHOOL_CREATION           = 0x00008;
const int SUBSCHOOL_FIGMENT            = 0x00010;
const int SUBSCHOOL_GLAMER             = 0x00020;
const int SUBSCHOOL_HEALING            = 0x00040;
const int SUBSCHOOL_PATTERN            = 0x00080;
const int SUBSCHOOL_PHANTASM           = 0x00100;
const int SUBSCHOOL_POLYMORPH          = 0x00200;
const int SUBSCHOOL_SCRYING            = 0x00400;
const int SUBSCHOOL_SHADOW             = 0x00800;
const int SUBSCHOOL_SUMMONING          = 0x01000;
const int SUBSCHOOL_TELEPORTATION      = 0x02000;

const string PRC_DESCRIPTOR = "PRC_Descriptor";
const string PRC_SUBSCHOOL  = "PRC_Subschool";


//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * Sets the descriptor of currently being cast spell / power / whatever
 * to be the given value. This should be called before spellhook / powerhook
 * / whateverhook.
 *
 * If the magic in question has multiple descriptors, they should be OR'd together.
 * For example, Phantasmal Killer would call the function thus:
 *  SetDescriptor(DESCRIPTOR_FEAR | DESCRIPTOR_MINDAFFECTING);
 *
 * This will override values set in prc_spells.2da
 *
 * @param nfDescriptorFlags The descriptors of a spell / power / X being currently used
 */
void SetDescriptor(int nfDescriptorFlags, object oPC = OBJECT_SELF);

/**
 * Sets the subschool / subdiscipline / subwhatever of currently being cast
 * spell / power / whatever to be the given value. This should be called before
 * spellhook / powerhook / whateverhook.
 *
 * If the magic in question has multiple subschools, they should be OR'd together.
 * For example, Mislead would call the function thus:
 *  SetDescriptor(SUBSCHOOL_FIGMENT | SUBSCHOOL_GLAMER);
 *
 * This will override values set in prc_spells.2da
 *
 * @param nfSubschoolFlags The subschools of a spell / power / X being currently used
 */
void SetSubschool(int nfSubschoolFlags, object oPC = OBJECT_SELF);

/**
 * Tests whether a magic being currently used has the given descriptor.
 *
 * NOTE: Multiple descriptors may be tested for at once. If so, the return value
 * will be true only if all the descriptors tested for are present. Doing so is
 * technically a misuse of this function.
 *
 *
 * @param nSpellID        row number of tested spell in spells.2da
 * @param nDescriptorFlag The descriptor to test for
 * @return                TRUE if the magic being used has the given descriptor(s), FALSE otherwise
 */
int GetHasDescriptor(int nSpellID, int nDescriptorFlag);

/**
 * Returns TRUE if given spell has one of the elemental descriptors
 * (acid, cold, electricity, fire or sonic)
 *
 * @param nSpellID  row number of tested spell in spells.2da
 * @return          ID of elemental descriptor or FALSE
 */
int GetIsElementalSpell(int nSpellID, int nDescriptor = -1);

/**
 * Tests whether a magic being currently used is of the given subschool.
 *
 * NOTE: Multiple subschools may be tested for at once. If so, the return value
 * will be true only if all the subschools tested for are present. Doing so is
 * technically a misuse of this function.
 *
 *
 * @param nSpellID        row number of tested spell in spells.2da
 * @param nDescriptorFlag The subschool to test for
 * @return                TRUE if the magic being used is of the given subschool(s), FALSE otherwise
 */
int GetIsOfSubschool(int nSpellID, int nSubschoolFlag);

/**
 * Returns an integer value containing the bitflags of descriptors set in prc_spells.2da
 * for a given SpellID
 *
 * @param nSpellID  row number of tested spell in spells.2da
 * @return          The converted raw integer value from prc_spells.2da
 */
int GetDescriptorFlags(int nSpellID);

/**
 * Returns an integer value containing the bitflags of subschools set in prc_spells.2da
 * for a given SpellID
 *
 * @param nSpellID  row number of tested spell in spells.2da
 * @return          The converted raw integer value from prc_spells.2da
 */
int GetSubschoolFlags(int nSpellID);

//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "inc_2dacache"
#include "inc_utility"

//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

void SetDescriptor(int nfDescriptorFlags, object oPC = OBJECT_SELF)
{
    // Store the value
    SetLocalInt(oPC, PRC_DESCRIPTOR, nfDescriptorFlags);

    // Queue cleanup. No duplicacy checks, this function is not particularly likely to be called more than once anyway
    DelayCommand(0.0f, DeleteLocalInt(oPC, PRC_DESCRIPTOR));
}

void SetSubschool(int nfSubschoolFlags, object oPC = OBJECT_SELF)
{
    // Store the value
    SetLocalInt(oPC, PRC_SUBSCHOOL, nfSubschoolFlags);

    // Queue cleanup. No duplicacy checks, this function is not particularly likely to be called more than once anyway
    DelayCommand(0.0f, DeleteLocalInt(oPC, PRC_SUBSCHOOL));
}

int GetHasDescriptor(int nSpellID, int nDescriptorFlag)
{
    //check for descriptor override
    int nDescriptor = GetLocalInt(OBJECT_SELF, PRC_DESCRIPTOR);
    if(!nDescriptor)
        nDescriptor = GetDescriptorFlags(nSpellID);

    if(nDescriptorFlag & DESCRIPTOR_ELEMENTAL)
    {
        return nDescriptorFlag & GetIsElementalSpell(nSpellID, nDescriptor);
    }

    return nDescriptor & nDescriptorFlag;
}

int GetIsElementalSpell(int nSpellID, int nDescriptor = -1)
{
    if(nDescriptor == -1)
    {
        //check for descriptor override
        nDescriptor = GetLocalInt(OBJECT_SELF, PRC_DESCRIPTOR);
        if(!nDescriptor)
            nDescriptor = GetDescriptorFlags(nSpellID);
    }

    int nMastery = GetLocalInt(OBJECT_SELF, "archmage_mastery_elements");

    //mastery of elements is active
    if(nMastery)
    {
        switch(nMastery)
        {
            case DAMAGE_TYPE_ACID:       return DESCRIPTOR_ACID;
            case DAMAGE_TYPE_COLD:       return DESCRIPTOR_COLD;
            case DAMAGE_TYPE_ELECTRICAL: return DESCRIPTOR_ELECTRICITY;
            case DAMAGE_TYPE_FIRE:       return DESCRIPTOR_FIRE;
            case DAMAGE_TYPE_SONIC:      return DESCRIPTOR_SONIC;
        }
    }

    return nDescriptor & DESCRIPTOR_ELEMENTAL;
}

int GetIsOfSubschool(int nSpellID, int nSubschoolFlag)
{
    //check for subschool override
    int nSubschool = GetLocalInt(OBJECT_SELF, PRC_SUBSCHOOL);
    if(!nSubschool)
        nSubschool = GetSubschoolFlags(nSpellID);
    return (nSubschool & nSubschoolFlag);
}

int GetDescriptorFlags(int nSpellID)
{
    return HexToInt(Get2DACache("prc_spells", "Descriptor", nSpellID));
}

int GetSubschoolFlags(int nSpellID)
{
    return HexToInt(Get2DACache("prc_spells", "Subschool", nSpellID));
}

// Test main
//void main(){}
