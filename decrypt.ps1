#
# Remote Desktop Connection Manager
# password encryption/decryption

$certificateEncryption = $true
$certificateThumbprint = ""
$certificateThumbprintAutofill = $true

$workdir = "C:\temp"
$rdcmandll = "$workdir\RDCMan.dll"
$config = "$workdir\config.rdg"

# ----------------------------------------

# Test if files exists
if ((Test-Path $rdcmandll -PathType Leaf) -eq $false) {
    Write-Host "File '$rdcmandll' does not exist"
    $read = Read-Host "Provide path to 'RDCMan.exe' file"

    # Try to copy DLL file from user input
    if ((Test-Path $read -PathType Leaf)) {
        Copy-Item "$read" "$rdcmandll"
        Write-Host "Copied successfuly"
    } else {
        Write-Host "Path to 'RDCMan.exe' is not correct"
        return $null
    }
}

if ((Test-Path $config -PathType Leaf) -eq $false) {
    Write-Host "File '$config' does not exist"
    return $null
}

# Autofill certificate thumbprint from settings file
if ($certificateThumbprintAutofill -and $certificateEncryption) {
    $settings = "$env:LOCALAPPDATA\Microsoft\Remote Desktop Connection Manager\RDCMan.settings"

    if ((Test-Path $settings -PathType Leaf) -eq $true) {
        $settingsXml = [xml](Get-Content $settings)
        $credentialData = $settingsXml.SelectNodes("//encryptionSettings").credentialData
        $certificateThumbprint = $credentialData
        Write-Host "Certificate thumbprint set '$certificateThumbprint'"
    } else {
        Write-Host "RDCMan settings file does not exist in localappdata path."
    }
}

Unblock-File $rdcmandll
Import-Module $rdcmandll

# Initialize encryption settings
$encryptionSettings = New-Object -TypeName RdcMan.EncryptionSettings

if ($certificateEncryption -eq $true) {
    $encryptionSettings.CredentialData.Value = $certificateThumbprint
    $encryptionSettings.EncryptionMethod.Value = [RdcMan.EncryptionMethod]::Certificate
} else {
    $encryptionSettings.EncryptionMethod.Value = [RdcMan.EncryptionMethod]::LogonCredentials
}

# Parse XML configuration
$xml = [xml](Get-Content $config)
$profiles = $xml.SelectNodes("//credentialsProfile")

$credentials = @()

# Loop through all profiles
foreach ($profile in $profiles) {

    $username = $profile.userName
    $password = $profile.password
    $decrypted = $null
    $domain = $profile.domain

    try {
        $decrypted = [RdcMan.Encryption]::DecryptString($password, $encryptionSettings)
    } catch {
        $_.Exception.InnerException.Message
    }

    $credentials += [PSCustomObject]@{
        username = $username
        password = $password
        decrypted = $decrypted
        domain = $domain
    }
}

Write-Host "Use 'credentials' variable for listing"
