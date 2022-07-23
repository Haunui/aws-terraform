#!/bin/bash

IP=$1

if [ -z "$IP" ]; then
  echo "Usage: $0 <ip>"
  exit 1
fi

while ! scp -o StrictHostKeyChecking=no -i keypairs/keypair-haunui-ext.pem keypairs/keypair-haunui-int.pem ubuntu@$IP:~/.ssh/id_rsa; do
  sleep 2
done

ssh -o StrictHostKeyChecking=no -i keypairs/keypair-haunui-ext.pem ubuntu@$IP 'chmod 600 ~/.ssh/id_rsa'
