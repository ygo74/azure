$Debug = $true
Function Trace-Message
{
    param([string] $Message)
    
    if ($Debug)
    {
        #Write-Host $Message -ForegroundColor Magenta
        #Check why Verbose is not OK
        $VerbosePreference="Continue"
        Write-Verbose (("{0} : " -f [System.DateTime]::Now) + $Message)
    }
}


Function Trace-StartFunction
{
    [OutputType( [system.diagnostics.stopwatch] )]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.FunctionInfo] $InvocationMethod        
    )
    
    if ($Debug)
    {
        $watch = [system.diagnostics.stopwatch]::StartNew()         
        $Message = "Start {0}" -f $InvocationMethod.Name
        Trace-Message -Message $Message
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
    
    if ($Debug)
    {
        $Message = "End {0}" -f $InvocationMethod.Name
        if ($watcher -ne $null)
        {
           $watcher.Stop(); 
           $message += " => Completion Time : $($watcher.Elapsed)"    
        }
        Trace-Message -Message $Message
    }
}