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
            PrintToServer("Weapon %s given to %s", weapon, usersStorage[i].steamId);
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
        PrintToServer("Client not found");
        return;
    }
    GetCurrentMap(map, sizeof(map));
    if (strcmp(map, "de_dust2") != 0 && strcmp(map, "de_inferno") != 0 && strcmp(map, "de_mirage") != 0) {
        PrintToServer("Map not supported");
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
                    manageGiveWeapon(param1, "weapon_ak47", true);
                case 1:
                    manageGiveWeapon(param1, "weapon_m4a1", true);
                case 2:
                    manageGiveWeapon(param1, "weapon_m4a1_silencer", true);
                case 3:
                    manageGiveWeapon(param1, "weapon_aug", true);
                case 4:
                    manageGiveWeapon(param1, "weapon_sg556", true);
                case 5:
                    manageGiveWeapon(param1, "weapon_awp", true);
                case 6:
                    manageGiveWeapon(param1, "weapon_deagle", false);
                case 7:
                    manageGiveWeapon(param1, "weapon_p2000", false);
                case 8:
                    manageGiveWeapon(param1, "weapon_usp_silencer", false);
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
    weaponMenu = CreateMenu(OnMenuSelectionWeapon, MENU_ACTIONS_ALL);
    weaponMenu.SetTitle("Choose your weapon");
    weaponMenu.AddItem("AK47", "weapon_ak47", 0);
    weaponMenu.AddItem("M4A4", "weapon_m4a4", 0);
    weaponMenu.AddItem("M4A1-S", "weapon_m4a1_silencer", 0);
    weaponMenu.AddItem("AUG", "weapon_aug", 0);
    weaponMenu.AddItem("SG553", "weapon_sg553", 0);
    weaponMenu.AddItem("AWP", "weapon_awp", 0);
    weaponMenu.AddItem("DEAGLE", "weapon_deagle", 0);
    weaponMenu.AddItem("P2000", "weapon_p2000", 0);
    weaponMenu.AddItem("USP-S", "weapon_usp_silencer", 0);
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