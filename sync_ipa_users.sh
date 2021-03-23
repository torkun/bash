#!/bin/bash
echo This script will migrate the users and groups with the given server 
read -p "Do you want to continue process? [Y/N]" -r

if [[ $REPLY =~ ^[Yy]$ ]]
then
echo
echo Please enter ipa servers FQDN
echo 
read -r ipaservervar
echo Please Enter Directory Manager Password
read -s var1

# Change FQDN in "dc= .dc= ...." format to use in LDAP connection below
IFS='.' read -ra ADDR <<< "$ipaservervar"
for i in "${ADDR[@]}";
 do
  ipaservar_splitted=$ipaservar_splitted"dc=$i,"
 done
 ipaservar_splitted=${ipaservar_splitted::-1}

# Migrate with server by using ipa migrate-ds
echo $var1| ipa migrate-ds --bind-dn="cn=Directory Manager" --user-container=cn=users,cn=accounts --group-container=cn=groups,cn=accounts --group-objectclass=posixgroup --user-ignore-attribute={krbPrincipalName,krbextradata,krblastfailedauth,krblastpwdchange,krblastsuccessfulauth,krbloginfailedcount,krbpasswordexpiration,krbticketflags,krbpwdpolicyreference,mepManagedEntry} --user-ignore-objectclass=mepOriginEntry --with-compat ldap://$ipaservervar

# Get a list of disabled users and disable them on new server. *Ipa migrate does not include disabled users.
my_array=()
while IFS= read -r line; do
        my_array+=( "$line" )
done < <( ldapsearch -x -h $ipaservervar -D "cn=Directory Manager" -w $var1 -b $ipaservar_splitted "(nsaccountlock=TRUE)" |grep uid:|awk '{print $2}' )

for each in "${my_array[@]}"
do
  echo "$each"
ipa user-disable $each
done
fi
echo
exit