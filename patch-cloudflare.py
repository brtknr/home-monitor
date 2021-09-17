import time
import requests
from config import CloudFlare


def main():
    endpoint = "https://api.cloudflare.com/client/v4/zones/{}/dns_records".format(
        CloudFlare.zone
    )

    session = requests.Session()

    current_ip = session.get("http://ifconfig.me")._content.decode()
    print("Current IP is: %s" % current_ip)

    headers = {"Authorization": "Bearer %s" % CloudFlare.token}
    res = session.get(endpoint, params={"type": "A"}, headers=headers).json()
    skipped = []
    for i in res.get("result"):
        name = i.get("name")
        if i.get("name") in CloudFlare.records:
            if current_ip == i.get("content"):
                skipped.append(name)
                continue
            else:
                payload = {
                    "type": "A",
                    "name": name,
                    "content": current_ip,
                    "proxied": False,
                }
                print(
                    name,
                    session.put(
                        "{endpoint}/{record_id}".format(
                            endpoint=endpoint, record_id=i.get("record_id")
                        ),
                        json=payload,
                        headers=headers,
                    )._content,
                )
    print("Skipping {}".format(", ".join(skipped)))


if __name__ == "__main__":
    while True:
        modulus = time.time() % CloudFlare.interval
        difference = CloudFlare.interval - modulus
        if modulus > 0.1 and difference > 0.1:
            print("Sleeping for", difference)
            sys.stdout.flush()
            time.sleep(difference)
        main()
