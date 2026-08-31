

public void OnPluginEnd()
{
	ClearVoteInteractionState();
}

public void OnMapEnd()
{
	ClearVoteInteractionState();
	if (NoPlayerResetTimer != null)
	{
		delete NoPlayerResetTimer;
		NoPlayerResetTimer = null;
	}
	for (int client = 1; client <= MaxClients; client++)
	{
		// Menu callbacks own deletion at MenuAction_End. Only drop the slot
		// references here so a reused slot cannot address an old menu.
		N_MenuVoteMenu[client] = null;
		N_MenuAdminMenu[client] = null;
	}
}

public Action Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client < 1 || client > MaxClients)
		return Plugin_Continue;

	// The disconnect event can run after IsClientInGame() is already false.
	// Clear slot-local chat/menu state anyway so a reconnect cannot inherit it.
	BoolWaitForVoteItems[client] = false;
	BoolWaitForAdminItems[client] = false;
	AdminEditItems[client] = NULL_STRING;
	cleanplayerchar(client);

	if (IsFakeClient(client))
		return Plugin_Continue;

	if (!RealPlayerExist(client) && NCvar[Neko_NeedResetNoPlayer].BoolValue)
	{
		if (NoPlayerResetTimer != null)
			delete NoPlayerResetTimer;
		NoPlayerResetTimer = CreateTimer(float(NCvar[Neko_NeedResetTime].IntValue), Timer_CheckPlayers,
			GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}

	return Plugin_Continue;
}

void ClearVoteInteractionState()
{
	// Only cancel a vote that this plugin owns. The native vote plugin may also
	// The snapshot token is the ownership check. A stale snapshot cannot
	// cancel a newer vote created by another plugin after our vote disappeared.
	if (VoteSnapshotActive && VoteSnapshotToken != 0 &&
		GetFeatureStatus(FeatureType_Native, "L4D2NativeVote_CancelVote") == FeatureStatus_Available)
		L4D2NativeVote_CancelVote(VoteSnapshotToken);

	for (int client = 1; client <= MaxClients; client++)
	{
		BoolWaitForVoteItems[client] = false;
		BoolWaitForAdminItems[client] = false;
		cleanplayerchar(client);
		AdminEditItems[client] = NULL_STRING;
		AdminRangeItems[client] = NULL_STRING;
	}
	ClearVoteSnapshot();
}
void UpdateConfigFile(bool NeedReset)
{
	if (NeedReset)
		ClearVoteInteractionState();

	AutoExecConfig_DeleteConfig();

	for (int i = 1; i < Cvar_Max; i++)
		AutoExecConfig_UpdateToConfig(NCvar[i], NeedReset);

	AutoExecConfig_OnceExec();
}

stock bool RealPlayerExist(int Exclude = 0)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (client != Exclude && IsClientConnected(client))
			if (!IsFakeClient(client))
				return true;
	}
	return false;
}

public Action OpenVoteMenu(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;
	Menu menu = NekoVoteMenu(client);
	if (menu != null)
		menu.Display(client, MENU_TIME);
	return Plugin_Handled;
}

public Action OpenVoteAdminMenu(int client, int args)
{
	if (!IsVoteAdmin(client))
		return Plugin_Handled;
	Menu menu = NekoVoteAdminMenu(client);
	if (menu != null)
		menu.Display(client, MENU_TIME);
	return Plugin_Handled;
}

void cleanplayerwait(int client)
{
	BoolWaitForVoteItems[client] = false;
}

void cleanplayerchar(int client)
{
	VoteMenuItemValue[client] = 0;
	VoteMenuItems[client]	  = NULL_STRING;
	WaitForVoteItems[client]  = NULL_STRING;
	SubMenuVoteItems[client]  = NULL_STRING;
}

public any NekoVote_REPlHandle(Handle plugin, int numParams)
{
	return GetMyHandle();
}

public any NekoVote_REVoteStatus(Handle plugin, int numParams)
{
	return NCvar[Neko_CanSwitch].BoolValue;
}
