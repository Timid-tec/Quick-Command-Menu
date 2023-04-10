#if defined _timid_included
#endinput
#endif
#define _timid_included

#define PLUGIN_AUTHOR "Timid"
#define PLUGIN_VERSION "4.2.0"

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

bool g_bWarmup_Round = false;

int GrenadesAll[] = { 15, 17, 16, 14, 18, 17 };


stock void ClearTimer2(Handle timer)
{
	if (timer != null)
	{
		KillTimer(timer);
		timer = null;
	}
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

public float IntToFloat(int integer) {
	char s[300];
	IntToString(integer, s, sizeof(s));
	return StringToFloat(s);
} 