#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "BattlefieldDuck"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>

//Our Includes
#include <tf2jail2/tf2jail2_warden>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "[TF2Jail2] Module: Guards Logo",
	author = PLUGIN_AUTHOR,
	description = "Display a Defence Logo on guards' head",
	version = PLUGIN_VERSION,
	url = ""
};

#define MODEL_SHIELD "models/pickups/pickup_powerup_defense.mdl"

int g_iShieldRef[MAXPLAYERS + 1];

public void OnPluginStart()
{
	HookEvent("teamplay_round_start", Event_OnRoundStart);
	HookEvent("teamplay_round_win", Event_OnRoundEnd);
}

public void OnMapStart()
{
	PrecacheModel(MODEL_SHIELD);
	
	for (int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			OnClientPutInServer(client);
		}
	}
}

public void OnClientPutInServer(int client)
{
	g_iShieldRef[client] = INVALID_ENT_REFERENCE;
}

public void Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		KillShield(i);
	}
}

public void Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		KillShield(i);
	}
}

public void TF2Jail2_OnWardenSet_Post(int warden, int admin)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		KillShield(i);
		
		if (i == warden)
		{
			continue;
		}
		
		if (!IsClientInGame(i))
		{
			continue;
		}
		
		if (GetClientTeam(i) == 3)
		{
			int shield = CreateShield();
			if (shield != INVALID_ENT_REFERENCE)
			{
				g_iShieldRef[i] = EntIndexToEntRef(shield);
			}
		}
	}
}

public void TF2Jail2_OnWardenRemoved_Post(int old_warden, int admin)
{
	if (IsClientInGame(old_warden) && IsPlayerAlive(old_warden) && GetClientTeam(old_warden) == 3)
	{
		int shield = CreateShield();
		if (shield != INVALID_ENT_REFERENCE)
		{
			g_iShieldRef[old_warden] = EntIndexToEntRef(shield);
		}
	}
}

public void OnGameFrame()
{
	int warden = TF2Jail2_GetWarden();
	
	float vec[3];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (i == warden)
		{
			continue;
		}
		
		if (!IsClientInGame(i))
		{
			continue;
		}
		
		if (!IsPlayerAlive(i))
		{
			continue;
		}
		
		if (GetClientTeam(i) == 3)
		{
			int shield = EntRefToEntIndex(g_iShieldRef[i]);
			if (shield <= 0)
			{
				continue;
			}
			
			GetClientAbsOrigin(i, vec);
			vec[2] += 78.0;
			TeleportEntity(shield, vec, NULL_VECTOR, NULL_VECTOR);
		}
	}
}

int CreateShield()
{
	int shield = CreateEntityByName("prop_dynamic_override");
	if (shield == INVALID_ENT_REFERENCE)
	{
		return -1;
	}
	
	SetEntityModel(shield, MODEL_SHIELD);

	DispatchSpawn(shield);
	
	SetEntData(shield, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
	
	SetEntProp(shield, Prop_Send, "m_nSkin", 2);
	
	SetEntPropFloat(shield, Prop_Send, "m_flModelScale", 0.5);
	
	SetEntProp(shield, Prop_Send, "m_nSequence", 0);
	SetVariantString("spin");
	AcceptEntityInput(shield, "SetAnimation");
	AcceptEntityInput(shield, "Enable");
	
	return shield;
}

bool KillShield(int client)
{
	int shield = EntRefToEntIndex(g_iShieldRef[client]);
	if (shield > 0)
	{
		AcceptEntityInput(shield, "Kill");
	}
	
	return true;
}