
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
                        New-Item -Path "$FilePath/$Container" -ItemType Directory | Out-Null
                        $ContainerPath = Join-Path -Path $FilePath -ChildPath $Container
                        ForEach($Extension in $Extensions)
                        {
                            $FolderName = $Extension.TrimStart('.')
                            $ChildPath = Join-Path -Path $ContainerPath -ChildPath $FolderName
                            if (!(Test-Path -LiteralPath $ChildPath -PathType Container))
                            {
                                New-Item -Path $ChildPath -ItemType Directory | Out-Null
                            }
                        }
                        $LoopContainer=0
                        MoveContainer
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
                                New-Item -Path $ChildPath -ItemType Directory | Out-Null
                            }
                        }
                        $LoopContainer=0
                        MoveContainer
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
    $MoveCount = 0
    ForEach ($File in $FileScan)
    {
    $Extension = $File.Extension.TrimStart('.')
    $DestinationMove = Join-Path -Path $ContainerPath -ChildPath $Extension

           try
        {
            Move-Item -LiteralPath $File.FullName -Destination $DestinationMove -ErrorAction Stop | Out-Null

            $MoveCount++
        }
        catch
        {
            Write-Warning "Failed to move $($File.Name)"
        }
    }
    OrganiseMedia 
}
Function OrganiseMedia
{
    $Categories = 
    @{
    ".txt" = "TextFiles"
    ".jpg" = "Images"
    ".pdf" = "PDFs"
    }

    $DestinationOrganisation = Join-Path -Path $ContainerPath -ChildPath $FolderName     
    Foreach ($Extension in $Extensions)
    {
        $FolderName = $Extension.TrimStart('.')

        $ChildPath = Join-Path -Path $ContainerPath -ChildPath $FolderName
         if ($Categories.ContainsKey($Extension))
        {
            $FolderName = $Categories[$Extension]
        }
        else
        {
            $FolderName = "UnknownFiles"
        }

        $DestinationOrganisation = Join-Path -Path $ContainerPath -ChildPath $FolderName

        New-Item -ItemType Directory -Path $DestinationOrganisation -Force | Out-Null

        Move-Item -LiteralPath $ChildPath -Destination $DestinationOrganisation | Out-Null
    }
    GenerateReport

}

Function GenerateReport
{
    $ComputerName = $env:COMPUTERNAME
    $User = $env:USERNAME
    $DateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Workgroup = (Get-CimInstance Win32_ComputerSystem).Workgroup
    Get-NetIPConfiguration |
Where-Object { $_.IPv4DefaultGateway } |
Select-Object -First 1 -ExpandProperty IPv4Address |
Select-Object -ExpandProperty IPAddress
    $FileScanCount = $FileScan.Count
    $FileTypeCount = $Extensions.Count

    $ReportPath = Join-Path -Path $ContainerPath -ChildPath "Report.txt"
    
    Write-Host "Summary of Operations"
    $Report= @" 
    The Computer Name is $ComputerName
    The current username is $User
    The current Time an date is $DateTime
    The Current Workgroup is $Workgroup
    The current Ip is $IPv4
    The amount of files scanned is $FileScanCount
    The amount of Extensions scanned is $FileTypeCount
    The amount of files moved is $MoveCount
    This report will be contained in $ReportPath
"@
    $Report | Out-File -FilePath $ReportPath -Encoding utf8
    Write-Host $Report

   # ContainerPath
}
# Generate Report within Console & in txt File
function Invoke-start 
{
    Write-Host "When specying a path to another drive, ensure to specify the letter."
    Write-Host "Example: D:\home\user\example drive"
    Write-host "********************************************************************"
    PathVerification
}

Invoke-start

