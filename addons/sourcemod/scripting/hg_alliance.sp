#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required // let's go new syntax! 

int equipo[MAXPLAYERS+1];
int icon[MAXPLAYERS+1];

Handle array_icons_base;
Handle array_icons;

Handle cvar_hp, cvar_grenade;

#define DATA "1.1"
public Plugin myinfo =
{
	name = "Hunger Games Alliance",
	author = "Franc1sco franug",
	description = "",
	version = DATA,
	url = "http://steamcommunity.com/id/franug"
};

public void OnPluginStart()
{
	CreateConVar("sm_hgalliance_version", DATA, "", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	array_icons_base = CreateArray();
	array_icons = CreateArray();

	HookEvent("round_start", Event_Start);
	HookEvent("player_death", event_Death, EventHookMode_Pre);
	
	cvar_hp = CreateConVar("sm_hgalliance_hp", "1", "Enable or disable earn health");
	cvar_grenade = CreateConVar("sm_hgalliance_grenade", "1", "Enable or disable the give grenades feature");
	
}

public void OnMapStart()
{
	ClearArray(array_icons_base);

	AddFileToDownloadsTable("materials/sprites/hg2/districts/3_icon.vmt");
	AddFileToDownloadsTable("materials/sprites/hg2/districts/3_icon.vtf");

	AddFileToDownloadsTable("materials/sprites/hg2/districts/5_icon.vmt");
	AddFileToDownloadsTable("materials/sprites/hg2/districts/5_icon.vtf");

	AddFileToDownloadsTable("materials/sprites/hg2/districts/6_icon.vmt");
	AddFileToDownloadsTable("materials/sprites/hg2/districts/6_icon.vtf");

	AddFileToDownloadsTable("materials/sprites/hg2/districts/7_icon.vmt");
	AddFileToDownloadsTable("materials/sprites/hg2/districts/7_icon.vtf");

	AddFileToDownloadsTable("materials/sprites/hg2/districts/8_icon.vmt");
	AddFileToDownloadsTable("materials/sprites/hg2/districts/8_icon.vtf");

	AddFileToDownloadsTable("materials/sprites/hg2/districts/9_icon.vmt");
	AddFileToDownloadsTable("materials/sprites/hg2/districts/9_icon.vtf");

	AddFileToDownloadsTable("materials/sprites/hg2/districts/10_icon.vmt");
	AddFileToDownloadsTable("materials/sprites/hg2/districts/10_icon.vtf");
		
	AddFileToDownloadsTable("materials/sprites/hg2/districts/11_icon.vmt");
	AddFileToDownloadsTable("materials/sprites/hg2/districts/11_icon.vtf");

	AddFileToDownloadsTable("materials/sprites/hg2/districts/12_icon.vmt");
	AddFileToDownloadsTable("materials/sprites/hg2/districts/12_icon.vtf");

	PrecacheModel("materials/sprites/hg2/districts/3_icon.vmt");
	PushArrayCell(array_icons_base, 3);

	PrecacheModel("materials/sprites/hg2/districts/5_icon.vmt");
	PushArrayCell(array_icons_base, 5);

	PrecacheModel("materials/sprites/hg2/districts/6_icon.vmt");
	PushArrayCell(array_icons_base, 6);

	PrecacheModel("materials/sprites/hg2/districts/7_icon.vmt");
	PushArrayCell(array_icons_base, 7);

	PrecacheModel("materials/sprites/hg2/districts/8_icon.vmt");
	PushArrayCell(array_icons_base, 8);

	PrecacheModel("materials/sprites/hg2/districts/9_icon.vmt");
	PushArrayCell(array_icons_base, 9);

	PrecacheModel("materials/sprites/hg2/districts/10_icon.vmt");
	PushArrayCell(array_icons_base, 10);
		
	PrecacheModel("materials/sprites/hg2/districts/11_icon.vmt");
	PushArrayCell(array_icons_base, 11);

	PrecacheModel("materials/sprites/hg2/districts/12_icon.vmt");
	PushArrayCell(array_icons_base, 12);

}

public Action Event_Start(Handle event, char[] name, bool dontBroadcast)
{
	array_icons = CloneArray(array_icons_base);
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
		{
			equipo[i] = 0;
			LimpiarAdjunto(i);
		}
}

public Action event_Death(Handle event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	LimpiarAdjunto(client);
	
	if(!GetConVarBool(cvar_hp)) return;
	
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(IsValidClient(attacker) && equipo[client] != 0)
	{
		int vida = GetClientHealth(attacker);

		if(equipo[attacker] == equipo[client]) vida += 15;
		else if(equipo[attacker] == 0) vida += 5;

		if(vida > 115) vida = 115;

		SetEntityHealth(attacker, vida);
	}
}

public bool IsValidClient( int client )
{
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) )
        return false;

    return true;
}

void LimpiarAdjunto(int client)
{
	if(icon[client] > 0 && IsValidEntity(icon[client]))
	{
		//SDKUnhook(icon[client], SDKHook_SetTransmit, Hook_SetTransmit);
		AcceptEntityInput(icon[client], "Kill");
	}
	icon[client] = 0;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3])
{
	if(!IsClientInGame(client)) return;

	if(buttons & IN_USE)
	{
		int entidad = GetClientAimTarget(client);
		if(entidad > 0)
		{
			if(equipo[entidad] != 0) return;
			//if(equipo[client] == equipo[entidad] && equipo[entidad] != 0) return;

			if(GetClientAimTarget(entidad) != client) return;

			float OriginG[3], TargetOriginG[3];
			GetClientEyePosition(client, TargetOriginG);
			GetClientEyePosition(entidad, OriginG);
			if(GetVectorDistance(TargetOriginG,OriginG, false) > 200.0) return;

			PrintCenterText(client, "Sending team request to %N", entidad);
			PrintCenterText(entidad, "Player %N are sending a team request to you.\nFor accept just press +USE (E button).", client);
			if(!(GetClientButtons(entidad) & IN_USE)) return;

			HacerEquipo(client, entidad);
		}
	}
}

void HacerEquipo(int client, int target)
{
	if(equipo[client] == 0 && equipo[target] == 0)
	{
		if(GetArraySize(array_icons) == 0)
		{
			PrintToChat(client, "The max amount of teams have been reached.");
			PrintToChat(target, "The max amount of teams have been reached.");

			return;
		}

		int aleatorio = GetRandomInt(0, GetArraySize(array_icons)-1);
		int equipos = GetArrayCell(array_icons, aleatorio);
		RemoveFromArray(array_icons, aleatorio);

		equipo[client] = equipos;
		equipo[target] = equipos;

		icon[client] = CreateIcon(client);
		icon[target] = CreateIcon(target);

		GanarGranada(client);
		GanarGranada(target);

		PrintToChat(client, "Team request accepted by %N.", target);
		PrintToChat(target, "Team request accepted by %N.", client);
	}
	else
	{
		PrintToChat(client, "Team request accepted by %N.", target);
		PrintToChat(target, "Team request accepted by %N.", client);
		equipo[target] = equipo[client];
		icon[target] = CreateIcon(target);
	}
}

int CreateIcon(int client)
{
	LimpiarAdjunto(client);
	char iTarget[16];
	Format(iTarget, 16, "client%d", client);
	DispatchKeyValue(client, "targetname", iTarget);

	float origin[3];

	GetClientAbsOrigin(client, origin);
	origin[2] = origin[2] + 80.0;

	int Ent = CreateEntityByName("env_sprite");
	if(!Ent) return -1;

	char valor[4], sprite[64];
	Format(valor, 4, "%i", equipo[client]);
	Format(sprite, 64, "sprites/hg2/districts/%i_icon.vmt", equipo[client]);
		
	DispatchKeyValue(Ent, "model", sprite);
	DispatchKeyValue(Ent, "classname", valor);
	DispatchKeyValue(Ent, "spawnflags", "1");
	DispatchKeyValue(Ent, "scale", "0.08");
	DispatchKeyValue(Ent, "rendermode", "1");
	DispatchKeyValue(Ent, "rendercolor", "255 255 255");
	DispatchSpawn(Ent);
	TeleportEntity(Ent, origin, NULL_VECTOR, NULL_VECTOR);
	SetVariantString(iTarget);
	AcceptEntityInput(Ent, "SetParent", Ent, Ent, 0);

	//SDKHook(Ent, SDKHook_SetTransmit, Hook_SetTransmit);
	return Ent;
}

/* public Action:Hook_SetTransmit(entity, client)
{
	if (entity == client) return Plugin_Continue;

	decl String:name[32];
	//GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));
	GetEdictClassname(entity, name, sizeof(name));

	if(equipo[client] == StringToInt(name)) return Plugin_Continue;

	return Plugin_Handled;
}   */

void GanarGranada(int client)
{
	if(!GetConVarBool(cvar_grenade)) return;
	int aleatorio = GetRandomInt(1, 100);
	if(aleatorio == 1) GivePlayerItem(client, "weapon_hegrenade");
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(!attacker || !IsValidClient(attacker)) return Plugin_Continue;

	if(equipo[attacker] == 0 && equipo[client] != 0)
	{
		damage = (damage * 1.05);
		return Plugin_Changed;
	}

	return Plugin_Continue;
}


