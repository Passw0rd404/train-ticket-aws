{{/* Ingress allow-list: only the listed services (networkPolicy.allowFrom) and the listed
     external CIDRs (networkPolicy.externalCidrs) can reach this service's port. */}}
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
        {{- range $caller := ($np.allowFrom | default list) }}
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: {{ required (printf "networkPolicy.namespaces.%s is missing in tt-app/values.yaml" $caller) (index $nsMap $caller) }}
          podSelector:
            matchLabels:
              app: {{ $caller }}
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
