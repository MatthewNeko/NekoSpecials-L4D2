stock bool IsVoteAdmin(int client)
{
	return IsValidClient(client) && (GetUserFlagBits(client) & ADMFLAG_ROOT) != 0;
}
public Menu NekoVoteAdminMenu(int client)
{
	if (!IsVoteAdmin(client))
		return null;

	N_MenuAdminMenu[client] = new Menu(AdminMenuHandler);
	char line[256];
	Format(line, sizeof(line), "+|NS|+ 投票管理菜单\n实时设置，修改后立即保存");
	N_MenuAdminMenu[client].SetTitle(line);

	Format(line, sizeof(line), "全局投票开关 [%s]", NCvar[Neko_CanSwitch].BoolValue ? "开" : "关");
	N_MenuAdminMenu[client].AddItem("swplu", line);
	N_MenuAdminMenu[client].AddItem("switches", "投票项目独立开关");
	N_MenuAdminMenu[client].AddItem("ranges", "数值投票范围设置");
	N_MenuAdminMenu[client].AddItem("rules", "投票规则设置");
	N_MenuAdminMenu[client].AddItem("maintenance", "配置维护");
	Format(line, sizeof(line), "版本 %s", PLUGIN_VERSION);
	N_MenuAdminMenu[client].AddItem("info", line, ITEMDRAW_DISABLED);
	N_MenuAdminMenu[client].ExitBackButton = true;
	return N_MenuAdminMenu[client];
}

public Menu NekoVoteSwitchMenu(int client)
{
	if (!IsVoteAdmin(client))
		return null;

	Menu menu = new Menu(AdminSwitchMenuHandler);
	menu.SetTitle("+|NS|+ 投票项目独立开关");
	AddSwitchItem(menu, "swstat", "插件状态", Neko_SwitchStatus);
	AddSwitchItem(menu, "swtime", "刷特时间", Neko_SwitchTime);
	AddSwitchItem(menu, "swnum", "初始刷特数量", Neko_SwitchNumber);
	AddSwitchItem(menu, "swadd", "进人增加特感数", Neko_SwitchNumAdd);
	AddSwitchItem(menu, "swpnum", "初始玩家数量", Neko_SwitchPlayerJoin);
	AddSwitchItem(menu, "swpadd", "玩家增加间隔", Neko_SwitchPlayerAdd);
	AddSwitchItem(menu, "swtank", "坦克存活刷特", Neko_SwitchTankAlive);
	AddSwitchItem(menu, "swdown", "倒地暂停刷特", Neko_SwitchPauseOnDown);
	AddSwitchItem(menu, "swdowncount", "倒地人数投票", Neko_SwitchDownCount);
	AddSwitchItem(menu, "swgm", "特感游戏模式", Neko_SwitchGameMode);
	AddSwitchItem(menu, "swsm", "特感刷新模式", Neko_SwitchSpawnMode);
	AddSwitchItem(menu, "swrandom", "随机特感", Neko_SwitchRandom);
	menu.ExitBackButton = true;
	return menu;
}

void AddSwitchItem(Menu menu, const char[] id, const char[] name, int cvarIndex)
{
	char line[128];
	Format(line, sizeof(line), "%s [%s]", name, NCvar[cvarIndex].BoolValue ? "开" : "关");
	menu.AddItem(id, line);
}

public Menu NekoVoteRangeMenu(int client)
{
	if (!IsVoteAdmin(client))
		return null;

	Menu menu = new Menu(AdminRangeMenuHandler);
	menu.SetTitle("+|NS|+ 数值投票范围\n选择要修改的边界");
	AddRangeItems(menu, "tgtime", "刷特时间", Neko_TimeMin, Neko_TimeMax);
	AddRangeItems(menu, "tgnum", "初始刷特数量", Neko_NumMin, Neko_NumMax);
	AddRangeItems(menu, "tgadd", "进人增加特感数", Neko_AddMin, Neko_AddMax);
	AddRangeItems(menu, "tgpnum", "初始玩家数量", Neko_PlayerNumMin, Neko_PlayerNumMax);
	AddRangeItems(menu, "tgpadd", "玩家增加间隔", Neko_PlayerAddMin, Neko_PlayerAddMax);
	AddRangeItems(menu, "tgdowncount", "倒地暂停人数", Neko_DownCountMin, Neko_DownCountMax);
	menu.ExitBackButton = true;
	return menu;
}

void AddRangeItems(Menu menu, const char[] item, const char[] name, int minIndex, int maxIndex)
{
	char id[64], line[192];
	Format(id, sizeof(id), "%s_min", item);
	Format(line, sizeof(line), "%s 最小值 [%d]", name, NCvar[minIndex].IntValue);
	menu.AddItem(id, line);
	Format(id, sizeof(id), "%s_max", item);
	Format(line, sizeof(line), "%s 最大值 [%d]", name, NCvar[maxIndex].IntValue);
	menu.AddItem(id, line);
}

public Menu NekoVoteRuleMenu(int client)
{
	if (!IsVoteAdmin(client))
		return null;

	Menu menu = new Menu(AdminRuleMenuHandler);
	menu.SetTitle("+|NS|+ 投票规则设置\n按投票池人数计算");
	char line[192];
	Format(line, sizeof(line), "通过率 [%d%%]", NCvar[Neko_VotePassPercent].IntValue);
	menu.AddItem("pass", line);
	Format(line, sizeof(line), "最低投票池人数 [%d]", NCvar[Neko_VoteMinPlayers].IntValue);
	menu.AddItem("players", line);
	menu.ExitBackButton = true;
	return menu;
}

public Menu NekoVoteMaintenanceMenu(int client)
{
	if (!IsVoteAdmin(client))
		return null;

	Menu menu = new Menu(AdminMaintenanceMenuHandler);
	menu.SetTitle("+|NS|+ 配置维护");
	char line[192];
	Format(line, sizeof(line), "无人自动重置 [%s]", NCvar[Neko_NeedResetNoPlayer].BoolValue ? "开" : "关");
	menu.AddItem("swtreload", line);
	Format(line, sizeof(line), "无人重置延迟 [%d 秒]", NCvar[Neko_NeedResetTime].IntValue);
	menu.AddItem("reset_time", line);
	menu.AddItem("reload", "从配置文件重载");
	menu.AddItem("write", "立即写入配置文件");
	menu.AddItem("reset", "恢复配置默认值");
	menu.ExitBackButton = true;
	return menu;
}

void BeginAdminEdit(int client, const char[] item, const char[] prompt)
{
	BoolWaitForAdminItems[client] = true;
	strcopy(AdminEditItems[client], sizeof(AdminEditItems[]), item);
	PrintToChat(client, "\x05%s \x04%s，输入整数；输入 !cancel 取消", NEKOTAG, prompt);
}

public int AdminMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select && IsVoteAdmin(client))
	{
		char item[64];
		menu.GetItem(selection, item, sizeof(item));
		if (StrEqual(item, "swplu"))
		{
			ClearVoteInteractionState();
			NCvar[Neko_CanSwitch].SetBool(!NCvar[Neko_CanSwitch].BoolValue);
			SaveVoteConfig();
			CreateTimer(0.1, Timer_ReloadAdminMenu, GetClientUserId(client));
		}
		else if (StrEqual(item, "switches"))
			NekoVoteSwitchMenu(client).Display(client, MENU_TIME);
		else if (StrEqual(item, "ranges"))
			NekoVoteRangeMenu(client).Display(client, MENU_TIME);
		else if (StrEqual(item, "rules"))
			NekoVoteRuleMenu(client).Display(client, MENU_TIME);
		else if (StrEqual(item, "maintenance"))
			NekoVoteMaintenanceMenu(client).Display(client, MENU_TIME);
	}
	else if (action == MenuAction_Cancel && IsVoteAdmin(client) && selection == MenuCancel_ExitBack)
		return 0;
	else if (action == MenuAction_End)
		delete menu;
	return 0;
}

public int AdminSwitchMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select && IsVoteAdmin(client))
	{
		char item[64];
		menu.GetItem(selection, item, sizeof(item));
		int index = -1;
		if (StrEqual(item, "swstat")) index = Neko_SwitchStatus;
		else if (StrEqual(item, "swtime")) index = Neko_SwitchTime;
		else if (StrEqual(item, "swnum")) index = Neko_SwitchNumber;
		else if (StrEqual(item, "swadd")) index = Neko_SwitchNumAdd;
		else if (StrEqual(item, "swpnum")) index = Neko_SwitchPlayerJoin;
		else if (StrEqual(item, "swpadd")) index = Neko_SwitchPlayerAdd;
		else if (StrEqual(item, "swtank")) index = Neko_SwitchTankAlive;
		else if (StrEqual(item, "swdown")) index = Neko_SwitchPauseOnDown;
		else if (StrEqual(item, "swdowncount")) index = Neko_SwitchDownCount;
		else if (StrEqual(item, "swgm")) index = Neko_SwitchGameMode;
		else if (StrEqual(item, "swsm")) index = Neko_SwitchSpawnMode;
		else if (StrEqual(item, "swrandom")) index = Neko_SwitchRandom;
		if (index != -1)
		{
			ClearVoteInteractionState();
			NCvar[index].SetBool(!NCvar[index].BoolValue);
			SaveVoteConfig();
		}
		NekoVoteSwitchMenu(client).Display(client, MENU_TIME);
	}
	else if (action == MenuAction_Cancel && IsVoteAdmin(client) && selection == MenuCancel_ExitBack)
		NekoVoteAdminMenu(client).Display(client, MENU_TIME);
	else if (action == MenuAction_End)
		delete menu;
	return 0;
}

public int AdminRangeMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select && IsVoteAdmin(client))
	{
		char item[64];
		menu.GetItem(selection, item, sizeof(item));
		strcopy(AdminRangeItems[client], sizeof(AdminRangeItems[]), item);
		BeginAdminEdit(client, item, "请输入新的范围值");
	}
	else if (action == MenuAction_Cancel && IsVoteAdmin(client) && selection == MenuCancel_ExitBack)
		NekoVoteAdminMenu(client).Display(client, MENU_TIME);
	else if (action == MenuAction_End)
		delete menu;
	return 0;
}

public int AdminRuleMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select && IsVoteAdmin(client))
	{
		char item[32];
		menu.GetItem(selection, item, sizeof(item));
		BeginAdminEdit(client, item, StrEqual(item, "pass") ? "请输入通过率百分比" : "请输入最低投票池人数");
	}
	else if (action == MenuAction_Cancel && IsVoteAdmin(client) && selection == MenuCancel_ExitBack)
		NekoVoteAdminMenu(client).Display(client, MENU_TIME);
	else if (action == MenuAction_End)
		delete menu;
	return 0;
}

public int AdminMaintenanceMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select && IsVoteAdmin(client))
	{
		char item[32];
		menu.GetItem(selection, item, sizeof(item));
		if (StrEqual(item, "swtreload"))
		{
			NCvar[Neko_NeedResetNoPlayer].SetBool(!NCvar[Neko_NeedResetNoPlayer].BoolValue);
			SaveVoteConfig();
			NekoVoteMaintenanceMenu(client).Display(client, MENU_TIME);
		}
		else if (StrEqual(item, "reset_time"))
			BeginAdminEdit(client, "reset_time", "请输入无人重置延迟秒数");
		else if (StrEqual(item, "reload"))
		{
			// exec is queued by SourceMod; invalidate pending interaction and
			// vote state before the new values become visible.
			ClearVoteInteractionState();
			AutoExecConfig_OnceExec();
			CreateTimer(0.1, Timer_ReloadAdminMenu, GetClientUserId(client));
		}
		else if (StrEqual(item, "write"))
		{
			SaveVoteConfig();
			NekoVoteAdminMenu(client).Display(client, MENU_TIME);
		}
		else if (StrEqual(item, "reset"))
		{
			UpdateConfigFile(true);
			CreateTimer(0.1, Timer_ReloadAdminMenu, GetClientUserId(client));
		}
	}
	else if (action == MenuAction_Cancel && IsVoteAdmin(client) && selection == MenuCancel_ExitBack)
		NekoVoteAdminMenu(client).Display(client, MENU_TIME);
	else if (action == MenuAction_End)
		delete menu;
	return 0;
}
