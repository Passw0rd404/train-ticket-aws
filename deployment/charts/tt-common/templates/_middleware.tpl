{{- define "tt-common.middlewares" -}}
{{- $root := . -}}
{{- $fullname := include "tt-common.fullname" . -}}
{{- range $key, $spec := (.Values.middlewares | default dict) }}
---
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  {{- include "tt-common.metadata" (dict "ctx" $root "name" (printf "%s-%s" $fullname $key)) | nindent 2 }}
spec:
  {{- toYaml $spec | nindent 2 }}
{{- end }}
{{- end -}}
