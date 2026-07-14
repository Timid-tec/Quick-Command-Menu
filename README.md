# Quick Command Menu

A lightweight SourceMod plugin for CS:GO that builds an in-game command menu from a KeyValues configuration file.

## Features

- Opens a configurable menu with `sm_qc` (or `!qc` in chat).
- Runs a client command, prints a private chat message, or does both for each item.
- Supports CS:GO chat-color tokens without an external include.
- Reloads the configuration without restarting the plugin.
- Validates malformed and empty configuration sections instead of adding broken menu items.

## Requirements

- SourceMod 1.10 or newer
- Counter-Strike: Global Offensive

The bundled `quick-command-menu.smx` is compiled with SourceMod 1.12.0.7041.

## Installation

1. Copy the included `addons` directory into the server's `csgo` directory.
2. Edit `addons/sourcemod/configs/quickcommands.cfg` as needed.
3. Load the plugin or change maps. If it is already loaded, run `sm_qc_reload` from the server console or as an admin with the Config flag.

## Commands

| Command | Access | Description |
| --- | --- | --- |
| `sm_qc` | Everyone | Opens the Quick Command Menu. |
| `sm_qc_reload` | Config admin flag | Reloads and validates `quickcommands.cfg`. |

## Configuration

Every item needs a `name` and at least one action: `command`, `chatprint`, or both.

```text
"quickcommand"
{
	"1"
	{
		"name"      "!rules"
		"command"   "sm_rules"
	}

	"2"
	{
		"name"      "!discord"
		"chatprint" "{grey}Join us: {purple}https://discord.com/example"
	}
}
```

Supported color tokens are `{default}`, `{darkred}`, `{green}`, `{lightgreen}`, `{red}`, `{blue}`, `{olive}`, `{lime}`, `{lightred}`, `{purple}`, `{grey}`, `{gray}`, `{yellow}`, `{orange}`, `{bluegrey}`, `{bluegray}`, `{lightblue}`, `{darkblue}`, `{grey2}`, `{gray2}`, `{orchid}`, and `{lightred2}`.

Invalid sections are skipped and reported in the SourceMod error log. A reload only replaces the current menu after at least one valid item has been parsed, so a bad edit does not destroy a working menu.

## Building from source

Run the SourceMod compiler from `addons/sourcemod/scripting`:

```text
spcomp quick-command-menu.sp -o../plugins/quick-command-menu.smx
```

The source uses only standard SourceMod includes.

## Changelog

| Version | Changes |
| --- | --- |
| 4.3.0 | Hardened config parsing and menu actions, added safe reloads and working color tokens, removed unused dependencies, and refreshed documentation. |
| 4.2.1 | Reduced memory usage. |
| 4.2.0 | Initial GitHub release. |

## License

[GNU General Public License v3.0](LICENSE)
