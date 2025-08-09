
void CheckDifficulty(bool ShowTips = true)
{
    Call_StartForward(N_Forward_OnSetSpecialsTime);

    if (NCvar[CSpecial_Spawn_Time_DifficultyChange].BoolValue)
    {
        char NowDifficulty[64];
        NCvar[CGame_Difficulty].GetString(NowDifficulty, sizeof(NowDifficulty));

        if (strcmp(NowDifficulty, "Easy") == 0)
            SetSpecialRespawnInterval(NCvar[CSpecial_Spawn_Time_Easy].IntValue);
        else if (strcmp(NowDifficulty, "Normal") == 0)
            SetSpecialRespawnInterval(NCvar[CSpecial_Spawn_Time_Normal].IntValue);
        else if (strcmp(NowDifficulty, "Hard") == 0)
            SetSpecialRespawnInterval(NCvar[CSpecial_Spawn_Time_Hard].IntValue);
        else if (strcmp(NowDifficulty, "Impossible") == 0)
            SetSpecialRespawnInterval(NCvar[CSpecial_Spawn_Time_Impossible].IntValue);
    }
    else
        SetSpecialRespawnInterval(NCvar[CSpecial_Spawn_Time].IntValue);

    Call_Finish();

    if (ShowTips)
        InfectedTips();
}

void SetAISpawnInit()
{
    SetSpecialSpawnWay(NCvar[CSpecial_SpawnWay].IntValue);
    SetSpecialAssault(NCvar[CSpecial_Fast_Response].BoolValue);
    SetSpecialSpawnMode(NCvar[CSpecial_Spawn_Mode].IntValue);

    if (NCvar[CSpecial_CanCloseDirector].BoolValue)
    {
        if (GetSpecialSpawnMode() == 0)
            FindConVar("director_no_specials").SetInt(0, true, false);
        else
            FindConVar("director_no_specials").SetInt(1, true, false);
    }
}

void SwitchRandom(int client)
{
    if (NCvar[CSpecial_Random_Mode].BoolValue)
    {
        PrintToChat(client, "\x05%s \x04关闭了随机特感", NEKOTAG);
        NCvar[CSpecial_Random_Mode].SetBool(false);
    }
    else
    {
        PrintToChat(client, "\x05%s \x04开启了随机特感", NEKOTAG);
        NCvar[CSpecial_Random_Mode].SetBool(true);
    }
    TgModeStartSet();
}

void SwitchPlugin(int client)
{
    if (NCvar[CSpecial_PluginStatus].BoolValue)
    {
        PrintToChat(client, "\x05%s \x04关闭了NS特感插件", NEKOTAG);
        NCvar[CSpecial_PluginStatus].SetBool(false);
        SetSpecialRunning(false);
        if (NCvar[CSpecial_CanCloseDirector].BoolValue)
            FindConVar("director_no_specials").SetInt(1, true, false);
    }
    else
    {
        PrintToChat(client, "\x05%s \x04开启了NS特感插件", NEKOTAG);
        NCvar[CSpecial_PluginStatus].SetBool(true);
        SetSpecialRunning(true);
        if (NCvar[CSpecial_CanCloseDirector].BoolValue)
        {
            if (NCvar[CSpecial_Spawn_Mode].IntValue == 0)
                FindConVar("director_no_specials").SetInt(0, true, false);
            else
                FindConVar("director_no_specials").SetInt(1, true, false);
        }
    }
}

void TgModeStartSet(bool NeedSetNum = true)
{
    CheckDifficulty(false);
    SetSpecialSpawnSubMode(NCvar[CSpecial_IsModeInNormal].IntValue);

    ModeValue = NCvar[CSpecial_Default_Mode].IntValue;

    if (NCvar[CSpecial_Random_Mode].BoolValue)
        ModeValue = GetRandomInt(1, 7);

    if (NCvar[CSpecial_Show_Tips].BoolValue)
        ModeTips();

    int HunterNum, SmokerNum, BoomerNum, SpitterNum, JockeyNum, ChargerNum;

    switch (ModeValue)
    {
        case 1: ChargerNum = 31;
        case 2: BoomerNum = 31;
        case 3: SpitterNum = 31;
        case 4: SmokerNum = 31;
        case 5: JockeyNum = 31;
        case 6: HunterNum = 31;
        default:
        {
            HunterNum  = NCvar[CSpecial_Hunter_Num].IntValue;
            SmokerNum  = NCvar[CSpecial_Smoker_Num].IntValue;
            BoomerNum  = NCvar[CSpecial_Boomer_Num].IntValue;
            SpitterNum = NCvar[CSpecial_Spitter_Num].IntValue;
            JockeyNum  = NCvar[CSpecial_Jockey_Num].IntValue;
            ChargerNum = NCvar[CSpecial_Charger_Num].IntValue;
        }
    }

    SetSpecialSpawnLimit(HUNTER, HunterNum);
    SetSpecialSpawnLimit(CHARGER, ChargerNum);
    SetSpecialSpawnLimit(JOCKEY, JockeyNum);
    SetSpecialSpawnLimit(SPITTER, SpitterNum);
    SetSpecialSpawnLimit(BOOMER, BoomerNum);
    SetSpecialSpawnLimit(SMOKER, SmokerNum);

    if (NeedSetNum)
        SetMaxSpecialsCount(false);
}

void ModeTips()
{
    PrintToChatAll("\x05%s \x04现在是\x03 %s 模式", NEKOTAG, SpecialName[ModeValue]);
}

void InfectedTips()
{
    if (!IsMapRunning() || !NCvar[CSpecial_PluginStatus].BoolValue || !NCvar[CSpecial_Show_Tips].BoolValue)
        return;

    char tips[256];

    if (!NCvar[CSpecial_Show_Tips_Chat].BoolValue)
    {
        Format(tips, sizeof(tips), "%s模式，特感数量为 %d 特，刷新时间 %d", SpecialName[ModeValue], GetSpecialMax(), GetSpecialRespawnInterval());
        HUDShowMsg(tips);
    }
    else
    {
        Format(tips, sizeof(tips), "%s模式，特感数量为 \x03%d \x04特，刷新时间 \x03%d", SpecialName[ModeValue], GetSpecialMax(), GetSpecialRespawnInterval());
        PrintToChatAll("\x05%s \x04%s", NEKOTAG, tips);
    }
}

void SetMaxSpecialsCount(bool ShowTips = true)
{
    int Player_count;

    int oldtgnum = GetSpecialMax();

    int cultgnum = GetSpecialMax();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i))
            continue;

        if (NCvar[CSpecial_Num_NotCul_Death].BoolValue && !IsPlayerAlive(i))
            continue;

        if (NCvar[CSpecial_Num_NotCul_Bot].BoolValue && IsFakeClient(i))
            continue;

        if (GetClientTeam(i) == 2)
            ++Player_count;

        if (NCvar[CSpecial_PlayerCountSpec].BoolValue)
            if (GetClientTeam(i) == 1 && !IsClientIdle(i))
                ++Player_count;
    }

    if (Player_count > NCvar[CSpecial_PlayerNum].IntValue)
        cultgnum = NCvar[CSpecial_AddNum].IntValue * RoundToFloor(float((Player_count - NCvar[CSpecial_PlayerNum].IntValue) / NCvar[CSpecial_PlayerAdd].IntValue)) + NCvar[CSpecial_Num].IntValue;
    else
        cultgnum = NCvar[CSpecial_Num].IntValue;

    if (cultgnum > 32)
        cultgnum = 32;

    SetSpecialMax(cultgnum);

    if (ShowTips && NCvar[CSpecial_AddNum].IntValue > 0 && 0 < NCvar[CSpecial_Default_Mode].IntValue && (oldtgnum != cultgnum))
        CreateTimer(0.2, ShowTipsTimer);

    Call_StartForward(N_Forward_OnSetSpecialsNum);
    Call_Finish();
}

void UpdateSpawnWeight()
{
    SetSpecialSpawnWeight(HUNTER, NCvar[CSpecial_Hunter_Spawn_Weight].IntValue);
    SetSpecialSpawnWeight(SMOKER, NCvar[CSpecial_Smoker_Spawn_Weight].IntValue);
    SetSpecialSpawnWeight(BOOMER, NCvar[CSpecial_Boomer_Spawn_Weight].IntValue);
    SetSpecialSpawnWeight(SPITTER, NCvar[CSpecial_Spitter_Spawn_Weight].IntValue);
    SetSpecialSpawnWeight(JOCKEY, NCvar[CSpecial_Jockey_Spawn_Weight].IntValue);
    SetSpecialSpawnWeight(CHARGER, NCvar[CSpecial_Charger_Spawn_Weight].IntValue);
}

void UpdateSpawnDirChance()
{
    SetSpecialSpawnDirChance(HUNTER, NCvar[CSpecial_Hunter_Spawn_DirChance].IntValue);
    SetSpecialSpawnDirChance(SMOKER, NCvar[CSpecial_Smoker_Spawn_DirChance].IntValue);
    SetSpecialSpawnDirChance(BOOMER, NCvar[CSpecial_Boomer_Spawn_DirChance].IntValue);
    SetSpecialSpawnDirChance(SPITTER, NCvar[CSpecial_Spitter_Spawn_DirChance].IntValue);
    SetSpecialSpawnDirChance(JOCKEY, NCvar[CSpecial_Jockey_Spawn_DirChance].IntValue);
    SetSpecialSpawnDirChance(CHARGER, NCvar[CSpecial_Charger_Spawn_DirChance].IntValue);
}

void UpdateSpawnArea()
{
    SetSpecialSpawnArea(HUNTER, NCvar[CSpecial_Hunter_Spawn_Area].BoolValue);
    SetSpecialSpawnArea(SMOKER, NCvar[CSpecial_Smoker_Spawn_Area].BoolValue);
    SetSpecialSpawnArea(BOOMER, NCvar[CSpecial_Boomer_Spawn_Area].BoolValue);
    SetSpecialSpawnArea(SPITTER, NCvar[CSpecial_Spitter_Spawn_Area].BoolValue);
    SetSpecialSpawnArea(JOCKEY, NCvar[CSpecial_Jockey_Spawn_Area].BoolValue);
    SetSpecialSpawnArea(CHARGER, NCvar[CSpecial_Charger_Spawn_Area].BoolValue);
}

void UpdateSpawnDistance()
{
    SetSpecialSpawnMaxDis(HUNTER, NCvar[CSpecial_Hunter_Spawn_MaxDis].IntValue);
    SetSpecialSpawnMaxDis(SMOKER, NCvar[CSpecial_Smoker_Spawn_MaxDis].IntValue);
    SetSpecialSpawnMaxDis(BOOMER, NCvar[CSpecial_Boomer_Spawn_MaxDis].IntValue);
    SetSpecialSpawnMaxDis(SPITTER, NCvar[CSpecial_Spitter_Spawn_MaxDis].IntValue);
    SetSpecialSpawnMaxDis(JOCKEY, NCvar[CSpecial_Jockey_Spawn_MaxDis].IntValue);
    SetSpecialSpawnMaxDis(CHARGER, NCvar[CSpecial_Charger_Spawn_MaxDis].IntValue);

    SetSpecialSpawnMinDis(HUNTER, NCvar[CSpecial_Hunter_Spawn_MinDis].IntValue);
    SetSpecialSpawnMinDis(SMOKER, NCvar[CSpecial_Smoker_Spawn_MinDis].IntValue);
    SetSpecialSpawnMinDis(BOOMER, NCvar[CSpecial_Boomer_Spawn_MinDis].IntValue);
    SetSpecialSpawnMinDis(SPITTER, NCvar[CSpecial_Spitter_Spawn_MinDis].IntValue);
    SetSpecialSpawnMinDis(JOCKEY, NCvar[CSpecial_Jockey_Spawn_MinDis].IntValue);
    SetSpecialSpawnMinDis(CHARGER, NCvar[CSpecial_Charger_Spawn_MinDis].IntValue);

    SetSpecialSpawnMaxDis_(NCvar[CSpecial_Spawn_MaxDis].IntValue);
    SetSpecialSpawnMinDis_(NCvar[CSpecial_Spawn_MinDis].IntValue);
}

void UpdateNekoAllSettings()
{
    if (L4D2_IsTankInPlay() && !NCvar[CSpecial_Spawn_Tank_Alive].BoolValue)
        SetSpecialRunning(false);
    else
        SetSpecialRunning(NCvar[CSpecial_PluginStatus].BoolValue);
    SetAISpawnInit();
    TgModeStartSet(false);
    UpdateSpawnWeight();
    UpdateSpawnDirChance();
    UpdateSpawnArea();
    UpdateSpawnDistance();
    SetMaxSpecialsCount(true);
    LogMessage("[NS] Update Settings!!!");
}

stock void HUDShowMsg(char[] Message)
{
    if (HUDSlotIsUsed(HUD_MID_TOP))
        RemoveHUD(HUD_MID_TOP);
    HUDSetLayout(HUD_MID_TOP, HUD_FLAG_ALIGN_LEFT | HUD_FLAG_BLINK | HUD_FLAG_COUNTDOWN_WARN, Message);
    HUDPlace(HUD_MID_TOP, 0.2, 0.02, 0.6, 0.05);
    CreateTimer(5.0, KillHUDShow);
}

void UpdateConfigFile(bool NeedReset)
{
    AutoExecConfig_DeleteConfig();

    for (int i = 1; i < Cvar_Max; i++)
        AutoExecConfig_UpdateToConfig(NCvar[i], NeedReset);

    AutoExecConfig_OnceExec();
}