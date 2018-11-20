log_level  = "DEBUG"
data_dir   = "/nomad/data"
datacenter = "dc-1"

client {
    enabled = true
    options {
        "driver.raw_exec.enable" = "true"
        "docker.privileged.enabled" = "true"
    }
}

ports {
    http = 4656
}
