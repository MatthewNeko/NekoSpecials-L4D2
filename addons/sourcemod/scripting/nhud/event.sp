

public void OnPlayerDisconnect(Event hEvent, const char[] sName, bool bDontBroadcast)
{
    int client = GetClientOfUserId(hEvent.GetInt("userid"));
    if (!client || (IsClientConnected(client) && !IsClientInGame(client))) return;

    Neko_ClientInfo[client].Reset();

    if (IsPlayerTank(client))
        CreateTimer(0.5, Timer_DelayDeath);
}

public void OnClientConnected(int client)
{
    Neko_ClientInfo[client].Reset();
}

public void OnMapStart()
{
    ResetHudSolt();
    HudRunning     = false;
    StyleChatDelay = NCvar[CKillHud_StyleChatDelay].IntValue;
    StartCatchTime();
}

public void OnConfigsExecuted()
{
    if (!IsMapTransition)
        Neko_GlobalState.ResetGO();
    else
        IsMapTransition = false;
}

public void OnMapEnd()
{
    HudRunning = false;

    ResetHudSolt();
}

/*public void OnTakeDamage(int victim, int attacker, int inflictor, float idamage, int damagetype)
{
    int damage = RoundToFloor(idamage);
    if (IsValidClient(victim) && IsValidClient(attacker) && victim != attacker && GetClientTeam(victim) == 2 && !IsFakeClient(attacker))
    {
        Neko_ClientInfo[victim].Friendly_Hurt += damage;
        Neko_ClientInfo[attacker].Friendly_Fire += damage;
    }

    if (TankAlive && IsPlayerTank(victim) && IsValidClient(attacker) && GetClientTeam(attacker) == 2 && !IsTankIncapacitated(victim))
        Neko_ClientInfo[attacker].DmgToTank += damage;
}*/

public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
    int victim   = GetClientOfUserId(GetEventInt(event, "userid"));
    int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    int damage   = GetEventInt(event, "dmg_health");

    if (IsValidClient(victim) && IsValidClient(attacker) && victim != attacker && GetClientTeam(victim) == 2 && !IsFakeClient(attacker))
    {
        Neko_ClientInfo[victim].Friendly_Hurt += damage;
        Neko_ClientInfo[attacker].Friendly_Fire += damage;
    }

    if (TankAlive && IsPlayerTank(victim) && IsValidClient(attacker) && GetClientTeam(attacker) == 2 && !IsTankIncapacitated(victim))
        Neko_ClientInfo[attacker].DmgToTank += damage;

    return Plugin_Continue;
}

public Action Timer_DelayDeath(Handle hTimer)
{
    if (IsTankLive())
        TankAlive = true;
    else
    {
        TankAlive = false;
        if (NCvar[CKillHud_KillTank].BoolValue && NCvar[CKillHud_HudStyle].IntValue > 0)
            CreateTimer(0.1, KillTankHUD);
    }
    return Plugin_Continue;
}

public Action Event_Round_Start(Event event, const char[] name, bool dontBroadcast)
{
    HudRunning = false;

    Kill_Init();

    CreateTimer(0.2, RoundStart, _, TIMER_FLAG_NO_MAPCHANGE);

    return Plugin_Continue;
}

public Action RoundStart(Handle Timer)
{
    if (NCvar[CKillHud_Show].BoolValue)
        CreateTimer(1.0, PlayerLeftStart, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    else
        CreateHud();
    return Plugin_Continue;
}

public Action PlayerLeftStart(Handle Timer)
{
    if (L4D_HasAnySurvivorLeftSafeArea())
    {
        CreateHud();
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

public Action Event_Round_End(Event event, const char[] name, bool dontBroadcast)
{
    HudRunning = false;
    Kill_Init();
    return Plugin_Continue;
}

public Action Event_PlayerIncapPre(Event event, const char[] name, bool dontBroadcast)
{
    int victim   = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));

    if (IsValidClient(victim) && IsValidClient(attacker) && victim != attacker && GetClientTeam(victim) == 2 && !IsFakeClient(attacker))
    {
        int damage = GetClientHealth(victim);
        Neko_ClientInfo[victim].Friendly_Hurt += damage;
        Neko_ClientInfo[attacker].Friendly_Fire += damage;
    }

    if (TankAlive && IsPlayerTank(victim) && IsValidClient(attacker) && GetClientTeam(attacker) == 2 && !IsTankIncapacitated(victim))
    {
        int damage = GetClientHealth(victim);
        Neko_ClientInfo[attacker].DmgToTank += damage;
    }

    return Plugin_Continue;
}

/*public Action Event_PlayerDeathPre(Event event, const char[] name, bool dontBroadcast)
{
    int victim   = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));

    if (IsValidClient(victim) && IsValidClient(attacker) && victim != attacker && GetClientTeam(victim) == 2 && !IsFakeClient(attacker))
    {
        int damage = GetClientHealth(victim);
        Neko_ClientInfo[victim].Friendly_Hurt += damage;
        Neko_ClientInfo[attacker].Friendly_Fire += damage;
    }

    if (TankAlive && IsPlayerTank(victim) && IsValidClient(attacker) && GetClientTeam(attacker) == 2 && !IsTankIncapacitated(victim))
    {
        int damage = GetClientHealth(victim);
        Neko_ClientInfo[attacker].DmgToTank += damage;
    }

    return Plugin_Continue;
}*/

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int victim   = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));

    if (IsValidClient(victim) && GetClientTeam(victim) == 3 && !IsPlayerTank(victim) && IsValidClient(attacker) && GetClientTeam(attacker) == 2)
    {
        Neko_ClientInfo[attacker].Kill_Infected++;
        Neko_GlobalState.Kill_AllInfected++;
        Neko_GlobalState.Kill_AllInfectedGO++;
    }

    return Plugin_Continue;
}

public Action Event_infectedDeath(Event event, const char[] name, bool dontBroadcast)
{
    int attacker = GetClientOfUserId(event.GetInt("attacker"));

    if (IsValidClient(attacker) && GetClientTeam(attacker) == 2)
    {
        Neko_GlobalState.Kill_AllZombie++;
        Neko_GlobalState.Kill_AllZombieGO++;
        Neko_ClientInfo[attacker].Kill_Zombie++;
    }

    return Plugin_Continue;
}

public Action Event_MapTransition(Event event, const char[] name, bool dontBroadcast)
{
    IsMapTransition = true;
    return Plugin_Continue;
}