{{- define "tt-common.rollout" -}}
{{- $g := .Values.global | default dict -}}
{{- $gi := $g.image | default dict -}}
{{- $i := .Values.image | default dict -}}
{{- $sa := .Values.serviceAccount | default dict -}}
{{- $hpa := .Values.autoscaling | default dict -}}
{{- $hr := .Values.httpRoute | default dict -}}
{{- $name := include "tt-common.fullname" . -}}
{{- $port := include "tt-common.port" . | int -}}
{{- $portName := .Values.portName | default "http" -}}
{{- $canary := (.Values.rollout | default dict).canary | default ($g.rollout | default dict).canary | default dict -}}
{{- $strategy := deepCopy $canary -}}
{{- if and (not $strategy) $hr.enabled (include "tt-common.canaryService" .) -}}
{{- $strategy = dict
  "trafficRouting" (dict "plugins" (dict "argoproj-labs/gatewayAPI" (dict "httpRoute" $name "namespace" .Release.Namespace)))
  "steps" (list
    (dict "setWeight" 20)
    (dict "pause" (dict "duration" "1m"))
    (dict "analysis" (dict
      "templates" (list (dict "templateName" "canary-http-health" "clusterScope" true))
      "args" (list
        (dict "name" "service" "value" $name)
        (dict "name" "prom-url" "valueFrom" (dict "secretKeyRef" (dict "name" "grafana-prom-read" "key" "prom_url")))
        (dict "name" "prom-auth" "valueFrom" (dict "secretKeyRef" (dict "name" "grafana-prom-read" "key" "basic_auth")))
      )
    ))
    (dict "setWeight" 50)
    (dict "pause" (dict "duration" "1m"))
  )
-}}
{{- end -}}
{{- with (include "tt-common.canaryService" .) -}}
{{- $_ := set $strategy "stableService" $name -}}
{{- $_ := set $strategy "canaryService" . -}}
{{- end -}}
{{- $pull := concat ($g.imagePullSecrets | default list) (.Values.imagePullSecrets | default list) }}
---
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  {{- include "tt-common.metadata" (dict "ctx" . "name" $name "annotations" .Values.rolloutAnnotations) | nindent 2 }}
spec:
  {{- if not $hpa.enabled }}
  replicas: {{ if hasKey .Values "replicaCount" }}{{ .Values.replicaCount }}{{ else }}1{{ end }}
  {{- end }}
  {{- if hasKey .Values "revisionHistoryLimit" }}
  revisionHistoryLimit: {{ .Values.revisionHistoryLimit }}
  {{- end }}
  {{- with .Values.minReadySeconds }}
  minReadySeconds: {{ . }}
  {{- end }}
  strategy:
    canary:
      {{- if $strategy }}
      {{- toYaml $strategy | nindent 6 }}
      {{- else }} {}
      {{- end }}
  selector:
    matchLabels:
      {{- include "tt-common.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- include "tt-common.podMetadata" . | nindent 6 }}
    spec:
      {{- with $pull }}
      imagePullSecrets:
        {{- range . }}
        - name: {{ if kindIs "string" . }}{{ . }}{{ else }}{{ .name }}{{ end }}
        {{- end }}
      {{- end }}
      serviceAccountName: {{ include "tt-common.serviceAccountName" . }}
      {{- if hasKey $sa "automount" }}
      automountServiceAccountToken: {{ $sa.automount }}
      {{- end }}
      {{- with (.Values.priorityClassName | default $g.priorityClassName) }}
      priorityClassName: {{ . }}
      {{- end }}
      {{- if hasKey .Values "terminationGracePeriodSeconds" }}
      terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds }}
      {{- end }}
      {{- with (.Values.podSecurityContext | default $g.podSecurityContext) }}
      securityContext:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.initContainers }}
      initContainers:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ .Values.containerName | default $name }}
          image: {{ include "tt-common.image" . | quote }}
          imagePullPolicy: {{ $i.pullPolicy | default $gi.pullPolicy | default (ternary "Always" "IfNotPresent" (and (not $i.digest) (eq (toString ($i.tag | default $gi.tag | default "latest")) "latest"))) }}
          {{- with .Values.command }}
          command:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.args }}
          args:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with (include "tt-common.env" .) }}
          {{- . | nindent 10 }}
          {{- end }}
          {{- with (include "tt-common.envFrom" .) }}
          {{- . | nindent 10 }}
          {{- end }}
          ports:
            - name: {{ $portName }}
              containerPort: {{ $port }}
              protocol: TCP
            {{- with .Values.extraPorts }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
          {{- $readinessDefault := mergeOverwrite (dict "type" "http" "path" "/actuator/health/readiness" "initialDelaySeconds" 10 "periodSeconds" 10 "timeoutSeconds" 5) (.Values.readinessProbe | default dict) }}
          {{- with (include "tt-common.probe" (dict "cfg" $readinessDefault "port" $port "enabled" true)) }}
          readinessProbe:
            {{- . | nindent 12 }}
          {{- end }}
          {{- $livenessDefault := mergeOverwrite (dict "type" "http" "path" "/actuator/health/liveness" "initialDelaySeconds" 10 "periodSeconds" 15 "timeoutSeconds" 5) (.Values.livenessProbe | default dict) }}
          {{- with (include "tt-common.probe" (dict "cfg" $livenessDefault "port" $port "enabled" true)) }}
          livenessProbe:
            {{- . | nindent 12 }}
          {{- end }}
          {{- $startupDefault := mergeOverwrite (dict "type" "tcp" "initialDelaySeconds" 15 "periodSeconds" 10 "timeoutSeconds" 5 "failureThreshold" 30) (.Values.startupProbe | default dict) }}
          {{- with (include "tt-common.probe" (dict "cfg" $startupDefault "port" $port "enabled" true)) }}
          startupProbe:
            {{- . | nindent 12 }}
          {{- end }}
          {{- with (.Values.resources | default $g.resources) }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with (.Values.securityContext | default $g.securityContext) }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.lifecycle }}
          lifecycle:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.volumeMounts }}
          volumeMounts:
            {{- toYaml . | nindent 12 }}
          {{- end }}
        {{- with .Values.sidecars }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- with .Values.volumes }}
      volumes:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with (.Values.nodeSelector | default $g.nodeSelector) }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with (.Values.affinity | default $g.affinity) }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with (.Values.tolerations | default $g.tolerations) }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with (.Values.topologySpreadConstraints | default $g.topologySpreadConstraints) }}
      topologySpreadConstraints:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end -}}
