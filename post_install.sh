#!/bin/sh
set -eu

plugin services set nginx

plugin config set nginx_listen_addr 0.0.0.0
plugin config set nginx_mode http

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
  echo "Modified nginx rc.d script to render config"
fi

# Enable the service
sysrc -f /etc/rc.conf nginx_enable=YES
echo "Enabled nginx service"

# Start the service
service nginx start
echo "Started nginx service"
