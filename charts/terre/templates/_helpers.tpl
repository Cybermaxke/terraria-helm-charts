{{/*
Expand the name of the chart.
*/}}
{{- define "terre.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "terre.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "terre.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "terre.labels" -}}
helm.sh/chart: {{ include "terre.chart" . }}
{{ include "terre.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "terre.selectorLabels" -}}
app.kubernetes.io/name: {{ include "terre.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "terre.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "terre.fullname" .) (tpl .Values.serviceAccount.name .) }}
{{- else }}
{{- default "default" (tpl .Values.serviceAccount.name .) }}
{{- end }}
{{- end }}

{{/*
Define the namespace template if set with forceNamespace or .Release.Namespace is set.
*/}}
{{- define "terre.namespace" -}}
{{- if .Values.forceNamespace -}}
namespace: {{ .Values.forceNamespace }}
{{- else -}}
namespace: {{ .Release.Namespace }}
{{- end -}}
{{- end -}}

{{/*
Define probe values.
*/}}
{{- define "terre.probeValues" -}}
initialDelaySeconds: {{ .initialDelaySeconds }}
periodSeconds: {{ .periodSeconds }}
timeoutSeconds: {{ .timeoutSeconds }}
successThreshold: {{ .successThreshold }}
failureThreshold: {{ .failureThreshold }}
{{- end }}
