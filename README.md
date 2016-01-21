# Garrys-Mod-Family-Sharing

Prevent players bypassing existing bans on Garrys Mod Servers.

This script will prevent players bypassing current / existing bans using Steam's built in family sharing feature.

This will also "if enabled." add banning users by IP address to the default ULX `!ban` `"ulx ban"` and `!banid` `"ulx banid"` command.

If you have any bugs issues or problems just post a Issue request. https://github.com/C0nw0nk/Garrys-Mod-Family-Sharing/issues

# Features :

Banning those who try to bypass current / existing bans. (Default : TRUE)

Ban length is configurable. (Default : 0 Permament).

Ban reason is configurable.

Ban users by IP address too. (Default : TRUE)

Block all family sharing accounts configurable. (Default : FALSE)

Block all family sharing kick reason configurable.

Extra Ban Checks on accounts that connect to the server, If their IP is not banned but their SteamID is then their IP will be banned too for what ever length their current ban is. This feature will only work if the Banning users by IP address feature is also enabled. (Default : TRUE)

Informative Ban Message makes the default ULX ban message pretty and useful to the player reading it. (Default : TRUE)

Custom ban message configurable.

Ban tracker to prevent players buying a new GMod Garry's Mod in order to connect. (Default : TRUE)

Ban tracker paths settings and options all configurable.

# How to install

Install the script to the `"/garrysmod/lua/autorun/"` folder.

The path to should look like this : `"/garrysmod/lua/autorun/familysharing.lua"`

Configure the script and put your Steam Dev API Key : https://github.com/C0nw0nk/Garrys-Mod-Family-Sharing/blob/master/garrysmod/lua/autorun/familysharing.lua#L18

Inside your `server.cfg` file make sure you have the following : (This makes sure if you enable the IP banning feature it will actualy use the ip ban list.)

`exec banned_user.cfg`

`exec banned_ip.cfg`

# Dependencies / Requirements :

ULX / ULIB :

http://ulyssesmod.net/downloads.php

Steam Dev API Key can be obtained from :

http://steamcommunity.com/dev/apikey
