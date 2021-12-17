Using module .\datadogClass.psm1
using module .\datadogApm.psm1

class datadogLicense : datadog 
{
    datadogLicense([string]$APIKey, [string]$APPKey) 
    {
        $this.APIKey = $APIKey
        $this.APPKey = $APPKey
        $this.headers.Add("Content-Type", "application/json")
        $this.headers.Add("DD-API-KEY", $this.APIKey)
        $this.headers.Add("DD-APPLICATION-KEY", $this.APPKey)
    }

    
}