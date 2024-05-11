local elapsed_time = 0


local function is_mythic_plus()
    return C_ChallengeMode.GetActiveChallengeMapID()
end

local function get_mythic_plus_time()
    if not is_mythic_plus() then
        return 0
    end

    local current_map_id = C_ChallengeMode.GetActiveChallengeMapID()
    local _, _, max_time = C_ChallengeMode.GetMapUIInfo(current_map_id)
    local remaining_time = max_time - elapsed_time

    if remaining_time < 0 then
        remaining_time = 0
    end

    return remaining_time
end

-- Send message to channel
local function get_message()
    local name = GetInstanceInfo()
    local _, _, steps = C_Scenario.GetStepInfo()
    local completed_count = 0;
    local total_count = 0;

    if not steps or steps <= 0 then
        return "Currently not playing Mythic+"
    end

    for i = 1, steps do
        local _, criteria_type, completed = C_Scenario.GetCriteriaInfo(i)

        if criteria_type ~= 0 then
            if completed then
                completed_count = completed_count + 1
            end

            total_count = total_count + 1
        end
    end

    if is_mythic_plus() then
        local remaining_time = get_mythic_plus_time()
        local keystone_level = C_ChallengeMode.GetActiveKeystoneInfo()
        local death_count = C_ChallengeMode.GetDeathCount()

        return "[+"..keystone_level.."] "..name..". Killed: "..completed_count.." / "..total_count..", Time left: "..format_time(remaining_time)..", Deaths: "..death_count
    end

    return name..". Killed: "..completed_count.." / "..total_count
end

local function send_message(message, player_name, bn_sender_id)
    if bn_sender_id ~= 0 then
        BNSendWhisper(bn_sender_id, message)
    else
        SendChatMessage(message, "WHISPER", nil, player_name)
    end
end

local function on_chat_event(self, event, ...)
    if event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_BN_WHISPER" then
        local text, player_name, _, _, _, _, _, _, _, _, _, _, bn_sender_id = ...

        if text:match("!info") then
            send_message(get_message(), player_name, bn_sender_id)
        end
    end
end

local function on_update_time(_, time)
    elapsed_time = time
end

local chatListener = CreateFrame("Frame")
chatListener:RegisterEvent("CHAT_MSG_WHISPER")
chatListener:RegisterEvent("CHAT_MSG_BN_WHISPER")
chatListener:SetScript("OnEvent", on_chat_event)

hooksecurefunc("Scenario_ChallengeMode_UpdateTime", on_update_time)