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
}

public void OnThinkPost(int m_iEntity)
{
    int m_iLevelTemp[MAX_PLAYER] = {0};

    GetEntDataArray(m_iEntity, add_oRank, m_iLevelTemp, MAX_PLAYER);
    for (int i = 0; i < MAX_PLAYER; i++) {
        if (usersStorage[i].assign && usersStorage[i].rankIdPic != -1) {
            if (usersStorage[i].rankIdPic != m_iLevelTemp[i]) {
                PrintToServer("SetEntData %i %i", m_iLevelTemp[i], usersStorage[i].rankIdPic);
                SetEntData(m_iEntity, add_oRank + (1 * 4), usersStorage[i].rankIdPic, true);
            }
		}
	}
}
