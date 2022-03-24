util.AddNetworkString("elven.display.sync");
util.AddNetworkString("elven.display.edit");
util.AddNetworkString("elven.display.show");
util.AddNetworkString("elven.display.view");

local function DetectMime(url, callback)
	HTTP({
		method = "HEAD",
		url = url,
		success = function(code, body, headers)
			if headers and headers["Content-Type"] then
				local kb = 0;

				if headers["Content-Length"] then
					local num = tonumber(headers["Content-Length"], 10);
					
					if num then
						kb = num / 1000;
					end
				end

				callback(true, headers["Content-Type"], kb);
				return;
			end

			callback(false);
		end,
		failed = function(reason)
			callback(false);
		end
	});
end

local function VerifyUrl(url, ply)
	if ElvenDisplay.FilterIgnoreAdmins:GetBool() and ply:IsSuperAdmin() then
		return true;
	end

	for k,v in pairs(ElvenDisplay.Filters) do
		if url:match(v) then
			return true;
		end
	end

	return false;
end

hook.Add("PlayerSpawnedSENT", "elven.display.spawned", function(ply, ent)
	if ent:GetClass() == "elven_display" then
		ent:SetCreator(ply);
	end
end);

hook.Add("PlayerDisconnected", "elven.display.cleanup", function(ply)
	local displays = ents.FindByClass("elven_display");

	for k,v in pairs(displays) do
		if v:GetCreator() == ply then
			v:Remove();
		end
	end
end);

net.Receive("elven.display.sync", function(len, ply)
	local ent = net.ReadEntity();

	if IsValid(ent) and ent:GetClass() == "elven_display" then
		ent:Sync(ply);
	end
end);

net.Receive("elven.display.edit", function(len, ply)
	if ElvenDisplay.AdminOnly:GetBool() then
		if not ply:IsAdmin() then
			return;
		end
	end

	local ent = net.ReadEntity();

	if IsValid(ent) and ent:GetClass() == "elven_display" then
		if ent:GetCreator() ~= ply and not ply:IsAdmin() then
			ply:ChatPrint("[Elven Display] You are not the owner of this display.");
			return;
		end

		local url = net.ReadString();
		local scale = math.Clamp(net.ReadFloat(), 0, 1);
		local invisible = net.ReadBool();
		local physics = net.ReadBool();

		ent.MediaScale = scale;
		ent.Invisible = invisible;
		ent.Physics = physics;

		if ent.Invisible then
			ent:DrawShadow(false);
		else
			ent:DrawShadow(true);
		end

		if ent.Physics then
			ent:SetMoveType(MOVETYPE_VPHYSICS);
		else
			ent:SetMoveType(MOVETYPE_FLY);
		end

		if url ~= ent.MediaSrc then
			if not VerifyUrl(url, ply) then
				ply:ChatPrint("[Elven Display] Url failed to pass filters.");
				ent.MediaScale = scale;
				ent:Broadcast();
			else
				DetectMime(url, function(success, mime, kb)
					if not success then
						ply:ChatPrint("[Elven Display] Failed to fetch media.");
						return;
					end

					if not (ElvenDisplay.FilterIgnoreAdmins:GetBool() and ply:IsAdmin()) then
						if kb > ElvenDisplay.KbLimit:GetInt() then
							ply:ChatPrint("[Elven Display] Media file size is too large.");
							return;
						end
					end

					if not ElvenDisplay.MimeTypes[mime] then
						ply:ChatPrint("[Elven Display] Media type verification failed.");
						return;
					end

					ent.MediaSrc = url;
					ent.MediaScale = scale;
					ent:Broadcast();
				end);
			end
		else
			ent.MediaScale = scale;
			ent:Broadcast();
		end
	end
end);

net.Receive("elven.display.show", function(len, ply)
	if ply.ElvenShowWait and ply.ElvenShowWait > SysTime() then
		return;
	end

	ply.ElvenShowWait = SysTime() + 5;
	local show = net.ReadBool();

	for k,v in pairs(ents.FindByClass("elven_display")) do
		v:SetPreventTransmit(ply, not show);
	end
end);

net.Receive("elven.display.view", function(len, ply)
	if not ply:IsAdmin() then
		return;
	end

	local display = net.ReadEntity();

	if display then
		if hook.Run("PlayerNoClip", ply, true) then
			ply:SetMoveType(MOVETYPE_NOCLIP);
		end

		ply:SetPos(display:GetPos() + (display:GetForward() * 100));
		ply:SetEyeAngles((display:GetPos() - ply:GetPos()):Angle());
	end
end);

concommand.Add("sv_elvendisplay_view", function(ply)
	if not ply:IsAdmin() then
		return;
	end

	local displays = ents.FindByClass("elven_display");

	if #displays > 0 then
		net.Start("elven.display.view");
		net.WriteUInt(#displays, 12);

		for k,v in pairs(displays) do
			net.WriteString(v.MediaSrc);
			net.WriteEntity(v);
			net.WriteEntity(v:GetCreator());
		end

		net.Send(ply);
	end
end, nil, "Admin menu for viewing all displays on the server.");