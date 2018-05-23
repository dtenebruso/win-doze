#Grabs the path the script was run from; should always be in the folder downloaded from e-room
$masterPath=split-path $MyInvocation.MyCommand.path

## extracts all instances of (KB######) from the mbsacli3
$regex = '\(([KB[0-9-\s]+)\)'

## declaring all variables up here for a cleaner look
$path_to_catalog = Join-Path $masterPath "\catalog\wsusscn2.cab"
$path_to_foundupdates = Join-Path $masterPath "foundupdates.txt"
$path_to_extractedKBs = Join-Path $masterPath "extracted_kbs.txt"
$path_to_mbsacli = Join-Path $masterPath "\mbsacli.exe"

$input_path = $path_to_foundupdates
$output_file = $path_to_extractedKBs

##MAIN - Program starts here; As long as mbsacli.exe is in the Manual Update folder

$user_answer = Read-Host -Prompt "`n`nWhat would you like to do?`n`n1 == Scan this computer for updates`n`n2 == I've already downloaded the patches, install now"

If($user_answer -eq 1)
    {
        If(Test-Path $path_to_mbsacli)
            {
                Write-Host "`n`n'mbsacli' is already installed`n" -ForegroundColor Yellow;
                Write-Host "-------------------------------`nChecking for missing patches...`n-------------------------------" -ForegroundColor Green  
            }
            else 
            {
                
                Write-Host "`n`n'mbsacli' is NOT in the folder`nPlease re-download the Manual Update folder...`n`nIf this issue persists, contact Dylan" -ForegroundColor Red
                EXIT
            }
        
        Write-Host "`n`nStarting MBSA scanning process`n`nThis may take up to 30 minutes depending on the specs of the host PC`n" -ForegroundColor Yellow
        
        # leveraging CMD to run the mbsacli client
        & $path_to_mbsacli /xmlout /wi /nvc /catalog $path_to_catalog > $path_to_foundupdates
        
        Write-Host "`n`n-----------------------`nWriting KB's to file...`n-----------------------" -ForegroundColor Green
        
        # use regex to find all KB numbers in the following format: (KB######)  : output all found strings to the extracted_kbs.txt file
        select-string -Path $input_path -Pattern $regex -AllMatches | %{$_.Matches}|%{$_.Value} > $output_file
        
        # launch notepad with the extracted KB's
        Start-Process 'C:\Windows\system32\Notepad.exe\' $path_to_extractedKBs
        
        Set-ExecutionPolicy Restricted -Force
        
        Write-Host "`n`nAll tasks have completed successfully`n`n" -ForegroundColor Green
    }
    else
    {
        Write-Host "works"

        ###Fix this so that it looks in the correct directory and runs right!
        <#
        $dir = (Get-Item -Path ".\" -Verbose).FullName
        Foreach($item in (ls $dir *.msu -Name))
        {
            echo $item
            $item = $dir + "\" + $item
            wusa $item /quiet /norestart | Out-Null
        }
        
        #>
    }
