-- WezTerm config: 默认启动 WSL Debian（原 Ubuntu 已迁移至 Debian）
-- 注意：此版本（20240203）配置中没有 wezterm 全局量，必须 require，
-- 否则用到 wezterm.action 的条目会让整份配置静默失效。
local wezterm = require 'wezterm'

return {
  default_prog = { 'wsl', '-d', 'Debian' },

  -- 右键标签栏的 ➕ 按钮会弹出这个菜单
  launch_menu = {
    { label = 'WSL Debian',        args = { 'wsl', '-d', 'Debian' } },
    { label = 'PowerShell (pwsh)', args = { 'pwsh', '-NoLogo' } },
    { label = 'MSYS2 bash',        args = { 'C:/msys64/usr/bin/bash.exe', '-i', '-l' } },
  },

  -- 快捷键：Alt+P 新标签开 pwsh，Alt+M 新标签开 MSYS2，Alt+L 打开启动菜单
  keys = {
    { key = 'p', mods = 'ALT', action = wezterm.action.SpawnCommandInNewTab { args = { 'pwsh', '-NoLogo' } } },
    { key = 'm', mods = 'ALT', action = wezterm.action.SpawnCommandInNewTab { args = { 'C:/msys64/usr/bin/bash.exe', '-i', '-l' } } },
    { key = 'l', mods = 'ALT', action = wezterm.action.ShowLauncher },
  },
}
