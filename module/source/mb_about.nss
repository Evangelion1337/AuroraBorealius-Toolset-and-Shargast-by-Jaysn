//::///////////////////////////////////////////////
//:: AnchorDeep Message Board
//::
//:: MB_ABOUT.nss
//:://////////////////////////////////////////////
//:: General info about the message board
//::
//:://////////////////////////////////////////////
//:: Edited By: 69_Jeremy_69 On: September 2, 2003
//:: Created By: 69_Jeremy_69 On: August 20, 2003
//////////////////////////////////////////////////
//:: September 2, 2003
//:: - Added a DM board that is read only to players
//:: - Posts dont loop anymore
//:: - Fixed filter
///////////////////////////////////////////////////
//:: August 24, 2003
//:: - When reading new posts it now shows the newest posts first
//:: - When looking at posts to delete, the oldest show
//::   first
///////////////////////////////////////////////////

/*
- This Message Board System was made for the PW AnchorDeep
  found in the RolePlay section on GameSpy

This is all very straight forward, drop a Message Board found in Custom =>
Penants and Signs in the Placeable Pallette, in any area you want your
players to have access to getting and sending messages.

Once the boards are in the code handles the rest.
There are a few Options you can edit in the file MB_INC. If you edit
this file though you will have to do a full recompile of the scripts.

Features this message board has:
** All found in the file MB_INC under Constants **
- Persistent messages
- Flood Control to stop Spammers
- You can Enable/Disable the showing of names
- Players can delete there own messages
- There is a language filter to catch 'BAD WORDS'
- DM's can delete any post, board or the whole database from in game.

*/



// Ignore this, used to avoid compile error
int StartingConditional(){return 1;}
