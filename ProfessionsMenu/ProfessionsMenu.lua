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

-- List of profession spell IDs (WotLK)
local professionSpellIds = {
    2259,   -- Alchemy
    2018,   -- Blacksmithing
    7411,   -- Enchanting
    4036,   -- Engineering
    45357,  -- Inscription
    25229,  -- Jewelcrafting
    2108,   -- Leatherworking
    3908,   -- Tailoring
    2550,   -- Cooking
    3273,   -- First Aid
    2366,   -- Herbalism
    2575,   -- Mining
    8613,   -- Skinning
    7620,   -- Fishing
    53428,  -- Runeforging
}

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

    -- Process the professions list
    for _, spellId in ipairs(professionSpellIds) do
        local spellName, _, spellIcon = GetSpellInfo(spellId)
        local hasProfession = false
        local skillLevel = "Unknown"
        local maxSkillLevel = "Unknown"
        local func = nil
        if spellName then
            if skillLines[spellName] then
                hasProfession = true
                skillLevel = skillLines[spellName].skillRank
                maxSkillLevel = skillLines[spellName].skillMaxRank
            end
            table.insert(professions, {
                name = spellName,
                icon = spellIcon,
                hasProfession = hasProfession,
                skillLevel = skillLevel,
                maxSkillLevel = maxSkillLevel,
                func = func
            })
        end
    end

    -- Add the Riding skill
    local ridingSkill = skillLines["Riding"]
    if ridingSkill then
        table.insert(professions, {
            name = "Riding",
            icon = "Interface\\Icons\\Spell_Nature_Swiftness",
            hasProfession = true,
            skillLevel = ridingSkill.skillRank,
            maxSkillLevel = ridingSkill.skillMaxRank,
            func = nil  -- No action on click
        })
    else
        table.insert(professions, {
            name = "Riding",
            icon = "Interface\\Icons\\Spell_Nature_Swiftness",
            hasProfession = false,
            skillLevel = "Unknown",
            maxSkillLevel = "Unknown",
            func = nil
        })
    end

    return professions
end

-- Initialize the dropdown menu
local function InitializeProfessionsDropDown(self, level)
    if not level then return end
    local professions = GetPlayerProfessions()
    for _, prof in ipairs(professions) do
        local info = UIDropDownMenu_CreateInfo()
        if prof.hasProfession then
            info.text = string.format("%s (%s/%s)    ", prof.name , prof.skillLevel, prof.maxSkillLevel)
            info.disabled = false
            info.func = prof.func
        else
            info.text = string.format("%s (Unknown)    ", prof.name)
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
    if not IsTitanPanelLoaded() then return end

    local ProfessionsTitanPlugin = {
        id = "ProfessionsMenu",
        version = "1.0",
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
    --TitanPanelButton_OnLoad(frame)

    print("|cFFFFFF00[Professions Menu]|r Integrated with Titan Panel.")
end

-- Event frame to handle addon loading
local profmenuEventFrame = CreateFrame("Frame")
profmenuEventFrame:RegisterEvent("ADDON_LOADED")
profmenuEventFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "ProfessionsMenu" then
        -- Initialize saved variables and UI elements
        UpdateButtonVisibility()
        if IsTitanPanelLoaded() then
            IntegrateWithTitanPanel()
        end

        -- Print startup messages
        print("|cFFFFFF00[Professions Menu]|r Addon loaded.")
        print("|cFFFFFF00[Professions Menu]|r Use /profmenu to toggle floating button.")
        if IsTitanPanelLoaded() then
            print("|cFFFFFF00[Professions Menu]|r Titan Panel detected and integrated.")
        else
            print("|cFFFFFF00[Professions Menu]|r Titan Panel not detected.")
        end
    end
end)
