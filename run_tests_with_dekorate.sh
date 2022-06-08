#!/usr/bin/env bash

source scripts/waitFor.sh

# Deploy SSO
oc apply -f .openshiftio/sso.yaml
if [[ $(waitFor "sso" "application") -eq 1 ]] ; then
  echo "SSO failed to deploy. Aborting"
  exit 1
fi
SSO_URL=$(oc get route secure-sso -o jsonpath='https://{.spec.host}/auth')

# 3.- Capture SpringBoot version
SB_VERSION_SWITCH=""

while getopts v: option
do
    case "${option}"
        in
        v)SB_VERSION_SWITCH="-Dspring-boot.version=${OPTARG}";;
    esac
done

echo "SB_VERSION_SWITCH: ${SB_VERSION_SWITCH}"

# Run OpenShift Tests
eval "./mvnw -s .github/mvn-settings.xml clean verify -Popenshift,openshift-it -DSSO_AUTH_SERVER_URL=$SSO_URL ${SB_VERSION_SWITCH}"
