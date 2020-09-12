# powershell-mtp-file-transfer
Powershell script to copy files/folders from the Android phone connected to Windows PC.
Uses `Shell.Application` object to interact with Windows explorer API to copy from device connected via MTP Protocol

Sometimes the  `Shell.Application` doesn't detect all files unless the folder on phone to be backed up was opened in Windows Explorer previously
