//::///////////////////////////////////////////////
//:: FileName mk_inc_tools
//:: Copyright (c) 2008 Kamiryn
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By: Kamiryn
//:: Created On: 08.03.2008
//:://////////////////////////////////////////////

// mk_inc_tools

// ----------------------------------------------------------------------------
// Converts an integer to a right aligned string with length nLen, prefixed with c
// ----------------------------------------------------------------------------
string MK_IntToString(int nInteger, int nLen, string c=" ");

// ----------------------------------------------------------------------------
// Trims a string
// ----------------------------------------------------------------------------
string MK_TrimString(string sString);

// ----------------------------------------------------------------------------
// Removes every occurance of sRemove in sString
// ----------------------------------------------------------------------------
string MK_RemoveFromString(string sString, string sRemove);


// ----------------------------------------------------------------------------
// returns true if there is a color tag (<c???>) in sString at position nPos
// ----------------------------------------------------------------------------
int MK_IsColorTag(string sString, int nPos=0);

// ----------------------------------------------------------------------------
// returns true if there is a close tag (</c>) in sString at position nPos
// ----------------------------------------------------------------------------
int MK_IsCloseTag(string sString, int nPos=0);

// ----------------------------------------------------------------------------
// Returns the length of sString. If bIgnoreColorTags is TRUE then
// the color tags are ignored (they do not count)
// ----------------------------------------------------------------------------
int MK_GetStringLength(string sString, int bIgnoreColorTags=TRUE);

// ----------------------------------------------------------------------------
// Get nCount characters from the left end of sString.
// Color tags are ignored (they do not count) if bIgnoreColorTags is TRUE
// ----------------------------------------------------------------------------
string MK_GetStringLeft(string sString, int nCount, int bIgnoreColorTags=TRUE);


string MK_IntToString(int nInteger, int nLen, string c)
{
    string s = IntToString(nInteger);
    while (GetStringLength(s)<nLen)
    {
        s=c+s;
    }
    return s;
}

string MK_TrimString(string sString)
{
    int iPosA = 0;
    int iPosE = GetStringLength(sString)-1;

    while ((iPosA<=iPosE) && (GetSubString(sString,iPosA,1)==" "))
    {
        iPosA++;
    }
    while ((iPosA<=iPosE) && (GetSubString(sString,iPosE,1)==" "))
    {
        iPosE--;
    }

    string sResult;
    if (iPosA<=iPosE)
    {
        sResult = GetSubString(sString, iPosA, iPosE-iPosA+1);
    }
    else
    {
        sResult = "";
    }
    return sResult;
}

string MK_RemoveFromString(string sString, string sRemove)
{
    int nPos = 0;
    int nLen = GetStringLength(sString);
    int nLenRemove = GetStringLength(sRemove);
    string s1,s2;
    while ((nPos = FindSubString(sString, sRemove, nPos))!=-1)
    {
        s1 = GetStringLeft(sString,nPos);
        s2 = GetStringRight(sString, nLen - nPos - nLenRemove);
        sString = s1+s2;
        nLen-=nLenRemove;
    }
    return sString;
}

int GetTagLength(string sString, int nPos)
{
    int nLen = 0;
    if (MK_IsColorTag(sString, nPos))
    {
        nLen = 6;
    }
    else if (MK_IsCloseTag(sString, nPos))
    {
        nLen = 4;
    }
    return nLen;
}

string MK_RemoveColorTagsFromString(string sString)
{
    string s1,s2;
    int nTagLength;
    int nLen = GetStringLength(sString);
    int nPos = 0;
    while ((nPos = FindSubString(sString, "<", nPos))!=-1)
    {
        nTagLength = GetTagLength(sString, nPos);
        if (nTagLength>0)
        {
            s1 = GetStringLeft(sString,nPos);
            s2 = GetStringRight(sString, nLen - nPos - nTagLength);
            sString = s1+s2;
            nLen-=nTagLength;
        }
        else
        {
            nPos++;
        }
    }
    return sString;
}

int MK_IsColorTag(string sString, int nPos)
{
    if (GetStringLength(sString)<nPos+6)
    {
        return FALSE;
    }
    if (GetSubString(sString,nPos,2)!="<c")
    {
        return FALSE;
    }
    if (GetSubString(sString,nPos+5,1)!=">")
    {
        return FALSE;
    }
    return TRUE;
}

int MK_IsCloseTag(string sString, int nPos)
{
    if (GetStringLength(sString)<nPos+4)
    {
        return FALSE;
    }
    if (GetSubString(sString,nPos,4)!="</c>")
    {
        return FALSE;
    }
    return TRUE;
}


int MK_GetStringLength(string sString, int bIgnoreColorTags)
{
    int nLen = GetStringLength(sString);
    if (bIgnoreColorTags)
    {
        int nTagLengths=0;
        int nTagLength;
        int nPos = 0;
        while ((nPos = FindSubString(sString, "<", nPos)) != -1)
        {
            nTagLength = GetTagLength(sString, nPos);
            if (nTagLength>0)
            {
                nTagLengths += nTagLength;
                nPos += nTagLength;
            }
            else
            {
                nPos++;
            }
        }
        nLen-=nTagLengths;
    }
    return nLen;
}

string MK_GetStringLeft(string sString, int nCount, int bIgnoreColorTags)
{
    if (bIgnoreColorTags)
    {
        int nTagLengths = 0;
        int nTagLength;
        int nPos = 0;
        while ((nPos = FindSubString(sString, "<", nPos)) != -1)
        {
            if (nPos < nCount + nTagLengths)
            {
                nTagLength = GetTagLength(sString, nPos);
                if (nTagLength>0)
                {
                    nTagLengths += nTagLength;
                    nPos += nTagLength;
                }
                else
                {
                    nPos++;
                }
            }
            else
            {
                break;
            }
        }
        nCount += nTagLengths;
    }
    return GetStringLeft(sString, nCount);
}

string MK_CloseColorTags(string sString)
{
    int nOpenColorTags=0;

    int nPos = 0;
    while ((nPos = FindSubString(sString, "<", nPos)) != -1)
    {
        if (MK_IsColorTag(sString, nPos))
        {
            nOpenColorTags++;
            nPos+=6;
        }
        else if ((MK_IsCloseTag(sString, nPos)) && (nOpenColorTags>0))
        {
            nOpenColorTags--;
            nPos+=4;
        }
        else
        {
            nPos+=1;
        }
    }
    while (nOpenColorTags-->0)
    {
        sString+="</c>";
    }
    return sString;
}

/*
void main()
{

}
/**/

