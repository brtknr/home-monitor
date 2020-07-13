set -x
source config.sh
OUTPUT_DIR=octopus
BASE_URL="https://api.octopus.energy/v1/electricity-meter-points"
mkdir -p $OUTPUT_DIR
for i in {1..9}; do
	curl -u "$API_KEY:" "$BASE_URL/$MPAN/meters/$METER_NO/consumption/?page=$i" | jq . > $OUTPUT_DIR/$i.json
done
