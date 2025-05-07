#!/usr/bin/env bash

(free -m; echo -ne "load average "; cat /proc/loadavg) | awk -v host="$HOSTNAME" '
/^Mem:/ {
	total = $2
	used = $3
}
/^-\/+/ {
	# used = $3
}
/load average/ {
	split($0, array, " ")
	avg1 = array[3]
	avg2 = array[4]
	agv3 = array[5]
}
END {
	# printf("%su - %.1f / %.0fG, %s, %s", users, used/1000, total/1000, avg1, avg2)
	printf("%.1f / %.0fG, %.1f, %.1f", used/1000, total/1000, avg1, avg2)
}
' 2>/dev/null
