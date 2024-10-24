local M = {}
local db = require 'code_annotate.database'
local utils = require 'code_annotate.utils'

-- TODO: Use this to check if a mark already exists
local curr_extmarks = {}
local monitored_bufs = {}

--- Creates a buffer and window for annotation. If nothing exists it creates one else it clears the old one and returns it.
--- @return integer
local function create_anno_buf()
    local bufr = vim.fn.bufnr 'Annotation'
    if bufr == -1 then
        bufr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_option_value('filetype', 'markdown', { buf = bufr })
        vim.api.nvim_buf_set_name(bufr, 'Annotation')
    else
        vim.api.nvim_set_option_value('modifiable', true, { buf = bufr })
        vim.api.nvim_buf_set_lines(bufr, 0, -1, true, {})
    end
    vim.api.nvim_buf_set_keymap(bufr, 'n', 'q', ':close<cr>', { noremap = true, silent = true, nowait = true })
    --- @type vim.api.keyset.win_config
    local win_opts = {
        anchor = 'NE',
        border = 'rounded',
        col = vim.api.nvim_win_get_width(0),
        height = M.config.height,
        relative = 'win',
        row = 5,
        title = 'Code Annotation',
        title_pos = 'center',
        width = M.config.width,
    }
    local win = vim.api.nvim_open_win(bufr, true, win_opts)
    local winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,FloatTitle:NormalFloat'
    vim.api.nvim_set_option_value('winhl', winhighlight, { win = win })
    return bufr
end

--- Checks if a buffer is empty or not.
--- @param bufnr integer
--- @return boolean
local function isBufEmpty(bufnr)
    local buf_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
    for _, line in ipairs(buf_lines) do
        if line ~= '' then
            return false
        end
    end
    return true
end

--- Creates an annotation in the current line.
function M.create_annotation()
    local bufnr = vim.api.nvim_get_current_buf()
    local file_name = vim.api.nvim_buf_get_name(bufnr)
    local cur_row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local cur_col = 0
    local mark_ns = vim.api.nvim_create_namespace 'annotate'
    local existing_marks = vim.api.nvim_buf_get_extmarks(bufnr, mark_ns, { cur_row, cur_col }, { cur_row, cur_col }, {})
    local update_note = false
    local anno_buf = create_anno_buf()
    if next(existing_marks) ~= nil then
        update_note = true
        local prev_text = db.get_anno(file_name, cur_row)
        local split_txt = utils.mstr2table(prev_text)
        vim.api.nvim_buf_set_lines(anno_buf, 0, -1, false, split_txt)
    end
    local anno_ag = vim.api.nvim_create_augroup('CodeAnnoEdit', { clear = true })
    vim.api.nvim_create_autocmd('BufHidden', {
        callback = function()
            if isBufEmpty(anno_buf) then
                vim.print 'Annotation is empty like your head! Write some shit to save it dummy.'
            else
                local anno_txt = vim.api.nvim_buf_get_lines(anno_buf, 0, -1, true)
                if update_note then
                    db.update_anno_text(file_name, cur_row, anno_txt)
                else
                    db.create_anno(file_name, cur_row, anno_txt)
                    vim.api.nvim_buf_set_extmark(bufnr, mark_ns, cur_row, cur_col, {
                        sign_text = M.config.annot_sign,
                        sign_hl_group = M.config.annot_sign_hl,
                    })
                    curr_extmarks[bufnr] = vim.api.nvim_buf_get_extmarks(bufnr, mark_ns, 0, -1, {})
                end
            end
        end,
        group = anno_ag,
        buffer = anno_buf,
        once = true,
    })
end

--- Deletes the annotation in the current line.
function M.delete_annotation()
    local bufnr = vim.api.nvim_get_current_buf()
    local file_name = vim.api.nvim_buf_get_name(bufnr)
    local cur_row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local cur_col = 0
    local mark_ns = vim.api.nvim_create_namespace 'annotate'
    local existing_marks = vim.api.nvim_buf_get_extmarks(bufnr, mark_ns, { cur_row, cur_col }, { cur_row, cur_col }, {})
    if next(existing_marks) == nil then
        vim.print 'There is no note in Ba Singe Se'
        return
    end
    if not M.config.auto_confirm_delete then
        local choice = vim.fn.confirm('*John Cena Voice* Are you sure about that??', '&1. No shit Sherlock!\n&2. No god please no! Nooooo!', 2, 'Question')
        if choice == 1 then
            vim.print 'I gotchu fam!'
        elseif choice == 2 then
            vim.print 'Aight imma head out. Idk why you called me tho Damn.'
            return
        else
            vim.print "BITCH! I said pick 1 or 2. Don't put random shit in input lmao!"
            return
        end
    end
    vim.api.nvim_buf_del_extmark(bufnr, mark_ns, existing_marks[1][1])
    db.delete_anno(file_name, cur_row)
    curr_extmarks[bufnr] = vim.api.nvim_buf_get_extmarks(bufnr, mark_ns, 0, -1, {})
end

--- Shows a Unmodifiable preview of the annotation in the current line.
function M.preview_annotation()
    local bufnr = vim.api.nvim_get_current_buf()
    local file_name = vim.api.nvim_buf_get_name(bufnr)
    local cur_row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local cur_col = 0
    local mark_ns = vim.api.nvim_create_namespace 'annotate'
    local existing_marks = vim.api.nvim_buf_get_extmarks(bufnr, mark_ns, { cur_row, cur_col }, { cur_row, cur_col }, {})
    if next(existing_marks) == nil then
        vim.print 'There is no note in Ba Singe Se'
        return
    end
    local anno_buf = create_anno_buf()
    local prev_text = db.get_anno(file_name, cur_row)
    local split_txt = utils.mstr2table(prev_text)
    vim.api.nvim_buf_set_lines(anno_buf, 0, -1, false, split_txt)
    vim.api.nvim_set_option_value('modifiable', false, { buf = anno_buf })
end

--[[ local list_anno_locs = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local mark_ns = vim.api.nvim_create_namespace 'annotate'
    local existing_marks = vim.api.nvim_buf_get_extmarks(bufnr, mark_ns, 0, -1, {})
    vim.print(existing_marks)
end ]]

--- Automatically monitor and update extended mark position.
--- @param cur_buf integer
local function auto_update_extmarks(cur_buf)
    for bufs, _ in pairs(monitored_bufs) do
        if cur_buf == bufs then
            return
        end
    end
    local mark_ns = vim.api.nvim_create_namespace 'annotate'
    monitored_bufs[cur_buf] = vim.api.nvim_buf_line_count(cur_buf)
    vim.api.nvim_buf_attach(cur_buf, false, {
        on_lines = function(_, bufnr, _, first_line, last_line)
            local file_name = vim.api.nvim_buf_get_name(bufnr)
            if curr_extmarks[bufnr] == nil then
                return
            end
            vim.schedule(function()
                local prev_line_count = monitored_bufs[bufnr]
                local curr_line_count = vim.api.nvim_buf_line_count(bufnr)
                -- To handle if you mass delete lines.
                for idx, mark in ipairs(curr_extmarks[bufnr]) do
                    if curr_line_count < prev_line_count and (mark[2] >= first_line and mark[2] <= last_line) then
                        vim.api.nvim_buf_del_extmark(bufnr, mark_ns, mark[1])
                        db.delete_anno(file_name, mark[2])
                        -- WARN: Maybe removal during the loop is a bad idea? add it to a list and remove it after maybe?
                        table.remove(curr_extmarks[bufnr], idx)
                    end
                end
                -- Handle for moving lines and coding and shit
                for idx, mark in ipairs(curr_extmarks[bufnr]) do
                    local mark_id = mark[1]
                    local prev_mark_ln = mark[2]
                    local cur_mark_ln = vim.api.nvim_buf_get_extmark_by_id(bufnr, mark_ns, mark_id, {})[1]
                    if prev_mark_ln ~= cur_mark_ln then
                        curr_extmarks[bufnr][idx] = vim.api.nvim_buf_get_extmarks(bufnr, mark_ns, mark_id, mark_id, {})[1]
                        db.update_anno_pose(file_name, prev_mark_ln, cur_mark_ln)
                    end
                end
            end)
        end,
    })
end

--- Set the annotation for the provided buffer.
--- @param buf integer
local function set_buf_annotation(buf)
    local mark_ns = vim.api.nvim_create_namespace 'annotate'
    local existing_marks = vim.api.nvim_buf_get_extmarks(buf, mark_ns, 0, -1, {})
    if next(existing_marks) ~= nil then
        return
    end
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local db_all_anno = db.get_all_anno(buf_name)
    if next(db_all_anno) == nil then
        return
    end
    for _, anno in pairs(db_all_anno) do
        vim.api.nvim_buf_set_extmark(buf, mark_ns, anno.row_num, anno.col_num, {
            sign_text = M.config.annot_sign,
            sign_hl_group = M.config.annot_sign_hl,
        })
    end
    curr_extmarks[buf] = vim.api.nvim_buf_get_extmarks(buf, mark_ns, 0, -1, {})
end

--- Loads all the annotations from the DB for all listed buffers.
local set_annotations = function()
    local bufnr = vim.api.nvim_get_current_buf()
    set_buf_annotation(bufnr)
    auto_update_extmarks(bufnr)
end

--- Creates User Commands put here so we can have localised behaviour.
local function create_usr_cmds()
    vim.api.nvim_create_user_command('NoteCreate', require('code_annotate').create_annotation, {})
    vim.api.nvim_create_user_command('NoteDelete', require('code_annotate').delete_annotation, {})
    vim.api.nvim_create_user_command('NoteView', require('code_annotate').preview_annotation, {})
    vim.api.nvim_create_user_command('NoteTelescope', 'Telescope code_annotate current', {})
    -- vim.api.nvim_create_user_command('NoteList', require('code_annotate').list_anno_locs, {})
end

--- @class code_annotate.setup.config_opts
--- @field annot_sign string
--- @field annot_sign_hl string
--- @field auto_confirm_delete boolean
--- @field db_path string
--- @field height integer
--- @field width integer

--- @type code_annotate.setup.config_opts
local default_opts = {
    annot_sign = '',
    annot_sign_hl = 'DiagnosticOk',
    auto_confirm_delete = false,
    db_path = vim.fn.stdpath 'data' .. '/code_annotate.db',
    height = 10,
    width = 35,
}

--- Sets up the plugin.
--- @param opts code_annotate.setup.config_opts
function M.setup(opts)
    M.config = vim.tbl_deep_extend('force', default_opts, opts or {})
    require 'sqlite.db' { uri = M.config.db_path, anno_tbl = db.anno_tbl, opts = {} }

    create_usr_cmds()

    local anno_set_ag = vim.api.nvim_create_augroup('CodeAnnoSetAnno', { clear = true })
    vim.api.nvim_create_autocmd('BufEnter', {
        group = anno_set_ag,
        pattern = '*',
        callback = function()
            set_annotations()
        end,
    })
end

function M.reset()
    require('plenary.reload').reload_module 'code_annotate'
    require('code_annotate').setup()
end

return M
