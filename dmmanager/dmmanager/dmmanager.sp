#include <dmmanager>
#include "dmmanagerhandleevent.sp"
#include "dmmanagerhandledb.sp"
#include "dmmanagerhandlemenu.sp"
#include "dmmanagerhandlestat.sp"
#include "dmmanagerhandleranks.sp"

public Plugin:myinfo =
{
    name = "DM_Manager",
    author = "Artotototo",
    description = "DM_Manager",
    version = "1.0",
    url = "https://github.com/XavTo"
}

public void OnPluginStart()
{
    onlyHs = false;
    onlyPistol = false;
    add_oHealth = FindSendPropInfo("CCSPlayer", "m_iHealth");
    add_oArmor = FindSendPropInfo("CCSPlayer", "m_ArmorValue");
    add_oRank = FindSendPropInfo("CCSPlayerResource", "m_iCompetitiveRanking");
    BuildPath(Path_SM, m_cFilePath, sizeof(m_cFilePath), "configs/ranks.ini");
    PrintToServer("[DM_MANAGER]DM_Manager by Artotototo");
    initDataBase();
    getBotName();
    createMenuWeapon();
    createMenuSpawn();
    myHookEvent();
    SetHudTextParams(0.01, 0.5, 10.0, 0, 0, 128, 128, 0, 1.0, 0.3, 2.0);
}