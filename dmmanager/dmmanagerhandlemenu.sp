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
    if (strcmp(map, "de_dust2") != 0) {
        PrintToServer("[DM_MANAGER]Map not supported");
        return;
    }
    if (strcmp(map, "de_dust2") == 0) {
        for (int i = 0, rand = 0; i < 25; i += 5) {
            if (strcmp(spawn, dust2_Pos[i].name) == 0) {
                rand = GetRandomInt(0, 4);
                usersStorage[id].spawnPoint[0] = dust2_Pos[i + rand].x;
                usersStorage[id].spawnPoint[1] = dust2_Pos[i + rand].y;
                usersStorage[id].spawnPoint[2] = dust2_Pos[i + rand].z;
                usersStorage[id].spawnAngle[0] = dust2_Pos[i + rand].ang_x;
                usersStorage[id].spawnAngle[1] = dust2_Pos[i + rand].ang_y;
                usersStorage[id].spawnAngle[2] = dust2_Pos[i + rand].ang_z;
                usersStorage[id].spawnPos = i;
                usersStorage[id].spawnSet = true;
                PrintToServer("[DM_MANAGER]Spawn set to %s, pos %.2f %.2f %.2f", spawn, usersStorage[id].spawnPoint[0], usersStorage[id].spawnPoint[1], usersStorage[id].spawnPoint[2]);
                return;
            }
        }
    }
}

void setBotSpawnPoint(char posName[32])
{
    char map[32];

    GetCurrentMap(map, sizeof(map));
    if (strcmp(map, "de_dust2") != 0) {
        PrintToServer("[DM_MANAGER]Map not supported");
        return;
    }
    if (strcmp(map, "de_dust2") == 0) {
        for (int i = 0, rand = 0; i < 25; i += 5) {
            if (strcmp(posName, dust2_Pos[i].name) == 0) {
                for (int j = 0; j < MAX_PLAYER; j++) {
                    if (!botStorage[j].assign || GetRandomInt(0, 1) == 0)
                        continue;
                    rand = GetRandomInt(0, 4);
                    botStorage[j].spawnPoint[0] = dust2_Pos[i + rand].x;
                    botStorage[j].spawnPoint[1] = dust2_Pos[i + rand].y;
                    botStorage[j].spawnPoint[2] = dust2_Pos[i + rand].z;
                    botStorage[j].spawnPos = i;
                    botStorage[j].spawnSet = true;
                }
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

public int handleVoteMenu(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_End) {
        delete menu;
        voteMenu = null;
    }
    return 0;
}

public void Handle_VoteResults(Menu menu, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
    int winner = 0;
    int votes = 0;
    int max_votes = 0;
    char map[32];

    for (int i = 0; i < num_items; i++) {
        votes = item_info[i][VOTEINFO_ITEM_VOTES];
        if (votes > max_votes) {
            max_votes = votes;
            winner = i;
        }
    }
    if (winner == 0) {
        voteMenu.GetItem(item_info[winner][VOTEINFO_ITEM_INDEX], map, sizeof(map));
        if (strcmp(map, "No") == 0)
            return;
        PrintToServer("[DM_MANAGER]Vote for change bot spawn point to %s", map);
        setBotSpawnPoint(map);
    }
}

void createVoteBot(char []title)
{
    int listClients[MAX_PLAYER];
    int ind = 0;

    for (int i = 0; i < MAX_PLAYER; i++) {
        if (usersStorage[i].assign) {
            listClients[ind] = usersStorage[i].clientId;
            ind++
        }
    }
    if (voteMenu != null)
        return;
    voteMenu = new Menu(handleVoteMenu);
    voteMenu.VoteResultCallback = Handle_VoteResults;
    voteMenu.ExitButton = false;
    voteMenu.SetTitle("change bot spawn point to %s", title)
    voteMenu.AddItem(title, "Yes");
    voteMenu.AddItem("No", "No");
    VoteMenu(voteMenu, listClients, ind, 10);
}

public int OnMenuSelectionSpawnBot(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            switch (param2)
            {
                case 0:
                    createVoteBot("bombsite_b");
                case 1:
                    createVoteBot("bombsite_a");
                case 2:
                    createVoteBot("ct_spawn");
                case 3:
                    createVoteBot("t_spawn");
                case 4:
                    createVoteBot("middle");
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

void createMenuSpawnBot()
{
    botMenu = CreateMenu(OnMenuSelectionSpawnBot, MENU_ACTIONS_ALL);
    botMenu.SetTitle("Start vote to set spawn bot (most likely)");
    botMenu.AddItem("Bombsite B", "bombsite_b", 0);
    botMenu.AddItem("Bombsite A", "bombsite_a", 0);
    botMenu.AddItem("CT Spawn", "ct_spawn", 0)
    botMenu.AddItem("T Spawn", "t_spawn", 0)
    botMenu.AddItem("Middle", "middle", 0);
}
