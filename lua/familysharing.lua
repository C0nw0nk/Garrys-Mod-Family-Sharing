--[[
Credits :
C0nw0nk

Info :
This script will make it very hard for users who you ban from your server to return or bypass their current/existing bans.
When you ban a user it will also ban the account that owns Garry's Mod / has family shared them the game.
Because of the way this script works you can guarantee when you ban someone they have to buy a new Garry's Mod to be able to return. (Keep wasting your money. I am sure Garry does not mind you making him richer.)
Depending on the settings you assign you may also ban users by IP too what will make it harder for the banned user to return.
]]

--APIKey required to deal with those family sharing.
--You may obtain your Steam API Key from here | http://steamcommunity.com/dev/apikey
local APIKey = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

--The message displayed to those who connect by a family shared account that has been banned.
local kickmessage = "The account that lent you Garry's Mod is banned on this server"

--Ban those who try to bypass a current ban by returning on a family shared account.
--Set true to enable | false to disable.
--If this is set to false it will only kick those bypassing bans.
local banbypass = true

--The length to ban those who are trying to bypass a current / existing ban.
--This will also increase/change the ban length on the account that owns Garry's Mod. (They shouldn't attempt to bypass a current ban.)
--time is in minutes.
--0 is permanent.
local banlength = 0

--The reason the player has been banned automaticly for connecting from a family shared account that already has a ban.
local banreason = "attempting to bypass a current/existing ban."

--Enable banning users by IP address too.
--Makes it even harder for continuous offenders to return to the server.
--Set true to enable | false to disable.
local banip = false

--Enable blocking anyone joining on a family shared account regardless if they are banned or not.
--Enabling this will allow only accounts that have bought and own Garry's Mod to join.
--Set true to enable | false to disable.
local blockfamilysharing = false

--The message to display to those who have been blocked by "blockfamilysharing".
local blockfamilysharingmessage = "Please connect to the server by a account that own's Garry's Mod."

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
	if blockfamilysharing == true then
		ply:Kick(blockfamilysharingmessage)
	end
	--End preventing anyone joining on a family shared account regardless if they are banned or not.
	
	--Check if ULX is installed.
	if not (ULib and ULib.bans) then return end

	--If the lenderSteamID is in the ULX ban list then kick/ban the SteamID they are sharing Garry's Mod with.
	if ULib.bans[lenderSteamID] then
		--Kick the player.
		ply:Kick(kickmessage)
		--If banbypass is enabled.
		if banbypass == true then
			--Ban the shared account that has connected.
			RunConsoleCommand( "ulx", "banid", ply:SteamID(), banlength, banreason)
			--Ban the lenderSteamID (The account that owns Garry's mod what is originally banned) or increase their ban.
			RunConsoleCommand( "ulx", "banid", lenderSteamID, banlength, banreason)
			
			--If banip is enabled.
			if banip == true then
				--Ban the players IP who is trying to bypass a existing ban.
				RunConsoleCommand( "addip", banlength, string.sub( tostring( ply:IPAddress() ), 1, string.len( tostring( ply:IPAddress() ) ) - 6 ))
				RunConsoleCommand( "writeip" )
				--exec banned_ip file to make the ban take effect.
				--RunConsoleCommand("exec banned_ip.cfg")
				--Use ULX to exec the banned ip file.
				if ULib.fileExists( "cfg/banned_ip.cfg" ) then
					ULib.execFile( "cfg/banned_ip.cfg" )
				end
			end
		end
		
	end
end

--Function to check players who connect if they are on a family shared account or not.
--If they are family sharing they will be passed to the "HandleSharedPlayer" function to decide their fate.
local function CheckFamilySharing(ply)
	--Send request to the SteamDEV API with the SteamID64 of the player who has just connected.
	http.Fetch(
		string.format("http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&format=json&steamid=%s&appid_playing=4000",
			APIKey,
			ply:SteamID64()
		),

		function(body)
			--Put the http response into a table.
			body = util.JSONToTable(body)

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
function banHook(ply, commandName, translated_args)
	--If the admin is banning a player. "!ban" in chat or "ulx ban" via console. (Works for !menu bans too.)
	if string.lower(commandName) == "ulx ban" then
		--Split up the command into sections.
		local admin = nil
		local target = translated_args[ 2 ]
		local time = translated_args[ 3 ]
		local offence = translated_args[ 4 ]

		--If banip is enabled.
		if banip == true then
			--Ban the players IP who is trying to bypass a existing ban.
			RunConsoleCommand( "addip", time, string.sub( tostring( target:IPAddress() ), 1, string.len( tostring( target:IPAddress() ) ) - 6 ))
			RunConsoleCommand( "writeip" )
			--exec banned_ip file to make the ban take effect.
			--RunConsoleCommand("exec banned_ip.cfg")
			--Use ULX to exec the banned ip file.
			if ULib.fileExists( "cfg/banned_ip.cfg" ) then
				ULib.execFile( "cfg/banned_ip.cfg" )
			end
		end

		--Send request to the SteamDEV API with the SteamID64 of the player we are banning.
		http.Fetch(
		string.format("http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&format=json&steamid=%s&appid_playing=4000",
			APIKey,
			target:SteamID64()
		),

		function(body)
			--Put the http response into a table.
			body = util.JSONToTable(body)

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
				RunConsoleCommand( "ulx", "banid", lenderSteamID, time, offence)
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
		local admin = nil
		local target = translated_args[ 2 ]
		local time = translated_args[ 3 ]
		local offence = translated_args[ 4 ]

		--If banip is enabled.
		if banip == true then
			--Lets check if the SteamID that is getting banned is currently playing on the server.
			--If they are playing on the server lets ban their IP too.
			--Get all players currently playing.
			local plys = player.GetAll()
			for i=1, #plys do
				--If a player on the servers SteamID matches with the one getting banned grab their IP too.
				if plys[ i ]:SteamID() == target then
					--Ban the players IP who is trying to bypass a existing ban.
					RunConsoleCommand( "addip", time, string.sub( tostring( plys[ i ]:IPAddress() ), 1, string.len( tostring( plys[ i ]:IPAddress() ) ) - 6 ))
					RunConsoleCommand( "writeip" )
					--exec banned_ip file to make the ban take effect.
					--RunConsoleCommand("exec banned_ip.cfg")
					--Use ULX to exec the banned ip file.
					if ULib.fileExists( "cfg/banned_ip.cfg" ) then
						ULib.execFile( "cfg/banned_ip.cfg" )
					end
				end
			end
		end

		--Send request to the SteamDEV API with the SteamID64 of the player we are banning.
		http.Fetch(
		string.format("http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&format=json&steamid=%s&appid_playing=4000",
			APIKey,
			util.SteamIDTo64(target)
		),

		function(body)
			--Put the http response into a table.
            body = util.JSONToTable(body)
			
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
				RunConsoleCommand( "ulx", "banid", lenderSteamID, time, offence)
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
