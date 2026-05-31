void main()
{
    if (GetTag(GetItemActivated()) == "cr_ossotransf")
    {
        int iAP = GetLocalInt(GetItemActivator(), "AparenciaTransf");
        SetLocalObject(GetItemActivator(), "TransfAlvo", GetItemActivatedTarget());
        SendMessageToPC(GetItemActivator(), "Aparencia selecionada atualmente: " + IntToString(iAP));
        AssignCommand(GetItemActivator(), ActionStartConversation(GetItemActivator(), "cr_transf", TRUE));
    }
}
