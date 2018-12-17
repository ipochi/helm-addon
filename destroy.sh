#!/bin/bash


target="./main.yml"
rm "$target"
echo "# Derived from config" >> "$target"

# User provided input
type=$1
# check if user input is not empty
  if [ -z "$type" ]; then
    echo "Provide namespace where tiller was installed, accepted input 'tiller' or 'kube-system'"
    echo "e.g : ./main.sh <namespace-name>"
    exit
  fi

# checkHelmInstalledVersion checks which version of helm is installed 
checkHelmInstalledVersion() {
  if  [ -x "${HELM_INSTALL_DIR}/${PROJECT_NAME}" ]; then
    local version=$(helm version -c | grep '^Client' | cut -d'"' -f2)
    echo "Helm client ${version} found, proceeding with tiller installation."
    return 0
  else
    echo "Helm client not found in $HELM_INSTALL_DIR Please check if it's installed"
    echo "Installation steps can be found below. Re-run the install addon command again after helm client installation."
    echo "
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh
    chmod 700 get_helm.sh
    ./get_helm.sh"
    return 1
  fi
}

# Install Helm
installHelm() {
    # using the option passed by the user.
    case $type in

      "tiller")
        echo "Installing Helm in tiller namespace"

        # for file in $(find ./installation-type/ -type f -name "rbac-config.yaml" | sort) ; do
        #   echo "add " $file
        #   cat "$file" >> "$target"
        #   echo " " >> "$target"
        #   echo "---" >> "$target"
        # done
        helm reset --tiller-namespace $type
        if [ $? -ne 0 ]; then
          exit 1
        fi

        for file in $(find ./installation-type/tiller -type f -name "*.yaml" | sort) ; do
          echo "add " $file
          cat "$file" >> "$target"
          echo " " >> "$target"
          echo "---" >> "$target"
        done
          ;;
      "kube-system")
        echo "Installing Helm in kube-system namespace"
        helm reset   
        if [ $? -ne 0 ]; then
          exit 1
        fi   

        for file in $(find ./installation-type/ -type f -name "rbac-config.yaml" | sort) ; do
          echo "add " $file
          cat "$file" >> "$target"
          echo " " >> "$target"
          echo "---" >> "$target"
        done

        for file in $(find ./installation-type/kube-system -type f -name "*.yaml" | sort) ; do
          echo "add " $file
          cat "$file" >> "$target"
          echo " " >> "$target"
          echo "---" >> "$target"
        done
          ;;    
      *) echo "invalid option '$type' , accepted inputs are 'tiller' ,'kube-system'";;
  esac
}

#  Helm Installation
if checkHelmInstalledVersion; then
  installHelm
fi