date > /www/P1/date-lastrun.txt
# stty 9600 cs7 parenb -cstopb  -F /dev/ttyUSB0
stty 115200 cs7 parenb -cstopb  -F /dev/ttyUSB0

TMPFILE=/tmp/P1-raw-output.txt	# the raw stuff from the USB / P1 port
MULTIP1FILE=/www/P1/teller5.txt	# cleaned up TMPFILE, to be published too for reference
RESULTFILE=/www/P1/result.txt 	# control file for humans
P1FILE=/www/P1/P1.txt		# the beautiful stuff we want

# starting copying stuff from USB port, and kill that process after 55 seconds:
# Warning: because of the $1, only put ONE command within the () !!!
(cat /dev/ttyUSB0 > $TMPFILE ) & pid=$! ; (sleep 55 && kill -9 $pid)

# remove strange characters and empty lines:
cat $TMPFILE | tr -d '\000' | grep -vi "^$" > $MULTIP1FILE 

if [ -s $MULTIP1FILE ]
then
	echo "file has some data." > $RESULTFILE
	# Find first '/' (=start of telegram) and print everything starting from there
	# Find '!' (=end of telegram), and start everyting before
        cat $MULTIP1FILE | sed -n '/\//,200 p' | sed -n '1,/\!/ p' > $P1FILE
        date >> $P1FILE
else
	echo "file is empty." > $RESULTFILE
fi

# <ks> added upload facility to data.sparkfun.com
result="$(grep "0-1:24.2.1" /www/P1/P1.txt | sed "s/.*(/gas=/;s/).*//;s/\*m3//")&$(grep "1-0:1.8.2"  /www/P1/P1.txt | sed "s/.*(/stroomhoog=/;s/).*//;s/\*kWh//")&$(grep "1-0:1.8.1"  /www/P1/P1.txt | sed "s/.*(/stroomlaag=/;s/).*//;s/\*kWh//")"

echo $result >> $RESULTFILE  


curl -X POST 'http://data.sparkfun.com/input/<public key>' -H 'Phant-Private-Key: <private key>' -d ''$result'' >> $RESULTFILE  

