# code_annotate.nvim for Neovim

https://github.com/user-attachments/assets/b1666786-a807-4c35-abd1-fc15b8c3d47e

## Table of Contents

1. [Introduction](#introduction)
    - [Features](#features)
2. [Installation](#installation)
    - [Requirements](#requirements)
    - [Setup](#setup)
    - [Configuration](#configuration)
3. [Usage](#usage)
    - [Create Annotation](#create-annotation)
    - [Delete Annotation](#delete-annotation)
    - [Preview Annotation](#preview-annotation)
    - [Telescope Integration](#telescope-integration)
    - [Key Mappings](#key-mappings)
4. [Credits](#credits)
    - [Inspiration](#inspiration)
    - [Special Thanks](#special-thanks)
    - [Links](#links)

---

## 1. Introduction

`code_annotate.nvim` allows you to write rich-formatted notes using Markdown without cluttering your code with comments. It uses Neovim's extmarks and an SQLite database to track your notes. This keeps your code clean and organized while still providing a way to document thoughts, ideas, or reminders exactly where they belong.

### 1.1. Features

- **Markdown support**: Write rich-formatted notes using Markdown for enhanced readability and structure.
- **Permanent storage**: Stores notes using an SQLite database, ensuring they persist between sessions.
- **Telescope support**: Native integration with [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim), allowing quick preview of all annotations in the current buffer and the ability to jump to them.

---

## 2. Installation

### 2.1. Requirements

Required:

- [sqlite.lua](https://github.com/kkharji/sqlite.lua)

Optional yet highly recommended:

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

### 2.2. Setup

**Lazy.nvim:**

```lua
{
  "Sahas-Ananth/code_annotate.nvim",
  -- To set all the previous annotations when entering a buffer.
  lazy = false,
  dependencies = { 
    "kkharji/sqlite.lua",
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim"
  },
  opts = {
    -- Your configuration comes here or leave it empty to use the default
    -- settings, refer to the configuration section below
  }
}
```

### 2.3. Configuration

These are the following defaults:

```lua
{
  -- Sign Icon used for the sign column.
  annot_sign = '',
  -- Highlight Group for setting sign color.
  annot_sign_hl = 'DiagnosticOk',
  -- Do not ask for confirmation before deleting a note.
  auto_confirm_delete = false,
  -- Path to the database file. It is created if it does not exist.
  db_path = vim.fn.stdpath('data') .. '/code_annotate.db',
  -- Height of the floating annotation window.
  height = 10,
  -- Width of the floating annotation window.
  width = 35,
}
```

---

## 3. Usage

### 3.1. Create Annotation

Use this Vim command to create or edit an annotation:

```vim
:NoteCreate
```

Or in Lua:

```lua
require("code_annotate").create_annotation()
```

If you want to close the preview window, you can do so by pressing `q` or `:close`. If a note is empty (filled with only whitespace characters), it is not saved; otherwise, it is saved automatically.

### 3.2. Delete Annotation

Use this Vim command to delete the annotation on the current line:

```vim
:NoteDelete
```

Or in Lua:

```lua
require("code_annotate").delete_annotation()
```

If you have set `auto_confirm_delete` to `true` in the configuration, it will not ask for confirmation when deleting a note. Otherwise, you'll need to confirm by pressing `1` to confirm or `2` (default) to cancel the deletion.

### 3.3. Preview Annotation

Use this Vim command to preview the annotation on the current line:

```vim
:NoteView
```

Or in Lua:

```lua
require("code_annotate").preview_annotation()
```

To close the preview window, press `q` or use `:close`. The preview window is non-editable; to modify a note, use the `:NoteCreate` command.

### 3.4. Telescope Integration

Use this command to view all annotations in the current buffer and jump to the selected one:

```vim
:NoteTelescope
```

This is equivalent to running:

```vim
:Telescope code_annotate current
```

### 3.5. Key Mappings

The plugin does not come with any key mappings by default. However, if you're using `lazy.nvim`, you can set them up like this:

```lua
keys = {
    { '<leader>nc', '<cmd>NoteCreate<cr>', desc = '[n]ote [c]reate' },
    { '<leader>nd', '<cmd>NoteDelete<cr>', desc = '[n]ote [d]elete' },
    { '<leader>nv', '<cmd>NoteView<cr>', desc = '[n]ote [v]iew' },
    { '<leader>sn', '<cmd>NoteTelescope<cr>', desc = '[s]earch [n]ote' },
}
```

Alternatively, create key mappings manually:

```lua
vim.keymap.set('n', '<leader>nc', '<cmd>NoteCreate<cr>', { desc = '[n]ote [c]reate' })
vim.keymap.set('n', '<leader>nd', '<cmd>NoteDelete<cr>', { desc = '[n]ote [d]elete' })
vim.keymap.set('n', '<leader>nv', '<cmd>NoteView<cr>', { desc = '[n]ote [v]iew' })
vim.keymap.set('n', '<leader>sn', '<cmd>NoteTelescope<cr>', { desc = '[s]earch [n]ote' })
```

---

## 4. Credits

### 4.1. Inspiration

I had been searching for a plugin like this for a while. In one of Primeagen’s VoDs, he built something similar just because he wanted to. Watching that, I thought, “If he can do it, so can I!” and decided to create this plugin. It’s my first plugin, so I’m open to feedback and suggestions for improvement.

Halfway through the project, I discovered Andrew's (winter-again) plugin, which inspired me to incorporate some of his approaches. Since I was already deep into development, I wanted to see my version through to completion, adding a few extra features that I thought were missing from his project.

### 4.2. Special Thanks

A huge thanks to TJ Devries for the fantastic plugin development videos. I used them extensively as a reference for this project, especially the ones on creating a Neovim plugin. Also, thanks for always reminding us to “RTFM”—that advice has been invaluable. Special thanks as well for creating `kickstart.nvim`, which I used to set up my Neovim configuration. And of course, thank you for maintaining such an amazing code editor.

Thank you to Primeagen for introducing me to Neovim a year ago (2023) and, jokingly, for influencing my personality! When I started using Neovim, I never imagined I’d end up creating my own plugin, let alone learning so much about my editor.

Finally, thanks to Folke. While working on this project, I studied your plugin code and borrowed a few feature ideas, such as jumping to notes (coming soon™).

### 4.3. Links

Here are some links for the people mentioned in the credits:

- [Annotation Project (winter-again)](https://github.com/winter-again/annotate.nvim)
- [winter-again](https://github.com/winter-again)
- [TJ Devries](https://github.com/tjdevries)
- [Primeagen](https://github.com/theprimeagen)
- [Folke](https://github.com/folke)

