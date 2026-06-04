param(
    [Parameter(Mandatory = $true)]
    [string]$CommitMessage,
    [Parameter(Mandatory = $true)]
    [string]$BuildNumber

)

#Assign as script level variable to avoid unnecessary passing of arguments later on.
$script:buildNumber = $BuildNumber

function Split-CommitMessage {
    param (
        [string]$inputWords
    )
    $words = $inputWords -replace '[^a-zA-Z\s]', ''
    $outputWords = $inputWords.split(" ")
    return $outputWords
}

function Append-CommitMessageDefinitionLog {
    param (
        [string]$word,
        [string]$definition
    )

    $output = [PSCustomObject]@{
        Word = $word
        Definition = $definition
    }

    $output | Export-Csv -Path ".\Commit Message Word Definitions\$script:buildNumber.csv" -Append -NoTypeInformation

}

# Base URL for Merriam-Webster Dictionary API.  Static API Inputs
$baseUrl = "https://www.dictionaryapi.com/api/v3/references/collegiate/json"
$ApiKey = "01708239-0f4d-4139-ae28-be0037467c72"
$headers = @{
    "Accept"     = "application/json"
    "User-Agent" = "PowerShell-Client"
}

#Call function to split commit message into single words for evaluation.
$outputWords = Split-CommitMessage -inputWords $CommitMessage

foreach ($Word in $outputWords) {
    try {
        $definition = $null

        # Construct full request URL
        $requestUrl = "$baseUrl/$Word`?key=$ApiKey"
        $definition = Invoke-RestMethod -Uri $requestUrl -Headers $headers -Method Get

        if ($null -eq $definition -OR $definition -eq ""){
            throw "There was no definition retrieved.  The input may not be in the dictionary."
        }
        $definitionSingleString = ""
        $definition = $definition | Where-Object shortdef -ne $null | Select-Object -First 1 -ExpandProperty shortdef -ErrorAction SilentlyContinue

        $definition | Foreach-Object {$definitionSingleString += $definition}

        if ($null -eq $definitionSingleString -OR $definitionSingleString -eq ""){
            throw "There was an error compiling the definition."
        } else {
            Append-CommitMessageDefinitionLog  -word $word -definition $definitionSingleString
        }
    }
    catch {
        #Read-Host "$_`nPress enter to exit"
        Append-CommitMessageDefinitionLog  -word $word -definition $_ 
        exit 0
    }
}

exit 0