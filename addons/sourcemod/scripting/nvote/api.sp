// Shared vote configuration helpers.

stock int ClampVoteConfigValue(ConVar cvar, int hardMin, int hardMax)
{
	int value = cvar.IntValue;
	if (value < hardMin)
		value = hardMin;
	else if (value > hardMax)
		value = hardMax;

	if (value != cvar.IntValue)
		cvar.SetInt(value);
	return value;
}

stock void NormalizeVoteRange(ConVar minCvar, ConVar maxCvar, int hardMin, int hardMax)
{
	int minValue = ClampVoteConfigValue(minCvar, hardMin, hardMax);
	int maxValue = ClampVoteConfigValue(maxCvar, hardMin, hardMax);
	if (minValue > maxValue)
	{
		// Keep the configured lower bound and collapse the upper bound to it.
		maxCvar.SetInt(minValue);
	}
}

stock void NormalizeVoteConfig()
{
	ClampVoteConfigValue(NCvar[Neko_VotePassPercent], 1, 100);
	ClampVoteConfigValue(NCvar[Neko_VoteMinPlayers], 1, 32);
	NormalizeVoteRange(NCvar[Neko_TimeMin], NCvar[Neko_TimeMax], 0, 180);
	NormalizeVoteRange(NCvar[Neko_NumMin], NCvar[Neko_NumMax], 1, 32);
	NormalizeVoteRange(NCvar[Neko_AddMin], NCvar[Neko_AddMax], 0, 8);
	NormalizeVoteRange(NCvar[Neko_PlayerNumMin], NCvar[Neko_PlayerNumMax], 1, 32);
	NormalizeVoteRange(NCvar[Neko_PlayerAddMin], NCvar[Neko_PlayerAddMax], 1, 8);
	NormalizeVoteRange(NCvar[Neko_DownCountMin], NCvar[Neko_DownCountMax], 1, 4);
	ClampVoteConfigValue(NCvar[Neko_NeedResetTime], 0, 3600);
}

stock bool GetVoteRange(const char[] item, int &minValue, int &maxValue, char[] label, int labelMax)
{
	if (StrEqual(item, "tgtime"))
	{
		minValue = NCvar[Neko_TimeMin].IntValue;
		maxValue = NCvar[Neko_TimeMax].IntValue;
		strcopy(label, labelMax, "刷特时间");
	}
	else if (StrEqual(item, "tgnum"))
	{
		minValue = NCvar[Neko_NumMin].IntValue;
		maxValue = NCvar[Neko_NumMax].IntValue;
		strcopy(label, labelMax, "初始刷特数量");
	}
	else if (StrEqual(item, "tgadd"))
	{
		minValue = NCvar[Neko_AddMin].IntValue;
		maxValue = NCvar[Neko_AddMax].IntValue;
		strcopy(label, labelMax, "进人增加数量");
	}
	else if (StrEqual(item, "tgpnum"))
	{
		minValue = NCvar[Neko_PlayerNumMin].IntValue;
		maxValue = NCvar[Neko_PlayerNumMax].IntValue;
		strcopy(label, labelMax, "初始玩家数量");
	}
	else if (StrEqual(item, "tgpadd"))
	{
		minValue = NCvar[Neko_PlayerAddMin].IntValue;
		maxValue = NCvar[Neko_PlayerAddMax].IntValue;
		strcopy(label, labelMax, "玩家增加间隔");
	}
	else if (StrEqual(item, "tgdowncount"))
	{
		minValue = NCvar[Neko_DownCountMin].IntValue;
		maxValue = NCvar[Neko_DownCountMax].IntValue;
		strcopy(label, labelMax, "倒地暂停人数");
	}
	else
	{
		return false;
	}

	return true;
}

stock bool IsVoteSubItemIntegerInRange(const char[] subItem, int minValue, int maxValue)
{
	int length = strlen(subItem);
	if (length <= 0 || length > 3)
		return false;

	int value;
	for (int i = 0; i < length; i++)
	{
		if (subItem[i] < '0' || subItem[i] > '9')
			return false;

		int digit = subItem[i] - '0';
		if (value > (maxValue - digit) / 10)
			return false;
		value = value * 10 + digit;
	}

	return value >= minValue && value <= maxValue;
}

stock bool IsVoteSubItemValid(const char[] item, const char[] subItem)
{
	if (StrEqual(item, "tgmode"))
		return IsVoteSubItemIntegerInRange(subItem, 1, 7);
	if (StrEqual(item, "tgspawn"))
		return IsVoteSubItemIntegerInRange(subItem, 0, 4);
	return true;
}

stock bool IsVoteItemEnabled(const char[] item)
{
	if (!NCvar[Neko_CanSwitch].BoolValue)
		return false;
	if (StrEqual(item, "tgstat"))
		return NCvar[Neko_SwitchStatus].BoolValue;
	if (StrEqual(item, "tgtime"))
		return NCvar[Neko_SwitchTime].BoolValue && !GCvar[CSpecial_Spawn_Time_DifficultyChange].BoolValue;
	if (StrEqual(item, "tgnum"))
		return NCvar[Neko_SwitchNumber].BoolValue;
	if (StrEqual(item, "tgadd"))
		return NCvar[Neko_SwitchNumAdd].BoolValue;
	if (StrEqual(item, "tgpnum"))
		return NCvar[Neko_SwitchPlayerJoin].BoolValue;
	if (StrEqual(item, "tgpadd"))
		return NCvar[Neko_SwitchPlayerAdd].BoolValue;
	if (StrEqual(item, "tgtanklive"))
		return NCvar[Neko_SwitchTankAlive].BoolValue;
	if (StrEqual(item, "tgdown"))
		return NCvar[Neko_SwitchPauseOnDown].BoolValue;
	if (StrEqual(item, "tgdowncount"))
		return NCvar[Neko_SwitchDownCount].BoolValue;
	if (StrEqual(item, "tgmode"))
		return NCvar[Neko_SwitchGameMode].BoolValue;
	if (StrEqual(item, "tgspawn"))
		return NCvar[Neko_SwitchSpawnMode].BoolValue;
	if (StrEqual(item, "tgrandom"))
		return NCvar[Neko_SwitchRandom].BoolValue;
	return false;
}

stock int GetSurvivorVotePool(int clients[MAXPLAYERS + 1])
{
	int count;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
			clients[count++] = i;
	}
	return count;
}

stock bool VoteRangeIsValid(const char[] item)
{
	int minValue, maxValue;
	char label[64];
	if (!GetVoteRange(item, minValue, maxValue, label, sizeof(label)))
		return true;
	return minValue <= maxValue;
}

stock int GetVotePassCount(int playerCount, int passPercent = -1)
{
	if (playerCount <= 0)
		return 1;

	if (passPercent < 0)
		passPercent = NCvar[Neko_VotePassPercent].IntValue;
	int required = RoundToCeil(float(playerCount) * float(passPercent) / 100.0);
	return required < 1 ? 1 : required;
}

stock void ScheduleVoteSnapshotCleanup()
{
	if (!VoteSnapshotActive || VoteSnapshotToken == 0)
		return;

	delete VoteSnapshotCleanupTimer;
	// Pass the owner token into the timer so a stale callback cannot clear a newer vote.
	VoteSnapshotCleanupTimer = CreateTimer(1.25, Timer_ClearVoteSnapshot, VoteSnapshotToken, TIMER_FLAG_NO_MAPCHANGE);
}

stock void ClearVoteSnapshot()
{
	delete VoteSnapshotCleanupTimer;
	VoteSnapshotCleanupTimer = null;
	VoteSnapshotActive = false;
	VoteSnapshotValue = 0;
	VoteSnapshotToken = 0;
	VoteSnapshotInitiatorUserId = 0;
	VoteSnapshotPassPercent = 0;
	VoteSnapshotItem = NULL_STRING;
	VoteSnapshotSubItem = NULL_STRING;
}

stock void SaveVoteConfig()
{
	NormalizeVoteConfig();
	UpdateConfigFile(false);
}
