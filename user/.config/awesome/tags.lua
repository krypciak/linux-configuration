all_tags = {}

local tag_order = {}

local tag_order_counter = 1
function add_tag(properties)
    properties.c_index = tag_order_counter
    tag_order_counter = tag_order_counter + 1

    local name = properties.c_name
    properties.name = ' ' .. name .. ' '
    all_tags[name] = properties

    table.insert(tag_order, name)
end


function get_all_clients()
	return awful.screen.focused().all_clients
end

function get_running_clients(clients, classes, names)
    local client_list = {}

    for i=1, #clients do
        local client = clients[i]
        
        if classes ~= nil then
            for _, class in ipairs(classes) do
                if client.class ~= nil and string.match(client.class, class) then
                    table.insert(client_list, client)
                goto continue
                end
            end
        end
        if names ~= nil then
            for _, name in ipairs(names) do 
                if client.class ~= nil and string.match(client.name, name) then 
                    table.insert(client_list, client)
                goto continue
                end
                end
            end
        ::continue::
    end
    --noti("clients:", tostring(#client_list))
    return client_list
end

function run_if_not_running_clients(to_run, clients, classes, names)
    if #get_running_clients(clients, classes, names) == 0 then
	for _, app in ipairs(to_run) do 
		awful.spawn(app[1], app[2]) 
	end
    end
end

require("tags_init")

function get_tag(root_tag, action)
    local screen = awful.screen.focused()
    -- Get the the tag
    local tag = awful.tag.find_by_name(screen, root_tag.name)
    -- If it doesn't exist (and redirect is nil), create it
    if tag == nil and root_tag.c_redirect == nil then
        awful.tag.add(root_tag.name, root_tag)
        tag = awful.tag.find_by_name(screen, root_tag.name)
        assert(tag ~= nil)
        -- Sort tags when tag list changes; function is at tags.lua
        sort_tags()
    end

    -- If/ redirect if set
    local redirect = root_tag.c_redirect
    if redirect ~= nil then
        -- Find the tag to be redirected to
        tag = awful.tag.find_by_name(screen, redirect)
        -- If it doesn't exist, create it
        if tag == nil then
            awful.tag.add(redirect, all_tags[redirect])
            tag = awful.tag.find_by_name(screen, redirect)
            -- Sort tags when tag list changes; function is at tags.lua
            sort_tags()
        end
        assert(tag ~= nil)
    end
    -- If its view tag or toggle tag, execute the custom action (if set)
    if action and root_tag.c_switchaction ~= nil then
        root_tag.c_switchaction(tag)
    end
    assert(tag ~= nil)
    return tag
end

local function delete_unused_tags()
    local tags = awful.screen.focused().tags
    for _, tag in ipairs(tags) do
	if not tag.c_defactivated then
	    local clients = tag:clients()
	    if not clients or #tag:clients() == 0 then tag:delete() end
	end
    end
end


function sort_tags()
    for s in screen do
        local tags_table = {}
        for i, tag in ipairs(s.tags) do
            tags_table[tag.name] = tag
        end

        local index = 1
        for _, name in ipairs(tag_order) do
            local tag = tags_table[name]
            if tag then
                --noti(name, tostring(index))
                tag.index = index
                index = index + 1
            end
        end
    end
end
local function get_view_tag_key(mod_keys, key, root_tag, desc)
    return awful.key(mod_keys, key, function()
	    delete_unused_tags()
        local tag = get_tag(root_tag, true)
        tag:view_only()
        sort_tags()
    end, {description = desc, group = "tag"})
end

local function get_viewtoggle_tag_key(mod_keys, key, root_tag, desc)
    return awful.key(mod_keys, key, function()
        local tag = get_tag(root_tag, true)
        awful.tag.viewtoggle(tag)
    end, {description = desc, group = "tag"})
end

local function get_moveclient_key(mod_keys, key, root_tag, desc)
    return awful.key(mod_keys, key, function()
        if client.focus then
            client.focus:move_to_tag(get_tag(root_tag, false))
        end
    end, {description = desc, group = "tag"})
end

local function get_toggleclient_key(mod_keys, key, root_tag, desc)
    return awful.key(mod_keys, key, function()
        if client.focus then
            client.focus:toggle_tag(get_tag(root_tag, false))
        end
    end, {description = desc, group = "tag"})
end

for _, name in ipairs(tag_order) do
    local tag = all_tags[name]
    local key = tag.c_key

    if tag.c_defactivated then awful.tag.add(name, tag) end

    globalkeys = gears.table.join(globalkeys,
	    get_view_tag_key({alt}, key, tag, "view tag " .. tag.name),
	    get_viewtoggle_tag_key({alt, ctrl}, key, tag, "toggle tag " .. tag.name),
	    get_moveclient_key({alt, shift}, key, tag, 
	    	"move focused client to tag " .. tag.name),
        get_toggleclient_key({alt, ctrl, shift}, key, tag,
            "toggle focused client on tag " .. tag.name))
end

function sort_clients()
    noti("Sorting clients", tostring(#awful.screen.focused().all_clients))

    for _, tag in pairs(all_tags) do
        if tag.c_apps ~= nil then
            local clients = get_running_clients(get_all_clients(), tag.c_apps["class"], tag.c_apps["name"])
            if #clients ~= 0 then
                local tag1 = get_tag(tag, false)
                for _, client in ipairs(clients) do
                    client:move_to_tag(tag1)
                end
            end
        end
    end
end

