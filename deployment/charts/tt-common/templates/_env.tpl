{{/* env: global.env + env (maps) and global.envRaw + envRaw (raw k8s entries, e.g. valueFrom). rabbitmq.host adds rabbitmq_host */}}
{{- define "tt-common.env" -}}
{{- $g := .Values.global | default dict -}}
{{- $r := mergeOverwrite (dict) ($g.rabbitmq | default dict) (.Values.rabbitmq | default dict) -}}
{{- $envMap := mergeOverwrite (dict) ($g.env | default dict) (.Values.env | default dict) -}}
{{- if and $r.enabled $r.host -}}
{{- $_ := set $envMap "rabbitmq_host" $r.host -}}
{{- end -}}
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

{{/* envFrom: global.envFrom + envFrom (raw entries) + the mysql secret + the rabbitmq ConfigMap + any secrets[*].envFrom: true */}}
{{- define "tt-common.envFrom" -}}
{{- $g := .Values.global | default dict -}}
{{- $m := mergeOverwrite (dict) ($g.mysql | default dict) (.Values.mysql | default dict) -}}
{{- $r := mergeOverwrite (dict) ($g.rabbitmq | default dict) (.Values.rabbitmq | default dict) -}}
{{- $fullname := include "tt-common.fullname" . -}}
{{- $items := concat ($g.envFrom | default list) (.Values.envFrom | default list) -}}
{{- if $m.enabled -}}
{{- $items = append $items (dict "secretRef" (dict "name" (include "tt-common.mysqlSecretName" .))) -}}
{{- end -}}
{{- if and $r.enabled (not $r.host) -}}
{{- $items = append $items (dict "configMapRef" (dict "name" ($r.configMapName | default "rabbitmq"))) -}}
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
