Using module .\datadogClass.psm1

$APIKey = "123456"
$APPKey = "789456"

$teste = New-Object -TypeName datadog

class datadogGcpPubSub : datadog 
{
    [string]$subscriptionId

    # Constructor
    datadogGcpPubSub ([string]$APIKey, [string]$APPKey, [string]$subscriptionId) 
    {
        $this.APIKey = $APIKey
        $this.APPKey = $APPKey
        $this.headers.Add("Content-Type", "application/json")
        $this.headers.Add("DD-API-KEY", $this.APIKey)
        $this.headers.Add("DD-APPLICATION-KEY", $this.APPKey)
        $this.subscriptionId = $subscriptionId
    }


}