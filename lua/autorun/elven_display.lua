AddCSLuaFile("elven_display/cl_edit.lua");
AddCSLuaFile("elven_display/sh_options.lua");

include("elven_display/sh_options.lua");

if SERVER then
	resource.AddSingleFile("materials/elven_display/icon.png");
	resource.AddSingleFile("materials/entities/elven_display.png");
	
	include("elven_display/sv_main.lua");
elseif CLIENT then
	include("elven_display/cl_edit.lua");
end