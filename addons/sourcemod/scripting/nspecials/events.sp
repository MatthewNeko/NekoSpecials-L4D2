

public Action OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
    IsPlayerLeftCP = false;
    SetSpecialRunning(false);
    TgModeStartSet();
    CreateTimer(0.1, PlayerLeftStart, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Continue;
}

public Action player_team(Event event, const char[] name, bool dontBroadcast)
{
    CreateTimer(0.1, Timer_SetMaxSpecialsCount, _, TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Continue;
}

public void OnClientPostAdminCheck(int client)
{
    CheckBiledTime[client] = 0.0;
    CheckFreeTime[client]  = 0.0;
    CheckNotCombat[client] = 0;
    N_ClientItem[client].Reset();
    N_ClientMenu[client].Reset(true);
}

public void OnPlayerDisconnect(Event hEvent, const char[] sName, bool bDontBroadcast)
{
    int client = GetClientOfUserId(hEvent.GetInt("userid"));
    if (IsValidClient(client))
    {
        if (IsFakeClient(client))
        {
            if (NCvar[CSpecial_PluginStatus].BoolValue && IsPlayerLeftCP)
            {
                if (IsPlayerTank(client))
                    CreateTimer(0.5, Timer_DelayDeath);
            }
            else
                SetSpecialRunning(false);
        }
        else
        {
            CheckBiledTime[client] = 0.0;
            CheckFreeTime[client]  = 0.0;
            CheckNotCombat[client] = 0;
            N_ClientItem[client].Reset();
            N_ClientMenu[client].Reset(true);
            CreateTimer(0.1, Timer_SetMaxSpecialsCount, _, TIMER_FLAG_NO_MAPCHANGE);
        }
    }
}

public Action OnRoundEnd(Event hEvent, const char[] sName, bool bDontBroadcast)
{
    IsPlayerLeftCP = false;
    SetSpecialRunning(false);
    return Plugin_Continue;
}

public Action OnPlayerStuck(int client)
{
    if (IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3 && IsFakeClient(client))
    {
        if (IsPlayerTank(client) && !NCvar[CSpecial_AutoKill_StuckTank].BoolValue)
            return Plugin_Continue;

        if (!NCvar[CSpecial_AutoKill_StuckSpecials].BoolValue)
            return Plugin_Continue;

        KickClient(client, "Infected Stuck");
    }
    return Plugin_Continue;
}

public Action BinHook_OnSpawnSpecial()
{
    if (!NCvar[CSpecial_Spawn_Tank_Alive].BoolValue && NCvar[CSpecial_Spawn_Tank_Alive_Pro].BoolValue)
    {
        if (L4D2_IsTankInPlay())
        {
            for (int i = 1; i <= MaxClients; i++)
            {
                if (!IsClientInGame(i))
                    continue;

                if (GetClientTeam(i) != 3)
                    continue;

                if (IsPlayerTank(i))
                    continue;

                if (!IsFakeClient(i))
                    continue;

                KickClient(i, "Infected Not Allow Spawn");
            }
        }
    }

    if (NCvar[CSpecial_Random_Mode].BoolValue)
        TgModeStartSet();

    if (NCvar[CSpecial_Catch_FastPlayer].BoolValue)
    {
        int client = GetHighestFlowSurvivor();
        if (IsValidClient(client) && IsPlayerAlive(client))
        {
            if (GetCurrentFlowDistanceForPlayer(client) - GetAverageSurvivorFlowDistance() >= NCvar[CSpecial_Catch_FastPlayer_CheckDistance].FloatValue)
            {
                SetSpecialSpawnClient(client);
            }
        }
    }

    if (NCvar[CSpecial_Catch_SlowestPlayer].BoolValue)
    {
        int client = GetLowestFlowSurvivor();
        if (IsValidClient(client) && IsPlayerAlive(client))
        {
            if (GetAverageSurvivorFlowDistance() - GetCurrentFlowDistanceForPlayer(client) >= NCvar[CSpecial_Catch_SlowestPlayer_CheckDistance].FloatValue)
            {
                SetSpecialSpawnClient(client);
            }
        }
    }

    if (NCvar[CSpecial_Check_IsPlayerNotInCombat].BoolValue)
    {
        for (int i = 0; i <= MaxClients; i++)
        {
            if (IsValidClient(i) && IsPlayerAlive(i) && !IsClientInCombat(i))
            {
                SetSpecialSpawnClient(i);
            }
        }
    }

    return Plugin_Continue;
}

public Action OnTankDeath(Handle event, const char[] name, bool dontBroadcast)
{
    if (NCvar[CSpecial_PluginStatus].BoolValue)
        CreateTimer(0.2, Timer_DelayDeath);
    else
        SetSpecialRunning(false);

    return Plugin_Continue;
}

public Action Timer_DelayDeath(Handle hTimer)
{
    if (L4D2_IsTankInPlay() && !NCvar[CSpecial_Spawn_Tank_Alive].BoolValue)
        SetSpecialRunning(false);
    else
        SetSpecialRunning(true);

    return Plugin_Continue;
}

public Action OnPlayerDeath(Event hEvent, const char[] sName, bool bDontBroadcast)
{
    int client = GetClientOfUserId(hEvent.GetInt("userid"));
    if (IsValidClient(client) && IsFakeClient(client) && GetClientTeam(client) == 3)
        RequestFrame(Timer_KickBot, GetClientUserId(client));

    if (IsValidClient(client) && GetClientTeam(client) == 2 && NCvar[CSpecial_Num_NotCul_Death].BoolValue)
        SetMaxSpecialsCount();

    return Plugin_Continue;
}

public Action OnPlayerSpawn(Event hEvent, const char[] sName, bool bDontBroadcast)
{
    int client = GetClientOfUserId(hEvent.GetInt("userid"));

    if (IsValidClient(client) && GetClientTeam(client) == 2 && NCvar[CSpecial_Num_NotCul_Death].BoolValue)
        SetMaxSpecialsCount();

    return Plugin_Continue;
}

public Action OnTankSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if (NCvar[CSpecial_PluginStatus].BoolValue)
        SetSpecialRunning(NCvar[CSpecial_Spawn_Tank_Alive].BoolValue);
    else
        SetSpecialRunning(false);

    return Plugin_Continue;
}