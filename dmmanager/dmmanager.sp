#include <dmmanager>
#include "dmmanagerhandleevent.sp"
#include "dmmanagerhandledb.sp"
#include "dmmanagerhandlemenu.sp"
#include "dmmanagerhandlestat.sp"

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
    initDataBase();
    usersStorage[0].assign = false;
    getBotName();
    createMenuWeapon();
    createMenuSpawn();
    myHookEvent();
    SetHudTextParams(0.01, 0.5, 10.0, 0, 0, 128, 128, 0, 1.0, 0.3, 2.0);
}