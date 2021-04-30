# ThrowPhish
Using Terraform to Automate Cloud Deployment of multiple GoPhish environments. 

```
 _____ _                 _____ _   _     _
|_   _| |_ ___ ___ _ _ _|  _  | |_|_|___| |_
  | | |   |  _| . | | | |   __|   | |_ -|   |
  |_| |_|_|_| |___|_____|__|  |_|_|_|___|_|_|


Description: Creates and destroys GoPhish campaigns.
Usage: throwphish.sh [customer_name] [command]

customer_name:
 - customer name, matching name of config file in the config/ directory

command:
 - one of the following: createdns, createvm, destroy

command description

createdns - Creates Azure RG, prereq networking, and DNS Zone
            Returns a list of DNS Nameservers to be applied at the
            domain registrar prior to running 'createvm'

createvm  - Creates a LetsEncrypt certificate and the GoPhish VM

destroy   - Destroys all Azure resources created for the customer

ssh       - Connect to the GoPhish VM via SSH
```

## Using ThrowPhish

Check out the [blog post](https://nmanzi.com/blog/gophish-at-scale) or reach out to me on [twitter](https://twitter.com/hadricus).

### Prerequisites

You can run ThrowPhish on Windows (with [WSL](https://ubuntu.com/wsl)) or Linux.

You'll need to install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and run `az login` to get things ready for Terraform. ThrowPhish will take care of downloading the Terraform binary for you.

Other things you'll need:
- A domain name (create one with GoDaddy or any registrar)
- A SendGrid account
- An AzureAD Service Principal (create one with `az sp create-for-rbac --skip-assignment --name TerraformAcmeDNS`)

### Running ThrowPhish

ThrowPhish uses json-based configuration files representing a 'customer' to determine how to build the Azure resources.

In the `/config` folder of the repo you'll find `domain.json.example`

Edit the file and save the file as `<customername>.json` in the `/config` folder.

Run the following command from the repo folder, replacing `<customername>` with the name of the JSON file you created earlier (without the `.json` on the end, of course).

```bash
## Make the script executable
chmod +x throwphish.sh

## Run the first stage to prepare Azure Resource Group, DNS Zone, and Networking
./throwphish.sh <customername> createdns
```

This will take a little while, but once complete it'll spit out the nameserver FQDNs. Log into your registrar and configure the domain to use these nameservers - you might need to wait a couple hours before proceeding to Step 2 to allow the nameserver change to replicate through DNS.

When you're ready, run throwphish with the `createvm` parameter to complete the setup.

```bash
./throwphish.sh <customername> createvm
```

This does the following:
- Validates the domain, and creates a publicly-trusted SSL certificate for the GoPhish instance
- Creates the Azure VM, and installs/configures GoPhish

## Contact
Reach me on twitter [@hadricus](https://twitter.com/hadricus/)