while true; do
	timestamp=`date --rfc-3339=s`
	result=`curl http://192.168.8.110/bme280`
	echo "$timestamp	$result" | tee -a temp.log
	sleep 10
done
