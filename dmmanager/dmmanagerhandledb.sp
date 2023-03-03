#include <dmmanager>

void initDataBase()
{
    char error[256]
    Handle handleError;

    db = SQL_Connect(NAME_DATABASE, false, error, sizeof(error));
    if (db == null) {
        PrintToServer("[DM_MANAGER]Failed to connect to database: %s", error);
        return;
    } else {
        PrintToServer("[DM_MANAGER]Connected to database");
    }
    handleError = SQL_Query(db, "CREATE TABLE IF NOT EXISTS `users` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `steam_id` TEXT, `kills` INTEGER, `deaths` INTEGER, `headshot_give` INTEGER,`headshot_received` INTEGER, `last_seen` DATETIME DEFAULT CURRENT_TIMESTAMP, `first_time_seen` DATETIME DEFAULT CURRENT_TIMESTAMP, `total_time` FLOAT DEFAULT 0)");
    if (CheckError("create table", handleError, true) == false)
        return;
    handleError = SQL_Query(db, "CREATE TABLE IF NOT EXISTS `bot_names` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT)");
    if (CheckError("create table", handleError, true) == false)
        return;
    handleError = SQL_Query(db, "CREATE TABLE IF NOT EXISTS `kills` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `weapon` TEXT, `killer_id` INTEGER, `victim_id` INTEGER, headshot BOOLEAN, datetime DATETIME DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(`killer_id`) REFERENCES `users`(`id`), FOREIGN KEY(`victim_id`) REFERENCES `users`(`id`))");
    if (CheckError("create table", handleError, true) == false)
        return;
    if (insertBotNames(handleError))
        return;
    db.Close();
}

bool insertBotNames(Handle handleError)
{
    handleError = SQL_Query(db, "SELECT * FROM `bot_names`");
    if (CheckError("select bot names", handleError, false) == false)
        return false;
    int rows = SQL_GetRowCount(handleError);
    if (rows == 0) {
        CloseHandle(handleError);
        handleError = SQL_Query(db, "INSERT INTO `bot_names` (`name`) VALUES ('name1'), ('name2'), ('name3'), ('name4'), ('name5'), ('name6'), ('name7'), ('name8'), ('name9'), ('name10'), ('name11'), ('name12'), ('name13'), ('name14'), ('name15'), ('name16'), ('name17'), ('name18'), ('name19'), ('name20')");
        if (CheckError("insert into bot_names", handleError, true) == false)
            return false;
    } else {
        PrintToServer("[DM_MANAGER]No need to insert");
        CloseHandle(handleError);
    }
    return true;
}

bool CheckError(char string[256], Handle handle, bool close)
{
    char error[256]

    if (handle == null) {
        SQL_GetError(db, error, sizeof(error))
        PrintToServer("[DM_MANAGER]Failed to %s: %s", string, error);
        if (close)
            CloseHandle(handle);
        return false;
    } else {
        if (close)
            CloseHandle(handle);
        return true;
    }
}

bool getBotName()
{
    Handle handleError = SQL_Query(db, "SELECT name FROM `bot_names`");

    if (CheckError("select bot names", handleError, false) == false)
        return false;
    int rows = SQL_GetRowCount(handleError);
    if (rows == 0) {
        PrintToServer("[DM_MANAGER]No bot names in database");
        return false;
    }
    for (int i = 0; i < rows; i++) {
        botStorage[i].assign = false;
        SQL_FetchRow(handleError);
        SQL_FetchString(handleError, 0, botStorage[i].name, MAX_BOTNAME_LENGTH);
        PrintToServer("[DM_MANAGER]Bot name %d: %s", i, botStorage[i].name);
    }
    CloseHandle(handleError);
    return true;
}

int getPlayerRank(int clientId)
{
    char query[256];
    Handle handleError;
    int rank;

    Format(query, sizeof(query), "SELECT * FROM `users` WHERE `kills` > (SELECT `kills` FROM `users` WHERE `id` = %d)", getDbId(clientId));
    handleError = SQL_Query(db, query);
    if (CheckError("select rank", handleError, false) == false)
        return -1;
    rank = SQL_GetRowCount(handleError);
    CloseHandle(handleError);
    return rank + 1;
}

void insertUserData(char steamId[32], int clientId)
{
    char query[256];
    Handle handleError;

    Format(query, sizeof(query), "INSERT INTO `users` (`steam_id`, `kills`, `deaths`, `headshot_give`, `headshot_received`) VALUES ('%s', 0, 0, 0, 0)", steamId);
    handleError = SQL_Query(db, query);
    if (CheckError("insert into users", handleError, false) == false)
        return;
    setUsersStorage(clientId, SQL_GetInsertId(handleError), steamId);
    CloseHandle(handleError);
    PrintToServer("[DM_MANAGER]Hello there, first time we see you !");
}

void manageUserInDb(char steamId[32], int clientId)
{
    Handle handleError;
    char query[256];
    char error[256]
    int rows;

    db = SQL_Connect(NAME_DATABASE, false, error, sizeof(error));
    if (db == null) {
        PrintToServer("[DM_MANAGER]Failed to connect to database: %s", error);
        return;
    } else {
        PrintToServer("[DM_MANAGER]Connected to database");
    }
    Format(query, sizeof(query), "SELECT * FROM `users` WHERE `steam_id` = '%s'", steamId);
    handleError = SQL_Query(db, query);
    if (CheckError("select users", handleError, false) == false)
        return;
    rows = SQL_GetRowCount(handleError);
    if (rows == 0)
        insertUserData(steamId, clientId);
    else {
        SQL_FetchRow(handleError);
        setUsersStorage(clientId, SQL_FetchInt(handleError, 0), steamId);
        PrintToServer("[DM_MANAGER]Welcome back !");
    }
    CloseHandle(handleError);
    setPlayerNameTop(clientId);
    db.Close();
}

void callbackFuncDefault(Handle owner, Handle hndl, const char[] error, any data)
{
    if (error[0] != '\0')
        PrintToServer("[DM_MANAGER]SQL Error: %s", error);
    if (hndl != INVALID_HANDLE)
        CloseHandle(hndl);
}

void setUsersStorage(int clientId, int idUser, char steamId[32])
{
    int i = 0;
    for (i = 0; usersStorage[i].assign == true; i++) {}

    usersStorage[i].assign = true;
    usersStorage[i].clientId = clientId;
    usersStorage[i].dbId = idUser;
    usersStorage[i].steamId = steamId;
    usersStorage[i].time = GetTime();
    usersStorage[i].rankIdPic = -1;
    setRanks(clientId);
}

