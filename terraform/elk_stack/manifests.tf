resource "kubectl_manifest" "elasticsearch_quickstart" {
  depends_on = [ helm_release.eck_operator ]
  yaml_body = <<YAML
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: quickstart
  namespace: default
spec:
  http:
    service:
      spec:
        type: LoadBalancer
    tls:
      certificate:
        secretName: my-tls-secret
      selfSignedCertificate:
        subjectAltNames:
        - ip: 192.168.49.2
        - dns: quickstart-es-http
  nodeSets:
  - config:
      node.store.allow_mmap: false
    count: 1
    name: default
  version: 8.17.3
YAML
}


resource "time_sleep" "wait_for_operator" {
  depends_on = [helm_release.eck_operator , kubectl_manifest.elasticsearch_quickstart]
  create_duration = "30s"
}
resource "kubectl_manifest" "kibana_monitored_sample" {
  depends_on = [time_sleep.wait_for_operator]  # Wait for Elasticsearch
  
  yaml_body = <<-YAML
    apiVersion: kibana.k8s.elastic.co/v1
    kind: Kibana
    metadata:
      name: monitored-sample
      namespace: default
    spec:
      version: 8.17.3
      elasticsearchRef:
        name: quickstart
      http:
        tls:
          certificate:
            secretName: quickstart-es-http-certs-internal
      count: 1
  YAML
}

resource "time_sleep" "wait_for_operator1" {
  depends_on = [helm_release.eck_operator , kubectl_manifest.elasticsearch_quickstart]
  create_duration = "30s"
}



resource "kubectl_manifest" "filebeat_quickstart" {
  depends_on = [time_sleep.wait_for_operator1]

  yaml_body = <<YAML
apiVersion: beat.k8s.elastic.co/v1beta1
kind: Beat
metadata:
  name: quickstart
  namespace: default
spec:
  type: filebeat
  version: 8.17.4
  elasticsearchRef:
    name: quickstart
  config:
    filebeat.inputs:
    - type: filestream
      enabled: true
      paths:
      %{ for path in var.filebeat_log_paths ~}
      - ${path}
      %{endfor~}
      
    output.elasticsearch:
      hosts: ['https://quickstart-es-http.default.svc:9200']
      username: "${var.username}"
      password: "${var.password}"
      ssl:
        certificate_authorities: ["${var.filebeat_path_certs}"]
      index: "${var.filebeat_index_name}"
    setup.template:
      name: "filebeat"
      pattern: "filebeat*"
      enabled: false
    setup.ilm.enabled: false
    processors:
    - add_host_metadata: {}
  daemonSet:
    podTemplate:
      spec:
        securityContext:
          runAsUser: 0
        containers:
        - name: filebeat
          volumeMounts:
          - name: host-mount
            mountPath: /var/log/nginx-containers
            readOnly: true
          - name: es-certs
            mountPath: /usr/share/filebeat/config/elasticsearch-certs
            readOnly: true
        volumes:
        - name: host-mount
          hostPath:
            path: /var/log/nginx-containers
            type: DirectoryOrCreate
        - name: es-certs
          secret:
            secretName: quickstart-es-http-certs-internal
YAML
}