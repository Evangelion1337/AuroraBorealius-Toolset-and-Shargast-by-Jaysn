//::///////////////////////////////////////////////
//:: Drawing include - PRC-created functions
//:: inc_draw_prc
//::///////////////////////////////////////////////
/** @file
    PRC extensions and additions to gaoneng's
    Pentagrams & Summoning Circles system.

    @author Ornedan
    @date   Created - 2005.12.05
*/
//:://////////////////////////////////////////////

//////////////////////////////////////////////////
/*             Function prototypes              */
//////////////////////////////////////////////////

/**
 * An attempt at conical VFX. Draws a bunch from the center towards the edge
 * of a quarter-circle.
 *
 * @param nLines     Number of lines to draw
 * @param fLength    Length of the cone
 * @param lOrigin    The origin of the cone
 * @param fDirection The direction of the cone
 *
 * @param nDurationType The duration type of the applied VFX
 * @param nVFX          Visual effect to use
 * @param fDuration     Duration of the visualeffects, if temporary
 * @param nFrequency    How many VFX per line
 * @param fTime         How long it takes to draw the whole thing
 */
void DrawLinesInACone(int nLines, float fLength, location lOrigin, float fDirection,
                      int nDurationType, int nVFX, float fDuration, int nFrequency, float fTime);


//////////////////////////////////////////////////
/*                  Includes                    */
//////////////////////////////////////////////////

#include "inc_draw"


//////////////////////////////////////////////////
/*             Function definitions             */
//////////////////////////////////////////////////

void DrawLinesInACone(int nLines, float fLength, location lOrigin, float fDirection,
                      int nDurationType, int nVFX, float fDuration, int nFrequency, float fTime)
{
    float fTheta = 90.0f / nLines;
    vector vCenter = GetPositionFromLocation(lOrigin);
    object oArea   = GetAreaFromLocation(lOrigin);

    int i;
    float f, fAngle;
    vector vTarget;
    for(i = 0; i < nLines; i++)
    {
        f = IntToFloat(i);
        fAngle = fTheta * f + (fDirection - 45.0);
        vTarget = vCenter + Vector(cos(fAngle), sin(fAngle), 0.0f);
        DrawLineFromVectorToVector(nDurationType, nVFX, oArea, vCenter, vTarget, fDuration, nFrequency, fTime);
    }
}
