job "Redis-Job" {
  datacenters = ["dc-1"]

  group "Redis-Group" {
    task "Redis-Task" {
      driver = "docker"

      config {
        image        = "redis"
        privileged   = true
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
}
