function Get-Definition {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Word
    )

    # Base URL for Merriam-Webster Dictionary API
    $baseUrl = "https://www.dictionaryapi.com/api/v3/references/collegiate/json"

    $ApiKey = "01708239-0f4d-4139-ae28-be0037467c72"
    # Construct full request URL
    $requestUrl = "$baseUrl/$Word`?key=$ApiKey"

    $headers = @{
        "Accept"     = "application/json"
        "User-Agent" = "PowerShell-Client"
    }

    try {
        $response = Invoke-RestMethod -Uri $requestUrl -Headers $headers -Method Get
        return $response
    }
    catch {
        Write-Error "Failed to retrieve definition for '$Word'. $_"
        exit 1
    }
}

try {
    $definition = Get-Definition

    if ($null -eq $definition){
        throw "There was no definition retrieved.  The input may not be a valid word."
    }
    $definitionSingleString = ""
    $definition = $definition | Select-Object -First 1 -ExpandProperty shortdef

    $definition | Foreach-Object {$definitionSingleString += $definition}

    if ($null -eq $definitionSingleString){
        throw "There was an error compiling the definition."
    } else {
        return $definitionSingleString
    }
}
catch {
    Read-Host "$_`nPress enter to exit"
    exit 0
}

exit 0