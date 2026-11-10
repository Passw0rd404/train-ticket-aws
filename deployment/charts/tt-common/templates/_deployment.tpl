{{- define "tt-common.deployment" -}}
{{- $g := .Values.global | default dict -}}
{{- $gi := $g.image | default dict -}}
{{- $i := .Values.image | default dict -}}
{{- $sa := .Values.serviceAccount | default dict -}}
{{- $hpa := .Values.autoscaling | default dict -}}
{{- $name := include "tt-common.fullname" . -}}
{{- $port := include "tt-common.port" . | int -}}
{{- $portName := .Values.portName | default "http" -}}
{{- $pull := concat ($g.imagePullSecrets | default list) (.Values.imagePullSecrets | default list) }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  {{- include "tt-common.metadata" (dict "ctx" . "name" $name "annotations" .Values.deploymentAnnotations) | nindent 2 }}
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
  {{- with .Values.strategy }}
  strategy:
    {{- toYaml . | nindent 4 }}
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
          imagePullPolicy: {{ $i.pullPolicy | default $gi.pullPolicy | default "IfNotPresent" }}
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
          {{- with (include "tt-common.probe" (dict "cfg" .Values.readinessProbe "port" $port "enabled" true)) }}
          readinessProbe:
            {{- . | nindent 12 }}
          {{- end }}
          {{- with (include "tt-common.probe" (dict "cfg" .Values.livenessProbe "port" $port "enabled" false)) }}
          livenessProbe:
            {{- . | nindent 12 }}
          {{- end }}
          {{- with (include "tt-common.probe" (dict "cfg" .Values.startupProbe "port" $port "enabled" false)) }}
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
