#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

new equipo[MAXPLAYERS+1];
new icon[MAXPLAYERS+1];

new Handle:array_icons_base;
new Handle:array_icons;

public Plugin:myinfo =
{
        name = "Hunger Games Teams",
        author = "Franc1sco franug",
        description = "",
        version = "1.0.0",
        url = "http://steamcommunity.com/id/franug"
};

public OnPluginStart()
{
        array_icons_base = CreateArray();
        array_icons = CreateArray();

        HookEvent("round_start", Event_Start);
        HookEvent("player_death", event_Death, EventHookMode_Pre);
}

public OnMapStart()
{
        ClearArray(array_icons_base);

        AddFileToDownloadsTable("materials/sprites/hg/districts/3_icon.vmt");
        AddFileToDownloadsTable("materials/sprites/hg/districts/3_icon.vtf");

        AddFileToDownloadsTable("materials/sprites/hg/districts/5_icon.vmt");
        AddFileToDownloadsTable("materials/sprites/hg/districts/5_icon.vtf");

        AddFileToDownloadsTable("materials/sprites/hg/districts/6_icon.vmt");
        AddFileToDownloadsTable("materials/sprites/hg/districts/6_icon.vtf");

        AddFileToDownloadsTable("materials/sprites/hg/districts/7_icon.vmt");
        AddFileToDownloadsTable("materials/sprites/hg/districts/7_icon.vtf");

        AddFileToDownloadsTable("materials/sprites/hg/districts/8_icon.vmt");
        AddFileToDownloadsTable("materials/sprites/hg/districts/8_icon.vtf");

        AddFileToDownloadsTable("materials/sprites/hg/districts/9_icon.vmt");
        AddFileToDownloadsTable("materials/sprites/hg/districts/9_icon.vtf");

        AddFileToDownloadsTable("materials/sprites/hg/districts/10_icon.vmt");
        AddFileToDownloadsTable("materials/sprites/hg/districts/10_icon.vtf");
		
        AddFileToDownloadsTable("materials/sprites/hg/districts/11_icon.vmt");
        AddFileToDownloadsTable("materials/sprites/hg/districts/11_icon.vtf");

        AddFileToDownloadsTable("materials/sprites/hg/districts/12_icon.vmt");
        AddFileToDownloadsTable("materials/sprites/hg/districts/12_icon.vtf");

        PrecacheModel("materials/sprites/hg/districts/3_icon.vmt");
        PushArrayCell(array_icons_base, 3);

        PrecacheModel("materials/sprites/hg/districts/5_icon.vmt");
        PushArrayCell(array_icons_base, 5);

        PrecacheModel("materials/sprites/hg/districts/6_icon.vmt");
        PushArrayCell(array_icons_base, 6);

        PrecacheModel("materials/sprites/hg/districts/7_icon.vmt");
        PushArrayCell(array_icons_base, 7);

        PrecacheModel("materials/sprites/hg/districts/8_icon.vmt");
        PushArrayCell(array_icons_base, 8);

        PrecacheModel("materials/sprites/hg/districts/9_icon.vmt");
        PushArrayCell(array_icons_base, 9);

        PrecacheModel("materials/sprites/hg/districts/10_icon.vmt");
        PushArrayCell(array_icons_base, 10);
		
        PrecacheModel("materials/sprites/hg/districts/11_icon.vmt");
        PushArrayCell(array_icons_base, 11);

        PrecacheModel("materials/sprites/hg/districts/12_icon.vmt");
        PushArrayCell(array_icons_base, 12);

}

public Action:Event_Start(Handle:event, const String:name[], bool:dontBroadcast)
{
        array_icons = CloneArray(array_icons_base);
        for(new i = 1; i <= MaxClients; i++)
                if(IsClientInGame(i))
                {
                        equipo[i] = 0;
                        LimpiarAdjunto(i);
                }
}

public Action:event_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
        new client = GetClientOfUserId(GetEventInt(event, "userid"));
        LimpiarAdjunto(client);

        new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
        if(IsValidClient(attacker) && equipo[client] != 0)
        {
                new vida = GetClientHealth(attacker);

                if(equipo[attacker] == equipo[client]) vida += 15;
                else if(equipo[attacker] == 0) vida += 5;

                if(vida > 115) vida = 115;

                SetEntityHealth(attacker, vida);
        }
}

public IsValidClient( client )
{
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) )
        return false;

    return true;
}

LimpiarAdjunto(client)
{
        if(icon[client] > 0 && IsValidEntity(icon[client]))
        {
                //SDKUnhook(icon[client], SDKHook_SetTransmit, Hook_SetTransmit);
                AcceptEntityInput(icon[client], "Kill");
        }
        icon[client] = 0;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3])
{
        if(!IsClientInGame(client)) return;

        if(buttons & IN_USE)
        {
                new entidad = GetClientAimTarget(client);
                if(entidad > 0)
                {
                        if(equipo[entidad] != 0) return;
                        //if(equipo[client] == equipo[entidad] && equipo[entidad] != 0) return;

                        if(GetClientAimTarget(entidad) != client) return;

                        decl Float:OriginG[3],Float:TargetOriginG[3];
                        GetClientEyePosition(client, TargetOriginG);
                        GetClientEyePosition(entidad, OriginG);
                        if(GetVectorDistance(TargetOriginG,OriginG, false) > 200.0) return;

                        PrintHintText(client, "Sending team request to %N", entidad);
                        if(!(GetClientButtons(entidad) & IN_USE)) return;

                        HacerEquipo(client, entidad);
                }
        }
}

HacerEquipo(client, target)
{
        if(equipo[client] == 0 && equipo[target] == 0)
        {
                if(GetArraySize(array_icons) == 0)
                {
                        PrintToChat(client, "The max amount of teams have been reached.");
                        PrintToChat(target, "The max amount of teams have been reached.");

                        return;
                }

                new aleatorio = GetRandomInt(0, GetArraySize(array_icons)-1);
                new equipos = GetArrayCell(array_icons, aleatorio);
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

CreateIcon(client)
{
        LimpiarAdjunto(client);
        decl String:iTarget[16];
        Format(iTarget, 16, "client%d", client);
        DispatchKeyValue(client, "targetname", iTarget);

        decl Float:origin[3];

        GetClientAbsOrigin(client, origin);
        origin[2] = origin[2] + 80.0;

        new Ent = CreateEntityByName("env_sprite");
        if(!Ent) return -1;

        decl String:valor[4], String:sprite[64];
        Format(valor, 4, "%i", equipo[client]);
        Format(sprite, 64, "sprites/hg/districts/%i_icon.vmt", equipo[client]);
		
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

GanarGranada(client)
{
        new aleatorio = GetRandomInt(1, 100);
        if(aleatorio == 1) GivePlayerItem(client, "weapon_hegrenade");
}

public OnClientPutInServer(client)
{
        SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
        if(!attacker || !IsValidClient(attacker)) return Plugin_Continue;

        if(equipo[attacker] == 0 && equipo[client] != 0)
        {
                damage = (damage * 1.05);
                return Plugin_Changed;
        }

        return Plugin_Continue;
}


