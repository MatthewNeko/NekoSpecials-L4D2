public Action ChatListener(int client, const char[] command, int args)
{
	if (!IsValidClient(client) || IsFakeClient(client))
		return Plugin_Continue;

	char msg[128];
	GetCmdArgString(msg, sizeof(msg));
	StripQuotes(msg);
	TrimString(msg);

	if (BoolWaitForAdminItems[client])
	{
		if (!(GetUserFlagBits(client) & ADMFLAG_ROOT))
		{
			BoolWaitForAdminItems[client] = false;
			AdminEditItems[client] = NULL_STRING;
			AdminRangeItems[client] = NULL_STRING;
			return Plugin_Continue;
		}
		if (StrEqual(msg, "!cancel", false))
		{
			BoolWaitForAdminItems[client] = false;
			AdminEditItems[client] = NULL_STRING;
			PrintToChat(client, "\x05%s \x04本次设置已取消", NEKOTAG);
			return Plugin_Continue;
		}

		if (msg[0] == '\0' || !IsInteger(msg))
		{
			PrintToChat(client, "\x05%s \x04请输入非负整数，请重试", NEKOTAG);
			return Plugin_Continue;
		}

		int value = StringToInt(msg);
		ConVar target = null;
		int hardMin = 0, hardMax = 0;
		char title[64];
		strcopy(title, sizeof(title), "配置项");
		if (StrEqual(AdminEditItems[client], "pass"))
		{
			target = NCvar[Neko_VotePassPercent]; hardMin = 1; hardMax = 100; strcopy(title, sizeof(title), "投票通过率");
		}
		else if (StrEqual(AdminEditItems[client], "players"))
		{
			target = NCvar[Neko_VoteMinPlayers]; hardMin = 1; hardMax = 32; strcopy(title, sizeof(title), "最低投票池人数");
		}
		else if (StrEqual(AdminEditItems[client], "time_min"))
		{
			target = NCvar[Neko_TimeMin]; hardMin = 0; hardMax = 180; strcopy(title, sizeof(title), "刷特时间最小值");
		}
		else if (StrEqual(AdminEditItems[client], "time_max"))
		{
			target = NCvar[Neko_TimeMax]; hardMin = 0; hardMax = 180; strcopy(title, sizeof(title), "刷特时间最大值");
		}
		else if (StrEqual(AdminEditItems[client], "num_min"))
		{
			target = NCvar[Neko_NumMin]; hardMin = 1; hardMax = 32; strcopy(title, sizeof(title), "初始刷特数量最小值");
		}
		else if (StrEqual(AdminEditItems[client], "num_max"))
		{
			target = NCvar[Neko_NumMax]; hardMin = 1; hardMax = 32; strcopy(title, sizeof(title), "初始刷特数量最大值");
		}
		else if (StrEqual(AdminEditItems[client], "add_min"))
		{
			target = NCvar[Neko_AddMin]; hardMin = 0; hardMax = 8; strcopy(title, sizeof(title), "进人增加数量最小值");
		}
		else if (StrEqual(AdminEditItems[client], "add_max"))
		{
			target = NCvar[Neko_AddMax]; hardMin = 0; hardMax = 8; strcopy(title, sizeof(title), "进人增加数量最大值");
		}
		else if (StrEqual(AdminEditItems[client], "pnum_min"))
		{
			target = NCvar[Neko_PlayerNumMin]; hardMin = 1; hardMax = 32; strcopy(title, sizeof(title), "初始玩家数量最小值");
		}
		else if (StrEqual(AdminEditItems[client], "pnum_max"))
		{
			target = NCvar[Neko_PlayerNumMax]; hardMin = 1; hardMax = 32; strcopy(title, sizeof(title), "初始玩家数量最大值");
		}
		else if (StrEqual(AdminEditItems[client], "padd_min"))
		{
			target = NCvar[Neko_PlayerAddMin]; hardMin = 1; hardMax = 8; strcopy(title, sizeof(title), "玩家增加间隔最小值");
		}
		else if (StrEqual(AdminEditItems[client], "padd_max"))
		{
			target = NCvar[Neko_PlayerAddMax]; hardMin = 1; hardMax = 8; strcopy(title, sizeof(title), "玩家增加间隔最大值");
		}
		else if (StrEqual(AdminEditItems[client], "tgdowncount_min"))
		{
			target = NCvar[Neko_DownCountMin]; hardMin = 1; hardMax = 4; strcopy(title, sizeof(title), "倒地暂停人数最小值");
		}
		else if (StrEqual(AdminEditItems[client], "tgdowncount_max"))
		{
			target = NCvar[Neko_DownCountMax]; hardMin = 1; hardMax = 4; strcopy(title, sizeof(title), "倒地暂停人数最大值");
		}
		else if (StrEqual(AdminEditItems[client], "reset_time"))
		{
			target = NCvar[Neko_NeedResetTime]; hardMin = 0; hardMax = 3600; strcopy(title, sizeof(title), "无人重置延迟秒数");
		}

		if (target == null)
		{
			// Do not keep consuming chat for a stale/unknown menu state.  The
			// previous code also formatted an uninitialized title and bounds here.
			BoolWaitForAdminItems[client] = false;
			AdminEditItems[client] = NULL_STRING;
			AdminRangeItems[client] = NULL_STRING;
			PrintToChat(client, "\x05%s \x04当前管理员设置项已失效，请重新打开菜单", NEKOTAG);
			return Plugin_Continue;
		}
		if (value < hardMin || value > hardMax)
		{
			PrintToChat(client, "\x05%s \x04输入无效，%s范围为 [%d - %d]，请重试", NEKOTAG, title, hardMin, hardMax);
			return Plugin_Continue;
		}
		if ((StrEqual(AdminEditItems[client], "time_min") && value > NCvar[Neko_TimeMax].IntValue)
			|| (StrEqual(AdminEditItems[client], "num_min") && value > NCvar[Neko_NumMax].IntValue)
			|| (StrEqual(AdminEditItems[client], "add_min") && value > NCvar[Neko_AddMax].IntValue)
			|| (StrEqual(AdminEditItems[client], "pnum_min") && value > NCvar[Neko_PlayerNumMax].IntValue)
			|| (StrEqual(AdminEditItems[client], "padd_min") && value > NCvar[Neko_PlayerAddMax].IntValue)
			|| (StrEqual(AdminEditItems[client], "time_max") && value < NCvar[Neko_TimeMin].IntValue)
			|| (StrEqual(AdminEditItems[client], "num_max") && value < NCvar[Neko_NumMin].IntValue)
			|| (StrEqual(AdminEditItems[client], "add_max") && value < NCvar[Neko_AddMin].IntValue)
			|| (StrEqual(AdminEditItems[client], "pnum_max") && value < NCvar[Neko_PlayerNumMin].IntValue)
			|| (StrEqual(AdminEditItems[client], "padd_max") && value < NCvar[Neko_PlayerAddMin].IntValue)
			|| (StrEqual(AdminEditItems[client], "tgdowncount_min") && value > NCvar[Neko_DownCountMax].IntValue)
			|| (StrEqual(AdminEditItems[client], "tgdowncount_max") && value < NCvar[Neko_DownCountMin].IntValue))
		{
			PrintToChat(client, "\x05%s \x04范围边界不能覆盖当前另一边，请先调整另一边", NEKOTAG);
			return Plugin_Continue;
		}
		ClearVoteInteractionState();
		target.SetInt(value);
		BoolWaitForAdminItems[client] = false;
		AdminEditItems[client] = NULL_STRING;
		SaveVoteConfig();
		PrintToChat(client, "\x05%s \x04%s已设置为 \x03%d\x04，配置已保存", NEKOTAG, title, value);
		CreateTimer(0.1, Timer_ReloadAdminMenu, GetClientUserId(client));
		return Plugin_Continue;
	}

	if (BoolWaitForVoteItems[client])
	{
		if (StrEqual(msg, "!cancel", false))
		{
			PrintToChat(client, "\x05%s \x04本次操作取消", NEKOTAG);
			cleanplayerwait(client);
			cleanplayerchar(client);
			return Plugin_Continue;
		}
		if (!L4D2NativeVote_IsAllowNewVote())
		{
			PrintToChat(client, "\x05%s \x04暂时不能开启新的投票", NEKOTAG);
			cleanplayerwait(client);
			return Plugin_Continue;
		}

		int minValue, maxValue;
		char label[64];
		if (!GetVoteRange(WaitForVoteItems[client], minValue, maxValue, label, sizeof(label)) || minValue > maxValue)
		{
			PrintToChat(client, "\x05%s \x04该投票的后台范围设置无效，请联系管理员", NEKOTAG);
			cleanplayerwait(client);
			return Plugin_Continue;
		}
		if (msg[0] == '\0' || !IsInteger(msg))
		{
			PrintToChat(client, "\x05%s \x04请输入非负整数，请重试", NEKOTAG);
			return Plugin_Continue;
		}
		int value = StringToInt(msg);
		if (value < minValue || value > maxValue)
		{
			PrintToChat(client, "\x05%s \x04输入的%s有误，请重试，范围[%d - %d]", NEKOTAG, label, minValue, maxValue);
			return Plugin_Continue;
		}
		VoteMenuItems[client] = WaitForVoteItems[client];
		VoteMenuItemValue[client] = value;
		StartVoteYesNo(client);
		cleanplayerwait(client);
		return Plugin_Continue;
	}
	return Plugin_Continue;
}
