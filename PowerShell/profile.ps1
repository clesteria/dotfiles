# OS判定

[String]$OS = if ( $IsMacOS ) {
  'macOS'
}
elseif ( $IsLinux ) {
  'Linux'
}
else {
  'Windows'
}

# ScriptBlock変数設定

## プロンプトの表示切替
function Switch-Prompt {
  if ( $Global:DisplayDate ) {
    Remove-Variable -Name DisplayDate -Scope Global
  }
  else {
    [ScriptBlock]$Global:DisplayDate = { (Get-Date).ToString('yyyy/MM/dd HH:mm:ss') }
  }
}

## 管理者権限確認
if ( $IsWindows ) {
  [ScriptBlock]$Global:IsAdmin = { [Security.Principal.WindowsIdentity]::GetCurrent().Owner -eq 'S-1-5-32-544' }
}
else {
  [ScriptBlock]$Global:IsAdmin = { (whoami) -match 'root' }
}

## プロンプト表示内容
[ScriptBlock]$Global:Prompt = {
  if ( $Global:DisplayDate ) {
    Write-Host ('{0}[{1}]' -f "`n", (& $Global:DisplayDate)) -ForegroundColor Yellow -NoNewline
    Write-Host ' <PowerShell>' -ForegroundColor Green -NoNewline
    Write-Host (' {0} ' -f $Pwd.ProviderPath.Replace($HOME, '~')) -ForegroundColor Cyan
  }

  if ( & $IsAdmin ) {
    '# '
  }
  else {
    '> '
  }
}

# 変数設定

[String[]]$Global:ProgramFiles = ($env:ProgramFiles, ${env:ProgramFiles(x86)})
[String]$Global:ProfileRoot = Split-Path $PROFILE
[String]$Global:WorkplaceProfile = Join-Path $ProfileRoot 'WorkplaceProfile.ps1'
[String]$Global:GitPath = '~/Git'
[String]$Global:PathDelimiter = if ( $env:PSModulePath -match ';' ) { ';' } else { ':' }

## クリップボード格納コマンド統一
if ( $IsMacOS ) {
  Set-Alias -Name 'scb' -Value 'pbcopy' -Option AllScope -Scope Global
}
elseif ( $IsLinux ) {
  Set-Alias -Name 'scb' -Value 'xsel -bi' -Option AllScope -Scope Global
}

# PATH初期値設定

if ( $IsMacOS ) {
  if ( (Split-Path -Leaf $env:SHELL) -eq 'pwsh' ) {
    ## PowerShellのディレクトリを先頭にする
    $env:PATH = $env:PATH.Split($PathDelimiter)[0]
    ## bash用PATH初期値設定コマンドから初期値を末尾に追加
    $env:PATH = ($env:PATH, (((/usr/libexec/path_helper) -split '"')[1] -replace $env:PATH)) -join $PathDelimiter
    ## 両端のパス区切り文字を除外
    $env:PATH = $env:PATH.Trim($PathDelimiter)
  }
}

# PATH追加

& {
  $ErrorActionPreference = 'SilentlyContinue'
  @(
    (Split-Path $PROFILE), # Profile
    ($ProgramFiles | Get-ChildItem -Directory | Where-Object -Property Name -match 'vim' | Get-ChildItem | Where-Object -Property Name -match '^vim').DirectoryName, # vim
    ('C:\Windows\Microsoft.NET\Framework64' | Get-ChildItem -Directory | Get-ChildItem | Where-Object -Property Name -eq 'csc.exe' | Sort-Object VersionInfo)[-1].DirectoryName # .NET Framework
  ).ForEach.({
    if ( $env:PATH.Split($PathDelimiter) -notcontains $_ ) {
      $env:PATH += ($PathDelimiter + $_)
    }
  })
}

# LOCAL MACHINEとCURRENT USER以外のレジストリをマウント

if ( $IsWindows ) {
  (
    @{ Name = 'HKCR'; PSProvider = 'Registry'; Root = 'HKEY_CLASSES_ROOT' },
    @{ Name = 'HKU'; PSProvider = 'Registry'; Root = 'HKEY_USERS' },
    @{ Name = 'HKCC'; PSProvider = 'Registry'; Root = 'HKEY_CURRENT_CONFIG' }
  ).ForEach({
    ## レジストリの場合はスキップ
    if ( $_.PSProvider -eq 'Registry' ) {
      return
    }

    ## なければ追加
    if ( ! (Test-Path ('{0}:' -f $_.Name)) ) {
      [void](New-PSDrive @_)
    }
  })
}

# プロンプト設定

## ScriptBlock型の変数の内容をプロンプトとする
function prompt { & $Prompt }

## プロンプトを詳細表示に切り替える
Switch-Prompt

# 環境別プロファイルを読み込み(場所により異なる設定が必要な場合に使用)

if ( Test-Path -Path $WorkplaceProfile -ErrorAction 'SilentlyContinue' ) {
  . $WorkplaceProfile
}
