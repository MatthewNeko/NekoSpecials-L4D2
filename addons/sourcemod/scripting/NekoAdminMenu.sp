#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <adminmenu>
#include <neko/nekotools>
#include <neko/nekonative>

#define SPECIALS_AVAILABLE()   (GetFeatureStatus(FeatureType_Native, "NekoSpecials_GetSpecialsNum") == FeatureStatus_Available)
#define NKILLHUD_AVAILABLE()   (GetFeatureStatus(FeatureType_Native, "NekoKillHud_GetStatus") == FeatureStatus_Available)
#define VOTEMENU_AVAILABLE()   (GetFeatureStatus(FeatureType_Native, "NekoVote_VoteStatus") == FeatureStatus_Available)
#define SERVERNAME_AVAILABLE() (GetFeatureStatus(FeatureType_Native, "NekoServerName_PlHandle") == FeatureStatus_Available)

TopMenu		  top_menu = null;
TopMenuObject obj_dmcommands, hud_menu, specials_menu, voteadmin_menu, updateservername_option;

public Plugin myinfo =
{
	name		= "Neko Admin Menu",
	description = "Neko hud&specials&vote Admin Menu!",
	author		= "Neko Channel",
	version		= PLUGIN_VERSION,
	url			= "https://himeneko.cn/nekospecials"
	//请勿修改插件信息！
};

public void OnPluginStart()
{
	if (LibraryExists("adminmenu") && ((top_menu = GetAdminTopMenu()) != null))
		OnAdminMenuReady(top_menu);
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("nekoadminmenu");

	CreateNative("NekoAdminMenu_PlHandle", NekoAdminMenu_REPlHandle);

	MarkNativeAsOptional("NekoSpecials_GetSpecialsNum");
	MarkNativeAsOptional("NekoSpecials_GetSpecialsTime");
	MarkNativeAsOptional("NekoSpecials_GetSpawnMode");
	MarkNativeAsOptional("NekoSpecials_GetSpecialsMode");
	MarkNativeAsOptional("NekoSpecials_GetPluginStatus");
	MarkNativeAsOptional("NekoKillHud_GetStatus");
	MarkNativeAsOptional("NekoKillHud_GetStyle");
	MarkNativeAsOptional("NekoVote_VoteStatus");
	MarkNativeAsOptional("NekoServerName_PlHandle");

	return APLRes_Success;
}

public any NekoAdminMenu_REPlHandle(Handle plugin, int numParams)
{
	return GetMyHandle();
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "adminmenu", false))
		top_menu = null;
}

public void OnAdminMenuReady(Handle aTopMenu)
{
	TopMenu topmenu = TopMenu.FromHandle(aTopMenu);
	if (topmenu == top_menu && obj_dmcommands != INVALID_TOPMENUOBJECT) return;
	top_menu = topmenu;
	AddToTopMenu(topmenu, "nsmenu", TopMenuObject_Category, CategoryHandler, INVALID_TOPMENUOBJECT);

	TopMenuObject neko_menu = FindTopMenuCategory(top_menu, "nsmenu");
	if (neko_menu == INVALID_TOPMENUOBJECT) return;

	specials_menu			= AddToTopMenu(top_menu, "sm_ntg", TopMenuObject_Item, AdminMenu_Neko, neko_menu, "sm_ntg", ADMFLAG_ROOT);
	hud_menu				= AddToTopMenu(top_menu, "sm_nhud", TopMenuObject_Item, AdminMenu_Neko, neko_menu, "sm_nhud", ADMFLAG_ROOT);
	voteadmin_menu			= AddToTopMenu(top_menu, "sm_tgvoteadmin", TopMenuObject_Item, AdminMenu_Neko, neko_menu, "sm_tgvoteadmin", ADMFLAG_ROOT);
	updateservername_option = AddToTopMenu(top_menu, "sm_updateservername", TopMenuObject_Item, AdminMenu_Neko, neko_menu, "sm_updateservername", ADMFLAG_ROOT);
}

public void CategoryHandler(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int client, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayTitle)
		Format(buffer, maxlength, "+|NS|+ 功能菜单\n当前版本: %s", PLUGIN_VERSION);
	else if (action == TopMenuAction_DisplayOption)
		Format(buffer, maxlength, "+|NS|+ 功能菜单");
}

public void AdminMenu_Neko(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int client, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		if (object_id == specials_menu)
		{
			if (SPECIALS_AVAILABLE())
			{
				if (NekoSpecials_GetPluginStatus())
					Format(buffer, maxlength, "多特模块设置\n特感数量 [%d]\n刷特时间 [%d]\n现在模式 [%s]\n刷特模式 [%s]", NekoSpecials_GetSpecialsNum(), NekoSpecials_GetSpecialsTime(), SpecialName[NekoSpecials_GetSpecialsMode()], SpawnModeName[NekoSpecials_GetSpawnMode()]);
				else
					Format(buffer, maxlength, "多特模块设置\n插件状态 [已关闭]");
			}
			else
				Format(buffer, maxlength, "多特模块未安装");
		}
		else if (object_id == hud_menu)
		{
			if (NKILLHUD_AVAILABLE())
				Format(buffer, maxlength, "击杀统计设置\n插件样式 [%s]\n运行状态 [%s]", HudStyleName[NekoKillHud_GetStyle()], NekoKillHud_GetStatus() ? "运行中" : "未运行");
			else
				Format(buffer, maxlength, "统计模块未安装");
		}
		else if (object_id == voteadmin_menu)
		{
			if (VOTEMENU_AVAILABLE())
				Format(buffer, maxlength, "玩家投票设置\n投票状态 [%s]", NekoVote_VoteStatus() ? "开启" : "关闭");
			else if (!IsDedicatedServer())
				Format(buffer, maxlength, "投票模块不支持");
			else
				Format(buffer, maxlength, "投票模块未安装");
		}
		else if (object_id == updateservername_option)
		{
			if (SERVERNAME_AVAILABLE())
				Format(buffer, maxlength, "更新服务器名字");
			else
				Format(buffer, maxlength, "服名模块未安装");
		}
	}
	else if (action == TopMenuAction_SelectOption)
	{
		if (object_id == specials_menu)
			FakeClientCommand(client, "sm_ntg");
		else if (object_id == hud_menu)
			FakeClientCommand(client, "sm_nhud");
		else if (object_id == voteadmin_menu)
			FakeClientCommand(client, "sm_tgvoteadmin");
		else if (object_id == updateservername_option)
			FakeClientCommand(client, "sm_updateservername");
	}
}