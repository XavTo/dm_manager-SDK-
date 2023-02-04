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