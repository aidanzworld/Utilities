local Services = {
    HTTP = game:GetService("HttpService")
}

-----------------------------------------------------------------------
-- Script API Declarations
-----------------------------------------------------------------------
local isfile = isfile
local readfile = readfile
local writefile = writefile

local module = {}

local RSPNChannels = {
    ["RoSportProgrammingNetwork"] = "730050166",
    ["RSPN_2"] = "846285089",
    ["RSPN3"] = "846285510",
    ["RSPN4"] = "875247498",
    ["RSPN_5"] = "875247935",
    ["RSPNDeportes"] = "875248189"
}

function module:GetRSPNChannels()
    return RSPNChannels
end

function module:GetChannelID(channel)
    return RSPNChannels[channel]
end

function module:FormatClock(seconds : number)
    local minutes = (seconds - seconds%60)/60
    seconds = seconds-minutes*60
    local zero = ""
    if (seconds < 10) then
        zero = "0"
    end

    return minutes .. ":" .. zero .. seconds
end

function module:FormatNumber(number : number)
    if (number == 1) then
        return "1st"
    elseif (number == 2) then
        return "2nd"
    elseif (number == 3) then
        return "3rd"
    elseif (number == 4) then
        return "4th"
    elseif (number >= 5) then
        return "OT " .. number-4
    end
end

local DefaultConfig = {
    GameInfo = {
        Away = "AWAY_TEAM_HERE",
        AwayRank = 0,
        Home = "HOME_TEAM_HERE",
        HomeRank = 0,
        Primetime = "false",
        Series = "SERIES_HERE",
        Season = "SEASON_HERE",
        League = "LEAGUE_HERE"
    },
    Settings = {
        AssetsFilePath = "",
        AutoTwitchClipping = "false",
        AutoTwitchUpdates = "false",
        Channel = "",
        SendToWebhook = "false",
        TwitchAuthCode = "",
        UploadStatsToDatabase = "false",
        UploadToRealtimeAPI = "false"
    }
}

function ReadConfigArray(default, compare)
    local returnTable = {}

    for i,v in pairs(compare) do
        if (default[i] and type(default[i]) == type(v)) then
            if (type(v) == "table") then
                returnTable[i] = ReadConfigArray(default[i], v)
            else
                returnTable[i] = v
            end
        elseif (default[i]) then
            returnTable[i] = default[i]
        end
    end

    for i,v in pairs(default) do
        if not (returnTable[i]) then
            returnTable[i] = v
        end
    end

    return returnTable
end

function module:GetConfig()
    local succ, result = pcall(function()
        return readfile("config.json")
    end)

    local config = DefaultConfig  -- Default config if reading fails
    
    if succ then
        succ, result = pcall(function()
            return Services.HTTP:JSONDecode(result)
        end)
        
        if succ then
            config = ReadConfigArray(DefaultConfig, result)
            print("[Utilities] Successfully got the config file.")
        else
            print("[Utilities] Failed to decode the config file JSON.")
        end
    else
        print("[Utilities] Failed to read the config file.")
    end

    writefile("config.json", Services.HTTP:JSONEncode(config)) -- Update config file with either default or read values
    return config
end

return module
