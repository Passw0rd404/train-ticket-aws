{{/* env: global.env + env (maps) and global.envRaw + envRaw (raw k8s entries, e.g. valueFrom) */}}
{{- define "tt-common.env" -}}
{{- $g := .Values.global | default dict -}}
{{- $envMap := mergeOverwrite (dict) ($g.env | default dict) (.Values.env | default dict) -}}
{{- $raw := concat ($g.envRaw | default list) (.Values.envRaw | default list) -}}
{{- if or $envMap $raw -}}
env:
  {{- range $k := (keys $envMap | sortAlpha) }}
  - name: {{ $k }}
    value: {{ index $envMap $k | toString | quote }}
  {{- end }}
  {{- with $raw }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end -}}
{{- end -}}

{{/* envFrom: global.envFrom + envFrom (raw entries) + the mysql and rabbitmq secrets (made by ESO) + any secrets[*].envFrom: true */}}
{{- define "tt-common.envFrom" -}}
{{- $g := .Values.global | default dict -}}
{{- $m := .Values.mysql | default dict -}}
{{- $r := .Values.rabbitmq | default dict -}}
{{- $fullname := include "tt-common.fullname" . -}}
{{- $items := concat ($g.envFrom | default list) (.Values.envFrom | default list) -}}
{{- if $m.enabled -}}
{{- $items = append $items (dict "secretRef" (dict "name" (include "tt-common.mysqlSecretName" .))) -}}
{{- end -}}
{{- if $r.enabled -}}
{{- $items = append $items (dict "secretRef" (dict "name" (include "tt-common.rabbitmqSecretName" .))) -}}
{{- end -}}
{{- range $key, $s := (.Values.secrets | default dict) -}}
{{- if $s.envFrom -}}
{{- $items = append $items (dict "secretRef" (dict "name" (printf "%s-%s" $fullname $key))) -}}
{{- end -}}
{{- end -}}
{{- if $items -}}
envFrom:
  {{- toYaml $items | nindent 2 }}
{{- end -}}
{{- end -}}
