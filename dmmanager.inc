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
#define MENU_DISPLAY_TIME 20
#define NB_RANK 16
#define NAME_DATABASE "new_database"
#define SOUND_LEVEL_UP "dmmanager/level_up.mp3"
#define SOUND_LEVEL_DOWN "dmmanager/level_down.mp3"
#define SOUND_HEADSHOT "dmmanager/headshot.mp3"

enum struct BotInfo
{
    int botId;
    char name[MAX_BOTNAME_LENGTH];
    char weapon[SIZE_STRING_DEFAULT];
    float spawnPoint[3];
    int spawnPos;
    bool spawnSet;
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
    int spawnPos;
    float spawnPoint[3];
    float spawnAngle[3];
    int time;
    int rankIdPic;
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
Menu weaponMenu = null;
Menu spawnMenu = null;
Menu botMenu = null;
Menu voteMenu = null;
bool onlyHs;
bool onlyPistol;
int add_oHealth;
int add_oArmor;
char m_cFilePath[PLATFORM_MAX_PATH];
KeyValues kv;
Handle db;
