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
	name = "[TF2Jail2] Module: Warden Crown",
	author = PLUGIN_AUTHOR,
	description = "Display a King Crown on warden head",
	version = PLUGIN_VERSION,
	url = ""
};

#define MODEL_CROWN "models/pickups/pickup_powerup_king.mdl"

int g_iCrownRef = INVALID_ENT_REFERENCE;

public void OnPluginStart()
{
	HookEvent("teamplay_round_start", Event_OnRoundStart);
	HookEvent("teamplay_round_win", Event_OnRoundEnd);
}

public void OnMapStart()
{
	PrecacheModel(MODEL_CROWN);
}

public void Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	KillCrown();
}

public void Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	KillCrown();
}

public void TF2Jail2_OnWardenSet_Post(int warden, int admin)
{
	KillCrown();
	
	int crown = CreateCrown();
	if (crown == INVALID_ENT_REFERENCE)
	{
		return;
	}
	
	g_iCrownRef = EntIndexToEntRef(crown);
}

public void TF2Jail2_OnWardenRemoved_Post(int old_warden, int admin)
{
	KillCrown();
}

public void OnGameFrame()
{
	int crown = EntRefToEntIndex(g_iCrownRef);
	if (crown == INVALID_ENT_REFERENCE)
	{
		return;
	}
	
	int warden = TF2Jail2_GetWarden();
	if (warden <= 0)
	{
		return;
	}
	
	float vec[3];
	GetClientAbsOrigin(warden, vec);
	vec[2] += 80.0;
	TeleportEntity(crown, vec, NULL_VECTOR, NULL_VECTOR);
}

int CreateCrown()
{
	int crown = CreateEntityByName("prop_dynamic_override");
	if (crown == INVALID_ENT_REFERENCE)
	{
		return -1;
	}
	
	SetEntityModel(crown, MODEL_CROWN);

	DispatchSpawn(crown);
	
	SetEntData(crown, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
	
	SetEntPropFloat(crown, Prop_Send, "m_flModelScale", 0.5);
	
	SetEntProp(crown, Prop_Send, "m_nSequence", 0);
	SetVariantString("spin");
	AcceptEntityInput(crown, "SetAnimation");
	AcceptEntityInput(crown, "Enable");
	
	return crown;
}

bool KillCrown()
{
	int crown = EntRefToEntIndex(g_iCrownRef);
	if (crown != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(crown, "Kill");
	}
	
	return true;
}