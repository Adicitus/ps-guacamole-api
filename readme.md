Powershell Wrapper for the Guacamole REST API \[WIP\]

Based on information from the Guacamole Manual: https://github.com/kingmeers/guacamole-manual/blob/master/src/chapters/guacamole-rest-api.xml

The raw REST API calls as implementated of the Guacamole Web App can be found here:
https://github.com/apache/guacamole-client/blob/master/guacamole/src/main/frontend/src/app/rest/services

# Usage:

```
$guacamoleHostname = "<Your Guacamole server address here>"
$guacamolePath = "guacamole"
$guacamoleCredential = Get-Credential

# Request authenticaton token from the server:
$guacamoleAuth = Request-GuacamoleAPIAuth -Hostname $guacamoleHostname -Credential $guacamoleCredential -GuacamolePath $guacamolePath -protocol https 

# Save the authentication details to the file .guacamole and encrypt it via DPAPI using the current user credential:
Save-GuacamoleAPIAuth ".\.guacamole" -AuthObject $guacamoleAuth
```