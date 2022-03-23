--[[
    Taken from https://github.com/Facepunch/garrysmod/blob/ee2e914d3a801d27ecf361057a59563fd4bfc48b/garrysmod/lua/vgui/dhtml.lua
    Purely done to allow AddFunction on Chromium panels.
]]

local PANEL = {};

AccessorFunc(PANEL, "m_bScrollbars", "Scrollbars", FORCE_BOOL);
AccessorFunc(PANEL, "m_bAllowLua", "AllowLua", FORCE_BOOL);

function PANEL:Init()
    self:SetScrollbars(true);
    self:SetAllowLua(false);

    self.JS = {};
    self.Callbacks = {};
end

function PANEL:Think()
    if self.JS and not self:IsLoading() then
        for k, v in pairs(self.JS) do
            self:RunJavascript(v);
        end

        self.JS = nil
    end
end

function PANEL:Paint()
    if self:IsLoading() then
        return true;
    end
end

function PANEL:QueueJavascript(js)
    if not self.JS and not self:IsLoading() then
        return self:RunJavascript(js);
    end

    self.JS = self.JS or {};

    table.insert(self.JS, js);
    self:Think();
end

function PANEL:Call(js)
    self:QueueJavascript(js);
end

function PANEL:OnCallback(obj, func, args)
    local f = self.Callbacks[obj .. "." .. func];

    if f then
        return f(unpack(args));
    end
end

function PANEL:AddFunction(obj, funcname, func)
    if not self.Callbacks[obj] then
        self:NewObject(obj);
        self.Callbacks[obj] = true;
    end

    self:NewObjectCallback(obj, funcname);
    self.Callbacks[obj .. "." .. funcname] = func;
end

function PANEL:OnBeginLoadingDocument(url)

end

function PANEL:OnFinishLoadingDocument(url)

end

function PANEL:OnDocumentReady(url)

end

function PANEL:OnChildViewCreated(sourceURL, targetURL, isPopup)

end

function PANEL:OnChangeTitle(title)

end

function PANEL:OnChangeTargetURL(url)

end

derma.DefineControl("DChromium", "A chrome shape", PANEL, "Chromium");