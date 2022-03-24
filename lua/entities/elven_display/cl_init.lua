include("shared.lua");

function ENT:Initialize()
	self:SetupPanel();
end

function ENT:SetupPanel()
	if BRANCH == "x86-64" then
		self.Panel = vgui.Create("DChromium");
	else
		self.Panel = vgui.Create("DHTML");
	end

	self.Panel:SetPaintedManually(true);
	self.Panel:SetPos(0, 0);
	self.Panel:SetSize(150, 150);

	self.Panel:SetHTML([[
		<style>
			body
			{
				overflow: hidden;
				border: none !important;
			}
		</style>

		<div id="home">
			<b id="main">Loading...</b>
		</div>

		<script>
			function ShowImage(url)
			{
				var img = document.createElement("img"); 
				img.src = url;
				img.id = "main";
				img.style.width = "100%";
				img.style.position = "absolute";
				img.style.bottom = "5px";

				img.onload = function()
				{
					display.SyncSize(img.naturalWidth, img.naturalHeight);
				}
				
				document.getElementById("home").removeChild(document.getElementById("main"));
				document.getElementById("home").appendChild(img); 
			}

			function ShowVideo(url)
			{
				var vid = document.createElement("video");
				vid.autoplay = true;
				vid.loop = true;
				vid.muted = true;
				vid.id = "main";
				vid.style.width = "100%";
				vid.style.position = "absolute";
				vid.style.bottom = "5px";

				vid.oncanplay = function()
				{
					display.SyncSize(vid.videoWidth, vid.videoHeight);
				}

				var source = document.createElement("source");
				source.type = "video/webm";
				source.src = url;

				vid.appendChild(source);

				document.getElementById("home").removeChild(document.getElementById("main"));
				document.getElementById("home").appendChild(vid);
			}

			function SetMedia(url)
			{
				if (url.indexOf(".webm", url.length - 5) !== -1)
				{
					ShowVideo(url);
				}
				else
				{
					ShowImage(url);
				}
			}
		</script>
	]]);

	local ref = self;
	self.Panel:AddFunction("display", "SyncSize", function(w, h)
		if w and h then
			local maxSize = ElvenDisplay.MaxSize:GetInt();

			if w > maxSize or h > maxSize then
				local scale = (w > h) and (w / maxSize) or (h / maxSize);
				w = math.floor(w / scale);
				h = math.floor(h / scale);
			end

			ref.Panel:SetSize(w, h);
			ref.Ratio = (w > h) and (h / w) or (w / h);

			ref:ScaleRenderBounds();
		end
	end);

	self.LastSrc = "";
	self.RenderScale = 0;
	self.Ratio = 1;
	self.Delta = SysTime();
	self.MediaSrc = "asset://garrysmod/materials/elven_display/icon.png";
	self.MediaScale = 0.24;

	net.Start("elven.display.sync");
		net.WriteEntity(self);
	net.SendToServer();
end

function ENT:ScaleRenderBounds()
	if not IsValid(self.Panel) then
		self:SetupPanel();
	end

	local w, h = self.Panel:GetSize();
	self:SetRenderBounds(Vector(0, (-w / 2), 0) * self.MediaScale, Vector(0, w / 2, h) * self.MediaScale);
end

function ENT:UpdateMedia(url, scale)
	if not IsValid(self.Panel) then
		self:SetupPanel();
	end

	self.MediaSrc = url;
	self.MediaScale = scale;

	if self.LastSrc ~= self.MediaSrc then
		self.Panel:Call('SetMedia("' .. self.MediaSrc .. '");');
		self.LastSrc = self.MediaSrc;
		self.RenderScale = 0;
	end

	if self.RenderScale ~= self.MediaScale then
		self.Delta = SysTime();
	end

	self:ScaleRenderBounds();
end

function ENT:DrawTranslucent()
	self:DrawModel();

	if not IsValid(self.Panel) then
		--[[
			For unknown reasons, self.Panel will randomly become null for a very small group of people.
			I don't know enough about the problem to claim what's causing it.
			My head immediately thinks of the garbage collector, but again i have no idea.

			The only lead i have so far: People that have this problem also have high ping.
			So this is here to fix that problem for people that run into it.
		]]

		self:SetupPanel();
		return;
	end

	local w, h = self.Panel:GetSize();

	if self.RenderScale ~= self.MediaScale then
		self.RenderScale = Lerp((SysTime() - self.Delta) / (self.Ratio * 10), self.RenderScale, self.MediaScale);
	end

	local angles = self:EyeAngles();
	local rotated = self:EyeAngles();
	rotated:RotateAroundAxis(rotated:Forward(), 90);
	rotated:RotateAroundAxis(rotated:Right(), -90);

	if self:GetForward():Dot((self:GetPos() - EyePos()):GetNormalized()) < 0 then
		cam.Start3D2D(((self:GetPos() + (angles:Up() * (h * self.RenderScale))) - (angles:Right() * -((w * self.RenderScale) / 2))), rotated, self.RenderScale);
			self.Panel:PaintManual();
		cam.End3D2D();
	else
		rotated:RotateAroundAxis(rotated:Right(), 180);

		cam.Start3D2D(((self:GetPos() + (angles:Up() * (h * self.RenderScale))) - (angles:Right() * ((w * self.RenderScale) / 2))), rotated, self.RenderScale);
			self.Panel:PaintManual();
		cam.End3D2D();
	end
end

function ENT:OnRemove()
	if IsValid(self.Panel) then
		self.Panel:Remove();
	end
end