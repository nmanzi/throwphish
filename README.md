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

createvm -  Creates a LetsEncrypt certificate and the GoPhish VM

destroy -   Destroys all Azure resources created for the customer
```

## Using ThrowPhish

Check out the [blog post](https://nmanzi.com/blog/gophish-at-scale) or reach out to me below.

## Contact
Reach me on twitter [@hadricus](https://twitter.com/hadricus/)