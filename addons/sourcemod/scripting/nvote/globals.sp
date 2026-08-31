#define CSpecial_Fast_Response                     1
#define CSpecial_Spawn_Time                        2
#define CSpecial_Random_Mode                       3
#define CSpecial_Default_Mode                      4
#define CSpecial_Show_Tips                         5
#define CSpecial_Spawn_Tank_Alive                  6
#define CSpecial_Num                               7
#define CSpecial_AddNum                            8
#define CSpecial_PlayerAdd                         9
#define CSpecial_PlayerNum                         10
#define CSpecial_Spawn_Mode                        11
#define CSpecial_Boomer_Num                        12
#define CSpecial_Smoker_Num                        13
#define CSpecial_Charger_Num                       14
#define CSpecial_Hunter_Num                        15
#define CSpecial_Spitter_Num                       16
#define CSpecial_Jockey_Num                        17
#define CSpecial_AutoKill_StuckTank                18
#define CSpecial_LeftPoint_SpawnTime               19
#define CSpecial_PluginStatus                      20
#define CSpecial_Show_Tips_Chat                    21
#define CSpecial_PlayerCountSpec                   22
#define CSpecial_CanCloseDirector                  23
#define CGame_Difficulty                           24
#define CSpecial_Spawn_Time_DifficultyChange       25
#define CSpecial_Spawn_Time_Easy                   26
#define CSpecial_Spawn_Time_Normal                 27
#define CSpecial_Spawn_Time_Hard                   28
#define CSpecial_Spawn_Time_Impossible             29
#define CSpecial_IsModeInNormal                    30
#define CSpecial_Boomer_Spawn_Weight               31
#define CSpecial_Smoker_Spawn_Weight               32
#define CSpecial_Charger_Spawn_Weight              33
#define CSpecial_Hunter_Spawn_Weight               34
#define CSpecial_Spitter_Spawn_Weight              35
#define CSpecial_Jockey_Spawn_Weight               36
#define CSpecial_Boomer_Spawn_DirChance            37
#define CSpecial_Smoker_Spawn_DirChance            38
#define CSpecial_Charger_Spawn_DirChance           39
#define CSpecial_Hunter_Spawn_DirChance            40
#define CSpecial_Spitter_Spawn_DirChance           41
#define CSpecial_Jockey_Spawn_DirChance            42
#define CSpecial_Boomer_Spawn_Area                 43
#define CSpecial_Smoker_Spawn_Area                 44
#define CSpecial_Charger_Spawn_Area                45
#define CSpecial_Hunter_Spawn_Area                 46
#define CSpecial_Spitter_Spawn_Area                47
#define CSpecial_Jockey_Spawn_Area                 48
#define CSpecial_Boomer_Spawn_MaxDis               49
#define CSpecial_Smoker_Spawn_MaxDis               50
#define CSpecial_Charger_Spawn_MaxDis              51
#define CSpecial_Hunter_Spawn_MaxDis               52
#define CSpecial_Spitter_Spawn_MaxDis              53
#define CSpecial_Jockey_Spawn_MaxDis               54
#define CSpecial_Boomer_Spawn_MinDis               55
#define CSpecial_Smoker_Spawn_MinDis               56
#define CSpecial_Charger_Spawn_MinDis              57
#define CSpecial_Hunter_Spawn_MinDis               58
#define CSpecial_Spitter_Spawn_MinDis              59
#define CSpecial_Jockey_Spawn_MinDis               60
#define CSpecial_Spawn_MaxDis                      61
#define CSpecial_Spawn_MinDis                      62
#define CSpecial_Num_NotCul_Death                  63
#define CSpecial_Num_NotCul_Bot                    64
#define CSpecial_Spawn_Tank_Alive_Pro              65
#define CSpecial_AutoKill_StuckSpecials            66
#define CSpecial_Catch_FastPlayer                  67
#define CSpecial_Catch_FastPlayer_CheckDistance    68
#define CSpecial_Catch_SlowestPlayer               69
#define CSpecial_Catch_SlowestPlayer_CheckDistance 70
#define CSpecial_Check_IsPlayerNotInCombat         71
#define CSpecial_Check_IsPlayerBiled               72
#define CSpecial_Check_IsPlayerBiled_Time          73
#define CSpecial_SpawnWay                          74
#define CSpecial_Attack_PlayerNotInCombat          75
#define CSpecial_Attack_PlayerNotInCombat_Time     76
#define CSpecial_PauseOnDown                       77
#define CSpecial_DownCount                         78
#define GetCvar_Max                                79

#define Neko_CanSwitch                             1
#define Neko_SwitchStatus                          2
#define Neko_SwitchNumber                          3
#define Neko_SwitchTime                            4
#define Neko_SwitchRandom                          5
#define Neko_SwitchGameMode                        6
#define Neko_SwitchSpawnMode                       7
#define Neko_SwitchPlayerJoin                      8
#define Neko_SwitchTankAlive                       9
#define Neko_NeedResetNoPlayer                     10
#define Neko_NeedResetTime                         11
#define Neko_SwitchNumAdd                          12
#define Neko_SwitchPlayerAdd                       13
#define Neko_VotePassPercent                       14
#define Neko_VoteMinPlayers                        15
#define Neko_TimeMin                               16
#define Neko_TimeMax                               17
#define Neko_NumMin                                18
#define Neko_NumMax                                19
#define Neko_AddMin                                20
#define Neko_AddMax                                21
#define Neko_PlayerNumMin                          22
#define Neko_PlayerNumMax                          23
#define Neko_PlayerAddMin                          24
#define Neko_PlayerAddMax                          25
#define Neko_SwitchPauseOnDown                      26
#define Neko_SwitchDownCount                        27
#define Neko_DownCountMin                           28
#define Neko_DownCountMax                           29
#define Cvar_Max                                   30

ConVar NCvar[Cvar_Max], GCvar[GetCvar_Max];

int    MENU_TIME = 60;

int    MenuPageItem[MAXPLAYERS + 1], VoteMenuItemValue[MAXPLAYERS + 1], AdminMenuPageItem[MAXPLAYERS + 1];

char   VoteMenuItems[MAXPLAYERS + 1][512], WaitForVoteItems[MAXPLAYERS + 1][512], SubMenuVoteItems[MAXPLAYERS + 1][512];

bool   BoolWaitForVoteItems[MAXPLAYERS + 1];
bool   BoolWaitForAdminItems[MAXPLAYERS + 1];
char   AdminEditItems[MAXPLAYERS + 1][64];
char   AdminRangeItems[MAXPLAYERS + 1][32];

// A vote outlives its initiator's client slot. Keep an immutable snapshot so
// disconnect/reconnect cannot make VoteAction_End read another player's data.
bool   VoteSnapshotActive;
int    VoteSnapshotValue;
int    VoteSnapshotToken;
int    VoteSnapshotInitiatorUserId;
int    NextVoteSnapshotToken;
char   VoteSnapshotItem[64];
char   VoteSnapshotSubItem[16];
int    VoteSnapshotPassPercent;
Handle VoteSnapshotCleanupTimer;
Handle NoPlayerResetTimer;

Menu   N_MenuVoteMenu[MAXPLAYERS + 1], N_MenuAdminMenu[MAXPLAYERS + 1];
