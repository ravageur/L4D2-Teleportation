#include <clients>
#include <sourcemod>
#include <sdktools_functions>

/**
 * Declare this as a struct in your plugin to expose its information.
 */
public Plugin myinfo = 
{
    name = "Teleportation",
    description = "This plugin will allow you to teleport a player or yourself to another location.",
    author = "ravageur",
    version = "1.0",
    url = "https://github.com/ravageur/L4D2-Teleportation"
};

public void OnPluginStart()
{
    PrintToServer("[TP]: Plugin teleportation ready to save you !");

    LoadTranslations("common.phrases");

    RegisterCommands();
}

public void OnPluginEnd()
{
    PrintToServer("[TP]: Plugin teleportation disabled !");
}

/**
 * Allow to register all commands for this plugin.
 */
void RegisterCommands()
{
    RegAdminCmd("tp_coordinate", GetCoordinatePlayer, ADMFLAG_ROOT, "Allow to get the coordinate from a player.");
    RegAdminCmd("tp_teleport", TeleportPlayerToPlayer, ADMFLAG_ROOT, "Allow to teleporte a player to another player.");
    RegAdminCmd("tp_teleport_location", TeleportPlayerToLocation, ADMFLAG_ROOT, "Allow to teleport a player or yourself to another location by different type of teleportation.");
}

/**
 * Allow to get the coordinate from a player.
 * 
 * @param client
 * @param args
 *
 * @return Action
 */
Action GetCoordinatePlayer(int client = 0, int args)
{
    char nameOfTargetedPlayer[255];
    int indexTargetedPlayer;
    float location[3];

    if(args == 1)
    {
        GetCmdArg(1, nameOfTargetedPlayer, sizeof(nameOfTargetedPlayer));
        indexTargetedPlayer = FindTarget(client, nameOfTargetedPlayer);

        if(indexTargetedPlayer != -1)
        {
            GetClientAbsOrigin(indexTargetedPlayer, location);

            if(client == 0)
            {
                PrintToServer("[TP]: The coordinates of %s are [x: %f, y: %f, z: %f]", nameOfTargetedPlayer, location[0], location[1], location[2]);
            }
            else
            {
                PrintToChat(client, "[TP]: The coordinates of %s are [x: %f, y: %f, z: %f]", nameOfTargetedPlayer, location[0], location[1], location[2]);
            }
        }
        else
        {
            ReplyToCommand(client, "[TP]: Player %s not found.", nameOfTargetedPlayer);
        }
    }
    else if(client != 0)
    {
        GetClientName(client, nameOfTargetedPlayer, sizeof(nameOfTargetedPlayer));
        GetClientAbsOrigin(indexTargetedPlayer, location);
        PrintToChat(client, "[TP]: Your coordinates are [x: %f, y: %f, z: %f]", location[0], location[1], location[2]);
    }
    else
    {
        ReplyToCommand(client, "[TP]: tp_coordinate <nameOfPlayer>");
    }

    return Plugin_Handled;
}

/**
 * Allow to teleporte a player to another player.
 *
 * The first argument is the <name|userid> of the player to teleport.
 * The second argument is the <name|userid> of the player where the the other player will be teleported. (If this is not defined, then it is the player who
 * use this command who will be targetted).
 * 
 * @param client
 * @param args
 *
 * @return Action
 */
Action TeleportPlayerToPlayer(int client = 0, int args)
{
    char nameOfPlayer_1[255];
    char nameOfPlayer_2[255];

    int indexPlayer_1;
    int indexPlayer_2;

    float vecP2[3];

    if(args == 2)
    {
        GetCmdArg(1, nameOfPlayer_1, sizeof(nameOfPlayer_1));
        GetCmdArg(2, nameOfPlayer_2, sizeof(nameOfPlayer_2));

        indexPlayer_1 = FindTarget(client, nameOfPlayer_1);
        indexPlayer_2 = FindTarget(client, nameOfPlayer_2);

        if(indexPlayer_1 != -1 && indexPlayer_2 != -1)
        {
            GetClientAbsOrigin(indexPlayer_2, vecP2);
            TeleportEntity(indexPlayer_1, vecP2);
        }
    }
    else if(client != 0 && args == 1)
    {
        GetCmdArg(1, nameOfPlayer_1, sizeof(nameOfPlayer_1));
        indexPlayer_1 = FindTarget(client, nameOfPlayer_1);

        if(indexPlayer_1 != -1)
        {
            GetClientAbsOrigin(client, vecP2);
            TeleportEntity(indexPlayer_1, vecP2);
        }
    }
    else
    {
        ReplyToCommand(client, "[TP]: ut_teleport <namePlayer1> <namePlayer2(If not specified then it's you)>");
    }

    return Plugin_Handled;
}

/**
 * Allow to teleport a player or yourself to another location by different type of teleportation. (Absolute or relative)
 * 
 * @param client
 * @param args
 *
 * @return Action
 */
Action TeleportPlayerToLocation(int client = 0, int args)
{
    char nameOfTargetedPlayer[255];
    int indexTargetedPlayer;
    char typeTeleportation[255];
    char locationArgumentToConvert[3][255];
    float locationTargetedPlayer[3];
    float locationToAdd[3];

    if(args == 5)
    {
        GetCmdArg(1, nameOfTargetedPlayer, sizeof(nameOfTargetedPlayer));
        GetCmdArg(2, typeTeleportation, sizeof(typeTeleportation));
        GetCmdArg(3, locationArgumentToConvert[0], sizeof(locationArgumentToConvert[]));
        GetCmdArg(4, locationArgumentToConvert[1], sizeof(locationArgumentToConvert[]));
        GetCmdArg(5, locationArgumentToConvert[2], sizeof(locationArgumentToConvert[]));

        locationToAdd[0] = StringToFloat(locationArgumentToConvert[0]);
        locationToAdd[1] = StringToFloat(locationArgumentToConvert[1]);
        locationToAdd[2] = StringToFloat(locationArgumentToConvert[2]);

        indexTargetedPlayer = FindTarget(client, nameOfTargetedPlayer);

        if(indexTargetedPlayer != -1)
        {
            if(StrEqual(typeTeleportation, "0") || StrEqual(typeTeleportation, "absolute", false) || StrEqual(typeTeleportation, "a", false))
            {
                GetClientAbsOrigin(indexTargetedPlayer, locationTargetedPlayer);

                locationTargetedPlayer[0] = locationToAdd[0];
                locationTargetedPlayer[1] = locationToAdd[1];
                locationTargetedPlayer[2] = locationToAdd[2];

                TeleportEntity(indexTargetedPlayer, locationTargetedPlayer);
            }
            else if(StrEqual(typeTeleportation, "1") || StrEqual(typeTeleportation, "relative", false) || StrEqual(typeTeleportation, "r", false))
            {
                GetClientAbsOrigin(indexTargetedPlayer, locationTargetedPlayer);

                locationTargetedPlayer[0] = locationTargetedPlayer[0] + locationToAdd[0];
                locationTargetedPlayer[1] = locationTargetedPlayer[1] + locationToAdd[1];
                locationTargetedPlayer[2] = locationTargetedPlayer[2] + locationToAdd[2];

                TeleportEntity(indexTargetedPlayer, locationTargetedPlayer);
            }
            else
            {
                ReplyToCommand(client, "[TP]: Type of teleportation %s does not exist.", typeTeleportation);
            }
        }
        else
        {
            ReplyToCommand(client, "[TP]: Player %s not found.", nameOfTargetedPlayer);
        }
    }
    else
    {
        ReplyToCommand(client, "[TP]: ut_teleportLocation <nameOfPlayerToTeleport> <[0: absolute, 1: relative]> <x> <y> <z>");
    }

    return Plugin_Handled;
}