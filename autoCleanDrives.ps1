### VARIABLES ###

#set absolute paths for drives to be cleaned
#can't see DFS links for several of these, so have done FQDN for fileserver instead. Fine until we change fileserver.
#add or remove drives to clean here.
$drives = @()
#set recipient for email output here.
$recipient='email here';
#Initialise output
$deletedDirs=@();
#Set path to log directory.
$logPath='C:\Temp\';
#set log directory name.
$logDir='cleanupLog\';
#set log file name.
$logFileName="cleanupLog_$((Get-date).ToString('yyyyMMdd')).log"

### CODE ###

#create logs folder if doesn't exist.
if (-not (Test-Path -Path $logPath$logDir)){
	New-Item -Path $logPath -ItemType Directory -Name $logDir
}
#create the log file if doesn't already exist.
if (-not (Test-Path -Path $logPath$logDir$logFileName)){
	New-Item -Path $logPath$logDir -ItemType File -Name $logFileName
}

$drives | ForEach-Object{
	#temporarily store drive we're working on
	$currentDrive = $_
	#initialize a failsafe
	$foundADUser = $False
	#Store drives that will be deleted at the end if failsafe is true
	$drivesToDelete = @();
	
	#For each drive in the list, check that drives do exist.
	#test-path returns true if exists
	if (Test-Path -Path $currentDrive){
		#gets names of directories in the specified location.
		#The | foreach will pipe the output into a for loop that repeats as many times as there are results.
		Get-ChildItem -path $currentDrive -name -attributes directory | foreach{
			#temporarily need to store the directory we're testing.
			$dirName = $_
			#check if an ad user of the same name exists
			#no proper function actually exists for this, so we just try to get the AD user, and catch the exception if thrown
			try{
				$user=Get-ADUser $dirName
				#does not need to be deleted if successful, so we turn off the failsafe, and do nothing else.
				"$dirName exists in AD" | Out-File -FilePath $logPath$logDir$logFileName -append;
				$foundADUser = $True;
			}
			catch{ 
				#If user doesn't exist, delete the drive and append to logs.
				
				$drivesToDelete+=$currentDrive+$dirName;
				"$currentDrive$dirName needs to be deleted" | Out-File -FilePath $logPath$logDir$logFileName -append;
			}
		}
		
		if ($foundADUser){
			#if the script found even a single AD object while iterating through the drive, we should be safe to delete the objects that don't exist in AD.
			$drivesToDelete | foreach{
				#Remove-Item -Path $_ -Recurse;
				"$_ has been deleted" | Out-File -FilePath $logPath$logDir$logFileName -append;
			}
			#add these now-deleted drives to the output.
			$deletedDirs+=$drivesToDelete;
		}
		else{
			"$currentDrive didn't delete anything as it failed to turn off the failsafe! Are you sure this drive contains AD objects?" | Out-File -FilePath $logPath$logDir$logFileName -append;
			"$currentDrive didn't delete anything as it failed to turn off the failsafe! Are you sure this drive contains AD objects?" | Out-File -FilePath $logPath$logDir$logFileName -append;
			"$currentDrive didn't delete anything as it failed to turn off the failsafe! Are you sure this drive contains AD objects?" | Out-File -FilePath $logPath$logDir$logFileName -append;
			"$currentDrive didn't delete anything as it failed to turn off the failsafe! Are you sure this drive contains AD objects?" | Out-File -FilePath $logPath$logDir$logFileName -append;
			"$currentDrive didn't delete anything as it failed to turn off the failsafe! Are you sure this drive contains AD objects?" | Out-File -FilePath $logPath$logDir$logFileName -append;
		}
	}
	else{
		#skip the path if it doesn't exist
		"$currentDrive was skipped as it doesn't exist." | Out-File -FilePath $logPath$logDir$logFileName -append;
	}
}
#Final output to log file
" " | Out-File -FilePath $logPath$logDir$logFileName -append;
"Folders to be deleted" | Out-File -FilePath $logPath$logDir$logFileName -append;
$deletedDirs | Out-File -FilePath $logPath$logDir$logFileName -append;

#once completed, send an email with the list of folders deleted.
$sendMailMessageSplat = @{
    From = 'email here'
    To = $recipient
    Subject = 'Drives autocleaned'
	Body = $deletedDirs | Out-String
	SmtpServer = 'smtp server here'
}
Send-MailMessage @sendMailMessageSplat


#If provided drive is a DFS namespace (try/catch 'get-dfsnroot -path $currentDrive')
#For each child item:
#$targetPath=(get-dfsnfoldertarget -path '\\contoso\homes\[user]' | select-object TargetPath).TargetPath
#The above line will get the target path for a home folder, ie output is "\\fileserver\homes\[user]
#Remove-DfsnFolderTarget -Path "$currentDrive$dirName" -TargetPath "$targetPath" -Force -Confirm:$false;
#Remove-Item -Path $targetPath -Recurse;
#"DFS link for $currentDrive$dirName was removed" | Out-File -FilePath $logPath$logDir$logFileName -append;
#"Corresponding folder $targetPath was removed" | Out-File -FilePath $logPath$logDir$logFileName -append;
