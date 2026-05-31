void main()
{
  object oUser = GetLastUsedBy();
  ActionStartConversation( oUser, "", TRUE);
}
