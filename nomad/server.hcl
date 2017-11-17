log_level  = "DEBUG"
data_dir   = "/nomad/data"
datacenter = "dc-1"

server {
    enabled          = true
    bootstrap_expect = 1

    # retry_join = ["${NOMAD_SERVER_ADDRESS_1}", "${NOMAD_SERVER_ADDRESS_2}", "${NOMAD_SERVER_ADDRESS_3}"]
}

ports {
  http = 4646
  rpc  = 4647
  serf = 4648
}