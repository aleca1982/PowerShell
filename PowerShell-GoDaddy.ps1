﻿# Configuration
$domain = 'yourdomain.com'       # Replace with your domain
$recordName = 'subdomain'        # Replace with the A record to update (use '@' for the root domain)
$apiKey = 'your_api_key'         # Replace with your GoDaddy API key
$apiSecret = 'your_api_secret'   # Replace with your GoDaddy API secret

# Headers for API authentication
$headers = @{
    Authorization = "sso-key $($apiKey):$($apiSecret)"
}

# Get current public IP address
$currentIP = Invoke-RestMethod -Uri "https://api.ipify.org"

# Retrieve existing DNS record
$dnsRecord = Invoke-RestMethod -Method Get -Uri "https://api.godaddy.com/v1/domains/$domain/records/A/$recordName" -Headers $headers

# Check if update is needed
if ($dnsRecord.data -ne $currentIP) {
    # Prepare the updated DNS record
    $updatePayload = @(
        @{
            data = $currentIP
            ttl = 600  # Time to live in seconds
        }
    ) | ConvertTo-Json

    # Update the DNS record
    Invoke-RestMethod -Method Put -Uri "https://api.godaddy.com/v1/domains/$domain/records/A/$recordName" -Headers $headers -Body $updatePayload -ContentType "application/json"

    Write-Output "DNS record updated to $currentIP"
} else {
    Write-Output "No update needed; DNS record is current."
}