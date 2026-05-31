/*
Original code by Mojo and his ATS.
He was a great scripter and his presence will be missed.
Code tweaked for generic use in all merchants by:
Chris Morris
*/

void main()
{
    object oCurrentItem = GetFirstItemInInventory();
    string sItemTag;
    int iItemCount = 0;

    //this while does the trimming
    while(oCurrentItem != OBJECT_INVALID){

        sItemTag = GetTag(oCurrentItem);
        iItemCount = GetLocalInt(OBJECT_SELF, "count_" + sItemTag);

        if(iItemCount >= 1){           //set this number to amount of duplicates
            DestroyObject(oCurrentItem);//that are acceptable
        }else{
            ++iItemCount;               //incrementing number in inventory
            SetLocalInt(OBJECT_SELF, "count_" + sItemTag ,iItemCount );
        }
        oCurrentItem = GetNextItemInInventory();   //do next item
    }//end while

    oCurrentItem = GetFirstItemInInventory();
    //this while resets for next onOpen
    while(oCurrentItem != OBJECT_INVALID){
        SetLocalInt(OBJECT_SELF, "count_" + GetTag(oCurrentItem) , 0);
        oCurrentItem = GetNextItemInInventory();
    }//end while
}//end main()
