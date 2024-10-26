-- Function to handle custom command messages
local function OnChat(event, player, msg, _, _)
    -- Check if the message is a custom command
    if msg:sub(1, 6) == "!cast " then
        -- Extract the spellID from the message
        local spellID = tonumber(msg:sub(7))

        if spellID then
            -- Execute the spell as a GM command
            player:CastSpell(player, spellID, true)  -- 'true' to cast without targeting
            player:SendBroadcastMessage("|cFF69CCF0[Mage Utils]|r Cast spell with ID: " .. spellID)
        else
            player:SendBroadcastMessage("|cFFFF0000[Mage Utils]|r Invalid spell ID provided.")
        end
    end
end

-- Register the chat event to listen for messages
RegisterPlayerEvent(18, OnChat) 