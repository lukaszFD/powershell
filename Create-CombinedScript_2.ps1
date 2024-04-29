function Create-CombinedScript {
    param (
        [string]$mainDirectory
    )

    function AddScriptsToCombinedScript($directory, $objectType, $combinedScriptContent, [ref]$changelogList) {
        $orderExecuted = 1
        Get-ChildItem $directory -Filter *.sql | ForEach-Object {
            $scriptName = $_.Name
            $tbl = $scriptName -replace ".sql$", ""
            $dropStatement = "DROP $objectType TEST.$tbl;"

            Write-Host "Reading file: $scriptName"

            $scriptContent = Get-Content $_.FullName -Raw

            # Add entry to changelog list
            $changelogList.Value += [PSCustomObject]@{
                OBJECT_NAME = $tbl
                FILE_NAME = $scriptName
                ORDER_EXCUTED = $orderExecuted
            }

            [void]$combinedScriptContent.Append("`r`n$dropStatement`r`n/`r`n")
            $scriptContent = $scriptContent -replace "`n", "`r`n  " 
            [void]$combinedScriptContent.Append("`r`n$scriptContent`r`n /`r`nGRANT SELECT ON $tbl TO PIMINV;`r`nGRANT INSERT ON $tbl TO PIMINV;`r`nGRANT UPDATE ON $tbl TO PIMINV;`r`nGRANT DELETE ON $tbl TO PIMINV;`r`n/")

            $orderExecuted++
        }
    }

    function Add_Dml($directory, $objectType, $combinedScriptContent) {
        Get-ChildItem $directory -Filter *.sql | ForEach-Object {
            $scriptName = $_.Name

            Write-Host "Reading file: $scriptName"

            $scriptContent = Get-Content $_.FullName -Raw
            $scriptContent += "`r`ncommit;"

            [void]$combinedScriptContent.Append("`r`n$scriptContent/`r`n")
        }
    }

    function Add_Ddl($directory, $objectType, $combinedScriptContent) {
        Get-ChildItem $directory -Filter *.sql | ForEach-Object {
            $scriptName = $_.Name

            Write-Host "Reading file: $scriptName"

            $scriptContent = Get-Content $_.FullName -Raw
            
            [void]$combinedScriptContent.Append("`r`n$scriptContent/`r`n")
        }
    }

    function Add_Pkg($directory, $objectType, $combinedScriptContent) {
        Get-ChildItem $directory -Filter *.sql | ForEach-Object {
            $scriptName = $_.Name

            Write-Host "Reading file: $scriptName"

            $scriptContent = Get-Content $_.FullName -Raw
            
            [void]$combinedScriptContent.Append("`r`n$scriptContent/`r`n")
        }
    }

    $combinedScriptPath = Join-Path $mainDirectory "CombinedScript.sql"
    $combinedScriptContent = New-Object System.Text.StringBuilder
    $changelogList = @()

    AddScriptsToCombinedScript (Join-Path $mainDirectory "TABLE") "TABLE" $combinedScriptContent ([ref]$changelogList)
    AddScriptsToCombinedScript (Join-Path $mainDirectory "VIEWS") "VIEW" $combinedScriptContent ([ref]$changelogList)
    Add_Dml (Join-Path $mainDirectory "DML") "DML" $combinedScriptContent
    Add_Ddl (Join-Path $mainDirectory "DDL") "DDL" $combinedScriptContent
    Add_Pkg (Join-Path $mainDirectory "PACKAGE") "PACKAGE" $combinedScriptContent

    $combinedScriptContent.Append("BEGIN`r`nEXEC DBMS_UTILITY.compile_schema(schema => '', compile_all => false);`r`nEND;`r`n/`r`n")

    # Dodanie INSERT do tabeli DATABASE_CHANGELOG na koniec skryptu
    $combinedScriptContent.Append("`r`n")

    foreach ($entry in $changelogList) {
        $insertQuery = "INSERT INTO PIMSNAPS.DATABASE_CHANGELOG (OBJECT_NAME, FILE_NAME, ORDER_EXCUTED) VALUES ('$($entry.OBJECT_NAME)', '$($entry.FILE_NAME)', $($entry.ORDER_EXCUTED));"
        $combinedScriptContent.Append("$insertQuery`r`n")
    }

    $combinedScriptContent.Append("`r`nCOMMIT;`r`n")

    $combinedScriptContent.ToString() | Out-File -FilePath $combinedScriptPath -Encoding UTF8 -Force
    Write-Host "Combined script has been created: $combinedScriptPath"
}

Create-CombinedScript -mainDirectory "C:\Users\"
