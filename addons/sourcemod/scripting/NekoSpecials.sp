#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <dhooks>
#include <left4dhooks>
#include <binhooks>
#include <neko/nekotools>
#include <neko/nekonative>
#include "nspecials/globals.sp"

public Plugin myinfo =
{
    name        = "Neko Specials Spawner",
    description = "Neko Specials Spawner Base on Binhooks",
    author      = "Neko Channel & Mr Cheng",
    version     = PLUGIN_VERSION,
    url         = "https://himeneko.cn/nekospecials"
    //请勿修改插件信息！
};

public void OnPluginStart()
{
    AutoExecConfig_SetFile(PLUGIN_CONFIG);

    NCvar[CSpecial_PluginStatus]                      = AutoExecConfig_CreateConVar("Special_PluginStatus", "1", "[0=关|1=开]禁用/启用刷特[禁用后插件将不会刷出特感，若Special_CanCloseDirector为打开状态，将会一只特感都不会刷出]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_Fast_Response]                     = AutoExecConfig_CreateConVar("Special_Fast_Response", "1", "[0=关|1=开]禁用/启用更快的特殊感染反应[建议开着就好]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_CanCloseDirector]                  = AutoExecConfig_CreateConVar("Special_CanCloseDirector", "0", "[0=关|1=开]是否插件控制导演系统开关[若刷不出坦克请关掉此选项，此选项能让单一特感刷新模式时防止其他类型的特感刷出来，如果发现开了单一特感类型刷新时会出现其他特感，请开启，开启后请配合boss_spawn插件食用]", _, true, 0.0, true, 1.0);

    NCvar[CSpecial_LeftPoint_SpawnTime]               = AutoExecConfig_CreateConVar("Special_LeftPoint_SpawnTime", "5.0", "离开安全区域后多久刷特[默认5.0秒]", _, true, 0.1, true, 120.0);
    NCvar[CSpecial_Spawn_Time]                        = AutoExecConfig_CreateConVar("Special_Spawn_Time", "10", "全局特感刷新时间间隔[0-180]", _, true, 0.0, true, 180.0);
    NCvar[CSpecial_Spawn_Time_DifficultyChange]       = AutoExecConfig_CreateConVar("Special_Spawn_Time_DifficultyChange", "0", "[0=关|1=开]禁用/启用根据游戏难度改变刷特时间[启用后-全局特感刷新时间间隔-将不会生效]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_Spawn_Time_Easy]                   = AutoExecConfig_CreateConVar("Special_Spawn_Time_Easy", "25", "简单难度特感刷新时间间隔[0-180]", _, true, 0.0, true, 180.0);
    NCvar[CSpecial_Spawn_Time_Normal]                 = AutoExecConfig_CreateConVar("Special_Spawn_Time_Normal", "20", "普通难度特感刷新时间间隔[0-180]", _, true, 0.0, true, 180.0);
    NCvar[CSpecial_Spawn_Time_Hard]                   = AutoExecConfig_CreateConVar("Special_Spawn_Time_Hard", "15", "高级难度特感刷新时间间隔[0-180]", _, true, 0.0, true, 180.0);
    NCvar[CSpecial_Spawn_Time_Impossible]             = AutoExecConfig_CreateConVar("Special_Spawn_Time_Impossible", "10", "专家难度特感刷新时间间隔[0-180]", _, true, 0.0, true, 180.0);

    NCvar[CSpecial_Num]                               = AutoExecConfig_CreateConVar("Special_Num", "4", "特感初始的刷新数量[1-32]", _, true, 1.0, true, 32.0);
    NCvar[CSpecial_AddNum]                            = AutoExecConfig_CreateConVar("Special_AddNum", "1", "特感每次进人增加数量[0-8][前提请设置Special_PlayerAdd]", _, true, 0.0, true, 8.0);
    NCvar[CSpecial_PlayerNum]                         = AutoExecConfig_CreateConVar("Special_PlayerNum", "4", "玩家初始计算人数[1-32][意思为从第几个玩家开始，来增加特感数量，低于或等于这个数值则按Special_Num的数量刷特，如果不会弄就不需要改这个]", _, true, 1.0, true, 32.0);
    NCvar[CSpecial_PlayerAdd]                         = AutoExecConfig_CreateConVar("Special_PlayerAdd", "1", "玩家增加数量[1-8][玩家每进几个人，才增加Special_AddNum数量的特感，Special_AddNum不为0才生效]", _, true, 1.0, true, 8.0);
    NCvar[CSpecial_PlayerCountSpec]                   = AutoExecConfig_CreateConVar("Special_PlayerCountSpec", "0", "[0=关|1=开]计算玩家人数时，是否把旁观者也算进去[这个会把旁观者也算进去，非常不建议打开!]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_Num_NotCul_Death]                  = AutoExecConfig_CreateConVar("Special_Num_NotCul_Death", "0", "[0=关|1=开]计算玩家人数时，不把死亡玩家也算进去[这个不会把死亡玩家也算进去，非常不建议打开!]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_Num_NotCul_Bot]                    = AutoExecConfig_CreateConVar("Special_Num_NotCul_Bot", "0", "[0=关|1=开]计算玩家人数时，不把人机也算进去", _, true, 0.0, true, 1.0);

    NCvar[CSpecial_Random_Mode]                       = AutoExecConfig_CreateConVar("Special_Random_Mode", "0", "[0=关|1=开]启用随机特感[开启后会随机Special_Default_Mode中包含的模式，仅供娱乐]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_SpawnWay]                          = AutoExecConfig_CreateConVar("Special_SpawnWay", "0", "[0=一起刷新|1=死后补充]特感刷新方式[死后补充目前有BUG，相当于无限刷特]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_Default_Mode]                      = AutoExecConfig_CreateConVar("Special_Default_Mode", "7", "指定刷新模式(当随机特感关闭生效)[1=全牛子|2=全胖子|3=全口水|4=全舌头|5=全猴子|6=全猎人|7=默认][默认模式为全部特感类型都会刷新，其他为单一类型刷新]", _, true, 1.0, true, 8.0);
    NCvar[CSpecial_Spawn_Mode]                        = AutoExecConfig_CreateConVar("Special_Spawn_Mode", "1", "[0=导演|1=普通|2=噩梦|3=地狱|4=可变]特感生成方式[导演就是游戏自带的导演系统，普通是插件默认选项比较适合普通玩家，噩梦与地狱适合大佬游玩，地狱是最高难度，噩梦与地狱刷特位置会比较近]", _, true, 0.0, true, 4.0);
    NCvar[CSpecial_IsModeInNormal]                    = AutoExecConfig_CreateConVar("Special_IsModeInNormal", "1", "[1=模式1(默认)|2=模式2]在Special_Spawn_Mode的普通、噩梦、地狱模式下有效的子模式,只有1和2可选，具体说明请看插件的说明书。", _, true, 1.0, true, 2.0);

    NCvar[CSpecial_Spawn_Tank_Alive]                  = AutoExecConfig_CreateConVar("Special_Spawn_Tank_Alive", "1", "[0=关|1=开]特感是否在坦克活着时刷新", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_Spawn_Tank_Alive_Pro]              = AutoExecConfig_CreateConVar("Special_Spawn_Tank_Alive_Pro", "0", "[0=关|1=开]当坦克活着时，特感强制在刷新的时候被踢出[开启后可试图修复CSpecial_Spawn_Tank_Alive关闭后坦克存活依旧刷特问题]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_AutoKill_StuckTank]                = AutoExecConfig_CreateConVar("Special_AutoKill_StuckTank", "1", "[0=关|1=开]自动处死卡住的坦克[有防卡插件可以关闭]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_AutoKill_StuckSpecials]            = AutoExecConfig_CreateConVar("Special_AutoKill_StuckSpecials", "1", "[0=关|1=开]自动处死卡住的特感[请慎重关闭，有很大几率卡特]", _, true, 0.0, true, 1.0);

    NCvar[CSpecial_Show_Tips]                         = AutoExecConfig_CreateConVar("Special_Show_Tips", "0", "[0=关|1=开]显示特感数量改变提示", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_Show_Tips_Chat]                    = AutoExecConfig_CreateConVar("Special_Show_Tips_Chat", "1", "[0=关|1=开]将特感改变提示变为聊天框输出，关闭就使用HUD显示", _, true, 0.0, true, 1.0);

    NCvar[CSpecial_Boomer_Num]                        = AutoExecConfig_CreateConVar("Special_Boomer_Num", "4", "Boomer最大刷新数量[当指定默认刷新模式时生效]", _, true, 0.0, true, 32.0);
    NCvar[CSpecial_Smoker_Num]                        = AutoExecConfig_CreateConVar("Special_Smoker_Num", "4", "Smoker最大刷新数量[当指定默认刷新模式时生效]", _, true, 0.0, true, 32.0);
    NCvar[CSpecial_Charger_Num]                       = AutoExecConfig_CreateConVar("Special_Charger_Num", "4", "Charger最大刷新数量[当指定默认刷新模式时生效]", _, true, 0.0, true, 32.0);
    NCvar[CSpecial_Hunter_Num]                        = AutoExecConfig_CreateConVar("Special_Hunter_Num", "4", "Hunter最大刷新数量[当指定默认刷新模式时生效]", _, true, 0.0, true, 32.0);
    NCvar[CSpecial_Spitter_Num]                       = AutoExecConfig_CreateConVar("Special_Spitter_Num", "4", "Spitter最大刷新数量[当指定默认刷新模式时生效]", _, true, 0.0, true, 32.0);
    NCvar[CSpecial_Jockey_Num]                        = AutoExecConfig_CreateConVar("Special_Jockey_Num", "4", "Jockey最大刷新数量[当指定默认刷新模式时生效]", _, true, 0.0, true, 32.0);

    NCvar[CSpecial_Boomer_Spawn_Weight]               = AutoExecConfig_CreateConVar("Special_Boomer_Spawn_Weight", "50", "Boomer刷新概率[范围1-100|当其他特感也设置了数量时生效]", _, true, 1.0, true, 100.0);
    NCvar[CSpecial_Smoker_Spawn_Weight]               = AutoExecConfig_CreateConVar("Special_Smoker_Spawn_Weight", "50", "Smoker刷新概率[范围1-100|当其他特感也设置了数量时生效]", _, true, 1.0, true, 100.0);
    NCvar[CSpecial_Charger_Spawn_Weight]              = AutoExecConfig_CreateConVar("Special_Charger_Spawn_Weight", "50", "Charger刷新概率[范围1-100|当其他特感也设置了数量时生效]", _, true, 1.0, true, 100.0);
    NCvar[CSpecial_Hunter_Spawn_Weight]               = AutoExecConfig_CreateConVar("Special_Hunter_Spawn_Weight", "50", "Hunter刷新概率[范围1-100|当其他特感也设置了数量时生效]", _, true, 1.0, true, 100.0);
    NCvar[CSpecial_Spitter_Spawn_Weight]              = AutoExecConfig_CreateConVar("Special_Spitter_Spawn_Weight", "50", "Spitter刷新概率[范围1-100|当其他特感也设置了数量时生效]", _, true, 1.0, true, 100.0);
    NCvar[CSpecial_Jockey_Spawn_Weight]               = AutoExecConfig_CreateConVar("Special_Jockey_Spawn_Weight", "50", "Jockey刷新概率[范围1-100|当其他特感也设置了数量时生效]", _, true, 1.0, true, 100.0);

    NCvar[CSpecial_Boomer_Spawn_DirChance]            = AutoExecConfig_CreateConVar("Special_Boomer_Spawn_DirChance", "50", "Boomer刷新方位概率，数值越大越容易刷在前方，数值越小越容易刷在后方[范围1-100|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, true, 100.0);
    NCvar[CSpecial_Smoker_Spawn_DirChance]            = AutoExecConfig_CreateConVar("Special_Smoker_Spawn_DirChance", "50", "Smoker刷新方位概率，数值越大越容易刷在前方，数值越小越容易刷在后方[范围1-100|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, true, 100.0);
    NCvar[CSpecial_Charger_Spawn_DirChance]           = AutoExecConfig_CreateConVar("Special_Charger_Spawn_DirChance", "50", "Charger刷新方位概率，数值越大越容易刷在前方，数值越小越容易刷在后方[范围1-100|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, true, 100.0);
    NCvar[CSpecial_Hunter_Spawn_DirChance]            = AutoExecConfig_CreateConVar("Special_Hunter_Spawn_DirChance", "50", "Hunter刷新方位概率，数值越大越容易刷在前方，数值越小越容易刷在后方[范围1-100|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, true, 100.0);
    NCvar[CSpecial_Spitter_Spawn_DirChance]           = AutoExecConfig_CreateConVar("Special_Spitter_Spawn_DirChance", "50", "Spitter刷新方位概率，数值越大越容易刷在前方，数值越小越容易刷在后方[范围1-100|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, true, 100.0);
    NCvar[CSpecial_Jockey_Spawn_DirChance]            = AutoExecConfig_CreateConVar("Special_Jockey_Spawn_DirChance", "50", "Jockey刷新方位概率，数值越大越容易刷在前方，数值越小越容易刷在后方[范围1-100|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, true, 100.0);

    NCvar[CSpecial_Boomer_Spawn_Area]                 = AutoExecConfig_CreateConVar("Special_Boomer_Spawn_Area", "1", "Boomer刷新区域，0为产生在官方区域，1为产生在任何区域[仅梦魇、炼狱、可变模式有效]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_Smoker_Spawn_Area]                 = AutoExecConfig_CreateConVar("Special_Smoker_Spawn_Area", "1", "Smoker刷新区域，0为产生在官方区域，1为产生在任何区域[仅梦魇、炼狱、可变模式有效]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_Charger_Spawn_Area]                = AutoExecConfig_CreateConVar("Special_Charger_Spawn_Area", "1", "Charger刷新区域，0为产生在官方区域，1为产生在任何区域[仅梦魇、炼狱、可变模式有效]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_Hunter_Spawn_Area]                 = AutoExecConfig_CreateConVar("Special_Hunter_Spawn_Area", "1", "Hunter刷新区域，0为产生在官方区域，1为产生在任何区域[仅梦魇、炼狱、可变模式有效]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_Spitter_Spawn_Area]                = AutoExecConfig_CreateConVar("Special_Spitter_Spawn_Area", "1", "Spitter刷新区域，0为产生在官方区域，1为产生在任何区域[仅梦魇、炼狱、可变模式有效]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_Jockey_Spawn_Area]                 = AutoExecConfig_CreateConVar("Special_Jockey_Spawn_Area", "1", "Jockey刷新区域，0为产生在官方区域，1为产生在任何区域[仅梦魇、炼狱、可变模式有效]", _, true, 0.0, true, 1.0);

    NCvar[CSpecial_Boomer_Spawn_MaxDis]               = AutoExecConfig_CreateConVar("Special_Boomer_Spawn_MaxDis", "2000", "Boomer刷新最大距离[范围不能小于1|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, false);
    NCvar[CSpecial_Smoker_Spawn_MaxDis]               = AutoExecConfig_CreateConVar("Special_Smoker_Spawn_MaxDis", "2000", "Smoker刷新最大距离[范围不能小于1|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, false);
    NCvar[CSpecial_Charger_Spawn_MaxDis]              = AutoExecConfig_CreateConVar("Special_Charger_Spawn_MaxDis", "2000", "Charger刷新最大距离[范围不能小于1|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, false);
    NCvar[CSpecial_Hunter_Spawn_MaxDis]               = AutoExecConfig_CreateConVar("Special_Hunter_Spawn_MaxDis", "2000", "Hunter刷新最大距离[范围不能小于1|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, false);
    NCvar[CSpecial_Spitter_Spawn_MaxDis]              = AutoExecConfig_CreateConVar("Special_Spitter_Spawn_MaxDis", "2000", "Spitter刷新最大距离[范围不能小于1|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, false);
    NCvar[CSpecial_Jockey_Spawn_MaxDis]               = AutoExecConfig_CreateConVar("Special_Jockey_Spawn_MaxDis", "2000", "Jockey刷新最大距离[范围不能小于1|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, false);

    NCvar[CSpecial_Boomer_Spawn_MinDis]               = AutoExecConfig_CreateConVar("Special_Boomer_Spawn_MinDis", "500", "Boomer刷新最小距离[范围不能小于1|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, false);
    NCvar[CSpecial_Smoker_Spawn_MinDis]               = AutoExecConfig_CreateConVar("Special_Smoker_Spawn_MinDis", "500", "Smoker刷新最小距离[范围不能小于1|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, false);
    NCvar[CSpecial_Charger_Spawn_MinDis]              = AutoExecConfig_CreateConVar("Special_Charger_Spawn_MinDis", "500", "Charger刷新最小距离[范围不能小于1|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, false);
    NCvar[CSpecial_Hunter_Spawn_MinDis]               = AutoExecConfig_CreateConVar("Special_Hunter_Spawn_MinDis", "500", "Hunter刷新最小距离[范围不能小于1|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, false);
    NCvar[CSpecial_Spitter_Spawn_MinDis]              = AutoExecConfig_CreateConVar("Special_Spitter_Spawn_MinDis", "500", "Spitter刷新最小距离[范围不能小于1|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, false);
    NCvar[CSpecial_Jockey_Spawn_MinDis]               = AutoExecConfig_CreateConVar("Special_Jockey_Spawn_MinDis", "500", "Jockey刷新最小距离[范围不能小于1|仅梦魇、炼狱、可变模式有效]", _, true, 1.0, false);

    NCvar[CSpecial_Spawn_MaxDis]                      = AutoExecConfig_CreateConVar("Special_Spawn_MaxDis", "1500", "全部特感刷新最大距离[范围不能小于1|仅导演和普通模式有效]", _, true, 1.0, false);
    NCvar[CSpecial_Spawn_MinDis]                      = AutoExecConfig_CreateConVar("Special_Spawn_MinDis", "500", "全部特感刷新最小距离[范围不能小于1|仅导演和普通模式有效]", _, true, 1.0, false);

    NCvar[CSpecial_Catch_FastPlayer]                  = AutoExecConfig_CreateConVar("Special_Catch_FastPlayer", "1", "[0=关|1=开]禁用/启用在跑的最快的玩家身边刷特[建议开着就好]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_Catch_FastPlayer_CheckDistance]    = AutoExecConfig_CreateConVar("Special_Catch_FastPlayer_CheckDistance", "200.0", "最快的玩家与平均队伍之间相隔多远时开始在他身边刷特，数值请带小数点", _, true, 100.0, true, 10000.0);

    NCvar[CSpecial_Catch_SlowestPlayer]               = AutoExecConfig_CreateConVar("Special_Catch_SlowestPlayer", "0", "[0=关|1=开]禁用/启用在跑的最慢的玩家身边刷特[建议慎用]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_Catch_SlowestPlayer_CheckDistance] = AutoExecConfig_CreateConVar("Special_Catch_SlowestPlayer_CheckDistance", "400.0", "最慢的玩家与平均队伍之间相隔多远时开始在他身边刷特给他一波送走，有可能会误伤回去救助的队友，慎用，数值请带小数点", _, true, 100.0, true, 10000.0);

    NCvar[CSpecial_Check_IsPlayerNotInCombat]         = AutoExecConfig_CreateConVar("Special_Check_IsPlayerNotInCombat", "0", "[0=关|1=开]禁用/启用在摸鱼的玩家身边刷特[仅供测试]", _, true, 0.0, true, 1.0);

    NCvar[CSpecial_Check_IsPlayerBiled]               = AutoExecConfig_CreateConVar("Special_Check_IsPlayerBiled", "0", "[0=关|1=开]禁用/启用让某些特感注重攻击被胖子喷一脸的玩家", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_Check_IsPlayerBiled_Time]          = AutoExecConfig_CreateConVar("Special_Check_IsPlayerBiled_Time", "1.5", "检查玩家是否被喷一脸的间隔，单位秒，间隔越低性能消耗越大精度越准确，不需要的可以不开该功能[0.1s-2.0s]", _, true, 0.1, true, 2.0);

    NCvar[CSpecial_Attack_PlayerNotInCombat]          = AutoExecConfig_CreateConVar("Special_Attack_PlayerNotInCombat", "0", "[0=关|1=开]禁用/启用特感主动攻击摸鱼玩家[仅供测试]", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_Attack_PlayerNotInCombat_Time]     = AutoExecConfig_CreateConVar("Special_Attack_PlayerNotInCombat_Time", "6", "检查玩家是否一直处于摸鱼状态，达到指定秒数，将让其中一只特感目标设置为该玩家，Special_Attack_PlayerNotInCombat启用后才生效[3-15秒]", _, true, 3.0, true, 15.0);

    NCvar[CSpecial_PauseOnDown]                     = AutoExecConfig_CreateConVar("Special_PauseOnDown", "0", "[0=关|1=开]达到指定倒地人数后暂停刷特", _, true, 0.0, true, 1.0);
    NCvar[CSpecial_DownCount]                       = AutoExecConfig_CreateConVar("Special_DownCount", "1", "达到多少名幸存者倒地后暂停刷特[1-4]", _, true, 1.0, true, 4.0);

    NCvar[CGame_Difficulty]                           = FindConVar("z_difficulty");

    AutoExecConfig_OnceExec();

    HookEventEx("round_start", OnRoundStart);
    HookEventEx("tank_spawn", OnTankSpawn, EventHookMode_Pre);
    HookEventEx("tank_killed", OnTankDeath, EventHookMode_PostNoCopy);
    HookEventEx("player_death", OnPlayerDeath);
    HookEventEx("player_spawn", OnPlayerSpawn);
    HookEventEx("player_incapacitated", OnPlayerIncapacitated);
    HookEventEx("revive_success", OnReviveSuccess);
    HookEventEx("mission_lost", OnRoundEnd);
    HookEventEx("round_end", OnRoundEnd);
    HookEventEx("player_team", player_team);
    HookEventEx("player_disconnect", OnPlayerDisconnect, EventHookMode_Pre);

    RequestFrame(SetCvarHook);
    RequestFrame(SetAISpawnInit);

    AddCommandListener(ChatListener, "say");
    AddCommandListener(ChatListener, "say2");
    AddCommandListener(ChatListener, "say_team");

    RegAdminCmd("sm_nekotg", OpenSpecialMenu, ADMFLAG_ROOT, "打开Neko多特管理员菜单");
    RegAdminCmd("sm_tgadmin", OpenSpecialMenu, ADMFLAG_ROOT, "打开Neko多特管理员菜单");
    RegAdminCmd("sm_ntg", OpenSpecialMenu, ADMFLAG_ROOT, "打开Neko多特管理员菜单");
    RegAdminCmd("sm_tgmenu", OpenSpecialMenu, ADMFLAG_ROOT, "打开Neko多特管理员菜单");
    RegAdminCmd("sm_ntgversion", SpecialVersionCMD, ADMFLAG_ROOT, "Neko多特版本&状态查询");
    RegAdminCmd("sm_reloadntgconfig", ReloadNTGConfig, ADMFLAG_ROOT, "重载多特配置文件");
    RegAdminCmd("sm_updatentgconfig", UpdateNTGConfig, ADMFLAG_ROOT, "写入多特配置文件");
    RegAdminCmd("sm_resetntgconfig", ReSetNTGConfig, ADMFLAG_ROOT, "重置多特配置文件");
}

#include "nspecials/native.sp"
#include "nspecials/cmd.sp"
#include "nspecials/hooks.sp"
#include "nspecials/menus.sp"
#include "nspecials/events.sp"
#include "nspecials/timer.sp"
#include "nspecials/frame.sp"
#include "nspecials/api.sp"

public void OnConfigsExecuted()
{
    SetAISpawnInit();
    TgModeStartSet();
    UpdateSpawnWeight();
    UpdateSpawnDirChance();
    UpdateSpawnArea();
    UpdateSpawnDistance();

    for (int i = 1; i <= MaxClients; i++)
    {
        CheckBiledTime[i] = 0.0;
        CheckFreeTime[i]  = 0.0;
        CheckNotCombat[i] = 0;
        N_ClientItem[i].Reset();
        N_ClientMenu[i].Reset(true);
    }
}

// Try to fix lag when specials spawn at first time.
public void OnMapStart()
{
    CreateTimer(0.1, Timer_SpawnFakeClient);
}

public void OnMapEnd()
{
    g_DownedPauseActive = false;
    SetSpecialRunning(false);
    IsPlayerLeftCP = false;
    if (g_hPlayerLeftTimer != null)
    {
        delete g_hPlayerLeftTimer;
        g_hPlayerLeftTimer = null;
    }
    if (g_hSetMaxSpecialsTimer != null)
    {
        delete g_hSetMaxSpecialsTimer;
        g_hSetMaxSpecialsTimer = null;
    }
    SetSpecialSpawnClient(0);
}

public void DifficultyChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    CheckDifficulty();
}

public void HookChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    UpdateNekoAllSettings();
}

void SetCvarHook()
{
    NCvar[CGame_Difficulty].AddChangeHook(DifficultyChanged);

    for (int i = 1; i < Cvar_Max; i++)
    {
        if (i == CGame_Difficulty)
            continue;

        NCvar[i].AddChangeHook(HookChanged);
    }
}