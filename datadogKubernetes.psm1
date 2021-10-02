Using module .\datadogClass.psm1

# Funcoes que consultam metricas ou eventos de um cluster k8s
class datadogKubernetes : datadog 
{
    [string]$clustername

    datadogKubernetes([string]$APIKey, [string]$APPKey, [string]$clustername) 
    {
        $this.APIKey = $APIKey
        $this.APPKey = $APPKey
        $this.headers.Add("Content-Type", "application/json")
        $this.headers.Add("DD-API-KEY", $this.APIKey)
        $this.headers.Add("DD-APPLICATION-KEY", $this.APPKey)
        $this.clustername = $clustername
    }

    # Obtem a quantidade a quantidade de restart de pods em cada deploy nos ultimos 5 minutos
    # (Nao retorna deployments que nao tiveram restart de pod nesse periodo)
    [System.Object[]] getPodRestarts () 
    {
        $epochTimestampNow = [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
        $epochTimestampBefore = $epochTimestampNow - 600
        $query = "exclude_null(max:kubernetes.containers.restarts{cluster_name:$($this.clustername)} by {kube_deployment}.rollup(max, 60))"
        $queryEncoded = [uri]::EscapeDataString($query)
        $uriNow = "https://api.datadoghq.com/api/v1/query?from=$($epochTimestampNow - 60)&to=$($epochTimestampNow)&query=$($queryEncoded)"
        $requestNow = Invoke-RestMethod -Uri $uriNow -Headers $this.headers -Method "GET"
        $uri5MinAgo = "https://api.datadoghq.com/api/v1/query?from=$($epochTimestampBefore - 60)&to=$($epochTimestampBefore)&query=$($queryEncoded)"
        $request5MinAgo = Invoke-RestMethod -Uri $uri5MinAgo -Headers $this.headers -Method "GET"
        $seriesNow = $requestNow.series
        $series5MinAgo = $request5MinAgo.series

        $restartedPods = @{}
        for ($i = 0; $i -lt $seriesNow.Count; $i++) 
        {
            if($seriesNow[$i].pointlist[0][1] -ne 0)
            {
                $match = $series5MinAgo | Where-Object {$_.scope -eq $seriesNow[$i].scope}
                $deployName = $seriesNow[$i].scope.Split(":")[2]
                $diffRestartMetric = $seriesNow[$i].pointlist[0][1]
                if($null -ne $match)
                {
                    $diffRestartMetric -= $match.pointlist[0][1]
                    if($diffRestartMetric -lt 0) {$diffRestartMetric = 0}
                }
                if ($diffRestartMetric -ne 0) 
                {
                    $restartedPods[$i] = @{}
                    $restartedPods[$i][$deployName] = $diffRestartMetric
                }
            }            
        }
        return $restartedPods.Values
    } 
}



