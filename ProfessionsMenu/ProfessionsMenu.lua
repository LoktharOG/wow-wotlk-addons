-- ProfessionsMenu Addon
-- Version: 1.2
-- Description: Provides a floating button to access professions and integrates with Titan Panel.

-- Initialize ProfessionsMenuDB if not already set
ProfessionsMenuDB = ProfessionsMenuDB or {}
ProfessionsMenuDB.ShowFloatingButton = ProfessionsMenuDB.ShowFloatingButton ~= false -- Default to true
ProfessionsMenuDB.ButtonPosition = ProfessionsMenuDB.ButtonPosition or {
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
local professionsButton = CreateFrame("Button", "ProfessionsButtonFrame", UIParent, "UIPanelButtonTemplate")
professionsButton:SetSize(100, 24)  -- Adjust size as needed
professionsButton:SetPoint(
    ProfessionsMenuDB.ButtonPosition.point,
    UIParent,
    ProfessionsMenuDB.ButtonPosition.relativePoint,
    ProfessionsMenuDB.ButtonPosition.xOfs,
    ProfessionsMenuDB.ButtonPosition.yOfs
)
professionsButton:SetMovable(true)
professionsButton:EnableMouse(true)
professionsButton:RegisterForDrag("LeftButton")
professionsButton:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
professionsButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save position
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
    ProfessionsMenuDB.ButtonPosition = {
        point = point,
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs,
    }
end)
professionsButton:SetText("Professions")

-- Function to update the floating button's visibility
local function UpdateButtonVisibility()
    if ProfessionsMenuDB.ShowFloatingButton then
        professionsButton:Show()
    else
        professionsButton:Hide()
    end
end

-- Initialize the dropdown menu frame
local ProfessionsDropDown = CreateFrame("Frame", "ProfessionsDropDownFrame", UIParent, "UIDropDownMenuTemplate")

-- Expanded list of profession spell IDs including all ranks
local professionSpellIds = {
    Alchemy = {2259, 3101, 3464, 11611, 28596, 51304},
    Blacksmithing = {2018, 3100, 3538, 9785, 29844, 51300},
    Enchanting = {7411, 7412, 7413, 13920, 28029, 51313},
    Engineering = {4036, 4037, 4038, 12656, 20219, 51306},
    Inscription = {45357, 45358, 45359, 45360, 45361},
    Jewelcrafting = {25229, 25230, 28894, 28895, 28897, 51311},
    Leatherworking = {2108, 3104, 3811, 10662, 32549, 51302},
    Tailoring = {3908, 3909, 3910, 12180, 26790, 51309},
    Cooking = {2550, 3102, 3413, 18260, 33359},
    FirstAid = {3273, 3274, 7924, 10846, 27028},
    Mining = {2575, 2576, 3564, 10248, 29354},
    Herbalism = {2366, 2368, 3570, 11993, 28695},
    Skinning = {8613, 8617, 8618, 10768, 32678},
    Fishing = {7620, 7731, 7732, 18248, 33095},
    Runeforging = {53428}  -- Only one rank for Runeforging
}

local gatheringProfessions = {"Skinning", "Herbalism", "Fishing", "Riding"}

-- Function to retrieve the player's professions, including Riding
local function GetPlayerProfessions()
    local professions = {}
    local numSkills = GetNumSkillLines()
    local skillLines = {}

    -- Build a table of the player's skill lines
    for i = 1, numSkills do
        local skillName, isHeader, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i)
        if not isHeader then
            skillLines[skillName] = {
                skillRank = skillRank,
                skillMaxRank = skillMaxRank
            }
        end
    end

    -- Process the professions list, handling gathering professions separately
    for profession, spellIds in pairs(professionSpellIds) do
        local hasProfession = false
        local skillLevel = "Unknown"
        local maxSkillLevel = "Unknown"
        local func = nil
        local spellIcon, spellName = nil, nil

        if profession == "Mining" then
            -- For Mining, use Smelting spell ID if learned
            local smeltSpellId = 2656
            hasProfession = skillLines[profession] ~= nil
            skillLevel = hasProfession and skillLines[profession].skillRank or "Unknown"
            maxSkillLevel = hasProfession and skillLines[profession].skillMaxRank or "Unknown"
            if IsSpellKnown(smeltSpellId) then
                func = function()
                    CastSpellByID(smeltSpellId)
                end
            end
            spellName, _, spellIcon = GetSpellInfo(spellIds[1]) -- Use the first icon as a placeholder

        elseif profession == "Skinning" or profession == "Herbalism" or profession == "Fishing" then
            -- For Skinning, Herbalism, and Fishing, set func to nil (do nothing when clicked)
            hasProfession = skillLines[profession] ~= nil
            skillLevel = hasProfession and skillLines[profession].skillRank or "Unknown"
            maxSkillLevel = hasProfession and skillLines[profession].skillMaxRank or "Unknown"
            func = nil
            spellName, _, spellIcon = GetSpellInfo(spellIds[1]) -- Use the first icon as a placeholder
        else
            -- Handle other crafting professions
            for _, spellId in ipairs(spellIds) do
                spellName, _, spellIcon = GetSpellInfo(spellId)
                if IsSpellKnown(spellId) then
                    hasProfession = true
                    if skillLines[spellName] then
                        skillLevel = skillLines[spellName].skillRank
                        maxSkillLevel = skillLines[spellName].skillMaxRank
                    end
                    func = function()
                        CastSpellByID(spellId)
                    end
                    break  -- Stop once we find the highest rank they have
                end
            end
        end

        -- Add profession data to the dropdown menu list
        table.insert(professions, {
            name = profession,
            icon = spellIcon,
            hasProfession = hasProfession,
            skillLevel = skillLevel,
            maxSkillLevel = maxSkillLevel,
            func = func
        })
    end

    -- Separate out gathering professions and Riding for special ordering
    local regularProfessions = {}
    local specialProfessions = {}

    for _, prof in ipairs(professions) do
        if tContains(gatheringProfessions, prof.name) or prof.name == "Riding" then
            table.insert(specialProfessions, prof)
        else
            table.insert(regularProfessions, prof)
        end
    end

    -- Sort regular and special professions alphabetically
    table.sort(regularProfessions, function(a, b) return a.name < b.name end)
    table.sort(specialProfessions, function(a, b) return a.name < b.name end)

    -- Combine sorted lists
    for _, prof in ipairs(specialProfessions) do
        table.insert(regularProfessions, prof)
    end

    return regularProfessions
end

-- Initialize the dropdown menu
local function InitializeProfessionsDropDown(self, level)
    if not level then return end
    local professions = GetPlayerProfessions()
    for _, prof in ipairs(professions) do
        local info = UIDropDownMenu_CreateInfo()
        if prof.hasProfession then
            info.text = string.format("%s (%s/%s)", prof.name, prof.skillLevel, prof.maxSkillLevel)
            info.disabled = false
            info.func = prof.func
        else
            info.text = string.format("%s (Unknown)", prof.name)
            info.disabled = true
            info.func = nil
        end
        info.icon = prof.icon
        info.notCheckable = true
        UIDropDownMenu_AddButton(info, level)
    end
end

UIDropDownMenu_Initialize(ProfessionsDropDown, InitializeProfessionsDropDown, "MENU")

-- Set the OnClick handler for the button to toggle the dropdown menu
professionsButton:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        ToggleDropDownMenu(1, nil, ProfessionsDropDown, self, 0, 0)
    end
end)

-- Slash command to toggle the floating button visibility
SLASH_PROFESSIONSMENU1 = "/profmenu"
SlashCmdList["PROFESSIONSMENU"] = function(msg)
    ProfessionsMenuDB.ShowFloatingButton = not ProfessionsMenuDB.ShowFloatingButton
    if ProfessionsMenuDB.ShowFloatingButton then
        print("|cFFFFFF00[Professions Menu]|r Floating button shown.")
    else
        print("|cFFFFFF00[Professions Menu]|r Floating button hidden.")
    end
    UpdateButtonVisibility()
end

-- Function to handle Titan Panel integration
local function IntegrateWithTitanPanel()
    

    local ProfessionsTitanPlugin = {
        id = "ProfessionsMenu",
        version = "1.2",
        category = "Profession",
        menuText = "ProfessionsMenu",
        buttonTextFunction = "TitanPanelProfessionsMenuButton_GetButtonText",
        tooltipTitle = "Professions",
        tooltipTextFunction = "TitanPanelProfessionsMenuButton_GetTooltipText",
        icon = "Interface\\Icons\\Trade_BlackSmithing",
        iconWidth = 16,
        savedVariables = {
            ShowIcon = 1,
            ShowLabelText = true,
        },
    }

    function TitanPanelProfessionsMenuButton_GetButtonText(id)
        return "Professions"
    end

    function TitanPanelProfessionsMenuButton_GetTooltipText()
        return "Left-click to open Professions menu."
    end

    function TitanPanelProfessionsMenuButton_OnClick(self, button)
        if button == "LeftButton" then
            ToggleDropDownMenu(1, nil, ProfessionsDropDown, self, 0, 0)
        end
    end

    -- Register the plugin with Titan Panel
    local frame = CreateFrame("Button", "TitanPanelProfessionsMenuButton", UIParent, "TitanPanelComboTemplate")
    frame.registry = ProfessionsTitanPlugin
    frame:SetScript("OnClick", TitanPanelProfessionsMenuButton_OnClick)
    -- TitanPanelButton_OnLoad(frame)

    print("|cFFFFFF00[Professions Menu]|r Integrated with Titan Panel.")
end

IntegrateWithTitanPanel()
