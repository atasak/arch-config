function Dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k2,v in pairs(o) do
            local k = k2
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. Dump(v) .. ','
        end
        return s .. '} '
    elseif type(o) == 'userdata' then
        return 'UD: ' .. Dump(getmetatable(o))
    else
        return tostring(o)
    end
end

function MergeDeep(objects, reuse)
    local result = reuse or {}
    for _, obj in ipairs(objects) do
        for k,v in pairs(obj) do
            if v == nil then
                result[k] = nil
            elseif type(v) == 'table' then
                if result[k] == nil then result[k] = {} end
                result[k] = MergeDeep({v}, result[k])
            else
                result[k] = v
            end
        end
    end
    return result
end