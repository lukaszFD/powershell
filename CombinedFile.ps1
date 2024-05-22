# Poproś użytkownika o podanie ścieżki do folderu
$folderPath = Read-Host "Podaj ścieżkę do folderu"

# Sprawdź czy folder istnieje
if (-Not (Test-Path -Path $folderPath -PathType Container)) {
    Write-Host "Podany folder nie istnieje. Skrypt zakończony."
    exit
}

# Ścieżka do pliku wynikowego
$outputFile = Join-Path -Path $folderPath -ChildPath "zbiorczy.txt"

# Wyczyść zawartość pliku wynikowego, jeśli już istnieje
Clear-Content -Path $outputFile -ErrorAction SilentlyContinue

# Przejdź przez wszystkie pliki w folderze
Get-ChildItem -Path $folderPath | ForEach-Object {
    $filePath = $_.FullName
    Write-Host "Przetwarzanie pliku: $filePath"

    # Odczytaj zawartość pliku
    $fileContent = Get-Content -Path $filePath -Raw

    # Dodaj zawartość pliku do pliku wynikowego
    Add-Content -Path $outputFile -Value $fileContent

    # Dodaj separator między zawartościami różnych plików (opcjonalnie)
    Add-Content -Path $outputFile -Value "`n--- Koniec pliku: $filePath ---`n"
}

Write-Host "Zakończono przetwarzanie. Zawartość plików została zapisana do $outputFile"