function resolve_time(seconds)
    local min = math.floor(seconds / 60)
    local sec = seconds - (min * 60)

    return min, sec
end

function format_time(seconds)
    local min, sec = resolve_time(seconds)

    if min < 10 then
        min = "0" .. min
    end

    if sec < 10 then
        sec = "0" .. sec
    end

    return min .. ":" .. sec
end