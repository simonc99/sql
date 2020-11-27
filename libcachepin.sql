SELECT s.sid, kglpnmod "Mode", kglpnreq "Req"
FROM x$kglpn p, v$session s
WHERE p.kglpnuse=s.saddr
AND kglpnhdl='&P1RAW'
