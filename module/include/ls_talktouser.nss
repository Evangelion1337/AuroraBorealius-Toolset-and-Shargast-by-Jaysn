//Script written by Lilac Soul, aka Carsten Hjorthoj
//Makes a placeable start its attached conversation with
//the player using it.

void main()
{
ClearAllActions();

ActionStartConversation(GetLastUsedBy());
}
