storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault"
}

listener "tcp" {
  address         = "${VAULT_ADDR}:8200"
  cluster_address = "server-1:8201"
  tls_disable     = 1
}
