import requests

token = requests.put('http://169.254.169.254/latest/api/token',
                     headers={'X-aws-ec2-metadata-token-ttl-seconds': '60'}).text
metadata_json = requests.get('http://169.254.169.254/latest/meta-data',
                             headers={'X-aws-ec2-metadata-token': token}).json()
print(metadata_json)
