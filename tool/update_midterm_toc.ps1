$ErrorActionPreference = "Stop"

$docxPath = (Resolve-Path "docs\RESIBO_PLEASE_MIDTERM_DOCUMENTATION.docx").Path
$word = $null
$document = $null

try {
    Write-Output "STAGE=starting Word"
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0

    Write-Output "STAGE=opening document"
    $document = $word.Documents.Open($docxPath)
    Write-Output "STAGE=updating fields"
    $document.Fields.Update() | Out-Null
    $document.Repaginate()
    $document.Fields.Update() | Out-Null

    Write-Output "STAGE=saving document"
    $document.Save()
    $pageCount = $document.ComputeStatistics(2)
    Write-Output "PAGES=$pageCount"
}
finally {
    if ($null -ne $document) {
        $document.Close($false)
        [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($document)
    }
    if ($null -ne $word) {
        $word.Quit()
        [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($word)
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
