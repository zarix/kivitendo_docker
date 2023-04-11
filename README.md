# Kivitendo Docker

## Version

* 3.8.0

# Setup

## Basic Docker

Database:
```
docker run --name db \
    -e POSTGRES_PASSWORD=kivitendo \
    -e POSTGRES_USER=kivitendo \
    -e POSTGRES_DB=kivitendo_auth \
    -d postgres:14
```

Kivitendo:
```
docker run --name kivitendo \
    --link db:db \
    -p '80:80' \
    -d zarix/kivitendo_docker
```

## via Compose

```
wget https://raw.githubusercontent.com/zarix/kivitendo_docker/master/docker-compose.yml
docker compose up -d
```

# Environment Variables
**All variable names and values are case-sensitive!**

| Name | Default | Purpose |
|----------|----------|-------|
| `ADMIN_PASSWORD` | admin | |
| `POSTGRES_HOST` | db | |
| `POSTGRES_PORT` | 5432 | |
| `POSTGRES_NAME` | kivitendo_auth | |
| `POSTGRES_USER` | kivitendo | |
| `POSTGRES_PASSWORD` | kivitendo | |
| `START_TASK_SERVER` | 0 | |
| `AUTH_MODULE` | DB | |
| `LDAP_HOST` | localhost | |
| `LDAP_PORT` | 389 | |
| `LDAP_TLS` | 0 | |
| `LDAP_ATTR` | uid | |
| `LDAP_BASEDN` | | |
| `LDAP_FILTER` | | |
| `LDAP_BINDDN` | | |
| `LDAP_BINDPW` | | |
| `LDAP_TIMEOUT` | 10 | |
| `LDAP_VERIFY` | require | |
| `MAIL_METHOD` | smtp  | |
| `MAIL_HOST` | localhost | |
| `MAIL_PORT` | 25 | |
| `MAIL_SECURITY` | none | |
| `MAIL_LOGIN` | | |
| `MAIL_PASSWORD` | | |
| `MAIL_FROM` | | |
| `MAIL_TO` | | |

### Start

```
docker compose up -d
```
Point your browser to http://localhost:8080 and login using the default username and password:

- password: __admin__

# Contribution

If you want contribute to this project feel free to fork this project, do your work in a branch and create a pull request.

