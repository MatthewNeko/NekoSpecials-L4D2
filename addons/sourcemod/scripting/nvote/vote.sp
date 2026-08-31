stock void ClearVoteInitiatorState(bool keepNativeOwnership = false)
{
	int initiator = GetClientOfUserId(VoteSnapshotInitiatorUserId);
	if (IsValidClient(initiator))
		cleanplayerchar(initiator);

	if (keepNativeOwnership)
		ScheduleVoteSnapshotCleanup();
	else
		ClearVoteSnapshot();
}

void StartVoteYesNo(int client)
{
	if (!IsValidClient(client))
		return;

	char item[64];
	strcopy(item, sizeof(item), VoteMenuItems[client]);
	if (!IsVoteItemEnabled(item))
	{
		PrintToChat(client, "\x05%s \x04该投票项目当前已关闭", NEKOTAG);
		cleanplayerchar(client);
		return;
	}
	if (!IsVoteSubItemValid(item, SubMenuVoteItems[client]))
	{
		PrintToChat(client, "\x05%s \x04该投票选项无效，请重新选择", NEKOTAG);
		cleanplayerchar(client);
		return;
	}
	if (!VoteRangeIsValid(item))
	{
		PrintToChat(client, "\x05%s \x04该投票的后台范围设置无效，请联系管理员", NEKOTAG);
		cleanplayerchar(client);
		return;
	}
	if (!L4D2NativeVote_IsAllowNewVote())
	{
		PrintToChat(client, "\x05%s \x04暂时不能开启新的投票", NEKOTAG);
		cleanplayerchar(client);
		return;
	}

	int minValue, maxValue;
	char label[64];
	if (GetVoteRange(item, minValue, maxValue, label, sizeof(label))
		&& (VoteMenuItemValue[client] < minValue || VoteMenuItemValue[client] > maxValue))
	{
		PrintToChat(client, "\x05%s \x04输入的%s已超出当前后台范围[%d - %d]", NEKOTAG, label, minValue, maxValue);
		cleanplayerchar(client);
		return;
	}

	char buffer[512], sbuffer[512];

	if (StrEqual(item, "tgstat"))
	{
		Format(buffer, sizeof buffer, "多特插件");
		Format(sbuffer, sizeof sbuffer, "%s", !GCvar[CSpecial_PluginStatus].BoolValue ? "开启" : "关闭");
	}
	if (StrEqual(item, "tgrandom"))
	{
		Format(buffer, sizeof buffer, "随机特感");
		Format(sbuffer, sizeof sbuffer, "%s", !GCvar[CSpecial_Random_Mode].BoolValue ? "开启" : "关闭");
	}
	if (StrEqual(item, "tgtanklive"))
	{
		Format(buffer, sizeof buffer, "坦克存活时刷新特感");
		Format(sbuffer, sizeof sbuffer, "%s", !GCvar[CSpecial_Spawn_Tank_Alive].BoolValue ? "开启" : "关闭");
	}
	if (StrEqual(item, "tgdown"))
	{
		Format(buffer, sizeof buffer, "倒地暂停刷特");
		Format(sbuffer, sizeof sbuffer, "%s", !GCvar[CSpecial_PauseOnDown].BoolValue ? "开启" : "关闭");
	}
	if (StrEqual(item, "tgdowncount"))
	{
		Format(buffer, sizeof buffer, "倒地暂停人数为");
		Format(sbuffer, sizeof sbuffer, "%d 人", VoteMenuItemValue[client]);
	}
	if (StrEqual(item, "tgtime"))
	{
		Format(buffer, sizeof buffer, "刷特时间为");
		Format(sbuffer, sizeof sbuffer, "%d s", VoteMenuItemValue[client]);
	}
	if (StrEqual(item, "tgnum"))
	{
		Format(buffer, sizeof buffer, "初始刷特数量为");
		Format(sbuffer, sizeof sbuffer, "%d 特", VoteMenuItemValue[client]);
	}
	if (StrEqual(item, "tgadd"))
	{
		Format(buffer, sizeof buffer, "进人增加数量为");
		Format(sbuffer, sizeof sbuffer, "%d 特", VoteMenuItemValue[client]);
	}
	if (StrEqual(item, "tgpnum"))
	{
		Format(buffer, sizeof buffer, "初始玩家数量为");
		Format(sbuffer, sizeof sbuffer, "%d 人", VoteMenuItemValue[client]);
	}
	if (StrEqual(item, "tgpadd"))
	{
		Format(buffer, sizeof buffer, "玩家增加数量为");
		Format(sbuffer, sizeof sbuffer, "%d 人", VoteMenuItemValue[client]);
	}
	if (StrEqual(item, "tgmode"))
	{
		int mode = StringToInt(SubMenuVoteItems[client]);
		Format(sbuffer, sizeof(sbuffer), "%s", SpecialName[mode >= 1 && mode <= 7 ? mode : 7]);
		Format(buffer, sizeof buffer, "游戏模式为");
	}
	if (StrEqual(item, "tgspawn"))
	{
		int spawnMode = StringToInt(SubMenuVoteItems[client]);
		Format(sbuffer, sizeof(sbuffer), "%s", SpawnModeName[spawnMode >= 0 && spawnMode <= 4 ? spawnMode : 0]);
		Format(buffer, sizeof buffer, "刷特模式为");
	}

	int iClients[MAXPLAYERS + 1];
	int iCount = GetSurvivorVotePool(iClients);
	if (iCount < NCvar[Neko_VoteMinPlayers].IntValue)
	{
		PrintToChat(client, "\x05%s \x04投票池人数不足，至少需要 %d 名幸存者玩家", NEKOTAG, NCvar[Neko_VoteMinPlayers].IntValue);
		cleanplayerchar(client);
		return;
	}

	VoteSnapshotActive = true;
	VoteSnapshotValue = VoteMenuItemValue[client];
	NextVoteSnapshotToken++;
	if (NextVoteSnapshotToken <= 0)
		NextVoteSnapshotToken = 1;
	VoteSnapshotToken = NextVoteSnapshotToken;
	VoteSnapshotInitiatorUserId = GetClientUserId(client);
	VoteSnapshotPassPercent = NCvar[Neko_VotePassPercent].IntValue;
	strcopy(VoteSnapshotItem, sizeof(VoteSnapshotItem), item);
	strcopy(VoteSnapshotSubItem, sizeof(VoteSnapshotSubItem), SubMenuVoteItems[client]);

	L4D2NativeVote vote = L4D2NativeVote(VoteYesNoHandle);
	vote.Value = VoteSnapshotToken;
	vote.Initiator = client;
	vote.SetDisplayText("投票%s %s", buffer, sbuffer);

	if (!vote.DisplayVote(iClients, iCount, 15))
	{
		ClearVoteInitiatorState();
		LogError("%s 无法开始投票!", NEKOTAG);
	}
}

public void VoteYesNoHandle(L4D2NativeVote vote, VoteAction action, int param1, int param2)
{
	switch (action)
	{
		case VoteAction_Start:
		{
			PrintToChatAll("\x05%s \x03%N \x04开始了一轮新的投票", NEKOTAG, param1);
		}

		case VoteAction_PlayerVoted:
		{
			PrintToChatAll("\x05%s \x03%N \x04投了 \x03%s", NEKOTAG, param1, param2 == VOTE_YES ? "确定" : "否决");
		}

		case VoteAction_End:
		{
			if (!VoteSnapshotActive || !IsVoteItemEnabled(VoteSnapshotItem) || !IsVoteSubItemValid(VoteSnapshotItem, VoteSnapshotSubItem) || !VoteRangeIsValid(VoteSnapshotItem) || vote.PlayerCount <= 0)
			{
				ClearVoteInitiatorState(true);
				vote.SetFail();
				return;
			}
			int minValue, maxValue;
			char label[64];
			if (GetVoteRange(VoteSnapshotItem, minValue, maxValue, label, sizeof(label))
				&& (VoteSnapshotValue < minValue || VoteSnapshotValue > maxValue))
			{
				ClearVoteInitiatorState(true);
				vote.SetFail();
				return;
			}
			if (vote.YesCount >= GetVotePassCount(vote.PlayerCount, VoteSnapshotPassPercent))
			{
				// Keep a rollback snapshot. SetPass() sends an engine usermessage; if
				// the engine rejects it during a transition, the vote must not leave
				// a partially applied configuration behind.
				bool oldPluginStatus = GCvar[CSpecial_PluginStatus].BoolValue;
				bool oldRandomMode = GCvar[CSpecial_Random_Mode].BoolValue;
				bool oldTankAlive = GCvar[CSpecial_Spawn_Tank_Alive].BoolValue;
				int oldSpawnTime = GCvar[CSpecial_Spawn_Time].IntValue;
				int oldSpecialNum = GCvar[CSpecial_Num].IntValue;
				int oldAddNum = GCvar[CSpecial_AddNum].IntValue;
				int oldPlayerNum = GCvar[CSpecial_PlayerNum].IntValue;
				int oldPlayerAdd = GCvar[CSpecial_PlayerAdd].IntValue;
				int oldDefaultMode = GCvar[CSpecial_Default_Mode].IntValue;
				int oldSpawnMode = GCvar[CSpecial_Spawn_Mode].IntValue;
				bool oldPauseOnDown = GCvar[CSpecial_PauseOnDown].BoolValue;
				int oldDownCount = GCvar[CSpecial_DownCount].IntValue;

				char buffer[512], sbuffer[512], item[64];
				item = VoteSnapshotItem;
				if (StrEqual(item, "tgstat"))
				{
					Format(buffer, sizeof buffer, "多特插件");
					Format(sbuffer, sizeof sbuffer, "%s", !GCvar[CSpecial_PluginStatus].BoolValue ? "开启" : "关闭");
					GCvar[CSpecial_PluginStatus].SetBool(!GCvar[CSpecial_PluginStatus].BoolValue);
				}
				if (StrEqual(item, "tgrandom"))
				{
					Format(buffer, sizeof buffer, "随机特感");
					Format(sbuffer, sizeof sbuffer, "%s", !GCvar[CSpecial_Random_Mode].BoolValue ? "开启" : "关闭");
					GCvar[CSpecial_Random_Mode].SetBool(!GCvar[CSpecial_Random_Mode].BoolValue);
				}
				if (StrEqual(item, "tgtanklive"))
				{
					Format(buffer, sizeof buffer, "坦克存活时刷新特感");
					Format(sbuffer, sizeof sbuffer, "%s", !GCvar[CSpecial_Spawn_Tank_Alive].BoolValue ? "开启" : "关闭");
					GCvar[CSpecial_Spawn_Tank_Alive].SetBool(!GCvar[CSpecial_Spawn_Tank_Alive].BoolValue);
				}
				if (StrEqual(item, "tgdown"))
				{
					Format(buffer, sizeof buffer, "倒地暂停刷特");
					Format(sbuffer, sizeof sbuffer, "%s", !GCvar[CSpecial_PauseOnDown].BoolValue ? "开启" : "关闭");
					GCvar[CSpecial_PauseOnDown].SetBool(!GCvar[CSpecial_PauseOnDown].BoolValue);
				}
				if (StrEqual(item, "tgdowncount"))
				{
					Format(buffer, sizeof buffer, "倒地暂停人数为");
					Format(sbuffer, sizeof sbuffer, "%d 人", VoteSnapshotValue);
					GCvar[CSpecial_DownCount].SetInt(VoteSnapshotValue);
				}
				if (StrEqual(item, "tgtime"))
				{
					Format(buffer, sizeof buffer, "刷特时间为");
					Format(sbuffer, sizeof sbuffer, "%d s", VoteSnapshotValue);
					GCvar[CSpecial_Spawn_Time].SetInt(VoteSnapshotValue);
				}
				if (StrEqual(item, "tgnum"))
				{
					Format(buffer, sizeof buffer, "初始刷特数量为");
					Format(sbuffer, sizeof sbuffer, "%d 特", VoteSnapshotValue);
					GCvar[CSpecial_Num].SetInt(VoteSnapshotValue);
				}
				if (StrEqual(item, "tgadd"))
				{
					Format(buffer, sizeof buffer, "进人增加数量为");
					Format(sbuffer, sizeof sbuffer, "%d 特", VoteSnapshotValue);
					GCvar[CSpecial_AddNum].SetInt(VoteSnapshotValue);
				}
				if (StrEqual(item, "tgpnum"))
				{
					Format(buffer, sizeof buffer, "初始玩家数量为");
					Format(sbuffer, sizeof sbuffer, "%d 人", VoteSnapshotValue);
					GCvar[CSpecial_PlayerNum].SetInt(VoteSnapshotValue);
				}
				if (StrEqual(item, "tgpadd"))
				{
					Format(buffer, sizeof buffer, "玩家增加数量为");
					Format(sbuffer, sizeof sbuffer, "%d 人", VoteSnapshotValue);
					GCvar[CSpecial_PlayerAdd].SetInt(VoteSnapshotValue);
				}
				if (StrEqual(item, "tgmode"))
				{
					int mode = StringToInt(VoteSnapshotSubItem);
					Format(sbuffer, sizeof(sbuffer), "%s", SpecialName[mode >= 1 && mode <= 7 ? mode : 7]);
					Format(buffer, sizeof buffer, "游戏模式为");

					GCvar[CSpecial_Default_Mode].SetInt(StringToInt(VoteSnapshotSubItem));

					// Defer HUD/chat side effects until VotePass is accepted.
					if (oldRandomMode)
						GCvar[CSpecial_Random_Mode].SetBool(false);
				}
				if (StrEqual(item, "tgspawn"))
				{
					int spawnMode = StringToInt(VoteSnapshotSubItem);
					Format(sbuffer, sizeof(sbuffer), "%s", SpawnModeName[spawnMode >= 0 && spawnMode <= 4 ? spawnMode : 0]);
					Format(buffer, sizeof buffer, "刷特模式为");

					GCvar[CSpecial_Spawn_Mode].SetInt(StringToInt(VoteSnapshotSubItem));

				}

				int initiator = GetClientOfUserId(VoteSnapshotInitiatorUserId);
				if (IsValidClient(initiator))
					cleanplayerchar(initiator);

				// NativeVote keeps its controller occupied for the result window.
				// Retain the token until that window expires so config reload/map
				// cleanup can still cancel only this vote.
				if (!vote.SetPass("投票%s %s 通过!!!", buffer, sbuffer))
				{
					GCvar[CSpecial_PluginStatus].SetBool(oldPluginStatus);
					GCvar[CSpecial_Random_Mode].SetBool(oldRandomMode);
					GCvar[CSpecial_Spawn_Tank_Alive].SetBool(oldTankAlive);
					GCvar[CSpecial_Spawn_Time].SetInt(oldSpawnTime);
					GCvar[CSpecial_Num].SetInt(oldSpecialNum);
					GCvar[CSpecial_AddNum].SetInt(oldAddNum);
					GCvar[CSpecial_PlayerNum].SetInt(oldPlayerNum);
					GCvar[CSpecial_PlayerAdd].SetInt(oldPlayerAdd);
					GCvar[CSpecial_Default_Mode].SetInt(oldDefaultMode);
					GCvar[CSpecial_Spawn_Mode].SetInt(oldSpawnMode);
					GCvar[CSpecial_PauseOnDown].SetBool(oldPauseOnDown);
					GCvar[CSpecial_DownCount].SetInt(oldDownCount);
					ClearVoteInitiatorState();
					LogError("%s 投票通过消息发送失败，已回滚本轮设置", NEKOTAG);
					return;
				}
				ScheduleVoteSnapshotCleanup();

				// These notifications and HUD side effects must happen only after the
				// engine accepted VotePass. ConVars are rolled back on failure, but
				// chat/HUD output cannot be rolled back.
				if (StrEqual(item, "tgmode"))
				{
					if (GCvar[CSpecial_Show_Tips].BoolValue)
						NekoSpecials_ShowSpecialsModeTips();
					if (oldRandomMode)
						PrintToChatAll("\x05%s \x04关闭了随机特感", NEKOTAG);
				}
				else if (StrEqual(item, "tgspawn"))
				{
					PrintToChatAll("\x05%s \x04特感刷新方式更改为 \x03%s刷特模式", NEKOTAG, sbuffer);
				}

				if (IsValidClient(initiator))
					CreateTimer(0.2, Timer_ReloadMenu, GetClientUserId(initiator));
			}
			else
			{
				ClearVoteInitiatorState(true);
				vote.SetFail();
			}
		}
	}
}
