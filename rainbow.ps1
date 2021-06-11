param
(
    $count = 10000,
    $message = "SO MUCH COLOR"
)
function ColorMeImpressed
{
    param
    (
        $count = 10000,
        $message = "SO MUCH COLOR"
    )

    $colorList = @(
        "Black"
        "DarkBlue"
        "DarkGreen"
        "DarkCyan"
        "DarkRed"
        "DarkMagenta"
        "DarkYellow"
        "Gray"
        "DarkGray"
        "Blue"
        "Green"
        "Cyan"
        "Red"
        "Magenta"
        "Yellow"
        "White"
    )

    for ($i = 0; $i -lt $count; $i++)
    {
        $fgColor = Get-Random -Minimum 0 -Maximum ($colorList.Count - 1)
        $bgColor = Get-Random -Minimum 0 -Maximum ($colorList.Count - 1)

	if ($fgColor -eq $bgColor)
	{
		$fgColor = $colorList[-1]
		$bgColor = Get-Random -Minimum 0 -Maximum ($colorList.Count - 2)
	}

        Write-Host -Object " $message " -ForegroundColor $fgColor -BackgroundColor $bgColor -NoNewline
    }
}

ColorMeImpressed -count $count -message $message