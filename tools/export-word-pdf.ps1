param([Parameter(Mandatory=$true)][string]$InputDocx,[Parameter(Mandatory=$true)][string]$OutputPdf)
$ErrorActionPreference = 'Stop'
$taskRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskInput = [System.IO.Path]::GetFullPath((Join-Path $taskRoot $InputDocx))
$taskOutput = [System.IO.Path]::GetFullPath((Join-Path $taskRoot $OutputPdf))
if (-not $taskInput.StartsWith($taskRoot + [System.IO.Path]::DirectorySeparatorChar) -or -not $taskOutput.StartsWith($taskRoot + [System.IO.Path]::DirectorySeparatorChar)) { throw 'Document paths must stay in the project.' }
$taskBefore = (Get-FileHash -LiteralPath $taskInput).Hash
$taskWord = $null
$taskDoc = $null
try {
 $taskWord = New-Object -ComObject Word.Application
 if ($taskWord.Documents.Count -ne 0) { throw 'Existing Word documents detected; export instance not isolated.' }
 $taskWord.Visible = $false
 $taskDoc = $taskWord.Documents.Open($taskInput, $false, $true, $false)
 $taskDoc.Repaginate()
 $taskPages = $taskDoc.ComputeStatistics(2)
 $taskDoc.ExportAsFixedFormat($taskOutput,17)
 Write-Output "PASS read-only Word pagination/export: $taskPages pages"
} finally {
 if ($null -ne $taskDoc) { $taskDoc.Close(0) }
 if ($null -ne $taskWord -and $taskWord.Documents.Count -eq 0) { $taskWord.Quit() }
}
if ((Get-FileHash -LiteralPath $taskInput).Hash -ne $taskBefore) { throw 'Read-only export unexpectedly changed DOCX bytes.' }
