$buildnumFile = "$PSScriptRoot\.meta\buildnumber"

$buildnum = Get-Content $buildnumFile

"1.0.25.{0}" -f $buildnum