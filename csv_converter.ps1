# Define the directory containing the source CSV files
$SourceDirectory = "C:\Users\SNOW_Reports"

# Get all CSV files in the specified directory
$SourceFiles = Get-ChildItem -Path $SourceDirectory -Filter "*.csv"

# Start processing files
Write-Host "Starting file processing in '$SourceDirectory'..."

# Loop through each file found
foreach ($File in $SourceFiles) {
    # Get the full path of the current source file
    $SourceFilePath = $File.FullName

    # Construct the output filename
    $OutputFilePath = $SourceFilePath -replace '\.csv$', '_out.csv'

    # Display which file is being processed
    Write-Host "Processing file: '$($File.Name)'..."

    # 1. Import the data and store it in a variable ($CsvData). 
    # This ensures the source file handle is closed immediately after the import completes.
    $CsvData = Import-Csv -Path $SourceFilePath

    # 2. Export the data from the variable to the new file
    $CsvData | Export-Csv -Path $OutputFilePath -NoTypeInformation

    # Remove the variable from memory to free up resources immediately (optional but good practice)
    Remove-Variable CsvData -Force -ErrorAction SilentlyContinue

    # Display confirmation for the current file
    Write-Host "Output saved to: '$($OutputFilePath)'"
}

# Display overall completion message
Write-Host "---"
Write-Host "All files have been processed successfully."
