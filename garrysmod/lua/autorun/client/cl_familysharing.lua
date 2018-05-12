net.Receive("SteamFamilySharing_NetworkServerToClient", function()
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
			net.Start("SteamFamilySharing_NetworkClientToServer")
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