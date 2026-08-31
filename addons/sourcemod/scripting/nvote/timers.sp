public Action Timer_ClearVoteSnapshot(Handle timer, any token)
{
	if (timer != VoteSnapshotCleanupTimer)
		return Plugin_Stop;

	VoteSnapshotCleanupTimer = null;
	// The native vote can be reset and a new vote can start before this timer
	// fires. Only clear the snapshot that scheduled this exact callback.
	if (VoteSnapshotActive && VoteSnapshotToken == token)
		ClearVoteSnapshot();
	return Plugin_Stop;
}

public Action Timer_ReloadMenu(Handle timer, any client)
{
	client = GetClientOfUserId(client);
	if (IsValidClient(client))
		NekoVoteMenu(client).DisplayAt(client, MenuPageItem[client], MENU_TIME);
	return Plugin_Continue;
}

public Action Timer_ReloadAdminMenu(Handle timer, any client)
{
	client = GetClientOfUserId(client);
	if (IsVoteAdmin(client))
	{
		Menu menu = NekoVoteAdminMenu(client);
		if (menu != null)
			menu.DisplayAt(client, AdminMenuPageItem[client], MENU_TIME);
	}
	return Plugin_Continue;
}

public Action Timer_CheckPlayers(Handle timer, any UserId)
{
	// A cancelled/replaced timer can still have a queued callback. Only the
	// currently owned timer may reset the specials configuration.
	if (timer != NoPlayerResetTimer)
		return Plugin_Stop;

	NoPlayerResetTimer = null;

	// The timer can outlive a runtime toggle or a reconnect. Re-check both
	// conditions at execution time instead of trusting the disconnect event.
	if (!NCvar[Neko_NeedResetNoPlayer].BoolValue
		|| (UserId != 0 && GetClientOfUserId(UserId) != 0)
		|| RealPlayerExist())
		return Plugin_Stop;

	NekoSpecials_ReLoadAllConfig();
	LogMessage("[NekoVote] Reset Specials Config!");
	return Plugin_Stop;
}