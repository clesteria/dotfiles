#!/usr/bin/env pwsh

# 変数
New-Variable -Name 'ProfileRoot' -Value $(Split-Path -Path $PROFILE.CurrentUserAllHosts) -Scope 'Script'
New-Variable -Name 'InitialRoot' -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'PowerShell') -Scope 'Script'
New-Variable -Name 'PathDelimiter' -Value $(if ( $env:PSModulePath -match ';' ) { ';' } else { ':' }) -Scope 'Script'

# Profile用ディレクトリ作成

(
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

(
  @{ ItemType = 'SymbolicLink'; Path = $env:PSModulePath.Split($PathDelimiter)[0]; Value = (Join-Path $InitialRoot 'Modules') },
  @{ ItemType = 'SymbolicLink'; Path = $PROFILE.CurrentUserAllHosts; Value = (Join-Path $InitialRoot 'profile.ps1') },
  @{ ItemType = 'SymbolicLink'; Path = $PROFILE; Value = (Join-Path $InitialRoot (Split-Path -Leaf $PROFILE)) },
  @{ ItemType = 'SymbolicLink'; Path = '~\.fontlist'; Value = (Join-Path $PSScriptRoot '.fontlist') }
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
