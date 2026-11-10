{{- define "tt-common.hpa" -}}
{{- $hpa := .Values.autoscaling | default dict -}}
{{- $name := include "tt-common.fullname" . -}}
{{- if $hpa.enabled }}
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  {{- include "tt-common.metadata" (dict "ctx" . "name" $name) | nindent 2 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ $name }}
  minReplicas: {{ $hpa.minReplicas | default 1 }}
  maxReplicas: {{ $hpa.maxReplicas | default 3 }}
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ $hpa.targetCPUUtilizationPercentage | default 80 }}
    {{- with $hpa.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ . }}
    {{- end }}
  {{- with $hpa.behavior }}
  behavior:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}
