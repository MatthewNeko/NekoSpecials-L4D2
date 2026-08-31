

public Action ChatListener(int client, const char[] command, int args)
{
	if (!IsValidClient(client) || IsFakeClient(client) || IsChatTrigger())
		return Plugin_Continue;

	if (N_ClientItem[client].InWait())
	{
		char msg[128];

		GetCmdArgString(msg, sizeof(msg));
		StripQuotes(msg);

		if (StrEqual(msg, "!cancel"))
		{
			PrintToChat(client, "\x05%s \x04本次操作取消", NEKOTAG);
			N_ClientItem[client].Reset();
			return Plugin_Continue;
		}

		if (N_ClientItem[client].WaitingForTgtime)
		{
			if (GetCmdArgInt(1) < 0 || GetCmdArgInt(1) > 180)
			{
				PrintToChat(client, "\x05%s \x04输入的时间有误，请重试 \x03范围[3 - 180]", NEKOTAG);
				return Plugin_Continue;
			}
			else
			{
				if (StrEqual(N_ClientItem[client].WaitingForTgTimeType, "tgtime"))
					NCvar[CSpecial_Spawn_Time].SetInt(GetCmdArgInt(1));
				else if (StrEqual(N_ClientItem[client].WaitingForTgTimeType, "tgtimeeasy"))
					NCvar[CSpecial_Spawn_Time_Easy].SetInt(GetCmdArgInt(1));
				else if (StrEqual(N_ClientItem[client].WaitingForTgTimeType, "tgtimenormal"))
					NCvar[CSpecial_Spawn_Time_Normal].SetInt(GetCmdArgInt(1));
				else if (StrEqual(N_ClientItem[client].WaitingForTgTimeType, "tgtimehard"))
					NCvar[CSpecial_Spawn_Time_Hard].SetInt(GetCmdArgInt(1));
				else if (StrEqual(N_ClientItem[client].WaitingForTgTimeType, "tgtimeexpert"))
					NCvar[CSpecial_Spawn_Time_Impossible].SetInt(GetCmdArgInt(1));

				PrintToChat(client, "\x05%s \x04更改刷特时间为 \x03%i 秒", NEKOTAG, GetSpecialRespawnInterval());
			}
		}
		else if (N_ClientItem[client].WaitingForTgnum)
		{
			if (GetCmdArgInt(1) < 1 || GetCmdArgInt(1) > 32)
			{
				PrintToChat(client, "\x05%s \x04输入的数量有误，请重试 \x03范围[1 - 32]", NEKOTAG);
				return Plugin_Continue;
			}
			else
			{
				NCvar[CSpecial_Num].SetInt(GetCmdArgInt(1));
				PrintToChat(client, "\x05%s \x04更改刷特初始数量为 \x03%i ", NEKOTAG, GetCmdArgInt(1));
				if(GetCmdArgInt(1) > 28 && NCvar[CSpecial_AddNum].IntValue >= 1 && NCvar[CSpecial_PlayerNum].IntValue >= 4)
				{
					PrintToChat(client, "\x05%s \x03注意: \x04当设置刷特数大于28时或达到32时，实际刷特数量计算公式为\x03 31位置-人类数量 \x04，这是由于求生的引擎过老限制所导致的，同时如果要达到20特以上，\x03你还需要安装多人破解拓展！", NEKOTAG);
					PrintToChat(client, "\x05%s \x04多人破解拓展获取地址 \x03https://github.com/lakwsh/l4dtoolz", NEKOTAG);
				}
			}
		}
		else if (N_ClientItem[client].WaitingForTgadd)
		{
			if (GetCmdArgInt(1) < 0 || GetCmdArgInt(1) > 8)
			{
				PrintToChat(client, "\x05%s \x04输入的数量有误，请重试 \x03范围[0 - 8]", NEKOTAG);
				return Plugin_Continue;
			}
			else
			{
				NCvar[CSpecial_AddNum].SetInt(GetCmdArgInt(1));
				PrintToChat(client, "\x05%s \x04更改刷特增加数量为 \x03%i ", NEKOTAG, GetCmdArgInt(1));
			}
		}
		else if (N_ClientItem[client].WaitingForPnum)
		{
			if (GetCmdArgInt(1) < 1 || GetCmdArgInt(1) > 32)
			{
				PrintToChat(client, "\x05%s \x04输入的数量有误，请重试 \x03范围[1 - 8]", NEKOTAG);
				return Plugin_Continue;
			}
			else
			{
				NCvar[CSpecial_PlayerNum].SetInt(GetCmdArgInt(1));
				PrintToChat(client, "\x05%s \x04更改初始玩家数量为 \x03%i ", NEKOTAG, GetCmdArgInt(1));
			}
		}
		else if (N_ClientItem[client].WaitingForPadd)
		{
			if (GetCmdArgInt(1) < 1 || GetCmdArgInt(1) > 8)
			{
				PrintToChat(client, "\x05%s \x04输入的数量有误，请重试 \x03范围[1 - 8]", NEKOTAG);
				return Plugin_Continue;
			}
			else
			{
				NCvar[CSpecial_PlayerAdd].SetInt(GetCmdArgInt(1));
				PrintToChat(client, "\x05%s \x04更改玩家增加数量为 \x03%i ", NEKOTAG, GetCmdArgInt(1));
			}
		}
		else if (N_ClientItem[client].WaitingForTgDownCount)
		{
			int value = GetCmdArgInt(1);
			if (value < 1 || value > 4)
			{
				PrintToChat(client, "\x05%s \x04输入的倒地暂停人数有误，请重试 \x03范围[1 - 4]", NEKOTAG);
				return Plugin_Continue;
			}
			NCvar[CSpecial_DownCount].SetInt(value);
			PrintToChat(client, "\x05%s \x04倒地暂停人数设置为 \x03%d", NEKOTAG, value);
		}
		else if (N_ClientItem[client].WaitingForTgCustom)
		{
			if (GetCmdArgInt(1) < 0 || GetCmdArgInt(1) > 32)
			{
				PrintToChat(client, "\x05%s \x04输入的数量有误，请重试 \x03范围[0 - 32]", NEKOTAG);
				return Plugin_Continue;
			}
			else
			{
				switch (StringToInt(N_ClientItem[client].WaitingForTgCustomItem))
				{
					case 1: NCvar[CSpecial_Charger_Num].SetInt(GetCmdArgInt(1));
					case 2: NCvar[CSpecial_Boomer_Num].SetInt(GetCmdArgInt(1));
					case 3: NCvar[CSpecial_Spitter_Num].SetInt(GetCmdArgInt(1));
					case 4: NCvar[CSpecial_Smoker_Num].SetInt(GetCmdArgInt(1));
					case 5: NCvar[CSpecial_Jockey_Num].SetInt(GetCmdArgInt(1));
					case 6: NCvar[CSpecial_Hunter_Num].SetInt(GetCmdArgInt(1));
				}

				PrintToChat(client, "\x05%s \x04%s数量设置为 \x03%d", NEKOTAG, SpecialName[StringToInt(N_ClientItem[client].WaitingForTgCustomItem)], GetCmdArgInt(1));
				NCvar[CSpecial_Default_Mode].SetInt(7);

				if (NCvar[CSpecial_Show_Tips].BoolValue)
					ModeTips();
				if (NCvar[CSpecial_Random_Mode].BoolValue)
				{
					NCvar[CSpecial_Random_Mode].SetBool(false);
					PrintToChat(client, "\x05%s \x04关闭了随机特感", NEKOTAG);
				}
			}
		}
		else if (N_ClientItem[client].WaitingForTgCustomWeight)
		{
			if (GetCmdArgInt(1) < 1 || GetCmdArgInt(1) > 100)
			{
				PrintToChat(client, "\x05%s \x04输入的概率有误，请重试 \x03范围[1 - 100]", NEKOTAG);
				return Plugin_Continue;
			}
			else
			{
				switch (StringToInt(N_ClientItem[client].WaitingForTgCustomWeightItem))
				{
					case 1: NCvar[CSpecial_Charger_Spawn_Weight].SetInt(GetCmdArgInt(1));
					case 2: NCvar[CSpecial_Boomer_Spawn_Weight].SetInt(GetCmdArgInt(1));
					case 3: NCvar[CSpecial_Spitter_Spawn_Weight].SetInt(GetCmdArgInt(1));
					case 4: NCvar[CSpecial_Smoker_Spawn_Weight].SetInt(GetCmdArgInt(1));
					case 5: NCvar[CSpecial_Jockey_Spawn_Weight].SetInt(GetCmdArgInt(1));
					case 6: NCvar[CSpecial_Hunter_Spawn_Weight].SetInt(GetCmdArgInt(1));
				}

				PrintToChat(client, "\x05%s \x04%s刷新概率设置为 \x03%d", NEKOTAG, SpecialName[StringToInt(N_ClientItem[client].WaitingForTgCustomWeightItem)], GetCmdArgInt(1));
			}
		}
		else if (N_ClientItem[client].WaitingForTgCustomDirChance)
		{
			if (GetCmdArgInt(1) < 1 || GetCmdArgInt(1) > 100)
			{
				PrintToChat(client, "\x05%s \x04输入的概率有误，请重试 \x03范围[1 - 100]", NEKOTAG);
				return Plugin_Continue;
			}
			else
			{
				switch (StringToInt(N_ClientItem[client].WaitingForTgCustomDirChanceItem))
				{
					case 1: NCvar[CSpecial_Charger_Spawn_DirChance].SetInt(GetCmdArgInt(1));
					case 2: NCvar[CSpecial_Boomer_Spawn_DirChance].SetInt(GetCmdArgInt(1));
					case 3: NCvar[CSpecial_Spitter_Spawn_DirChance].SetInt(GetCmdArgInt(1));
					case 4: NCvar[CSpecial_Smoker_Spawn_DirChance].SetInt(GetCmdArgInt(1));
					case 5: NCvar[CSpecial_Jockey_Spawn_DirChance].SetInt(GetCmdArgInt(1));
					case 6: NCvar[CSpecial_Hunter_Spawn_DirChance].SetInt(GetCmdArgInt(1));
				}
				PrintToChat(client, "\x05%s \x04%s刷新方位百分比设置为 \x03%d", NEKOTAG, SpecialName[StringToInt(N_ClientItem[client].WaitingForTgCustomDirChanceItem)], GetCmdArgInt(1));
			}
		}
		else if (N_ClientItem[client].WaitingForTgCustomMaxDis)
		{
			if (GetCmdArgInt(1) < 1)
			{
				PrintToChat(client, "\x05%s \x04输入的数值有误，请重试 \x03范围[不能小于1，不要小于最小距离]", NEKOTAG);
				return Plugin_Continue;
			}
			else
			{
				switch (StringToInt(N_ClientItem[client].WaitingForTgCustomMaxDisItem))
				{
					case 1: NCvar[CSpecial_Charger_Spawn_MaxDis].SetInt(GetCmdArgInt(1));
					case 2: NCvar[CSpecial_Boomer_Spawn_MaxDis].SetInt(GetCmdArgInt(1));
					case 3: NCvar[CSpecial_Spitter_Spawn_MaxDis].SetInt(GetCmdArgInt(1));
					case 4: NCvar[CSpecial_Smoker_Spawn_MaxDis].SetInt(GetCmdArgInt(1));
					case 5: NCvar[CSpecial_Jockey_Spawn_MaxDis].SetInt(GetCmdArgInt(1));
					case 6: NCvar[CSpecial_Hunter_Spawn_MaxDis].SetInt(GetCmdArgInt(1));
				}
				PrintToChat(client, "\x05%s \x04%s刷新最大距离设置为 \x03%d", NEKOTAG, SpecialName[StringToInt(N_ClientItem[client].WaitingForTgCustomMaxDisItem)], GetCmdArgInt(1));
			}
		}
		else if (N_ClientItem[client].WaitingForTgCustomMinDis)
		{
			if (GetCmdArgInt(1) < 1)
			{
				PrintToChat(client, "\x05%s \x04输入的数值有误，请重试 \x03范围[不能小于1，不要超过最大距离]", NEKOTAG);
				return Plugin_Continue;
			}
			else
			{
				switch (StringToInt(N_ClientItem[client].WaitingForTgCustomMinDisItem))
				{
					case 1: NCvar[CSpecial_Charger_Spawn_MinDis].SetInt(GetCmdArgInt(1));
					case 2: NCvar[CSpecial_Boomer_Spawn_MinDis].SetInt(GetCmdArgInt(1));
					case 3: NCvar[CSpecial_Spitter_Spawn_MinDis].SetInt(GetCmdArgInt(1));
					case 4: NCvar[CSpecial_Smoker_Spawn_MinDis].SetInt(GetCmdArgInt(1));
					case 5: NCvar[CSpecial_Jockey_Spawn_MinDis].SetInt(GetCmdArgInt(1));
					case 6: NCvar[CSpecial_Hunter_Spawn_MinDis].SetInt(GetCmdArgInt(1));
				}
				PrintToChat(client, "\x05%s \x04%s刷新最小距离设置为 \x03%d", NEKOTAG, SpecialName[StringToInt(N_ClientItem[client].WaitingForTgCustomMinDisItem)], GetCmdArgInt(1));
			}
		}
		else if (N_ClientItem[client].WaitingForTgCustomMaxDisNor)
		{
			if (GetCmdArgInt(1) < 1)
			{
				PrintToChat(client, "\x05%s \x04输入的数值有误，请重试 \x03范围[不能小于1，不要小于最小距离]", NEKOTAG);
				return Plugin_Continue;
			}
			else
			{
				NCvar[CSpecial_Spawn_MaxDis].SetInt(GetCmdArgInt(1));
				PrintToChat(client, "\x05%s \x04全特感刷新最小距离设置为 \x03%d", NEKOTAG, GetCmdArgInt(1));
			}
		}
		else if (N_ClientItem[client].WaitingForTgCustomMinDisNor)
		{
			if (GetCmdArgInt(1) < 1)
			{
				PrintToChat(client, "\x05%s \x04输入的数值有误，请重试 \x03范围[不能小于1，不要超过最大距离]", NEKOTAG);
				return Plugin_Continue;
			}
			else
			{
				NCvar[CSpecial_Spawn_MinDis].SetInt(GetCmdArgInt(1));
				PrintToChat(client, "\x05%s \x04全特感刷新最小距离设置为 \x03%d", NEKOTAG, GetCmdArgInt(1));
			}
		}
		else if (N_ClientItem[client].WaitingForTgFastPDis)
		{
			if (GetCmdArgFloat(1) < 100.0 || GetCmdArgFloat(1) > 10000.0)
			{
				PrintToChat(client, "\x05%s \x04输入的数值有误，请重试 \x03范围[100.0 至 10000.0]", NEKOTAG);
				return Plugin_Continue;
			}
			else
			{
				NCvar[CSpecial_Catch_FastPlayer_CheckDistance].SetFloat(GetCmdArgFloat(1));
				PrintToChat(client, "\x05%s \x04最快玩家与队伍之间相隔最大距离设置为 \x03%0.1f", NEKOTAG, GetCmdArgFloat(1));
			}
		}
		else if (N_ClientItem[client].WaitingForTgSlowPDis)
		{
			if (GetCmdArgFloat(1) < 100.0 || GetCmdArgFloat(1) > 10000.0)
			{
				PrintToChat(client, "\x05%s \x04输入的数值有误，请重试 \x03范围[100.0 至 10000.0]", NEKOTAG);
				return Plugin_Continue;
			}
			else
			{
				NCvar[CSpecial_Catch_SlowestPlayer_CheckDistance].SetFloat(GetCmdArgFloat(1));
				PrintToChat(client, "\x05%s \x04掉队玩家与队伍之间相隔最大距离设置为 \x03%0.1f", NEKOTAG, GetCmdArgFloat(1));
			}
		}
		else if (N_ClientItem[client].WaitingForTgCheckBliedTime)
		{
			if (GetCmdArgFloat(1) < 0.1 || GetCmdArgFloat(1) > 2.0)
			{
				PrintToChat(client, "\x05%s \x04输入的数值有误，请重试 \x03范围[0.1 至 2.0]", NEKOTAG);
				return Plugin_Continue;
			}
			else
			{
				NCvar[CSpecial_Check_IsPlayerBiled_Time].SetFloat(GetCmdArgFloat(1));
				PrintToChat(client, "\x05%s \x04检查间隔设置为 \x03%0.1f", NEKOTAG, GetCmdArgFloat(1));
			}
		}
		else if (N_ClientItem[client].WaitingForTgCheckNotInCombat)
		{
			if (GetCmdArgInt(1) < 3 || GetCmdArgInt(1) > 15)
			{
				PrintToChat(client, "\x05%s \x04输入的数值有误，请重试 \x03范围[3 至 15]", NEKOTAG);
				return Plugin_Continue;
			}
			else
			{
				NCvar[CSpecial_Attack_PlayerNotInCombat_Time].SetInt(GetCmdArgInt(1));
				PrintToChat(client, "\x05%s \x04摸鱼最大秒数设置为 \x03%d", NEKOTAG, GetCmdArgInt(1));
			}
		}

		N_ClientItem[client].Reset();
		N_ClientMenu[client].Reset();

		if (N_ClientItem[client].WaitingForTgCustom)
			SpecialMenuCustom(client).Display(client, MENU_TIME);
		else if (N_ClientItem[client].WaitingForTgCustomWeight)
			SpecialMenuCustomWeight(client).Display(client, MENU_TIME);
		else if (N_ClientItem[client].WaitingForTgCustomDirChance)
			SpecialMenuCustomDirChance(client).Display(client, MENU_TIME);
		else if (N_ClientItem[client].WaitingForTgCustomMaxDis)
			SpecialMenuCustomMaxDis(client).Display(client, MENU_TIME);
		else if (N_ClientItem[client].WaitingForTgCustomMinDis)
			SpecialMenuCustomMinDis(client).Display(client, MENU_TIME);
		else
			SpecialMenu(client).DisplayAt(client, N_ClientMenu[client].MenuPageItem, MENU_TIME);

		return Plugin_Continue;
	}
	return Plugin_Continue;
}
