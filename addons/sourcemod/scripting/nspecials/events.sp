

static void SchedulePlayerLeftTimer()
{
    if (g_hPlayerLeftTimer != null)
        delete g_hPlayerLeftTimer;

    g_hPlayerLeftTimer = CreateTimer(0.1, PlayerLeftStart, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

static void ScheduleSetMaxSpecialsTimer()
{
    if (g_hSetMaxSpecialsTimer == null)
        g_hSetMaxSpecialsTimer = CreateTimer(0.1, Timer_SetMaxSpecialsCount, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
    IsPlayerLeftCP = false;
    g_DownedPauseActive = false;
    SetSpecialRunning(false);
    TgModeStartSet();
    SchedulePlayerLeftTimer();
    return Plugin_Continue;
}

public Action player_team(Event event, const char[] name, bool dontBroadcast)
{
    ScheduleSetMaxSpecialsTimer();
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
            ScheduleSetMaxSpecialsTimer();
        }
    }
}

public Action OnRoundEnd(Event hEvent, const char[] sName, bool bDontBroadcast)
{
    IsPlayerLeftCP = false;
    g_DownedPauseActive = false;
    SetSpecialRunning(false);
    if (g_hPlayerLeftTimer != null)
    {
        delete g_hPlayerLeftTimer;
        g_hPlayerLeftTimer = null;
    }
    if (g_hSetMaxSpecialsTimer != null)
    {
        delete g_hSetMaxSpecialsTimer;
        g_hSetMaxSpecialsTimer = null;
    }
    SetSpecialSpawnClient(0);
    return Plugin_Continue;
}

public Action OnPlayerStuck(int client)
{
    if(!NCvar[CSpecial_PluginStatus].BoolValue)
        return Plugin_Continue;

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
    // BinHooks consumes the target after this whole spawn batch. Do not clear
    // a target installed by another plugin before it gets a chance to use it.
    int target = 0;

    if (NCvar[CSpecial_Random_Mode].BoolValue)
        TgModeStartSet();

    if (NCvar[CSpecial_Catch_FastPlayer].BoolValue)
    {
        int client = GetClientOfUserId(GetHighestFlowSurvivor());
        if (IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2 &&
            GetCurrentFlowDistanceForPlayer(client) - GetAverageSurvivorFlowDistance() >= NCvar[CSpecial_Catch_FastPlayer_CheckDistance].FloatValue)
        {
            target = client;
        }
    }

    if (NCvar[CSpecial_Catch_SlowestPlayer].BoolValue)
    {
        int client = GetClientOfUserId(GetLowestFlowSurvivor());
        if (IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2 &&
            GetAverageSurvivorFlowDistance() - GetCurrentFlowDistanceForPlayer(client) >= NCvar[CSpecial_Catch_SlowestPlayer_CheckDistance].FloatValue)
        {
            target = client;
        }
    }

    if (NCvar[CSpecial_Check_IsPlayerNotInCombat].BoolValue)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2 && !IsClientInCombat(i))
            {
                target = i;
                break;
            }
        }
    }

    if (target > 0)
        SetSpecialSpawnClient(target);

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

    // Tank transitions can change the running flag after the downed-player
    // handler. Re-apply the downed pause ownership before returning.
    UpdateDownedPause();
    return Plugin_Continue;
}

stock int CountIncapacitatedSurvivors()
{
    int count;
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client) || GetClientTeam(client) != 2 || !IsPlayerAlive(client))
            continue;
        if (HasEntProp(client, Prop_Send, "m_isIncapacitated") && GetEntProp(client, Prop_Send, "m_isIncapacitated") != 0)
            count++;
    }
    return count;
}

stock bool CanRunSpecialsNormally()
{
    if (!NCvar[CSpecial_PluginStatus].BoolValue || !IsPlayerLeftCP)
        return false;
    if (L4D2_IsTankInPlay() && !NCvar[CSpecial_Spawn_Tank_Alive].BoolValue)
        return false;
    return true;
}

void UpdateDownedPause()
{
    if (!NCvar[CSpecial_PauseOnDown].BoolValue)
    {
        if (g_DownedPauseActive)
        {
            g_DownedPauseActive = false;
            if (CanRunSpecialsNormally())
                SetSpecialRunning(true);
        }
        return;
    }

    int downed = CountIncapacitatedSurvivors();
    int threshold = NCvar[CSpecial_DownCount].IntValue;
    if (threshold < 1)
        threshold = 1;

    if (downed >= threshold)
    {
        // Only claim the pause if this feature actually stopped a running
        // spawner. Tank/round/plugin pauses remain owned by their own logic.
        if (!g_DownedPauseActive && GetSpecialRunning() && CanRunSpecialsNormally())
            g_DownedPauseActive = true;
        if (g_DownedPauseActive && GetSpecialRunning())
            SetSpecialRunning(false);
        return;
    }

    if (g_DownedPauseActive)
    {
        g_DownedPauseActive = false;
        if (CanRunSpecialsNormally())
            SetSpecialRunning(true);
    }
}

public Action OnPlayerIncapacitated(Event event, const char[] name, bool dontBroadcast)
{
    UpdateDownedPause();
    return Plugin_Continue;
}

public Action OnReviveSuccess(Event event, const char[] name, bool dontBroadcast)
{
    UpdateDownedPause();
    return Plugin_Continue;
}

public Action OnPlayerDeath(Event hEvent, const char[] sName, bool bDontBroadcast)
{
    if(!NCvar[CSpecial_PluginStatus].BoolValue)
        return Plugin_Continue;

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

    if (!IsValidClient(client))
        return Plugin_Continue;

    if (GetClientTeam(client) == 2 && NCvar[CSpecial_Num_NotCul_Death].BoolValue)
        SetMaxSpecialsCount();

    // Preserve the Tank-only policy without deleting specials that were
    // already fighting before this spawn event. Only the newly spawned bot is
    // eligible for this cleanup.
    if (GetClientTeam(client) == 3 && IsFakeClient(client) &&
        !NCvar[CSpecial_Spawn_Tank_Alive].BoolValue &&
        NCvar[CSpecial_Spawn_Tank_Alive_Pro].BoolValue &&
        L4D2_IsTankInPlay() && !IsPlayerTank(client))
    {
        KickClient(client, "Infected Not Allow Spawn");
    }

    return Plugin_Continue;
}

public Action OnTankSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if (NCvar[CSpecial_PluginStatus].BoolValue)
        SetSpecialRunning(NCvar[CSpecial_Spawn_Tank_Alive].BoolValue);
    else
        SetSpecialRunning(false);

    // A Tank spawn may overwrite a pause established by an incapacitation
    // event, so let the feature restore its state after the Tank policy runs.
    UpdateDownedPause();
    return Plugin_Continue;
}