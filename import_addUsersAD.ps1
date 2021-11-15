# Start transcript
Start-Transcript -Path C:\Temp\Add-ADUsers-Multi2.log -Append

@("a;b;c") + (Get-Content "C:\Temp\test.csv") | Set-Content "C:\Temp\test1.csv"

# Import AD Module
Import-Module ActiveDirectory

function importUser{
    # Import the data from CSV file and assign it to variable (For Importing Users)
    Import-Csv "C:\Temp\test1.csv" -Delimiter ';' |

    # Import New Users
    ForEach-Object{
        # Retrieve UserSamAccountName and ADGroup
        $UserSam = $_.c
        # Retrieve SamAccountName and ADGroup
        $ADUser = Get-ADUser -Filter * | Select-Object Name

        # User does not exist in AD
        if ($ADUser -ne $null) {
            Write-Host "$UserSam has been added in AD" -ForegroundColor Red
        }
        else{
            # Import User to AD
            New-ADUser -Name $_.c
            Write-Host "Added $UserSam to AD" -ForeGroundColor Green
        }
    }
}

function addUser{
    # Import the data from CSV file and assign it to variable (For Adding Users into Group)
    Import-Csv "C:\Temp\test1.csv" -Delimiter ';' |
    
    ForEach-Object {
        # Retrieve UserSamAccountName and ADGroup
        $UserSam = $_.c
        $Groups = $_.b
    
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

importUser
addUser

Stop-Transcript 