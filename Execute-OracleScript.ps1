function Execute-OracleScript {
    param (
        [string]$dataSource,
        [string]$userId,
        [string]$password,
        [string]$scriptPath
    )

    $oracleConnection = New-Object System.Data.OracleClient.OracleConnection
    $oracleConnection.ConnectionString = "Data Source=$dataSource;User Id=$userId;Password=$password;"

    try {
        $oracleConnection.Open()

        $scriptContent = Get-Content $scriptPath -Raw

        $oracleCommand = $oracleConnection.CreateCommand()
        $oracleCommand.CommandText = $scriptContent

        $oracleCommand.ExecuteNonQuery()

        Write-Host "Skrypt uruchomiony pomyślnie."
    }
    finally {
        $oracleConnection.Close()
    }
}

# Przykład użycia procedury
Execute-OracleScript -dataSource "Twoja_Baza_Oracle" -userId "Twoj_Username" -password "Twoje_Haslo" -scriptPath "C:\Sciezka\Do\Twojego\Katalogu\CombinedScript.sql"
