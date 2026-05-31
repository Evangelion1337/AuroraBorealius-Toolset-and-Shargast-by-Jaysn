// Intelligence is in the middle range (9-14)

int StartingConditional()
{
    int iResult;

    iResult = ((!GetAbilityScore(GetPCSpeaker(), ABILITY_INTELLIGENCE) > 14) &&
              (!GetAbilityScore(GetPCSpeaker(), ABILITY_INTELLIGENCE) < 9));
    return iResult;
}
