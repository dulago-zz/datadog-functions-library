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
    
    # Retorna a quantidade de mensagens na fila num intervalo de X minutos
    [int] getUndeliveredMessages ($interval) 
    {
        $intervalSeconds = $interval * 60
        $epochTimestampNow = [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
        $epochTimestampBefore = $epochTimestampNow - $intervalSeconds
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
            return "[ERROR] Error sending event do Datadog (Status code $StatusCode)"
        }

        $numMessages = 0
        for ($i = 0; $i -lt $response.series.pointlist.Count; $i++) 
        {
            $numMessages += $response.series.pointlist[$i][1]   
        }
        return $numMessages
    }
}