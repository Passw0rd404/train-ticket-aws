{{/* Service name, e.g. ts-order-service (required). Used as the Service DNS name, so it must match what other services call. */}}
{{- define "tt-common.name" -}}
{{- required "`name` is required in values (e.g. name: ts-order-service)" .Values.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tt-common.fullname" -}}
{{- default (include "tt-common.name" .) .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tt-common.port" -}}
{{- required "`port` (container port) is required in values" .Values.port -}}
{{- end -}}

{{- define "tt-common.selectorLabels" -}}
app: {{ include "tt-common.fullname" . }}
{{- end -}}

{{- define "tt-common.serviceAccountName" -}}
{{- $sa := .Values.serviceAccount | default dict -}}
{{- if $sa.create -}}
{{- default (include "tt-common.fullname" .) $sa.name -}}
{{- else -}}
{{- default "default" $sa.name -}}
{{- end -}}
{{- end -}}

{{/* Image reference: image.registry / global.image.registry + repository (default: name) + tag or digest */}}
{{- define "tt-common.image" -}}
{{- $g := .Values.global | default dict -}}
{{- $gi := $g.image | default dict -}}
{{- $i := .Values.image | default dict -}}
{{- $registry := $i.registry | default $gi.registry | default "" -}}
{{- $repository := $i.repository | default (include "tt-common.name" .) -}}
{{- $tag := $i.tag | default $gi.tag | default "latest" -}}
{{- $ref := $repository -}}
{{- if $registry -}}
{{- $ref = printf "%s/%s" (trimSuffix "/" $registry) $repository -}}
{{- end -}}
{{- if $i.digest -}}
{{- printf "%s@%s" $ref $i.digest -}}
{{- else -}}
{{- printf "%s:%s" $ref $tag -}}
{{- end -}}
{{- end -}}

{{/* metadata block: name + labels + annotations. Args: ctx, name, labels (optional), annotations (optional) */}}
{{- define "tt-common.metadata" -}}
{{- $ctx := .ctx -}}
{{- $g := $ctx.Values.global | default dict -}}
{{- $labels := mergeOverwrite (dict "app.kubernetes.io/name" (include "tt-common.name" $ctx) "app.kubernetes.io/instance" $ctx.Release.Name "app.kubernetes.io/managed-by" $ctx.Release.Service "helm.sh/chart" (printf "%s-%s" $ctx.Chart.Name $ctx.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-")) ($g.labels | default dict) ($ctx.Values.labels | default dict) (.labels | default dict) -}}
{{- $_ := set $labels "app" (include "tt-common.fullname" $ctx) -}}
{{- $ann := mergeOverwrite (dict) ($g.annotations | default dict) ($ctx.Values.annotations | default dict) (.annotations | default dict) -}}
name: {{ .name }}
labels:
  {{- toYaml $labels | nindent 2 }}
{{- if $ann }}
annotations:
  {{- toYaml $ann | nindent 2 }}
{{- end }}
{{- end -}}

{{/* pod template metadata: labels + annotations (global.podLabels/podAnnotations + podLabels/podAnnotations) */}}
{{- define "tt-common.podMetadata" -}}
{{- $g := .Values.global | default dict -}}
{{- $labels := mergeOverwrite (dict "app.kubernetes.io/name" (include "tt-common.name" .) "app.kubernetes.io/instance" .Release.Name) ($g.labels | default dict) ($g.podLabels | default dict) (.Values.labels | default dict) (.Values.podLabels | default dict) -}}
{{- $_ := set $labels "app" (include "tt-common.fullname" .) -}}
{{- $ann := mergeOverwrite (dict) ($g.podAnnotations | default dict) (.Values.podAnnotations | default dict) -}}
{{- if .Values.checksumAnnotations -}}
{{- $_ := set $ann "checksum/config" (toYaml (dict "cm" .Values.configMaps "s" .Values.secrets "m" .Values.mysql) | sha256sum) -}}
{{- end -}}
labels:
  {{- toYaml $labels | nindent 2 }}
{{- if $ann }}
annotations:
  {{- toYaml $ann | nindent 2 }}
{{- end }}
{{- end -}}

{{/* One probe. Args: cfg, port, enabled (default on/off). Prints nothing when disabled. */}}
{{- define "tt-common.probe" -}}
{{- $cfg := .cfg | default dict -}}
{{- $c := mergeOverwrite (dict "type" "tcp" "initialDelaySeconds" 60 "periodSeconds" 10 "timeoutSeconds" 5) $cfg -}}
{{- $enabled := .enabled -}}
{{- if hasKey $cfg "enabled" -}}
{{- $enabled = $cfg.enabled -}}
{{- end -}}
{{- if $enabled -}}
{{- if $c.custom -}}
{{- toYaml $c.custom -}}
{{- else -}}
{{- if eq (toString $c.type) "http" -}}
httpGet:
  path: {{ $c.path | default "/" }}
  port: {{ .port }}
{{- else -}}
tcpSocket:
  port: {{ .port }}
{{- end }}
initialDelaySeconds: {{ $c.initialDelaySeconds }}
periodSeconds: {{ $c.periodSeconds }}
timeoutSeconds: {{ $c.timeoutSeconds }}
{{- with $c.failureThreshold }}
failureThreshold: {{ . }}
{{- end }}
{{- with $c.successThreshold }}
successThreshold: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}
{{- end -}}
