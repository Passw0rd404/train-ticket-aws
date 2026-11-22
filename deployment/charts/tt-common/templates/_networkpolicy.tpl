{{/* Ingress allow-list: only the listed services (networkPolicy.allowFrom) and the listed
     external CIDRs (networkPolicy.externalCidrs) can reach this service's port.
     allowFrom entries are {name, namespace} (or a plain name found in networkPolicy.namespaces). */}}
{{- define "tt-common.networkpolicy" -}}
{{- $np := .Values.networkPolicy | default dict -}}
{{- if $np.enabled }}
{{- $port := include "tt-common.port" . | int }}
{{- $nsMap := $np.namespaces | default dict }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  {{- include "tt-common.metadata" (dict "ctx" . "name" (printf "%s-ingress" (include "tt-common.fullname" .))) | nindent 2 }}
spec:
  podSelector:
    matchLabels:
      {{- include "tt-common.selectorLabels" . | nindent 6 }}
  policyTypes:
    - Ingress
  {{- if or $np.allowFrom $np.externalCidrs }}
  ingress:
    - from:
        {{- range $c := ($np.allowFrom | default list) }}
        {{- $cname := $c }}
        {{- $cns := "" }}
        {{- if kindIs "map" $c }}
        {{- $cname = $c.name }}
        {{- $cns = required (printf "networkPolicy.allowFrom entry %s needs a namespace" $c.name) $c.namespace }}
        {{- else }}
        {{- $cns = required (printf "networkPolicy.namespaces.%s is missing" $c) (index $nsMap $c) }}
        {{- end }}
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: {{ $cns }}
          podSelector:
            matchLabels:
              app: {{ $cname }}
        {{- end }}
        {{- range $cidr := ($np.externalCidrs | default list) }}
        - ipBlock:
            cidr: {{ $cidr }}
        {{- end }}
      ports:
        - port: {{ $port }}
          protocol: TCP
  {{- end }}
{{- end }}
{{- end -}}
