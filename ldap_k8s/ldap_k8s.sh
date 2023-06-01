#!/bin/bash

kubectl apply -f ldap-deployment.yaml

kubectl apply -f ldap-service.yaml


# Port Forwarding

kubectl port-forward service/ldap-service 389:389


#This command will forward the service's port 389 to your local machine's port 389, allowing you to access the LDAP server at ldap://localhost:389 from your local machine.