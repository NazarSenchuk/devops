namespace: "vault"
followers: ${followers_count}
defaultCapacity: ${storage_capacity}
tls:
  enabled: ${tls_enabled}
  ca_cert: "${ca_cert}"
  ca_key:  "${ca_key}"
config_leader: |

    storage "raft" {
      path    = "/vault/data/"
      node_id = "vault_leader"
    }

    listener "tcp" {
      address          = "0.0.0.0:8200"
      cluster_address = "0.0.0.0:8201"
      tls_disable      = true
    }

    seal "awskms" {
      region     = "us-east-1"
      kms_key_id = "18e421dc-f0e4-429c-94cf-ae15f3e5bd6e"
    }

    disable_mlock = true
    cluster_name            = "cluster"
    cluster_addr  = "http://vault-leader.vault.svc.cluster.local:8201"
    api_addr      = "http://vault-leader.vault.svc.cluster.local:8200"




aws_access_key: "${aws_access_key}"
aws_secret_key: "${aws_secret_key}"
