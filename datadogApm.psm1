Using module .\datadogClass.psm1

class datadogApm : datadog 
{
    datadogApm([string]$APIKey, [string]$APPKey, [string]$clustername) 
    {
        $this.APIKey = $APIKey
        $this.APPKey = $APPKey
        $this.headers.Add("Content-Type", "application/json")
        $this.headers.Add("DD-API-KEY", $this.APIKey)
        $this.headers.Add("DD-APPLICATION-KEY", $this.APPKey)
    }

}