#include <dmmanager>
#include "dmmanagerhandleevent.sp"
#include "dmmanagerhandledb.sp"
#include "dmmanagerhandlemenu.sp"

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
}