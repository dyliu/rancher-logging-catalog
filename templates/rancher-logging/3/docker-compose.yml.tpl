version: '2'
services:
  logging-agent:
    privileged: true
    image: registry.cn-hangzhou.aliyuncs.com/niusmallnan/logging-es:v0.2.0
    pid: host
    {{- if eq .Values.log_driver "journald" }}
    command:
    - fluentd
    - -c
    - /fluentd/etc/fluent-journald.conf
    volumes:
    - /run/log/journal:/run/log/journal
    {{- end }}
    external_links:
    - ${elasticsearch_source}:elasticsearch
    volumes_from:
    - logging-helper
    labels:
      io.rancher.container.pull_image: always
      io.rancher.scheduler.global: 'true'
      io.rancher.sidekicks: logging-helper
  logging-helper:
    privileged: true
    image: registry.cn-hangzhou.aliyuncs.com/niusmallnan/logging-helper:v0.2.1
    environment:
      LOG_VOL_PATTERN: '${log_vol_pattern}'
      LOG_FILE_PATTERN: '${log_file_pattern}'
    volumes:
    - /var/lib/docker:/var/lib/docker
    - /var/log/logging-volumes:/var/log/logging-volumes
    - /var/log/logging-containers:/var/log/logging-containers
    - /var/run/docker.sock:/var/run/docker.sock
    {{- if eq .Values.log_driver "journald" }}
    - /run/log/journal:/run/log/journal
    {{- end }}
    pid: host
    labels:
      io.rancher.container.pull_image: always
