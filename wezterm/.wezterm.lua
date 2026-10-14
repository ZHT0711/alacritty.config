local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- 直接进入 Debian WSL domain。新标签和分屏会继承当前 WSL 工作目录。
config.default_domain = 'WSL:Debian'

-- 与 Alacritty / Windows Terminal 共用一套字体和 Dracula 配色。
config.font = wezterm.font('IoskeleyMonoTerm Nerd Font Mono')
config.font_size = 13.0
config.window_background_opacity = 0.96
config.window_padding = { left = 10, right = 10, top = 8, bottom = 8 }
config.colors = {
  foreground = '#f8f8f2',
  background = '#282a36',
  cursor_bg = '#f8f8f2',
  cursor_fg = '#282a36',
  selection_bg = '#44475a',
  selection_fg = '#f8f8f2',
  ansi = { '#21222c', '#ff5555', '#50fa7b', '#f1fa8c', '#bd93f9', '#ff79c6', '#8be9fd', '#f8f8f2' },
  brights = { '#6272a4', '#ff6e6e', '#69ff94', '#ffffa5', '#d6acff', '#ff92df', '#a4ffff', '#ffffff' },
}

config.launch_menu = {
  { label = 'WSL Debian',        domain = { DomainName = 'WSL:Debian' } },
  { label = 'PowerShell (pwsh)', args = { 'pwsh', '-NoLogo' } },
  { label = 'Git Bash',          args = { 'D:/Program Files/Git/bin/bash.exe', '--login', '-i' } },
  { label = 'MSYS2 bash',        args = { 'C:/msys64/usr/bin/bash.exe', '-i', '-l' } },
}

config.keys = {
  { key = 'p', mods = 'ALT', action = act.SpawnCommandInNewTab { args = { 'pwsh', '-NoLogo' } } },
  { key = 'g', mods = 'ALT', action = act.SpawnCommandInNewTab { args = { 'D:/Program Files/Git/bin/bash.exe', '--login', '-i' } } },
  { key = 'm', mods = 'ALT', action = act.SpawnCommandInNewTab { args = { 'C:/msys64/usr/bin/bash.exe', '-i', '-l' } } },
  { key = 'l', mods = 'ALT', action = act.ShowLauncher },

  -- Alt+\\ 左右分屏，Alt+- 上下分屏；新窗格沿用当前 domain。
  { key = '\\', mods = 'ALT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'ALT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'LeftArrow',  mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = 'ALT', action = act.ActivatePaneDirection 'Down' },

  -- 从屏幕中选择完整 URL 并用默认浏览器打开。
  {
    key = 'u',
    mods = 'CTRL|SHIFT',
    action = act.QuickSelectArgs {
      label = 'open URL',
      patterns = { 'https?://\\S+' },
      action = wezterm.action_callback(function(window, pane)
        wezterm.open_with(window:get_selection_text_for_pane(pane))
      end),
    },
  },
}

return config
