# Create folder "img"
New-Item -ItemType directory -Force -Path C:\Users\m.riedlsperger\Desktop\img


# Copy from "Bildpuffer" and "pdf Puffer" to "img"
Copy-Item -Path 'V:\Bildpuffer\*' -Destination 'C:\Users\m.riedlsperger\Desktop\img'
Copy-Item -Path 'V:\pdf Puffer\*' -Destination 'C:\Users\m.riedlsperger\Desktop\img'


# Copy from "Artikelbilder" and "Sicherheitsdatenblaetter" to "img", if the file is newer than 14 days
Get-ChildItem -Path 'V:\Artikelbilder\' -Recurse|
Where-Object {
  $_.LastWriteTime -gt [datetime]::Now.AddDays(-14)
}| Copy-Item -Destination 'C:\Users\m.riedlsperger\Desktop\img'
Get-ChildItem -Path 'V:\Sicherheitsdatenblaetter\' -Recurse|
Where-Object {
  $_.LastWriteTime -gt [datetime]::Now.AddDays(-14)
}| Copy-Item -Destination 'C:\Users\m.riedlsperger\Desktop\img'


# Delete evil characters
ls 'C:\Users\m.riedlsperger\Desktop\img' -File -Recurse -Force -EA SilentlyContinue | ?{$_.Basename -match '[^\w\+\-\(\)äöü ]'} | ren -NewName {(Replace-Chars $_.Basename -replaceString '_') + $_.Extension} -Force -Verbose


# Add csv and img folder to zip
Compress-Archive -Path C:\Users\m.riedlsperger\Desktop\catalog.csv -DestinationPath C:\Users\m.riedlsperger\Desktop\catalog.zip
Compress-Archive -Path C:\Users\m.riedlsperger\Desktop\img -Update -DestinationPath C:\Users\m.riedlsperger\Desktop\catalog.zip


# Move zip to ftp-server
Move-Item -Path C:\Users\m.riedlsperger\Desktop\catalog.zip -Destination W:\nordwest\ESHOPIMPORT\catalog.zip -Force









# SRC: https://administrator.de/forum/powershell-regex-unerlaubte-zeichen-und-symbole-aus-dateinamen-entfernen-639712.html
function Replace-Chars([parameter(ValueFromPipeline=$true)]$string,$replaceString='_'){
    $r = "[^\w\+\-\(\)äöü ]"
    if ($replaceString -match $r){
        Write-Error -Message "Parameter '-replaceString' contains invalid filename chars/sequences." -Category InvalidArgument -TargetObject $replaceString
        break
    }
    while($string -match $r){
        $string = ($string -replace $r,$replaceString).trim()
    }
    return $string
}