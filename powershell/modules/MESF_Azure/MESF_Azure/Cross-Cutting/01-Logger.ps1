$script:Debug   =   $false
$script:Verbose = $false
Function Trace-Message
{
    param(
        [string] $Message,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.FunctionInfo] $InvocationMethod
    )

    if ($Verbose)
    {
        #Write-Host $Message -ForegroundColor Magenta
        #Check why Verbose is not OK
        $VerbosePreference="Continue"

        $commandName = "N/A"
        if ($null -ne $InvocationMethod) {$commandName = $InvocationMethod.Name}

        Write-Verbose (("{0} - {1} : " -f [System.DateTime]::Now, $commandName) + $Message)
    }
}


Function Trace-StartFunction
{
    [OutputType( [system.diagnostics.stopwatch] )]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.FunctionInfo] $InvocationMethod
    )

    if ($Verbose)
    {
        $watch = [system.diagnostics.stopwatch]::StartNew()
        Trace-Message -Message "Start" -InvocationMethod $InvocationMethod
        return $watch
    }
}

Function Trace-EndFunction
{
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.FunctionInfo] $InvocationMethod,

        [Parameter(Mandatory = $false)]
        [System.Diagnostics.Stopwatch] $watcher
    )

    if ($Verbose)
    {
        $Message = "End"
        if ($null -ne $watcher)
        {
           $watcher.Stop();
           $message += " => Completion Time : $($watcher.Elapsed)"
        }
        Trace-Message -Message $Message -InvocationMethod $InvocationMethod
    }
}

Function Debug-Message
{
    param(
        [string] $Message,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.FunctionInfo] $InvocationMethod
    )

    if ($Debug)
    {
        #Write-Host $Message -ForegroundColor Magenta
        #Check why Verbose is not OK
        $VerbosePreference="Continue"

        $commandName = $InvocationMethod.Name

        Write-Verbose (("{0} - {1} : DEBUG => " -f [System.DateTime]::Now, $commandName) + $Message)
    }
}

Function Enable-MESF_AzureVerbose
{
    $script:Verbose = $true
}

Function Enable-MESF_AzureDebug
{
    $script:Debug = $true
    $script:Verbose = $true
}

Function Disable-MESF_AzureVerbose
{
    $script:Verbose = $false
}

Function Disable-MESF_AzureDebug
{
    $script:Debug = $false
    $script:Verbose = $false
}

