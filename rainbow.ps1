param
(
    $Count = 10000,
    $Message = "SO MUCH COLOR"
)

function ColorMeImpressed
{
    param
    (
        $Count,
        $Message
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

    for ($i = 0; $i -lt $Count; $i++)
    {
        $fgColor = Get-Random -Minimum 0 -Maximum ($colorList.Count - 1)
        $bgColor = Get-Random -Minimum 0 -Maximum ($colorList.Count - 1)

	if ($fgColor -eq $bgColor)
	{
		$fgColor = $colorList[-1]
		$bgColor = Get-Random -Minimum 0 -Maximum ($colorList.Count - 2)
	}

        Write-Host -Object " $Message " -ForegroundColor $fgColor -BackgroundColor $bgColor -NoNewline
    }
}

ColorMeImpressed -Count $Count -Message $message
