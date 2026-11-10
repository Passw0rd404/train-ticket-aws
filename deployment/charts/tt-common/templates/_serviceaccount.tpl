{{- define "tt-common.serviceaccount" -}}
{{- $sa := .Values.serviceAccount | default dict -}}
{{- if $sa.create }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  {{- include "tt-common.metadata" (dict "ctx" . "name" (include "tt-common.serviceAccountName" .) "labels" $sa.labels "annotations" $sa.annotations) | nindent 2 }}
{{- if hasKey $sa "automount" }}
automountServiceAccountToken: {{ $sa.automount }}
{{- end }}
{{- end }}
{{- end -}}
