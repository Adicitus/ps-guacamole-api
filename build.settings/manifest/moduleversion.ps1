$buildnumFile = "$PSScriptRoot\.meta\buildnumber"

$buildnum = Get-Content $buildnumFile

"1.0.1.{0}" -f $buildnum