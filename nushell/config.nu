# ============================================================================
#  Nushell 配置 (config.nu)
#  路径 : %APPDATA%\nushell\config.nu
#  组成 : $env.config 外观/行为 → zoxide → Oh My Posh → 别名/小工具
#  说明 : $env.config 只写要覆盖的键，其余自动沿用 nushell 默认值（深合并）
#  自检 : nu -c 'print $env.POSH_CONFIG'（应输出主题路径）
# ============================================================================

# --------------------------- 1. 外观与行为 ---------------------------------
$env.config = {
    show_banner: false # 关掉启动横幅（想看就改成 true）
    edit_mode: emacs
    error_style: fancy
    buffer_editor: 'nvim' # ctrl+o 用 nvim 打开当前命令行
    cursor_shape: {
        emacs: block
        vi_insert: line
        vi_normal: block
    }
    table: {
        mode: rounded
        header_on_separator: false
    }
    filesize: {
        unit: metric
        show_unit: true
    }
    ls: {
        use_ls_colors: true
        clickable_links: false
    }
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: prefix
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
let omp_theme = ($env.POSH_THEME? | default 'C:\Users\skowosy\.config\oh-my-posh\dracula-dev.omp.json')
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
