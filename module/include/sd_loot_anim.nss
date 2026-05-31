void main()
{
object oPC = GetLastUsedBy();

       // Play crouch animation only if PC just opened the corpse inventory GUI
       // EXCEPTION: If the PC opens the corpse inventory, then quickly presses
       // the "I" key (to open the PC inventory), a BioWare software bug will
       // trick the software into permanently thinking the corpse inventory is
       // open (even though the GUI can be opened and closed normally).  This will
       // cause the animation to play when corpse is opened or closed (a minor
       // bug).
       if (GetIsOpen(OBJECT_SELF))
        {
           AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW, 1.0f, 600.0f));
        }
}
