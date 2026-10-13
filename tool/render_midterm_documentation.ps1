$ErrorActionPreference = "Stop"

$docxPath = (Resolve-Path "docs\RESIBO_PLEASE_MIDTERM_DOCUMENTATION.docx").Path
$pdfPath = Join-Path $env:TEMP "resibo_please_midterm_documentation_preview.pdf"

$word = $null
$document = $null

try {
    Write-Output "STAGE=starting Word"
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0

    Write-Output "STAGE=opening document"
    $document = $word.Documents.Open($docxPath)
    Write-Output "STAGE=repaginating"
    $document.Repaginate()

    Write-Output "STAGE=counting pages"
    $pageCount = $document.ComputeStatistics(2)
    Write-Output "STAGE=exporting PDF"
    $document.ExportAsFixedFormat($pdfPath, 17)

    Write-Output "PAGES=$pageCount"
    Write-Output "PDF=$pdfPath"
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
