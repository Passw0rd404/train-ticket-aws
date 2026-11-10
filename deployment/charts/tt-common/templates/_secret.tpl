{{- define "tt-common.mysqlSecretName" -}}
{{- $g := .Values.global | default dict -}}
{{- $m := mergeOverwrite (dict) ($g.mysql | default dict) (.Values.mysql | default dict) -}}
{{- default (printf "%s-mysql" (include "tt-common.fullname" .)) $m.existingSecret -}}
{{- end -}}

{{/* ORDER_MYSQL_ style prefix derived from the service name (ts-order-service -> ORDER_MYSQL_) */}}
{{- define "tt-common.mysqlPrefix" -}}
{{- $g := .Values.global | default dict -}}
{{- $m := mergeOverwrite (dict) ($g.mysql | default dict) (.Values.mysql | default dict) -}}
{{- if $m.envPrefix -}}
{{- $m.envPrefix -}}
{{- else -}}
{{- printf "%s_MYSQL_" (include "tt-common.name" . | trimPrefix "ts-" | trimSuffix "-service" | upper | replace "-" "_") -}}
{{- end -}}
{{- end -}}

{{- define "tt-common.secrets" -}}
{{- $root := . -}}
{{- $fullname := include "tt-common.fullname" . -}}
{{- $g := .Values.global | default dict -}}
{{- $m := mergeOverwrite (dict) ($g.mysql | default dict) (.Values.mysql | default dict) -}}
{{- if and $m.enabled (not $m.existingSecret) }}
{{- $p := include "tt-common.mysqlPrefix" . }}
---
apiVersion: v1
kind: Secret
metadata:
  {{- include "tt-common.metadata" (dict "ctx" . "name" (include "tt-common.mysqlSecretName" .)) | nindent 2 }}
type: Opaque
stringData:
  {{ $p }}HOST: {{ required "mysql.host is required (set it in global.mysql.host)" $m.host | quote }}
  {{ $p }}PORT: {{ $m.port | default 3306 | toString | quote }}
  {{ $p }}DATABASE: {{ required "mysql.database is required (set it in global.mysql.database)" $m.database | quote }}
  {{ $p }}USER: {{ required "mysql.user is required (set it in global.mysql.user)" $m.user | quote }}
  {{ $p }}PASSWORD: {{ required "mysql.password is required (pass it with --set global.mysql.password=... or use mysql.existingSecret)" $m.password | quote }}
{{- end }}
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
