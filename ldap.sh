#!/bin/bash

docker pull osixia/openldap

#Create a Docker container: Now, create a Docker container using the LDAP image you pulled. You'll need to specify the necessary environment variables and configuration options.This command sets up a container named my-ldap-container using the osixia/openldap image

docker run --name my-ldap -p 389:389 -e LDAP_ORGANISATION="IBM Demo" -e LDAP_DOMAIN="ibm.lab" -e LDAP_ADMIN_PASSWORD="P@ssw0rd" -d osixia/openldap


#Verify the LDAP deployment: After running the container, you can verify if the LDAP server is running correctly by using an LDAP client, such as ldapsearch. You may need to install an LDAP client on your macOS system if you don't have one already. 
ldapsearch -x -H ldap://localhost:389 -b "dc=ibm,dc=lab" -D "cn=admin,dc=ibm,dc=lab" -w P@ssw0rd

slappasswd -s P@ssw0rd

# Create parent OU

cat << EOF > parent.ldif
dn: ou=users,dc=ibm,dc=lab
objectClass: organizationalUnit
ou: users
EOF

# Add parent OU
ldapadd -x -D "cn=admin,dc=ibm,dc=lab" -W -f parent.ldif -H ldap://localhost:389

# Then add user
ldapadd -x -D "cn=admin,dc=ibm,dc=lab" -W -f jon.doe.ldif -H ldap://localhost:389


ldapadd -x -D "cn=admin,dc=ibm,dc=lab" -W -f jayden.aung.ldif -H ldap://localhost:389

#check the user created
ldapsearch -x -D "cn=admin,dc=ibm,dc=lab" -w P@ssw0rd -H ldap://localhost:389 -b "ou=users,dc=ibm,dc=lab" "(uid=jayden.aung)"

ldapsearch -x -D "cn=admin,dc=ibm,dc=lab" -w P@ssw0rd -H ldap://localhost:389 -b "ou=users,dc=ibm,dc=lab" "(uid=jon.doe)"


#To authenticate us jayden.aung
ldapsearch -x -D "cn=jayden.aung,ou=users,dc=ibm,dc=lab" -w P@ssw0rd -H ldap://localhost:389 -b "cn=jayden.aung,ou=users,dc=ibm,dc=lab" -s base "(objectClass=*)"

ldapsearch -x -D "cn=jon.doe,ou=users,dc=ibm,dc=lab" -w password -H ldap://localhost:389 -b "cn=jon.doe,ou=users,dc=ibm,dc=lab" -s base "(objectClass=*)"


# Delete user
ldapdelete -x -D "cn=admin,dc=ibm,dc=lab" -w P@ssw0rd -H ldap://localhost:389 "cn=jayden.aung,ou=users,dc=ibm,dc=lab"

ldapdelete -x -D "cn=admin,dc=ibm,dc=lab" -w P@ssw0rd -H ldap://localhost:389 "cn=jon.doe,ou=users,dc=ibm,dc=lab"


# Reset password

cat << EOF > reset-password.ldif
dn: cn=jon.doe,ou=users,dc=ibm,dc=lab
changetype: modify
replace: userPassword
userPassword: {SSHA}L2jj1u3VI5Hi5ZF6xD/qeo5yVhYx+awo
EOF

ldapmodify -x -D "cn=admin,dc=ibm,dc=lab" -W -H ldap://localhost:389 -f reset-password.ldif

# Check LDAP directory structure 
ldapsearch -x -D "cn=admin,dc=ibm,dc=lab" -w P@ssw0rd -H ldap://localhost:389 -b "dc=ibm,dc=lab" -s base "(objectClass=*)"

