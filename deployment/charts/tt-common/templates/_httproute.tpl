{{- define "tt-common.httproute" -}}
{{- $hr := .Values.httpRoute | default dict -}}
{{- if $hr.enabled -}}
{{- $svc := .Values.service | default dict -}}
{{- $name := include "tt-common.fullname" . -}}
{{- $svcPort := $svc.port | default (include "tt-common.port" . | int) -}}
{{- $parentRefs := $hr.parentRefs | default (list (dict "name" "traefik-gateway" "namespace" "traefik" "sectionName" "web")) -}}
{{- $hostnames := $hr.hostnames | default (list "api.abdullahsameh.tech") -}}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  {{- include "tt-common.metadata" (dict "ctx" . "name" $name "labels" $hr.labels "annotations" $hr.annotations) | nindent 2 }}
spec:
  parentRefs:
    {{- toYaml $parentRefs | nindent 4 }}
  {{- with $hostnames }}
  hostnames:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  rules:
    - matches:
        {{- range ($hr.paths | default (list)) }}
        - path:
            type: {{ .type | default "PathPrefix" }}
            value: {{ required "httpRoute.paths[].value is required" .value | quote }}
        {{- end }}
      {{- $filters := list }}
      {{- if $hr.urlRewrite }}
      {{- $filters = append $filters (dict "type" "URLRewrite" "urlRewrite" $hr.urlRewrite) }}
      {{- end }}
      {{- range ($hr.middlewares | default list) }}
      {{- $filters = append $filters (dict "type" "ExtensionRef" "extensionRef" (dict "group" "traefik.io" "kind" "Middleware" "name" (printf "%s-%s" $name .))) }}
      {{- end }}
      {{- range ($hr.filters | default list) }}
      {{- $filters = append $filters . }}
      {{- end }}
      {{- with $filters }}
      filters:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      backendRefs:
        - name: {{ $name }}
          port: {{ $svcPort }}
{{- end -}}
{{- end -}}
