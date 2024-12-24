# creating a tag/stub file to mark the script as haing already run so this can be read by intune and reported
if (-not (Test-Path "$($env:ProgramData)\Microsoft\Microsoft\W11Bloatware"))
{
    Mkdir "$($env:ProgramData)\Microsoft\W11Bloatware"
}
Set-Content -Path "$($env:ProgramData)\Microsoft\Microsoft\W11Bloatware.ps1.tag" -Value "Installed"

# start transcript log file
Start-Transcript "$($env:ProgramData)\Microsoft\Microsoft\W11Debloat.log"

# list of GCC unapproved apps to be removed from W11 devices
$UninstallPackages = @(
    "*ActiproSoftwareLLC*"
    "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
    "*BubbleWitch3Saga*"
    "*CandyCrush*"
    "*DevHome*"
    "*Disney*"
    "*Dolby*"
    "*Duolingo-LearnLanguagesforFree*"
    "*EclipseManager*"
    "*Facebook*"
    "*Flipboard*"
    "*gaming*"
    "*Minecraft*"
#    "*Office*"
    "*PandoraMediaInc*"
    "*Royal Revolt*"
    "*Speed Test*"
    "*Spotify*"
    "*Sway*"
    "*Twitter*"
    "*Wunderlist*"
#    "AD2F1837.HPPrinterControl"
#    "AppUp.IntelGraphicsExperience"
    "C27EB4BA.DropboxOEM*"
    "Disney.37853FC22B2CE"
    "DolbyLaboratories.DolbyAccess"
    "DolbyLaboratories.DolbyAudio"
    "E0469640.SmartAppearance"
#    "Microsoft.549981C3F5F10"
    "Microsoft.AV1VideoExtension"
    "Microsoft.BingNews"
    "Microsoft.BingSearch"
    "Microsoft.BingWeather"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.GamingApp"
    "Microsoft.HEVCVideoExtension"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftEdge.Stable"
    "Microsoft.MicrosoftJournal"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MixedReality.Portal"
    "Microsoft.MPEG2VideoExtension"
    "Microsoft.News"
    "Microsoft.Office.Lens"
#    "Microsoft.Office.OneNote"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
#    "Microsoft.OneDriveSync"
    "Microsoft.People"
#    "Microsoft.PowerAutomateDesktop"
#    "Microsoft.PowerAutomateDesktopCopilotPlugin"
    "Microsoft.Print3D"
#    "Microsoft.RemoteDesktop"
    "Microsoft.SkypeApp"
    "Microsoft.StorePurchaseApp"
    "Microsoft.SysinternalsSuite"
#    "Microsoft.Teams"
    "Microsoft.Todos"
    "Microsoft.Whiteboard"
    "Microsoft.Windows.DevHome"
    "Microsoft.WindowsAlarms"
    "Microsoft.WindowsCamera"
    "Microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
#    "Microsoft.WindowsSoundRecorder"
#    "Microsoft.WindowsStore"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxGamingOverlay_5.721.10202.0_neutral_~_8wekyb3d8bbwe"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "MicrosoftCorporationII.MicrosoftFamily"
    "MicrosoftCorporationII.QuickAssist"
    "MicrosoftWindows.Client.WebExperience"
    "MicrosoftWindows.CrossDevice"
    "MirametrixInc.GlancebyMirametrix"
#    "MSTeams"
    "RealtimeboardInc.RealtimeBoard"
    "SpotifyAB.SpotifyMusic"
)

$InstalledPackages = Get-AppxPackage -AllUsers | Where {($UninstallPackages -contains $_.Name)}

$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where {($UninstallPackages -contains $_.DisplayName)}

$InstalledPrograms = Get-Package | Where {$UninstallPrograms -contains $_.Name}

# Remove provisioned packages first
ForEach ($ProvPackage in $ProvisionedPackages) {

    Write-Host -Object "Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."

    Try {
       $Null = Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop
       Write-Host -Object "Successfully removed provisioned package: [$($ProvPackage.DisplayName)]"
}
    Catch {Write-Warning -Message "Failed to remove provisioned package: [$($ProvPackage.DisplayName)]"}
}

# Remove appx packages
ForEach ($AppxPackage in $InstalledPackages) {
                                            
    Write-Host -Object "Attempting to remove Appx package: [$($AppxPackage.Name)]..."

    Try {
        $Null = Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
        Write-Host -Object "Successfully removed Appx package: [$($AppxPackage.Name)]"
}
    Catch {Write-Warning -Message "Failed to remove Appx package: [$($AppxPackage.Name)]"}
}

# Remove installed programs
$InstalledPrograms | ForEach {

    Write-Host -Object "Attempting to uninstall: [$($_.Name)]..."

    Try {
        $Null = $_ | Uninstall-Package -AllVersions -Force -ErrorAction Stop
        Write-Host -Object "Successfully uninstalled: [$($_.Name)]"
}
    Catch {Write-Warning -Message "Failed to uninstall: [$($_.Name)]"}
}

Stop-Transcript