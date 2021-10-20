FROM mysql
RUN sed -i '/skip-name-resolve/d' /etc/mysql/conf.d/docker.cnf
COPY todo.sql /docker-entrypoint-initdb.d/1.sql
EXPOSE 3306
