job "view_files" {
  type = "system"
  datacenters = ["dc-1"]

  group "view_files"{
    restart {
      mode = "fail"
    }

    task "view_files" {
      driver = "raw_exec"

      config {
        command = "ls"
        args    = ["-la"]
      }
    }
  }
}