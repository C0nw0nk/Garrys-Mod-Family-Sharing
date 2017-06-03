if SERVER then --If SERVER statement to ensure the following code stays server side.
--[[
Credits :
C0nw0nk, Edit by Momox

Github : https://github.com/C0nw0nk/Garrys-Mod-Family-Sharing

Info :
This script will make it very hard for users who you ban from your server to return or bypass their current/existing bans.
When you ban a user it will also ban the account that owns Garry's Mod / has family shared them the game.
Because of the way this script works you can guarantee when you ban someone they have to buy a new Garry's Mod to be able to return. (Keep wasting your money. I am sure Garry does not mind you making him richer.)
Depending on the settings you assign you may also ban users by IP too what will make it harder for the banned user to return.
]]

GMFS = GMFS or {} --We're now storing things inside tables ;)

--GMFS.APIKey required to deal with those family sharing.
--You may obtain your Steam API Key from here | http://steamcommunity.com/dev/GMFS.APIKey
GMFS.APIKey = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

--The message displayed to those who connect by a family shared account that has been banned.
GMFS.kickmessage = "The account that lent you Garry's Mod is banned on this server"

--Ban those who try to bypass a current ban by returning on a family shared account.
--Set true to enable | false to disable.
--If this is set to false it will only kick those bypassing bans.
GMFS.banbypass = true

--The length to ban those who are trying to bypass a current / existing ban.
--This will also increase/change the ban length on the account that owns Garry's Mod. (They shouldn't attempt to bypass a current ban.)
--time is in minutes.
--0 is permanent.
GMFS.banlength = 0

--The reason the player has been banned automaticly for connecting from a family shared account that already has a ban.
GMFS.banreason = "attempting to bypass a current/existing ban."

--Enable banning users by IP address too.
--Makes it even harder for continuous offenders to return to the server.
--Set true to enable | false to disable.
GMFS.banip = true

--Enable blocking anyone joining on a family shared account regardless if they are banned or not.
--Enabling this will allow only accounts that have bought and own Garry's Mod to join.
--Set true to enable | false to disable.
GMFS.blockfamilysharing = false

--The message to display to those who have been blocked by "GMFS.blockfamilysharing".
GMFS.blockfamilysharingmessage = "Please connect to the server by a account that own's Garry's Mod."

--Extra Ban Checks will ban users IP addresses who connect to the server if their SteamID is in the ban list
--and their IP is not already banned.
--Set true to enable | false to disable.
GMFS.extra_ban_checks = true

--Makes the default ULX banned message more informative and pretty.
--Set true to enable | false to disable.
GMFS.informative_ban_message = true

--The custom banned message to display to those who are banned.
--\n is for a new line.
GMFS.custom_ban_message = "You're banned! \n\n Visit www.your-site.com to appeal it."

--Configuration for the ban tracker.
--Set file name path and file type to track players who get banned.
--(This will help us prevent banned players buying new Garry's Mod(s) in order to come back.)
--I recommend having this different to what is set in this script so your server is unique and uses its own path.
--The folder we will create and put the file into to make it inconspicuous.
--If this is empty = "" then no file path will be set and it will just create in a root folder.
GMFS.storage_path = "models/" --Always keep a forward slash if you set a directory or folder.
--The file types you can choose are ".txt", ".jpg", ".png", ".dat" or ".vtf" according to what the GMOD Wiki tells us : https://wiki.garrysmod.com/page/file/Write
GMFS.file_type = ".jpg"
--File name can be what ever you want it to be for example "DarkRP" or "License" something inconspicuous.
GMFS.file_name = "player"

--End if server statement.
end

--[[This is a shared setting that both client and server need to read.
Because of that this setting is in the shared location not in client code tags and not in server code tags.
Both client and server may now read and use this.
]]

--Enable or Disable the ban tracker, This is how we track and prevent players who get banned buying a new GMod in order to connect.
--Set true to enable | false to disable.
local ban_tracker = true

--Specify Custom Network string names here so we can control and change them at any time easily.
--String name for Server to talk to Client via.
local NetworkServerToClient = "ServerToClient"
--String name for Client to talk to Server via.
local NetworkClientToServer = "ClientToServer"

--[[End shared setting]]

if SERVER then --If SERVER statement to ensure the following code stays server side.
--[[
DO NOT TOUCH ANYTHING BELOW THIS POINT UNLESS YOU KNOW WHAT YOU ARE DOING.

^^^^^ YOU WILL MOST LIKELY BREAK THE SCRIPT SO TO CONFIGURE THE FEATURES YOU WANT JUST USE WHAT I GAVE YOU ABOVE. ^^^^^

THIS BLOCK IS ENTIRELY WRITTEN IN CAPS LOCK TO SHOW YOU HOW SERIOUS I AM.
]]

--Function to handle those who connect via family shared steam accounts.
local function HandleSharedPlayer(ply, lenderSteamID)
	--Log to server console who has been detected family sharing.
	print(string.format("FamilySharing: %s | %s has been lent Garry's Mod by %s",
		ply:Nick(),
		ply:SteamID(),
		lenderSteamID
	))

	--Prevent anyone joining on a family shared account regardless if they are banned or not.
	if GMFS.blockfamilysharing == true then
		ply:Kick(GMFS.blockfamilysharingmessage)
	end
	--End preventing anyone joining on a family shared account regardless if they are banned or not.

	--Check if ULX is installed.
	if not (ULib and ULib.bans) then return end

	--If the lenderSteamID is in the ULX ban list then kick/ban the SteamID they are sharing Garry's Mod with.
	if ULib.bans[lenderSteamID] then
		--If GMFS.banbypass is enabled.
		if GMFS.banbypass == true then
			--Ban the shared account that has connected.
			RunConsoleCommand("ulx", "banid", ply:SteamID(), GMFS.banlength, GMFS.banreason)
			--Ban the lenderSteamID (The account that owns Garry's mod what is originally banned) or increase their ban.
			RunConsoleCommand("ulx", "banid", lenderSteamID, GMFS.banlength, GMFS.banreason)
		--else ban bypass is disabled so kick the person bypassing a ban instead.
		else
			--Kick the player.
			ply:Kick(GMFS.kickmessage)
		end
	end
end

--Function to check players who connect if they are on a family shared account or not.
--If they are family sharing they will be passed to the "HandleSharedPlayer" function to decide their fate.
local function CheckFamilySharing(ply)
	--Send request to the SteamDEV API with the SteamID64 of the player who has just connected.
	http.Fetch(
	string.format("http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&format=json&steamid=%s&appid_playing=4000",
		GMFS.APIKey,
		ply:SteamID64()
	),

	function(body)
		--Put the http response into a table.
		local body = util.JSONToTable(body)

		--If the response does not contain the following table items.
		if not body or not body.response or not body.response.lender_steamid then
			error(string.format("FamilySharing: Invalid Steam API response for %s | %s\n", ply:Nick(), ply:SteamID()))
		end

		--Set the lender to be the lender in our body response table.
		local lender = body.response.lender_steamid
		--If the lender is not 0 (Would contain SteamID64). Lender will only ever == 0 if the account owns the game.
		if lender ~= "0" then
			--Handle the player that is on a family shared account to decide their fate.
			HandleSharedPlayer(ply, util.SteamIDFrom64(lender))
		end
	end,

	function(code)
		error(string.format("FamilySharing: Failed API call for %s | %s (Error: %s)\n", ply:Nick(), ply:SteamID(), code))
	end
	)
end
hook.Add("PlayerAuthed", "CheckFamilySharing", CheckFamilySharing)

--Start hooking the ulx ban commands.
--This is mandatory because when you ban a player you need to check if they are already on a family shared account or not.
--So lets check if the person we are banning is already connected by a family shared account,
--that way we can ban both their shared account and the account that owns Garry's Mod. (That will teach them!, You can't outsmart me with your lies.)
local function banHook(ply, commandName, translated_args)
	--If the admin is banning a player. "!ban" in chat or "ulx ban" via console. (Works for !menu bans too.)
	if string.lower(commandName) == "ulx ban" then
		--Split up the command into sections.
		--local admin = translated_args[1]
		local target = translated_args[2]
		local time = translated_args[3]
		local offence = translated_args[4]

		--If GMFS.banip is enabled.
		if GMFS.banip == true then
			--Ban the players IP who is trying to bypass a existing ban.
			RunConsoleCommand("addip", time, target:IPAddress():Split(":")[1])
			RunConsoleCommand("writeip")
		end

		--Send request to the SteamDEV API with the SteamID64 of the player we are banning.
		http.Fetch(
		string.format("http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&format=json&steamid=%s&appid_playing=4000",
			GMFS.APIKey,
			target:SteamID64()
		),

		function(body)
			--Put the http response into a table.
			local body = util.JSONToTable(body)

			--If the response does not contain the following table items.
			if not body or not body.response or not body.response.lender_steamid then
				error(string.format("FamilySharing: Invalid Steam API response for %s | %s\n", target:Nick(), target:SteamID()))
			end

			--Set the lender to be the lender in our body response table.
			local lender = body.response.lender_steamid
			--If the lender is not 0 (Would contain SteamID64). Lender will only ever == 0 if the account owns the game.
			if lender ~= "0" then
				--Lets ban the owners account too.
				local lenderSteamID = util.SteamIDFrom64(lender)
				RunConsoleCommand("ulx", "banid", lenderSteamID, time, offence)
			end
		end,

		function(code)
			error(string.format("FamilySharing: Failed API call for %s | %s (Error: %s)\n", target:Nick(), target:SteamID(), code))
		end
		)
	end

	--If the admin is banning a player. "!banid" in chat or "ulx banid" via console. (Works for !menu bans too.)
	if string.lower(commandName) == "ulx banid" then
		--Split up the command into sections.
		--local admin = translated_args[1]
		local target = translated_args[2]
		local time = translated_args[3]
		local offence = translated_args[4]

		--If GMFS.banip is enabled.
		if GMFS.banip == true then
			--Lets check if the SteamID that is getting banned is currently playing on the server.
			--If they are playing on the server lets ban their IP too.
			--Get all players currently playing.
			local plys = player.GetAll()
			for i=1, #plys do
				--If a player on the servers SteamID matches with the one getting banned grab their IP too.
				if plys[i]:SteamID() == target then
					--Ban the players IP who is trying to bypass a existing ban.
					RunConsoleCommand("addip", time, plys[i]:IPAddress():Split(":")[1])
					RunConsoleCommand("writeip")
					
					--break out of the for each. (pointless to go through the rest when we found what we want.)
					break
				end
			end
		end

		--Send request to the SteamDEV API with the SteamID64 of the player we are banning.
		http.Fetch(
		string.format("http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&format=json&steamid=%s&appid_playing=4000",
			GMFS.APIKey,
			util.SteamIDTo64(target)
		),

		function(body)
			--Put the http response into a table.
			local body = util.JSONToTable(body)

			--If the response does not contain the following table items.
			if not body or not body.response or not body.response.lender_steamid then
				error(string.format("FamilySharing: Invalid Steam API response for %s | %s\n", util.SteamIDTo64(target), target))
			end

			--Set the lender to be the lender in our body response table.
			local lender = body.response.lender_steamid
			--If the lender is not 0 (Would contain SteamID64). Lender will only ever == 0 if the account owns the game.
			if lender ~= "0" then
				--Lets ban the owners account too.
				local lenderSteamID = util.SteamIDFrom64(lender)
				RunConsoleCommand("ulx", "banid", lenderSteamID, time, offence)
			end
		end,

		function(code)
			error(string.format("FamilySharing: Failed API call for %s | %s (Error: %s)\n", util.SteamIDTo64(target), target, code))
		end
		)
	end
end
hook.Add("ULibPostTranslatedCommand", "BanHook", banHook)
--End hooking ulx ban commands.

--If GMFS.informative_ban_message is enabled or extra ban checks are enabled.
if GMFS.informative_ban_message == true or GMFS.extra_ban_checks == true then
--Start IP banned or Steam ID banned check. (Extra checks to prevent players bypassing bans.)
hook.Add("CheckPassword", "Extra-BanChecks", function(steamID64, ipAddress)
	--Check if their SteamID is in the ban list.
	if ULib.bans[util.SteamIDFrom64(steamID64)] then
		--Log to server console who has been detected attempting to bypass a existing ban.
		print(string.format("The following players SteamID: %s | matched with a SteamID in the ban list we are now going to ban their new IP too (Stop trying to bypass bans): %s",
			util.SteamIDFrom64(steamID64),
			ipAddress:Split(":")[1]
		))

		--If ban time remaining is less than or equal to 0 then.
		if tonumber(ULib.bans[util.SteamIDFrom64(steamID64)].unban) <= 0 then
			--Make the ban length 0 for permanent.
			GMFS.banip_length = 0
		else
			--If the ban time remaining is not 0 then make it the time remaining on the users ban.
			GMFS.banip_length = math.Round((ULib.bans[util.SteamIDFrom64(steamID64)].unban - os.time())/60)
		end

		--If GMFS.banip is enabled and extra ban checks are enabled.
		if GMFS.banip == true and GMFS.extra_ban_checks == true then
			--Ban their IP address if it is not already banned.
			RunConsoleCommand("addip", GMFS.banip_length, ipAddress:Split(":")[1])
			RunConsoleCommand("writeip")
		end

		--Show custom you are banned message.
		--Put the date of our ban into a readable format.
		local date_of_ban = os.date("%b %d, %Y - %I:%M:%S %p", tonumber(ULib.bans[util.SteamIDFrom64(steamID64)].time))
		--Put the date of unbanning the player into a readable format.
		local date_of_unban = os.date("%b %d, %Y - %I:%M:%S %p", tonumber(ULib.bans[util.SteamIDFrom64(steamID64)].unban))
		--Put the time remaining into a format that the player can read.
		local ban_time_left = math.Round((ULib.bans[util.SteamIDFrom64(steamID64)].unban - os.time())/60)
		--If ban time remaining is less than or equal to 0 then.
		if tonumber(ULib.bans[util.SteamIDFrom64(steamID64)].unban) <= 0 then
			--Set the displayed information for the player to read.
			date_of_unban = "Never."
			ban_time_left = "None, You are banned permanently."
		end
		--If GMFS.informative_ban_message is enabled.
		if GMFS.informative_ban_message == true then
			--Show our nicely detailed you are banned informative message.
			return false, ""..GMFS.custom_ban_message.."\n\nDate of Ban : "..date_of_ban.."\n\nDate of Unban : "..date_of_unban.."\n\nTime left minute(s) : "..ban_time_left..""
		else
			--Show the default you are banned message.
			return false, "You have been banned from this server."
		end
	end

	--If extra ban checks are enabled.
	if GMFS.extra_ban_checks == true then
		--Check if their IP address is in the ban list.
		if file.Exists("cfg/banned_ip.cfg", "GAME") then
			--Read the banned ip file.
			local input = file.Read("cfg/banned_ip.cfg", "GAME")
			--Put all banned ip's into a table separate each by a new line.
			local data = string.Explode("\n", input)
			--For each ip check if it matches with the ip connecting to the server.
			for i=1, #data do
				--If the ip in the banned_ip list matches with the ip connecting to the server then.
				if data[i]:Split(" ")[3] == ipAddress:Split(":")[1] then
					--Log to server console who has been detected attempting to bypass a existing ban.
					print(string.format("The following players IP: %s | matched with %s in the IP ban list we are banning their new SteamID too (Stop trying to bypass bans): %s",
						ipAddress:Split(":")[1],
						data[i]:Split(" ")[3],
						util.SteamIDFrom64(steamID64)
					))
					--Ban the SteamID of the account connecting too. length of ban depends on what the IP ban length is set to. (data[i]:Split(" ")[2])
					RunConsoleCommand("ulx", "banid", util.SteamIDFrom64(steamID64), data[i]:Split(" ")[2], GMFS.banreason)
					--Show the default you are banned message.
					return false, "You have been banned from this server."
				end
			end
		end
	end
end)
--End extra ban checks.
end
--End If server statement
end

--Ban tracker.
--If ban tracker config is enabled then run the following code.
if ban_tracker == true then
--Lets stop those players from rejoining when banned regardless if they buy a new Garry's Mod or not with a secret weapon.
--(I can be a sneaky devil.)
if SERVER then
	--Create our Network String to communicate with the player over.
	util.AddNetworkString(NetworkServerToClient)
	--Create our Network String to communicate with the server over.
	util.AddNetworkString(NetworkClientToServer)

	--Receive our message from the client.
	net.Receive(NetworkClientToServer, function(length, player)
		--If the account in the net.ReadString() that the client just sent us is banned.
		--Convert the string to a SteamID util.SteamIDFrom64(net.ReadString())
		local clientsteamidfromfile = net.ReadString()
		--Ignore admins and check if the steamid is in the banlist.
		if !player:IsAdmin() and ULib.bans[util.SteamIDFrom64(clientsteamidfromfile)] then
			--Log to server console who has been detected attempting to bypass a existing ban.
			print(string.format("The following SteamID: %s | matched with a SteamID in the ban list we are now going to ban their new account too (Stop trying to bypass bans): %s",
				util.SteamIDFrom64(clientsteamidfromfile),
				player:SteamID()
			))
			--Ban the player who just sent the message.
			RunConsoleCommand("ulx", "banid", player:SteamID(), GMFS.banlength, GMFS.banreason)
			--Increase the ban on their original steam account.
			RunConsoleCommand("ulx", "banid", util.SteamIDFrom64(clientsteamidfromfile), GMFS.banlength, GMFS.banreason)
		end
	end)

	--When the player connects and is authenticated Send a message from the server to them.
	hook.Add("PlayerAuthed", "PlayerAuthed-NetSend", function(player)
		--Begin communications with CLIENT.
		net.Start(NetworkServerToClient)
		--Send SteamID.
		net.WriteString(player:SteamID64())
		--Send GMFS.file_name.
		net.WriteString(GMFS.file_name)
		--Send GMFS.file_type.
		net.WriteString(GMFS.file_type)
		--Send GMFS.storage_path.
		net.WriteString(GMFS.storage_path)
		--Send to player that we just authenticated.
		net.Send(player)
	end)
--Else if CLIENT this is the code the client gets access to.
else
	--Receive the message from the server's "PlayerAuthed" hook.
	net.Receive(NetworkServerToClient, function()
		--The SteamID is what the server tells us our SteamID is.
		local steamid = net.ReadString()
		--Name the file with what the server tells us the name is.
		local server_ip = net.ReadString()
		--Set the file type / format as what the server tells us the format is.
		local file_format = net.ReadString()
		--Set directory/file path.
		local file_path = net.ReadString()
		--If the Client has this file already.
		if file.Exists(""..file_path..""..server_ip..""..file_format.."", "DATA") then
			--Read our file.
			local lol = file.Read(""..file_path..""..server_ip..""..file_format.."", "DATA")
			--Put our file data into a table.
			local data = string.Explode("\n", lol)
			--If the Table does not already contain this ID.
			if !table.HasValue(data, steamid) then
				--Add the new ID to the file.
				file.Append(""..file_path..""..server_ip..""..file_format.."", "\n"..steamid.."")
			end

			--For each ID in our table.
			for i=1, #data do
				--Send the data to the server.
				net.Start(NetworkClientToServer)
				net.WriteString(data[i])
				net.SendToServer()
			end
		else
			--If the file path has a directory.
			if file_path != "" then
				--Create the folder(s) to store the file.
				file.CreateDir(""..file_path.."")
			end
			--Client did not have the file already so create it and add our SteamID.
			file.Write(""..file_path..""..server_ip..""..file_format.."", ""..steamid.."")
		end
	end)
end
--End If CLIENT
end
--End if ban_tracker enabled.
