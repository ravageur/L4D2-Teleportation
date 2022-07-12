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
    RegAdminCmd("tp_teleport", Teleport, ADMFLAG_ROOT, "Allow to teleporte.");
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
    char nameOfTargetedPlayer[256];
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
                PrintToServer("[TP]: The coordinates of %s are [x: %f, y: %f, z: %f].", nameOfTargetedPlayer, location[0], location[2], location[1]);
            }
            else
            {
                PrintToChat(client, "[TP]: The coordinates of %s are [x: %f, y: %f, z: %f].", nameOfTargetedPlayer, location[0], location[2], location[1]);
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
        ReplyToCommand(client, "[TP]: tp_coordinate <nameOfPlayer>.");
    }

    return Plugin_Handled;
}



Action Teleport(int client = 0, int args)
{
    if(args == 5)
    {
        TeleportPlayerToLocation(client);
    }
    else if(args != 0)
    {
        TeleportPlayerToPlayer(client, args);
    }
    else
    {
        ReplyToCommand(client, "[TP]: ut_teleport <namePlayer1> <namePlayer2(If not specified then it's you)>    OR    ut_teleport <nameOfPlayerToTeleport> <[0: absolute, 1: relative]> <x> <y> <z>.");
    }

    return Plugin_Handled;
}



void TeleportPlayerToPlayer(int client, int args)
{
    char nameOfPlayer_1[256];

    int indexPlayer;

    float locationPlayer[3];

    if(args == 2)
    {
        char nameOfPlayer_2[256];
    
        int indexPlayer_2;

        GetCmdArg(1, nameOfPlayer_1, sizeof(nameOfPlayer_1));
        GetCmdArg(2, nameOfPlayer_2, sizeof(nameOfPlayer_2));

        indexPlayer = FindTarget(client, nameOfPlayer_1);
        indexPlayer_2 = FindTarget(client, nameOfPlayer_2);

        if(indexPlayer != -1 && indexPlayer_2 != -1)
        {
            if(indexPlayer_2 != -1)
            {
                GetClientAbsOrigin(indexPlayer_2, locationPlayer);
                TeleportEntity(indexPlayer, locationPlayer);

                ReplyToCommand(client, "[TP]: %s has been teleported to %s.", nameOfPlayer_2);
            }
            else
            {
                ReplyToCommand(client, "[TP]: %s not found.", nameOfPlayer_2);
            }

        }
        else
        {
            ReplyToCommand(client, "[TP]: %s not found.", nameOfPlayer_1);
        }
    }
    else if(client != 0 && args == 1)
    {
        GetCmdArg(1, nameOfPlayer_1, sizeof(nameOfPlayer_1));
        indexPlayer = FindTarget(client, nameOfPlayer_1);

        if(indexPlayer != -1)
        {
            GetClientAbsOrigin(client, locationPlayer);
            TeleportEntity(indexPlayer, locationPlayer);

            ReplyToCommand(client, "[TP]: You have been teleported to %s.", nameOfPlayer_1);
        }
        else
        {
            ReplyToCommand(client, "[TP]: %s not found.", nameOfPlayer_1);
        }
    }
    else
    {
        ReplyToCommand(client, "[TP]: ut_teleport <namePlayer1> <namePlayer2(If not specified then it's you)>.");
    }
}


void TeleportPlayerToLocation(int client)
{
    char namePlayer[256];
    char arguments[4][16];

    int indexPlayer;

    float locationPlayer[3];

    GetCmdArg(1, namePlayer, sizeof(namePlayer));
    GetCmdArg(2, arguments[0], 16);
    GetCmdArg(3, arguments[1], 16);
    GetCmdArg(4, arguments[2], 16);
    GetCmdArg(5, arguments[3], 16);

    indexPlayer = FindTarget(client, namePlayer);

    if(indexPlayer != -1)
    {
        if(StrEqual(arguments[0], "0") || StrEqual(arguments[0], "absolute", false) || StrEqual(arguments[0], "a", false))
        {
            GetClientAbsOrigin(indexPlayer, locationPlayer);

            locationPlayer[0] = StringToFloat(arguments[1]);
            locationPlayer[1] = StringToFloat(arguments[3]);
            locationPlayer[2] = StringToFloat(arguments[2]);

            TeleportEntity(indexPlayer, locationPlayer);

            ReplyToCommand(client, "[TP]: %s has been teleported directly to [X: %s, Y: %s, Z: %s].", namePlayer, arguments[1], arguments[2], arguments[3]);
        }
        else if(StrEqual(arguments[0], "1") || StrEqual(arguments[0], "relative", false) || StrEqual(arguments[0], "r", false))
        {
            GetClientAbsOrigin(indexPlayer, locationPlayer);

            locationPlayer[0] = locationPlayer[0] + StringToFloat(arguments[1]);
            locationPlayer[1] = locationPlayer[1] + StringToFloat(arguments[3]);
            locationPlayer[2] = locationPlayer[2] + StringToFloat(arguments[2]);

            TeleportEntity(indexPlayer, locationPlayer);

            ReplyToCommand(client, "[TP]: %s has been teleported from his position to [X: %s, Y: %s, Z: %s].", namePlayer, arguments[1], arguments[2], arguments[3]);
        }
        else
        {
            ReplyToCommand(client, "[TP]: Type of teleportation %s does not exist.", arguments[0]);
        }
    }
    else
    {
        ReplyToCommand(client, "[TP]: %s not found.", namePlayer);
    }
}