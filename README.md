# Garrys-Mod-Family-Sharing

Prevent players bypassing existing bans on Garrys Mod Servers.

The way this script works is it lets family sharing users join and play (Unless you enable the block all family shared accounts feature.) When you ban a player from your server it will check if the account is shared if it is it will ban both the owners steam account and the shared account they are currently connected via thus preventing any more alts joining.

This script will prevent players bypassing current / existing bans using Steam's built in family sharing feature.

This script will also prevent players bypassing current / existing bans by buying a new Garry's Mod. (Yes it can detect that too.) via the ban tracker feature.

This will also "if enabled." add banning users by IP address to the default ULX `!ban` `"ulx ban"` and `!banid` `"ulx banid"` command.

If you have any bugs issues or problems just post a Issue request. https://github.com/C0nw0nk/Garrys-Mod-Family-Sharing/issues

# Features :

Banning those who try to bypass current / existing bans. (Default : TRUE)

Ban length is configurable. (Default : 0 Permament).

Ban reason is configurable.

Ban users by IP address too. (Default : TRUE)

Block all family sharing accounts configurable. (Default : FALSE)

Block all family sharing kick reason configurable.

Extra Ban Checks on accounts that connect to the server, If their IP is not banned but their SteamID is then their IP will be banned too for what ever length their current ban is. (Default : TRUE)

Informative Ban Message makes the default ULX ban message pretty and useful to the player reading it. (Default : TRUE)

Custom ban message configurable.

Ban tracker to prevent players buying a new GMod Garry's Mod in order to connect. (Default : TRUE)

Ban tracker paths settings and options all configurable.

# How to install

Install the script to the `"/garrysmod/lua/autorun/"` folder.

The path to should look like this : `"/garrysmod/lua/autorun/familysharing.lua"`

###### Alternative Install Location :
If you don't want to use the directory above you can install this script as an addon in the following location.

Install the addon to the `"/garrysmod/addons/"` folder.

The path layout should look like this : `"/garrysmod/addons/familysharing/lua/autorun/familysharing.lua"`

Configure the script and put your Steam Dev API Key : https://github.com/C0nw0nk/Garrys-Mod-Family-Sharing/blob/master/garrysmod/lua/autorun/familysharing.lua#L17

##### Optional :

Inside your `server.cfg` file make sure you have the following : (This makes sure if you enable the IP banning feature it will actualy use the ip ban list.)

`exec banned_user.cfg`

`exec banned_ip.cfg`

# Usage :

In order to ban users family sharing the script will do it all automaticly so you don't have to worry about a thing all you have to do is use either the `!ban` or `!banid` command in chat or you can use the ULX menu `!menu` or `ulx ban` / `ulx banid` via the console. The script does all the rest.

# Recommended Settings :

I recommend default settings and the only settings I ever recommend every server owner change is the following that way your server is unique and uses its own paths to track banned players.

https://github.com/C0nw0nk/Garrys-Mod-Family-Sharing/blob/master/garrysmod/lua/autorun/familysharing.lua#L62-L72

# Dependencies / Requirements :

ULX / ULIB :

http://ulyssesmod.net/downloads.php

Steam Dev API Key can be obtained from :

http://steamcommunity.com/dev/apikey

# F.A.Q (Frequently asked Questions) :

##### Will i add MySQL / Database support ?

I do not need to. That is something to be added to the ULX Admin mod not this script.
