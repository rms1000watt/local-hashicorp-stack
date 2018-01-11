job "Golang-Redis-PG" {
  datacenters = ["dc-1"]

  group "Golang-Group" {
    count = 2

    task "Golang-Task" {
      driver = "docker"
      
      env {
        GLP_LISTEN_PORT = 9998
        GLP_REDIS_HOST = "RedisServer.service.dc-1.consul"
        GLP_REDIS_PORT = 6379
        GLP_PG_HOST = "PostgresServer.service.dc-1.consul"
        GLP_PG_PORT = 5432
        GLP_PG_USER = "postgres"
        GLP_PG_PASS = "password"
        GLP_PG_DB = "postgres"
      }

      config {
        image        = "rms1000watt/golang-redis-pg:latest"
        // privileged   = true
        network_mode = "host"
        dns_servers = ["127.0.0.1"]
      }

      service {
        name = "GolangServer"
        port = "golangPort"
        check {
          type     = "tcp"
          port     = "golangPort"
          interval = "15s"
          timeout  = "10s"
        }
      }

      resources {
        network {
          port "golangPort" {
            static = "9998"
          }
        }
      }
    }
  }

  group "Redis-Group" {
    task "Redis-Task" {
      driver = "docker"

      config {
        image        = "redis:4.0.6-alpine"
        // privileged   = true
        network_mode = "host"
      }

      service {
        name = "RedisServer"
        port = "redisPort"
        check {
          type     = "tcp"
          port     = "redisPort"
          interval = "15s"
          timeout  = "10s"
        }
      }

      resources {
        network {
          port "redisPort" {
            static = "6379"
          }
        }
      }
    }
  }

  group "Postgres-Group" {
    task "Postgres-Task" {
      driver = "docker"

      env {
        POSTGRES_USER     = "postgres"
        POSTGRES_PASSWORD = "password"
        // PGUSER            = "root"
        // PGDATA            = "/tmp/pgdata"
      }

      config {
        image        = "postgres:9.6.6-alpine"
        privileged   = true
        network_mode = "host"
        volumes = [ "local/postgres:/var/lib/postgresql/data" ]
      }
      

      service {
        name = "PostgresServer"
        port = "postgresPort"
        check {
          type     = "tcp"
          port     = "postgresPort"
          interval = "15s"
          timeout  = "10s"
        }
      }

      resources {
        network {
          port "postgresPort" {
            static = "5432"
          }
        }
      }
    }
  }
}