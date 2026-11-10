{{- define "tt-common.pdb" -}}
{{- $pdb := .Values.podDisruptionBudget | default dict -}}
{{- if $pdb.enabled }}
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  {{- include "tt-common.metadata" (dict "ctx" . "name" (include "tt-common.fullname" .)) | nindent 2 }}
spec:
  {{- if $pdb.maxUnavailable }}
  maxUnavailable: {{ $pdb.maxUnavailable }}
  {{- else }}
  minAvailable: {{ $pdb.minAvailable | default 1 }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "tt-common.selectorLabels" . | nindent 6 }}
{{- end }}
{{- end -}}
