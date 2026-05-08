$logoPath = "C:\Users\hugui\OneDrive\Escritorio\[Programacion]\Proyecto AlfaZulu\AlfaZulu\logo1.png"
$outputPath = "C:\Users\hugui\OneDrive\Escritorio\[Programacion]\Proyecto AlfaZulu\AlfaZulu\apps\mobile\playstore_assets"

Add-Type -AssemblyName System.Drawing

$logo = [System.Drawing.Image]::FromFile($logoPath)

# 1. Icono Play Store (512x512)
$icon = New-Object System.Drawing.Bitmap($logo, 512, 512)
$icon.Save("$outputPath\playstore-icon-512.png", [System.Drawing.Imaging.ImageFormat]::Png)
$icon.Dispose()
Write-Host "Icono 512x512 creado: playstore-icon-512.png"

# 2. Feature Graphic (1024x500)
$feature = New-Object System.Drawing.Bitmap(1024, 500)
$g = [System.Drawing.Graphics]::FromImage($feature)
$g.Clear([System.Drawing.Color]::Black)

$logoResized = New-Object System.Drawing.Bitmap($logo, 200, 200)
$x = (1024 - 200) / 2
$y = (500 - 200) / 2
$g.DrawImage($logoResized, $x, $y)

$font = New-Object System.Drawing.Font("Arial", 48, [System.Drawing.FontStyle]::Bold)
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 0))
$text = "ALFAZULU"
$textSize = $g.MeasureString($text, $font)
$textX = (1024 - $textSize.Width) / 2
$textY = $y + 200 + 20
$g.DrawString($text, $font, $brush, $textX, $textY)

$feature.Save("$outputPath\feature-graphic-1024x500.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$feature.Dispose()
$logoResized.Dispose()
Write-Host "Feature Graphic 1024x500 creado: feature-graphic-1024x500.png"

$logo.Dispose()
Write-Host "Assets generados exitosamente!"
