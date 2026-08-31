#define PLUGIN_VERSION "7.15NS"

// AdminMenu
/**
 * Returns Plugins Handle.
 *
 * @return				Plugins Handle.
 */
native Handle  NekoAdminMenu_PlHandle();

// KillHUD
/**
 * Returns Plugins Handle.
 *
 * @return				Plugins Handle.
 */
native Handle  NekoKillHud_PlHandle();

native bool	   NekoKillHud_GetStatus();

native int	   NekoKillHud_GetStyle();

// ServerName
/**
 * Returns Plugins Handle.
 *
 * @return				Plugins Handle.
 */
native Handle  NekoServerName_PlHandle();

forward Handle NekoServerName_OnChangeServerName();

/**
 * Change your custom Text.
 *
 * @param Text	        What you want to display.
 * @return				NULL.
 */
native void	   NekoServerName_ChangeCustomTest(const char[] Text);

// VoteMenu
/**
 * Returns Plugins Handle.
 *
 * @return				Plugins Handle.
 */
native Handle  NekoVote_PlHandle();

native bool	   NekoVote_VoteStatus();

// Specials
/**
 * Returns Plugins Handle.
 *
 * @return				Plugins Handle.
 */
native Handle  NekoSpecials_PlHandle();

/**
 * Returns Spawn Mode
 *
 * @return				Spawn Mode.
 */
native int	   NekoSpecials_GetSpawnMode();

/**
 * Returns Specials Num
 *
 * @return				Specials Num.
 */
native int	   NekoSpecials_GetSpecialsNum();

/**
 * Returns Specials Spawn Time
 *
 * @return				Specials Spawn Time.
 */
native int	   NekoSpecials_GetSpecialsTime();

/**
 * Returns Specials Mode
 *
 * @return				Specials Mode.
 */
native int	   NekoSpecials_GetSpecialsMode();

/**
 * Returns Plugin Status
 *
 * @return				Status.
 */
native bool	   NekoSpecials_GetPluginStatus();

/**
 * Show Specials Tips
 *
 * @return				NULL
 */
native void	   NekoSpecials_ShowSpecialsTips();

/**
 * Show Specials Mode Tips
 *
 * @return				NULL
 */
native void	   NekoSpecials_ShowSpecialsModeTips();

/**
 * Reload Specials Plugin Config
 *
 * @return				NULL
 */
native void	   NekoSpecials_ReLoadAllConfig();

/**
 * Get Specials Plugin ConVar
 *
 * @return				ConVar[]
 */
native ConVar  NekoSpecials_GetConVar(int ConVarNum);

/**
 * Show your custom tips.
 *
 * @param TipsFormat	What you want to display.
 * @return				NULL.
 */
native void	   NekoSpecials_ShowYourTips(const char[] TipsFormat);

forward Action NekoSpecials_OnSetSpecialsNum();

forward Action NekoSpecials_OnSetSpecialsTime();

forward Action NekoSpecials_OnStartFirstSpawn();