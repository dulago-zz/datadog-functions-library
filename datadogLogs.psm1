Using module .\datadogClass.psm1

## Funcoes para extrair estatisticas de logs indexados pelo Datadog e enviar logs
class datadogLogs : datadog 
{
    # Constructor
    datadogLogs ([string]$APIKey, [string]$APPKey) 
    {
        $this.APIKey = $APIKey
        $this.APPKey = $APPKey
        $this.headers.Add("Content-Type", "application/json")
        $this.headers.Add("DD-API-KEY", $this.APIKey)
        $this.headers.Add("DD-APPLICATION-KEY", $this.APPKey)
    }
    
    # envia um payload de log para o Datadog. Recomendado que mensagem seja JSON
    [string]sendLog([string]$service, [string]$message)
    {
        $body = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $body.Add("ddsource", "powershell")
        $body.Add("message",$message)
        $body.add("service",$service)    
        $uri = "https://http-intake.logs.datadoghq.com/v1/input"
        try 
        {
            $response = Invoke-WebRequest -Uri $uri -Headers $this.headers -Body ($body | ConvertTo-Json) -Method "POST"    
            return $true
        }
        catch 
        {
            $StatusCode = $_.Exception.Response.StatusCode.value__
            return "[ERROR] Error sending logs do Datadog (Status code $StatusCode)"
        }
    }

    # retorna "true" caso haja algum erro nos logs de uma aplicacao especifica em um ambiente nos ultimos 5 min
    [bool]hasErrors([string]$serviceName, [string]$env)
    {
        $query = "status:error service:$($serviceName) env:$($env)"
        $body = "{`n  `"filter`": {`n    `"from`": `"now-5m`",`n    `"to`": `"now`",`n    `"query`": `"$($query)`" `n  },`n `"page`":{ `n `"limit`":5000 `n } `n}"
        $uri = "https://api.datadoghq.com/api/v2/logs/events/search"
        try 
        {
            $response = Invoke-RestMethod -Uri $uri -Method "POST" -Headers $this.headers -Body $body
            $numErr = $response.data.count
            if ($numErr -eq 0) { return $false }
            else { return $true }
        }
        catch 
        {
            $StatusCode = $_.Exception.Response.StatusCode.value__
            return "[ERROR] Error retrieving log data from Datadog (Status code $StatusCode)"
        }   
    }

    # busca por uma chave:valor especifica e retorna se houveram logs de erro pra ela nos ultimos 5 min
    [bool]hasErrorsKeyValue([string]$key, [string]$value)
    {
        $query = "@$($key):$($value) status:error"
        $body = "{`n  `"filter`": {`n    `"from`": `"now-5m`",`n    `"to`": `"now`",`n    `"query`": `"$($query)`" `n  },`n `"page`":{ `n `"limit`":5000 `n } `n}"
        $uri = "https://api.datadoghq.com/api/v2/logs/events/search"
        try 
        {
            $response = Invoke-RestMethod -Uri $uri -Method "POST" -Headers $this.headers -Body $body
            $numErr = $response.data.count
            if ($numErr -eq 0) { return $false }
            else { return $true }
        }
        catch 
        {
            $StatusCode = $_.Exception.Response.StatusCode.value__
            return "[ERROR] Error retrieving log data from Datadog (Status code $StatusCode)"
        }   
    }
}