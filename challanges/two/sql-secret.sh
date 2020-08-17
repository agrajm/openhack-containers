#!/bin/bash

# Either this or the similarly named yaml file will work

kubectl create secret generic sql \
    --from-literal=SQL_USER=<> \
    --from-literal=SQL_PASSWORD=<> \
    --from-literal=SQL_SERVER=<>.database.windows.net \
    --from-literal=SQL_DBNAME=<>