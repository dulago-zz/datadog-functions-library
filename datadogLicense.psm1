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

    # returns the ratio of indexed spans for each service compared to the total on the last given hours
    [psobject] getIndexedSpansRatioPerService([int] $lastHours)
    {
        $epochTimestampNow = [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
        $epochTimestampBefore = $epochTimestampNow - ($lastHours * 3600)
        $queryPerService = "sum:datadog.estimated_usage.apm.indexed_spans{env:*} by {service}.as_count().rollup(sum, 3600)"
        $queryEncodedPerService = [uri]::EscapeDataString($queryPerService)
        $uriPerService = "https://api.datadoghq.com/api/v1/query?from=$($epochTimestampBefore)&to=$($epochTimestampNow)&query=$($queryEncodedPerService)"
        $queryAllSpans = "sum:datadog.estimated_usage.apm.indexed_spans{env:*}.rollup(sum, 3600)"
        $queryEncodedAllSpans = [uri]::EscapeDataString($queryAllSpans)
        $uriPerAllSpans = "https://api.datadoghq.com/api/v1/query?from=$($epochTimestampBefore)&to=$($epochTimestampNow)&query=$($queryEncodedAllSpans)"

        try 
        {   
            $responsePerService = Invoke-RestMethod -Uri $uriPerService -Method "GET" -Headers $this.headers -SkipCertificateCheck       
            $responseAllSpans = Invoke-RestMethod -Uri $uriPerAllSpans -Method "GET" -Headers $this.headers -SkipCertificateCheck         
        }
        catch 
        {
            $StatusCode = $_.Exception.Response.StatusCode.value__
            return "[ERROR] Error getting services from Datadog (Status code $StatusCode)"
        }

        [double]$allSpans = 0
        for ($i = 0; $i -lt $lastHours; $i++) 
        {
            $allSpans += [double]$responseAllSpans.series.pointlist[$i][1]
        }

        $ratioPerService = New-Object "System.Collections.Generic.Dictionary[[String],[double]]"
        for ($i = 0; $i -lt $responsePerService.series.Count; $i++) 
        {
            [string]$serviceName = ""
            [double]$totalSpans = 0
            $serviceName = $responsePerService.series[$i].tag_set.Split(":")[1]
            for ($j = 0; $j -lt $lastHours; $j++) 
            {
                $totalSpans += [double]$responsePerService.series[$i].pointlist[$j][1]
            }
            $ratio = ($totalSpans/$allSpans)*100
            $ratioPerService.Add("$serviceName", $ratio)
        }
        
        return $ratioPerService
    }
}