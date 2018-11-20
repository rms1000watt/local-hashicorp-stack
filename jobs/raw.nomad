job "view_files" {
  type = "system"
  datacenters = ["dc-1"]

  task "view_files" {
    driver = "raw_exec"

    config {
      command = "ls"
      args    = ["-la"]
    }
  }
}