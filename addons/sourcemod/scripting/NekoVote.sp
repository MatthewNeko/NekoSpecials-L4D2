#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <dhooks>
#include <left4dhooks>
#include <binhooks>
#include <neko/nekotools>
#include <neko/nekonative>
#include <l4d2_nativevote>
#include "nvote/globals.sp"

#define PLUGIN_CONFIG "Neko_VoteMenu"

public Plugin myinfo =
{
	name		= "Neko Vote Menu",
	description = "Neko Specials Vote Menu",
	author		= "Neko Channel",
	version		= PLUGIN_VERSION,
	url			= "https://himeneko.cn/nekospecials"
	//请勿修改插件信息！
};

public void OnPluginStart()
{
	AutoExecConfig_SetFile(PLUGIN_CONFIG);

	NCvar[Neko_CanSwitch]		  = AutoExecConfig_CreateConVar("Neko_CanSwitch", "0", "[0=关|1=开]全局投票开关", _, true, 0.0, true, 1.0);
	NCvar[Neko_SwitchStatus]	  = AutoExecConfig_CreateConVar("Neko_SwitchStatus", "0", "[0=关|1=开]玩家是否能投票更改插件状态", _, true, 0.0, true, 1.0);
	NCvar[Neko_SwitchNumber]	  = AutoExecConfig_CreateConVar("Neko_SwitchNumber", "0", "[0=关|1=开]玩家是否能投票更改特感数量", _, true, 0.0, true, 1.0);
	NCvar[Neko_SwitchTime]		  = AutoExecConfig_CreateConVar("Neko_SwitchTime", "0", "[0=关|1=开]玩家是否能投票更改刷特时间", _, true, 0.0, true, 1.0);
	NCvar[Neko_SwitchRandom]	  = AutoExecConfig_CreateConVar("Neko_SwitchRandom", "0", "[0=关|1=开]玩家是否能投票开关随机特感", _, true, 0.0, true, 1.0);
	NCvar[Neko_SwitchGameMode]	  = AutoExecConfig_CreateConVar("Neko_SwitchGameMode", "0", "[0=关|1=开]玩家是否能投票更改插件特感模式", _, true, 0.0, true, 1.0);
	NCvar[Neko_SwitchSpawnMode]	  = AutoExecConfig_CreateConVar("Neko_SwitchSpawnMode", "0", "[0=关|1=开]玩家是否能投票更改插件刷特模式", _, true, 0.0, true, 1.0);
	NCvar[Neko_SwitchPlayerJoin]  = AutoExecConfig_CreateConVar("Neko_SwitchPlayerJoin", "0", "[兼容项][0=关|1=开]玩家是否能投票更改初始玩家数量", _, true, 0.0, true, 1.0);
	NCvar[Neko_SwitchNumAdd]       = AutoExecConfig_CreateConVar("Neko_SwitchNumAdd", "0", "[0=关|1=开]玩家是否能投票更改进人增加特感数量", _, true, 0.0, true, 1.0);
	NCvar[Neko_SwitchPlayerAdd]    = AutoExecConfig_CreateConVar("Neko_SwitchPlayerAdd", "0", "[0=关|1=开]玩家是否能投票更改玩家增加间隔", _, true, 0.0, true, 1.0);
	NCvar[Neko_SwitchTankAlive]	  = AutoExecConfig_CreateConVar("Neko_SwitchTankAlive", "0", "[0=关|1=开]玩家是否能开关坦克存活时依旧刷特功能", _, true, 0.0, true, 1.0);
	NCvar[Neko_NeedResetNoPlayer] = AutoExecConfig_CreateConVar("Neko_NeedResetNoPlayer", "0", "[0=关|1=开]全部玩家离开游戏后自动重置特感数据", _, true, 0.0, true, 1.0);
	NCvar[Neko_VotePassPercent] = AutoExecConfig_CreateConVar("Neko_VotePassPercent", "80", "投票通过率百分比", _, true, 1.0, true, 100.0);
	NCvar[Neko_VoteMinPlayers]  = AutoExecConfig_CreateConVar("Neko_VoteMinPlayers", "1", "发起投票所需的最低投票池人数", _, true, 1.0, true, 32.0);
	NCvar[Neko_TimeMin] = AutoExecConfig_CreateConVar("Neko_TimeMin", "3", "刷特时间投票最小值（插件硬限制0-180）", _, true, 0.0, true, 180.0);
	NCvar[Neko_TimeMax] = AutoExecConfig_CreateConVar("Neko_TimeMax", "180", "刷特时间投票最大值（插件硬限制0-180）", _, true, 0.0, true, 180.0);
	NCvar[Neko_NumMin] = AutoExecConfig_CreateConVar("Neko_NumMin", "1", "初始刷特数量投票最小值（插件硬限制1-32）", _, true, 1.0, true, 32.0);
	NCvar[Neko_NumMax] = AutoExecConfig_CreateConVar("Neko_NumMax", "32", "初始刷特数量投票最大值（插件硬限制1-32）", _, true, 1.0, true, 32.0);
	NCvar[Neko_AddMin] = AutoExecConfig_CreateConVar("Neko_AddMin", "0", "进人增加特感数量投票最小值（插件硬限制0-8）", _, true, 0.0, true, 8.0);
	NCvar[Neko_AddMax] = AutoExecConfig_CreateConVar("Neko_AddMax", "8", "进人增加特感数量投票最大值（插件硬限制0-8）", _, true, 0.0, true, 8.0);
	NCvar[Neko_PlayerNumMin] = AutoExecConfig_CreateConVar("Neko_PlayerNumMin", "1", "初始玩家数量投票最小值（插件硬限制1-32）", _, true, 1.0, true, 32.0);
	NCvar[Neko_PlayerNumMax] = AutoExecConfig_CreateConVar("Neko_PlayerNumMax", "32", "初始玩家数量投票最大值（插件硬限制1-32）", _, true, 1.0, true, 32.0);
	NCvar[Neko_PlayerAddMin] = AutoExecConfig_CreateConVar("Neko_PlayerAddMin", "1", "玩家增加间隔投票最小值（插件硬限制1-8）", _, true, 1.0, true, 8.0);
	NCvar[Neko_PlayerAddMax] = AutoExecConfig_CreateConVar("Neko_PlayerAddMax", "8", "玩家增加间隔投票最大值（插件硬限制1-8）", _, true, 1.0, true, 8.0);
	NCvar[Neko_NeedResetTime]	  = AutoExecConfig_CreateConVar("Neko_NeedResetTime", "10", "全部玩家离开游戏多少秒后自动重置");
	NCvar[Neko_SwitchPauseOnDown] = AutoExecConfig_CreateConVar("Neko_SwitchPauseOnDown", "0", "[0=关|1=开]玩家是否能投票开关倒地暂停刷特", _, true, 0.0, true, 1.0);
	NCvar[Neko_SwitchDownCount]   = AutoExecConfig_CreateConVar("Neko_SwitchDownCount", "0", "[0=关|1=开]玩家是否能投票修改倒地人数阈值", _, true, 0.0, true, 1.0);
	NCvar[Neko_DownCountMin]      = AutoExecConfig_CreateConVar("Neko_DownCountMin", "1", "倒地人数投票最小值（插件硬限制1-4）", _, true, 1.0, true, 4.0);
	NCvar[Neko_DownCountMax]      = AutoExecConfig_CreateConVar("Neko_DownCountMax", "4", "倒地人数投票最大值（插件硬限制1-4）", _, true, 1.0, true, 4.0);

	AutoExecConfig_OnceExec();

	HookEventEx("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);

	AddCommandListener(ChatListener, "say");
	AddCommandListener(ChatListener, "say2");
	AddCommandListener(ChatListener, "say_team");

	RegConsoleCmd("sm_tgvote", OpenVoteMenu, "打开特感投票菜单");

	RegAdminCmd("sm_tgvoteadmin", OpenVoteAdminMenu, ADMFLAG_ROOT, "打开管理员投票控制菜单");
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("nekovote");
	CreateNative("NekoVote_PlHandle", NekoVote_REPlHandle);
	CreateNative("NekoVote_VoteStatus", NekoVote_REVoteStatus);

	return APLRes_Success;
}

public void OnConfigsExecuted()
{
	for (int i = 1; i < GetCvar_Max; i++)
	{
		if (i == CGame_Difficulty)
			continue;

		GCvar[i] = NekoSpecials_GetConVar(i);
	}

	// A config reload can change the meaning of an in-flight vote or a pending
	// chat edit. Clear only NekoVote-owned state; ClearVoteInteractionState()
	// cancels the native vote only when our snapshot is active.
	ClearVoteInteractionState();

	// ConVar bounds protect individual values, but not reversed min/max pairs.
	// Normalize after every config execution so external edits cannot disable a
	// whole vote category.
	NormalizeVoteConfig();
}

#include "nvote/natives.sp"
#include "nvote/api.sp"
#include "nvote/hooks.sp"
#include "nvote/timers.sp"
#include "nvote/adminmenus.sp"
#include "nvote/menus.sp"
#include "nvote/vote.sp"
