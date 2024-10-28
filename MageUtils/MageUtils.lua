local L = LibStub("AceLocale-3.0"):GetLocale("MageNuggets")

MageUtils = {
    lockFrames = false;
}

function MU_Start(self)
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    SlashCmdList['MAGEUTILS_SLASHCMD'] = MageUtils_SlashCommandHandler
    SLASH_MAGEUTILS_SLASHCMD1 = L["/mageutils"]
end

function MageUtils_SlashCommandHandler(msg) --Handles the slash commands
    if (msg == "ports") then
        MageUtils_OnClick(); 
    else
    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff------------|cff00BFFF"..L["Mage"].." |cff00FF00"..L["Utils"].."|cffffffff 1.86--------------")
    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff"..L["/mageUtils"].." "..L["ports (Shows Portal Menu)"])
    end
end

function MageUtils_OnClick() 
    local englishFaction = UnitFactionGroup("player")
    if (englishFaction == "Horde")then
        MageUtilsHordeFrame:Show();
    end
    if (englishFaction == "Alliance") then
        MageUtilsAlliFrame:Show();
    end   
end

-- Initialize MageUtilsDB to store button position and settings
MageUtilsDB = MageUtilsDB or {
    ShowFloatingButton = true,
    ButtonPosition = {
        point = "CENTER",
        relativePoint = "CENTER",
        xOfs = 0,
        yOfs = 0,
    }
}

-- Function to check if Titan Panel is loaded
local function IsTitanPanelLoaded()
    return IsAddOnLoaded("Titan")
end

-- Create the main floating Mage Utils button
local mageUtilsButton = CreateFrame("Button", "MageUtilsButtonFrame", UIParent, "UIPanelButtonTemplate")
mageUtilsButton:SetSize(100, 24)
mageUtilsButton:SetPoint(
    MageUtilsDB.ButtonPosition.point,
    UIParent,
    MageUtilsDB.ButtonPosition.relativePoint,
    MageUtilsDB.ButtonPosition.xOfs,
    MageUtilsDB.ButtonPosition.yOfs
)
mageUtilsButton:SetMovable(true)
mageUtilsButton:EnableMouse(true)
mageUtilsButton:RegisterForDrag("LeftButton")
mageUtilsButton:SetScript("OnDragStart", function(self) self:StartMoving() end)
mageUtilsButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    MageUtilsDB.ButtonPosition = { point = point, relativePoint = relativePoint, xOfs = xOfs, yOfs = yOfs }
end)
mageUtilsButton:SetText("Mage Utils")

-- Function to toggle the visibility of Mage Utils button
local function UpdateMageUtilsButtonVisibility()
    if MageUtilsDB.ShowFloatingButton then
        mageUtilsButton:Show()
    else
        mageUtilsButton:Hide()
    end
end

-- Functions to open each spell category frame
local function ShowPortals() MageUtils_OnClick() end
local function ShowTeleports() MageUtilsTeleportsFrame:Show() end
local function ShowConjure() MageUtilsConjureFrame:Show() end

-- Hide all frames initially
local function HideAllFrames()
    if MageUtilsPortalsFrame then MageUtilsPortalsFrame:Hide() end
    if MageUtilsTeleportsFrame then MageUtilsTeleportsFrame:Hide() end
    if MageUtilsConjureFrame then MageUtilsConjureFrame:Hide() end
end

-- Attach dropdown menu to Mage Utils button
local MageUtilsDropdown = CreateFrame("Frame", "MageUtilsDropdownFrame", UIParent, "UIDropDownMenuTemplate")
local function InitializeMageUtilsDropdown(self, level)
    if not level then return end
    local info = UIDropDownMenu_CreateInfo()

    if level == 1 then
        info.text = "Portal"
        info.func = function() HideAllFrames() ShowPortals() end
        UIDropDownMenu_AddButton(info, level)

        info.text = "Teleport"
        info.func = function() HideAllFrames() ShowTeleports() end
        UIDropDownMenu_AddButton(info, level)

        info.text = "Conjure"
        info.func = function() HideAllFrames() ShowConjure() end
        UIDropDownMenu_AddButton(info, level)
    end
end

UIDropDownMenu_Initialize(MageUtilsDropdown, InitializeMageUtilsDropdown, "MENU")
mageUtilsButton:SetScript("OnClick", function(self, button)
    ToggleDropDownMenu(1, nil, MageUtilsDropdown, "cursor", 3, -3)
end)

-- Slash command to toggle the floating button visibility
SLASH_MAGEUTILS1 = "/mageutils"
SlashCmdList["MAGEUTILS"] = function(msg)
    MageUtilsDB.ShowFloatingButton = not MageUtilsDB.ShowFloatingButton
    if MageUtilsDB.ShowFloatingButton then
        print("|cFFFFFF00[Mage Utils]|r Floating button shown.")
    else
        print("|cFFFFFF00[Mage Utils]|r Floating button hidden.")
    end
    UpdateMageUtilsButtonVisibility()
end

-- Function to handle Titan Panel integration for MageUtils
local function IntegrateWithTitanPanelMageUtils()
    if not IsTitanPanelLoaded() then 
        print("|cFFFFFF00[Mage Utils]|r Titan Panel not loaded.")
        return 
    end

    -- Define the Titan Panel plugin details for MageUtils
    local MageUtilsTitanPlugin = {
        id = "MageUtils",
        version = "1.0",
        category = "General",
        menuText = "Mage Utils",
        buttonTextFunction = "TitanPanelMageUtilsButton_GetButtonText",
        tooltipTitle = "Mage Utils",
        tooltipTextFunction = "TitanPanelMageUtilsButton_GetTooltipText",
        icon = "Interface\\Icons\\Spell_Holy_ArcaneIntellect",
        iconWidth = 16,
        savedVariables = {
            ShowIcon = 1,
            ShowLabelText = true,
        },
    }

    -- Define text to display on the Titan Panel button
    function TitanPanelMageUtilsButton_GetButtonText(id)
        return "Mage Utils"
    end

    -- Define tooltip text for Titan Panel button
    function TitanPanelMageUtilsButton_GetTooltipText()
        return "Left-click to open Mage Utils menu."
    end

    -- Define the OnClick function to open MageUtils dropdown on left-click
    function TitanPanelMageUtilsButton_OnClick(self, button)
        if button == "LeftButton" then
            ToggleDropDownMenu(1, nil, MageUtilsDropdown, self, 0, 0)
        end
    end

    -- Register the plugin with Titan Panel
    local frame = CreateFrame("Button", "TitanPanelMageUtilsButton", UIParent, "TitanPanelComboTemplate")
    frame.registry = MageUtilsTitanPlugin
    frame:SetScript("OnClick", TitanPanelMageUtilsButton_OnClick)
    -- TitanPanelButton_OnLoad(frame)

    print("|cFFFFFF00[Mage Utils]|r Integrated with Titan Panel.")
end

IntegrateWithTitanPanelMageUtils()

function MULockFrames()
    if (MageUtils.lockFrames == false)then
       this:StartMoving(); this.isMoving = true;
    end
end