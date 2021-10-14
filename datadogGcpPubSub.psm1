Using module .\datadogClass.psm1

## Funcoes para extrair dados de um topico do GCP PubSub
class datadogGcpPubSub : datadog 
{
    [string]$projectId
    [string]$subscriptionId

    # Constructor
    datadogGcpPubSub ([string]$APIKey, [string]$APPKey, [string]$projectId,[string]$subscriptionId) 
    {
        $this.APIKey = $APIKey
        $this.APPKey = $APPKey
        $this.headers.Add("Content-Type", "application/json")
        $this.headers.Add("DD-API-KEY", $this.APIKey)
        $this.headers.Add("DD-APPLICATION-KEY", $this.APPKey)
        $this.projectId = $projectId
        $this.subscriptionId = $subscriptionId
    }
    
    # Retorna a quantidade de mensagens nao lidas na fila no momento
    [int] getUndeliveredMessages () 
    {
        $epochTimestampNow = ([Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s")) - 180) # 3min delay to account for GCP metrics delay
        $epochTimestampBefore = $epochTimestampNow - 300
        $query = "max:gcp.pubsub.subscription.num_undelivered_messages{subscription_id:$($this.subscriptionId),project_id:$($this.projectId)}" 
        $queryEncoded = [uri]::EscapeDataString($query)
        $uri = "https://api.datadoghq.com/api/v1/query?from=$($epochTimestampBefore)&to=$($epochTimestampNow)&query=$($queryEncoded)"
        
        try 
        {
            $response = Invoke-RestMethod -Uri $uri -Method "GET" -Headers $this.headers
        }
        catch 
        {
            $StatusCode = $_.Exception.Response.StatusCode.value__
            return "[ERROR] Error getting log data from Datadog (Status code $StatusCode)"
        }

        return $response.series.pointlist[($response.series.pointlist.Length)-1][1]
    }
}