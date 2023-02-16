#if defined _dmmanager_included
#endinput
#endif
#define _dmmanager_included

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <regex>

#define MAX_PLAYER 20
#define MAX_BOTNAME_LENGTH 32
#define SIZE_STRING_DEFAULT 32
#define GLOCK_AMMO 20
#define USP_AMMO 12
#define P2000_AMMO 13
#define MENU_DISPLAY_TIME 30
#define NAME_DATABASE "new_database"

enum struct BotInfo
{
    int botId;
    char name[MAX_BOTNAME_LENGTH];
    char weapon[SIZE_STRING_DEFAULT];
    bool assign;
}

enum struct UsersInfo
{
    int clientId;
    int dbId;
    char steamId[SIZE_STRING_DEFAULT];
    char mainWeapon[SIZE_STRING_DEFAULT];
    char secondaryWeapon[SIZE_STRING_DEFAULT];
    int mainWeaponAmmo;
    int secondaryWeaponAmmo;
    bool spawnSet;
    float spawnPoint[3];    
    int time;
    bool assign;
}

enum struct WeaponInfo
{
    char name[SIZE_STRING_DEFAULT];
    int kills;
    int hs;
}

BotInfo botStorage[MAX_PLAYER];
UsersInfo usersStorage[MAX_PLAYER];
Menu weaponMenu;
Menu spawnMenu;
Menu botMenu;
Handle db;
