# Define the directory containing the source CSV files
$SourceDirectory = "C:\Users\SNOW_Reports"

# Get all CSV files in the specified directory
# The -Filter "*.csv" ensures only CSV files are processed
$SourceFiles = Get-ChildItem -Path $SourceDirectory -Filter "*.csv"

# Start processing files
Write-Host "Starting file processing in '$SourceDirectory'..."

# Loop through each file found
foreach ($File in $SourceFiles) {
    # Get the full path of the current source file
    $SourceFilePath = $File.FullName

    # Construct the output filename by inserting "_out" before the extension
    # Example: C:\...\Report.csv -> C:\...\Report_out.csv
    $OutputFilePath = $SourceFilePath -replace '\.csv$', '_out.csv'

    # Display which file is being processed
    Write-Host "Processing file: '$($File.Name)'..."

    # Import, process, and export the data
    Import-Csv -Path $SourceFilePath | Export-Csv -Path $OutputFilePath -NoTypeInformation

    # Display confirmation for the current file
    Write-Host "Output saved to: '$($OutputFilePath)'"
}

# Display overall completion message
Write-Host "---"
Write-Host "All files have been processed successfully."
