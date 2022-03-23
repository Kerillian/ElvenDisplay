ElvenDisplay = ElvenDisplay or {};

ElvenDisplay.MaxSize = CreateConVar("sv_elvendisplay_maxsize", "1280", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Will limit images to this size in pixels. (Checks both width and height).", 0, 7680);
ElvenDisplay.Random = CreateConVar("sv_elvendisplay_random", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Enable the random button inside the edit UI.", 0, 1);
ElvenDisplay.AdminOnly = CreateConVar("sv_elvendisplay_adminonly", "0", FCVAR_ARCHIVE, "Makes it so only admins can edit the panels.", 0, 1);
ElvenDisplay.FilterIgnoreAdmins = CreateConVar("sv_elvendisplay_filterignoreadmins", "1", FCVAR_ARCHIVE, "Admins can bypass link filters. Mime type checks are still enforced.", 0, 1);
ElvenDisplay.KbLimit = CreateConVar("sv_elvendisplay_kblimit", "10000", FCVAR_ARCHIVE, "The maximum file size of media in kilobytes.", 200, 50000);

if CLIENT then
	ElvenDisplay.Show = CreateClientConVar("cl_elvendisplay_show", "1", true, true, "Enable the displays.", 0, 1);
	ElvenDisplay.CloseOnSave = CreateClientConVar("cl_elvendisplay_closeonsave", "1", true, false, "Close the editing menu on save.", 0, 1);

	cvars.AddChangeCallback("cl_elvendisplay_show", function(convar, old, new)
		net.Start("elven.display.show");
			net.WriteBool(new == "1");
		net.SendToServer();
	end);
end

if SERVER then
	local DefaultFilters = {
		"https?://cdn%.nekos%.life/.+",
		"https://.+%.gelbooru%.com/images/.+/.+/.+",
		"https?://i%.imgur%.com/.+",
		"https?://.+%.webmshare%.com/.+",
		"https?://pbs%.twimg%.com/media/.+%?format=jpg&name=.+",
		"https?://pbs%.twimg%.com/media/.+%?format=png&name=.+"
	};

	local DefaultMimeTypes = {
		["image/apng"] = true,
		["image/gif"] = true,
		["image/jpeg"] = true,
		["image/png"] = true,
		["image/webp"] = true,
		["video/webm"] = true,

		-- This is here for Discord CDN, for some reason thier CDN returns text/html for everything.
		-- This will only work for admins anyway if you have your filters setup correctly.
		["text/html; charset=UTF-8"] = true 
	}; 

	ElvenDisplay.Filters = table.Copy(DefaultFilters);
	ElvenDisplay.MimeTypes = table.Copy(DefaultMimeTypes);

	local function SaveTable(name, tbl)
		file.CreateDir("ElvenDisplay");

		local json = util.TableToJSON(tbl);

		if json then
			file.Write("ElvenDisplay/" .. name .. ".txt", json);
		end
	end

	local function LoadTable(name, key)
		if file.Exists("ElvenDisplay/" .. name .. ".txt", "DATA") then
			file.AsyncRead("ElvenDisplay/" .. name .. ".txt", "DATA", function(name, path, status, data)
				local tbl = util.JSONToTable(data);

				if tbl then
					ElvenDisplay[key] = tbl;
				end
			end);
		end
	end

	LoadTable("filters", "Filters");
	LoadTable("mimetypes", "MimeTypes");

	--[[
		Filters
	]]
	concommand.Add("sv_elvendisplay_filters", function(ply)
		if ply:IsSuperAdmin() then
			for k,v in pairs(ElvenDisplay.Filters) do
				ply:PrintMessage(HUD_PRINTCONSOLE, tostring(k) .. ": " .. v);
			end
		end
	end, nil, "List the currently used filters.");

	concommand.Add("sv_elvendisplay_filters_add", function(ply, cmd, args)
		if ply:IsSuperAdmin() and #args > 0 then
			for k,v in pairs(ElvenDisplay.Filters) do
				if v == args[1] then
					return;
				end
			end

			table.insert(ElvenDisplay.Filters, args[1]);
			SaveTable("filters", ElvenDisplay.Filters);
		end
	end, nil, "Add a filter to the filter list.");

	concommand.Add("sv_elvendisplay_filters_remove", function(ply, cmd, args)
		if ply:IsSuperAdmin() and #args > 0 then
			local index = tonumber(args[1], 10);

			if index and index > 0 and #ElvenDisplay.Filters >= index then
				table.remove(ElvenDisplay.Filters, index);
				SaveTable("filters", ElvenDisplay.Filters);
			end
		end
	end, nil, "Remove a filter from the filter list.");

	--[[
		MimeTypes
	]]
	concommand.Add("sv_elvendisplay_mimetypes", function(ply)
		if ply:IsSuperAdmin() then
			for k,v in pairs(table.GetKeys(ElvenDisplay.MimeTypes)) do
				ply:PrintMessage(HUD_PRINTCONSOLE, tostring(k) .. ": " .. v);
			end
		end
	end, nil, "List the currently allowed mime types.");

	concommand.Add("sv_elvendisplay_mimetypes_add", function(ply, cmd, args)
		if ply:IsSuperAdmin() and #args > 0 then
			if ElvenDisplay.MimeTypes[args[1]] then
				return;
			end

			ElvenDisplay.MimeTypes[args[1]] = true;
			SaveTable("mimetypes", ElvenDisplay.MimeTypes);
		end
	end, nil, "Add a mime type to the mime type list.");

	concommand.Add("sv_elvendisplay_mimetypes_remove", function(ply, cmd, args)
		if ply:IsSuperAdmin() and #args > 0 then
			local keys = table.GetKeys(ElvenDisplay.MimeTypes);
			local index = tonumber(args[1], 10);

			if index and index > 0 and #keys >= index then
				ElvenDisplay.MimeTypes[keys[index]] = nil;
				SaveTable("mimetypes", ElvenDisplay.MimeTypes);
			end
		end
	end, nil, "Remove a mime type from the mime type list.");

	--[[
		Other
	]]
	concommand.Add("sv_elvendisplay_settings_reset", function(ply)
		if ply:IsSuperAdmin() then
			ElvenDisplay.Filters = table.Copy(DefaultFilters);
			ElvenDisplay.MimeTypes = table.Copy(DefaultMimeTypes);
			
			ElvenDisplay.MaxSize:SetInt(1280);
			ElvenDisplay.KbLimit:SetInt(10000);
			ElvenDisplay.Random:SetBool(true);
			ElvenDisplay.AdminOnly:SetBool(false);
			ElvenDisplay.FilterIgnoreAdmins:SetBool(true);

			SaveTable("filters", ElvenDisplay.Filters);
			SaveTable("mimetypes", ElvenDisplay.MimeTypes);
		end
	end, nil, "Reset all ElvenDisplay Settings.");
end