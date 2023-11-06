# aws sso login --profile login
# Import-Module AWS.Tools.SSO
# Import-Module AWS.Tools.SSOOIDC
# Import-Module AWS.Tools.EC2
# Import-Module AWS.Tools.Common

function Export-Ec2Instances{
    [CmdletBinding()]
    Param(
        [Parameter(Position=0,mandatory=$true)]
        [string] $outfile,

        [Parameter(Position=1,mandatory=$true)]
        [string[]] $regions
    )

    # Set working variables
    $profiles = Get-AWSCredential -ListProfileDetail
    $DesktopPath = [Environment]::GetFolderPath("Desktop")
    $date = Get-Date -Format "MM_dd_yyyy"
    $writeFile = "$($DesktopPath)\$($outfile)_$($date).csv"
    Write-Host "Writefile $writeFile" -ForegroundColor Red

    $headers = 'Profile,Instance_ID,nodeName,State,Region,OS,IP_Address,LaunchTime'
    Add-Content -LiteralPath $writeFile -Value $headers

    Foreach($profile in $profiles){
        $profileName = $profile.ProfileName
        Write-Host -ForegroundColor Green $profileName

        # Insert any exception profiles in the if statement below
        If($profileName -ne "login"){
            Foreach($region in $regions){
                $instances = $null # This resets the variable at every iteration

                try{
                    $instances = (Get-EC2Instance -Filter @{Name="instance-state-name";Values="running"} -Region $region -ProfileName $profileName).Instances | Select -Property *
                }
                catch{
                    
                }

                Foreach($instance in $instances){
                    $instance # Write output to console
                    $instanceId = $instance.InstanceId
                    $state = $instance.State.Name.Value
                    $os = $instance.PlatformDetails
                    $ip = $instance.PrivateIpAddress
                    $launchTime = $instance.LaunchTime

                    $row = "$profileName,$instanceId,$state,$region,$os,$ip,$launchTime"
                    Add-Content -LiteralPath $writeFile -Value $row
                }
            }
        }
    }
}
