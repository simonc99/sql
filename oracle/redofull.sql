SELECT
	le.leseq 			"Current log sequence #",
	100*cp.cpodr_bno/LE.lesiz	"% Full"
from
	x$kcccp cp,x$kccle le
WHERE
	LE.leseq = CP.cpodr_seq
AND
	LE.ledup != 0
/
