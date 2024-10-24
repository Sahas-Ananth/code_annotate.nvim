local M = {}

--- Utility function that converts a multiline string (strings that have a "\n") to a string array. Used for setting a buffer.
--- @param lines string
--- @return string[]
function M.mstr2table(lines)
    --- @type string[]
    local str_tbl = {}
    for line in string.gmatch(lines .. '\\n', '(.-)\\n') do
        table.insert(str_tbl, line)
    end
    return str_tbl
end

return M
