function Select-Dialog {
    param (
        [Parameter(mandatory, ValueFromPipeline = $true)]
        [string[]]
        $Items
    )

    # 要素が一つの場合、そのまま返す
    if ($Items.Count -eq 1) {
        return $Items[0]
    }

    # 何列目を選択中か
    $SelectRowNum = 0

    # 検索文字列初期化
    $InputString = ''

    # 表示用メニュー取得
    $Menu = $Items

    while ($true) {
        # ターミナルをクリア
        Clear-Host

        # 検索文字列描画
        Write-Host -Object ('QUERY> ') -NoNewline
        Write-Host -Object $InputString -ForegroundColor 'White'
        $Counter = 0

        # メニューを表示
        $Menu.ForEach({
                if ($Counter -eq $SelectRowNum) {
                    $MenuParameter = @{
                        'BackgroundColor' = 'White'
                        'ForegroundColor' = 'Black'
                    }
                }
                else {
                    $MenuParameter = @{
                        'ForegroundColor' = 'White'
                    }
                }

                Write-Host -Object $_ @MenuParameter
                $Counter++
            })

        # 表示用パラメータの初期化
        Clear-Variable -Name 'MenuParameter' -Force

        # キーボード入力を取得
        $Key = [Console]::ReadKey($true)

        # Backspaceが押されたら検索文字列を一つ削る
        if (($Key.Key -eq 'Backspace') -and ($InputString.Length -gt 0)) {
            $InputString = $InputString.Substring(0, $InputString.Length - 1)
            $Menu = $Items.Where({ $_ -match $InputString })
            #$SelectRowNum = 0
        }
        # 検索文字を取得
        elseif (($Key.KeyChar -notmatch "^\s") -and ($Key.Key -notmatch "Arrow$")) {
            $InputString = $InputString + $Key.KeyChar
            $Menu = $Items.Where({ $_ -match $InputString })
            #$SelectRowNum = 0
        }
        # Enterが押されたらループを抜ける
        elseif ($Key.Key -eq 'Enter') {
            break
        }
        # 方向キーに応じてメニューカーソル位置を移動
        elseif (($Key.Key -eq 'UpArrow') -and ($SelectRowNum -gt 0)) {
            --$SelectRowNum
        }
        elseif (($Key.Key -eq "DownArrow") -and ($SelectRowNum -lt ($Menu.Count - 1))) {
            ++$SelectRowNum
        }
        elseif (($Key.Key -match "Arrow$") -and ($SelectRowNum -ge $Menu.Count)) {
            $SelectRowNum = ($Menu.Count - 1)
        }
    }

    # 結果を出力
    $Host.UI.RawUI.CursorPosition.Y++
    $Host.UI.RawUI.CursorPosition.Y++
    Write-Output -InputObject $Menu[$SelectRowNum]
}

Set-Alias -Name 'peco' -Value Select-Dialog

Export-ModuleMember -Function * -Alias *
