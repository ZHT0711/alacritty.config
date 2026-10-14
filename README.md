# Terminal configuration backup

Configuration files currently in use on this Windows PC. The repository keeps the Alacritty files at the root for compatibility with its original layout.

| Software | Repository file | Local location |
| --- | --- | --- |
| Alacritty | `alacritty.toml`, `themes/dracula.toml` | `%APPDATA%\alacritty\` |
| WezTerm | `wezterm/.wezterm.lua` | `%USERPROFILE%\.wezterm.lua` |
| Windows Terminal (packaged) | `windows-terminal/packaged-settings.json` | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` |
| Windows Terminal (unpackaged) | `windows-terminal/unpackaged-settings.json` | `%LOCALAPPDATA%\Microsoft\Windows Terminal\settings.json` |
| Nushell | `nushell/config.nu`, `nushell/env.nu` | `%APPDATA%\nushell\` |
| PowerShell 7 | `powershell/Microsoft.PowerShell_profile.ps1` | `D:\Document\PowerShell\Microsoft.PowerShell_profile.ps1` |
| Windows PowerShell | `powershell/WindowsPowerShell_profile.ps1` | `D:\Document\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` |
| Git Bash | `git-bash/.bashrc` | `%USERPROFILE%\.bashrc` |
| Oh My Posh | `oh-my-posh/dracula-dev.omp.json` | `%USERPROFILE%\.config\oh-my-posh\dracula-dev.omp.json` |
| WSL | `wsl/.wslconfig` | `%USERPROFILE%\.wslconfig` |

These are snapshots of manually maintained configuration. History, caches, plugins, and generated startup scripts are excluded. Some files contain paths specific to this PC (including the Windows username and `D:` drive), so update those paths when restoring elsewhere.

## Included conveniences

- Consistent Dracula colors and Ioskeley Nerd Font across Alacritty, WezTerm, and Windows Terminal.
- URL hints in Alacritty and WezTerm.
- WezTerm WSL-domain tabs, pane splitting, pane navigation, and Git Bash launcher.
- PowerShell, Nushell, and Git Bash integrations for Oh My Posh, zoxide, eza, bat, and fzf where installed.
- Nushell SQLite history, fuzzy completion, and optional Carapace completion.

The packaged Windows Terminal settings are the active Microsoft Store/MSIX configuration on this machine. The unpackaged file is retained as a snapshot for portable installations.
