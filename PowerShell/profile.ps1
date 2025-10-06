# 変数

if ( $IsWindows ) {
  [String[]]$Local:ProgramFiles = ($env:ProgramFiles, ${env:ProgramFiles(x86)})
}
else {
  [String]$env:COMPUTERNAME = $(uname -n | sed -e "s/\.local$//")
}
[String]$Local:ProfileRoot = Split-Path $PROFILE
[String]$Local:WorkplaceProfile = Join-Path $ProfileRoot 'WorkplaceProfile.ps1'
[String]$Local:PathDelimiter = if ( $env:PSModulePath -match ';' ) { ';' } else { ':' }

# ScriptBlock変数

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
    Write-Host (' {0}@{1}' -f $env:USER, $env:COMPUTERNAME) -ForegroundColor Magenta -NoNewline
    Write-Host ' <PowerShell>' -ForegroundColor Blue -NoNewline
    Write-Host (' {0} ' -f $Pwd.ProviderPath.Replace($HOME, '~')) -ForegroundColor Cyan
  }

  if ( & $IsAdmin ) {
    '# '
  }
  else {
    '> '
  }
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

## 追加用スクリプトブロック(使い終わったら消す)
[ScriptBlock]$Local:AddPath = {
  param(
    [String]$Path
  ) 

  if ( $env:PATH.Split($Global:PathDelimiter) -notcontains $Path ) {
    $env:PATH += ($Global:PathDelimiter + $Path)
  }
}

## Profile
& $Local:AddPath -Path $(Split-Path -Path $PROFILE.CurrentUserAllHosts)

## スクリプトブロック削除
Remove-Variable -Name 'AddPath' -Scope 'Local'

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
