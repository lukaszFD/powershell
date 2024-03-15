function Export-OracleObjectDefinitions {
    param (
        [string]$dataSource,
        [string]$userId,
        [string]$password,
        [string]$outputDirectory
    )

    $oracleConnection = New-Object System.Data.OracleClient.OracleConnection
    $oracleConnection.ConnectionString = "Data Source=$dataSource;User Id=$userId;Password=$password;"

    try {
        $oracleConnection.Open()

        $oracleCommand = $oracleConnection.CreateCommand()
        $oracleCommand.CommandText = "SELECT name, OBJECT, SQL_SCRIPT FROM DB_OBJECTS WHERE OBJECT IN ('table', 'view', 'mview')"
        
        $oracleDataReader = $oracleCommand.ExecuteReader()

        while ($oracleDataReader.Read()) {
            $objectName = $oracleDataReader.GetValue(0)
            $objectType = $oracleDataReader.GetValue(1)
            $objectDefinitionLob = $oracleDataReader.GetOracleLob(2)

            # Określ podkatalog w zależności od rodzaju obiektu
            switch ($objectType) {
                'table' {
                    $subDirectory = 'table'
                    break
                }
                'view' {
                    $subDirectory = 'views'
                    $header = "CREATE VIEW $objectName AS"
                    break
                }
                'mview' {
                    $subDirectory = 'mviews'
                    $header = "CREATE MATERIALIZED VIEW $objectName AS"
                    break
                }
                default {
                    $subDirectory = 'unknown'
                    break
                }
            }

            $filePath = Join-Path $outputDirectory "$subDirectory\$objectName.sql"

            $objectDefinition = $objectDefinitionLob.Value

            # Dodaj nagłówek przed definicją obiektu (jeśli jest wymagany)
            if ($header) {
                $objectDefinition = "$header`r`n$objectDefinition"
            }

            [System.IO.File]::WriteAllText($filePath, $objectDefinition, [System.Text.Encoding]::UTF8)

            Write-Host "Zapisano definicję obiektu $objectType $objectName do $filePath"
        }
    }
    finally {
        $oracleConnection.Close()
    }
}

# Przykład użycia procedury
Export-OracleObjectDefinitions -dataSource "Your_Oracle_DB" -userId "Your_Username" -password "Your_Password" -outputDirectory "C:\Sciezka\Do\Twojego\Katalogu"
