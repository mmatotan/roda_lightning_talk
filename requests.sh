#!/bin/bash

#curl localhost:9292

token=$(curl -X POST localhost:9292/login)
echo $token
  
#curl -H "Authorization: Bearer ${token}" localhost:9292/user
curl -X POST -H "Authorization: Bearer ${token}" localhost:9292/user/edit

