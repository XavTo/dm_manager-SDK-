#include <dmmanager>

WeaponInfo getPrefereWeapon(int client, bool pistol = false)
{
    int idDb = getDbId(client);
    Handle handleError;
    char error[256];
    char query[256];
    int rows = 0;
    char bufferName[32];
    WeaponInfo weaponInfo[33];
    WeaponInfo max = {"", 0, 0};

    strcopy(max.name, 32, pistol ? "weapon_glock" : "weapon_ak47");
    if (idDb == -1)
        return max;
    db = SQL_Connect(NAME_DATABASE, false, error, sizeof(error));
    if (db == null) {
        PrintHintText(client, "Failed to connect to database: %s", error);
        return max;
    }
    weaponInfoInit(weaponInfo);
    Format(query, sizeof(query), "SELECT * FROM `kills` WHERE `killer_id` = %d", idDb);
    handleError = SQL_Query(db, query);
    if (CheckError("select users", handleError, false) == false)
        return max;
    rows = SQL_GetRowCount(handleError);
    if (rows == 0)
        return max;
    for (int i = 0; i < rows; i++) {
        SQL_FetchRow(handleError);
        if (SQL_FetchString(handleError, 1, bufferName, sizeof(bufferName)) > 0) {
            if (pistol && (strcmp(bufferName, "weapon_p250") != 0 && strcmp(bufferName, "weapon_glock") != 0 && strcmp(bufferName, "weapon_deagle") != 0
                && strcmp(bufferName, "weapon_elite") != 0 && strcmp(bufferName, "weapon_tec9") != 0 && strcmp(bufferName, "weapon_fiveseven") != 0
                && strcmp(bufferName, "weapon_cz75a") != 0 && strcmp(bufferName, "weapon_revolver") != 0 && strcmp(bufferName, "weapon_hkp2000") != 0
                && strcmp(bufferName, "weapon_usp_silencer") != 0))
                continue;
            weaponInfoSet(weaponInfo, bufferName, SQL_FetchInt(handleError, 4));
        }
    }
    return weaponInfoGetMax(weaponInfo);
}

WeaponInfo weaponInfoGetMax(WeaponInfo weaponInfo[33])
{
    WeaponInfo max = {"No favorite weapon", 0, 0};

    for (int i = 1; i < 32; i++) {
        if (weaponInfo[i].kills > max.kills)
            max = weaponInfo[i];
    }
    return max;
}

WeaponInfo weaponInfoFindByName(WeaponInfo weaponInfo[33], char weaponName[32])
{
    char shortName[32];

    for (int i = 0; i < 32; i++) {
        if (strncmp(weaponName, "weapon_", 7, false) != 0) {
            strcopy(shortName, 32, "weapon_\0");
            StrCat(shortName, 32, weaponName);
            if (strcmp(weaponInfo[i].name, shortName, false) == 0)
                return weaponInfo[i];
        }
        if (strcmp(weaponInfo[i].name, weaponName, false) == 0)
            return weaponInfo[i];
    }
    weaponInfo[0].name = "Invalid weapon";
    return weaponInfo[0];
}

void weaponInfoSet(WeaponInfo weaponInfo[33], char weaponName[32], int hs)
{
    for (int i = 0; i < 32; i++) {
        if (strcmp(weaponInfo[i].name, weaponName) == 0) {
            weaponInfo[i].kills += 1;
            if (hs == 1)
                weaponInfo[i].hs += 1;
            return;
        }
    }
}

void weaponInfoInit(WeaponInfo weaponInfo[33])
{
    for (int i = 0; i < 33; i++) {
        strcopy(weaponInfo[i].name, SIZE_STRING_DEFAULT, listWeaponName[i]);
        weaponInfo[i].kills = 0;
        weaponInfo[i].hs = 0;
    }
}

void displayNoArgs(Handle handleError, WeaponInfo weaponInfo[33], int rows, int client)
{
    WeaponInfo max;
    char bufferName[32];
    int hs = 0;

    for (int i = 0; i < rows; i++) {
        SQL_FetchRow(handleError);
        if (SQL_FetchInt(handleError, 4) == 1)
            hs++;
        if (SQL_FetchString(handleError, 1, bufferName, sizeof(bufferName)) > 0)
            weaponInfoSet(weaponInfo, bufferName, SQL_FetchInt(handleError, 4));
    }
    max = weaponInfoGetMax(weaponInfo);
    ShowHudText(client, -1, "You have %d %s with %d %s (%.2f%%)\nFavorite weapon : %s\nYou have %d %s with %d %s (%.2f%%)",
        rows, rows > 1 ? "kills" : "kill", hs, hs > 1 ? "headshots" : "headshot", float(hs) / float(rows) * 100,
        max.name, max.kills, max.kills > 1 ? "kills" : "kill", max.hs, max.hs > 1 ? "headshots" : "headshot", float(max.hs) / float(max.kills) * 100)
}

void displayStatWeapon(Handle handleError, WeaponInfo weaponInfo, int rows, int client)
{
    char bufferName[32];

    for (int i = 0; i < rows; i++) {
        SQL_FetchRow(handleError);
        if (SQL_FetchString(handleError, 1, bufferName, sizeof(bufferName)) <= 0)
            continue;
        if (strcmp(bufferName, weaponInfo.name) == 0) {
            if (SQL_FetchInt(handleError, 4) == 1)
                weaponInfo.hs++;
            weaponInfo.kills++;
        }
    }
    ShowHudText(client, -1, "With %s you have %d %s with %d %s (%.2f%%)", weaponInfo.name,
        weaponInfo.kills, weaponInfo.kills > 1 ? "kills" : "kill", weaponInfo.hs, weaponInfo.hs > 1 ? "headshots" : "headshot", float(weaponInfo.hs) / float(weaponInfo.kills) * 100);
}

bool verifValidParamDate(char userDate[32])
{
    Regex date = new Regex("^[0-9]{4}[-/][0-9]{2}[-/][0-9]{2}(_[0-9]{2})?[:]?([0-9]{2})?[:]?([0-9]{2})?$");

    if (date.Match(userDate) <= 0)
        return false;
    return true;
}

void parseDate(char date[32], char userDate[32])
{
    int i = 0;
    int time = 0;

    while (date[i] != '\0') {
        if (date[i] == '/' || date[i] == '-')
            userDate[i] = '-';
        else if (date[i] == ':') {
            time++;
            userDate[i] = date[i];
        } else if (date[i] == '_') {
            time++;
            userDate[i] = ' ';
        }
        else
            userDate[i] = date[i];
        i++;
    }
    while (time < 3) {
        i += StrCat(userDate, 32, time == 0 ? " 00" : ":00");
        time++;
    }
    userDate[i] = '\0';
}

bool compareNumber(int a, int b, bool sens)
{
    if (sens)
        return a > b;
    return a < b;
}

int compareDate(char []userDate, char []userDateEnd, char []dbDate, bool sens = false)
{
    int i = 0;

    while (userDate[i] != '\0') {
        if ((userDate[i] == ':') || (userDate[i] == '-') || (userDate[i] == ' ')) {
            i++;
        } else {
            if (compareNumber(StringToInt(userDate[i]), StringToInt(dbDate[i]), sens))
                return (userDateEnd[0] != '\0' ? compareDate(userDateEnd, "\0", dbDate, true) : 1)
            else if (compareNumber(StringToInt(userDate[i]), StringToInt(dbDate[i]), !sens))
                return -1;
            while (userDate[i] != ':' && userDate[i] != '-' && userDate[i] != '\0')
                i++;
        }
    }
    return (userDateEnd[0] != '\0' ? compareDate(userDateEnd, "\0", dbDate, true) : 0);
}

void displayStatDate(Handle handleError, WeaponInfo weaponInfo[33], char date[32], char dateEnd[32], int client, char weaponName[32])
{
    char dbDate[32];
    char userDate[32];
    char userDateEnd[32];
    char bufferName[32];
    int hs = 0;
    int kills = 0;
    bool isWeapon = strcmp(weaponName, "\0") != 0 ? true : false;
    int rows = SQL_GetRowCount(handleError);
    WeaponInfo max;

    if (isWeapon)
        max = weaponInfoFindByName(weaponInfo, weaponName);
    parseDate(date, userDate);
    if (dateEnd[0] != '\0')
        parseDate(dateEnd, userDateEnd);
    for (int i = 0; i < rows; i++) {
        SQL_FetchRow(handleError);
        if (SQL_FetchString(handleError, 1, bufferName, sizeof(bufferName)) <= 0)
            continue;
        if (isWeapon) {
            if (strcmp(bufferName, max.name) != 0)
                continue;
        }
        if (SQL_FetchString(handleError, 5, dbDate, sizeof(dbDate)) <= 0)
            continue;
        if (compareDate(userDate, userDateEnd, dbDate) >= 0) {
            kills++;
            if (SQL_FetchInt(handleError, 4) == 1)
                hs++;
            weaponInfoSet(weaponInfo, bufferName, SQL_FetchInt(handleError, 4));
        }
    }
    bufferName[0] = '\0';
    if (dateEnd[0] != '\0') {
        strcopy(bufferName, 32, " until ");
        StrCat(bufferName, 32, userDateEnd);
        StrCat(bufferName, 32, "\n");
    }
    if (!isWeapon) {
        max = weaponInfoGetMax(weaponInfo);
        ShowHudText(client, -1, "Since %s%s you have %d %s with %d %s (%.2f%%)\nFavorite weapon : %s\nYou have %d %s with %d %s (%.2f%%)",
            userDate, bufferName, kills, kills > 1 ? "kills" : "kill", hs, hs > 1 ? "headshots" : "headshot", float(hs) / float(kills) * 100,
            max.name, max.kills, max.kills > 1 ? "kills" : "kill", max.hs, max.hs > 1 ? "headshots" : "headshot", float(max.hs) / float(max.kills) * 100)
    } else {
        ShowHudText(client, -1, "Since %s%s with %s you have %d %s with %d %s (%.2f%%)\n",
            userDate, bufferName, weaponName, kills, kills > 1 ? "kills" : "kill", hs, hs > 1 ? "headshots" : "headshot", float(hs) / float(kills) * 100)
    }
}

void checkParametersStat(Handle handleError, WeaponInfo weaponInfo[33], int rows, char args[5][32], int client)
{
    bool date = false;
    bool dateEnd = false;
    bool weapon = false;
    int dateInd = 0;
    int weaponInd = 0;

    for (int ind = 0; ind < 5 && args[ind][0] != '\0'; ind++) {
        if (strcmp(args[ind], "help") == 0) {
            PrintHintText(client, "Usage : !stat weapon {weapon name} date {YYYY/MM/DD_HH:MM:SS - optional{date}}");
            return;
        }
        if (strcmp(args[ind], "weapon") == 0) {
            if (args[ind + 1][0] == '\0') {
                PrintHintText(client, "You must specify a weapon");
                return;
            }
            weaponInd = ind + 1;
            weapon = true;
        }
        if (strcmp(args[ind], "date") == 0) {
            if (verifValidParamDate(args[ind + 1]) == false) {
                PrintHintText(client, "You must specify a date (YYYY/MM/DD_HH:MM:SS)");
                return;
            }
            if (ind + 2 < 5 && args[ind + 2][0] != '\0' && verifValidParamDate(args[ind + 2]))
                dateEnd = true;
            dateInd = ind + 1;
            date = true;
        }
    }
    if (date == false && weapon == false) {
        PrintHintText(client, "Usage : /stat weapon {weapon name} date {YYYY/MM/DD_HH:MM:SS optional{date}}");
        return;
    }
    if (date == true)
        displayStatDate(handleError, weaponInfo, args[dateInd], dateEnd ? args[dateInd + 1] : "\0", client, weapon ? args[weaponInd] : "\0");
    else
        displayStatWeapon(handleError, weaponInfoFindByName(weaponInfo, args[weaponInd]), rows, client);
}

void displayStat(int client, char args[5][32])
{
    int idDb = getDbId(client);
    Handle handleError;
    char error[256];
    char query[256];
    int rows = 0;
    WeaponInfo weaponInfo[33];

    if (idDb == -1)
        return;
    db = SQL_Connect(NAME_DATABASE, false, error, sizeof(error));
    if (db == null) {
        PrintHintText(client, "Failed to connect to database: %s", error);
        return;
    }
    weaponInfoInit(weaponInfo);
    Format(query, sizeof(query), "SELECT * FROM `kills` WHERE `killer_id` = %d", idDb);
    handleError = SQL_Query(db, query);
    if (CheckError("select users", handleError, false) == false)
        return;
    rows = SQL_GetRowCount(handleError);
    if (rows == 0) {
        PrintHintText(client, "You have no kills");
        return;
    }
    if (args[0][0] == '\0')
        displayNoArgs(handleError, weaponInfo, rows, client);
    else {
        checkParametersStat(handleError, weaponInfo, rows, args, client);
    }
    db.Close();
}