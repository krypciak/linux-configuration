local function switch_to_last_viewed_tag()
    -- If reloading, restore last viewed tag
    local last_tag = os.capture("cat /tmp/awesomewm_last_tag")
    last_tag = string.sub(last_tag, 0, -2)

    if last_tag ~= "" then
        --noti("Switching to last selected tag", last_tag)
        get_tag(all_tags[last_tag]):view_only()
        awful.spawn("rm -f /tmp/awesomewm_last_tag")
    else
        awful.screen.focused().tags[1]:view_only()
    end
end

switch_to_last_viewed_tag()

sort_tags()

