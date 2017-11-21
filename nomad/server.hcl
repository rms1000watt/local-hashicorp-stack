log_level  = "DEBUG"
data_dir   = "/nomad/data"
datacenter = "dc-1"

server {
  enabled          = true
  bootstrap_expect = 3

  retry_join = ["server-1", "server-2", "server-3"]
}

ports {
  http = 4646
  rpc  = 4647
  serf = 4648
}