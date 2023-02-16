#include <dmmanager>

void PrintUsersStorage()
{
    for (int i = 0; i < MAX_PLAYER; i++) {
        if (usersStorage[i].clientId == 0)
            continue;
        PrintToServer("usersStorage[%d].clientId = %d", i, usersStorage[i].clientId);
        PrintToServer("usersStorage[%d].dbId = %d", i, usersStorage[i].dbId);
        PrintToServer("usersStorage[%d].name = %s", i, usersStorage[i].steamId);
        PrintToServer("usersStorage[%d].mainWeapon = %s", i, usersStorage[i].mainWeapon);
    }
}

bool checkDefaultWeapon(int ind)
{
    if (strcmp(usersStorage[ind].secondaryWeapon, "weapon_hkp2000") == 0 || strcmp(usersStorage[ind].secondaryWeapon, "weapon_glock") == 0
        || strcmp(usersStorage[ind].secondaryWeapon, "weapon_usp_silencer") == 0 || strcmp(usersStorage[ind].secondaryWeapon, "") == 0)
        return true;
    return false;
}

int getIndIdBot(int botId)
{
    for (int i = 0; i < MAX_PLAYER; i++) {
        if (botStorage[i].botId == botId)
            return i;
    }
    return -1;
}

int getDbId(int id)
{
    if (id == 0)
        return -1;
    for (int i = 0; i < MAX_PLAYER; i++) {
        if (usersStorage[i].clientId == id)
            return usersStorage[i].dbId;
    }
    return -1;
}

int getIndId(int clientId)
{
    if (clientId == 0)
        return -1;
    for (int i = 0; i < MAX_PLAYER; i++) {
        if (usersStorage[i].clientId == clientId)
            return i;
    }
    return -1;
}

public Action checkSteamId(Handle timer, int userId)
{
    int botId = GetClientOfUserId(userId);
    char buffer[32];

    if (botId == 0)
        return Plugin_Continue;
    if (!IsFakeClient(botId)) {
        GetClientAuthId(botId, AuthId_SteamID64, buffer, sizeof(buffer));
        if (StrEqual(buffer, "") || StrEqual(buffer, "STEAM_ID_PENDING") || StrEqual(buffer, "STEAM_ID_STOP_IGNORING_RETVALS")) {
            PrintToServer("SteamId not found");
            KickClient(botId, "SteamId not found");
            return Plugin_Continue;
        }
        PrintToServer("SteamId found");
        manageUserInDb(buffer, botId, userId);
    }
    return Plugin_Continue;
}

public Action manageConnexion(Handle timer, int userId)
{
    int botId = GetClientOfUserId(userId);
    char buffer[32];

    if (botId == 0)
        return Plugin_Continue;
    if (botId > MAX_PLAYER + 1) {
        PrintToServer("Bot id %d is too high", botId);
        return Plugin_Continue;
    }
    if (!IsFakeClient(botId)) {
        GetClientAuthId(botId, AuthId_SteamID64, buffer, sizeof(buffer));
        if (StrEqual(buffer, "") || StrEqual(buffer, "STEAM_ID_PENDING") || StrEqual(buffer, "STEAM_ID_STOP_IGNORING_RETVALS")) {
            PrintToServer("SteamId not found");
            CreateTimer(10.0, checkSteamId, userId);
            return Plugin_Continue;
        }
        manageUserInDb(buffer, botId, userId);
        return Plugin_Continue;
    }
    for (int i = 0; i < MAX_PLAYER; i++) {
        if (botStorage[i].assign == false) {
            botStorage[i].assign = true;
            botStorage[i].botId = botId;
            SetClientName(botId, botStorage[i].name);
            break;
        }
    }
    return Plugin_Continue;
}

public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int clientId = GetClientOfUserId(GetEventInt(event, "userid"));
    int ind = getIndId(clientId);
    int indBot = getIndIdBot(clientId);

    if (clientId == 0) {
        PrintToServer("Client id is 0");
        return Plugin_Continue;
    }
    if (IsFakeClient(clientId)) {
        if (GetClientTeam(clientId) == CS_TEAM_T) {
            GivePlayerItem(clientId, "weapon_ak47");
            if (indBot == -1)
                return Plugin_Continue;
            botStorage[indBot].weapon = "weapon_ak47";
        }
        else {
            GivePlayerItem(clientId, "weapon_m4a1");
            if (indBot == -1)
                return Plugin_Continue;
            botStorage[indBot].weapon = "weapon_m4a1";
        }
    } else if (ind != -1) {
        if (strcmp(usersStorage[ind].mainWeapon, "") != 0)
            GivePlayerItem(clientId, usersStorage[ind].mainWeapon);
        if (strcmp(usersStorage[ind].secondaryWeapon, "") != 0) {
            RemovePlayerItem(clientId, GetEntPropEnt(clientId, Prop_Data, "m_hMyWeapons", 1));
            GivePlayerItem(clientId, usersStorage[ind].secondaryWeapon);
        } 
        if (GetClientTeam(clientId) != 0 && strcmp(usersStorage[ind].mainWeapon, "") == 0) {
            GetClientTeam(clientId) == CS_TEAM_T ? strcopy(usersStorage[ind].secondaryWeapon, SIZE_STRING_DEFAULT, "weapon_glock") :
                strcopy(usersStorage[ind].secondaryWeapon, SIZE_STRING_DEFAULT, "weapon_hkp2000");
            usersStorage[ind].secondaryWeaponAmmo = GetClientTeam(clientId) == CS_TEAM_T ?
                GLOCK_AMMO : (strcmp(usersStorage[ind].secondaryWeapon, "weapon_hkp2000") == 0 ? P2000_AMMO : USP_AMMO);
        }
        if (checkDefaultWeapon(ind) && strcmp(usersStorage[ind].mainWeapon, "") == 0) {
            weaponMenu.Display(clientId, MENU_DISPLAY_TIME);
        }
        if (usersStorage[ind].spawnSet)
            SetEntPropVector(usersStorage[ind].clientId, Prop_Data, "m_vecOrigin", usersStorage[ind].spawnPoint);
    } else {
        PrintUsersStorage();
        weaponMenu.Display(clientId, MENU_DISPLAY_TIME);
    }
    return Plugin_Continue;
}

public Action OnPlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
    CreateTimer(1.0, manageConnexion, GetEventInt(event, "userid"));
    return Plugin_Continue;
}

public Action OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int killerId = GetClientOfUserId(GetEventInt(event, "attacker"));
    int victimId = GetClientOfUserId(GetEventInt(event, "userid"));
    int headshot = GetEventInt(event, "headshot");
    int idUserDead = getDbId(GetClientOfUserId(GetEventInt(event, "userid")));
    int idUserKiller = getDbId(GetClientOfUserId(GetEventInt(event, "attacker")));
    char buffer[128];
    char error[128];
    char weaponName[32];
    
    if (killerId == 0 || victimId == 0 || (IsFakeClient(killerId) && IsFakeClient(victimId)) || (idUserDead == idUserKiller))
        return Plugin_Continue;
    GetClientWeapon(killerId, weaponName, sizeof(weaponName));
    db = SQL_Connect(NAME_DATABASE, false, error, sizeof(error));
    if (!IsFakeClient(killerId) && idUserKiller != -1) {
        if (headshot == 1)
            Format(buffer, sizeof(buffer), "UPDATE users SET kills = kills + 1, headshot_give = headshot_give + 1 WHERE id = %d", idUserKiller);
        else
            Format(buffer, sizeof(buffer), "UPDATE users SET kills = kills + 1 WHERE id = %d", idUserKiller);
        SQL_TQuery(db, callbackFuncDefault, buffer, 0, DBPrio_Normal);
        Format(buffer, sizeof(buffer), "INSERT INTO kills (weapon, killer_id, victim_id, headshot) VALUES ('%s', %d, %d, %d)",
            weaponName, idUserKiller, (idUserDead != -1 ? idUserDead : 0), headshot);
        SQL_TQuery(db, callbackFuncDefault, buffer, 0, DBPrio_Normal);
        SetEntProp(killerId, Prop_Send, "m_iHealth", 100);
        SetEntProp(GetEntPropEnt(killerId, Prop_Send, "m_hMyWeapons", 2), Prop_Send, "m_iClip1",
            usersStorage[getIndId(killerId)].mainWeaponAmmo + (strcmp(weaponName, usersStorage[getIndId(killerId)].mainWeapon) == 0 ? 1 : 0));
        if (strcmp(usersStorage[getIndId(killerId)].secondaryWeapon, "") != 0) {
            SetEntProp(GetEntPropEnt(killerId, Prop_Send, "m_hMyWeapons", 1), Prop_Send, "m_iClip1",
                usersStorage[getIndId(killerId)].secondaryWeaponAmmo + (strcmp(weaponName, usersStorage[getIndId(killerId)].secondaryWeapon) == 0 ? 1 : 0));
        }
        SetEntProp(killerId, Prop_Send, "m_ArmorValue", 100);
    }
    if (!IsFakeClient(victimId) && idUserDead != -1) {
        if (headshot == 1)
            Format(buffer, sizeof(buffer), "UPDATE users SET deaths = deaths + 1, headshot_received = headshot_received + 1 WHERE id = %d", idUserDead);
        else
            Format(buffer, sizeof(buffer), "UPDATE users SET deaths = deaths + 1 WHERE id = %d", idUserDead);
        SQL_TQuery(db, callbackFuncDefault, buffer, 0, DBPrio_Normal);
        Format(buffer, sizeof(buffer), "INSERT INTO kills (weapon, killer_id, victim_id, headshot) VALUES ('%s', %d, %d, %d)",
            weaponName, (idUserKiller != -1 ? idUserKiller : 0), idUserDead, headshot);
        SQL_TQuery(db, callbackFuncDefault, buffer, 0, DBPrio_Normal);
    }
    db.Close();
    return Plugin_Continue;
}

public Action OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
    int clientId = GetClientOfUserId(GetEventInt(event, "userid"));
    int dbInd = getDbId(clientId);
    int ind = getIndId(clientId);
    char query[128];
    char error [128];
    float totalTime = 0.0;

    if (dbInd == -1 || ind == -1 || IsFakeClient(clientId) || clientId == 0)
        return Plugin_Continue;
    PrintToServer("Disconnecting time : %d - %d", GetTime(), usersStorage[ind].time);
    totalTime = (GetTime() - usersStorage[ind].time) / 60.0;
    db = SQL_Connect(NAME_DATABASE, false, error, sizeof(error));
    if (db == null) {
        LogToFile("error", "Error while connecting to database: %s", error);
        PrintToServer("Can't save your data");
        return Plugin_Continue;
    }
    Format(query, sizeof(query), "UPDATE users SET total_time = total_time + %f, last_seen = CURRENT_TIMESTAMP WHERE id = %d", totalTime, dbInd);
    SQL_TQuery(db, callbackFuncDefault, query, 0, DBPrio_Normal);
    return Plugin_Continue;
}

void getArgs(const char[] string, char args[5][32])
{
    int i = 0;
    int j = 0;
    int k = 0;

    while (string[i] != '\0') {
        if (string[i] == ' ') {
            while (string[i] == ' ')
                i++;
            break;
        }
        i++;
    }
    if (string[i] == '\0')
        return;
    while (string[i] != '\0') {
        if (string[i] == ' ') {
            j++;
            k = 0;
            while (string[i] == ' ')
                i++;
        } else {
            args[j][k] = string[i];
            k++;
            i++;
        }
    }
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
    char args[5][32] = {"\0", "\0", "\0", "\0", "\0"};

    if (strcmp(sArgs, "/weapon", false) == 0 || strcmp(sArgs, "/weapons", false) == 0 || strcmp(sArgs, "/w", false) == 0 || strcmp(sArgs, "/gun", false) == 0
        || strcmp(sArgs, "/guns", false) == 0 || strcmp(sArgs, "/g", false) == 0) {
        PrintToServer("Display weapon menu");
        weaponMenu.Display(client, MENU_DISPLAY_TIME);
        return Plugin_Handled;
    }
    if (strcmp(sArgs, "/spawn", false) == 0) {
        PrintToServer("Display spawn menu");
        spawnMenu.Display(client, MENU_DISPLAY_TIME);
        return Plugin_Handled;
    }
    if (strcmp(sArgs, "/bot", false) == 0 || strcmp(sArgs, "/bots", false) == 0 || strcmp(sArgs, "/b", false) == 0) {
        PrintToServer("Display bot menu");
        botMenu.Display(client, MENU_DISPLAY_TIME);
        return Plugin_Handled;
    }
    if (strncmp(sArgs, "/stats", 6, false) == 0 || strncmp(sArgs, "/s", 2, false) == 0 || strncmp(sArgs, "/stat", 5, false) == 0) {
        getArgs(sArgs, args);
        displayStat(client, args);
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

void myHookEvent()
{
    PrintToServer("Hooking events");
    HookEvent("player_connect", OnPlayerConnect);
    HookEvent("player_spawn", OnPlayerSpawn);
    HookEvent("player_death", OnPlayerDeath);
    HookEvent("player_disconnect", OnPlayerDisconnect);
}