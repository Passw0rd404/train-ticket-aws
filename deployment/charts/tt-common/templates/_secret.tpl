{{- define "tt-common.mysqlSecretName" -}}
{{- printf "%s-mysql" (include "tt-common.fullname" .) -}}
{{- end -}}

{{- define "tt-common.rabbitmqSecretName" -}}
{{- printf "%s-rabbitmq" (include "tt-common.fullname" .) -}}
{{- end -}}

{{/* ORDER_MYSQL_ style prefix derived from the service name (ts-order-service -> ORDER_MYSQL_) */}}
{{- define "tt-common.mysqlPrefix" -}}
{{- $m := .Values.mysql | default dict -}}
{{- if $m.envPrefix -}}
{{- $m.envPrefix -}}
{{- else -}}
{{- printf "%s_MYSQL_" (include "tt-common.name" . | trimPrefix "ts-" | trimSuffix "-service" | upper | replace "-" "_") -}}
{{- end -}}
{{- end -}}

{{/* Plain Secrets from values (avoid for real credentials, use mysql / rabbitmq ExternalSecrets instead) */}}
{{- define "tt-common.secrets" -}}
{{- $root := . -}}
{{- $fullname := include "tt-common.fullname" . -}}
{{- range $key, $s := (.Values.secrets | default dict) }}
---
apiVersion: v1
kind: Secret
metadata:
  {{- include "tt-common.metadata" (dict "ctx" $root "name" (printf "%s-%s" $fullname $key) "annotations" $s.annotations) | nindent 2 }}
type: {{ $s.type | default "Opaque" }}
{{- with $s.data }}
data:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with $s.stringData }}
stringData:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}
