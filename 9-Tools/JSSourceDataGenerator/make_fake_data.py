import time

from faker import Faker
import requests
import json
import uuid
from datetime import datetime, timezone
import random
import os
import base64

DP_URL = os.environ.get('RS_DATA_PLANE')
if DP_URL is None:
    print('Please export RS_DATA_PLANE=https://<data-plane-url> to config Data Plane Url')
    exit(1)
RS_WriteKey = os.environ.get('RS_WRITE_KEY')
if RS_WriteKey is None:
    print('Please export RS_WRITE_KEY=<source-write-key> to config Authorization header')
    exit(1)

fake = Faker()
# name = fake.name()

# print(name) # Output: 'John Doe'
product_list = []

def get_source_medium_and_campaign():
    market_map = {
        'google': {
            'search': ['default'],
            'cpc': ['double-eleven']
        },
        'facebook': {
            'cpc': ['double-eleven']
        },
        'baidu': {
            'search': ['default'],
            'paid': ['double-eleven']
        },
        'toutiao': {
            'cpc': ['summer-off']
        },
        'email': {
            'email': ['summer-off']
        },
        'other': {
            'default': ['default']
        }
    }

    source = fake.random.choice(list(market_map.keys()))
    # print(f'{source=}')
    medium = fake.random.choice(list(market_map[source].keys()))
    # print(f'{medium=}')
    campaign = fake.random.choice(market_map[source][medium])
    return source, medium, campaign

def get_product():
    if len(product_list) == 0:
        print('get product list')
        resp = requests.get('http://retai-loadb-irasqng4pv09-1231390207.ap-northeast-1.elb.amazonaws.com/products/featured')
        plist = resp.json()
        # print(plist)
        for p in plist:
            product_list.append({
                'name': p['name'],
                'category': p['category'],
                'price': p['price'],
                'feature': 'home_featured_rerank',
                'image': p['image'],
                'productId': p['id'],
                'discount': 'No'
            })
    return fake.random.choice(product_list)

def gen_orderid():
    now_str = datetime.now().strftime('%Y%m%d%H%M%S')
    return now_str

def btoa(data: str) -> str:
    return base64.b64encode(data.encode()).decode()

def send_request(payload, type='track'):
    auth = btoa(RS_WriteKey + ':')
    headers = {
        'authorization': f'Basic {auth}',
        'Content-Type': 'application/json'
    }
    url = f"{DP_URL}/v1/{type}"

    response = requests.request("POST", url, headers=headers, data=json.dumps(payload))

    if str(response.text) != 'OK':
        print(response.text)

def purchase(traits, useragent, sessionid, utcnow, anony_id, user_id, cart_id, ordertotal, product):
    payload = {
        "channel": "web",
        "context": {
            "app": {
                "name": "RudderLabs JavaScript SDK",
                "namespace": "com.rudderlabs.javascript",
                "version": "2.26.0"
            },
            "traits": traits,
            "library": {
                "name": "RudderLabs JavaScript SDK",
                "version": "2.26.0"
            },
            "userAgent": useragent,
            "os": {
                "name": "",
                "version": ""
            },
            "locale": "zh-CN",
            "screen": {
                "density": 2,
                "width": 1920,
                "height": 1080,
                "innerWidth": 1855,
                "innerHeight": 406
            },
            "sessionId": sessionid,
            "campaign": {},
            "page": {
                "path": "/",
                "referrer": "$direct",
                "referring_domain": "",
                "search": "",
                "title": "Retail Demo Store",
                "url": "http://d2qogd6e3vaci5.cloudfront.net/",
                "tab_url": "http://d2qogd6e3vaci5.cloudfront.net/#/checkout",
                "initial_referrer": "$direct",
                "initial_referring_domain": ""
            }
        },
        "type": "track",
        "messageId": str(uuid.uuid4()),
        "originalTimestamp": utcnow,
        "anonymousId": anony_id,
        "userId": user_id,
        "event": "Purchase",
        "properties": {
            "productId": product['productId'],
            "discount": "No"
        },
        "integrations": {
            "All": True
        },
        "sentAt": utcnow
    }
    send_request(payload)

    order_completed_payload = {
        "channel": "web",
        "context": {
            "app": {
                "name": "RudderLabs JavaScript SDK",
                "namespace": "com.rudderlabs.javascript",
                "version": "2.26.0"
            },
            "traits": traits,
            "library": {
                "name": "RudderLabs JavaScript SDK",
                "version": "2.26.0"
            },
            "userAgent": useragent,
            "os": {
                "name": "",
                "version": ""
            },
            "locale": "zh-CN",
            "screen": {
                "density": 2,
                "width": 1920,
                "height": 1080,
                "innerWidth": 1855,
                "innerHeight": 406
            },
            "sessionId": sessionid,
            "campaign": {},
            "page": {
                "path": "/",
                "referrer": "$direct",
                "referring_domain": "",
                "search": "",
                "title": "Retail Demo Store",
                "url": "http://d2qogd6e3vaci5.cloudfront.net/",
                "tab_url": "http://d2qogd6e3vaci5.cloudfront.net/#/checkout",
                "initial_referrer": "$direct",
                "initial_referring_domain": ""
            }
        },
        "type": "track",
        "messageId": str(uuid.uuid4()),
        "originalTimestamp": utcnow,
        "anonymousId": anony_id,
        "userId": user_id,
        "event": "Order Completed",
        "properties": {
            "cartId": cart_id,
            "orderId": gen_orderid(),
            "orderTotal": ordertotal
        },
        "integrations": {
            "All": True
        },
        "sentAt": utcnow
    }
    send_request(order_completed_payload)

def start_checkout(traits, useragent, user_id, utcnow, carttotal, session_id, anony_id):
    cart_id = '100' + user_id
    paload = {
        "channel": "web",
        "context": {
            "app": {
                "name": "RudderLabs JavaScript SDK",
                "namespace": "com.rudderlabs.javascript",
                "version": "2.26.0"
            },
            "traits": traits,
            "library": {
                "name": "RudderLabs JavaScript SDK",
                "version": "2.26.0"
            },
            "userAgent": useragent,
            "os": {
                "name": "",
                "version": ""
            },
            "locale": "zh-CN",
            "screen": {
                "density": 2,
                "width": 1920,
                "height": 1080,
                "innerWidth": 1855,
                "innerHeight": 406
            },
            "sessionId": session_id,
            "campaign": {},
            "page": {
                "path": "/",
                "referrer": "$direct",
                "referring_domain": "",
                "search": "",
                "title": "Retail Demo Store",
                "url": "http://d2qogd6e3vaci5.cloudfront.net/",
                "tab_url": "http://d2qogd6e3vaci5.cloudfront.net/#/checkout",
                "initial_referrer": "$direct",
                "initial_referring_domain": ""
            }
        },
        "type": "track",
        "messageId": str(uuid.uuid4()),
        "originalTimestamp": utcnow,
        "anonymousId": anony_id,
        "userId": user_id,
        "event": "StartCheckout",
        "properties": {
            "cartId": cart_id,
            "cartTotal": carttotal,
            "cartQuantity": 1
        },
        "integrations": {
            "All": True
        },
        "sentAt": utcnow
    }
    send_request(paload)
    return cart_id

def login(useragent, session_id, utcnow, anony_id, user_id):
    user_info = get_user(user_id)
    payload = {
        "channel": "web",
        "context": {
            "app": {
                "name": "RudderLabs JavaScript SDK",
                "namespace": "com.rudderlabs.javascript",
                "version": "2.26.0"
            },
            "traits": user_info,
            "library": {
                "name": "RudderLabs JavaScript SDK",
                "version": "2.26.0"
            },
            "userAgent": useragent,
            "os": {
                "name": "",
                "version": ""
            },
            "locale": "zh-CN",
            "screen": {
                "density": 2,
                "width": 1920,
                "height": 1080,
                "innerWidth": 1855,
                "innerHeight": 406
            },
            "sessionId": session_id,
            "campaign": {},
            "page": {
                "path": "/",
                "referrer": "$direct",
                "referring_domain": "",
                "search": "",
                "title": "Retail Demo Store",
                "url": "http://d2qogd6e3vaci5.cloudfront.net/",
                "tab_url": "http://d2qogd6e3vaci5.cloudfront.net/#/auth",
                "initial_referrer": "$direct",
                "initial_referring_domain": ""
            }
        },
        "type": "identify",
        "messageId": str(uuid.uuid4()),
        "originalTimestamp": utcnow,
        "anonymousId": anony_id,
        "userId": user_id,
        "integrations": {
            "All": True
        },
        "sentAt": utcnow
    }
    send_request(payload, 'identify')
    return payload['context']['traits']

def add_to_cart(user_agent, utc_now, anonymousId, userId, cartId, session_id, traits, product):
    pcart = product.copy()
    pcart['cartId'] = cartId

    payload = {
        "channel": "web",
        "context": {
            "app": {
                "name": "RudderLabs JavaScript SDK",
                "namespace": "com.rudderlabs.javascript",
                "version": "2.26.0"
            },
            "traits": traits,
            "library": {
                "name": "RudderLabs JavaScript SDK",
                "version": "2.26.0"
            },
            "userAgent": user_agent,
            "os": {
                "name": "",
                "version": ""
            },
            "locale": "zh-CN",
            "screen": {
                "density": 2,
                "width": 1920,
                "height": 1080,
                "innerWidth": 1855,
                "innerHeight": 406
            },
            "sessionId": session_id,
            "sessionStart": True,
            "campaign": {},
            "page": {
                "path": "/",
                "referrer": "$direct",
                "referring_domain": "",
                "search": "",
                "title": "Retail Demo Store",
                "url": "http://d2qogd6e3vaci5.cloudfront.net/",
                "tab_url": "http://d2qogd6e3vaci5.cloudfront.net/#/product/8bffb5fb-624f-48a8-a99f-b8e9c64bbe29?feature=home_featured_rerank",
                "initial_referrer": "$direct",
                "initial_referring_domain": ""
            }
        },
        "type": "track",
        "messageId": str(uuid.uuid4()),
        "originalTimestamp": utc_now,
        "anonymousId": anonymousId,
        "userId": userId,
        "event": "AddToCart",
        "properties": pcart,
        "integrations": {
            "All": True
        },
        "sentAt": utc_now
    }
    send_request(payload)

def get_session_id():
    timestamp = int(time.time())
    return timestamp

def get_random_num():
    rand_num = random.randint(0, 99)
    return rand_num

def get_user_id():
    rand_num = random.randint(1, 5250)
    return str(rand_num)

def get_utc_now():
    now_utc = datetime.now(timezone.utc)
    millis = now_utc.strftime("%f")
    millis = int(millis) / 1000
    # Construct the final datetime string with milliseconds
    utc_str = now_utc.strftime("%Y-%m-%dT%H:%M:%S") + f".{millis:.3f}" + "Z"
    # print(utc_str)  # Output: '2023-03-06T06:02:49.858000Z'

    return utc_str


fake_user_list = {}
def load_fake_user():
    with open('fake_users.csv', mode='r') as csv_file:
        skip_header = False
        for l in csv_file:
            if not skip_header:
                skip_header = True
                continue
            if len(l.split(',')) >= 8:
                (user_id, username, email, fname, lname, mobile, gender, age, persona, discount_persona) = l.split(',')
                fake_user_list[user_id] = {
                    "username": username,
                    "email": email,
                    "firstName": fname,
                    "lastName": lname,
                    "gender": gender,
                    "age": int(age.replace('\n', '')),
                    "mobile": mobile,
                    "persona": persona,
                    "discount_persona": discount_persona
                }
    print(f'loaded {len(fake_user_list.keys())} users')

def get_user(user_id):
    return fake_user_list[user_id]


if __name__ == '__main__':

    load_fake_user()

    for i in range(500):
        print(str(i) + ':new', end='')
        user_agent = fake.user_agent()
        # Get the current UTC datetime
        utc_str = get_utc_now()
        session_id = get_session_id()
        anony_id = str(uuid.uuid4())

        if get_random_num() > 30:
            s, m, c = get_source_medium_and_campaign()
            campaign = {
                'source': s,
                'medium': m,
                'name': c
            }
            referrer_domain = fake.domain_name()
            referrer = 'https://' + referrer_domain + '/'
        else:
            campaign = {}
            referrer_domain = ""
            referrer = "$direct"
        search = None
        page_frag = {
            "path": "/",
            "referrer": referrer,
            "referring_domain": referrer_domain,
            "search": "",
            "title": "Retail Demo Store",
            "url": "http://d2qogd6e3vaci5.cloudfront.net/",
            "tab_url": "http://d2qogd6e3vaci5.cloudfront.net/#/",
            "initial_referrer": "$direct",
            "initial_referring_domain": ""
        }
        page_payload = {
            "channel": "web",
            "context": {
                "app": {
                    "name": "RudderLabs JavaScript SDK",
                    "namespace": "com.rudderlabs.javascript",
                    "version": "2.34.0"
                },
                "traits": {},
                "library": {
                    "name": "RudderLabs JavaScript SDK",
                    "version": "2.34.0"
                },
                "userAgent": user_agent,
                "os": {
                    "name": "",
                    "version": ""
                },
                "locale": "zh-CN",
                "screen": {
                    "density": 2,
                    "width": 1920,
                    "height": 1080,
                    "innerWidth": 1848,
                    "innerHeight": 488
                },
                "sessionId": session_id,
                "campaign": campaign,
                "page": page_frag
            },
            "type": "page",
            "messageId": str(uuid.uuid4()),
            "originalTimestamp": utc_str,
            "anonymousId": anony_id,
            "userId": "",
            "properties": page_frag,
            "integrations": {
                "All": True
            },
            "sentAt": utc_str
        }
        send_request(page_payload, 'page')
        # 15% guest only view the landing page
        if get_random_num() > 85:
            continue

        view_product = get_product()
        payload = {
            "channel": "web",
            "context": {
                "app": {
                    "name": "RudderLabs JavaScript SDK",
                    "namespace": "com.rudderlabs.javascript",
                    "version": "2.26.0"
                },
                "traits": {},
                "library": {
                    "name": "RudderLabs JavaScript SDK",
                    "version": "2.26.0"
                },
                "userAgent": user_agent,
                "os": {
                    "name": "",
                    "version": ""
                },
                "locale": "zh-CN",
                "screen": {
                    "density": 2,
                    "width": 1920,
                    "height": 1080,
                    "innerWidth": 1855,
                    "innerHeight": 406
                },
                "sessionId": session_id,
                "campaign": {},
                "page": {
                    "path": "/",
                    "referrer": "$direct",
                    "referring_domain": "",
                    "search": "",
                    "title": "Retail Demo Store",
                    "url": "http://d2qogd6e3vaci5.cloudfront.net/",
                    "tab_url": "http://d2qogd6e3vaci5.cloudfront.net/#/product/8bffb5fb-624f-48a8-a99f-b8e9c64bbe29?feature=home_featured_rerank",
                    "initial_referrer": "$direct",
                    "initial_referring_domain": ""
                }
            },
            "type": "track",
            "messageId": str(uuid.uuid4()),
            "originalTimestamp": utc_str,
            "anonymousId": anony_id,
            "userId": "",
            "event": "View",
            "properties": view_product,
            "integrations": {
                "All": True
            },
            "sentAt": utc_str
        }
        send_request(payload)
        if get_random_num() > 70:
            print('-> login', end='')
            time.sleep(0.2)
            user_id = get_user_id()
            traits = login(user_agent, session_id, get_utc_now(), anony_id, user_id)
            time.sleep(0.5)
            add_to_cart(user_agent, get_utc_now(), anony_id, user_id, cartId=user_id, session_id=session_id,
                        traits=traits, product=view_product)
            print('-> add to cart', end='')

            if fake.random_int(min=1, max=100) > 50:
                time.sleep(1)
                cart_id = start_checkout(traits, user_agent, user_id, get_utc_now(), view_product['price'], session_id, anony_id)
                print('-> start checkout', end='')
                if fake.random_int(min=1, max=100) > 20:
                    time.sleep(2)
                    purchase(traits, user_agent, session_id, get_utc_now(), anony_id, user_id, cart_id, view_product['price'], view_product)
                    print('-> purchase', end='')

        print('')
        time.sleep(0.5)
