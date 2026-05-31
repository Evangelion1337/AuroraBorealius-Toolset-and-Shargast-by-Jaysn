/*
    _________________________________________________________________________
   /                                                                         \
                         << Player Inventory Spy Package >>

    Author:
        Dom Queron, dom(at)gulbsoft(dot)de, http://www.gulbsoft.de
    Filename:
        gz_invspy_trash.nss
    Description:
        Destroys any item placed in
   Credits
        Russell S. Ahlstrom demonstrated this kind of trashbin in his
        excellent Purple Rose Inn HCR Addon
    version:
        $v1.0 02-09-16


   \_________________________________________________________________________/
*/

void main()
{
    object oTrash = GetInventoryDisturbItem();
    DestroyObject(oTrash);
    ApplyEffectToObject( DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_FNF_SMOKE_PUFF ), OBJECT_SELF );
}
