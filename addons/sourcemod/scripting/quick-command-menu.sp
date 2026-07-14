/*
 * Quick Command Menu
 * Copyright (C) 2021-2026 Timid
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option)
 * any later version.
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

#define PLUGIN_VERSION "4.3.0"
#define CONFIG_FILE "configs/quickcommands.cfg"
#define MENU_DISPLAY_TIME 15
#define QCM_MAX_ITEM_NAME 128
#define QCM_MAX_COMMAND 256
#define QCM_MAX_CHAT_MESSAGE 512

public Plugin myinfo =
{
	name = "Quick Command Menu",
	author = "Timid",
	description = "Provides a configurable menu for client commands and chat messages",
	version = PLUGIN_VERSION,
	url = "https://github.com/Timid-tec/Quick-Command-Menu"
};

Menu g_QuickCommandMenu = null;
ArrayList g_Commands = null;
ArrayList g_ChatMessages = null;

public void OnPluginStart()
{
	RegConsoleCmd("sm_qc", Command_QuickCommandMenu, "Opens the Quick Command Menu");
	RegAdminCmd("sm_qc_reload", Command_ReloadQuickCommands, ADMFLAG_CONFIG,
		"Reloads configs/quickcommands.cfg");

	char error[PLATFORM_MAX_PATH + 64];
	if (!LoadQuickCommands(error, sizeof(error)))
	{
		SetFailState("%s", error);
	}
}

public void OnPluginEnd()
{
	DestroyMenuData(false);
}

public Action Command_QuickCommandMenu(int client, int args)
{
	if (client <= 0)
	{
		ReplyToCommand(client, "[QCM] This command is only available to in-game clients.");
		return Plugin_Handled;
	}

	if (!IsClientInGame(client))
	{
		return Plugin_Handled;
	}

	if (g_QuickCommandMenu == null || !g_QuickCommandMenu.Display(client, MENU_DISPLAY_TIME))
	{
		ReplyToCommand(client, "[QCM] The Quick Command Menu is currently unavailable.");
	}

	return Plugin_Handled;
}

public Action Command_ReloadQuickCommands(int client, int args)
{
	char error[PLATFORM_MAX_PATH + 64];
	if (!LoadQuickCommands(error, sizeof(error)))
	{
		ReplyToCommand(client, "[QCM] Reload failed: %s", error);
		return Plugin_Handled;
	}

	ReplyToCommand(client, "[QCM] Reloaded %d quick command(s).", g_Commands.Length);
	return Plugin_Handled;
}

public int MenuHandler_QuickCommand(Menu menu, MenuAction action, int client, int selection)
{
	if (action != MenuAction_Select || !IsValidMenuClient(client))
	{
		return 0;
	}

	char itemInfo[16];
	if (!menu.GetItem(selection, itemInfo, sizeof(itemInfo)))
	{
		LogError("Could not read menu item %d.", selection);
		return 0;
	}

	int itemIndex = StringToInt(itemInfo);
	if (g_Commands == null || g_ChatMessages == null
		|| itemIndex < 0 || itemIndex >= g_Commands.Length
		|| itemIndex >= g_ChatMessages.Length)
	{
		LogError("Menu item %d references invalid action index %d.", selection, itemIndex);
		return 0;
	}

	char command[QCM_MAX_COMMAND];
	g_Commands.GetString(itemIndex, command, sizeof(command));
	if (command[0] != '\0')
	{
		FakeClientCommand(client, "%s", command);
	}

	char chatMessage[QCM_MAX_CHAT_MESSAGE];
	g_ChatMessages.GetString(itemIndex, chatMessage, sizeof(chatMessage));
	if (chatMessage[0] != '\0')
	{
		PrintToChat(client, "%s", chatMessage);
	}

	return 0;
}

bool LoadQuickCommands(char[] error, int errorLength)
{
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), CONFIG_FILE);

	KeyValues config = new KeyValues("quickcommand");
	if (!config.ImportFromFile(path))
	{
		Format(error, errorLength, "Unable to read %s", path);
		delete config;
		return false;
	}

	if (!config.GotoFirstSubKey())
	{
		Format(error, errorLength, "No command sections were found in %s", path);
		delete config;
		return false;
	}

	Menu newMenu = new Menu(MenuHandler_QuickCommand);
	newMenu.SetTitle("Quick Commands");

	ArrayList newCommands = new ArrayList(ByteCountToCells(QCM_MAX_COMMAND));
	ArrayList newChatMessages = new ArrayList(ByteCountToCells(QCM_MAX_CHAT_MESSAGE));

	int loadedCount = 0;
	do
	{
		char section[64];
		char itemName[QCM_MAX_ITEM_NAME];
		char command[QCM_MAX_COMMAND];
		char chatMessage[QCM_MAX_CHAT_MESSAGE];

		config.GetSectionName(section, sizeof(section));
		config.GetString("name", itemName, sizeof(itemName));
		config.GetString("command", command, sizeof(command));
		config.GetString("chatprint", chatMessage, sizeof(chatMessage));

		TrimString(itemName);
		TrimString(command);
		TrimString(chatMessage);

		if (itemName[0] == '\0')
		{
			LogError("Skipping quick command section \"%s\": missing \"name\".", section);
			continue;
		}

		if (command[0] == '\0' && chatMessage[0] == '\0')
		{
			LogError("Skipping quick command section \"%s\": add \"command\", \"chatprint\", or both.", section);
			continue;
		}

		if (StrContains(command, "\n") != -1 || StrContains(command, "\r") != -1)
		{
			LogError("Skipping quick command section \"%s\": command contains a line break.", section);
			continue;
		}

		ApplyChatColorTokens(chatMessage, sizeof(chatMessage));

		char itemInfo[16];
		IntToString(loadedCount, itemInfo, sizeof(itemInfo));
		if (!newMenu.AddItem(itemInfo, itemName))
		{
			LogError("Skipping quick command section \"%s\": the menu item could not be added.", section);
			continue;
		}

		newCommands.PushString(command);
		newChatMessages.PushString(chatMessage);
		loadedCount++;
	}
	while (config.GotoNextKey());

	delete config;

	if (loadedCount == 0)
	{
		Format(error, errorLength, "No valid quick commands were found in %s", path);
		delete newMenu;
		delete newCommands;
		delete newChatMessages;
		return false;
	}

	DestroyMenuData(true);
	g_QuickCommandMenu = newMenu;
	g_Commands = newCommands;
	g_ChatMessages = newChatMessages;

	LogMessage("Loaded %d quick command(s) from %s.", loadedCount, path);
	return true;
}

void DestroyMenuData(bool cancelMenu)
{
	if (g_QuickCommandMenu != null)
	{
		if (cancelMenu)
		{
			g_QuickCommandMenu.Cancel();
		}

		delete g_QuickCommandMenu;
		g_QuickCommandMenu = null;
	}

	delete g_Commands;
	g_Commands = null;

	delete g_ChatMessages;
	g_ChatMessages = null;
}

bool IsValidMenuClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client);
}

void ApplyChatColorTokens(char[] message, int maxLength)
{
	ReplaceString(message, maxLength, "{default}", "\x01", false);
	ReplaceString(message, maxLength, "{darkred}", "\x02", false);
	ReplaceString(message, maxLength, "{green}", "\x04", false);
	ReplaceString(message, maxLength, "{lightgreen}", "\x05", false);
	ReplaceString(message, maxLength, "{red}", "\x07", false);
	ReplaceString(message, maxLength, "{blue}", "\x0C", false);
	ReplaceString(message, maxLength, "{olive}", "\x05", false);
	ReplaceString(message, maxLength, "{lime}", "\x06", false);
	ReplaceString(message, maxLength, "{lightred}", "\x07", false);
	ReplaceString(message, maxLength, "{purple}", "\x0E", false);
	ReplaceString(message, maxLength, "{grey}", "\x08", false);
	ReplaceString(message, maxLength, "{gray}", "\x08", false);
	ReplaceString(message, maxLength, "{yellow}", "\x09", false);
	ReplaceString(message, maxLength, "{orange}", "\x10", false);
	ReplaceString(message, maxLength, "{bluegrey}", "\x0A", false);
	ReplaceString(message, maxLength, "{bluegray}", "\x0A", false);
	ReplaceString(message, maxLength, "{lightblue}", "\x0B", false);
	ReplaceString(message, maxLength, "{darkblue}", "\x0C", false);
	ReplaceString(message, maxLength, "{grey2}", "\x0D", false);
	ReplaceString(message, maxLength, "{gray2}", "\x0D", false);
	ReplaceString(message, maxLength, "{orchid}", "\x0E", false);
	ReplaceString(message, maxLength, "{lightred2}", "\x0F", false);
}
