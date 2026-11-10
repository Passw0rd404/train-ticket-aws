{{/*
Renders every resource of a service. Call it from the service chart:
  {{ include "tt-common.all" . }}
Each piece can also be used alone: tt-common.deployment, .service, .secrets,
.configmaps, .serviceaccount, .ingress, .hpa, .pdb
*/}}
{{- define "tt-common.all" -}}
{{- include "tt-common.serviceaccount" . }}
{{- include "tt-common.configmaps" . }}
{{- include "tt-common.secrets" . }}
{{- include "tt-common.deployment" . }}
{{- include "tt-common.service" . }}
{{- include "tt-common.ingress" . }}
{{- include "tt-common.hpa" . }}
{{- include "tt-common.pdb" . }}
{{- end -}}
