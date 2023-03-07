#include <dmmanager>

public void OnMapStart()
{
    char sBuffer[PLATFORM_MAX_PATH];
    SDKHook(GetPlayerResourceEntity(), SDKHook_ThinkPost, OnThinkPost);
    if (kv != null) kv.Close();
    kv = CreateKeyValues("Ranks");
    FileToKeyValues(kv, m_cFilePath);
    if (!KvGotoFirstSubKey(kv)) return;
    do {
        Format(sBuffer, sizeof(sBuffer), "materials/panorama/images/icons/skillgroups/skillgroup%i.svg", KvGetNum(kv, "index"));
        AddFileToDownloadsTable(sBuffer);
        PrintToServer("AddFileToDownloadsTable %s", sBuffer);
	} while (KvGotoNextKey(kv));
    KvRewind(kv);
    Format(sBuffer, sizeof(sBuffer), "sound/%s", SOUND_LEVEL_UP);
    AddFileToDownloadsTable(sBuffer);
    Format(sBuffer, sizeof(sBuffer), "sound/%s", SOUND_LEVEL_DOWN);
    AddFileToDownloadsTable(sBuffer);
    Format(sBuffer, sizeof(sBuffer), "sound/%s", SOUND_HEADSHOT);
    AddFileToDownloadsTable(sBuffer);
    PrecacheSound(SOUND_LEVEL_UP, true);
    PrecacheSound(SOUND_LEVEL_DOWN, true);
    PrecacheSound(SOUND_HEADSHOT, true);
}

public void OnThinkPost(int m_iEntity)
{
    int add_orank = FindSendPropInfo("CCSPlayerResource", "m_iCompetitiveRanking");

    for (int i = 1; i < MAX_PLAYER; i++) {
        if (usersStorage[i - 1].assign && usersStorage[i - 1].rankIdPic != -1) {
            if (GetEntData(m_iEntity, add_orank + (i * 4)) != usersStorage[i - 1].rankIdPic) {
                SetEntData(m_iEntity, add_orank + (i * 4), usersStorage[i - 1].rankIdPic);
            }
        }
    }
}

void setRanks(int clientId)
{
    char buffer[64];
    WeaponInfo weaponInfo;
    int id = getIndId(clientId);

    weaponInfo = getPrefereWeapon(clientId);
    if (strcmp(weaponInfo.name, "weapon_ak47") == 0 || strcmp(weaponInfo.name, "weapon_m4a1") == 0
        || strcmp(weaponInfo.name, "weapon_awp") == 0 || strcmp(weaponInfo.name, "weapon_deagle") == 0)
        strcopy(buffer, sizeof(buffer), weaponInfo.name);
    else
        strcopy(buffer, sizeof(buffer), "undefined");
    if (weaponInfo.kills >= 0 && weaponInfo.kills < 100)
        StrCat(buffer, sizeof(buffer), "-Silver");
    else if (weaponInfo.kills >= 100 && weaponInfo.kills < 250)
        StrCat(buffer, sizeof(buffer), "-Gold");
    else {
        if (weaponInfo.kills >= 500 && (float(weaponInfo.hs) / float(weaponInfo.kills) * 100) >= 80)
            StrCat(buffer, sizeof(buffer), "-Master");
        else
            StrCat(buffer, sizeof(buffer), "-Diamond");
    }
    if (!KvJumpToKey(kv, buffer)) {
        KvRewind(kv);
        return;
    }
    if (usersStorage[id].rankIdPic != KvGetNum(kv, "index") && usersStorage[id].rankIdPic != -1) {
        usersStorage[id].rankIdPic > KvGetNum(kv, "index") ? EmitSoundToClient(clientId, SOUND_LEVEL_DOWN) : EmitSoundToClient(clientId, SOUND_LEVEL_UP);
    }
    usersStorage[id].rankIdPic = KvGetNum(kv, "index");
    KvRewind(kv);
}