Add-Type -Path "WinSCPnet.dll"

# Pobranie aktualnej daty i obliczenie daty wczorajszej
$currentDate = Get-Date
$yesterdayDate = $currentDate.AddDays(-1)

# Lista ścieżek plików na dysku Z:
$zFilePaths = @(
    "Z:\{0:yyyy MMMM}\daily\Test1 test_{1:yyyyMMdd}.zip" -f $yesterdayDate, $yesterdayDate,
    "Z:\{0:yyyy MMMM}\daily\Test2 test_{1:yyyyMMdd}.zip" -f $yesterdayDate, $yesterdayDate,
    "Z:\{0:yyyy MMMM}\daily\Test3 test_{1:yyyyMMdd}.zip" -f $yesterdayDate, $yesterdayDate,
    "Z:\{0:yyyy MMMM}\daily\Test4 test_{1:yyyyMMdd}.zip" -f $yesterdayDate, $yesterdayDate
)

# Utworzenie dynamicznej ścieżki pliku na dysku V:
$vFilePath = "Y:\test\Test_{0:yyyyMMdd}*.zip" -f $yesterdayDate

$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Scp
    HostName = "test.dev.net"
    UserName = "test"
    Password = "1234"
}

$session = New-Object WinSCP.Session

try
{
    $session.Open($sessionOptions)

    # Ustawienie lokalnej ścieżki, gdzie zostaną zapisane pobrane pliki
    $localPath = "/test/folders/"

    # Sprawdzenie dostępności lokalizacji na dysku Z:
    if (Test-Path "Z:\") {
        foreach ($zFilePath in $zFilePaths) {
            # Sprawdzenie istnienia pliku na dysku Z:
            if (Test-Path $zFilePath) {
                # Pobranie pliku z dysku Z: i przesłanie do sesji WinSCP
                $session.GetFiles($zFilePath, $localPath).Check()
            }
            else {
                Write-Host ("Plik $zFilePath nie istnieje.") -ForegroundColor Red
            }
        }
    }
    else {
        Write-Host "Lokalizacja Z:\ nie jest dostępna." -ForegroundColor Red
    }

    # Sprawdzenie dostępności lokalizacji na dysku Y:
    if (Test-Path "Y:\") {
        # Pobranie pliku z dysku Y: po dacie i przesłanie do sesji WinSCP
        $vFiles = Get-ChildItem -Path $vFilePath | Where-Object { $_.LastWriteTime.Date -eq $yesterdayDate.Date }

        foreach ($vFile in $vFiles) {
            $session.GetFiles($vFile.FullName, $localPath).Check()
        }
    }
    else {
        Write-Host "Lokalizacja Y:\ nie jest dostępna." -ForegroundColor Red
    }
}
finally
{
    $session.Dispose()
}

-------------------------------------------------
$currentDate = Get-Date
$yesterdayDate = $currentDate.AddDays(-1)

$zFilePathTemplates = @(
    "Z:\{0:yyyy MMMM}\daily\Test1 test_{1:yyyyMMdd}.zip",
    "Z:\{0:yyyy MMMM}\daily\Test2 test_{1:yyyyMMdd}.zip",
    "Z:\{0:yyyy MMMM}\daily\Test3 test_{1:yyyyMMdd}.zip",
    "Z:\{0:yyyy MMMM}\daily\Test4 test_{1:yyyyMMdd}.zip"
)

$zFilePaths = foreach ($zTemplate in $zFilePathTemplates) {
    $zFilePath = $zTemplate -f $yesterdayDate, $yesterdayDate
    $zFilePath
}

foreach ($zFilePath in $zFilePaths) {
    Write-Host ("Plik $zFilePath") -ForegroundColor Red
}
