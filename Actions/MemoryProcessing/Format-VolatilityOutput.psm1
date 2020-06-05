function Format-VolatilityOutput {
    param (
        [Parameter(Mandatory=$true)]$VolatilityFunctionOutput
    )

    # Setup the output variable
    $output = @{
        "Object" = "Format-VolatilityOutput"
    }

    # Format the output
    # Filter the results so that only good things are returned. Also, if you're reading this, smile
    $results = $VolatilityFunctionOutput[2..$VolatilityFunctionOutput.Count]

    # Reconstruct the results based upon the strings. This will be moved into a separate function when completed
    # Get the title strings
    $resultstitles = $results[0] -split '\t'

    # Remove the titles from the results string, and trailing new line
    $results = $results[2..$results.Count]

    # Set up the results HashTables
    $resultstable = @()

    # Iterate through the results and turn into Powershell HashTables
    foreach($line in $results[2..$results.Count]){
        # Split the line based upon tabs
        $linesplit = $line -split "\t"

        # Setup a dictionary object
        $object = @{}

        # For each object in titles, associate with the incoming linesplit options
        for($i=0; $i -lt $resultstitles.Count; $i++){
            $object.Add($resultstitles[$i], $linesplit[$i])
        }

        $resultstable += $object

    }

    Write-Output $resultstable
}