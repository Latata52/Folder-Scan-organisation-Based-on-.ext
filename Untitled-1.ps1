
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
                        FileExt
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
        }
        else{
            Write-Output "File Path provided is invalid"
            $Retry=1
        }
    }
}

Function FileExt
{
    $FileScan = Get-ChildItem -LiteralPath $FilePath -File    
    $Extensions = $FileScan |
        Select-Object -ExpandProperty Extension |
        Where-Object { $_ } |
        Sort-Object -Unique
    ContainerCreation
}

Function ContainerCreation
{
    $LoopContainer = 1
    While($LoopContainer -eq 1)
    {
        $Container = Read-Host "Please enter the name of the Parent Container Folder"
        if(!(Test-Path -LiteralPath $Filepath/$Container -PathType Container ))
        {
            $ConfirmFile=Read-Host "Are you sure you want to create $ContainerPath (y/n)"
                switch($ConfirmFile)
                {
                    n
                    { 
                        $LoopContainer=1
                    }
                    y
                    {
                        New-Item -Path "$FilePath/$Container" -ItemType Directory
                        $ContainerPath = Join-Path -Path $FilePath -ChildPath $Container
                        ForEach($Extension in $Extensions)
                        {
                            $FolderName = $Extension.TrimStart('.')
                            $ChildPath = Join-Path -Path $ContainerPath -ChildPath $FolderName
                            if (!(Test-Path -LiteralPath $ChildPath -PathType Container))
                            {
                                New-Item -Path $ChildPath -ItemType Directory
                            }
                        }
                        $LoopContainer=0
                        #move Script
                    }
                    Default 
                    {
                        Write-Host "invalid input"
                        $LoopContainer=1
                    }
                }
        }
        elseif(Test-Path -LiteralPath $Filepath/$Container -PathType Container)
        {
            $ConfirmFile=Read-Host "The File $FilePath/$Container has already been created, do you want to use it?(y/n)"
            switch($ConfirmFile)
                {
                    n
                    { 
                        $LoopContainer=1
                    }
                    y
                    {
                        $ContainerPath = Join-Path -Path $FilePath -ChildPath $Container
                        ForEach($Extension in $Extensions)
                        {
                            $FolderName = $Extension.TrimStart('.')
                            $ChildPath = Join-Path -Path $ContainerPath -ChildPath $FolderName
                            if (!(Test-Path -LiteralPath $ChildPath -PathType Container))
                            {
                                New-Item -Path $ChildPath -ItemType Directory
                            }
                        }
                        $LoopContainer=0
                        #move Script
                    }
                    Default 
                    {
                        Write-Host "invalid input"
                        $LoopContainer=1
                    }
                }
            }
        else 
        {
            Write-Host "Input is invalid please try again"
        }
    #Name The Top Parent Container
    #Built Child Containers based on $Extension
    }    
}

# Function Move Script
Function MoveContainer
{
    
}
# Generate Report within Console & in txt File
function Invoke-start 
{
    Write-Host "When specying a path to another drive, ensure to specify the letter."
    Write-Host "Example: D:\home\user\ta000025"
    Write-host "********************************************************************"
    PathVerification
}

Invoke-start

