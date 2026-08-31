

public Action Timer_SpawnFakeClient(Handle hTimer)
{
	int client = CreateFakeClient("NEKOBOT");
	if (client > 0)
	{
		ChangeClientTeam(client, 3);
		KickClient(client);
	}
	return Plugin_Stop;
}

public Action Timer_DelaySpawnInfected(Handle hTimer)
{
	Call_StartForward(N_Forward_OnStartFirstSpawn);
	SetSpecialRunning(NCvar[CSpecial_PluginStatus].BoolValue);
	Call_Finish();

	return Plugin_Stop;
}

public Action PlayerLeftStart(Handle Timer)
{
	if (L4D_HasAnySurvivorLeftSafeArea())
	{
		IsPlayerLeftCP = true;
		g_hPlayerLeftTimer = null;
		CreateTimer(NCvar[CSpecial_LeftPoint_SpawnTime].FloatValue, Timer_DelaySpawnInfected);
		InfectedTips();
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_ReloadMenu(Handle timer, any client)
{
	client = GetClientOfUserId(client);
	if (IsValidClient(client))
	{
		N_ClientMenu[client].Reset();
		SpecialMenu(client).DisplayAt(client, N_ClientMenu[client].MenuPageItem, MENU_TIME);
	}
	return Plugin_Continue;
}

public Action Timer_SetMaxSpecialsCount(Handle timer)
{
	g_hSetMaxSpecialsTimer = null;
	SetMaxSpecialsCount();
	return Plugin_Stop;
}

public Action ShowTipsTimer(Handle timer)
{
	InfectedTips();
	return Plugin_Stop;
}

public void Timer_KickBot(any client)
{
	client = GetClientOfUserId(client);
	if (IsValidClient(client) && IsFakeClient(client) && !IsClientInKickQueue(client))
	{
		if (GetEntProp(client, Prop_Send, "m_zombieClass") != 4)
			KickClient(client);
		else
			CreateTimer(10.0, Timer_DelaySpitterDeath, GetClientUserId(client));
	}
}

public Action Timer_DelaySpitterDeath(Handle timer, any client)
{
	client = GetClientOfUserId(client);
	if (IsValidClient(client) && IsFakeClient(client) && !IsClientInKickQueue(client))
		KickClient(client);

	return Plugin_Stop;
}

public Action KillHUDShow(Handle timer)
{
	if (HUDSlotIsUsed(HUD_MID_TOP))
		RemoveHUD(HUD_MID_TOP);
	return Plugin_Stop;
}