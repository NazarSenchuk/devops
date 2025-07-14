
resource "aws_s3_bucket" "this" {
  bucket        = "crl_bucket-${timestamp()}"
  force_destroy = true
}


#Policy for s3
data "aws_iam_policy_document" "acmpca_bucket_access" {
  statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      identifiers = ["acm-pca.amazonaws.com"]
      type        = "Service"
    }
  }
}


#Atachment policy to bucket
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.acmpca_bucket_access.json
}



#Key for root CA
resource "tls_private_key" "root" {
  algorithm = "RSA"
}

#Root CA
resource "aws_acmpca_certificate_authority" "root_ca" {
  type = "ROOT"

  certificate_authority_configuration {
    key_algorithm     = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"

    subject {
      organization = var.organization
      country      = var.country
      common_name  = var.common_name
    }
  }

  revocation_configuration {
    crl_configuration {
      custom_cname       = "RootCA"
      enabled            = true
      expiration_in_days = 7
      s3_bucket_name     = aws_s3_bucket.this.id
      s3_object_acl      = "BUCKET_OWNER_FULL_CONTROL"
    }
  }

  permanent_deletion_time_in_days = 7

  depends_on = [aws_s3_bucket.this]
}

resource "time_sleep" "wait_for_activation" {
  depends_on = [aws_acmpca_certificate_authority.root_ca]

  create_duration = var.delay_between_ca
}

resource "tls_private_key" "intermediate" {
  algorithm = "RSA"
}


resource "tls_cert_request" "intermediate" {
  private_key_pem = tls_private_key.intermediate.private_key_pem
  subject {
    common_name  = "MyIntermediateCA"
    organization = var.organization
    country      = var.country
  }
}

resource "tls_locally_signed_cert" "intermediate" {
  cert_request_pem      = tls_cert_request.intermediate.cert_request_pem
  ca_private_key_pem    = tls_private_key.root.private_key_pem
  ca_cert_pem           = aws_acmpca_certificate_authority.root_ca.certificate
  validity_period_hours = 8760
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "crl_signing"
  ]
}

resource "aws_acmpca_certificate_authority" "intermediate_ca" {
  type = "SUBORDINATE"

  certificate_authority_configuration {
    key_algorithm     = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"

    subject {
      organization = var.organization
      country      = var.country
      common_name  = "MyIntermediateCA"
    }
  }

  revocation_configuration {
    crl_configuration {
      custom_cname       = "MyIntermediateCA"
      enabled            = true
      expiration_in_days = 7
      s3_bucket_name     = aws_s3_bucket.this.id
      s3_object_acl      = "BUCKET_OWNER_FULL_CONTROL"
    }
  }

  permanent_deletion_time_in_days = 7
}

resource "aws_acmpca_certificate_authority_certificate" "this" {
  certificate_authority_arn = aws_acmpca_certificate_authority.intermediate_ca.arn
  certificate               = tls_locally_signed_cert.intermediate.cert_pem
  certificate_chain         = aws_acmpca_certificate_authority.root_ca.certificate

  depends_on = [
    tls_locally_signed_cert.intermediate,
    time_sleep.wait_for_activation
  ]
}
