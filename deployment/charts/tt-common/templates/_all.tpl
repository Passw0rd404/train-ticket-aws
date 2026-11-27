{{/*
Renders every resource of a service. Call it from the service chart:
  {{ include "tt-common.all" . }}
Each piece can also be used alone: tt-common.rollout, .service, .secrets, .externalsecrets, .externalsecrets.custom,
.configmaps, .serviceaccount, .ingress, .hpa, .pdb, .networkpolicy, .securitygrouppolicy
*/}}
{{- define "tt-common.all" -}}
{{- include "tt-common.serviceaccount" . }}
{{- include "tt-common.configmaps" . }}
{{- include "tt-common.secrets" . }}
{{- include "tt-common.externalsecrets" . }}
{{- include "tt-common.externalsecrets.custom" . }}
{{- include "tt-common.rollout" . }}
{{- include "tt-common.service" . }}
{{- include "tt-common.middlewares" . }}
{{- include "tt-common.httproute" . }}
{{- include "tt-common.ingress" . }}
{{- include "tt-common.hpa" . }}
{{- include "tt-common.pdb" . }}
{{- include "tt-common.networkpolicy" . }}
{{- include "tt-common.securitygrouppolicy" . }}
{{- end -}}
