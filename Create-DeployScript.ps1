function Create-CombinedScript {
    param (
        [string]$mainDirectory
    )

    function AddScriptsToCombinedScript($directory, $objectType, $combinedScriptContent) {
        Get-ChildItem $directory -Filter *.sql | ForEach-Object {
            $scriptName = $_.Name
            $tbl = $scriptName -replace ".sql$", ""
            $dropStatement = "DROP $objectType TEST.$tbl;"

            Write-Host "Reading file: $scriptName"

            $scriptContent = Get-Content $_.FullName -Raw
            
            [void]$combinedScriptContent.Append("`r`n$dropStatement`r`n/`r`n")
            $scriptContent = $scriptContent -replace "`n", "`r`n  " 
            [void]$combinedScriptContent.Append("`r`n$scriptContent`r`n /`r`nGRANT SELECT ON $tbl TO PIMINV;`r`nGRANT INSERT ON $tbl TO PIMINV;`r`nGRANT UPDATE ON $tbl TO PIMINV;`r`nGRANT DELETE ON $tbl TO PIMINV;`r`n/")
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

    AddScriptsToCombinedScript (Join-Path $mainDirectory "TABLE") "TABLE" $combinedScriptContent
    AddScriptsToCombinedScript (Join-Path $mainDirectory "VIEWS") "VIEW" $combinedScriptContent
    Add_Dml (Join-Path $mainDirectory "DML") "DML" $combinedScriptContent
    Add_Ddl (Join-Path $mainDirectory "DDL") "DDL" $combinedScriptContent
    Add_Pkg (Join-Path $mainDirectory "PACKAGE") "PACKAGE" $combinedScriptContent

    $combinedScriptContent.Append("BEGIN`r`nEXEC DBMS_UTILITY.compile_schema(schema => '', compile_all => false);`r`nEND;`r`n/`r`n")
    
    $combinedScriptContent.ToString() | Out-File -FilePath $combinedScriptPath -Encoding UTF8 -Force
    Write-Host "Combined script has been created: $combinedScriptPath"
}

Create-CombinedScript -mainDirectory "C:\Users\"
