local TESTING = config.testing

if TESTING then
    local function draw_text(text, x, y)
        SetTextFont(4)
        SetTextProportional(0)
        SetTextScale(0.35, 0.35)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(1, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(false)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(x, y)
    end

    CreateThread(function()
        while true do
            Wait(1000)
            local statuses = get_data('statuses')
            local flags = get_data('flags')
            if statuses or flags then
                while statuses or flags do
                    Wait(0)
                    statuses = get_data('statuses')
                    flags = get_data('flags')
                    local x = 0.010
                    local y = 0.5
                    local y_flags = 0.2
                    local line_height = 0.025
                    if statuses then
                        for status, value in pairs(statuses) do
                            draw_text(string.format("%s: %s", status, value), x, y)
                            y = y + line_height
                        end
                    end
                    if flags then
                        for flag, value in pairs(flags) do
                            draw_text(string.format("%s: %s", flag, value and "Yes" or "No"), x, y_flags)
                            y_flags = y_flags + line_height
                        end
                    end
                end
            end
        end
    end)

    local function print_data()
        local statuses = get_data('statuses')
        local flags = get_data('flags')
        if statuses then
            for k, v in pairs(statuses) do
                print(k .. ': ' .. v)
            end
        else
            print("identity data not found.")
        end

        if flags then
            for k, v in pairs(flags) do
                print(k .. ': ' .. tostring(v))
            end
        else
            print("identity data not found.")
        end
    end

    RegisterCommand('test:print_data', function()
        print_data()
    end)

end