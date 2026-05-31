// gives a book with a little more info on the system
// gives a ring that when activated saves the players location
void main()
{
    CreateItemOnObject("pc_location", GetPCSpeaker());
    CreateItemOnObject("se_on_activate", GetPCSpeaker());
}
