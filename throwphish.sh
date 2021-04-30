#!/bin/bash
set -e

# TODO: Command to open SSH session to server

customer="$1"
command="$2"
config_path="$(pwd)/config/$customer.json"
state_path="state/$customer.tfstate"

tfversion="0.12.9"

function banner() {
  echo
  echo " _____ _                 _____ _   _     _   "
  echo "|_   _| |_ ___ ___ _ _ _|  _  | |_|_|___| |_ "
  echo "  | | |   |  _| . | | | |   __|   | |_ -|   |"
  echo "  |_| |_|_|_| |___|_____|__|  |_|_|_|___|_|_|"
  echo    
}

function usage() {
  echo "Description: Creates and destroys GoPhish campaigns."
  echo "Usage: throwphish.sh [customer_name] [command]"
  echo
  echo "customer_name:"
  echo " - customer name, matching name of config file in the config/ directory"
  echo
  echo "command:"
  echo " - one of the following: createdns, createvm, destroy"
  echo
  echo "command description"
  echo
  echo "createdns - Creates Azure RG, prereq networking, and DNS Zone"
  echo "            Returns a list of DNS Nameservers to be applied at the"
  echo "            domain registrar prior to running 'createvm'"
  echo
  echo "createvm -  Creates a LetsEncrypt certificate and the GoPhish VM"
  echo
  echo "destroy -   Destroys all Azure resources created for the customer"
}

# Ensure script console output is separated by blank line at top and bottom to improve readability
trap echo EXIT
echo

# Display the banner
banner

# Validate the input arguments
if [ "$#" -lt 2 ]; then
  echo
  echo "ERROR: Invalid number of parameters"
  echo
  usage
  exit 1
fi

# Check the customer config exists
if [[ ! -e "$config_path" ]]; then
  echo
  echo "ERROR: $config_path not found, please create this before running this script..."
  echo
  exit 1
fi

# Generate backend.tf config if not already present
if [[ ! -e "backend.tf" ]]; then
  echo "Backend configuration not found, generating now..."
  cleanup_backend=0
  cat <<- EOF > backend.tf
    terraform {
      backend "local" { }
    }
EOF
fi

# Install terraform if it's not installed already
if ! (./terraform --version | head -n 1 | grep $tfversion) > /dev/null 2>&1; then
  if [[ "`uname`" == "Darwin" ]]; then
    bin="darwin_amd64"
  else
    bin="linux_amd64"
  fi

  curl https://releases.hashicorp.com/terraform/$tfversion/terraform_${tfversion}_${bin}.zip > terraform.zip
  unzip -o terraform.zip
  rm terraform.zip
  chmod +x terraform
fi

# Configure remote state storage, if the state isn't already there
if [[ ! -e "$state_path" ]]; then
  ./terraform init -backend-config="path=$state_path"
fi

# Run command
case "$command" in
  createdns)
    echo
    echo "Building Azure RG, network, and DNS Zone."
    echo "Please wait..."
    echo
    ./terraform apply -var-file=$config_path -target=module.create_networking -target=module.create_dns
    if [ $? -eq 0 ]; then
      echo
      echo "###########################################################"
      echo "##  Please update the domain to use the list of          ##"
      echo "##  nameservers specified above, then wait 15 minutes    ##"
      echo "##  before proceeding to run the following command:      ##"
      echo "###########################################################"
      echo
      echo "COMMAND: ./throwphish.sh $customer createvm"
      touch state/.$customer-dnscomplete
      exit 0
    else
      echo
      echo "Terraform failed to complete, check log above for details"
      echo
      exit 1
    fi
    ;;
  createvm)
    if [[ ! -e "state/.$customer-dnscomplete" ]]; then
      echo "Backend configuration not found, generating now..."
    fi
    echo
    echo "Creating LetsEncrypt certificate and building GoPhish VM."
    echo "Please wait..."
    echo
    ./terraform apply -var-file=$config_path -target=module.create_letsencrypt_cert -target=module.phishing_server
    if [ $? -eq 0 ]; then
      echo
      echo "###########################################################"
      echo "##  Build complete! Use the output above for details.    ##"
      echo "##  Use the following command to destroy resources when  ##"
      echo "##  the campaign ends.                                   ##"
      echo "###########################################################"
      echo
      echo "COMMAND: ./throwphish.sh $customer destroy"
      exit 0
    else
      echo
      echo "Terraform failed to complete, check log above for details"
      echo
      exit 1
    fi
    ;;
  destroy)
    echo
    echo "Are you sure you want to destroy all GoPhish resources for this customer?"
    read -p "Continue (y/n)?" choice
    case "$choice" in 
      y|Y ) echo "Please wait...";;
      * ) echo "Aborting."; exit 0;;
    esac
    ./terraform destroy -var-file=$config_path
    rm state/.$customer-dnscomplete
    ;;
  ssh)
    serverip="$(terraform output -json | jq '.server_ip.value' | cut -d$'\n' -f2 | cut -d'"' -f2)"
    ssh -i ./ssh_keys/phishing_server_$customer gophishadm@$serverip
    ;;
  *)
    echo "Invalid command $command specified."
    usage
    ;;
esac