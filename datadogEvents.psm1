## Funcoes para obter e enviar informacoes de eventos para o Datadog
class datadogLogs : datadog 
{
    # Constructor
    datadogGcpPubSub ([string]$APIKey, [string]$APPKey) 
    {
        $this.APIKey = $APIKey
        $this.APPKey = $APPKey
        $this.headers.Add("Content-Type", "application/json")
        $this.headers.Add("DD-API-KEY", $this.APIKey)
        $this.headers.Add("DD-APPLICATION-KEY", $this.APPKey)
    }

    [string]sendEvent([string]$title, [string]$message, [string]$severity)
    {
        $uri = "https://api.datadoghq.com/api/v1/events"
        $body = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $body.Add("title",$title)
        $body.Add("text",$message)
        $body.Add("alert_type",$severity)

        try 
        {
            $response = Invoke-WebRequest -Uri $uri -Headers $this.headers -Body ($body | ConvertTo-Json) -Method "POST"    
            return "Event successfully sent to Datadog"
        }
        catch 
        {
            $StatusCode = $_.Exception.Response.StatusCode.value__
            return "[ERROR] Error sending event do Datadog (Status code $StatusCode)"
        }
    }
}