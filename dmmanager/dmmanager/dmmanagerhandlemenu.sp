#include <dmmanager>
#include <dmmanagermappos>

void manageGiveWeapon(int client, char weapon[32], bool mainWeapon)
{
    int weaponIndex = GetEntPropEnt(client, Prop_Data, "m_hMyWeapons", mainWeapon ? 2 : 1);
    
    if (weaponIndex != -1)
        RemovePlayerItem(client, weaponIndex);
    GivePlayerItem(client, weapon);
    weaponIndex = GetEntPropEnt(client, Prop_Data, "m_hMyWeapons", mainWeapon ? 2 : 1);
    for (int i = 0; i < MAX_PLAYER; i++) {
        if (usersStorage[i].assign && usersStorage[i].clientId == client) {
            if (mainWeapon) {
                usersStorage[i].mainWeapon = weapon;
                usersStorage[i].mainWeaponAmmo = GetEntProp(weaponIndex, Prop_Send, "m_iClip1", 1);
            }
            else {
                usersStorage[i].secondaryWeapon = weapon;
                usersStorage[i].secondaryWeaponAmmo = GetEntProp(weaponIndex, Prop_Send, "m_iClip1", 1);
            }
            break;
        }
    }
}

void setSpawnPoint(int id, char spawn[32])
{
    char map[32];

    if (id == -1) {
        PrintToServer("[DM_MANAGER]Client not found");
        return;
    }
    GetCurrentMap(map, sizeof(map));
    if (strcmp(map, "de_dust2") != 0 && strcmp(map, "de_inferno") != 0 && strcmp(map, "de_mirage") != 0) {
        PrintToServer("[DM_MANAGER]Map not supported");
        return;
    }
    if (strcmp(map, "de_dust2") == 0) {
        for (int i = 0; i < 5; i++) {
            if (strcmp(spawn, dust2_Pos[i].name) == 0) {
                usersStorage[id].spawnPoint[0] = dust2_Pos[i].x;
                usersStorage[id].spawnPoint[1] = dust2_Pos[i].y;
                usersStorage[id].spawnPoint[2] = dust2_Pos[i].z;
                usersStorage[id].spawnSet = true;
                return;
            }
        }
    }
    if (strcmp(map, "de_inferno") == 0) {
        for (int i = 0; i < 5; i++) {
            if (strcmp(spawn, inferno_Pos[i].name) == 0) {
                usersStorage[id].spawnPoint[0] = inferno_Pos[i].x;
                usersStorage[id].spawnPoint[1] = inferno_Pos[i].y;
                usersStorage[id].spawnPoint[2] = inferno_Pos[i].z;
                usersStorage[id].spawnSet = true;
                return;
            }
        }
    }
    if (strcmp(map, "de_mirage") == 0) {
        for (int i = 0; i < 5; i++) {
            if (strcmp(spawn, mirage_Pos[i].name) == 0) {
                usersStorage[id].spawnPoint[0] = mirage_Pos[i].x;
                usersStorage[id].spawnPoint[1] = mirage_Pos[i].y;
                usersStorage[id].spawnPoint[2] = mirage_Pos[i].z;
                usersStorage[id].spawnSet = true;
                return;
            }
        }
    }
}

public int OnMenuSelectionWeapon(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            switch (param2)
            {
                case 0:
                    manageGiveWeapon(param1, (getPrefereWeapon(param1)).name, true);
                case 1:
                    manageGiveWeapon(param1, "weapon_ak47", true);
                case 2:
                    manageGiveWeapon(param1, "weapon_m4a1", true);
                case 3:
                    manageGiveWeapon(param1, "weapon_m4a1_silencer", true);
                case 4:
                    manageGiveWeapon(param1, "weapon_aug", true);
                case 5:
                    manageGiveWeapon(param1, "weapon_sg556", true);
                case 6:
                    manageGiveWeapon(param1, "weapon_awp", true);
                case 7:
                    manageGiveWeapon(param1, "weapon_deagle", false);
                case 8:
                    manageGiveWeapon(param1, "weapon_hkp2000", false);
                case 9:
                    manageGiveWeapon(param1, "weapon_usp_silencer", false);
            }
            return 0;
        }
    }

    return 0;
}

public int OnMenuSelectionPistol(Menu menu, MenuAction action, int param1, int param2)
{
    if (param1 <= 0)
        return 0;
    switch (action)
    {
        case MenuAction_Select:
        {
            switch (param2)
            {
                case 0:
                    manageGiveWeapon(param1, getPrefereWeapon(param1, true).name, false);
                case 1:
                    manageGiveWeapon(param1, "weapon_hkp2000", false);
                case 2:
                    manageGiveWeapon(param1, "weapon_usp_silencer", false);
                case 3:
                    manageGiveWeapon(param1, "weapon_p250", false);
                case 4:
                    manageGiveWeapon(param1, "weapon_deagle", false);
                case 5:
                    manageGiveWeapon(param1, "weapon_elite", false);
                case 6:
                    manageGiveWeapon(param1, "weapon_fiveseven", false);
                case 7:
                    manageGiveWeapon(param1, "weapon_tec9", false);
                case 8:
                    manageGiveWeapon(param1, "weapon_cz75a", false);
            }
            return 0;
        }
    }
    return 0;
}

public int OnMenuSelectionSpawn(Menu menu, MenuAction action, int param1, int param2)
{
    int ind = getIndId(param1);

    switch (action)
    {
        case MenuAction_Select:
        {
            switch (param2)
            {
                case 0:
                    setSpawnPoint(ind, "bombsite_b");
                case 1:
                    setSpawnPoint(ind, "bombsite_a");
                case 2:
                    setSpawnPoint(ind, "ct_spawn");
                case 3:
                    setSpawnPoint(ind, "t_spawn");
                case 4:
                    setSpawnPoint(ind, "middle");
            }
            return 0;
        }
    }

    return 0;
}

void createMenuWeapon()
{
    if (weaponMenu != null)
        weaponMenu.RemoveAllItems();
    if (!onlyPistol) {
        weaponMenu = CreateMenu(OnMenuSelectionWeapon, MENU_ACTIONS_ALL);
        weaponMenu.SetTitle("Choose your weapon");
        weaponMenu.AddItem("PREFERE_WEAPON", "PREFERE_WEAPON", 0);
        weaponMenu.AddItem("AK47", "weapon_ak47", 0);
        weaponMenu.AddItem("M4A4", "weapon_m4a4", 0);
        weaponMenu.AddItem("M4A1-S", "weapon_m4a1_silencer", 0);
        weaponMenu.AddItem("AUG", "weapon_aug", 0);
        weaponMenu.AddItem("SG553", "weapon_sg553", 0);
        weaponMenu.AddItem("AWP", "weapon_awp", 0);
        weaponMenu.AddItem("DEAGLE", "weapon_deagle", 0);
        weaponMenu.AddItem("P2000", "weapon_hkp2000", 0);
        weaponMenu.AddItem("USP-S", "weapon_usp_silencer", 0);
    } else {
        weaponMenu = CreateMenu(OnMenuSelectionPistol, MENU_ACTIONS_ALL);
        weaponMenu.SetTitle("Choose your pistol");
        weaponMenu.AddItem("PREFERE_PISTOL", "PREFERE_PISTOL", 0);
        weaponMenu.AddItem("P2000", "weapon_hkp2000", 0);
        weaponMenu.AddItem("USP-S", "weapon_usp_silencer", 0);
        weaponMenu.AddItem("P250", "weapon_p250", 0);
        weaponMenu.AddItem("DEAGLE", "weapon_deagle", 0);
        weaponMenu.AddItem("DUALS", "weapon_elite", 0);
        weaponMenu.AddItem("five-seven", "weapon_fiveseven", 0);
        weaponMenu.AddItem("TEC-9", "weapon_tec9", 0);
        weaponMenu.AddItem("cz75", "weapon_cz75a", 0);
    }
}

void createMenuSpawn()
{
    spawnMenu = CreateMenu(OnMenuSelectionSpawn, MENU_ACTIONS_ALL);
    spawnMenu.SetTitle("Choose your spawn");
    spawnMenu.AddItem("Bombsite B", "bombsite_b", 0);
    spawnMenu.AddItem("Bombsite A", "bombsite_a", 0);
    spawnMenu.AddItem("CT Spawn", "ct_spawn", 0)
    spawnMenu.AddItem("T Spawn", "t_spawn", 0)
    spawnMenu.AddItem("Middle", "middle", 0);
}
