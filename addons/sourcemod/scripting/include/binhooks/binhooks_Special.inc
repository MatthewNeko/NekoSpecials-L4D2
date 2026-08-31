enum ZombieType {
  SMOKER = 0,
  BOOMER,
  HUNTER,
  SPITTER,
  JOCKEY,
  CHARGER,
};

/**
 * Gets limit of the Special.
 *
 * @return			Number to set Limit.
 * @no error
 */
native int GetSpecialSpawnLimit(ZombieType type);

/**
 * Sets limit of the Special.
 *
 * @param num			Number to set Limit.
 * @no return
 * @error				num < 0 , or num > 32.
 */
native void SetSpecialSpawnLimit(ZombieType type, int num);

/**
 * Gets Weight of the Special.
 *
 * @return			Number to set Weight.
 * @no error
 */
native int GetSpecialSpawnWeight(ZombieType type);

/**
 * Sets Weight of the Special.
 *
 * @param num			Number to set Weight.
 * @no return
 * @error				num < 0 , or num > 100.
 */
native void SetSpecialSpawnWeight(ZombieType type, int num);

/**
 * Gets spawn special's max distance of the from Special to survivor.
 * only (mode=2 and sub_mode=2) or (mode=3 and sub_mode=3) or mode = 4 is valid.
 *
 * @return			Number to set distance.
 * @no error
 */
native int GetSpecialSpawnMaxDis(ZombieType type);

/**
 * Sets spawn special's max distance of the from Special to survivor.
 * only (mode=2 and sub_mode=2) or (mode=3 and sub_mode=3) or mode = 4 is valid.
 *
 * @param num			Number to set distance.
 * @no return
 * @error				num < 0.
 */
native void SetSpecialSpawnMaxDis(ZombieType type, int dis);

/**
 * Gets spawn special's min distance of the from Special to survivor.
 * only (mode=2 and sub_mode=2) or (mode=3 and sub_mode=3) or mode = 4 is valid.
 *
 * @return			Number to set distance.
 * @no error
 */
native int GetSpecialSpawnMinDis(ZombieType type);

/**
 * Sets spawn special's min distance of the from Special to survivor.
 * only (mode=2 and sub_mode=2) or (mode=3 and sub_mode=3) or mode = 4 is valid.
 *
 * @param num			Number to set distance.
 * @no return
 * @error				num < 0.
 */
native void SetSpecialSpawnMinDis(ZombieType type, int dis);

/**
 * Gets spawn special's max distance of the from Special to survivor.
 * only mode=0 or mode=1 is valid.
 *
 * @return			Number to set distance.
 * @no error
 */
stock int GetSpecialSpawnMaxDis_() {
  return GetConVarInt(FindConVar("z_spawn_range"));
}

/**
 * Sets spawn special's max distance of the from Special to survivor.
 *
 * only mode=0 or mode=1 is valid.
 * @param num			Number to set distance.
 * @no return
 * @error				num < 0.
 */
stock void SetSpecialSpawnMaxDis_(int max) {
  int flags3 = (FindConVar("z_spawn_range")).Flags;
  SetConVarBounds(FindConVar("z_spawn_range"), ConVarBound_Upper, false);
  SetConVarFlags(FindConVar("z_spawn_range"), flags3 & ~FCVAR_NOTIFY);

  SetConVarInt(FindConVar("z_spawn_range"), max);
}

/**
 * Gets spawn special's max default distance of the from Special to survivor.
 * only mode=0 or mode=1 is valid.
 *
 * @return			Number to set distance.
 * @no error
 */
stock int GetSpecialSpawnMaxDis_default() {
  int oldvalue = GetSpecialSpawnMaxDis_();
  SetSpecialSpawnMaxDis_default();
  int value = GetSpecialSpawnMaxDis_();
  SetSpecialSpawnMaxDis_(oldvalue);
  return value;
}

/**
 * Sets spawn special's max default distance of the from Special to survivor.
 *
 * only mode=0 or mode=1 is valid.
 * @no return
 * @error				no error.
 */
stock void SetSpecialSpawnMaxDis_default() {
  ResetConVar(FindConVar("z_spawn_range"), true, true);
}

/**
 * Gets spawn special's min distance of the from Special to survivor.
 * only mode=0 or mode=1 is valid.
 *
 * @return			Number to set distance.
 * @no error
 */
stock int GetSpecialSpawnMinDis_() {
  return GetConVarInt(FindConVar("z_spawn_safety_range"));
}

/**
 * Sets spawn special's min distance of the from Special to survivor.
 *
 * only mode=0 or mode=1 is valid.
 * @param num			Number to set distance.
 * @no return
 * @error				num < 0.
 */
stock void SetSpecialSpawnMinDis_(int min) {
  int flags4 = FindConVar("z_spawn_safety_range").Flags;
  SetConVarBounds(FindConVar("z_spawn_safety_range"), ConVarBound_Upper, false);
  SetConVarFlags(FindConVar("z_spawn_safety_range"), flags4 & ~FCVAR_NOTIFY);

  SetConVarInt(FindConVar("z_spawn_safety_range"), min);
}

/**
 * Gets spawn special's max default distance of the from Special to survivor.
 * only mode=0 or mode=1 is valid.
 *
 * @return			Number to set distance.
 * @no error
 */
stock int GetSpecialSpawnMinDis_default() {
  int oldvalue = GetSpecialSpawnMinDis_();
  SetSpecialSpawnMinDis_default();
  int value = GetSpecialSpawnMinDis_();
  SetSpecialSpawnMaxDis_(oldvalue);
  return value;
}

/**
 * Sets spawn special's max default distance of the from Special to survivor.
 *
 * only mode=0 or mode=1 is valid.
 * @no return
 * @error				no error.
 */
stock void SetSpecialSpawnMinDis_default() {
  ResetConVar(FindConVar("z_spawn_safety_range"), true, true);
}

/**
 * Gets spawn special's direction Chance of the from Special to survivor.
 * only (mode=2 and sub_mode=2) or (mode=3 and sub_mode=3) or mode = 4 is valid.
 *
 * @return			chance to set direction.
 * @no error
 */
native int GetSpecialSpawnDirChance(ZombieType type);

/**
 * Sets spawn special's direction Chance of the from Special to survivor.
 * In genenal,Setting chance to 100 only spawn in front of survivor and chance
 * to 0 only spawn behind survivor. only (mode=2 and sub_mode=2) or (mode=3 and
 * sub_mode=3) or mode = 4 is valid.
 *
 * @param num			chance to set direction.
 * @no return
 * @error				chance < 0 or chance >100.
 */
native void SetSpecialSpawnDirChance(ZombieType type, int chance);

/**
 * Gets Spawn Area of the Special.
 * only (mode=2 and sub_mode=2) or (mode=3 and sub_mode=3) or mode = 4 is valid.
 *
 * @return			Number to set Area.
 * @no error
 */
native int GetSpecialSpawnArea(ZombieType type);

/**
 * Sets Spawn Area of the Special.
 * Setting Area to 0 for Official(engine) spawning area of the marked,Area to 1
 * for everywhere. only (mode=2 and sub_mode=2) or (mode=3 and sub_mode=3) or
 * mode = 4 is valid.
 *
 * @param num			Number to set Area.
 * @no return
 * @error				num < 0 , or num > 1.
 */
native void SetSpecialSpawnArea(ZombieType type, int num);

/**
 * Gets Spawn rely of Client of the Special.
 * only mode = 4 is valid.
 *
 * @return			rely of Client.
 * @no error
 */
native int GetSpecialSpawnClient();

/**
 * Sets the survivor target for the next spawn batch. Pass 0 to clear it.
 * only mode = 4 is valid.
 *
 * @param client		Survivor client index, or 0 to clear the override.
 * @no return
 * @error				Invalid survivor client.
 */
native void SetSpecialSpawnClient(int client);

/**
 * Gets Spawn Way of the Special.
 *
 *
 * @return			Way.
 * @no error
 */
native int GetSpecialSpawnWay();

/**
 * Sets Spawn Way of the Special.
 * way = 0 only all spawn together. way =1 spawn after special death
 *
 * @param num			Way.
 * @no return
 * @error				num>0 || num<1.
 */
native void SetSpecialSpawnWay(int way);

/**
 * Gets limit of the MaxSpecials.
 *
 * @return			Number to set Limit.
 * @no error
 */
native int GetSpecialMax();

/**
 * Sets limit of the MaxSpecials.
 *
 * @param num			Number to set Limit.
 * @no return
 * @error				num < 0 , or num > 32.
 */
native void SetSpecialMax(int num);

/**
 * Gets once again time of the Spawn.
 *
 * @return			Number to set time.
 * @no error
 */
native int GetSpecialRespawnInterval();

/**
 * Sets the  once again time of the Spawn.
 *
 * @param num 	timer to Limit.
 * @no return
 * @error				num < 0.
 */
native void SetSpecialRespawnInterval(int time);

/**
 * Gets Special Infected Assault.
 *
 * @return			Number to set Assault.
 * @no error
 */
native int GetSpecialAssault();

/**
 * Sets whether Special Infected Assault.
 *
 * @param num 	Yes:num = 1         No:num=0
 * @no return
 * @error				num < 0 or num > 1.
 */
native void SetSpecialAssault(bool num);

/**
 * Gets whether load auto SI function.
 *
 * @return			Number to set function.
 * @no error
 */
native int GetSpecialRunning();

/**
 * Sets whether load auto SI function.
 *
 * @param num 	Yes:num = 1         No:num=0
 * @no return
 * @error				num < 0 or num > 1.
 */
native void SetSpecialRunning(bool num);

/**
 * Gets various kinds of mode to spawn special...
 *
 * @return			Number to set mode.
 * @no error
 */
native int GetSpecialSpawnMode();

/**
 * Sets various kinds of mode to spawn special...
 *
 * @param mode 	Combine with  sub_mode;
 * @no return
 * @error				mode < 0 or mode > 4.
 */
native void SetSpecialSpawnMode(int mode);

/**
 * Gets various kinds of mode to spawn special...
 *
 * @return			Number to set sub_mode.
 * @no error
 */
native int GetSpecialSpawnSubMode();

/**
 * Sets various kinds of mode to spawn special...
 *
 * @param num 	Combine with mode;
 * @no return
 * @error				num < 1 or num > 2.
 */
native void SetSpecialSpawnSubMode(int sub_mode);

/**
 * Called when the BinHook manual Spawn Special.
 *
 *
 * @return  Plugin_Continue.
 * @error			No.
 */
forward Action BinHook_OnSpawnSpecial();