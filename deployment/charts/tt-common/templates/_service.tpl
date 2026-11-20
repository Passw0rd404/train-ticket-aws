{{/* Name of the canary Service (<name>-canary). Empty when the Service or its canary is disabled. */}}
{{- define "tt-common.canaryService" -}}
{{- $svc := .Values.service | default dict -}}
{{- $c := $svc.canary | default dict -}}
{{- if and (ne (toString $svc.enabled) "false") (ne (toString $c.enabled) "false") -}}
{{- printf "%s-canary" (include "tt-common.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "tt-common.service" -}}
{{- $svc := .Values.service | default dict -}}
{{- $canarySvc := $svc.canary | default dict -}}
{{- $canaryName := include "tt-common.canaryService" . -}}
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
{{- if $canaryName }}
---
apiVersion: v1
kind: Service
metadata:
  {{- include "tt-common.metadata" (dict "ctx" . "name" $canaryName "labels" $canarySvc.labels "annotations" $canarySvc.annotations) | nindent 2 }}
spec:
  type: ClusterIP
  ports:
    - name: {{ $portName }}
      port: {{ $svc.port | default $port }}
      targetPort: {{ $svc.targetPort | default $portName }}
      protocol: TCP
  selector:
    {{- include "tt-common.selectorLabels" . | nindent 4 }}
{{- end }}
{{- end -}}
