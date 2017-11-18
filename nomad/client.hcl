log_level  = "DEBUG"
data_dir   = "/nomad/data"
datacenter = "dc-1"

client {
    enabled = true
    options {
        "docker.privileged.enabled" = "true"
    }
}

ports {
    http = 4656
}
