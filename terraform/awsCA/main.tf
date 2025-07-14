provider "aws" {
  region     = ""
  access_key = ""
  secret_key = ""
}

module "ca" {
  source = "modules/ca/"
}

#example certificate
resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "tls_cert_request" "csr" {
  private_key_pem = tls_private_key.key.private_key_pem

  subject {
    common_name = "www.example.com"
  }
}



#Sign certificate by ca
resource "aws_acmpca_certificate" "end_entity" {
  certificate_authority_arn   = module.ca.intermediate_arn
  certificate_signing_request = tls_cert_request.csr.cert_request_pem
  signing_algorithm           = "SHA256WITHRSA"
  template_arn                = "arn:aws:acm-pca:::template/EndEntityCertificate/V1"

  validity {
    type  = "YEARS"
    value = 1
  }

  api_passthrough {
    extensions {
      key_usage {
        digital_signature = true
        key_encipherment  = true
      }
      subject_alternative_names {
        dns_names = ["example.com", "www.example.com"]
      }
    }
    subject {
      common_name = "example.com"
    }
  }
}


