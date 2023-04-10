/*  [CS:GO] Quick-Command-Menu: Quick menu for easy configuration.
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

public Plugin myinfo = 
{
	name = "Quick-Command-Menu", 
	author = PLUGIN_AUTHOR, 
	description = "Quick Command Menu configure plugin all inside (configs/quickcommands.cfg)", 
	version = "4.2.1", 
	url = "https://steamcommunity.com/id/MrTimid/"
}


/* Global Handles */
Handle gMenu;
Handle kv;

char gCmdResponse[128][256];

public void OnPluginStart()
{
	RegConsoleCmd("sm_qc", Menu_QuickCommand, "Opens the Quick-Command menu");
	
	/* load the key values on plugin start */
	ParseKV();
}

public Action Menu_QuickCommand(int client, int args)
{
	DisplayMenu(gMenu, client, 15);
	
	return Plugin_Handled;
}

public int MenuHandler1(Menu menu, MenuAction action, int client, int choice)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char info[256];
			char buffer[256];
			Format(buffer, sizeof(buffer), "%s", gCmdResponse[choice]);
			menu.GetItem(choice, info, sizeof(info));
			//Item = GetMenuSelectionPosition();
			FakeClientCommand(client, info);
			//PrintToChatAll("[QCDebug] choice = %i buffer = %s", choice, buffer);
			PrintToChat(client, buffer);
		}
		case MenuAction_End:
		{
			
		}
	}
	
	return 0;
}

public void ParseKV()
{
	/* find the path */
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "configs/quickcommands.cfg");
	
	kv = CreateKeyValues("quickcommands");
	FileToKeyValues(kv, path);
	
	if (!KvGotoFirstSubKey(kv))
	{
		SetFailState("Unable to find config section in file %s", path);
		return;
	}
	
	
	
	gMenu = CreateMenu(MenuHandler1);
	int cmdNum = 0;
	//char sCmdNum = 0;
	char cmdCMD[32];
	char cmdName[32];
	char cmdResponse[128];
	
	do {
		//IntToString(cmdNum, sCmdNum, sizeof(sCmdNum);
		//KvGetSectionName(kv, sCmdNum, sizeof(sCmdNum));
		KvGetString(kv, "name", cmdName, sizeof(cmdName));
		KvGetString(kv, "command", cmdCMD, sizeof(cmdCMD));
		KvGetString(kv, "chatprint", cmdResponse, sizeof(cmdResponse));
		
		//PrintToChatAll("%s", cmdResponse);
		
		SetMenuTitle(gMenu, "Quick Commands");
		AddMenuItem(gMenu, cmdCMD, cmdName);
		Format(gCmdResponse[cmdNum], sizeof(cmdResponse), cmdResponse);
		cmdNum++;
	} while (KvGotoNextKey(kv));
	CloseHandle(kv);
} 