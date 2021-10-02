class datadog
{
    [string]$APIKey
    [string]$APPKey
    $headers = [System.Collections.Generic.Dictionary[[String],[String]]]::new()

    ## Constructors
    datadog () {}
    datadog ([string]$APIKey, [string]$APPKey) 
    {
        $this.APIKey = $APIKey
        $this.APPKey = $APPKey
        $this.headers.Add("Content-Type", "application/json")
        $this.headers.Add("DD-API-KEY", $this.APIKey)
        $this.headers.Add("DD-APPLICATION-KEY", $this.APPKey)
    }   
}
