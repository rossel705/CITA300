# Import active directory module for running AD cmdlets
Import-Module ActiveDirectory
  
#Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Import-csv "C:\Users\rossel705\Desktop\bulk_users1.csv"

#Loop through each row containing user details in the CSV file 
foreach ($User in $ADUsers)
{
	#Read user data from each field in each row and assign the data to a variable as below
		
	$Username 	= $User.username
	$Password 	= $User.password
	$Firstname 	= $User.firstname
	$Lastname 	= $User.lastname
	$OU 		= $User.ou #This field refers to the OU the user account is to be created in
    $email      = $User.email
    $telephone  = $User.telephone
    $jobtitle   = $User.jobtitle
    $department = $User.department
    $Password = $User.Password


	#Check to see if the user already exists in AD
	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 #If user does exist, give a warning
		 Write-Warning "A user account with username $Username already exist in Active Directory."
	}
	else
	{
		#User does not exist then proceed to create the new user account
		
        #Account will be created in the OU provided by the $OU variable read from the CSV file
		New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@team2.local" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -DisplayName "$Lastname, $Firstname" `
            -Path $OU `
            -OfficePhone $telephone `
            -EmailAddress $email `
            -Title $jobtitle `
            -Department $department `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force)      
    }
    Write-Host $OU
    New-Item "C:\Parent-Directory\$Username" -type Directory

    $sharepath = "C:\Parent-Directory\$Username\"

    New-SmbShare -Name $Username -path $sharepath -FullAccess "team2\IT", "team2\Offices" -ReadAccess "team2\$Username"

    if ((Get-PSSnapin -Name MailEnable.Provision.Command -ErrorAction SilentlyContinue) -eq $null)
    {
        Add-PSSnapin MailEnable.Provision.Command
    }
    New-MailEnableMailbox -Mailbox "$Username" -Domain "team2.local" -Password "$Password" -Right "USER"

    $From = "rossel705@team2.local"
    $To = "$Username@team2.local"
    $Subject = "Welcome"
    $Body = "Welcome to the team! Your username is $Username and password is $Password"
    $SMTPserver = "team2.local"
    $SMTP = "587"
    $Credential = New-Object System.Management.Automation.PSCredential($From, $Password)
    Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Credential $Credential -SmtpServer $SMTPserver -Port $SMTP

    New-Item -Path "C:\Users\rossel705\Documents\newuser.txt" 

    $email1 = "Username"
    $email2 = $Username
    $email1 >> C:\userlist.txt
    $email2 >> C:\userlist.txt 
    $email3 = "Password"
    $email4 = $Password
    $email3 >> C:\userlist.txt
    $email4 >> C:\userlist.txt

    Send-MailMessage -From $From -To $From -Subject "New Users" -Attachments $email1 -Body "New Users" -SmtpServer $SMTPserver -Port $SMTP
}


