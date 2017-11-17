log_level  = "DEBUG"
data_dir   = "/nomad/data"
datacenter = "dc-1"

client {
    enabled = true
    # servers = ["${NOMAD_SERVER_ADDRESS_1}", "${NOMAD_SERVER_ADDRESS_2}", "${NOMAD_SERVER_ADDRESS_3}"]
    options {
        "docker.privileged.enabled" = "true"
    }
}

ports {
    http = 4656
}
