#pragma semicolon 1
#pragma newdecls required

#include <neko/nekonative>
#include <neko/nekotools>
#include <ripext>
#include <sourcemod>

#define PLUGIN_CONFIG "Neko_Updater"

#define SPECIALS_AVAILABLE()   (GetFeatureStatus(FeatureType_Native, "NekoSpecials_PlHandle") == FeatureStatus_Available)
#define NKILLHUD_AVAILABLE()   (GetFeatureStatus(FeatureType_Native, "NekoKillHud_PlHandle") == FeatureStatus_Available)
#define ADMINMENU_AVAILABLE()  (GetFeatureStatus(FeatureType_Native, "NekoAdminMenu_PlHandle") == FeatureStatus_Available)
#define SERVERNAME_AVAILABLE() (GetFeatureStatus(FeatureType_Native, "NekoServerName_PlHandle") == FeatureStatus_Available)
#define VOTEMENU_AVAILABLE()   (GetFeatureStatus(FeatureType_Native, "NekoVote_PlHandle") == FeatureStatus_Available)

ConVar AutoDownloadEnable, AutoBackupEnable, AutoCheckupTime, NativeVotes_Version;

public Plugin myinfo =
{
	name        = "Neko Updater",
	description = "Neko Specials Plugins Updater",
	author      = "Neko Channel",
	version     = PLUGIN_VERSION,
	url         = "https://himeneko.cn/nekospecials"
	//请勿修改插件信息！
};

public void OnPluginStart()
{
	AutoExecConfig_SetFile(PLUGIN_CONFIG);
	AutoExecConfig_SetCreateFile(true);
	
	AutoDownloadEnable  = AutoExecConfig_CreateConVar("neko_updater_autodownload", "1", "[0=关|1=开]插件自动下载[关闭后仅提示有新版本]", FCVAR_NONE, true, 0.0, true, 1.0);
	AutoBackupEnable    = AutoExecConfig_CreateConVar("neko_updater_autobackup", "1", "[0=关|1=开]插件自动备份", FCVAR_NONE, true, 0.0, true, 1.0);
	AutoCheckupTime     = AutoExecConfig_CreateConVar("neko_updater_autocheck_time", "43200.0", "[0=关|1=开]插件自动检查更新间隔", FCVAR_NONE, true, 3600.0, true, 90000.0);
	NativeVotes_Version = FindConVar("nativevotes_version");

	AutoExecConfig_OnceExec();

	CreateTimer(2.0, CheckUpdateStart);

	if (!IsDedicatedServer())
		MoveToDisabled();

	CreateTimer(AutoCheckupTime.FloatValue, AutoCheckUpdateStart, TIMER_REPEAT);

	RegAdminCmd("sm_nekoupdate", StartNekoUpdate, ADMFLAG_ROOT, "执行检查更新");
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("nekoupdater");
	MarkNativeAsOptional("NekoKillHud_PlHandle");
	MarkNativeAsOptional("NekoSpecials_PlHandle");
	MarkNativeAsOptional("NekoAdminMenu_PlHandle");
	MarkNativeAsOptional("NekoServerName_PlHandle");
	MarkNativeAsOptional("NekoVote_PlHandle");
	return APLRes_Success;
}

public Action StartNekoUpdate(int client, int args)
{
	CreateTimer(0.1, CheckUpdateStart);
	return Plugin_Continue;
}

public Action AutoCheckUpdateStart(Handle Timer)
{
	if (GetPlayers(false) > 0)
		return Plugin_Continue;

	CreateTimer(0.1, CheckUpdateStart);
	return Plugin_Continue;
}

public Action CheckUpdateStart(Handle Timer)
{
	LogMessage("%s 正在从API上获取更新信息...", NEKOTAG);
	HTTPRequest GetInfo = new HTTPRequest("http://dmapi.himeneko.cn/nekospecials/get");
	GetInfo.SetHeader("User-Agent", "NekoUpdater HTTP Client 1.0 (MainModule)");
	GetInfo.Get(CheckUpdateMethod);
	return Plugin_Stop;
}

public void CheckUpdateMethod(HTTPResponse response, any value)
{
	if (response.Status != HTTPStatus_OK)
	{
		LogError("%s 从API上获取更新信息失败! 请检查网络设置!", NEKOTAG);
		return;
	}

	if (response.Data == null)
	{
		LogError("%s 从API上获取更新信息失败!", NEKOTAG);
		return;
	}

	if (SPECIALS_AVAILABLE())
	{
		CheckUpdate(response.Data, NekoSpecials_PlHandle(), "NekoSpecials");
	}

	if (NKILLHUD_AVAILABLE())
	{
		CheckUpdate(response.Data, NekoKillHud_PlHandle(), "NekoKillHud");
	}

	if (ADMINMENU_AVAILABLE())
	{
		CheckUpdate(response.Data, NekoAdminMenu_PlHandle(), "NekoAdminMenu");
	}

	if (SERVERNAME_AVAILABLE())
	{
		CheckUpdate(response.Data, NekoServerName_PlHandle(), "NekoServerName");
	}

	if (VOTEMENU_AVAILABLE())
	{
		CheckUpdate(response.Data, NekoVote_PlHandle(), "NekoVote");
	}

	if (!SPECIALS_AVAILABLE() && !NKILLHUD_AVAILABLE() && !ADMINMENU_AVAILABLE() && !SERVERNAME_AVAILABLE() && !VOTEMENU_AVAILABLE())
	{
		LogMessage("%s 无支持插件可更新!", NEKOTAG);
		return;
	}

	CreateTimer(8.0, ChangeMapToUpdate, _, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(20.0, CheckMySelfUpdate);
}

public Action ChangeMapToUpdate(Handle Timer)
{
	char NowMapName[512];
	GetCurrentMap(NowMapName, sizeof NowMapName);
	ServerCommand("changelevel %s", NowMapName);
	return Plugin_Stop;
}

public Action CheckMySelfUpdate(Handle Timer)
{
	LogMessage("%s 正在从API上获取更新信息...", NEKOTAG);
	HTTPRequest GetInfo = new HTTPRequest("http://dmapi.himeneko.cn/nekospecials/get");
	GetInfo.SetHeader("User-Agent", "NekoUpdater HTTP Client 1.0 (MainModule)");
	GetInfo.Get(CheckMyUpdateMethod);
	return Plugin_Stop;
}

public void CheckMyUpdateMethod(HTTPResponse response, any value)
{
	if (response.Status != HTTPStatus_OK)
	{
		LogError("%s 从API上获取更新信息失败! 请检查网络设置!", NEKOTAG);
		return;
	}

	if (response.Data == null)
	{
		LogError("%s 从API上获取更新信息失败!", NEKOTAG);
		return;
	}

	CheckUpdate(response.Data, GetMyHandle(), "NekoUpdater");
}

public void MoveToDisabled()
{
	LogMessage("%s 检测为非服务端使用!", NEKOTAG);

	if (NativeVotes_Version != null)
		MoveBackupFile(NativeVotes_Version.Plugin);

	if (VOTEMENU_AVAILABLE())
		MoveBackupFile(NekoVote_PlHandle());
}

public void MoveBackupFile(Handle HPlugin)
{
	char NPluginsName[128], NPluginsPath[PLATFORM_MAX_PATH], BPluginsPath[PLATFORM_MAX_PATH];

	GetPluginFilename(HPlugin, NPluginsName, sizeof(NPluginsName));

	BuildPath(Path_SM, NPluginsPath, sizeof(NPluginsPath), "plugins/%s", NPluginsName);

	char NBackupPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, NBackupPath, sizeof(NBackupPath), "plugins/disabled");

	if (!DirExists(NBackupPath))
		CreateDirectory(NBackupPath, 511);

	char ExplodeName[64][256];

	int LastNum = ExplodeString(NPluginsName, "\\", ExplodeName, 64, 256);

	Format(BPluginsPath, sizeof(BPluginsPath), "%s/%s", NBackupPath, ExplodeName[LastNum - 1]);

	if (FileExists(NPluginsPath))
	{
		if (FileExists(BPluginsPath))
			DeleteFile(BPluginsPath);

		if (AutoBackupEnable.BoolValue)
			RenameFile(BPluginsPath, NPluginsPath);

		if (FileExists(NPluginsPath))
			DeleteFile(NPluginsPath);
	}

	LogMessage("%s 自动卸载移除 %s 插件到disabled文件夹", NEKOTAG, NPluginsPath);
	ServerCommand("sm plugins unload %s", NPluginsPath);
}

public void CheckUpdate(JSON json, Handle HPlugin, char[] MoudleName)
{
	char NVersion[64], PVersion[64];

	JSONObject jRoot   = view_as<JSONObject>(json);
	JSONObject jMoudle = view_as<JSONObject>(jRoot.Get(MoudleName));

	jMoudle.GetString("version", NVersion, sizeof(NVersion));

	GetPluginInfo(HPlugin, PlInfo_Version, PVersion, sizeof(PVersion));

	if (strcmp(NVersion, PVersion) == 0)
	{
		LogMessage("%s %s 已经是最新的版本!", NEKOTAG, MoudleName);
		return;
	}

	if (!AutoDownloadEnable.BoolValue)
	{
		LogMessage("%s 检测到 %s 最新的版本 %s, 请手动更新!", NEKOTAG, MoudleName, NVersion);
		return;
	}

	LogMessage("%s 检测到 %s 最新的版本 %s, 开始更新!", NEKOTAG, MoudleName, NVersion);

	char NPluginsName[128], NPluginsPath[PLATFORM_MAX_PATH], BPluginsPath[PLATFORM_MAX_PATH];

	GetPluginFilename(HPlugin, NPluginsName, sizeof(NPluginsName));

	BuildPath(Path_SM, NPluginsPath, sizeof(NPluginsPath), "plugins/%s", NPluginsName);

	char NBackupPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, NBackupPath, sizeof(NBackupPath), "plugins/disabled");

	if (!DirExists(NBackupPath))
		CreateDirectory(NBackupPath, 511);

	char ExplodeName[64][256];

	int LastNum = ExplodeString(NPluginsName, "\\", ExplodeName, 64, 256);

	Format(BPluginsPath, sizeof(BPluginsPath), "%s/%s", NBackupPath, ExplodeName[LastNum - 1]);

	if (FileExists(NPluginsPath))
	{
		if (FileExists(BPluginsPath))
			DeleteFile(BPluginsPath);

		if (AutoBackupEnable.BoolValue)
			RenameFile(BPluginsPath, NPluginsPath);

		if (FileExists(NPluginsPath))
			DeleteFile(NPluginsPath);
	}

	char DownFile[128];
	Format(DownFile, sizeof(DownFile), "http://dmapi.himeneko.cn/nekospecials/build7/%s.smx", MoudleName);

	HTTPRequest GetUpdate = new HTTPRequest(DownFile);
	GetUpdate.SetHeader("User-Agent", "NekoUpdater HTTP Client 1.0 (MainModule)");

	DataPack pushpack = new DataPack();

	GetUpdate.DownloadFile(NPluginsPath, DownloadInfo, pushpack);
	pushpack.WriteString(NPluginsName);
}

public void DownloadInfo(HTTPStatus status, any pack)
{
	DataPack pushpack = pack;
	if (status != HTTPStatus_OK)
	{
		LogError("%s 插件更新失败，请重新尝试或联系作者! 插件已备份!", NEKOTAG);
		return;
	}

	char NPluginsName[128];
	pushpack.Reset();
	pushpack.ReadString(NPluginsName, sizeof(NPluginsName));

	LogMessage("%s %s插件更新成功!", NEKOTAG, NPluginsName);

	CreateTimer(1.0, ReloadPlugins, pushpack);
}

public Action ReloadPlugins(Handle Timer, DataPack pushpack)
{
	char NPluginsName[128];
	pushpack.Reset();
	pushpack.ReadString(NPluginsName, sizeof(NPluginsName));

	delete pushpack;

	ServerCommand("sm plugins reload %s", NPluginsName);
	return Plugin_Stop;
}