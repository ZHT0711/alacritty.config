# ============================================================================
#  Nushell 配置 (config.nu)
#  路径 : %APPDATA%\nushell\config.nu
#  组成 : $env.config 外观/行为 → zoxide → Oh My Posh → 别名/小工具
#  说明 : 逐项覆盖需要的键，保留 Nushell 默认值和其他插件设置
#  自检 : nu -c 'print $env.POSH_CONFIG'（应输出主题路径）
# ============================================================================

# --------------------------- 1. 外观与行为 ---------------------------------
$env.config.show_banner = false
$env.config.edit_mode = 'emacs'
$env.config.error_style = 'fancy'
$env.config.buffer_editor = 'nvim'
$env.config.cursor_shape = {
    emacs: 'block'
    vi_insert: 'line'
    vi_normal: 'block'
}
$env.config.table.mode = 'rounded'
$env.config.table.header_on_separator = false
$env.config.filesize.unit = 'metric'
$env.config.filesize.show_unit = true
$env.config.ls.use_ls_colors = true
$env.config.ls.clickable_links = true

# SQLite 历史支持更可靠的并发会话和结构化查询。
$env.config.history = {
    file_format: 'sqlite'
    max_size: 1_000_000
    sync_on_enter: true
    isolation: true
}

$env.config.completions.case_sensitive = false
$env.config.completions.quick = true
$env.config.completions.partial = true
$env.config.completions.algorithm = 'fuzzy'
$env.config.completions.persistent_menus = true
$env.config.completions.cache_size = 100

# 如果安装了 Carapace，为 git、winget、docker 等外部命令提供参数补全。
if (which carapace | is-not-empty) {
    $env.config.completions.external.completer = {|place|
        carapace $place.command.0 nushell ...$place.command | from json
    }
}

# ------------------------------- 2. zoxide ---------------------------------
# 说明：zoxide 官方生成的脚本用 export-env / export def 写成"模块"，
#       若放在 if 块里 source，定义会留在块作用域内（外面拿不到 z/zi），
#       所以这里按官方生成的内容内联到顶层。
# 需要重新生成参考实现时：zoxide init nushell
def --env --wrapped __zoxide_z [...rest: directory] {
    let path = match $rest {
        [] => {'~'},
        [ '-' ] => {'-'},
        [ $arg ] if ($arg | path expand | path type) == 'dir' => {$arg}
        _ => {
            ^zoxide query --exclude $env.PWD -- ...$rest | str trim -r -c "\n"
        }
    }
    cd $path
}

def --env --wrapped __zoxide_zi [...rest: string] {
    cd $'(^zoxide query --interactive -- ...$rest | str trim -r -c "\n")'
}

alias z = __zoxide_z
alias zi = __zoxide_zi

# 切换目录时把路径写进 zoxide 数据库（z 的候选就来自这里）
$env.config = (
    $env.config
    | upsert hooks.env_change.PWD (
        ($env.config.hooks?.env_change?.PWD? | default [])
        | append {
            __zoxide_hook: true
            code: {|_, dir| ^zoxide add -- $dir }
        }
    )
)

# ----------------------------- 3. Oh My Posh -------------------------------
# 官方用法：这一行会把提示符脚本写到 $nu.data-dir/vendor/autoload/，
# nushell 启动时会自动加载该目录，于是提示符交给 Oh My Posh（与 pwsh 同一套主题）
let omp_theme = ($env.POSH_THEME? | default ($env.USERPROFILE | path join '.config' 'oh-my-posh' 'dracula-dev.omp.json'))
oh-my-posh init nu --config $omp_theme

# ----------------------------- 4. 别名 / 小工具 ----------------------------
# eza：更好看的目录列表（不覆盖 nu 原生 ls，避免丢掉它的参数与行为）
def --wrapped ll [...args] { eza -lah --icons --group-directories-first --git ...$args }
def --wrapped la [...args] { eza -a --icons --group-directories-first ...$args }
def --wrapped l [...args] { eza --icons --group-directories-first ...$args }
def --wrapped lt [...args] { eza --tree --level=2 --icons ...$args }
def --wrapped tree [...args] { eza --tree --icons ...$args }

# 用 bat 高亮查看文件（保留 nu 原生 cat / open）
def --wrapped bb [...args] { bat --style=plain ...$args }
