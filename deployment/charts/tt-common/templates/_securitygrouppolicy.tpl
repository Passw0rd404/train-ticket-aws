{{/* EKS security groups for pods: services that use MySQL (RDS) or RabbitMQ (Amazon MQ) get a
     security group that the database / broker security group allows. Other pods never get it. */}}
{{- define "tt-common.securitygrouppolicy" -}}
{{- $sg := .Values.securityGroupPolicy | default dict -}}
{{- $m := .Values.mysql | default dict -}}
{{- $r := .Values.rabbitmq | default dict -}}
{{- if $sg.enabled }}
{{- $ids := list }}
{{- if $m.enabled }}
{{- $ids = append $ids (required "securityGroupPolicy.mysqlGroupId is required for services that use MySQL" $sg.mysqlGroupId) }}
{{- end }}
{{- if $r.enabled }}
{{- $ids = append $ids (required "securityGroupPolicy.rabbitmqGroupId is required for services that use RabbitMQ" $sg.rabbitmqGroupId) }}
{{- end }}
{{- if $ids }}
---
apiVersion: {{ $sg.apiVersion | default "vpcresources.k8s.aws/v1beta1" }}
kind: SecurityGroupPolicy
metadata:
  {{- include "tt-common.metadata" (dict "ctx" . "name" (printf "%s-sg" (include "tt-common.fullname" .))) | nindent 2 }}
spec:
  podSelector:
    matchLabels:
      {{- include "tt-common.selectorLabels" . | nindent 6 }}
  securityGroups:
    groupIds:
      {{- range $ids }}
      - {{ . }}
      {{- end }}
{{- end }}
{{- end }}
{{- end -}}
