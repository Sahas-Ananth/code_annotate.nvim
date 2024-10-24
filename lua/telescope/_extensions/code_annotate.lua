local has_telescope, telescope = pcall(require, 'telescope')

if not has_telescope then
    error 'This plugin requires nvim-telescope/telescope.nvim'
end

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local previewers = require 'telescope.previewers'
local previewers_util = require 'telescope.previewers.utils'

local db = require 'code_annotate.database'
local utils = require 'code_annotate.utils'

--- Creates a Finder
--- @param entry code_annotate.database.annotation_db_entry
local function annotation_entry_maker(entry)
    local res = {}
    res.value = entry
    -- TODO: Maybe figure out a better way for this rather than disabling diagnostics, we can make get_all_annos return split strings.
    res.value.split_lines = utils.mstr2table(entry.text) ---@diagnostic disable-line
    res.display = 'Id: ' .. entry.id .. ' || Row: ' .. entry.row_num .. ' || Headline: ' .. res.value.split_lines[1]
    res.ordinal = tostring(entry.id)
    res.lnum = entry.row_num + 1
    res.col = entry.col_num
    res.filename = entry.file_path
    return res
end

local function annotation_previewer(self, entry, _)
    previewers_util.highlighter(self.state.bufnr, 'markdown')
    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, entry.value.split_lines)
end

-- our picker function: colors
local function code_annotate(opts)
    opts = opts or {}
    pickers
        .new(opts, {
            prompt_title = string.format('Annotations in %s', vim.fn.expand '%:t'),
            finder = finders.new_table {
                results = db.get_all_anno(vim.api.nvim_buf_get_name(0)),
                entry_maker = annotation_entry_maker,
            },
            sorter = conf.generic_sorter(opts),
            previewer = previewers.new_buffer_previewer {
                title = 'Annotation Preview',
                define_preview = annotation_previewer,
            },
            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col })
                end)
                return true
            end,
        })
        :find()
end

return telescope.register_extension {
    exports = {
        ['code_annotate'] = code_annotate,
        current = code_annotate,
    },
}
