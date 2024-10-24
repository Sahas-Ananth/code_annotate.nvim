local M = {}
local tbl = require 'sqlite.tbl'

--- @class code_annotate.database.annotation_db_entry
--- @field id integer
--- @field file_path string
--- @field row_num integer
--- @field col_num integer
--- @field text string

--- @type sqlite_tbl
M.anno_tbl = tbl('anno_tbl', {
    id = true,
    file_path = { 'text', required = true },
    row_num = { 'number', required = true },
    col_num = { 'number', default = 0 },
    text = { 'text', required = true },
})

--- Creates an annotation entry into the database.
--- @param file_name string
--- @param line_no integer
--- @param anno_text (string?)[]
function M.create_anno(file_name, line_no, anno_text)
    -- Store the text with a \n at the end.
    local anot = table.concat(anno_text, '\\n')
    M.anno_tbl:insert {
        file_path = file_name,
        row_num = line_no,
        text = anot,
    }
end

--- Returns the annotation text at the given file and line number.
--- @param file_name string
--- @param line_no integer
--- @return string
function M.get_anno(file_name, line_no)
    local anno_txt = M.anno_tbl:get {
        select = { 'text' },
        where = { file_path = file_name, row_num = line_no },
    }
    if #anno_txt > 0 then
        return anno_txt[1].text
    end
    return ''
end
--- Returns all annotations in the given file.
--- @param file_name string
--- @return (code_annotate.database.annotation_db_entry)[]
function M.get_all_anno(file_name)
    local annos = M.anno_tbl:get {
        select = { '*' },
        where = { file_path = file_name },
    }
    return annos
end

--- Updates the annotation text at a given line for a given file.
--- @param file_name string
--- @param line_no integer
--- @param anno_text (string?)[]
function M.update_anno_text(file_name, line_no, anno_text)
    local annot = table.concat(anno_text, '\\n')
    M.anno_tbl:update {
        set = { text = annot },
        where = { file_path = file_name, row_num = line_no },
    }
end

--- Updates the position of the annotation to new position given old line number and file.
---	@param file_name string
---	@param old_line_no integer
---	@param new_line_no integer
function M.update_anno_pose(file_name, old_line_no, new_line_no)
    M.anno_tbl:update {
        set = { row_num = new_line_no },
        where = { file_path = file_name, row_num = old_line_no },
    }
end

--- Updates the file name of the annotation to new file name given line number and old file name.
--- @param old_file_name string
--- @param line_no integer
--- @param new_file_name string
function M.update_anno_file(old_file_name, line_no, new_file_name)
    M.anno_tbl:update {
        set = { file_path = new_file_name },
        where = { file_path = old_file_name, row_num = line_no },
    }
end

--- Deletes an annotation given a file and line number.
--- @param file_name string
--- @param line_no integer
function M.delete_anno(file_name, line_no)
    M.anno_tbl:remove {
        file_path = file_name,
        -- TODO: Maybe fix this ignore diagnostic bit.
        row_num = line_no, ---@diagnostic disable-line: assign-type-mismatch
    }
end

return M
