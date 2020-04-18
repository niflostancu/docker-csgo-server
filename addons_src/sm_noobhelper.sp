#pragma semicolon 1

#include <sourcemod>

// Global Definitions
#define PLUGIN_VERSION "1.0.0"

char g_ConfigPath[PLATFORM_MAX_PATH];
KeyValues g_kvPlayers = null;

// Functions
public Plugin:myinfo =
{
	name = "Noob Helper",
	author = "Niflostancu",
	description = "Persistently sets noob players stats to make them resist longer.",
	version = PLUGIN_VERSION,
};


public OnPluginStart()
{
	BuildPath(Path_SM, g_ConfigPath, sizeof(g_ConfigPath), "configs/noob_players.txt");
	LoadTranslations("common.phrases");
	CreateConVar("sm_noobhelper_version", PLUGIN_VERSION, "NoobHelper Version", FCVAR_NOTIFY);
	RegAdminCmd("sm_noobhealth", Command_SetNoobHealth, ADMFLAG_SLAY, "sm_noobhealth <#userid|name> <amount>");

	LoadNoobPlayers();

	HookEvent("player_spawn", PlayerSpawn);
}

void LoadNoobPlayers()
{
	g_kvPlayers = new KeyValues("noobs");
	if (g_kvPlayers.ImportFromFile(g_ConfigPath))
	{
		char sectionName[30];
		if (!g_kvPlayers.GetSectionName(sectionName, sizeof(sectionName)))
		{
			SetFailState("Error in %s: File corrupt or in the wrong format", g_ConfigPath);
			return;
		}
		if (strcmp(sectionName, "noobs") != 0)
		{
			SetFailState("Error in %s: Couldn't find 'noobs' section", g_ConfigPath);
			return;
		}
		
		//Reset kvHandle
		g_kvPlayers.Rewind();
	}
}

void PersistNoobPlayers()
{
	g_kvPlayers.ExportToFile(g_ConfigPath);
	g_kvPlayers.Rewind();
}

public Action:Command_SetNoobHealth(client, args)
{
	decl String:target[32], String:mod[32], String:health[10];
	new nHealth;

	GetGameFolderName(mod, sizeof(mod));

	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_noobhealth <#userid|name> <amount>");
		return Plugin_Handled;
	}
	else {
		GetCmdArg(1, target, sizeof(target));
		GetCmdArg(2, health, sizeof(health));
		nHealth = StringToInt(health);
	}

	if (nHealth < 0) {
		ReplyToCommand(client, "[SM] Health must be greater then zero.");
		return Plugin_Handled;
	}

	decl String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count, bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			target,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		new String:auth[64];
		GetClientAuthId(target_list[i], AuthId_Steam2, auth, sizeof(auth), true);
		SetEntityHealth(target_list[i], nHealth);
		g_kvPlayers.JumpToKey(auth, true);
		g_kvPlayers.SetNum("health", nHealth);
		g_kvPlayers.Rewind();
		PersistNoobPlayers();
		LogAction(client, target_list[i], "\"%L\" set \"%L\" (\"%s\") health to %i", client, target_list[i], auth, nHealth);
	}

	return Plugin_Handled;
}

public void PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	new String:auth[64];
	GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth), true);
	
	if (!g_kvPlayers.JumpToKey(auth)) {
		g_kvPlayers.Rewind();
        return;
    }
	SetEntityHealth(client, g_kvPlayers.GetNum("health", 1));
	g_kvPlayers.Rewind();
}


