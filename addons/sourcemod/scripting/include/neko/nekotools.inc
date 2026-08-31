#if defined _neko_included
	#endinput
#endif
#define _neko_included

#include <sdktools>

// Neko Specials Inc 实用库

// Global variables
static char	  g_sConfigFile[PLATFORM_MAX_PATH];
static char	  g_sRawFileName[PLATFORM_MAX_PATH];
static char	  g_sFolderPath[PLATFORM_MAX_PATH];
static int	  g_iLastFindResult;
static int	  g_iLastAppendResult;
static bool	  g_bCreateFile	  = true;
static Handle g_hPluginHandle = null;

// Maptime
static float  MapStartTime;

// Append
#define AUTOEXEC_APPEND_BAD_FILENAME   0
#define AUTOEXEC_APPEND_FILE_NOT_FOUND 1
#define AUTOEXEC_APPEND_BAD_HANDLE	   2
#define AUTOEXEC_APPEND_SUCCESS		   3

// Find
#define AUTOEXEC_FIND_BAD_FILENAME	   10
#define AUTOEXEC_FIND_FILE_NOT_FOUND   11
#define AUTOEXEC_FIND_BAD_HANDLE	   12
#define AUTOEXEC_FIND_NOT_FOUND		   13
#define AUTOEXEC_FIND_SUCCESS		   14

// Clean
#define AUTOEXEC_CLEAN_FILE_NOT_FOUND  20
#define AUTOEXEC_CLEAN_BAD_HANDLE	   21
#define AUTOEXEC_CLEAN_SUCCESS		   22

// General
#define AUTOEXEC_NO_CONFIG			   30

// Formatter
#define AUTOEXEC_FORMAT_BAD_FILENAME   40
#define AUTOEXEC_FORMAT_SUCCESS		   41

#define AUTOEXEC_EXEC_SUCCESS		   50

#define NEKOTAG						   "[NS]"

stock char SpecialName[8][50]	 = { "NULL", "牛子", "胖子", "口水", "舌头", "猴子", "猎人", "默认" };

stock char SpawnModeName[5][50]	 = { "导演", "普通", "噩梦", "地狱", "可变" };

stock char GameDifficulty[4][50] = { "简单", "普通", "困难", "专家" };

stock char HudStyleName[5][50]	 = { "关闭中", "样式1", "样式2", "自定义", "聊天栏" };

// Core.Inc

stock void CreateConfigFire(char[] CorePath)
{
	Handle WriteConfig = OpenFile(CorePath, "w");
	if (WriteConfig == INVALID_HANDLE)
		SetFailState("%s 自定义配置文件创建失败: %s", NEKOTAG, CorePath);

	WriteFileLine(WriteConfig, "\"Settings\"");
	WriteFileLine(WriteConfig, "{");
	WriteFileLine(WriteConfig, "	\"KillHud_KillTankTitle\"			\"本次对Tank伤害\"");
	WriteFileLine(WriteConfig, "	\"KillHud_KillSpecialsTitle\"		\"击杀排行\"");
	WriteFileLine(WriteConfig, "	\"KillHud_FriendlyFireTitle\"		\"黑枪排行\"");
	WriteFileLine(WriteConfig, "	\"ServerNameFormat\"			\"XX多特{servernum}服[{specials}特{times}秒][重启:{restartcount}|路程:{flow}]{maptime}\"");
	WriteFileLine(WriteConfig, "}");

	WriteFileLine(WriteConfig, "//以下为自定义服务器名字能加入的参数，根据个人选择加入");
	WriteFileLine(WriteConfig, "//{servernum} 			服务器数字 服务器端口后缀 27015 的 15 就是你的服务器数字");
	WriteFileLine(WriteConfig, "//{specials} 			目前多特数量，需要搭配Neko多特插件");
	WriteFileLine(WriteConfig, "//{times} 				目前多特刷新时间，需要搭配Neko多特插件");
	WriteFileLine(WriteConfig, "//{spawnmode} 			目前多特刷特模式，需要搭配Neko多特插件");
	WriteFileLine(WriteConfig, "//{specialsmode} 		目前多特特感模式，需要搭配Neko多特插件");
	WriteFileLine(WriteConfig, "//{gamedifficulty} 		游戏难度");
	WriteFileLine(WriteConfig, "//{restartcount} 		失败重启次数");
	WriteFileLine(WriteConfig, "//{flow} 				当前玩家的路程");
	WriteFileLine(WriteConfig, "//{maptime}				目前地图时间，自带格式，例如[计时:2m:10s]");
	WriteFileLine(WriteConfig, "//{realplayernum}		服务器在线真人人数，不包括特感");
	WriteFileLine(WriteConfig, "//{playernum}			服务器在线人数含BOT，不包括特感");
	WriteFileLine(WriteConfig, "//{realaliveplayernum}	服务器在线且存活真人人数，不包括特感");
	WriteFileLine(WriteConfig, "//{aliveplayernum}		服务器存活真人人数，不包括特感");
	WriteFileLine(WriteConfig, "//{customtext}			ServerName_CustomText这个Convar的内容");

	delete WriteConfig;
}

// Time.Inc

/**
 * Create a StartTime.
 * This function must be set in OnMapStart().
 * @noreturn
 */
stock void StartCatchTime()
{
	MapStartTime = GetEngineTime();
}

/**
 * Get a NowTime.
 * This function will return the time.
 * @noreturn
 */
stock int GetNowTime()
{
	return RoundToZero(GetEngineTime() - MapStartTime);
}

/**
 * Format NowTime.
 * This function will return the time Format.
 */
stock char[] GetNowTime_Format()
{
	int	 MapTime	   = GetNowTime();
	int	 HoursPassed   = MapTime / 60 / 60;
	int	 MinutesPassed = MapTime / 60;
	int	 SecondsPassed = MapTime % 60;

	char Hours[32], Minutes[32], Seconds[32];
	if (HoursPassed < 10)
		Format(Hours, sizeof(Hours), "0%d", HoursPassed);
	else
		Format(Hours, sizeof(Hours), "%d", HoursPassed);
	if (MinutesPassed < 10)
		Format(Minutes, sizeof(Minutes), "0%d", MinutesPassed);
	else
		Format(Minutes, sizeof(Minutes), "%d", MinutesPassed);
	if (SecondsPassed < 10)
		Format(Seconds, sizeof(Seconds), "0%d", SecondsPassed);
	else
		Format(Seconds, sizeof(Seconds), "%d", SecondsPassed);

	char Retime[128];
	Format(Retime, sizeof(Retime), "%s:%s:%s", Hours, Minutes, Seconds);
	return Retime;
}

/**
 * Returns NowTime Hours.
 * This function will return the time.
 */
stock char[] GetNowTime_Hours()
{
	int	 HoursPassed = GetNowTime() / 60 / 60;

	char Hours[32];

	if (HoursPassed < 10)
		Format(Hours, sizeof(Hours), "0%d", HoursPassed);
	else
		Format(Hours, sizeof(Hours), "%d", HoursPassed);

	return Hours;
}

/**
 * Returns NowTime Minutes.
 * This function will return the time.
 */
stock char[] GetNowTime_Minutes()
{
	int	 MinutesPassed = GetNowTime() / 60;

	char Minutes[32];

	if (MinutesPassed < 10)
		Format(Minutes, sizeof(Minutes), "0%d", MinutesPassed);
	else
		Format(Minutes, sizeof(Minutes), "%d", MinutesPassed);

	return Minutes;
}

/**
 * Returns NowTime Seconds.
 * This function will return the time.
 */
stock char[] GetNowTime_Seconds()
{
	int	 SecondsPassed = GetNowTime() % 60;

	char Seconds[32];

	if (SecondsPassed < 10)
		Format(Seconds, sizeof(Seconds), "0%d", SecondsPassed);
	else
		Format(Seconds, sizeof(Seconds), "%d", SecondsPassed);

	return Seconds;
}

// MainLib.Inc
/**
 * Returns Difficulty number.
 *
 * @return				0-3.
 */
stock int GameDifficultyNum()
{
	char NowDifficulty[64];
	FindConVar("z_difficulty").GetString(NowDifficulty, sizeof(NowDifficulty));

	if (strcmp(NowDifficulty, "Easy") == 0)
		return 0;
	else if (strcmp(NowDifficulty, "Normal") == 0)
		return 1;
	else if (strcmp(NowDifficulty, "Hard") == 0)
		return 2;
	else if (strcmp(NowDifficulty, "Impossible") == 0)
		return 3;

	return 0;
}

/**
 * Returns if a certain Client is Vaild.
 *
 * @param client		Client index.
 * @return				True if player is vaild in the server, false otherwise.
 */
stock bool IsValidClient(int client)
{
	if (client < 1 || client > MaxClients)
		return false;
	if (!IsClientConnected(client) || !IsClientInGame(client))
		return false;
	return true;
}

/**
 * Returns if a certain Client is a Vaild Survivor.
 *
 * @param client		Client index.
 * @return				True if player is a vaild survivor in the server, false otherwise.
 */
stock bool IsValidSurvivor(int client)
{
	return IsValidClient(client) && GetClientTeam(client) == 2;
}

/**
 * Returns if a certain Client is admin.
 *
 * @param client		Client index.
 * @return				True if player is admin in the server, false otherwise.
 */
stock bool IsClientAdmin(int client)
{
	if (!IsValidClient(client))
		return false;

	if (CheckCommandAccess(client, "owner", ADMFLAG_ROOT))
		return true;
	else if (CheckCommandAccess(client, "headadmin", ADMFLAG_CHEATS))
		return true;
	else if (CheckCommandAccess(client, "admin", ADMFLAG_GENERIC))
		return true;
	else
		return false;
}

/**
 * Returns if a certain Client is Vaild Bot.
 *
 * @param client		Client index.
 * @return				True if player is vaild bot in the server, false otherwise.
 */
stock bool IsClientBot(int client)
{
	if (client > 0)
		if (IsClientConnected(client))
			if (IsFakeClient(client))
				if (!IsClientInGame(client))
					return true;
	return false;
}

/**
 * Returns if a bot has client is Idle.
 *
 * @param bot			Client index.
 * @return				True if bot has Idle client in the server, false otherwise.
 */
stock bool HasIdlePlayer(int bot)
{
	int userid = GetEntData(bot, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID"));
	int client = GetClientOfUserId(userid);

	if (client)
	{
		if (IsClientInGame(client) && !IsFakeClient(client) && (GetClientTeam(client) == 1))
			return true;
	}
	return false;
}

/**
 * Returns if a client is Idle.
 *
 * @param client		Client index.
 * @return				True if client Idle in the server, false otherwise.
 */
stock bool IsClientIdle(int client)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientConnected(i))
			continue;
		if (!IsClientInGame(i))
			continue;
		if (GetClientTeam(i) == 1)
			continue;
		if (!IsFakeClient(i))
			continue;
		if (!HasIdlePlayer(i))
			continue;

		int spectator_userid = GetEntData(i, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID"));
		int spectator_client = GetClientOfUserId(spectator_userid);

		if (spectator_client == client)
			return true;
	}
	return false;
}

/**
 * Returns if a Bot be Allow.
 *
 * @param client		Client index.
 * @param AllowBot		False to Start the client is bot.
 * @return				True if Bot be Allow in the server, false otherwise.
 */
stock bool IsAllowBot(int client, bool AllowBot)
{
	if (!AllowBot)
	{
		if (IsFakeClient(client))
			return false;
		else
			return true;
	}
	return true;
}

/**
 * Returns if a client is the specials type.
 *
 * @param client		Client index.
 * @param type			Specials type num.
 * @return				True if client is this type, false otherwise.
 */
stock bool IsInfected(int client, int type)
{
	int class = GetEntProp(client, Prop_Send, "m_zombieClass");
	if (type == class)
		return true;
	return false;
}

/**
 * Returns if a client is a tank.
 *
 * @param client		Client index.
 * @return				True if client is tank, false otherwise.
 */
stock bool IsPlayerTank(int client)
{
	if (IsValidClient(client) && GetClientTeam(client) == 3)
		if (GetEntProp(client, Prop_Send, "m_zombieClass") == 8)
			return true;

	return false;
}

/**
 * Returns if >2 specials is alive.
 *
 * @return				True if >2 specials is alive, false otherwise.
 */
stock bool IsMoreSpecialsAlive()
{
	int num = 0;
	for (int i = 0; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 3 || IsPlayerTank(i))
			continue;
		num++;
	}
	if (num > 2)
		return true;
	return false;
}

/**
 * Returns if any tank is alive.
 *
 * @return				True if any tank is alive, false otherwise.
 */
stock bool IsTankLive()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;

		if (GetClientTeam(i) == 3)
			if (IsPlayerTank(i) && IsPlayerAlive(i))
				return true;
	}
	return false;
}

/**
 * Returns if tank is Incapacitated.
 *
 * @param client		Client index.
 * @return				True if tank is Incapacitated, false otherwise.
 */
stock bool IsTankIncapacitated(int client)
{
	if (IsClientIncapacitated(client) || GetClientHealth(client) < 1)
		return true;
	return false;
}

/**
 * Returns if client is Incapacitated.
 *
 * @param client		Client index.
 * @return				True if client is Incapacitated, false otherwise.
 */
stock bool IsClientIncapacitated(int client)
{
	return !!GetEntProp(client, Prop_Send, "m_isIncapacitated");
}

/**
 * Returns if string is Integer.
 *
 * @param buffer		string buffer.
 * @return				True if string is Integer, false otherwise.
 */
stock bool IsInteger(char[] buffer)
{
	int len = strlen(buffer);
	for (int i = 0; i < len; i++)
		if (!IsCharNumeric(buffer[i]))
			return false;
	return true;
}

/**
 * Returns Player Num.
 *
 * @param connecting	bool Count the number of connecting people.
 * @return				Players Num.
 */
stock int GetPlayers(bool connecting)
{
	int players;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (connecting && IsClientConnected(i) && !IsClientInGame(i) && GetClientTeam(i) == 2) players++;
		else if (!connecting && IsValidClient(i) && GetClientTeam(i) == 2) players++;
	}
	return players;
}

/**
 * Returns Real Player Num.
 *
 * @param connecting	bool Count the number of connecting people.
 * @return				Players Num.
 */
stock int GetRealPlayers(bool connecting)
{
	int players;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (connecting && IsClientConnected(i) && !IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == 2) players++;
		else if (!connecting && IsValidClient(i) && !IsFakeClient(i) && GetClientTeam(i) == 2) players++;
	}
	return players;
}

/**
 * Returns Alive Player Num.
 *
 * @param connecting	bool Count the number of connecting people.
 * @return				Players Num.
 */
stock int GetAlivePlayers(bool connecting)
{
	int players;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (connecting && IsClientConnected(i) && !IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2) players++;
		else if (!connecting && IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2) players++;
	}
	return players;
}

/**
 * Returns Real&Alive Player Num.
 *
 * @param connecting	bool Count the number of connecting people.
 * @return				Players Num.
 */
stock int GetRealAlivePlayers(bool connecting)
{
	int players;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (connecting && IsClientConnected(i) && !IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2) players++;
		else if (!connecting && IsValidClient(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2) players++;
	}
	return players;
}

/**
 * Returns Server IP.
 *
 * @return				Server IP.
 */
stock char[] GetServerIP()
{
	char NetIP[32];
	int	 pieces[4];
	int	 longip = FindConVar("hostip").IntValue;

	pieces[0]	= (longip >> 24) & 0x000000FF;
	pieces[1]	= (longip >> 16) & 0x000000FF;
	pieces[2]	= (longip >> 8) & 0x000000FF;
	pieces[3]	= longip & 0x000000FF;

	Format(NetIP, sizeof(NetIP), "%d.%d.%d.%d:%d", pieces[0], pieces[1], pieces[2], pieces[3], FindConVar("hostport").IntValue);
	return NetIP;
}

/**
 * Returns Format time.
 *
 * @param time			Int Time.
 * @return				Format time. ex 00:00:00.
 */
stock char[] FormatShortTime(int time)
{
	char Time[12];
	int	 g_iHours	= 0;
	int	 g_iMinutes = 0;
	int	 g_iSeconds = time;

	while (g_iSeconds > 3600)
	{
		g_iHours++;
		g_iSeconds -= 3600;
	}
	while (g_iSeconds > 60)
	{
		g_iMinutes++;
		g_iSeconds -= 60;
	}
	if (g_iHours >= 1) Format(Time, sizeof(Time), "%d:%d:%d", g_iHours, g_iMinutes, g_iSeconds);
	else if (g_iMinutes >= 1) Format(Time, sizeof(Time), "  %d:%d", g_iMinutes, g_iSeconds);
	else Format(Time, sizeof(Time), "   %d", g_iSeconds);
	return Time;
}

/**
 * Returns how many times the given char occures in the given string.
 *
 * @param str		String to search for in.
 * @return			Occurences of the given char found in string.
 */
stock static int GetCharCountInStr(int character, const char[] str)
{
	int len = strlen(str);
	int count;

	for (int i; i < len; i++)
		if (str[i] == character)
			count++;

	return count;
}

/**
 * Runs a single line of VScript code.
 * NOTE: Dont use the "script" console command, it starts a new instance and leaks memory. Use this instead!
 *
 * @param sCode        The code to run.
 * @noreturn
 */
stock void L4D2_RunScript(const char[] sCode, any...)
{
	static int iScriptLogic = INVALID_ENT_REFERENCE;
	if (iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic))
	{
		iScriptLogic = EntIndexToEntRef(CreateEntityByName("logic_script"));
		if (iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic))
			SetFailState("Could not create 'logic_script'");

		DispatchSpawn(iScriptLogic);
	}

	static char sBuffer[8192];
	VFormat(sBuffer, sizeof(sBuffer), sCode, 2);

	SetVariantString(sBuffer);
	AcceptEntityInput(iScriptLogic, "RunScriptCode");
}

/**
 * Executes CheatCommand.
 *
 * @param client		Client index.
 * @param command		Command.
 * @param arguments		Arguments.
 * @noreturn
 */
stock void CheatCommand(int client, const char[] command, const char[] arguments)
{
	if (IsValidClient(client)) return;
	FakeClientCommand(client, "%s %s", command, arguments);
}

/**
 * Executes SuperCheatCommand.
 *
 * @param client		Client index.
 * @param command		Command.
 * @param arguments		Arguments.
 * @noreturn
 */
stock void SuperCheatCommand(int client, const char[] command, const char[] arguments)
{
	if (IsValidClient(client)) return;
	int admindata = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, admindata);
}

// AutoExecConfig.Inc

/**
 * Returns the last result from the parser.
 *
 * @return			Returns one of the AUTOEXEC_FIND values or -1 if not set.
 */
stock int AutoExecConfig_GetFindResult()
{
	return g_iLastFindResult;
}

/**
 * Returns the last result from the appender.
 *
 * @return			Returns one of the AUTOEXEC_APPEND values or -1 if not set.
 */
stock int AutoExecConfig_GetAppendResult()
{
	return g_iLastAppendResult;
}

/**
 * Set if the config file should be created if it doesn't exist yet.
 *
 * @param create 	True if config file should be created, false otherwise.
 * @noreturn
 */
stock void AutoExecConfig_SetCreateFile(bool create)
{
	g_bCreateFile = create;
}

/**
 * Returns if the config file should be created if it doesn't exist.
 *
 * @return			Returns true, if the config file should be created or false if it should not.
 */
stock bool AutoExecConfig_GetCreateFile()
{
	return g_bCreateFile;
}

/**
 * Set the plugin for which the config file should be created.
 * Set to null to use the calling plugin.
 * Used to print the correct filename in the top comment when creating the file.
 *
 * @param plugin 	The plugin to create convars for or null to use the calling plugin.
 * @noreturn
 */
stock void AutoExecConfig_SetPlugin(Handle plugin)
{
	g_hPluginHandle = plugin;
}

/**
 * Returns the plugin for which the config file is created.
 *
 * @return			The plugin handle
 */
stock Handle AutoExecConfig_GetPlugin()
{
	return g_hPluginHandle;
}

/**
 * Set the global autoconfigfile used by functions of this file.
 *
 * @param file			Name of the config file, path and .cfg extension is being added if not given.
 * @param folder		Folder under cfg/ to use.  By default this is "sourcemod."
 * @return				True if formatter returned success, false otherwise.
 */
stock bool AutoExecConfig_SetFile(char[] file, char[] folder = "sourcemod")
{
	Format(g_sConfigFile, sizeof(g_sConfigFile), "%s", file);

	strcopy(g_sRawFileName, sizeof(g_sRawFileName), file);
	strcopy(g_sFolderPath, sizeof(g_sFolderPath), folder);

	return AutoExecConfig_FormatFileName(g_sConfigFile, sizeof(g_sConfigFile), folder) == AUTOEXEC_FORMAT_SUCCESS;
}

/**
 * Get the formatted autoconfigfile used by functions of this file.
 *
 * @param buffer		String to format.
 * @param size			Maximum size of buffer
 * @return				True if filename was set, false otherwise.
 */
stock bool AutoExecConfig_GetFile(char[] buffer, int size)
{
	if (strlen(g_sConfigFile) > 0)
	{
		strcopy(buffer, size, g_sConfigFile);

		return true;
	}

	buffer[0] = '\0';

	return false;
}

/**
 * Creates a convar and appends it to the autoconfigfile if not found.
 * FCVAR_DONTRECORD will be skipped.
 *
 * @param name			Name of new convar.
 * @param defaultValue	String containing the default value of new convar.
 * @param description	Optional description of the convar.
 * @param flags			Optional bitstring of flags determining how the convar should be handled. See FCVAR_* constants for more details.
 * @param hasMin		Optional boolean that determines if the convar has a minimum value.
 * @param min			Minimum floating point value that the convar can have if hasMin is true.
 * @param hasMax		Optional boolean that determines if the convar has a maximum value.
 * @param max			Maximum floating point value that the convar can have if hasMax is true.
 * @return				A handle to the newly created convar. If the convar already exists, a handle to it will still be returned.
 * @error				Convar name is blank or is the same as an existing console command.
 */
stock ConVar AutoExecConfig_CreateConVar(const char[] name, const char[] defaultValue, const char[] description = "", int flags = 0, bool hasMin = false, float min = 0.0, bool hasMax = false, float max = 0.0)
{
	if (!(flags & FCVAR_DONTRECORD) && strlen(g_sConfigFile) > 0)
	{
		g_iLastFindResult	= -1;
		g_iLastAppendResult = -1;

		char buffer[64];

		g_iLastFindResult = AutoExecConfig_FindValue(name, buffer, sizeof(buffer), true);

		if (g_iLastFindResult == AUTOEXEC_FIND_NOT_FOUND || (g_iLastFindResult == AUTOEXEC_FIND_FILE_NOT_FOUND && g_bCreateFile))
			g_iLastAppendResult = AutoExecConfig_AppendValue(name, defaultValue, description, flags, hasMin, min, hasMax, max);
	}

	return CreateConVar(name, defaultValue, description, flags, hasMin, min, hasMax, max);
}

/**
 * Executes the autoconfigfile, and adds it to the OnConfigsExecuted forward.
 * If we didn't created it already we let SourceMod create it.
 *
 * @noreturn
 */
stock void AutoExecConfig_ExecuteFile()
{
	AutoExecConfig(!g_bCreateFile, g_sRawFileName, g_sFolderPath);
}

/**
 * Formats a autoconfigfile, prefixes path and adds .cfg extension if missed.
 *
 * @param buffer		String to format.
 * @param size			Maximum size of buffer.
 * @return				Returns one of the AUTOEXEC_FORMAT values..
 */
stock static int AutoExecConfig_FormatFileName(char[] buffer, int size, char[] folder = "sourcemod")
{
	if (strlen(g_sConfigFile) < 1)
		return AUTOEXEC_NO_CONFIG;

	if (StrContains(g_sConfigFile, ".cfg") == -1 && strlen(g_sConfigFile) < 4)
		return AUTOEXEC_FORMAT_BAD_FILENAME;

	char pathprefixbuffer[PLATFORM_MAX_PATH];

	if (strlen(folder) > 0)
		Format(pathprefixbuffer, sizeof(pathprefixbuffer), "cfg/%s/", folder);
	else
		Format(pathprefixbuffer, sizeof(pathprefixbuffer), "cfg/");

	char filebuffer[PLATFORM_MAX_PATH];
	filebuffer[0] = '\0';

	if (StrContains(buffer, pathprefixbuffer) != 0)
		StrCat(filebuffer, sizeof(filebuffer), pathprefixbuffer);

	StrCat(filebuffer, sizeof(filebuffer), g_sConfigFile);

	if (StrContains(filebuffer[strlen(filebuffer) - 4], ".cfg") != 0)
		StrCat(filebuffer, sizeof(filebuffer), ".cfg");

	strcopy(buffer, size, filebuffer);

	return AUTOEXEC_FORMAT_SUCCESS;
}

/**
 * Appends a convar to the global autoconfigfile
 *
 * @param name			Name of new convar.
 * @param defaultValue	String containing the default value of new convar.
 * @param description	Optional description of the convar.
 * @param flags			Optional bitstring of flags determining how the convar should be handled. See FCVAR_* constants for more details.
 * @param hasMin		Optional boolean that determines if the convar has a minimum value.
 * @param min			Minimum floating point value that the convar can have if hasMin is true.
 * @param hasMax		Optional boolean that determines if the convar has a maximum value.
 * @param max			Maximum floating point value that the convar can have if hasMax is true.
 * @return				Returns one of the AUTOEXEC_APPEND values
 */
stock int AutoExecConfig_AppendValue(const char[] name, const char[] defaultValue, const char[] description, int flags, bool hasMin, float min, bool hasMax, float max)
{
	if (strlen(g_sConfigFile) < 1)
		return AUTOEXEC_NO_CONFIG;

	char filebuffer[PLATFORM_MAX_PATH];
	strcopy(filebuffer, sizeof(filebuffer), g_sConfigFile);

	bool bFileExists = FileExists(filebuffer);

	if (g_bCreateFile || bFileExists)
	{
		File fFile = OpenFile(filebuffer, (bFileExists ? "a" : "w"));
		char writebuffer[2048];

		if (fFile == null)
			return AUTOEXEC_APPEND_BAD_HANDLE;

		if (g_bCreateFile && !bFileExists)
		{
			Format(writebuffer, sizeof(writebuffer), "// This file was auto-generated by SourceMod (%s) ", SOURCEMOD_VERSION);
			fFile.WriteLine(writebuffer);

			GetPluginInfo(g_hPluginHandle, PlInfo_Name, writebuffer, sizeof(writebuffer));
			Format(writebuffer, sizeof(writebuffer), "// ConVars for plugin \"%s\"", writebuffer);
			fFile.WriteLine(writebuffer);

			char writebuffer2[2048];

			GetPluginInfo(g_hPluginHandle, PlInfo_Version, writebuffer, sizeof(writebuffer));
			GetPluginInfo(g_hPluginHandle, PlInfo_Author, writebuffer2, sizeof(writebuffer2));
			Format(writebuffer, sizeof(writebuffer), "// Edit By %s Version %s", writebuffer2, writebuffer);
			fFile.WriteLine(writebuffer);
		}

		fFile.WriteLine("\n");

		int newlines = GetCharCountInStr('\n', description);
		if (newlines == 0)
		{
			Format(writebuffer, sizeof(writebuffer), "// %s", description);
			fFile.WriteLine(writebuffer);
		}
		else
		{
			char[][] newlineBuf = new char[newlines + 1][2048];
			ExplodeString(description, "\n", newlineBuf, newlines + 1, 2048, false);

			for (int i; i <= newlines; i++)
				if (strlen(newlineBuf[i]) > 0)
					fFile.WriteLine("// %s", newlineBuf[i]);
		}

		fFile.WriteLine("// -");

		Format(writebuffer, sizeof(writebuffer), "// Default: \"%s\"", defaultValue);
		fFile.WriteLine(writebuffer);

		if (hasMin)
		{
			Format(writebuffer, sizeof(writebuffer), "// Minimum: \"%f\"", min);
			fFile.WriteLine(writebuffer);
		}

		if (hasMax)
		{
			Format(writebuffer, sizeof(writebuffer), "// Maximum: \"%f\"", max);
			fFile.WriteLine(writebuffer);
		}

		Format(writebuffer, sizeof(writebuffer), "%s \"%s\"", name, defaultValue);
		fFile.WriteLine(writebuffer);

		fFile.Close();

		return AUTOEXEC_APPEND_SUCCESS;
	}
	return AUTOEXEC_APPEND_FILE_NOT_FOUND;
}

/**
 * Returns a convars value from the global autoconfigfile
 *
 * @param cvar				Cvar to search for.
 * @param value				Buffer to store result into.
 * @param size				Maximum size of buffer.
 * @param caseSensitive		Whether or not the search should be case sensitive.
 * @return					Returns one of the AUTOEXEC_FIND values
 */
stock int AutoExecConfig_FindValue(const char[] cvar, char[] value, int size, bool caseSensitive = false)
{
	value[0] = '\0';

	if (strlen(g_sConfigFile) < 1)
		return AUTOEXEC_NO_CONFIG;

	char filebuffer[PLATFORM_MAX_PATH];
	strcopy(filebuffer, sizeof(filebuffer), g_sConfigFile);

	bool bFileExists = FileExists(filebuffer);

	if (g_bCreateFile && !bFileExists)
		return AUTOEXEC_FIND_FILE_NOT_FOUND;

	if (bFileExists)
	{
		File fFile = OpenFile(filebuffer, "r");
		int	 valuestart;
		int	 valueend;
		int	 cvarend;

		char sConvar[64];
		char sValue[64];
		char readbuffer[2048];
		char copybuffer[2048];

		if (fFile == null)
			return AUTOEXEC_FIND_BAD_HANDLE;

		while (!fFile.EndOfFile() && fFile.ReadLine(readbuffer, sizeof(readbuffer)))
		{
			if (IsCharSpace(readbuffer[0]) || readbuffer[0] == '/' || !IsCharAlpha(readbuffer[0]))
				continue;

			if (GetCharCountInStr(' ', readbuffer) < 1)
				continue;

			if (GetCharCountInStr('"', readbuffer) != 2)
				continue;

			if ((valuestart = StrContains(readbuffer, "\"")) == -1)
				continue;

			if ((valueend = StrContains(readbuffer[valuestart + 1], "\"")) == -1)
				continue;

			if ((cvarend = StrContains(readbuffer, " ")) == -1 || cvarend >= valuestart)
				continue;

			if (cvarend >= valuestart)
				continue;

			strcopy(copybuffer, sizeof(copybuffer), readbuffer);
			copybuffer[cvarend] = '\0';

			strcopy(sConvar, sizeof(sConvar), copybuffer);

			strcopy(copybuffer, sizeof(copybuffer), readbuffer[valuestart + 1]);
			copybuffer[valueend] = '\0';

			strcopy(sValue, sizeof(sValue), copybuffer);

			if (StrEqual(sConvar, cvar, caseSensitive))
			{
				Format(value, size, "%s", sValue);

				fFile.Close();
				return AUTOEXEC_FIND_SUCCESS;
			}
		}

		fFile.Close();
		return AUTOEXEC_FIND_NOT_FOUND;
	}

	return AUTOEXEC_FIND_FILE_NOT_FOUND;
}

/**
 * Cleans the global autoconfigfile from too much spaces
 *
 * @return					One of the AUTOEXEC_CLEAN values.
 */
stock int AutoExecConfig_CleanFile()
{
	if (strlen(g_sConfigFile) < 1)
	{
		return AUTOEXEC_NO_CONFIG;
	}

	char sfile[PLATFORM_MAX_PATH];
	strcopy(sfile, sizeof(sfile), g_sConfigFile);

	if (!FileExists(sfile))
	{
		return AUTOEXEC_CLEAN_FILE_NOT_FOUND;
	}

	char sfile2[PLATFORM_MAX_PATH];
	Format(sfile2, sizeof(sfile2), "%s_tempcopy", sfile);

	char readbuffer[2048];
	int	 count;
	bool firstreached;

	File fFile1 = OpenFile(sfile, "r");
	File fFile2 = OpenFile(sfile2, "w");

	if (fFile1 == null || fFile2 == null)
	{
		if (fFile1 != null)
			fFile1.Close();

		if (fFile2 != null)
			fFile2.Close();

		return AUTOEXEC_CLEAN_BAD_HANDLE;
	}

	while (!fFile1.EndOfFile() && fFile1.ReadLine(readbuffer, sizeof(readbuffer)))
	{
		if (IsCharSpace(readbuffer[0]))
			count++;
		else
			count = 0;

		if (count < 2 || !firstreached)
		{
			ReplaceString(readbuffer, sizeof(readbuffer), "\n", "");
			fFile2.WriteLine(readbuffer);
		}

		if (count == 2)
			firstreached = true;
	}

	fFile1.Close();
	fFile2.Close();

	DeleteFile(sfile);
	RenameFile(sfile, sfile2);

	return AUTOEXEC_CLEAN_SUCCESS;
}

/**
 * Exec the ConVar Config.
 *
 * @return				Returns one of the AUTOEXEC_APPEND values
 */
stock int AutoExecConfig_OnceExec()
{
	if (strlen(g_sConfigFile) < 1)
		return AUTOEXEC_NO_CONFIG;

	char filebuffer[PLATFORM_MAX_PATH];
	strcopy(filebuffer, sizeof(filebuffer), g_sConfigFile);

	if (FileExists(filebuffer))
	{
		Format(filebuffer, sizeof(filebuffer), "%s/%s.cfg", g_sFolderPath, g_sRawFileName);
		ServerCommand("exec %s", filebuffer);
	}

	return AUTOEXEC_EXEC_SUCCESS;
}

stock int AutoExecConfig_DeleteConfig()
{
	if (strlen(g_sConfigFile) < 1)
		return AUTOEXEC_NO_CONFIG;

	char filebuffer[PLATFORM_MAX_PATH];
	strcopy(filebuffer, sizeof(filebuffer), g_sConfigFile);

	if (FileExists(filebuffer))
	{
		Format(filebuffer, sizeof(filebuffer), "cfg/%s/%s.cfg", g_sFolderPath, g_sRawFileName);
		if (DeleteFile(filebuffer))
			return AUTOEXEC_CLEAN_SUCCESS;
	}

	return AUTOEXEC_CLEAN_FILE_NOT_FOUND;
}

stock int AutoExecConfig_UpdateToConfig(ConVar Cvar, bool NeedReset)
{
	if (strlen(g_sConfigFile) < 1)
		return AUTOEXEC_NO_CONFIG;

	char ConName[128], ConDes[512], ConValue[512];

	Cvar.GetName(ConName, sizeof ConName);
	Cvar.GetDescription(ConDes, sizeof ConDes);

	bool  HasMax, HasMin;
	float MaxValue, MinValue;

	if (Cvar.GetBounds(ConVarBound_Upper, MaxValue))
		HasMax = true;
	if (Cvar.GetBounds(ConVarBound_Lower, MinValue))
		HasMin = true;

	if (NeedReset)
		Cvar.RestoreDefault();

	Cvar.GetString(ConValue, sizeof ConValue);

	return AutoExecConfig_AppendValue(ConName, ConValue, ConDes, Cvar.Flags, HasMin, MinValue, HasMax, MaxValue);
}