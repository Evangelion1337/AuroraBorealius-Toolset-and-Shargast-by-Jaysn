/*
Conversation Character Creator v1.4

This is a conversation driven in-game 100% serverside character creator allowing
the use of custom content on a serverside game from level 1 (including new races
and new base classes ). It is also more secure than conventional character creation
methods



You Need:

PRC (current version is 2.2d, but this should work with any
http://nwnprc.netgamers.co.uk/
or
http://nwvault.ign.com/Files/hakpacks/data/1071643329920.shtml
or
http://nwvault.ign.com/Files/hakpacks/data/1082946089000.shtml

NWNX 2
http://nwvault.ign.com/Files/other/data/1046636009723.shtml

NWNX-Leto
http://prdownloads.sourceforge.net/leto/nwnxleto-build-03%2B18.rar?download



This is an in-game conversation driven character creator. This is designed for
servervault so that custom content is used at character creation. To work
properly however, several things need to be done.

NWNX2 must be instlled and used to run the module ( http://nwvault.ign.com/Files/
other/...636009723.shtml ) See the readme included with NWNX2 for instructions,
its very easy.

The NWNX_ODBC plugin included with NWNX2 should be installed and setup. See the
readme included with NWNX2 for instructions, this is quite straightforward but
trickier than installing NWNX2. In particular, make sure that the aps_onload
script is setup and that the database can be read to and from using the demo module
included in NWNX2. The ConvoCC should work with Access or MySQL databases.

To enable the database system for 2da caching, you must set a local int on the
module named "USE_2DA_DB_CACHE" to 1.

In addition to using NWNX2 for database storage, the cache can also be stored as
object in the bioware database. This cache is only updated when a character is
created, and is only restored when the module is loaded. This is to keep lag to
a minimum. To enable this, add RestoreCache(); to your OnModuleLoad script just
after void main() and add #include "prc_ccc_cache" above void main()

NWNX-Leto plugin build 18 must be installed ( http://sourceforge.net/projects/leto/ )
See the readme included with NWNX-Leto for instructions, its very easy.

THIS IS A VERY IMPORTANT NOTE Inside the module, in inc_letoscript, the constant
NWN_DIR must point to your servers hard disk location where NWN is installed.
After this, the scripts must be recompiled. THIS IS A VERY IMPORTANT NOTE

The player start should be placed in an area with no access to the rest of the
module. Then you should add code to jump the player to a starting waypoint in
the mod_cliententer script. There is an example commented out, if you delete
the comments ( // at the start of the line) then you can simply place a waypoint
tagged "WP_RealStart" where you want players to be jumped to.

You must connect the mod_cliententer script to the modules on client enter event.
You must connect the mod_clientexit  script to the modules on client exit  event.

Since much of the data is read directly from 2da's, this can be very slow,
especially for feats and spells where an enourmous amount of data is used. To
speed this process up, all 2da reads are cached via NWNX_ODBC to form a
persistant cache. This is a single tabled named "prccache". This means
that the first time a character is created it is much slower than subsequent
times will be. Also, whenever the PRC updates, or your 2da files change, you
should delete the table from the DB. In addition you must delete the bioware
database named "ConvoCC" when your 2das are updated.

If you wish to expand it to include more custom content (for example CEP portraits),
you need to change the constants in inc_fileends to define the last lines of the
relevant 2das. You will also need to recompile all the scripts.


You may be able to use FastFrenchs NWNX development, I havn't tested it
particularly, but there is no reason why not. I have also only tested it with an
MS Access database, though it should work with MySQL too.


In addition, there is now a few optional extras. These are toggled by local int
variables set on the module.
PRC_CONVOCC_AVARIEL_WINGS               Avariel characters have bird wings
PRC_CONVOCC_FEYRI_WINGS                 Fey'ri characters have bat wings
PRC_CONVOCC_FEYRI_TAIL                  Fey'ri characters have a demonic tail
PRC_CONVOCC_DROW_ENFORCE_GENDER         Force Drow characters to be of the correct gender for
                            their race
PRC_CONVOCC_GENSAI_ENFORCE_DOMAINS      Force Gensai clerics to select the relevant elemental
                            domain as one of their feats
PRC_CONVOCC_ENFORCE_BLOOD_OF_THE_WARLORD Makes Blood of the Warlord only avliable to orcish characters
PRC_CONVOCC_ENFORCE_FEAT_NIMBUSLIGHT    Enforces the "moral" feats
PRC_CONVOCC_ENFORCE_FEAT_HOLYRADIANCE
PRC_CONVOCC_ENFORCE_FEAT_SERVHEAVEN
PRC_CONVOCC_ENFORCE_FEAT_SAC_VOW
PRC_CONVOCC_ENFORCE_FEAT_VOW_OBED
PRC_CONVOCC_ENFORCE_FEAT_THRALL_TO_DEMON
PRC_CONVOCC_ENFORCE_FEAT_DISCIPLE_OF_DARKNESS
PRC_CONVOCC_ENFORCE_FEAT_LICHLOVED
PRC_CONVOCC_ENFORCE_FEAT_EVIL_BRANDS
PRC_CONVOCC_ENFORCE_FEAT_VILE_WILL_DEFORM
PRC_CONVOCC_ENFORCE_FEAT_VILE_DEFORM_OBESE
PRC_CONVOCC_ENFORCE_FEAT_VILE_DEFORM_GAUNT
PRC_CONVOCC_RAKSHASHA_FEMALE_APPEARANCE Female rakshasha use the female rakshasha model
PRC_CONVOCC_DRIDER_FEMALE_APPEARANCE    Female drider use the female drider model
PRC_CONVOCC_DISALLOW_CUSTOMISE_WINGS    Stops players changing their wings
PRC_CONVOCC_DISALLOW_CUSTOMISE_TAIL     Stops players changing their tail
PRC_CONVOCC_DISALLOW_CUSTOMISE_MODEL    Stops players changing their model at all
PRC_CONVOCC_USE_RACIAL_APPEARANCES      Players can only change their model / portrait / soundset
PRC_CONVOCC_USE_RACIAL_PORTRAIT         to alternatives of the same race. If you have extra
PRC_CONVOCC_USE_RACIAL_SOUNDSET         content (e.g. from CEP) you must add them to
                            SetupRacialAppearances or SetupRacialPortraits or
                            SetupRacialSoundsets in prc_ccc_inc_e in order for
                            them to be shown on the list.
PRC_CONVOCC_ONLY_PLAYER_VOICESETS       Players can only select from the player voicesets
                            NPC voicesets are not complete, so wont play sounds
                            for many things such as emotes.
PRC_CONVOCC_RESTRICT_VOICESETS_BY_SEX   Only allows players to select voiceset of the same gender
PRC_CONVOCC_FORCE_KEEP_VOICESET         Skips the select a voiceset step entirely, and players
                            have to keep their current voiceset
PRC_CONVOCC_ALLOW_TO_KEEP_PORTRAIT      Allow players to keep their exisiting portrait
                            The ConvoCC cannot allow players to select custom
                            portriats, so the only way for players to have them
                            is to select them in the bioware character creator
                            and then select to keep them in the ConvoCC.
PRC_CONVOCC_FORCE_KEEP_PORTRAIT         Skips the select a portrait step entirely, and players
                            have to keep their current portrait
PRC_CONVOCC_RESTRICT_PORTRAIT_BY_SEX    Only allow players to select portraits of the same gender.
                            Most of the NPC portraits do not have a gender so are also
                            removed.
PRC_CONVOCC_ENABLE_RACIAL_HITDICE       This option give players the ability to start with racial
                            hit dice for some of the more powerful races. These are
                            defined in ECL.2da For these races, players do not pick
                            a class in the ConvoCC but instead select 1 or more levels
                            in a racial class (such as monsterous humanoid, or outsider).
                            This is not a complete ECL system, it mearly gives players
                            the racial hit dice component. It does not make any measure
                            of the Level Adjustment component. For example, a pixie has
                            no racial hit dice, but has a +4 level adjustment.
PRC_CONVOCC_ALLOW_HIDDEN_SKIN_COLOURS   These enable players to select the hidden skin, hair,
PRC_CONVOCC_ALLOW_HIDDEN_HAIR_COLOURS   and tattoo colours (metalics, matt black, matt white).
PRC_CONVOCC_ALLOW_HIDDEN_TATTOO_COLOURS
PRC_CONVOCC_ALLOW_SKILL_POINT_ROLLOVER  This option allows players to keep their skillpoints
                            from one level to the next, if they want to.
PRC_CONVOCC_USE_XP_FOR_NEW_CHAR         This will identify new characters based on X which is
                            the same as v1.3 but less secure.
PRC_CONVOCC_ENCRYPTION_KEY              This is the key used to encrypt characters names if
                            USE_XP_FOR_NEW_CHAR is false in order to identify
                            returning characters. It should be in the range 1-100.
                            If USE_XP_FOR_NEW_CHAR is true, then returning
                            characters will be encrypted too, so once everone has
                            logged on at least once, USE_XP_FOR_NEW_CHAR can be
                            set to false for greater security.


Change log
v1.4
    Changed several systems to the more general systems the PRC will use in 2.3
    Fixed alertness not being given as a racial/bonus feat
    Fixed cross class skills not dissapering at 1 skill point remaining
    Fixed clerical domain feats not being given correctly
    Fixed bonus feats not being given correctly
    Fixed quick to master feat selection not being reset correctly
    Added model selection
    Added wing selection
    Added tail selection
    Added skin colour selection
    Added hair colour selection
    Added preview for character customizations (model, soundset, colors, etc)
    Added builder options for lots of things
    Added skill point storage
v1.3
    Fixed a nasty bug 1.2 introduced where all characters were given elven radial feats and appearance
v1.2
    Fixed another bug with user and character names with unusual characters in
    Fixed bugs with MySQL database
    Added BiowareDB caching (at character creation and module load only)
    Added confirmation stages
    Added "keep existing" options to portrait and soundset
v1.1
    Fixed bug with usernames with spaces in them
    Fixed bug with cleric second domain scrolling
    Fixed bug with missing scripts in erf
    Added portrait selection
    Added soundset selection
v1.0
    First Release
*/
