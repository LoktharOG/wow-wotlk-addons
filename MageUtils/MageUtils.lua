-- Initialize MageUtilsDB if not already set
MageUtilsDB = MageUtilsDB or {}
MageUtilsDB.ShowFloatingButton = MageUtilsDB.ShowFloatingButton ~= false -- Default to true
MageUtilsDB.ButtonPosition = MageUtilsDB.ButtonPosition or {
    point = "CENTER",
    relativePoint = "CENTER",
    xOfs = 0,
    yOfs = 0,
}

-- Function to check if Titan Panel is loaded
local function IsTitanPanelLoaded()
    return IsAddOnLoaded("Titan")
end

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

-- Function to check if a spell is known (compatible with WotLK)
local function IsSpellKnownWotLK(spellID)
    if IsSpellKnown then
        return IsSpellKnown(spellID)
    else
        local spellName = GetSpellInfo(spellID)
        if not spellName then return false end

        for i = 1, MAX_SKILLLINE_TABS or 4 do
            local _, _, offset, numSpells = GetSpellTabInfo(i)
            if not numSpells then break end
            for j = offset + 1, offset + numSpells do
                local spellType, spellBookSpellID = GetSpellBookItemInfo(j, "spell")
                if spellType == "SPELL" and spellBookSpellID == spellID then
                    return true
                end
            end
        end
        return false
    end
end

-- Function to retrieve the mage's spells
local function GetMageSpells()
    local mageSpells = {
        ["Conjure Spells"] = {
            ["Conjure Food"] = {},
            ["Conjure Water"] = {},
            ["Conjure Mana Gem"] = {},
            ["Ritual of Refreshment"] = {},
        },
        ["Teleport"] = {},
        ["Portal"] = {}
    }

    -- Conjure Food spells
    local conjureFoodSpellIDs = {587, 597, 990, 6129, 10144, 10145, 28612}
    for _, spellID in ipairs(conjureFoodSpellIDs) do
        if IsSpellKnownWotLK(spellID) then
            local spellName, spellRank, spellIcon = GetSpellInfo(spellID)
            local fullName = spellRank and (spellName .. " (" .. spellRank .. ")") or spellName
            table.insert(mageSpells["Conjure Spells"]["Conjure Food"], { fullName = fullName, spellID = spellID, icon = spellIcon })
        end
    end

    -- Conjure Water spells
    local conjureWaterSpellIDs = {5504, 5505, 5506, 6127, 10138, 10139, 10140, 37420}
    for _, spellID in ipairs(conjureWaterSpellIDs) do
        if IsSpellKnownWotLK(spellID) then
            local spellName, spellRank, spellIcon = GetSpellInfo(spellID)
            local fullName = spellRank and (spellName .. " (" .. spellRank .. ")") or spellName
            table.insert(mageSpells["Conjure Spells"]["Conjure Water"], { fullName = fullName, spellID = spellID, icon = spellIcon })
        end
    end

    -- Conjure Mana Gem spells
    local conjureManaGemSpellIDs = {759, 3552, 10053, 10054, 27101, 42985}
    for _, spellID in ipairs(conjureManaGemSpellIDs) do
        if IsSpellKnownWotLK(spellID) then
            local spellName, spellRank, spellIcon = GetSpellInfo(spellID)
            local fullName = spellRank and (spellName .. " (" .. spellRank .. ")") or spellName
            table.insert(mageSpells["Conjure Spells"]["Conjure Mana Gem"], { fullName = fullName, spellID = spellID, icon = spellIcon })
        end
    end

    -- Ritual of Refreshment spells
    local ritualRefreshmentSpellIDs = {43987, 58659}
    for _, spellID in ipairs(ritualRefreshmentSpellIDs) do
        if IsSpellKnownWotLK(spellID) then
            local spellName, spellRank, spellIcon = GetSpellInfo(spellID)
            local fullName = spellRank and (spellName .. " (" .. spellRank .. ")") or spellName
            table.insert(mageSpells["Conjure Spells"]["Ritual of Refreshment"], { fullName = fullName, spellID = spellID, icon = spellIcon })
        end
    end

    -- Determine player's faction
    local faction = UnitFactionGroup("player")

    -- Teleport spells based on faction
    local teleportSpells = {}
    if faction == "Alliance" then
        teleportSpells = {
            { name = "Teleport: Stormwind", spellID = 3561 },
            { name = "Teleport: Ironforge", spellID = 3562 },
            { name = "Teleport: Darnassus", spellID = 3565 },
            { name = "Teleport: Exodar", spellID = 32271 },
            { name = "Teleport: Theramore", spellID = 49359 },
            { name = "Teleport: Shattrath", spellID = 33690 },
            { name = "Teleport: Dalaran", spellID = 53140 },
        }
    elseif faction == "Horde" then
        teleportSpells = {
            { name = "Teleport: Orgrimmar", spellID = 3567 },
            { name = "Teleport: Undercity", spellID = 3563 },
            { name = "Teleport: Thunder Bluff", spellID = 3566 },
            { name = "Teleport: Silvermoon", spellID = 32272 },
            { name = "Teleport: Stonard", spellID = 49358 },
            { name = "Teleport: Shattrath", spellID = 35715 },
            { name = "Teleport: Dalaran", spellID = 53140 },
        }
    end

    for _, spell in ipairs(teleportSpells) do
        if IsSpellKnownWotLK(spell.spellID) then
            local spellName, _, spellIcon = GetSpellInfo(spell.spellID)
            table.insert(mageSpells["Teleport"], {
                name = spellName,
                spellID = spell.spellID,
                icon = spellIcon,
            })
        end
    end

    -- Portal spells based on faction
    local portalSpells = {}
    if faction == "Alliance" then
        portalSpells = {
            { name = "Portal: Stormwind", spellID = 10059 },
            { name = "Portal: Ironforge", spellID = 11416 },
            { name = "Portal: Darnassus", spellID = 11419 },
            { name = "Portal: Exodar", spellID = 32266 },
            { name = "Portal: Theramore", spellID = 49360 },
            { name = "Portal: Shattrath", spellID = 33691 },
            { name = "Portal: Dalaran", spellID = 53142 },
        }
    elseif faction == "Horde" then
        portalSpells = {
            { name = "Portal: Orgrimmar", spellID = 11417 },
            { name = "Portal: Undercity", spellID = 11418 },
            { name = "Portal: Thunder Bluff", spellID = 11420 },
            { name = "Portal: Silvermoon", spellID = 32267 },
            { name = "Portal: Stonard", spellID = 49361 },
            { name = "Portal: Shattrath", spellID = 35717 },
            { name = "Portal: Dalaran", spellID = 53142 },
        }
    end

    for _, spell in ipairs(portalSpells) do
        if IsSpellKnownWotLK(spell.spellID) then
            local spellName, _, spellIcon = GetSpellInfo(spell.spellID)
            table.insert(mageSpells["Portal"], {
                name = spellName,
                spellID = spell.spellID,
                icon = spellIcon,
            })
        end
    end

    -- Remove empty categories and subcategories
    for categoryName, categoryData in pairs(mageSpells) do
        if type(categoryData) == "table" and next(categoryData) == nil then
            mageSpells[categoryName] = nil
        elseif type(categoryData) == "table" then
            for subcategoryName, subcategoryData in pairs(categoryData) do
                if type(subcategoryData) == "table" and next(subcategoryData) == nil then
                    mageSpells[categoryName][subcategoryName] = nil
                end
            end
            if next(mageSpells[categoryName]) == nil then
                mageSpells[categoryName] = nil
            end
        end
    end

    return mageSpells
end

-- Initialize the dropdown menu
local function InitializeMageUtilsDropDown(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    local mageSpells = GetMageSpells()

    if level == 1 then
        for categoryName, _ in pairs(mageSpells) do
            info.text = categoryName
            info.menuList = categoryName
            info.hasArrow = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
        end
    elseif level == 2 then
        if menuList == "Conjure Spells" then
            for subcategory, spells in pairs(mageSpells["Conjure Spells"]) do
                if next(spells) then
                    info.text = subcategory
                    info.menuList = subcategory
                    info.hasArrow = true
                    info.notCheckable = true
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        else
            local spells = mageSpells[menuList]
            if spells then
                for _, spell in ipairs(spells) do
                    info.text = spell.name
                    info.icon = spell.icon
                    info.func = function()
                        local spellID = spell.spellID
                        local commandMessage = "!cast " .. spellID
                        SendChatMessage(commandMessage, "WHISPER", nil, UnitName("player"))
                    end
                    info.notCheckable = true
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end
    elseif level == 3 then
        local spells = mageSpells["Conjure Spells"][menuList]
        if spells then
            for _, spell in ipairs(spells) do
                local spellFullName = spell.fullName
                info.text = spellFullName
                info.icon = spell.icon
                info.func = function()
                    local spellID = spell.spellID
                    local commandMessage = "!cast " .. spellID
                    SendChatMessage(commandMessage, "WHISPER", nil, UnitName("player"))
                end
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
        print("|cFF69CCF0[Mage Utils]|r Floating button shown.")
    else
        print("|cFF69CCF0[Mage Utils]|r Floating button hidden.")
    end
    UpdateButtonVisibility()
end

-- Function to handle Titan Panel integration
local function IntegrateWithTitanPanel()
    if not IsTitanPanelLoaded() then return end

    local MageUtilsTitanPlugin = {
        id = "MageUtils",
        version = "1.0",
        category = "General",
        menuText = "Mage Utils",
        buttonTextFunction = "TitanPanelMageUtilsButton_GetButtonText",
        tooltipTitle = "Mage Utils",
        tooltipTextFunction = "TitanPanelMageUtilsButton_GetTooltipText",
        icon = "Interface\\Icons\\INV_Misc_Book_09",
        iconWidth = 16,
        savedVariables = {
            ShowIcon = 1,
            ShowLabelText = true,
        },
    }

    function TitanPanelMageUtilsButton_GetButtonText(id)
        return "Mage Utils"
    end

    function TitanPanelMageUtilsButton_GetTooltipText()
        return "Left-click to open Mage Utils menu."
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
    --TitanPanelButton_OnLoad(frame)

    print("|cFF69CCF0[Mage Utils]|r Integrated with Titan Panel.")
end

-- Event frame to handle addon loading and initialization
local mageEventFrame = CreateFrame("Frame")
mageEventFrame:RegisterEvent("ADDON_LOADED")
mageEventFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName ~= "MageUtils" then return end

    -- Load button position
    local function LoadButtonPosition()
        local pos = MageUtilsDB.ButtonPosition
        mageUtilsButton:ClearAllPoints()
        mageUtilsButton:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    end

    LoadButtonPosition()
    UpdateButtonVisibility()

    -- Integrate with Titan Panel if it's loaded
    if IsTitanPanelLoaded() then
        IntegrateWithTitanPanel()
    end

    -- Print startup messages
    print("|cFF69CCF0[Mage Utils]|r Addon loaded.")
    print("|cFF69CCF0[Mage Utils]|r Use /mageutils to toggle floating button.")
    if IsTitanPanelLoaded() then
        print("|cFF69CCF0[Mage Utils]|r Titan Panel detected and integrated.")
    else
        print("|cFF69CCF0[Mage Utils]|r Titan Panel not detected.")
    end
end)
