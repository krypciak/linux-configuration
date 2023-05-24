local player_cache_file = "/tmp/playerctl-players"

local main_player
local secondary_player


local file = io.open(player_cache_file, "r")
if file then
    local i = 0
    for line in file:lines() do
        i = i + 1
        if i == 1 then main_player = line 
        elseif i == 2 then secondary_player = line
        else break end
    end

    if main_player == "nil" then mail_player = nil end
    if secondary_player == "nil" then secondary_player = nil end
end

local action
local playernumber

if arg then
    action = arg[1]
    playernumber = tonumber(arg[2])
else
    action = ext_action
    playernumber = ext_playernumber
end

function os.capture(cmd)
    local handle = assert(io.popen(cmd, "r"))
    local output = assert(handle:read("*a"))
    handle:close()
    return output
end

function split_by_line_ending(str)
    local t = {}
    local function helper(line)
        table.insert(t, line)
        return ""
    end
    helper((str:gsub("(.-)\r?\n", helper)))
    return t
end

function list_contains(list, key) 
    for i = 1, #list do
        if list[i] == key then return true end
    end
    return false
end

local function playerctl_action(action, playernumber)
    local output = os.capture("playerctl --list-all")
    output = string.sub(output, 0, -2)
    local split = split_by_line_ending(output)
    
    if #split == 0 then return end
    if #split == 1 then
        main_player = split[1]
        secondary_player = nil
    else
        if not list_contains(split, main_player) then
            main_player = secondary_player
            secondary_player = nil
            if not list_contains(split, main_player) then
                main_player = split[1]
                secondary_player = split[2]
            end
        end
        assert(main_player ~= nil)
        if not list_contains(split, secondary_player) then
            if split[2] == main_player then
                secondary_player = split[1]
            else
                secondary_player = split[2]
            end
        end
    end
    assert(main_player ~= secondary_player)
   
    if action == "swap" then
        if main_player and secondary_player then
            local t1 = main_player 
            main_player = secondary_player
            secondary_player = t1
        elseif secondary_player then 
            main_player = secondary_player
            secondary_player = nil
        end

        return
    end

    local player
    if playernumber == 1 then player = main_player
    elseif playernumber == 2 then player = secondary_player
    end
    if player then
        local cmd = "playerctl --player=" .. player .. " " .. action
        if awful then
            awful.spawn(cmd)
        else
            os.execute(cmd)
        end
    end
end

playerctl_action(action, playernumber)

file = io.open(player_cache_file, "w")
file:write(main_player .. '\n' .. tostring(secondary_player))
file:close()
