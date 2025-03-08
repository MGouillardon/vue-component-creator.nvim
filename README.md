# Vue Component Creator for Neovim

A Neovim plugin to simplify Vue component creation and extraction. This plugin allows you to:

- Create new Vue components with predefined templates
- Extract selected code to a new component file
- Keep organized component structure in your project
- Automatically detect TypeScript projects and use appropriate templates

## Features

- 🚀 Quick component creation with predefined templates
- ✂️ Cut and paste code into a new component
- 🧹 Automatic code indentation and formatting
- 📁 Automatic directory creation
- 🔌 Customizable templates and configuration
- 🔍 TypeScript detection and integration

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  'MGouillardon/vue-component-creator.nvim',
  ft = { "vue", "javascript", "typescript", "javascriptreact", "typescriptreact" }, -- Filetypes to load the plugin for
  cmd = { "VueComponent", "VueTemplate", "VueTypescriptComponent" },
  config = function()
    require("vue-component-creator").setup({
      components_dir = "src/components/", -- Customize for your project
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'MGouillardon/vue-component-creator.nvim',
  config = function()
    require('vue-component-creator').setup()
  end
}
```

## Usage

The plugin provides three main commands:

### 1. Create an empty component

```vim
:VueComponent components/buttons/PrimaryButton
```

This creates a new file at `components/buttons/PrimaryButton.vue` with the default template.

### 2. Create a TypeScript component

```vim
:VueTypescriptComponent components/buttons/PrimaryButton
```

This creates a new file with TypeScript support (`lang="ts"` attribute in the script tag).

### 3. Extract selected code to a new component

1. Select code in visual mode
2. Run `:VueComponent components/cards/InfoCard`
3. The selected code will be cut from the current file and placed in the new component

### Template-only components

To create or extract a component with only a `<template>` section:

```vim
:VueTemplate components/icons/CloseIcon
```

## TypeScript Support

The plugin can automatically detect TypeScript projects and use TypeScript templates when appropriate:

- If a `tsconfig.json` file is found in your project root
- When the `:VueTypescriptComponent` command is used explicitly
- You can force TypeScript mode through configuration

## Configuration

You can customize the plugin by passing a configuration table to the setup function:

```lua
require('vue-component-creator').setup({
  -- Base directory for components (relative to project root)
  components_dir = "src/components/",

  -- Space size for indentation
  indent_size = 2,

  -- Whether to automatically format pasted code
  auto_format = true,

  -- TypeScript configuration
  force_typescript = false,       -- Always use TypeScript templates
  auto_detect_typescript = true,  -- Automatically detect TypeScript projects

  -- Custom templates
  templates = {
    -- Default template with script and template
    default = [[<script setup>

</script>

<template>
%s
</template>]],

    -- Template-only components
    template_only = [[<template>
%s
</template>]],

    -- TypeScript template
    typescript = [[<script setup lang="ts">

</script>

<template>
%s
</template>

<style scoped>
</style>]]
  }
})
```
