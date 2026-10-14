# ============================================================================
#  Nushell 环境配置 (env.nu)
#  路径 : %APPDATA%\nushell\env.nu
#  只放环境变量；外观、提示符、别名都放在 config.nu
#  顺序 : nushell 先执行 env.nu，再执行 config.nu
# ============================================================================

# ------------------------------- 编辑器 ------------------------------------
$env.EDITOR = 'nvim'
$env.VISUAL = 'nvim'

# -------------------------------- bat --------------------------------------
$env.BAT_THEME = 'Dracula'

# ------------------------------- 分页器 ------------------------------------
# scoop 版 nushell 自带 less.exe，用作默认分页器
if (($env.USERPROFILE | path join 'scoop' 'apps' 'nu' 'current' 'less.exe') | path exists) {
    $env.PAGER = 'less'
}

# ------------------------------- 提示符 ------------------------------------
# Oh My Posh 主题路径（config.nu 里生成 autoload 脚本时会用到）
$env.POSH_THEME = 'C:\Users\skowosy\.config\oh-my-posh\dracula-dev.omp.json'
