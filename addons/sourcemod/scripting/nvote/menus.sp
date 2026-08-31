public Menu NekoVoteMenu(int client)
{
	if (!IsValidClient(client))
		return null;

	N_MenuVoteMenu[client] = new Menu(VoteMenuHandler);
	char line[2048];
	int flags = NCvar[Neko_CanSwitch].BoolValue ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;
	if (GCvar[CSpecial_PluginStatus].BoolValue)
		Format(line, sizeof(line), "+|NS|+ 特感玩家菜单\n刷特进程[%s]\n特感数量[%d] 刷特时间[%d]", !GetSpecialRunning() ? "未开始" : "已开始", NekoSpecials_GetSpecialsNum(), NekoSpecials_GetSpecialsTime());
	else
		Format(line, sizeof(line), "+|NS|+ 特感玩家菜单\n插件已关闭");
	N_MenuVoteMenu[client].SetTitle(line);

	AddPlayerVoteItem(client, "tgstat", "插件目前状态 [%s]", GCvar[CSpecial_PluginStatus].BoolValue ? "开" : "关", flags);
	if (GCvar[CSpecial_PluginStatus].BoolValue)
	{
		if (GCvar[CSpecial_Spawn_Time_DifficultyChange].BoolValue)
			N_MenuVoteMenu[client].AddItem("tgtime", "全局刷特时间 [按难度变化]", ITEMDRAW_DISABLED);
		else
		{
			Format(line, sizeof(line), "全局刷特时间 [%ds]", GCvar[CSpecial_Spawn_Time].IntValue);
			N_MenuVoteMenu[client].AddItem("tgtime", line, IsVoteItemEnabled("tgtime") ? flags : ITEMDRAW_DISABLED);
		}
		Format(line, sizeof(line), "初始刷特数量 [%d]", GCvar[CSpecial_Num].IntValue);
		N_MenuVoteMenu[client].AddItem("tgnum", line, IsVoteItemEnabled("tgnum") ? flags : ITEMDRAW_DISABLED);
		Format(line, sizeof(line), "进人增加数量 [%d]", GCvar[CSpecial_AddNum].IntValue);
		N_MenuVoteMenu[client].AddItem("tgadd", line, IsVoteItemEnabled("tgadd") ? flags : ITEMDRAW_DISABLED);
		Format(line, sizeof(line), "初始玩家数量 [%d]", GCvar[CSpecial_PlayerNum].IntValue);
		N_MenuVoteMenu[client].AddItem("tgpnum", line, IsVoteItemEnabled("tgpnum") ? flags : ITEMDRAW_DISABLED);
		Format(line, sizeof(line), "玩家增加间隔 [%d]", GCvar[CSpecial_PlayerAdd].IntValue);
		N_MenuVoteMenu[client].AddItem("tgpadd", line, IsVoteItemEnabled("tgpadd") ? flags : ITEMDRAW_DISABLED);
		Format(line, sizeof(line), "坦克存活时刷新 [%s]", GCvar[CSpecial_Spawn_Tank_Alive].BoolValue ? "是" : "否");
		N_MenuVoteMenu[client].AddItem("tgtanklive", line, IsVoteItemEnabled("tgtanklive") ? flags : ITEMDRAW_DISABLED);
		Format(line, sizeof(line), "倒地暂停刷特 [%s]", GCvar[CSpecial_PauseOnDown].BoolValue ? "是" : "否");
		N_MenuVoteMenu[client].AddItem("tgdown", line, IsVoteItemEnabled("tgdown") ? flags : ITEMDRAW_DISABLED);
		Format(line, sizeof(line), "倒地暂停人数 [%d]", GCvar[CSpecial_DownCount].IntValue);
		N_MenuVoteMenu[client].AddItem("tgdowncount", line, IsVoteItemEnabled("tgdowncount") ? flags : ITEMDRAW_DISABLED);
		int mode = GCvar[CSpecial_Default_Mode].IntValue;
		Format(line, sizeof(line), "特感游戏模式 [%s]", SpecialName[mode >= 1 && mode <= 7 ? mode : 7]);
		N_MenuVoteMenu[client].AddItem("tgmode", line, IsVoteItemEnabled("tgmode") ? flags : ITEMDRAW_DISABLED);
		int spawnMode = GetSpecialSpawnMode();
		Format(line, sizeof(line), "特感刷新模式 [%s]", SpawnModeName[spawnMode >= 0 && spawnMode <= 4 ? spawnMode : 0]);
		N_MenuVoteMenu[client].AddItem("tgspawn", line, IsVoteItemEnabled("tgspawn") ? flags : ITEMDRAW_DISABLED);
		Format(line, sizeof(line), "随机特感状态 [%s]", GCvar[CSpecial_Random_Mode].BoolValue ? "开" : "关");
		N_MenuVoteMenu[client].AddItem("tgrandom", line, IsVoteItemEnabled("tgrandom") ? flags : ITEMDRAW_DISABLED);
	}
	N_MenuVoteMenu[client].ExitBackButton = true;
	return N_MenuVoteMenu[client];
}

void AddPlayerVoteItem(int client, const char[] item, const char[] format, const char[] state, int flags)
{
	char line[256];
	Format(line, sizeof(line), format, state);
	N_MenuVoteMenu[client].AddItem(item, line, IsVoteItemEnabled(item) ? flags : ITEMDRAW_DISABLED);
}

public int VoteMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select && IsValidClient(client))
	{
		char item[64];
		menu.GetItem(selection, item, sizeof(item));
		MenuPageItem[client] = GetMenuSelectionPosition();
		N_MenuVoteMenu[client] = null;
		if (!IsVoteItemEnabled(item))
		{
			PrintToChat(client, "\x05%s \x04该投票项目当前已关闭", NEKOTAG);
			return 0;
		}
		if (!L4D2NativeVote_IsAllowNewVote())
		{
			PrintToChat(client, "\x05%s \x04暂时不能开启新的投票", NEKOTAG);
			return 0;
		}
		cleanplayerwait(client);
		if (StrEqual(item, "tgstat") || StrEqual(item, "tgrandom") || StrEqual(item, "tgtanklive") || StrEqual(item, "tgdown"))
		{
			VoteMenuItems[client] = item;
			StartVoteYesNo(client);
		}
		else if (StrEqual(item, "tgmode"))
			SpecialMenuMode(client);
		else if (StrEqual(item, "tgspawn"))
			SpecialMenuSpawn(client);
		else
		{
			int minValue, maxValue;
			char label[64];
			if (GetVoteRange(item, minValue, maxValue, label, sizeof(label)))
			{
				if (minValue > maxValue)
				{
					PrintToChat(client, "\x05%s \x04该投票的后台范围设置无效，请联系管理员", NEKOTAG);
					return 0;
				}
				PrintToChat(client, "\x05%s \x04请在聊天栏输入%s，范围[%d - %d]；输入 !cancel 取消", NEKOTAG, label, minValue, maxValue);
				WaitForVoteItems[client] = item;
				BoolWaitForVoteItems[client] = true;
			}
		}
	}
	else if (action == MenuAction_End)
		delete menu;
	return 0;
}

public Action SpecialMenuMode(int client)
{
	Menu menu = new Menu(SpecialMenuModeHandler);
	menu.SetTitle("+|NS|+ 选择特感模式\n选择一个模式");
	menu.AddItem("7", "默认模式");
	menu.AddItem("1", "牛子模式");
	menu.AddItem("2", "胖子模式");
	menu.AddItem("3", "口水模式");
	menu.AddItem("4", "舌头模式");
	menu.AddItem("5", "猴子模式");
	menu.AddItem("6", "猎人模式");
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME);
	return Plugin_Handled;
}

public int SpecialMenuModeHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char item[16];
				menu.GetItem(selection, item, sizeof(item));
				SubMenuVoteItems[client] = item;
				VoteMenuItems[client] = "tgmode";
				StartVoteYesNo(client);
			}
		}
		case MenuAction_Cancel:
		{
			if (IsValidClient(client) && selection == MenuCancel_ExitBack)
				NekoVoteMenu(client).DisplayAt(client, MenuPageItem[client], MENU_TIME);
		}
		case MenuAction_End:
			delete menu;
	}
	return 0;
}

public Action SpecialMenuSpawn(int client)
{
	Menu menu = new Menu(SpecialMenuSpawnHandler);
	menu.SetTitle("+|NS|+ 选择刷特模式\n选择一个模式");
	menu.AddItem("0", "导演刷特");
	menu.AddItem("1", "普通刷特");
	menu.AddItem("2", "噩梦刷特");
	menu.AddItem("3", "地狱刷特");
	menu.AddItem("4", "可变刷特");
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME);
	return Plugin_Handled;
}

public int SpecialMenuSpawnHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char item[16];
				menu.GetItem(selection, item, sizeof(item));
				SubMenuVoteItems[client] = item;
				VoteMenuItems[client] = "tgspawn";
				StartVoteYesNo(client);
			}
		}
		case MenuAction_Cancel:
		{
			if (IsValidClient(client) && selection == MenuCancel_ExitBack)
				NekoVoteMenu(client).DisplayAt(client, MenuPageItem[client], MENU_TIME);
		}
		case MenuAction_End:
			delete menu;
	}
	return 0;
}
