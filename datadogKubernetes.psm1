Using module .\datadogClass.psm1

# Funcoes que consultam metricas ou eventos de um cluster k8s
class datadogKubernetes : datadog 
{
    [string]$clustername

    datadogKubernetes
    {
        $this.APIKey = $APIKey
        $this.APPKey = $APPKey
        $this.headers.Add("Content-Type", "application/json")
        $this.headers.Add("DD-API-KEY", $this.APIKey)
        $this.headers.Add("DD-APPLICATION-KEY", $this.APPKey)
        $this.clustername = $clustername
    }

    
}