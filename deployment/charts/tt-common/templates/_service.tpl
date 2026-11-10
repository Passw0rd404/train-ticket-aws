{{- define "tt-common.service" -}}
{{- $svc := .Values.service | default dict -}}
{{- $portName := .Values.portName | default "http" -}}
{{- $port := include "tt-common.port" . | int -}}
{{- if ne (toString $svc.enabled) "false" }}
---
apiVersion: v1
kind: Service
metadata:
  {{- include "tt-common.metadata" (dict "ctx" . "name" (include "tt-common.fullname" .) "labels" $svc.labels "annotations" $svc.annotations) | nindent 2 }}
spec:
  type: {{ $svc.type | default "ClusterIP" }}
  ports:
    - name: {{ $portName }}
      port: {{ $svc.port | default $port }}
      targetPort: {{ $svc.targetPort | default $portName }}
      protocol: TCP
      {{- with $svc.nodePort }}
      nodePort: {{ . }}
      {{- end }}
    {{- with $svc.extraPorts }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  selector:
    {{- include "tt-common.selectorLabels" . | nindent 4 }}
{{- end }}
{{- end -}}
