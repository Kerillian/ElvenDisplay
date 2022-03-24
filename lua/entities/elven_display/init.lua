AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

include("shared.lua");

function ENT:Initialize()
	self:SetModel("models/hunter/plates/plate025x025.mdl");
	self:SetRenderMode(RENDERMODE_TRANSALPHA);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_FLY);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetUseType(SIMPLE_USE);

	self.MediaSrc = "asset://garrysmod/materials/elven_display/icon.png";
	self.MediaScale = 0.24;
	self.Invisible = false;
	self.Physics = false;

	for k,v in pairs(player.GetHumans()) do
		if v:GetInfo("cl_elvendisplay_show") == "0" then
			self:SetPreventTransmit(v, true);
		end
	end
end

function ENT:Use(activator)
	if not activator:IsPlayer() then
		return;
	end

	if not activator:IsAdmin() and activator ~= self:GetCreator() then
		return;
	end

	if ElvenDisplay.AdminOnly:GetBool() and not activator:IsAdmin() then
		return;
	end
	
	net.Start("elven.display.edit");
		net.WriteEntity(self);
	net.Send(activator);
end

function ENT:Sync(ply)
	net.Start("elven.display.sync");
		net.WriteEntity(self);
		net.WriteString(self.MediaSrc);
		net.WriteFloat(self.MediaScale);
		net.WriteBool(self.Invisible);
		net.WriteBool(self.Physics);
	net.Send(ply);
end

function ENT:Broadcast()
	net.Start("elven.display.sync");
		net.WriteEntity(self);
		net.WriteString(self.MediaSrc);
		net.WriteFloat(self.MediaScale);
		net.WriteBool(self.Invisible);
		net.WriteBool(self.Physics);
	net.Broadcast();
end