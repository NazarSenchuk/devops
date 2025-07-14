{{- define "kube-observability.fluentbit.fullname" -}}
{{- if .Values.fluentbit.create }}{{ .Release.Name }}-fluent-bit{{- end -}}
{{- end -}}


{{- define "kube-observability.fluentbit.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "kube-observability.fluentbit.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.commonLabels }}
{{- range $key, $value := .Values.fluentbit.commonLabels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kube-observability.fluentbit.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kube-observability.fluentbit.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}