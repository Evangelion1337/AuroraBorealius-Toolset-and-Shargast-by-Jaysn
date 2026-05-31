void main()
{
  object Notice = CreateItemOnObject("bbs_notice_bp", GetPCSpeaker());
  if (Notice != OBJECT_INVALID) {
    SetLocalString(Notice, "Title", GetLocalString(OBJECT_SELF, "Title"));
    SetLocalString(Notice, "Message", GetLocalString(OBJECT_SELF, "Message"));
  }
}
