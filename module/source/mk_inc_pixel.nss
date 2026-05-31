//::///////////////////////////////////////////////
//:: FileName mk_inc_pixel
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By: Kamiryn
//:: Created On: 10.03.2008
//:://////////////////////////////////////////////

//:://////////////////////////////////////////////
//:: Returns character size in pixel
//:://////////////////////////////////////////////
int MK_GetCharSize(string cChar);

//:://////////////////////////////////////////////
//:: Returns string size in pixel
//:://////////////////////////////////////////////
int MK_GetStringSize(string sString);


int MK_GetCharSize(string cChar)
{
    int nSize=6;

    if      (cChar=="1") nSize=5;
    else if (cChar=="2") nSize=8;
    else if (cChar=="3") nSize=8;
    else if (cChar=="4") nSize=9;
    else if (cChar=="5") nSize=8;
    else if (cChar=="6") nSize=8;
    else if (cChar=="7") nSize=8;
    else if (cChar=="8") nSize=8;
    else if (cChar=="9") nSize=8;
    else if (cChar=="0") nSize=8;
    else if (cChar==" ") nSize=4;
    else if (cChar=="a") nSize=8;
    else if (cChar=="b") nSize=8;
    else if (cChar=="c") nSize=7;
    else if (cChar=="d") nSize=8;
    else if (cChar=="e") nSize=8;
    else if (cChar=="f") nSize=6;
    else if (cChar=="g") nSize=8;
    else if (cChar=="h") nSize=8;
    else if (cChar=="i") nSize=3;
    else if (cChar=="j") nSize=4;
    else if (cChar=="k") nSize=8;
    else if (cChar=="l") nSize=3;
    else if (cChar=="m") nSize=11;
    else if (cChar=="n") nSize=8;
    else if (cChar=="o") nSize=8;
    else if (cChar=="p") nSize=8;
    else if (cChar=="q") nSize=8;
    else if (cChar=="r") nSize=6;
    else if (cChar=="s") nSize=7;
    else if (cChar=="t") nSize=6;
    else if (cChar=="u") nSize=8;
    else if (cChar=="v") nSize=9;
    else if (cChar=="w") nSize=10;
    else if (cChar=="x") nSize=8;
    else if (cChar=="y") nSize=9;
    else if (cChar=="z") nSize=8;
    else if (cChar=="A") nSize=11;
    else if (cChar=="B") nSize=9;
    else if (cChar=="C") nSize=10;
    else if (cChar=="D") nSize=10;
    else if (cChar=="E") nSize=9;
    else if (cChar=="F") nSize=9;
    else if (cChar=="G") nSize=11;
    else if (cChar=="H") nSize=9;
    else if (cChar=="I") nSize=3;
    else if (cChar=="J") nSize=7;
    else if (cChar=="K") nSize=10;
    else if (cChar=="L") nSize=9;
    else if (cChar=="M") nSize=11;
    else if (cChar=="N") nSize=9;
    else if (cChar=="O") nSize=11;
    else if (cChar=="P") nSize=9;
    else if (cChar=="Q") nSize=11;
    else if (cChar=="R") nSize=10;
    else if (cChar=="S") nSize=9;
    else if (cChar=="T") nSize=9;
    else if (cChar=="U") nSize=9;
    else if (cChar=="V") nSize=11;
    else if (cChar=="W") nSize=15;
    else if (cChar=="X") nSize=10;
    else if (cChar=="Y") nSize=11;
    else if (cChar=="Z") nSize=9;
    else if (cChar=="<") nSize=8;
    else if (cChar==">") nSize=8;
    else if (cChar==":") nSize=3;
    else if (cChar=="/") nSize=6;
    else if (cChar=="|") nSize=3;
    else if (cChar==",") nSize=3;
    else if (cChar==".") nSize=3;
    else if (cChar=="-") nSize=6;
    else if (cChar==";") nSize=3;
    else if (cChar==":") nSize=3;
    else if (cChar=="_") nSize=9;
    else if (cChar=="#") nSize=10;
    else if (cChar=="'") nSize=3;
    else if (cChar=="+") nSize=9;
    else if (cChar=="*") nSize=7;
    else if (cChar=="~") nSize=8;
    else if (cChar=="!") nSize=3;
    else if (cChar=="$") nSize=9;
    else if (cChar=="%") nSize=12;
    else if (cChar=="(") nSize=4;
    else if (cChar==")") nSize=5;
    else if (cChar=="=") nSize=8;
    else if (cChar=="?") nSize=8;
    else if (cChar=="\\") nSize=6;
    else if (cChar=="{") nSize=5;
    else if (cChar=="[") nSize=4;
    else if (cChar=="]") nSize=4;
    else if (cChar=="}") nSize=5;
    return nSize;
}
int MK_GetStringSize(string sString)
{
    int nSize = 0;
    int nLen = GetStringLength(sString);
    int iPos;
    for (iPos=0; iPos<nLen; iPos++)
    {
        nSize += MK_GetCharSize(GetSubString(sString,iPos,1));
    }
    return nSize;
}

/*
void main()
{

}

/* */
