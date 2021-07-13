#if defined _crabstocks_included
#endinput
#endif
#define _crabstocks_included
#pragma semicolon 1
#pragma newdecls required

#define MSG_LENGTH 192
#define PI 3.1415926535897932384626433832795
#define PLUGIN_AUTHOR "Timid"
#define PLUGIN_VERSION "4.2.0"
#define PREFIX "[SM]"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++)

#define LoopIngameClients(%1) for(int %1=1;%1<=MaxClients;%1++)\
if (IsClientInGame(%1))
	
#define LoopIngamePlayers(%1) for(int %1=1;%1<=MaxClients;%1++)\
if (IsClientInGame(%1) && !IsFakeClient(%1))
	
#define LoopAlivePlayers(%1) for(int %1=1;%1<=MaxClients;%1++)\
if (IsClientInGame(%1) && IsPlayerAlive(%1))


char g_ColorCheck[][] =  {"{normal}", "{darkred}", "{pink}", "{green}", "{yellow}", "{lightgreen}", "{lightred}", "{grey}", "{orange}", "{lightblue}", "{darkblue}", "{purple}"};
char g_ColorReplace[][] =  {"\x01", "\x02", "\x03", "\x04", "\x05", "\x06", "\x07", "\x08", "\x09", "\x0B", "\x0C", "\x0E"};

bool g_bWarmup_Round = false;

int GrenadesAll[] =  {15, 17, 16, 14, 18, 17};

stock void HookEvents()
{
	HookEvent("round_start", Event_Round_Start, EventHookMode_Pre);
	HookEvent("round_end", Event_Round_End, EventHookMode_Pre);
	HookEvent("player_spawn", Event_Player_Spawn);
	HookEvent("player_death", Event_Player_Death);
}
/*
public Action Event_Round_Start(Event event, const char[] name, bool dontBroadcast)
{
	return Plugin_Continue;
}
public Action Event_Round_End(Event event, const char[] name, bool dontBroadcast)
{
	return Plugin_Continue;
}
public Action Event_Player_Spawn(Event event, const char[] name, bool dontBroadcast)
{
	return Plugin_Continue;
}
public Action Event_Player_Death(Event event, const char[] name, bool dontBroadcast)
{
	return Plugin_Continue;
}
*/

stock void ClearTimer2(Handle timer)
{
	if (timer != null)
	{
		KillTimer(timer);
		timer = null;
	}
} 
stock void CPrintToChatAll(char[] msg)
{
	char message[MSG_LENGTH]; 
	strcopy(message, sizeof(message), msg);
	
	for (int k = 0; k < sizeof(g_ColorCheck); k++)
	{
		if (StrContains(message, g_ColorCheck[k]) != -1)
		{
			ReplaceString(message, sizeof(message), g_ColorCheck[k], g_ColorReplace[k]);
		}
	}
	PrintToChatAll("\x01\x0B%s",message);
}

stock bool IsWarmup()
{
	if (GameRules_GetProp("m_bWarmupPeriod") == 1) {
		g_bWarmup_Round = true;
		return true;
	}
	else if (GameRules_GetProp("m_bWarmupPeriod") == 0) {
		g_bWarmup_Round = false;
		return false;
	}
	return g_bWarmup_Round;
}

stock int GetEventClient(Event event)
{
	 return GetClientOfUserId(event.GetInt("userid"));
}

stock bool IsValidClient(int client, bool alive = false)
{
	if (0 < client && client <= MaxClients && IsClientInGame(client) && IsFakeClient(client) == false && (alive == false || IsPlayerAlive(client)))
	{
		return true;
	}
	return false;
}
stock void cRemoveWeapons(bool leavec4 = true) 
{
	LoopAlivePlayers(k)
	{
			int primary = GetPlayerWeaponSlot(k, 0);
			int secondary = GetPlayerWeaponSlot(k, 1);
			int knife = GetPlayerWeaponSlot(k, 2);
			if (primary > 0) 
			{
				RemovePlayerItem(k, primary);
				RemoveEdict(primary);
			}
			
			if (secondary > 0) 
			{
				RemovePlayerItem(k, secondary);
				RemoveEdict(secondary);
			}
			if (!leavec4)
			{
				int c4medi = GetPlayerWeaponSlot(k, 4);
				if (c4medi > 0) 
				{
					RemovePlayerItem(k, c4medi);
					RemoveEdict(c4medi);
				}
			}
			if (knife == -1)
			{
				GivePlayerItem(k, "weapon_knife");
			}
		}
}
stock void RemoveWeapons(int client, bool leavec4 = true) 
{
		int primary = GetPlayerWeaponSlot(client, 0);
		int secondary = GetPlayerWeaponSlot(client, 1);
		int knife = GetPlayerWeaponSlot(client, 2);
		if (primary > 0) 
		{
			RemovePlayerItem(client, primary);
			RemoveEdict(primary);
		}
		
		if (secondary > 0) 
		{
			RemovePlayerItem(client, secondary);
			RemoveEdict(secondary);
		}
		if (!leavec4)
		{
			int c4medi = GetPlayerWeaponSlot(client, 4);
			if (c4medi > 0) 
			{
				RemovePlayerItem(client, c4medi);
				RemoveEdict(c4medi);
			}
		}
		if (knife == -1)
		{
			GivePlayerItem(client, "weapon_knife");
		}
}
stock void RemoveNades() 
{
	LoopAlivePlayers(k)
	{
		for (int i = 0; i < 6; i++) {
			SetEntProp(k, Prop_Send, "m_iAmmo", 0, _, GrenadesAll[i]);
		}
	}
}

public float IntToFloat(int integer){
	char s[300];
	IntToString(integer,s,sizeof(s));
	return StringToFloat(s);
}