#!/bin/bash

function createNamespace() {
  ns=$1

  # verify that the namespace exists
  ns=`kubectl get namespace $1 --no-headers --output=go-template={{.metadata.name}} 2>/dev/null`
  if [ -z "${ns}" ]; then
    echo "Namespace (${1}) not found, creating namespace"
    kubectl create namespace "${1}"
  else echo "Namespace (${1})" exists, skipping namespace creation
  fi
}

function validate() {
  if [ $? -ne 0 ]; 
  then
      echo "$1 deployment failed in namespace $2. Exiting !!!"
      exit 1
  else
      echo "$1 deployment in namespace $2 successful !!!"    
  fi
}

function validateAndPrint() {
  if [ $? -ne 0 ]; 
  then
      echo "$1 !!! Exiting !!!"
      exit 1   
  fi
}

function validateIPAddressRange() {
  local  ip=$1
  local  stat=1

  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,3}$ ]];
  then
      OIFS=$IFS
      IFS='.'
      ip=($ip)
      IFS=$OIFS
      part3=$(cut -d'/' -f1 <<< ${ip[3]})
      part4=$(cut -d'/' -f2 <<< ${ip[3]})
      [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
          && ${ip[2]} -le 255 && $part3 -le 255 && $part4 -le 255 ]]

      if [ $? = 1 ];
      then
          echo "not valid"
          exit 1
      fi
  else
      echo "$ip is not a valid IP"
      exit 1
  fi
}

function validateCertificateStatus() {
  counter=1
  cert_creation_status="False"

  while [[ $counter -le 20 && "$cert_creation_status" = "False" ]];
  do
    cert_creation_status=$(kubectl -n istio-system get certificate istio-ingressgateway-certs -o jsonpath='{.status.conditions[0].status}')
    if [ "$cert_creation_status" = "True" ]; then
      echo "Certificate is in ready status"
    else
      echo "Certificate not in ready status yet, sleep for 10 more seconds"
      echo "${counter} iteration check for certificate ready status"
      sleep 10
    fi
    counter=$((counter+1))
  done

  if [ $counter -gt 20 ];
  then
    echo "Certification creation failed !! Exiting "
    cert_failure_reason=$(kubectl -n istio-system get certificaterequest -o json | jq -r '.items[0].status.conditions[0].message')
    echo "Cert Creation request failed with error: $cert_failure_reason"
    cert_failure_reason=$(kubectl -n istio-system get order -o json | jq -r '.items[0].status.reason')
    echo "Cert Order request failed with error: $cert_failure_reason"
    exit 1
  fi
}

function validateStorageClass() {
  counter=1
  storage_class_found="False"

  while [[ $counter -le 20 && "$storage_class_found" = "False" ]];
  do
    storage_counter=$(kubectl get storageclass | grep default | wc -l)
    if [ ! $storage_counter -gt 0 ]; then
      echo "Default storageClass not yet created, sleep for 10 more seconds"
      echo "${counter} iteration check for storageClass creation status"
      sleep 10
    else
      storage_class_found="True"
    fi
    counter=$((counter+1))
  done

  if [ $counter -gt 20 ];
  then
    echo "For the KotsAdmin installation to work default storageClass has to be set. Exiting !!"
    exit 1
  fi
}

function validateEmptyParam() {
    if [ ! -z "$1" ]
    then
      echo "$1 is empty..$2 Exiting !!"
      exit 1
    fi
}

#StartTime
start=`date +%s`
echo $@ >> consoleOutput.txt

#download artifacts and unzip
wget https://github.com/UiPath/ai-customer-scripts/raw/master/platform/aks/aks-arm.zip
unzip aks-arm.zip
cd aks-arm

  #install kubectl  
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"  
chmod +x ./kubectl  
mv ./kubectl /usr/local/bin/kubectl

vnet_flag=false
orchestrator_rg=false
peering_flag=false
expose_kots=false
zonal_cluster=false

while getopts ":g:k:d:c:s:p:e:z:O:V:P" opt; do  
  case $opt in
    g)  
      echo "Worker Resource Group is $OPTARG"
      RESOURCEGROUP=$OPTARG
      ;; 
    k)  
      echo "AKS Cluster name is $OPTARG"
      AKSCLUSTERNAME=$OPTARG
      ;;  
    d)  
      echo "DNS Prefix is $OPTARG"  
      DNSNAME=$OPTARG
      ;;
    c)  
      echo "KOTS channel is $OPTARG"  
      KOTS_CHANNEL=$OPTARG
      ;;
    s)  
      #echo "SQL user $OPTARG"  
      SQL_USERNAME=$OPTARG
      ;;
    p)  
      #echo "SQL Password is $OPTARG"  
      SQL_PASSWORD=$OPTARG
      ;;
    e)
      echo "Expose Kots via Public IP/LoadBalancer is $OPTARG"
      if [ $OPTARG = "Yes" ] ;
        then      
      	expose_kots=true;
      fi
      ;;
    z)
      echo "Zonal Cluster $OPTARG"
      zonal_cluster=$OPTARG
      ;;
    O)  
      echo "VNET Peering Target Resource Group is $OPTARG"  
      ORCH_RG=$OPTARG
      orchestrator_rg=true
      ;; 
    V)  
      echo "VNET Peering target name is $OPTARG"  
      ORCH_VNET=$OPTARG
      vnet_flag=true
      ;;  
    P)  
      echo "VNET Peering is enabled"  
      peering_flag=true
      ;;   
    \?)  
      echo "Invalid option: -"$OPTARG"" >&2
      echo "Plz remove the options that are not valid"
      exit 1
      ;;     
  esac  
done

#Defaulting namespace to aifabric
NAMESPACE="aifabric"

if  ! $orchestrator_rg & ! $vnet_flag && $peering_flag
then
    echo "The -O and -V flags have to be filled in order to configure peering, -O is Orchestrator Resource Group and -V is the Orchestrator Virtual Network to peer aifabric with" >&2
    exit 1
fi

if ((OPTIND == 1))
then
    echo "No options specified"
fi

#Validate Inputs
#Validate Resource Group
if [[ ! -n $RESOURCEGROUP ]]; then echo "ResourceGroup(-g option) cannot be empty. Exiting !!";exit 1;  fi
#Validate Domain Name
if [[ ! -n $DNSNAME ]]; then echo "DNS/Domain Name Prefix(-d option) cannot be empty. Exiting !!";exit 1;  fi
#Validate AKS Cluster Name
if [[ ! -n $AKSCLUSTERNAME ]]; then echo "AKS Cluster Name (-k option) cannot be empty. Exiting !!";exit 1;  fi
#Validate Kots Channel Name
if [[ ! -n $KOTS_CHANNEL ]]; then echo "Kots Channel Name (-c option) cannot be empty. Exiting !!";exit 1;  fi
#Validate kotsAdmin flag
if [[ ! -n $expose_kots ]]; then echo "Expose KotsAdmin flag (-e option) cannot be empty. Exiting !!";exit 1;  fi
#Validate Zonal Cluster
if [[ ! -n $zonal_cluster ]]; then echo "Zonal Cluster (-z option) cannot be empty. Exiting !!";exit 1;  fi

location=$(az group show --name $RESOURCEGROUP | jq -r '.location')


#Fetch AKS Version Dynamically
#current_aks_version=$(az aks get-versions -l westeurope | jq -r '.orchestrators[].orchestratorVersion' | grep 1.16 | tail -1)
#If 1.16 is deprecated then fallback to AKS version which is set as default
#if [ -z "$current_aks_version" ]
#then
#  current_aks_version=$(az aks get-versions -l $location | jq -r '.orchestrators[] | select(.default == true) | .orchestratorVersion')
#fi

#sed "s/AKS_VERSION/$current_aks_version/g" azuredeploy.parameters.json > azuredeploy.parameters-temp.json
#PARAMETERS_FILE="azuredeploy.parameters-temp.json"
#extracted_tags=$(jq -r '.parameters.resourceTags.value' $PARAMETERS_FILE)

#if [[ ! -n $extracted_tags || "$extracted_tags" == "{}" || "$extracted_tags" == "null" ]];
#then
#  echo "Resource tags cant be empty under $PARAMETERS_FILE file. Exiting !!"
#  exit 1
#fi

#Check if tags are valid
#empty_key_vals=$(jq -r '.parameters.resourceTags.value | to_entries[] | select(.value == null or .key == null or .value == "" or .key == "")' $PARAMETERS_FILE)

#If there exists keys/values which are null or empty
#if [ ! -z "$empty_key_vals" ]
#then
#  echo "Tags specified under $PARAMETERS_FILE are not of valid format. Exiting !!"
#  exit 1
#fi

#db_creation_option=$(jq -r '.parameters.sqlNewOrExisting.value' $PARAMETERS_FILE)

#if [ "${db_creation_option}" = "new" ];
#then
#  if [[ ! -n "$SQL_PASSWORD" ]]; then echo "SQL Password(-p option) has to be provided";exit 1; fi
#  if [[ ! -n "$SQL_USERNAME" ]]; then echo "SQL UserName(-s option) has to be provided";exit 1; fi
#fi

#Current SignIn User
sign_in_user=$(az ad signed-in-user show | jq -r '.mail')
echo "Current signIn user: $sign_in_user" | tee -a consoleOutputs.txt

echo "Permissions that exist on this Resource Group:" | tee -a consoleOutputs.txt
#Console, single command distorts the output
az role assignment list --resource-group $RESOURCEGROUP --out table
#To File
az role assignment list --resource-group $RESOURCEGROUP --out table >> consoleOutputs.txt

#Set Subscription
SUBSCRIPTION_ID=$(az group show --name $RESOURCEGROUP | jq -r '.id' | cut -d'/' -f3)
az account set --subscription $SUBSCRIPTION_ID

#cpu_instance_type=$(jq -r '.parameters.agentPoolProfiles.value[0].nodeVmSize' $PARAMETERS_FILE)
#gpu_instance_type=$(jq -r '.parameters.agentPoolProfiles.value[1].nodeVmSize' $PARAMETERS_FILE)

if [ "${zonal_cluster}" = "true" ];
then
  cpu_node_availability=$(az vm list-skus --location $location  | jq -r --arg cpu_instance_type "$cpu_instance_type" '.[] | select(.name==$cpu_instance_type and .locationInfo[0].zones[0] != null) | .name')
  gpu_node_availability=$(az vm list-skus --location $location  | jq -r --arg gpu_instance_type "$gpu_instance_type" '.[] | select(.name==$gpu_instance_type and .locationInfo[0].zones[0] != null) | .name')
else
  cpu_node_availability=$(az vm list-skus --location $location  | jq -r --arg cpu_instance_type "$cpu_instance_type" '.[] | select(.name==$cpu_instance_type) | .name')
  gpu_node_availability=$(az vm list-skus --location $location  | jq -r --arg gpu_instance_type "$gpu_instance_type" '.[] | select(.name==$gpu_instance_type) | .name')
fi
