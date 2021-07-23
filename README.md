# Quick-Command-Menu
A source mod plugin simply made to make a quick-command menu easily changeable.

# Custom Types for menu
- name: Item name to display in menu
- command: Fake client command
- chatprint: Print chat message

# Usable colors
- {default}, {darkred}, {green}, {red}, {blue}, {lime}, {lightred}, {purple}, {grey}, {yellow}, {orange}. {bluegrey}, {lightblue}, {darkblue}, {grey2}, {lightred2}

# Game Supported
- CS:GO

# How to Install
- Donwload Quick-Command-Menu.smx and put into /csgo/addons/sourcemod/plugins
- Configure settings by editing /addons/sourcemod/configs/quickcommands.cfg
# Example

		"quickcommand"
		{
			"1"
			{
				"name" "!rules"
				"command" "sm_rules"
			}
			"2"
			{
				"name" "!discord"
				"chatprint" "{grey}「{purple}MoonGlow{grey}」 {purple}https://discord.com/invite/Y9t9tA3"
			}
		}

# Updates

| Version | Change-Log          |
| ------- | ------------------ |
| 4.2.1   | Fix plugin to be less memory enticing|
| 4.2.0   | Added plugin to GitHub|

