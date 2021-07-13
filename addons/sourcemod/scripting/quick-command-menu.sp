#include <sourcemod>
#include <cstrike>
#include <timid>
#include <multicolors>

public Plugin myinfo = 
{
	name = "Quick Command Menu", 
	author = PLUGIN_AUTHOR, 
	description = "Increase HE Nade Damge and radius", 
	version = PLUGIN_VERSION, 
	url = ""
}


/* Char Values */
char qcpath[PLATFORM_MAX_PATH];

/* Int Values */
Item = 0;

public void OnPluginStart()
{
	RegConsoleCmd("sm_qctest", Menu_Test1);
	
	BuildPath(Path_SM, qcpath, sizeof(qcpath), "configs/quickcommands.cfg");
}

public Action Menu_Test1(int client, int args)
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
		Menu_Test1(param1, Item);
	}
}
