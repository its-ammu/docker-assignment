# ~ Progress

## Oct 13
  - [x] Host todo app in a php container 
  - [x] Ensure connection between container and mysql service
  - [x] Clear errors
  - [x] Clear warnings

### Files
```Dockerfile
# Dockerfile
FROM php:7.0-apache
COPY assignment/* /var/www/html/
RUN docker-php-ext-install mysqli
EXPOSE 80
```
```php
# DB connection in index.php
$servername = "127.0.0.1:3306";
$username = "php";
$password = "password";
$db = "todo";

// Create connection
$conn = new mysqli($servername, $username, $password,$db);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
echo "Connected";
```

### Commands
#### Current directory structure
```sh
$ ls -R
```
```sh
.:
Dockerfile  assignment  lamp.sh

./assignment:
index.php  style.css
```
#### Docker command to build php container
```sh
$ sudo docker build ./ -t intern/phptodo3
```
#### Docker command to run php container
```sh
$ sudo docker run -d --network=host intern/phptodo3

# -d tag is so that it doesn't display the logs and runs in background (detached)
# --network=host is so that Docker container shares its network namespace with the host machine, The application inside the container can access the port in host's ip ( to connect to mysql ) 
```
### Errors
- Since i didnt use `--net=host` php couldn't access mysql in port 3306 since it is running in local host and gave the error Connection refused.
- After specifying it was able to communicate to the port in host's ip.
- Then It gave the  following error : 
```
Warning: mysqli::__construct(): The server requested authentication method 
unknown to the client [caching_sha2_password] in /var/www/html/index.php on line 10
```
- It seems like newer mysql versions dont have password authentication as the default method they use a different method called as caching_sha2_password and so we have to change it in the `mysql.conf` file. So added the following lines in it. `mysql.conf` is found in `/etc/mysql/`
```conf
[mysqld]
default_authentication_plugin= mysql_native_password
```
- But I still got a access denied error but the necessary permissions were given. When I created a new user and did the same it worked. 
- It seems like the previous user got corrupted. I could event change its password with root access. The old user's way of authentication got stuck in a weird state after we updated the configuration that it no longer allowed us access. Once i dropped and created another one the same way with the same name it worked.

## Oct 18
  - [x] Docker beginners course
  - [x] .sql file with necessary sql commands
  - [x] Dockerfile for mysql container
  - [x] Host and ensure connection
### Files
```Dockerfile
# Dockerfile mysql
FROM mysql:5.6
COPY todo.sql /docker-entrypoint-initdb.d/1.sql
EXPOSE 3306
```
- Used 5.6 version because the latest versions use caching sha2 as the default authentication
- The todo.sql file is copied to the entrypoint folder so it is run when the container is started
```sql
CREATE DATABASE todo;
USE todo;
CREATE TABLE tasks(id int NOT NULL AUTO_INCREMENT PRIMARY KEY,task varchar(255));
CREATE USER 'php'@'127.0.0.1' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'php'@'127.0.0.1';
FLUSH PRIVILEGES;
```
### Commands
#### Current directory structure
```sh
$ ls -R

.:
Dockerfile  assignment  get-docker.sh  lamp.sh  mysql_container

./assignment:
index.php  style.css

./mysql_container:
Dockerfile  todo.sql
```
#### Docker command to run mysql container
```sh
sudo docker run -d --network=host -e MYSQL_ROOT_PASSWORD='mypassword' intern/mysqltodo
```
## Oct 19
- [x] adding secrets and volumes to docker-compose
- [x] check if running and connected (solve errors)
- [ ] finalise and revise
- [ ] Upload to git (For backup)
- [ ] kodekloud courses
### Files
```yaml
# docker-compose.yaml file

version: "3.3"
services:
        mysql:
                image: intern/mysqltodo
                ports:
                        - "3306:3306"
                network_mode: "host"
                volumes:
                        - db-data:/var/lib/mysql
                secrets:
                        - db_pass
                environment:
                        MYSQL_ROOT_PASSWORD_FILE: /run/secrets/db_pass
        php:
                image: intern/phptodo
                ports:
                        - "80:80"
                network_mode: "host"
                depends_on:
                        - mysql
                volumes:
                        - php-data:/var/www/html
                secrets:
                        - db_user
                        - db_pass
volumes:
        db-data:
        php-data:
secrets:
        db_user:
                file: ./mysql_user.txt
        db_pass:
                file: ./mysql_password.txt
```
```php
# Changed the following in index.php to get the secrets mounted

$username = rtrim(file_get_contents("/run/secrets/db_user"));
$password = rtrim(file_get_contents("/run/secrets/db_pass"));
```
### Commands
#### To create secrets from the files
```sh
# not necessary for docker-compose since already specified in docker compose
sudo docker create secrets db_user db_user.txt
sudo docker create secrets db_pass db_pass.txt
```
#### To start both the containers using docker-compose
```sh
sudo docker-compose up --detach # --detach to run in bg
```
#### To stop and remove the containers
```sh
sudo docker compose down
sudo docker compose down -v # to also delete the volumes
```
### Errors
- First I tried creating ther docker secrets without a file in a `external` way but it seems like this method only works with docker swarm and so next i tried it in the local way using files and then it worked. 
## Oct 20
- [ ] Docker swarm 
- [ ] Docker stack deploy
- [ ] Advanced course
