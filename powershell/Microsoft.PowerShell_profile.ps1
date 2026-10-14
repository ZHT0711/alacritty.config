# ============================================================================
#  PowerShell 7 配置文件 (Microsoft.PowerShell_profile.ps1)
#  位置 : D:\Document\PowerShell\Microsoft.PowerShell_profile.ps1
#  备份 : C:\Users\skowosy\.config-backup\20261014-094745\Microsoft.PowerShell_profile.ps1.bak
#  组成 : 编码 → 增强模块 → PSReadLine → fzf 快捷键 → Oh My Posh → zoxide → 别名
#  说明 : 每段都先判断工具是否存在，缺工具或报错都不会拖垮 shell；
#         想临时绕过本配置，就用 `pwsh -NoProfile` 启动。
# ============================================================================

# ------------------------------- 1. 编码 -----------------------------------
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$OutputEncoding = [Text.Encoding]::UTF8

# --------------------------- 2. 增强模块 -----------------------------------
# 补全预测器：给 PSReadLine 的插件预测提供命令级建议（实测约 0.3s，值得）
Import-Module CompletionPredictor -ErrorAction SilentlyContinue
# 启动速度取舍（冷启动实测）：
#   CompletionPredictor ≈ 0.3s → 保留
#   PSFzf               ≈ 0.5s → 改为首次按键时按需加载，见第 4 节
#   Terminal-Icons      ≈ 0.8s → 去掉：它只给 ls/Get-ChildItem 加图标，
#                                 而 ll/la/lt/tree 已用 eza 提供更好的图标列表。
#                                 想让 gci 也带图标就取消下面这行注释（代价 +0.8s）。
# Import-Module Terminal-Icons -ErrorAction SilentlyContinue

# --------------------------- 3. PSReadLine ---------------------------------
# 注意：这些"选项"必须在加载 Oh My Posh 之前设置好，omp 启动时会读取当前状态
if (Get-Module -ListAvailable PSReadLine) {
    Set-PSReadLineOption -EditMode Windows
    try {
        # 需要终端支持 VT（Alacritty / Windows Terminal / WezTerm 都支持）
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView
    }
    catch {
        # 输出被重定向或不支持虚拟终端时无法开启预测，跳过即可
        Write-Verbose "无法开启 PSReadLine 预测建议：$_"
    }
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
    Set-PSReadLineOption -MaximumHistoryCount 20000
    Set-PSReadLineOption -BellStyle None

    # 语法高亮配色对齐 Dracula
    try {
        Set-PSReadLineOption -Colors @{
            Default                = '#f8f8f2'
            Command                = '#8be9fd'
            Parameter              = '#ffb86c'
            Operator               = '#ff79c6'
            Variable               = '#f8f8f2'
            String                 = '#f1fa8c'
            Number                 = '#bd93f9'
            Type                   = '#50fa7b'
            Comment                = '#6272a4'
            Keyword                = '#ff79c6'
            Member                 = '#8be9fd'
            Error                  = '#ff5555'
            Selection              = '#44475a'
            InlinePrediction       = '#6272a4'
            ListPrediction         = '#bd93f9'
            ListPredictionSelected = '#44475a'
        }
    }
    catch { Write-Verbose "部分 PSReadLine 配色键不被支持：$_" }

    # 历史记录里不保存明显含口令/密钥的命令
    Set-PSReadLineOption -AddToHistoryHandler {
        param($line)
        $line -notmatch '(?i)(password|passwd|secret|token|api[_-]?key|ask-pass)'
    }

    # 方向键：按已输入的前缀搜索历史
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    # Tab：菜单式补全（列表 + 方向键选择）
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    # Ctrl+d：行内有内容就删字符，空行才退出
    Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit
    # Ctrl+w 删前一个单词；Ctrl+z / Ctrl+y 撤销 / 重做
    Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Key Ctrl+z -Function Undo
    Set-PSReadLineKeyHandler -Key Ctrl+y -Function Redo
    # F2：在"列表预测"和"内联预测"两种视图之间切换
    Set-PSReadLineKeyHandler -Key F2 -Function SwitchPredictionView
}

# --------------------------- 4. fzf (PSFzf) --------------------------------
# 按需加载 PSFzf：模块本身解析要 ~0.5s，而它的能力只在按快捷键时才需要
function __LoadPsFzf {
    if (-not (Get-Module PSFzf)) {
        Import-Module PSFzf -ErrorAction SilentlyContinue
    }
    if (Get-Module PSFzf) {
        # 绑定一次即可，之后 Ctrl+r / Ctrl+t / Alt+c 由 PSFzf 自己的处理器接管
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' `
                        -PSReadlineChordReverseHistory 'Ctrl+r' `
                        -PSReadlineChordSetLocation 'Alt+c' -ErrorAction SilentlyContinue
    }
}

if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Module -ListAvailable PSFzf)) {
    Set-PSReadLineKeyHandler -Key Ctrl+r -BriefDescription 'FzfHistory' -ScriptBlock {
        __LoadPsFzf
        if (Get-Command Invoke-FzfPsReadlineHandlerHistory -ErrorAction SilentlyContinue) {
            Invoke-FzfPsReadlineHandlerHistory
        }
        else {
            [Microsoft.PowerShell.PSConsoleReadLine]::ReverseSearchHistory()
        }
    }
    Set-PSReadLineKeyHandler -Key Ctrl+t -BriefDescription 'FzfProvider' -ScriptBlock {
        __LoadPsFzf
        if (Get-Command Invoke-FzfPsReadlineHandlerProvider -ErrorAction SilentlyContinue) {
            Invoke-FzfPsReadlineHandlerProvider
        }
    }
    Set-PSReadLineKeyHandler -Key Alt+c -BriefDescription 'FzfSetLocation' -ScriptBlock {
        __LoadPsFzf
        if (Get-Command Invoke-FzfPsReadlineHandlerSetLocation -ErrorAction SilentlyContinue) {
            Invoke-FzfPsReadlineHandlerSetLocation
        }
    }
}
elseif (Get-Module -ListAvailable PSReadLine) {
    # 没有 fzf 时退回 PSReadLine 自带的历史反向搜索
    Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
}

# --------------------------- 5. Oh My Posh ---------------------------------
$OmpTheme = Join-Path $HOME '.config\oh-my-posh\dracula-dev.omp.json'
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    try {
        if (Test-Path $OmpTheme) {
            oh-my-posh init pwsh --config $OmpTheme | Invoke-Expression
        }
        else {
            oh-my-posh init pwsh | Invoke-Expression
        }
    }
    catch {
        Write-Warning "Oh My Posh 初始化失败，已退回默认提示符：$($_.Exception.Message)"
    }
}

# --------------------------- 6. zoxide -------------------------------------
# 必须放在 Oh My Posh 之后：zoxide 会包装"当前"的 prompt 函数来记录访问过的目录
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# --------------------------- 7. 别名 / 小工具 ------------------------------
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'
if (Get-Command bat -ErrorAction SilentlyContinue) {
    $env:BAT_THEME = 'Dracula'
}

# eza：更好看的目录列表（刻意不覆盖 ls，避免丢掉 Get-ChildItem 的 -Force/-Recurse 等参数；
#      真想让 ls 也走 eza，可自行加：Set-Alias ls eza）
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ll { eza -lah --icons --group-directories-first --git @args }
    function la { eza -a --icons --group-directories-first @args }
    function l { eza --icons --group-directories-first @args }
    function lt { eza --tree --level=2 --icons @args }
    function lg { eza -lah --icons --group-directories-first --git-ignore @args }
}

function which { Get-Command @args }

function touch {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Path)
    foreach ($p in $Path) {
        if (Test-Path $p) { (Get-Item $p).LastWriteTime = Get-Date }
        else { New-Item -ItemType File -Path $p -Force | Out-Null }
    }
}

function mkcd {
    param([Parameter(Mandatory = $true)][string]$Path)
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
    Set-Location -Path $Path
}

function .. { Set-Location .. }
function ... { Set-Location ../.. }
function reload { . $PROFILE }

# 从 git.exe 自动推导 Git 安装目录，避免绑定盘符和安装位置。
function gb {
    $GitCommand = Get-Command git.exe -ErrorAction SilentlyContinue
    if (-not $GitCommand) {
        Write-Error '未找到 Git for Windows。'
        return
    }

    $GitRoot = Split-Path (Split-Path $GitCommand.Source -Parent) -Parent
    $GitBash = Join-Path $GitRoot 'bin\bash.exe'
    if (-not (Test-Path -LiteralPath $GitBash)) {
        Write-Error "未找到 Git Bash：$GitBash"
        return
    }

    & $GitBash --login -i
}
