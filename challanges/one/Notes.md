# Download SQL Server container and Load Sample Data into it


```
docker pull mcr.microsoft.com/mssql/server:2019-CU5-ubuntu-18.04

docker run --network challenge_1 -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Useme123" -p 1433:1433 --name sql1 -d mcr.microsoft.com/mssql/server:2017-latest

docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Useme123" \
    -p 1433:1433 --name sql1 \
    -d mcr.microsoft.com/mssql/server:2019-CU5-ubuntu-18.04
```

# Load Sample Data
	
```
docker run --network challenge_1 -e SQLFQDN="sql1,1433" -e SQLUSER="SA" -e SQLPASS="Useme123" -e SQLDB=mydrivingDB openhack/data-load:v1
```	
	
# Exec into Container & Connect
	
```
docker exec -it sql1 bash
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "Useme123"
SELECT Name from sys.Databases
GO
CREATE DATABASE mydrivingDB
GO
USE mydrivingDB
GO
SELECT Name from sys.Tables
GO
```

# Challenge 1 Steps

- Copy the dockerfile_3 in POI directory and run

```
docker build -t openhack/poi:v1 -f Dockerfile_3 .
```

- Run the POI image locally to connect to local SQL Server docker image 

```
docker run -d -p 8080:80 -e SQL_USER="SA" -e SQL_PASSWORD="Useme123" -e SQL_SERVER=sql1 -e ASPNETCORE_ENVIRONMENT="Local" openhackteam13/poi:1.0
```
	
Create Service Principal

```az ad sp create-for-rbac```

# Build & Deploy Images to Private ACR

```
docker build -t containersoh/userprofile:v1 .
docker tag containersoh/userprofile:v1 registrymad0964.azurecr.io/containersoh/userprofile:v1
docker push registrymad0964.azurecr.io/containersoh/userprofile:v1
```


