Add-Type -AssemblyName System.Drawing

function Make-Icon {
    param([int]$Size, [string]$OutPath)

    $bmp = New-Object System.Drawing.Bitmap($Size, $Size,
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)

    $bg = [System.Drawing.Color]::FromArgb(255, 255, 0, 255)
    $g.Clear($bg)

    $barColor = [System.Drawing.Color]::FromArgb(255, 30, 100, 200)
    $brush    = New-Object System.Drawing.SolidBrush($barColor)

    $margin = [int]($Size * 0.15)
    $barH   = [int]($Size * 0.14)
    $gap    = [int]($Size * 0.07)
    $w      = $Size - $margin * 2

    $y1 = [int]($Size * 0.22)
    $y2 = $y1 + $barH + $gap
    $y3 = $y2 + $barH + $gap

    $g.FillRectangle($brush, $margin, $y1, $w, $barH)
    $g.FillRectangle($brush, $margin, $y2, $w, $barH)
    $g.FillRectangle($brush, $margin, $y3, [int]($w * 0.65), $barH)

    $brush.Dispose()
    $g.Dispose()

    $bmp24 = $bmp.Clone(
        [System.Drawing.Rectangle]::new(0, 0, $Size, $Size),
        [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $bmp.Dispose()

    $bmp24.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Bmp)
    $bmp24.Dispose()
    Write-Host "Created: $OutPath"
}

$dir = Split-Path $MyInvocation.MyCommand.Path
Make-Icon -Size 24 -OutPath (Join-Path $dir "Query4D_Icon_24.bmp")
Make-Icon -Size 48 -OutPath (Join-Path $dir "Query4D_Icon_48.bmp")
