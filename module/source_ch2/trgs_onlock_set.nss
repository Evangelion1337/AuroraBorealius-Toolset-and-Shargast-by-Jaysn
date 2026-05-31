// Prevents players from locking an unlocked chest for more XP.
void main()
{
    SetLocalInt( OBJECT_SELF, "UNLOCK_DO_ONCE", TRUE );
}
