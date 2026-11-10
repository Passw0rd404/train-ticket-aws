{{- define "tt-common.configmaps" -}}
{{- $root := . -}}
{{- range $key, $data := (.Values.configMaps | default dict) }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  {{- include "tt-common.metadata" (dict "ctx" $root "name" (printf "%s-%s" (include "tt-common.fullname" $root) $key)) | nindent 2 }}
data:
  {{- toYaml $data | nindent 2 }}
{{- end }}
{{- end -}}
