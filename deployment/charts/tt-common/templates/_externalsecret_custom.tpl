{{/* Extra ExternalSecrets from values `externalSecrets` (map: name -> spec). The Secret is named
     <service>-<name> and is added to envFrom unless `envFrom: false`. */}}
{{- define "tt-common.externalsecrets.custom" -}}
{{- $root := . -}}
{{- $fullname := include "tt-common.fullname" . -}}
{{- range $key, $es := (.Values.externalSecrets | default dict) }}
{{- $store := $es.store | default dict }}
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  {{- include "tt-common.metadata" (dict "ctx" $root "name" (printf "%s-%s" $fullname $key)) | nindent 2 }}
spec:
  refreshInterval: {{ $es.refreshInterval | default "1h" }}
  secretStoreRef:
    kind: {{ $store.kind | default "ClusterSecretStore" }}
    name: {{ required (printf "externalSecrets.%s.store.name is required" $key) $store.name }}
  target:
    name: {{ printf "%s-%s" $fullname $key }}
    creationPolicy: Owner
  data:
    {{- range $d := (required (printf "externalSecrets.%s.data is required" $key) $es.data) }}
    - secretKey: {{ $d.secretKey }}
      remoteRef:
        key: {{ required (printf "externalSecrets.%s.key is required" $key) $es.key }}
        property: {{ $d.property }}
    {{- end }}
{{- end }}
{{- end -}}
