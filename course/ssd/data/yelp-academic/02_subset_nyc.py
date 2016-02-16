#!/usr/bin/env python3

import json

schools = set(['Columbia University'])
business = []

with open('business.json', 'r') as fin, \
        open('yelp-nyc-business.json', 'w') as fout:
    for l in fin:
        obj = json.loads(l)
        if len([s for s in obj['schools'] if s in schools]) > 0:
            fout.write(l)
            business.append(obj)

business_ids = set([x['business_id'] for x in business])
user_ids = set()

with open('review.json', 'r') as fin, \
        open('yelp-nyc-review.json', 'w') as fout:
    for l in fin:
        obj = json.loads(l)
        if obj['business_id'] in business_ids:
            user_ids.add(obj['user_id'])
            fout.write(l)

with open('user.json', 'r') as fin, \
        open('yelp-nyc-user.json', 'w') as fout:
    for l in fin:
        obj = json.loads(l)
        if obj['user_id'] in user_ids:
            fout.write(l)
