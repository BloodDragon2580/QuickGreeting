local addonName, addonTable = ...

addonTable.L = addonTable.L or {}
local L = addonTable.L

-- Default (English)
L["Hello"] = "Hello"
L["ThankYou"] = "Thank you"
L["Goodbye"] = "Goodbye"
L["HelloMessage"] = "Hello everyone!"
L["ThankYouMessage"] = "Thank you!"
L["GoodbyeMessage"] = "Goodbye!"
L["QuickGreeting"] = "QuickGreeting"
L["TooltipLeftClick"] = "Left Click to Open the Frame"
L["TooltipRightClick"] = "Right Click to move the Button"

-- German
if GetLocale() == "deDE" then
    L["Hello"] = "Hallo"
    L["ThankYou"] = "Danke"
    L["Goodbye"] = "Tschüss"
    L["HelloMessage"] = "Hallo zusammen!"
    L["ThankYouMessage"] = "Danke!"
    L["GoodbyeMessage"] = "Tschüss!"
    L["QuickGreeting"] = "QuickGreeting"
    L["TooltipLeftClick"] = "Linksklick, um das Fenster zu öffnen"
    L["TooltipRightClick"] = "Rechtsklick, um den Button zu verschieben"
end

-- Funktion für den Minimap-Button-Klick
function QuickGreeting_MinimapButton_OnClick(button)
    if button == "LeftButton" then
        SlashCmdList["QUICKGREETING"]("")
    end
end

-- Funktion für das Minimap-Button-Tooltip
function QuickGreeting_MinimapButton_OnEnter()
    GameTooltip:SetOwner(QuickGreeting_MinimapButton, "ANCHOR_LEFT")
    GameTooltip:SetText(L["QuickGreeting"])
    GameTooltip:AddLine(L["TooltipLeftClick"])
    GameTooltip:AddLine(L["TooltipRightClick"])
    GameTooltip:Show()
end

function QuickGreeting_MinimapButton_OnLeave()
    GameTooltip:Hide()
end

-- Funktion für das Draggen des Minimap-Buttons
function QuickGreeting_MinimapButton_DraggingFrame_OnUpdate()
    local xpos, ypos = GetCursorPosition()
    local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
    xpos = xmin - xpos / UIParent:GetScale() + 70
    ypos = ypos / UIParent:GetScale() - ymin - 70
    QuickGreetingDB.MinimapPos = math.deg(math.atan2(ypos, xpos))
    QuickGreeting_MinimapButton_Reposition()
end

-- Funktion zur Aktualisierung der Position des Minimap-Buttons
function QuickGreeting_MinimapButton_Reposition()
    local minimapButton = _G["QuickGreeting_MinimapButton"]
    minimapButton:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", 52 - (80 * cos(math.rad(QuickGreetingDB.MinimapPos))), (80 * sin(math.rad(QuickGreetingDB.MinimapPos))) - 52)
end

-- Frame für die Hauptoberfläche erstellen
local frame = CreateFrame("Frame", "QuickGreetingFrame", UIParent, "BackdropTemplate")
frame:SetSize(200, 150)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    QuickGreetingDB.framePos = {point, relativePoint, xOfs, yOfs}
end)
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
frame:SetBackdropColor(0.1, 0.1, 0.1, 0.7) -- Grau, leicht transparent
frame:Hide()

-- Funktion zum Erstellen der Buttons im Frame
local function CreateButton(name, y, command)
    local button = CreateFrame("Button", name, frame, "UIPanelButtonTemplate")
    button:SetSize(120, 22)
    button:SetPoint("CENTER", frame, "CENTER", 0, y)
    button:SetText(L[name])  -- Verwende die Übersetzung für den Button-Text
    button:SetScript("OnClick", function()
        SendChatMessage(command, IsInRaid() and "RAID" or IsInGroup() and "PARTY" or "SAY")
    end)
    return button
end

-- Erstellen der Buttons
local helloButton = CreateButton("Hello", 30, L["HelloMessage"])
local thanksButton = CreateButton("ThankYou", 0, L["ThankYouMessage"])
local byeButton = CreateButton("Goodbye", -30, L["GoodbyeMessage"])

-- Funktionen zur Aktualisierung der Positionen des Frames
local function UpdateFramePosition()
    if QuickGreetingDB and QuickGreetingDB.framePos then
        local point, relativePoint, xOfs, yOfs = unpack(QuickGreetingDB.framePos)
        if point and relativePoint then
            frame:ClearAllPoints()
            frame:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
        end
    else
        frame:SetPoint("CENTER")
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
    if addon == addonName then
        QuickGreetingDB = QuickGreetingDB or {}
        UpdateFramePosition()
    end
end)

-- Slash-Befehl zum Öffnen/Schließen des Frames
SLASH_QUICKGREETING1 = "/qg"
SlashCmdList["QUICKGREETING"] = function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end
