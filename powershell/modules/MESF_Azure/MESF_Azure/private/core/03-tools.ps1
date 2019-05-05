Function Get-ParamsFromObjectToCommand
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$CommandName,

        [Parameter(Mandatory=$true)]
        [Object]$Object

    )
    Process
    {
        #Retrieve the command
        $command = Get-Command -Name $CommandName

        #Find parameters
        $commandParams = $command.Parameters.Keys

        $params = @{}
        if ($Object -is [System.Collections.Hashtable]) {
            $Object.Keys | ForEach-Object {
                #Test if object params can be pass to the command
                if ($_ -notin $commandParams) {

                    Debug-Message ("Object parameters '{0}' doesn't belong to command arguments" -f $_) -InvocationMethod $MyInvocation.MyCommand
                    #return -eq Continue in a ForEach-Object cmdlet
                    return
                }
                $params.Add($_, $Object[$_])
            }
        }
        Write-Output $params
    }
}
