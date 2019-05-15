$ErrorActionPreference = "Stop"
$DestDirForPhotos = "C:\BACKUP\TELEFON_DCIM_ALL"
$DestDirForVoiceRecordings = "C:\BACKUP\TELEFON_VOICE_RECORDINGS_ALL"


function Create-Dir($path)
{
  if(! (Test-Path -Path $path))
  {
    Write-Host "Creating: $path"
    New-Item -Path $path -ItemType Directory
  }
  else
  {
    Write-Host "Path $path already exist"
  }
}


function Get-SubFolder($parentDir, $subPath)
{
  $result = $parentDir
  foreach($pathSegment in ($subPath -split "\\"))
  {
    $result = $result.GetFolder.Items() | Where-Object {$_.Name -eq $pathSegment} | select -First 1
    if($result -eq $null)
    {
      throw "Not found $subPath folder"
    }
  }
  return $result;
}


function Get-PhoneMainDir($phoneName)
{
  $o = New-Object -com Shell.Application
  $rootComputerDirectory = $o.NameSpace(0x11)
  $phoneDirectory = $rootComputerDirectory.Items() | Where-Object {$_.Name -eq $phoneName} | select -First 1
    
  if($phoneDirectory -eq $null)
  {
    throw "Not found '$phoneName' folder in This computer. Connect your phone."
  }
  
  return $phoneDirectory;
}


function Get-FullPathOfMtpDir($mtpDir)
{
 $fullDirPath = ""
 $directory = $mtpDir.GetFolder
 while($directory -ne $null)
 {
   $fullDirPath =  -join($directory.Title, '\', $fullDirPath)
   $directory = $directory.ParentFolder;
 }
 return $fullDirPath
}



function Copy-FromPhone-ToDestDir($sourceMtpDir, $destDirPath)
{
 Create-Dir $destDirPath
 $destDirShell = (new-object -com Shell.Application).NameSpace($destDirPath)
 $fullSourceDirPath = Get-FullPathOfMtpDir $sourceMtpDir
 
 Write-Host "Copying from: '" $fullSourceDirPath "' to '" $destDirPath "'"
 
 $copiedCount = 0;
 
 foreach ($item in $sourceMtpDir.GetFolder.Items())
  {
   $itemName = ($item.Name)
   $fullFilePath = Join-Path -Path $destDirPath -ChildPath $itemName
   
   if(Test-Path $fullFilePath)
   {
      Write-Host "Element '$itemName' already exists"
   }
   else
   {
     $copiedCount++;
     Write-Host ("Copying #{0}: {1}{2}" -f $copiedCount, $fullSourceDirPath, $item.Name)
     $destDirShell.CopyHere($item)
   }
  }
  Write-Host "Copied '$copiedCount' elements from '$fullSourceDirPath'"
}



$phoneRootDir = Get-PhoneMainDir "Miagwuś"

$phoneVoiceRecorderSourceDir = Get-SubFolder $phoneRootDir "Phone\VoiceRecorder"
Copy-FromPhone-ToDestDir $phoneVoiceRecorderSourceDir $DestDirForVoiceRecordings

$phoneCardPhotosSourceDir = Get-SubFolder $phoneRootDir "Card\DCIM\Camera"
Copy-FromPhone-ToDestDir $phoneCardPhotosSourceDir $DestDirForPhotos

$phonePhotosSourceDir = Get-SubFolder $phoneRootDir "Phone\DCIM\Camera"
Copy-FromPhone-ToDestDir $phonePhotosSourceDir $DestDirForPhotos
