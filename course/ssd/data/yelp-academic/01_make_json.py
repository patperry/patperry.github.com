#!/usr/bin/env python3

import gzip
import html # need python 3.4 or later
import json

tables = {}

tables['user'] = {
    'fields': ['user_id', 'name', 'review_count', 'average_stars',
               'votes', 'url'],
    'subfields': { 'votes':['funny', 'useful', 'cool'] }
    }

tables['review'] = {
    'fields': ['review_id', 'business_id', 'user_id', 'date', 'stars',
               'text', 'votes'],
    'subfields': { 'votes':['funny', 'useful', 'cool'] }
    }

tables['business'] = {
    'fields': ['business_id', 'name', 'review_count', 'stars', 'open',
               'categories', 'full_address', 'state', 'city', 'longitude',
               'latitude', 'neighborhoods', 'schools', 'photo_url', 'url'],
    'subfields': {}
    }

def unescape(x):
    if isinstance(x, str):
        x = html.unescape(x)
    return x

with gzip.open('yelp_academic_dataset.json.gz', 'r') as infile, \
        open('user.json', 'w') as user, \
        open('review.json', 'w') as review, \
        open('business.json', 'w') as business:

    tables['user']['file'] = user
    tables['review']['file'] = review
    tables['business']['file'] = business

    for line in infile:
        obj = json.loads(line.decode('utf-8'))
        tab = tables[obj['type']]
        f = tab['file']
        record = {}
        for i in tab['fields']:
            if i in tab['subfields']:
                record[i] = {}
                for j in tab['subfields'][i]:
                    record[i][j] = unescape(obj[i][j])
            else:
                record[i] = unescape(obj[i])
        json.dump(record, f)
        f.write('\n')
