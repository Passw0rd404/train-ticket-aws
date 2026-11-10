{{- define "tt-common.ingress" -}}
{{- $ing := .Values.ingress | default dict -}}
{{- $svc := .Values.service | default dict -}}
{{- $name := include "tt-common.fullname" . -}}
{{- $svcPort := $svc.port | default (include "tt-common.port" . | int) -}}
{{- if $ing.enabled }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  {{- include "tt-common.metadata" (dict "ctx" . "name" $name "labels" $ing.labels "annotations" $ing.annotations) | nindent 2 }}
spec:
  {{- with $ing.className }}
  ingressClassName: {{ . }}
  {{- end }}
  {{- with $ing.tls }}
  tls:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  rules:
    {{- range (required "ingress.hosts is required when ingress.enabled is true" $ing.hosts) }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range (.paths | default (list (dict "path" "/" "pathType" "Prefix"))) }}
          - path: {{ .path | default "/" }}
            pathType: {{ .pathType | default "Prefix" }}
            backend:
              service:
                name: {{ $name }}
                port:
                  number: {{ $svcPort }}
          {{- end }}
    {{- end }}
{{- end }}
{{- end -}}
