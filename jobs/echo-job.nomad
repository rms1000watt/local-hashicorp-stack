job "Echo-Job" {
  datacenters = ["dc-1"]

  group "Echo-Group" {
    task "Echo-Task" {
      driver = "docker"

      config {
        image = "hashicorp/http-echo"
        privileged = true
        network_mode = "host"

        args = [
          "-listen", ":5678",
          "-text", "hello world",
        ]
      }
    }
  }
}
