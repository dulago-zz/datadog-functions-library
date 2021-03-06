Using module .\datadogClass.psm1

## Funcoes para obter e enviar informacoes de eventos para o Datadog
class datadogEvent : datadog 
{
    # Constructor
    datadogEvent ([string]$APIKey, [string]$APPKey) 
    {
        $this.APIKey = $APIKey
        $this.APPKey = $APPKey
        $this.headers.Add("Content-Type", "application/json")
        $this.headers.Add("DD-API-KEY", $this.APIKey)
        $this.headers.Add("DD-APPLICATION-KEY", $this.APPKey)
    }

    # envia um evento para o Datadog. Recomendado que a mensagem seja um JSON
    # Severidades: error, warning, info, success, user_update, recommendation, snapshot
    [string]sendEvent([string]$title, [string]$message, [string]$severity)
    {
        $uri = "https://api.datadoghq.com/api/v1/events"
        $body = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $body.Add("title",$title)
        $body.Add("text",$message)
        $body.Add("alert_type",$severity)

        try 
        {
            $response = Invoke-WebRequest -Uri $uri -Headers $this.headers -Body ($body | ConvertTo-Json) -Method "POST" -SkipCertificateCheck     
            return $true
        }
        catch 
        {
            $StatusCode = $_.Exception.Response.StatusCode.value__
            return "[ERROR] Error sending event do Datadog (Status code $StatusCode)"
        }
    }
}