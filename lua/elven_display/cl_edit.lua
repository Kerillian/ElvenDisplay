local TagsCache = {"rating:safe"};

local function GetRandomImage(tags, success, failure)
	http.Fetch("https://gelbooru.com/index.php?page=dapi&s=post&q=index&limit=1&json=1&tags=sort:random+" .. table.concat(tags, "+"), function(body)
		local json = util.JSONToTable(body);

		if json["post"] then
			success(json["post"][1]["file_url"]);
		else
			failure("No image found with tags :/");
		end
	end, failure);
end

local function RandomMenu(item)
	local Root = vgui.Create("DFrame");
	Root:SetTitle("Elven Display: Gelbooru Random");
	Root:SetSize(300, 400);
	Root:SetDraggable(true);
	Root:SetAlpha(0);
	Root:AlphaTo(255, 0.3, 0);
	Root:Center();
	Root:MakePopup();

	Root.btnMaxim:SetVisible(false);
	Root.btnMinim:SetVisible(false);

	function Root.btnClose:DoClick()
		Root:SetMouseInputEnabled(false);
		Root:SetKeyBoardInputEnabled(false);

		Root:AlphaTo(0, 0.3, 0, function()
			Root:Close();
		end);
	end

	function Root:Paint(w, h)
		surface.SetDrawColor(32, 32, 32);
		surface.DrawRect(0, 0, w, h);
	end

	local TagList = vgui.Create("DListView", Root);
	TagList:Dock(FILL);
	TagList:SetMultiSelect(true);
	TagList:AddColumn("Tags");

	for k,v in ipairs(TagsCache) do
		TagList:AddLine(v);
	end
	
	function TagList:DoDoubleClick(id, line)
		TagList:RemoveLine(id);
	end

	local ApplyButton = vgui.Create("DButton", Root);
	ApplyButton:SetText("Apply");
	ApplyButton:Dock(BOTTOM);

	function ApplyButton:DoClick()
		TagsCache = {};

		for k,v in ipairs(TagList:GetLines()) do
			table.insert(TagsCache, v:GetValue(1));
		end

		GetRandomImage(TagsCache, function(url)
			item:SetValue(url);
			Root:Remove();
		end, function(error)
			Derma_Message(error, "Error", "Ok");
		end);
	end

	local TagInput = vgui.Create("DTextEntry", Root);
	TagInput:Dock(BOTTOM);
	TagInput:SetPlaceholderText("Tag...");

	function TagInput:OnEnter(tag)
		TagList:AddLine(tag);
		TagInput:SetText("");
		TagInput:RequestFocus();
	end
end

local function EditMenu(display)
	local Root = vgui.Create("DFrame");
	Root:SetTitle("Elven Display: Editor");
	Root:SetSize(300, 200);
	Root:SetAlpha(0);
	Root:SetDraggable(true);
	Root:SetDeleteOnClose(true);
	Root:AlphaTo(255, 0.3, 0);
	Root:Center();
	Root:MakePopup();

	Root.btnMaxim:SetVisible(false);
	Root.btnMinim:SetVisible(false);

	-- Listen i know, i know. I should just make my own panel.
	function Root.btnClose:DoClick()
		Root:SetMouseInputEnabled(false);
		Root:SetKeyBoardInputEnabled(false);

		Root:AlphaTo(0, 0.3, 0, function()
			Root:Close();
		end);
	end

	-- But I'm not going to, k?
	function Root:Paint(w, h)
		surface.SetDrawColor(32, 32, 32);
		surface.DrawRect(0, 0, w, h);
	end

	local SrcTextbox = vgui.Create("DTextEntry", Root);
	SrcTextbox:Dock(TOP);
	SrcTextbox:SetText(display.MediaSrc);
	
	local ScaleSlider = vgui.Create("DNumSlider", Root);
	ScaleSlider:Dock(TOP);
	ScaleSlider:SetText("Media Width");
	ScaleSlider:SetMin(0.01);
	ScaleSlider:SetMax(1);
	ScaleSlider:SetDecimals(3);
	ScaleSlider:SetValue(display.MediaScale);

	local SaveButton = vgui.Create("DButton", Root);
	SaveButton:SetText("Save Display");
	SaveButton:Dock(BOTTOM);

	function SaveButton:DoClick()
		net.Start("elven.display.edit");
			net.WriteEntity(display);
			net.WriteString(SrcTextbox:GetText());
			net.WriteFloat(ScaleSlider:GetValue());
		net.SendToServer();

		if ElvenDisplay.CloseOnSave:GetBool() then
			Root:Close();
		end
	end

	if ElvenDisplay.Random:GetBool() then
		local RandomButton = vgui.Create("DButton", Root);
		RandomButton:SetText("Random");
		RandomButton:Dock(BOTTOM);

		function RandomButton:DoClick()
			RandomMenu(SrcTextbox);
		end
	end
end

local function AdminMenu(displays)
	local OwnerLabel = vgui.Create("DLabel");
	local Browser = vgui.Create("DHTML");
	local TpDisplayButton = vgui.Create("DButton");

	local url = "";
	local display = nil;
	local owner = nil;

	local Root = vgui.Create("DFrame");
	Root:SetTitle("Elven Display: Admin View");
	Root:SetSize(900, 600);
	Root:SetDraggable(true);
	Root:SetAlpha(0);
	Root:AlphaTo(255, 0.3, 0);
	Root:Center();
	Root:MakePopup();

	Root.btnMaxim:SetVisible(false);
	Root.btnMinim:SetVisible(false);

	function Root.btnClose:DoClick()
		Root:SetMouseInputEnabled(false);
		Root:SetKeyBoardInputEnabled(false);

		Root:AlphaTo(0, 0.3, 0, function()
			Root:Close();
		end);
	end

	function Root:Paint(w, h)
		surface.SetDrawColor(32, 32, 32);
		surface.DrawRect(0, 0, w, h);
	end

	local DisplayList = vgui.Create("DListView", Root);
	DisplayList:Dock(LEFT);
	DisplayList:SetWide(200);
	DisplayList:SetMultiSelect(false);
	DisplayList:AddColumn("Tag");

	function DisplayList:OnRowSelected(row, panel)
		url = displays[row][1];
		display = displays[row][2];
		owner = displays[row][3];

		Browser:OpenURL(url);
		OwnerLabel:SetText(owner:GetName() .. " - " .. owner:SteamID64());
	end

	for k,v in pairs(displays) do
		DisplayList:AddLine(tostring(v[2]:GetPos()));
	end

	Browser:SetParent(Root);
	Browser:Dock(FILL);

	OwnerLabel:SetParent(Root);
	OwnerLabel:Dock(TOP);
	OwnerLabel:SetContentAlignment(5);

	function OwnerLabel:DoClick()
		if owner then
			gui.OpenURL("https://steamcommunity.com/profiles/" .. owner:SteamID64());
		end
	end

	TpDisplayButton:SetParent(Root);
	TpDisplayButton:Dock(BOTTOM);
	TpDisplayButton:SetText("TP: Display");

	function TpDisplayButton:DoClick()
		if display then
			net.Start("elven.display.view");
			net.WriteEntity(display);
			net.SendToServer();
		end
	end
end

hook.Add("AddToolMenuCategories", "CustomCategory", function()
	spawnmenu.AddToolCategory("Options", "Elven Display", "#Elven Display")
end);

hook.Add("PopulateToolMenu", "CustomMenuSettings", function()
	spawnmenu.AddToolMenuOption("Options", "Elven Display", "Elven_Display_Client", "#Client", "", "", function(panel)
		panel:ClearControls();
		panel:CheckBox("Show Displays", "cl_elvendisplay_show");
		panel:CheckBox("Save On Close", "cl_elvendisplay_closeonsave");
	end);

	spawnmenu.AddToolMenuOption("Options", "Elven Display", "Elven_Display_Server", "#Server", "", "", function(panel)
		panel:ClearControls();
		panel:CheckBox("Admin Only", "sv_elvendisplay_adminonly");
		panel:CheckBox("Filters ignore admins", "sv_elvendisplay_filterignoreadmins");
		panel:CheckBox("Random Button", "sv_elvendisplay_random");
		panel:NumberWang("Max Size", "sv_elvendisplay_maxsize", 0, 7680);
		panel:NumberWang("File Limit (Kilobytes)", "sv_elvendisplay_kblimit", 200, 50000);
	end);
end)

net.Receive("elven.display.sync", function()
	net.ReadEntity():UpdateMedia(net.ReadString(), net.ReadFloat());
end);

net.Receive("elven.display.edit", function()
	EditMenu(net.ReadEntity());
end);

net.Receive("elven.display.view", function()
	local displays = {};
	local items = net.ReadUInt(12);

	for i = 1, items do
		table.insert(displays, {net.ReadString(), net.ReadEntity(), net.ReadEntity()});
	end

	AdminMenu(displays);
end);