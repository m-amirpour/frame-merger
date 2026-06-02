# ============================================================
# prepare_videos.ps1
# Converts two .mov files to MATCHING resolution, framerate,
# and duration. Outputs: vid1_ready.mov, vid2_ready.mov
# ============================================================

$input1  = "vid1-raw.mov"
$input2  = "vid2-raw.mov"

# Target settings (adjust if you want a different size)
$width   = 1280
$height  = 720
$fps     = 30

# ----- Get video durations -----
$dur1 = ffprobe -v error -show_entries format=duration -of csv=p=0 $input1
$dur2 = ffprobe -v error -show_entries format=duration -of csv=p=0 $input2

if (-not $dur1 -or -not $dur2) {
    Write-Error "Could not read durations. Check file names."
    exit 1
}

$dur1 = [double]$dur1
$dur2 = [double]$dur2
$shortest = [math]::Min($dur1, $dur2)

Write-Host "Shorter video length: $shortest seconds"
Write-Host "Target: ${width}x${height} @ ${fps} fps"
Write-Host "Converting ..."

# Convert vid1
ffmpeg -i $input1 -vf "scale=${width}:${height},fps=$fps" -t $shortest -c:v libx264 -pix_fmt yuv420p -an vid1_ready.mov
if ($LASTEXITCODE -ne 0) { Write-Error "Error converting $input1"; exit 1 }

# Convert vid2
ffmpeg -i $input2 -vf "scale=${width}:${height},fps=$fps" -t $shortest -c:v libx264 -pix_fmt yuv420p -an vid2_ready.mov
if ($LASTEXITCODE -ne 0) { Write-Error "Error converting $input2"; exit 1 }

Write-Host "Done. Output files:"
Write-Host "  vid1_ready.mov"
Write-Host "  vid2_ready.mov"
Write-Host "Both are $shortest seconds long, ${width}x${height}, $fps fps."