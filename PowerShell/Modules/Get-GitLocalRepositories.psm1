function Get-GitLocalRepositories {
    param(
        [string]
        $Path = "$HOME\ghq"
    )

    # $Pathが実在しない場合、エラー終了
    if (-not (Test-Path -Path $Path)) {
        Write-Error -Message 'Path does not exist.'
        return
    }

    # Select-Dialogモジュールが読み込めてない場合、エラー終了
    if (Get-Module -Name 'Select-Dialog' > $null) {
        Write-Error -Message 'Module "Select-Dialog" does not exist.'
        return
    }

    # リポジトリ一覧を取得
    $Repositories = (Get-ChildItem -Path $Path -Recurse -Hidden -filter '.git').Parent.FullName

    # 0件の場合、終了
    if ($Repositories.Count -eq 0) {
        Write-Warning -Message 'No repositories found.'
        return
    }

    # リポジトリ一覧をpecoもどきに渡し、選択したパスに移動する
    Select-Dialog -Items $Repositories | Set-Location
}

Set-Alias -Name 'g' -Value 'Get-GitLocalRepositories' -Description 'Get Git Local Repositories'

Export-ModuleMember -Function * -Alias *
