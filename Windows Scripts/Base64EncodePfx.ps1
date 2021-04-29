$certificateLocation = 'C:\Users\umar.khan\Downloads\star.origence.local.pfx'

$fileContentBytes = get-content $certificateLocation -Encoding Byte

[System.Convert]::ToBase64String($fileContentBytes) `
    | Out-File ‘pfx-encoded-bytes.txt’