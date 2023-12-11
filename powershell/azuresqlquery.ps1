#import sql in powershell

import-Module SQLPS -DisableNameChecking
#Get the size of each database
$sendermail = ''
$receivermail = ''
$smtpserver = 'smtp.gmail.com'
$smtpport = '587'

function Get-Databasedetails{

Connect-AzAccount
#empty output object
$DataOut = @()

#get the a verified Azure Subscription to the services 

$Subscription = Get-AzSubscription | Out-GridView -OutputMode 'Single'
if($Subscription){
    $Subscription | Select-AzSubscription
    #Get Azure Sql Servers Available with a grid-view

    $AzSqlServer = Get-AzSqlServer | Out-GridView -OutputMode Multiple
    if($AzSqlServer)
    {
        Foreach ($server in $AzSqlServer)
        {
            $SQLDatabase = Get-AzSqlDatabase -ServerName $server.ServerName -ResourceGroupName $server.ResourceGroupName | Where-Object { $_.DatabaseName -notin $IgnoreDB }
            Foreach ($database in $SQLDatabase)
            {
                $db_resource = Get-AzResource -ResourceId $database.ResourceId

                # Database maximum storage size
                $db_MaximumStorageSize = $database.MaxSizeBytes / 1GB

                # Database used space
                $db_metric_storage = $db_resource | Get-AzMetric -MetricName 'storage'
                $db_UsedSpace = $db_metric_storage.Data.Maximum | Select-Object -Last 1
                $db_UsedSpace = [math]::Round($db_UsedSpace / 1GB, 2)

                # Database used space procentage
                $db_metric_storage_percent = $db_resource | Get-AzMetric -MetricName 'storage_percent'
                $db_UsedSpacePercentage = $db_metric_storage_percent.Data.Maximum | Select-Object -Last 1

                # Database allocated space
                $db_metric_allocated_data_storage = $db_resource | Get-AzMetric -MetricName 'allocated_data_storage'
                $db_AllocatedSpace = $db_metric_allocated_data_storage.Data.Average | Select-Object -Last 1
                $db_AllocatedSpace = [math]::Round($db_AllocatedSpace / 1GB, 2) 

                # Database VCore
                $db_VCoreMin = $db.MinimumCapacity
                $db_VCoreMax = $db.Capacity

                #Genrate ouytput object

                $Report = New-Object PSObject
                $Report | Add-Member -Name "ServerName" -MemberType NoteProperty -Value $server.ServerName
                $Report | Add-Member -Name "DatabaseName" -MemberType NoteProperty -Value $database.DatabaseName
                $Report | Add-Member -Name "UsedSpace" -MemberType NoteProperty -Value $db_UsedSpace
                $Report | Add-Member -Name "UsedSpaceProcentage" -MemberType NoteProperty -Value $db_UsedSpacePercentage
                $Report | Add-Member -Name "AllocatedSpace" -MemberType NoteProperty -Value $db_AllocatedSpace
                $Report | Add-Member -Name "MaximumStorageSize" -MemberType NoteProperty -Value $db_MaximumStorageSize
                $Report | Add-Member -Name "MinvCores" -MemberType NoteProperty -Value $db_VCoreMin
                $Report | Add-Member -Name "MaxvCores" -MemberType NoteProperty -Value $db_VCoreMax
                $DataOut += $Report

            }
        }
       
    }
}
}




#Get the databses status and save to csv file
Get-Databasedetails
$DataOut | ConvertTo-Xml | Out-File C:\PowerShell\Reports\Databases.Xml

#Send an email to the amdin
Send-MailMessage -to $sendermail -from $receivermail -Subject "DB Status" -SmtpServer $smtpserver -port $smtpport -Attachments "C:\PowerShell\Reports\Databases.Xml"



