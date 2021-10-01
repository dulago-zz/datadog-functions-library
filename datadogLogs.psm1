## Funcoes para extrair estatisticas de logs indexados pelo Datadog
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
    
    # send a log payload to Datadog. Recomendado que mensagem seja JSON
    [int]sendLog([string]$message,[string]$service)
    {
        $body = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $body.Add("ddsource", "powershell")
        $body.Add("message",$message)
        $body.add("service",$service)    
        $uri = "https://http-intake.logs.datadoghq.com/v1/input"
        try 
        {
            $response = Invoke-WebRequest -Uri $uri -Headers $this.headers -Body ($body | ConvertTo-Json) -Method "POST"    
        }
        catch 
        {
            $StatusCode = $_.Exception.Response.StatusCode.value__
            return "[ERROR] Error sending logs do Datadog (Status code $StatusCode)"
        }
    }
}