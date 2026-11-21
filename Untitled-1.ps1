
Function PathVerification
{
    $Retry =1
    While($Retry -eq 1)
    {
        Write-Host "If you want to terminate the process, type end"
        $FilePath = Read-Host "Please enter a valid Folder Path to be scanned" 
        if ($FilePath -eq "")
        {
            $FilePath=$PWD
        }
        if (Test-Path -LiteralPath "$FilePath" -PathType container)
            {
            Write-Output "File Path Provided, $FilePath , is valid"
            $ConfirmFile=Read-Host "Are you sure you want to scan $Filepath (y/n)"
                switch($ConfirmFile){
                    n
                    { 
                        $Retry=1
                    }
                    y
                    {
                        $Retry=0
                        FileScan
                    }
                    Default 
                    {
                        Write-Host "invalid input"
                        $Retry=1
                    }
                }
            }
        elseif ($FilePath -eq "end")
        {
            Write-Output "Ending Process"
            $Retry=0
            exit
        }
        else{
            Write-Output "File Path provided is invalid"
            $Retry=1
        }
    }
}

Function FileScan
{
    Get-ChildItem -LiteralPath $FilePath -File | Select-Object -Property Name, Extension
}
function Invoke-start 
{
    Write-Host "When specying a path to another drive, ensure to specify the letter."
    Write-Host "Example: D:\home\user\ta000025"
    Write-host "********************************************************************"
    PathVerification
}

Invoke-start

