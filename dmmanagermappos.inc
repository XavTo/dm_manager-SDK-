#if defined _dmmanager_mappos_included
#endinput
#endif
#define _dmmanager_mappos_included

enum struct namePos
{
    float x;
    float y;
    float z;
    char name[32];
} 

namePos dust2_Pos[5] = {
    { -1887.749878, 2369.946289, 6.210707, "bombsite_b" },
    { 265.675507, 2421.621582, -121.173813, "bombsite_a" },
    { 0.0, 0.0, 0.0, "ct_spawn" },
    { 0.0, 0.0, 0.0, "t_spawn" },
    { 0.0, 0.0, 0.0, "middle" }
}

namePos inferno_Pos[5] = {
    { 0.0, 0.0, 0.0, "bombsite_b" },
    { 0.0, 0.0, 0.0, "bombsite_a" },
    { 0.0, 0.0, 0.0, "ct_spawn" },
    { 0.0, 0.0, 0.0, "t_spawn" },
    { 0.0, 0.0, 0.0, "middle" }
}

namePos mirage_Pos[5] = {
    { 0.0, 0.0, 0.0, "bombsite_b" },
    { 0.0, 0.0, 0.0, "bombsite_a" },
    { 0.0, 0.0, 0.0, "ct_spawn" },
    { 0.0, 0.0, 0.0, "t_spawn" },
    { 0.0, 0.0, 0.0, "middle" }
}

char listWeaponName[33][32] = {
    "weapon_knife",
    "weapon_m4a1",
    "weapon_m4a1_silencer",
    "weapon_ak47",
    "weapon_aug",
    "weapon_sg556",
    "weapon_famas",
    "weapon_galilar",
    "weapon_mac10",
    "weapon_mp9",
    "weapon_mp7",
    "weapon_ump45",
    "weapon_bizon",
    "weapon_awp",
    "weapon_ssg08",
    "weapon_g3sg1",
    "weapon_scar20",
    "weapon_m249",
    "weapon_negev",
    "weapon_usp_silencer",
    "weapon_hkp2000",
    "weapon_glock",
    "weapon_p250",
    "weapon_elite",
    "weapon_cz75a",
    "weapon_fiveseven",
    "weapon_tec9",
    "weapon_revolver",
    "weapon_deagle",
    "weapon_nova",
    "weapon_xm1014",
    "weapon_mag7",
    "weapon_sawedoff",
}