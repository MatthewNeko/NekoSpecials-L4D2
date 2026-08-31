

public void OnGameFrame()
{
    UpdateDownedPause();
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (NCvar[CSpecial_PluginStatus].BoolValue && GetSpecialRunning())
	{
		if (!IsPlayerAlive(client) || IsFakeClient(client) || GetClientTeam(client) != 2)
			return Plugin_Continue;

		if (NCvar[CSpecial_Check_IsPlayerBiled].BoolValue)
		{
			if (GetGameTime() - CheckBiledTime[client] >= NCvar[CSpecial_Check_IsPlayerBiled_Time].FloatValue)
			{
				if (IsMoreSpecialsAlive() && IsEntityBiled(client))
				{
					int GetRandom = GetRandomFreeInfected();
					if (IsValidClient(GetRandom) && IsPlayerAlive(GetRandom))
					{
						ResetFakeClient(GetRandom);
						SetFakeClientAimTarget(GetRandom, client);
					}
				}

				CheckBiledTime[client] = GetGameTime();
			}
		}

		if (NCvar[CSpecial_Attack_PlayerNotInCombat].BoolValue)
		{
			if (GetGameTime() - CheckFreeTime[client] >= 1.0)
			{
				if (IsClientInCombat(client) || !IsMoreSpecialsAlive())
					CheckNotCombat[client] = 0;
				else
					CheckNotCombat[client]++;

				if (CheckNotCombat[client] >= NCvar[CSpecial_Attack_PlayerNotInCombat_Time].IntValue)
				{
					if (IsMoreSpecialsAlive())
					{
						int GetRandom = GetRandomFreeInfected();
						if (IsValidClient(GetRandom) && IsPlayerAlive(GetRandom))
						{
							ResetFakeClient(GetRandom);
							SetFakeClientAimTarget(GetRandom, client);
						}
					}
					CheckNotCombat[client] = 0;
				}
				CheckFreeTime[client] = GetGameTime();
			}
		}
	}
	return Plugin_Continue;
}

stock int GetRandomFreeInfected()
{
	ArrayList aClients = new ArrayList();

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 3 && IsPlayerAlive(i) && IsFakeClient(i))
		{
			if (!GetInfectedBySurvivorControled(i))
				aClients.Push(i);
		}
	}

	int client;

	if (aClients.Length > 0)
		client = aClients.Get(GetRandomInt(0, aClients.Length - 1));

	delete aClients;

	return client;
}