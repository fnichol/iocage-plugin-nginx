#!/bin/sh

main() {
  set -eu
  if [ -n "${DEBUG:-}" ]; then
    set -x
  fi

  configure
  patch_rc_d_nginx
  enable_services
  start_services
}

configure() {
  plugin services set nginx

  plugin config set nginx_listen_addr 0.0.0.0
  plugin config set nginx_mode http
}

patch_rc_d_nginx() {
  if ! grep -q 'template render' /usr/local/etc/rc.d/nginx >/dev/null; then
    ex /usr/local/etc/rc.d/nginx <<EOEX
/^nginx_checkconfig()
+3
i

	nginx_mode="\$(/usr/local/bin/plugin config get nginx_mode || echo '')"
	case "\$nginx_mode" in
		https|https-only|http)
			/usr/local/bin/plugin template render \\
				"/usr/local/share/nginx/nginx.conf.\${nginx_mode}.in" \\
				/usr/local/etc/nginx/nginx.conf || return 1
			;;
		*)
			echo "nginx_mode could not be determined; nginx_mode=\$nginx_mode" >&2
			return 1
			;;
	esac
.
wq!
EOEX
    log "Modified nginx rc.d script to render config"
  fi
}

enable_services() {
  sysrc nginx_enable="YES"
  log "Enabled nginx service"
}

start_services() {
  service nginx start
  log "Started nginx service"
}

log() {
  echo "$1" >>/root/PLUGIN_INFO
}

main "$@"
