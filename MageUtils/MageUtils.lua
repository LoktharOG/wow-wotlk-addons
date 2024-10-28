-- MageUtils Addon
-- Version: 1.0
-- Description: Provides a floating button to access mage utilities and integrates with Titan Panel.

-- Initialize MageUtilsDB if not already set
MageUtilsDB = MageUtilsDB or {}
MageUtilsDB.ShowFloatingButton = MageUtilsDB.ShowFloatingButton ~= false -- Default to true
MageUtilsDB.ButtonPosition = MageUtilsDB.ButtonPosition or {
    point = "CENTER",
    relativePoint = "CENTER",
    xOfs = 0,
    yOfs = 0,
}

-- Create the movable floating button
local mageUtilsButton = CreateFrame("Button", "MageUtilsButtonFrame", UIParent, "UIPanelButtonTemplate")
mageUtilsButton:SetSize(120, 24)  -- Adjust size as needed
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
mageUtilsButton:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
mageUtilsButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save position
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
    MageUtilsDB.ButtonPosition = {
        point = point,
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs,
    }
end)
mageUtilsButton:SetText("Mage Utils")

-- Function to update the floating button's visibility
local function UpdateButtonVisibility()
    if MageUtilsDB.ShowFloatingButton then
        mageUtilsButton:Show()
    else
        mageUtilsButton:Hide()
    end
end

-- Initialize the dropdown menu frame
local MageUtilsDropDown = CreateFrame("Frame", "MageUtilsDropDownFrame", UIParent, "UIDropDownMenuTemplate")

-- Function to initialize the dropdown menu
local function InitializeMageUtilsDropDown(self, level)
    local faction = UnitFactionGroup("player")

    if not level then return end

    if level == 1 then
        -- Top-level menu items
        local info = UIDropDownMenu_CreateInfo()
        
        -- Teleport
        info = UIDropDownMenu_CreateInfo()
        info.text = "Teleport"
        info.func = function() 
            -- Check if player is a Mage and knows the spell
            local _, class = UnitClass("player")
            if class ~= "MAGE" then
                print("|cFFFFFF00[Mage Utils]|r You must be a Mage to use this feature.")
                return
            end
            if faction == "Alliance" then
                -- Show the Teleport Frame
                MageUtilsAllianceTeleportFrame:Show()
                print("|cFFFFFF00[Mage Utils]|r Teleport frame opened.")
            end
            if faction == "Horde" then
                -- Show the Teleport Frame
                MageUtilsHordeTeleportFrame:Show()
                print("|cFFFFFF00[Mage Utils]|r Teleport frame opened.")
            end
        end
         info.notCheckable = true
        UIDropDownMenu_AddButton(info, level)
        
        -- Portals
        info = UIDropDownMenu_CreateInfo()
        info.text = "Portals"
        info.func = function() print("Portals clicked") end -- Placeholder
        info.notCheckable = true
        UIDropDownMenu_AddButton(info, level)
        
        -- Conjure (with submenus)
        info = UIDropDownMenu_CreateInfo()
        info.text = "Conjure"
        info.hasArrow = true
        info.notCheckable = true
        UIDropDownMenu_AddButton(info, level)
        
    elseif level == 2 then
        -- Submenu items for Conjure
        local parent = UIDROPDOWNMENU_MENU_VALUE
        if parent == "Conjure" then
            local conjureOptions = {"Food", "Water", "Mana Gem", "Refreshment"}
            for _, option in ipairs(conjureOptions) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = option
                info.func = function() print("Conjure " .. option .. " clicked") end -- Placeholder
                info.notCheckable = true
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end
end

UIDropDownMenu_Initialize(MageUtilsDropDown, InitializeMageUtilsDropDown, "MENU")

-- Set the OnClick handler for the button to toggle the dropdown menu
mageUtilsButton:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        ToggleDropDownMenu(1, nil, MageUtilsDropDown, self, 0, 0)
    end
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
    UpdateButtonVisibility()
end

-- Function to handle Titan Panel integration
local function MageUtils_IntegrateWithTitanPanel()
    local MageUtilsTitanPlugin = {
        id = "MageUtils",
        version = "1.0",
        category = "General",
        menuText = "MageUtils",
        buttonTextFunction = "TitanPanelMageUtilsButton_GetButtonText",
        tooltipTitle = "Mage Utilities",
        tooltipTextFunction = "TitanPanelMageUtilsButton_GetTooltipText",
        icon = "Interface\\Icons\\Spell_Magic_LesserInvisibilty", -- Replace with a suitable icon
        iconWidth = 16,
        savedVariables = {
            ShowIcon = 1,
            ShowLabelText = true,
        },
    }

    function TitanPanelMageUtilsButton_GetButtonText(id)
        return "MageUtils"
    end

    function TitanPanelMageUtilsButton_GetTooltipText()
        return "Left-click to open Mage Utilities menu."
    end

    function TitanPanelMageUtilsButton_OnClick(self, button)
        if button == "LeftButton" then
            ToggleDropDownMenu(1, nil, MageUtilsDropDown, self, 0, 0)
        end
    end

    -- Register the plugin with Titan Panel
    local frame = CreateFrame("Button", "TitanPanelMageUtilsButton", UIParent, "TitanPanelComboTemplate")
    frame.registry = MageUtilsTitanPlugin
    frame:SetScript("OnClick", TitanPanelMageUtilsButton_OnClick)

    print("|cFFFFFF00[Mage Utils]|r Integrated with Titan Panel.")
end

MageUtils_IntegrateWithTitanPanel()
UpdateButtonVisibility()
