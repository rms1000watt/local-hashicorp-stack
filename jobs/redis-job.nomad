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
    }
  }
}
