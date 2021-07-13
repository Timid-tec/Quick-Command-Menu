/*  [CS:GO] Quick-Command-Menu, quick menu for easy configuration.
 *
 *  Copyright (C) 2021 Mr.Timid // timidexempt@gmail.com
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod>
#include <cstrike>
#include <timid>
#include <multicolors>

public Plugin myinfo = 
{
	name = "Quick Command Menu", 
	author = PLUGIN_AUTHOR, 
	description = "Quick Command Menu configure plugin all inside (configs/quickcommands.cfg)", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/MrTimid/"
}


/* Char Values */
char qcpath[PLATFORM_MAX_PATH];

/* Int Values */
Item = 0;

public void OnPluginStart()
{
	RegConsoleCmd("sm_qc", Menu_QuickCommand, "Opens the Quick-Command menu");
	
	BuildPath(Path_SM, qcpath, sizeof(qcpath), "configs/quickcommands.cfg");
}

public Action Menu_QuickCommand(int client, int args)
{
	Handle QuickCommandMenu = CreateMenu(MenuHandler1);
	SetMenuTitle(QuickCommandMenu, "Quick Commands");
	
	Handle kv = CreateKeyValues("quickcommands");
	FileToKeyValues(kv, qcpath);
	
	if (!KvGotoFirstSubKey(kv))
	{
		return Plugin_Continue;
	}
	char QuickCommandNumber[64];
	char QuickCommandName[256];
	
	do
	{
		KvGetSectionName(kv, QuickCommandNumber, sizeof(QuickCommandNumber));
		KvGetString(kv, "name", QuickCommandName, sizeof(QuickCommandName));
		
		AddMenuItem(QuickCommandMenu, QuickCommandNumber, QuickCommandName);
		
		
	} while (KvGotoNextKey(kv));
	CloseHandle(kv);
	
	DisplayMenuAtItem(QuickCommandMenu, client, args, 15);
	
	return Plugin_Handled;
}

public int MenuHandler1(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		Handle kv = CreateKeyValues("quickcommands");
		FileToKeyValues(kv, qcpath);
		
		if (!KvGotoFirstSubKey(kv))
		{
			CloseHandle(menu);
		}
		
		char buffer[256];
		char choice[256];
		GetMenuItem(menu, param2, choice, sizeof(choice));
		
		do
		{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			if (StrEqual(buffer, choice))
			{
				char quickCommand[256];
				char quickCommandName[256];
				char quickCommandChat[256];
				KvGetString(kv, "name", quickCommandName, sizeof(quickCommandName));
				KvGetString(kv, "command", quickCommand, sizeof(quickCommand));
				KvGetString(kv, "chatprint", quickCommandChat, sizeof(quickCommandChat));
				
				Item = GetMenuSelectionPosition();
				LoopIngameClients(i)
				{
					FakeClientCommand(i, quickCommand);
					CPrintToChat(i, quickCommandChat);
				}
				
			}
		} while (KvGotoNextKey(kv));
		CloseHandle(kv);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}


public HandlerBackToMenu(Handle menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		Menu_QuickCommand(param1, Item);
	}
}
