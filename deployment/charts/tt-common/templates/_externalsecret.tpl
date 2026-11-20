{{/* Credentials pulled by External Secrets Operator. The store is a ClusterSecretStore that only
     namespaces with the right label may use (configured in the platform repo, not here). */}}
{{- define "tt-common.externalsecrets" -}}
{{- $m := .Values.mysql | default dict -}}
{{- $r := .Values.rabbitmq | default dict -}}
{{- if $m.enabled }}
{{- $es := $m.externalSecret | default dict }}
{{- $store := $es.store | default dict }}
{{- $p := include "tt-common.mysqlPrefix" . }}
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  {{- include "tt-common.metadata" (dict "ctx" . "name" (include "tt-common.mysqlSecretName" .)) | nindent 2 }}
spec:
  refreshInterval: {{ $es.refreshInterval | default "1h" }}
  secretStoreRef:
    kind: {{ $store.kind | default "ClusterSecretStore" }}
    name: {{ required "mysql.externalSecret.store.name is required" $store.name }}
  target:
    name: {{ include "tt-common.mysqlSecretName" . }}
    creationPolicy: Owner
  data:
    {{- range $field := (list "host" "port" "database" "user" "password") }}
    - secretKey: {{ $p }}{{ upper $field }}
      remoteRef:
        key: {{ required "mysql.externalSecret.key is required" $es.key }}
        property: {{ $field }}
    {{- end }}
{{- end }}
{{- if $r.enabled }}
{{- $es := $r.externalSecret | default dict }}
{{- $store := $es.store | default dict }}
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  {{- include "tt-common.metadata" (dict "ctx" . "name" (include "tt-common.rabbitmqSecretName" .)) | nindent 2 }}
spec:
  refreshInterval: {{ $es.refreshInterval | default "1h" }}
  secretStoreRef:
    kind: {{ $store.kind | default "ClusterSecretStore" }}
    name: {{ required "rabbitmq.externalSecret.store.name is required" $store.name }}
  target:
    name: {{ include "tt-common.rabbitmqSecretName" . }}
    creationPolicy: Owner
  data:
    {{- if $es.data }}
    {{- toYaml $es.data | nindent 4 }}
    {{- else }}
    {{- $key := required "rabbitmq.externalSecret.key is required" $es.key }}
    - secretKey: rabbitmq_host
      remoteRef:
        key: {{ $key }}
        property: host
    - secretKey: SPRING_RABBITMQ_USERNAME
      remoteRef:
        key: {{ $key }}
        property: user
    - secretKey: SPRING_RABBITMQ_PASSWORD
      remoteRef:
        key: {{ $key }}
        property: password
    {{- end }}
{{- end }}
{{- end -}}
