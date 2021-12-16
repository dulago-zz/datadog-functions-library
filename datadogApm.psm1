Using module .\datadogClass.psm1

class datadogApm : datadog 
{
    datadogApm([string]$APIKey, [string]$APPKey) 
    {
        $this.APIKey = $APIKey
        $this.APPKey = $APPKey
        $this.headers.Add("Content-Type", "application/json")
        $this.headers.Add("DD-API-KEY", $this.APIKey)
        $this.headers.Add("DD-APPLICATION-KEY", $this.APPKey)
    }

    # return a list of all services that reported to Datadog APM in the last given hours
    [System.Collections.Generic.List[string]]getReportingServices([int] $lastHours)
    {
        $epochTimestampNow = [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
        $epochTimestampBefore = $epochTimestampNow - ($lastHours * 3600)
        $query = "sum:datadog.estimated_usage.apm.indexed_spans {env:*} by {service}"
        $queryEncoded = [uri]::EscapeDataString($query)
        $uri = "https://api.datadoghq.com/api/v1/query?from=$($epochTimestampBefore)&to=$($epochTimestampNow)&query=$($queryEncoded)"

        try 
        {
            $response = Invoke-RestMethod -Uri $uri -Method "GET" -Headers $this.headers -SkipCertificateCheck        
        }
        catch 
        {
            $StatusCode = $_.Exception.Response.StatusCode.value__
            return "[ERROR] Error getting services from Datadog (Status code $StatusCode)"
        }
        $serviceList = [System.Collections.Generic.List[string]]::new()
        foreach ($item in $response.series) 
        {
            $serviceList.Add($item.tag_set.Split(":")[1])    
        }

        return $serviceList
    }
}