#!/usr/bin/env pwsh

# 変数
New-Variable -Name 'ProfileRoot' -Value $(Split-Path -Path $PROFILE.CurrentUserAllHosts) -Scope 'Script'
New-Variable -Name 'InitialRoot' -Value $(Join-Path -Path $PSScriptRoot -ChildPath '.config/powershell') -Scope 'Script'
New-Variable -Name 'PathDelimiter' -Value $(if ( $env:PSModulePath -match ';' ) { ';' } else { ':' }) -Scope 'Script'

# Profile用ディレクトリ作成

@(
  @{ ItemType = 'Directory'; Path = $ProfileRoot; Force = $true }
).ForEach({
  ## 配布先が既に存在する場合、次のエントリへ進む
  if ( Test-Path -Path $_.Path -ErrorAction 'SilentlyContinue') {
    Write-Host ($_.Path + " is existed.")
    return
  }

  ## アイテムを作成
  New-Item @_
})

# シンボリックリンク作成

@(
  @{ ItemType = 'SymbolicLink'; Path = $env:PSModulePath.Split($PathDelimiter)[0]; Value = (Join-Path $InitialRoot 'Modules') },
  @{ ItemType = 'SymbolicLink'; Path = $PROFILE.CurrentUserAllHosts; Value = (Join-Path $InitialRoot 'profile.ps1') },
  @{ ItemType = 'SymbolicLink'; Path = $PROFILE; Value = (Join-Path $InitialRoot (Split-Path -Leaf $PROFILE)) }
).ForEach({
  ## 配布先が既に存在する場合、次のエントリへ進む
  if ( Test-Path $_.Path -ErrorAction 'SilentlyContinue') {
    Write-Host ($_.Path + " is existed.")
    return
  }

  ## 配布元が存在しない場合、次のエントリへ進む(ISE用)
  if ( ! (Test-Path $_.Value -ErrorAction 'SilentlyContinue') ) {
    Write-Host ($_.Value + " is not existed.")
    return
  }

  ## アイテムを作成
  New-Item @_
})

# ------------------------------------------------------------------------------
# Windows用
# ------------------------------------------------------------------------------

if ( $IsWindows -eq $False ) {
  [void]$(exit $true)
}

# エクスプローラーの3Dオブジェクト削除

ri 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}' -ErrorAction SilentlyContinue

# CapsLock -> LeftCtrl

[byte[]]$RegValue = @()
('00','00','00','00','00','00','00','00','02','00','00','00','1d','00','3a','00','00','00','00','00') | % { $RegValue += [Byte]('0x' + $_) }
sp -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout' -Name 'Scancode Map' -Value $RegValue

# PackageProvider追加

@(
  @{ Name = 'Chocolatey'; Force = $true }
).ForEach({
  if ( ! (Get-PackageProvider @_ -ErrorAction SilentlyContinue) ) { 
    Install-PackageProvider @_
  }
})

# アプリ追加

(Get-Content -Path ($PSScriptRoot + '/pkg/windows.json') | ConvertFrom-Json).ForEach({
  if ( ! (Get-Package @_ -ErrorAction SilentlyContinue) ) {
    Install-Package @_
  }
})
