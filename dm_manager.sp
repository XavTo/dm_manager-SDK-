#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>


#define MAX_PLAYER 10
#define MAX_BOTNAME_LENGTH 32

public Plugin:myinfo =
{
    name = "DM_Manager",
    author = "Artotototo",
    description = "DM_Manager",
    version = "1.0",
    url = "https://github.com/XavTo"
}

enum struct BotInfo
{
    int nbDeath;
    char name[MAX_BOTNAME_LENGTH];
    bool assign;
}

BotInfo botStorage[MAX_PLAYER];
Menu g_Menu;

public Action changeBotAttributes(Handle timer, int userId)
{
    int botId = GetClientOfUserId(userId);
    char buffer[32];

    if (botId > MAX_PLAYER + 1) {
        PrintToServer("Bot id %d is too high", botId);
        return Plugin_Continue;
    }
    if(!IsFakeClient(botId)) {
        GetClientName(botId, buffer, sizeof(buffer));
        PrintToServer("Player name %d: %s", botId, buffer);
        return Plugin_Continue;
    }
    for (int i = 0; i < MAX_PLAYER; i++) {
        if (botStorage[i].assign == false) {
            botStorage[i].assign = true;
            PrintToServer("Bot name %d: %s", botId, botStorage[i].name);
            SetClientName(botId, botStorage[i].name);
            break;
        }
    }
    return Plugin_Continue;
}

public Action giveWeaponToBot(Handle timer, int userId)
{
    int clientId = GetClientOfUserId(userId);

    if (IsFakeClient(clientId)) {
        if (GetClientTeam(clientId) == CS_TEAM_T)
            GivePlayerItem(clientId, "weapon_ak47");
        else 
            GivePlayerItem(clientId, "weapon_m4a1");
    } else {
        g_Menu.Display(clientId, 20);
    }
    return Plugin_Continue;
}

public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    CreateTimer(0.5, giveWeaponToBot, GetEventInt(event, "userid"));
    return Plugin_Continue;
}

public Action OnPlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
    CreateTimer(2.0, changeBotAttributes, GetEventInt(event, "userid"));
    return Plugin_Continue;
}

public Action OnPlayerKeyEvent(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetEventInt(event, "userid");
    int key = GetEventInt(event, "f");
    int down = GetEventInt(event, "down");
 
    if (key == 1 && down == 1) {
        g_Menu.Display(client, 20);
    }
    return Plugin_Continue;
}

public void OnPluginStart()
{
    Database db;

    PrintToServer("Hello World!");
    initDataBase("new_database", db);
    getBotName(db);
    createMenuWeapon();
    HookEvent("player_connect", OnPlayerConnect);
    HookEvent("player_spawn", OnPlayerSpawn);
    db.Close();
}

void initDataBase(char name[32], Database &db)
{
    char error[256]
    Handle handleError;
    db = SQL_Connect(name, false, error, sizeof(error));
    if (db == null) {
        PrintToServer("Failed to connect to database: %s", error);
        return;
    } else {
        PrintToServer("Connected to database");
    }
    handleError = SQL_Query(db, "CREATE TABLE IF NOT EXISTS `users` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT, `values` INTEGER)");
    if (CheckError("create table", db, handleError, true) == false)
        return;
    handleError = SQL_Query(db, "CREATE TABLE IF NOT EXISTS `bot_names` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT)");
    if (CheckError("create table", db, handleError, true) == false)
        return;
    handleError = SQL_Query(db, "SELECT * FROM `bot_names`");
    if (CheckError("select bot names", db, handleError, false) == false)
        return;
    int rows = SQL_GetRowCount(handleError);
    if (rows == 0) {
        handleError = SQL_Query(db, "INSERT INTO `bot_names` (`name`) VALUES ('name1'), ('name2'), ('name3'), ('name4'), ('name5'), ('name6'), ('name7'), ('name8'), ('name9'), ('name10')");
        if (CheckError("insert into bot_names", db, handleError, true) == false)
            return;
    } else {
        PrintToServer("No need to insert");
        CloseHandle(handleError);
    }
}

bool CheckError(char string[256], Database db, Handle handle, bool close)
{
    char error[256]

    if (handle == null) {
        SQL_GetError(db, error, sizeof(error))
        PrintToServer("Failed to %s: %s", string, error);
        if (close)
            CloseHandle(handle);
        return false;
    } else {
        PrintToServer("No error when %s", string);
        if (close)
            CloseHandle(handle);
        return true;
    }
}

bool getBotName(Database &db)
{
    Handle handleError = SQL_Query(db, "SELECT name FROM `bot_names`");

    if (CheckError("select bot names", db, handleError, false) == false)
        return false;
    int rows = SQL_GetRowCount(handleError);
    if (rows == 0) {
        PrintToServer("No bot names in database");
        return false;
    }
    for (int i = 0; i < rows; i++) {
        botStorage[i].assign = false;
        botStorage[i].nbDeath = 0;
        SQL_FetchRow(handleError);
        SQL_FetchString(handleError, 0, botStorage[i].name, MAX_BOTNAME_LENGTH);
        PrintToServer("Bot name %d: %s", i, botStorage[i].name);
    }
    CloseHandle(handleError);
    return true;
}

public int OnMenuSelection(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            switch (param2)
            {
                case 0:
                    GivePlayerItem(param1, "weapon_ak47");
                case 1:
                    GivePlayerItem(param1, "weapon_m4a1");
                case 2:
                    GivePlayerItem(param1, "weapon_m4a1_silencer");
                case 3:
                    GivePlayerItem(param1, "weapon_awp");
                case 4:
                    GivePlayerItem(param1, "weapon_deagle");
                
            }
            return 0;
        }
    }
    return 0;
}

void createMenuWeapon()
{
    g_Menu = CreateMenu(OnMenuSelection, MENU_ACTIONS_ALL);
    g_Menu.SetTitle("Choose your weapon");
    g_Menu.AddItem("AK47", "weapon_ak47", 0);
    g_Menu.AddItem("M4A4", "weapon_m4a1", 0);
    g_Menu.AddItem("M4A1-S", "weapon_m4a1_silencer", 0);
    g_Menu.AddItem("AWP", "weapon_awp", 0);
    g_Menu.AddItem("AWP", "weapon_deagle", 0);
}