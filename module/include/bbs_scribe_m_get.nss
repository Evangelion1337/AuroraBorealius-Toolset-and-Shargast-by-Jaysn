void main()
{
  string sTalk = GetLocalString(OBJECT_SELF, "Stack");
  if (sTalk != "") {
    if (GetStringLength(sTalk) > 200) {sTalk = GetStringLeft(sTalk, 200);}
    SetLocalString(OBJECT_SELF, "Message", sTalk);
    SetLocalString(OBJECT_SELF, "Stack", "");
  }
}
