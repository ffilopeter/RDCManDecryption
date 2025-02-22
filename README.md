# RDCMan password decryption
Remote Desktop Connection Manager - decryption (PUBLIC)

Decrypts both:
- `certificate` encrypted passwords
- `logon credentials` encrypted passwords (on the same user profile)

## Usage
1. Create `C:\temp` directory.
2. Copy `.rdg` file to directory above
3. Set `$certificateEncryption` to `$true` if decrypting certificate-encrypted passwords, `$false` otherwise
4. Copy `decrypt.ps1` to powershell
5. If the `RDCMan.dll` does not exists in `C:\temp` directory, provide path to `RDCMan.exe` file in the script prompt

Script will try to get certificate thumbprint from RDCMan settings file located in `%localappdata\Microsoft\Remote Desktop Connection Manager` if this encryption method was already set in the program. Certificate must be imported in current-user Personal certificate store. If you don't have certificate-encryption set already, you can set `$certificateThumbprintAutofill` to `$false` and provide certificate thumbprint manually to `$certificateThumbprint` variable (this can be obtained from `certmgr.msc`). Either way, certificate must be imported.
