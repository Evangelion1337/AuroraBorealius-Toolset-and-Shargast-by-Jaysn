// On Heartbeat: Natural Random Walk script
//
// Every 6 seconds, on the heartbeat of a creature, this script has a
// 30% chance of running. If it activates, the creature will randomly
// walk to a location nearby (if the location is valid). You can easily
// change the chance to succeed by simply increasing or decreasing the
// value in the first "if" statement. By default it is at 3, meaning
// that it has a 30% chance of running what is below the "if". If you
// change it to 6, it would have a 60% chance of excuting the script.
//
// This is meant to take the place of ActionRandomWalk(); in many
// circumstances, such as when you want a creature or NPC to behave
// more naturally.
//
// With this in the heartbeat slot, 7 out of 10 times, any creature will
// wait an extra 6 seconds before walking again. Using statistics, ~50%
// of the time the creature will wait 18 seconds, and ~50% of the time,
// a creature will move on the first OR second heartbeat.
//
// Written by: Tyson McCann
// 07.16.03
//
void main()
{
    int nValue = Random(10);
    // Change the 3 below to a number from 1-10 to change the chance of
    // firing. 3 = 30%, 6 = 60%, 1 = 10%, etc. Essentially if you want them to
    // walk (or run) more often, set it to a higher number.
    if (nValue < 3)
    {
        vector vCurrent = GetPosition(OBJECT_SELF);
        float fOldX = vCurrent.x;
        float fOldY = vCurrent.y;
        float fOldZ = vCurrent.z;

        // Change the max distance you want the creature to walk in meters below.
        // Default = 7. There are 10 meters per square tile in NWN.
        int nX = Random(7);
        int nY = Random(7);

        // nSign determines whether we will be subtracting or adding to X or Y.
        int nSignX = Random(2);
        int nSignY = Random(2);

        float fNewX;
        float fNewY;
        float fNewZ = fOldZ; // since we're not changing Z

        switch(nSignX)
        {
            case 0:   // Add the random value to the X coordinate
                fNewX = fOldX + IntToFloat(nX);
                break;
            case 1:   // Subtract the random value from the X coordinate
                fNewX = fOldX - IntToFloat(nX);
                break;
        }
        switch(nSignY)
        {
            case 0:   // Add the random value to the Y coordinate
                fNewY = fOldY + IntToFloat(nY);
                break;
            case 1:   // Subtract the random value from the Y coordinate
                fNewY = fOldY - IntToFloat(nY);
                break;
        }
        // now setting up all the required parameters for the new location
        object oArea = GetArea(OBJECT_SELF);
        vector vNew = Vector(fNewX, fNewY, fNewZ);
        float fFacing = GetFacing(OBJECT_SELF);

        location lNewSpot = Location(oArea, vNew, fFacing);

        // and finally... if you prefer them to run, change FALSE to TRUE.
        AssignCommand(OBJECT_SELF, ActionMoveToLocation(lNewSpot, FALSE));

        // Now for some extra fun. If you want your creature to have a CHANCE
        // of running to a location instead of walking, even if minutely,
        // uncomment this section and RE-COMMENT the single line above.
        // The default chance to run (and remember they won't be moving every 6
        // seconds) is set to 7%. 7 times out of 100, when this script is
        // activated they will run to the new random location, giving their
        // movement an even greater sense of randomness. Whatever number you
        // put in the "if" statement below, that will be their chance to run.
        /*
        int nRun = Random(100);
        if (nRun < 7)
            AssignCommand(OBJECT_SELF, ActionMoveToLocation(lNewSpot, TRUE));
        else
            AssignCommand(OBJECT_SELF, ActionMoveToLocation(lNewSpot, FALSE));
        */
    }
}
