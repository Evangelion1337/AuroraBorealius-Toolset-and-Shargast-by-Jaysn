  // NWN v1.69 OnClientEnter Hook Script
  //:://///////////////////////////////////////////////////////////////////////////
  void main()
  {
      ExecuteScript("mm_client_ent", OBJECT_SELF);
      ExecuteScript("hif_trkloc", OBJECT_SELF);
  }

