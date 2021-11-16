# Start transcript
Start-Transcript -Path C:\Temp\Import-ADUsers.log -Append

@("a,b,c") + (Get-Content "C:\Temp\test.csv") | Set-Content "C:\Temp\test1.csv"

# Import AD Module
Import-Module ActiveDirectory

# Import the data from CSV file and assign it to variable (For Adding Users into Group)
Import-Csv "C:\Temp\test1.csv" -Delimiter ',' |

ForEach-Object {
    # Retrieve UserSamAccountName and ADGroup
    $UserSam = $_.c
    $Groups = $_.b
    $Command = $_.a
    $add = 'add'
    $delete = 'delete'

    # Retrieve SamAccountName and ADGroup
    $ADUser = Get-ADUser -Filter * | Select-Object Name
    $ADGroups = Get-ADGroup -Filter * | Select-Object Name

    # User does not exist in AD
    if ($ADUser -eq $null) {
        Write-Host "$UserSam does not exist in AD" -ForegroundColor Red
        Continue
    }
    # User does not have a group specified in CSV file
    if ($Groups -eq $null) {
        Write-Host "$UserSam has no group specified in CSV file" -ForegroundColor Yellow
        Continue
    }
    # Retrieve AD user group membership
    $ExistingGroups = Get-ADPrincipalGroupMembership $UserSam | Select-Object Name

    if ($Command -match $delete){
        foreach ($Group in $Groups.Split(';')) {
            # Group does not exist in AD
            if ($ADGroups.Name -notcontains $Group) {
                Write-Host "$Group group does not exist in AD" -ForegroundColor Red
                Continue
            }
             # Add user to group
             Remove-ADGroupMember -Identity $Group -Members $UserSam -Confirm:$false
             Write-Host "Deleted $UserSam to $Group" -ForeGroundColor Green
        }
    }
    elseif ($Command -match $add){
        foreach ($Group in $Groups.Split(';')) {
            # Group does not exist in AD
            if ($ADGroups.Name -notcontains $Group) {
                Write-Host "$Group group does not exist in AD" -ForegroundColor Red
                Continue
            }
            # User already member of group
            if ($ExistingGroups.Name -eq $Group) {
                Write-Host "$UserSam already exists in group $Group" -ForeGroundColor Yellow
            } 
            else {
                # Add user to group
                Add-ADGroupMember -Identity $Group -Members $UserSam
                Write-Host "Added $UserSam to $Group" -ForeGroundColor Green
            }
        }
    }

    
}
Stop-Transcript