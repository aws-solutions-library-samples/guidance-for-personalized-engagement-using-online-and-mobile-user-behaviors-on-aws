import time

from faker import Faker
import requests
import json
import uuid
from datetime import datetime, timezone
import random
import os
import base64
import pandas as pd
import numpy as np
from collections import defaultdict
import yaml
import csv

DP_URL = os.environ.get('RS_DATA_PLANE')
if DP_URL is None:
    print('Please export RS_DATA_PLANE=https://<data-plane-url> to config Data Plane Url')
    exit(1)
RS_WriteKey = os.environ.get('RS_WRITE_KEY')
if RS_WriteKey is None:
    print('Please export RS_WRITE_KEY=<source-write-key> to config Authorization header')
    exit(1)

fake = Faker()

product_list = []
fake_user_list = {}
DEFAULT_USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36'


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


def generate_product_properties(product, discount='No'):
    return {
        'name': product['name'],
        'category': product.category,
        'price': product.price,
        # 'feature': product.feature,
        'productId': product.id,
        'discount': discount
    }


def get_product():
    if len(product_list) == 0:
        print('get product list')
        resp = requests.get(
            'http://retai-loadb-irasqng4pv09-1231390207.ap-northeast-1.elb.amazonaws.com/products/featured')
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


def login(useragent, utcnow, anony_id, user_id):
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

    g_anony_id_user_id_mapping[user_id] = anony_id

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


def load_fake_user():
    with open('fake_users.csv', mode='r') as csv_file:
        csv_reader = csv.reader(csv_file)
        skip_header = False
        for row in csv_reader:
            if not skip_header:
                skip_header = True
                continue
            if len(row) >= 8:
                (user_id, username, email, fname, lname, mobile, gender, age, persona, discount_persona) = row
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


def load_products():
    # Product info is stored in the repository
    with open('products.yaml', 'r') as f:
        products = yaml.safe_load(f)

    products_df = pd.DataFrame(products)

    return products_df


def generate_interaction_event(products_df, login_users):
    min_interactions = 100
    product_added_count = 0
    product_viewed_count = 0
    product_added_percent = .40
    cart_viewed_percent = .30
    checkout_started_percent = .20
    order_completed_percent = .10
    interactions = 0
    discounted_product_viewed_count = 0
    discounted_product_added_count = 0
    cart_viewed_count = 0
    discounted_cart_viewed_count = 0
    checkout_started_count = 0
    discounted_checkout_started_count = 0
    order_completed_count = 0
    discounted_order_completed_count = 0
    subsets_cache = {}
    user_to_product = defaultdict(set)

    CATEGORY_AFFINITY_PROBS = [0.6, 0.25, 0.15]
    category_affinity_probs = np.array(CATEGORY_AFFINITY_PROBS)

    # from 0 to 1. If 0 then products in busy categories get represented less. If 1 then all products same amount.
    NORMALISE_PER_PRODUCT_WEIGHT = 1.0
    DISCOUNT_PROBABILITY = 0.2
    DISCOUNT_PROBABILITY_WITH_PREFERENCE = 0.5

    interaction_product_counts = defaultdict(int)
    product_affinities_bycatgender = {}
    user_category_to_first_prod = {}

    while interactions < min_interactions:
        # randomly pick up a logon user
        if len(login_users) > 0:
            user_id = login_users.pop()
        else:
            user_id = get_user_id()
        anony_id = g_anony_id_user_id_mapping[user_id] if user_id in g_anony_id_user_id_mapping else str(uuid.uuid4())

        traits = get_user(user_id)
        # Determine category affinity from user's persona
        persona = traits['persona']

        # If user persona has sub-categories, we will use those sub-categories to find products for users to partake
        # in interactions with. Otehrwise, we will use the high-level categories.
        preferred_categories_and_subcats = persona.split('_')
        preferred_highlevel_categories = [catstring.split(':')[0] for catstring in preferred_categories_and_subcats]

        category_frequencies = products_df.category.value_counts()
        category_frequencies /= sum(category_frequencies.values)

        p_normalised = (category_affinity_probs * category_frequencies[preferred_highlevel_categories].values)
        p_normalised /= p_normalised.sum()
        p = NORMALISE_PER_PRODUCT_WEIGHT * p_normalised + (1 - NORMALISE_PER_PRODUCT_WEIGHT) * category_affinity_probs
        # Select category based on weighted preference of category order.
        chosen_category_ind = np.random.choice(list(range(len(preferred_categories_and_subcats))), 1, p=p)[0]
        category = preferred_highlevel_categories[chosen_category_ind]

        discount_persona = traits['discount_persona']

        gender = traits['gender']

        # We are only going to use the machinery to keep things balanced
        # if there is no style appointed on the user preferences.
        # Here, in order to keep the number of products that are related to a product,
        # we restrict the size of the set of products that are recommended to an individual
        # user - in effect, the available subset for a particular category/gender
        # depends on the first product selected, which is selected as per previous logic
        # (looking at category affinities and gender)
        usercat_key = (user_id, category)  # has this user already selected a "first" product?
        if usercat_key in user_category_to_first_prod:
            # If a first product is already selected, we use the product affinities for that product
            # To provide the list of products to select from
            first_prod = user_category_to_first_prod[usercat_key]
            prods_subset_df = product_affinities_bycatgender[(category, gender)][first_prod]

        if not usercat_key in user_category_to_first_prod:
            # If the user has not yet selected a first product for this category
            # we do it by choosing between all products for gender.

            # First, check if subset data frame is already cached for category & gender
            cachekey = ('category-gender', category, gender)
            prods_subset_df = subsets_cache.get(cachekey)
            if prods_subset_df is None:
                # Select products from selected category without gender affinity or that match user's gender
                prods_subset_df = products_df.loc[(products_df['category'] == category) & (
                        (products_df['gender_affinity'] == gender) | (products_df['gender_affinity'].isnull()))]
                # Update cache
                subsets_cache[cachekey] = prods_subset_df

        # Pick a random product from gender filtered subset
        product = prods_subset_df.sample().iloc[0]

        interaction_product_counts[product.id] += 1

        user_to_product[user_id].add(product['id'])

        if not usercat_key in user_category_to_first_prod:
            user_category_to_first_prod[usercat_key] = product['id']

        average_product_price = int(products_df.price.mean())

        # Decide if the product the user is interacting with is discounted
        if discount_persona == 'discount_indifferent':
            discounted = random.random() < DISCOUNT_PROBABILITY
        elif discount_persona == 'all_discounts':
            discounted = random.random() < DISCOUNT_PROBABILITY_WITH_PREFERENCE
        elif discount_persona == 'lower_priced_products':
            if product.price < average_product_price:
                discounted = random.random() < DISCOUNT_PROBABILITY_WITH_PREFERENCE
            else:
                discounted = random.random() < DISCOUNT_PROBABILITY
        else:
            raise ValueError(f'Unable to handle discount persona: {discount_persona}')

        num_interaction_sets_to_insert = 1
        prodcnts = list(interaction_product_counts.values())
        prodcnts_max = max(prodcnts) if len(prodcnts) > 0 else 0
        prodcnts_min = min(prodcnts) if len(prodcnts) > 0 else 0
        prodcnts_avg = sum(prodcnts) / len(prodcnts) if len(prodcnts) > 0 else 0
        if interaction_product_counts[product.id] * 2 < prodcnts_max:
            num_interaction_sets_to_insert += 1
        if interaction_product_counts[product.id] < prodcnts_avg:
            num_interaction_sets_to_insert += 1
        if interaction_product_counts[product.id] == prodcnts_min:
            num_interaction_sets_to_insert += 1

        for _ in range(num_interaction_sets_to_insert):

            discount_context = 'Yes' if discounted else 'No'
            now_ts = int(datetime.timestamp(datetime.now()))
            product_props = generate_product_properties(product, discount_context)
            print(
                f"user {user_id} with persona {persona} viewed product {product['id']} in category {product.category} at {now_ts}, discount: {discount_context}")
            generate_view_product_event(DEFAULT_USER_AGENT, None, get_utc_now(), anony_id, product_props, user_id)

            product_viewed_count += 1
            interactions += 1

            if discounted:
                discounted_product_viewed_count += 1

            if product_added_count < int(product_viewed_count * product_added_percent):
                time.sleep(1)
                now_ts = int(datetime.timestamp(datetime.now()))
                print(f"user {user_id} add to cart product {product['id']} at {now_ts}, discount: {discount_context}")
                add_to_cart(DEFAULT_USER_AGENT, get_utc_now(), anony_id, user_id,
                            cartId=user_id, session_id=None, traits=traits,
                            product=product_props)

                interactions += 1
                product_added_count += 1

                if discounted:
                    discounted_product_added_count += 1

            if cart_viewed_count < int(product_viewed_count * cart_viewed_percent):
                time.sleep(1)
                now_ts = int(datetime.timestamp(datetime.now()))
                print(f"user {user_id} viewed cart product {product['id']} at {now_ts}, discount: {discount_context}")

                interactions += 1
                cart_viewed_count += 1
                if discounted:
                    discounted_cart_viewed_count += 1

            if checkout_started_count < int(product_viewed_count * checkout_started_percent):
                time.sleep(1)
                now_ts = int(datetime.timestamp(datetime.now()))
                print(
                    f"user {user_id} start checkout product {product['id']} at {now_ts}, discount: {discount_context}")
                cart_id = start_checkout(traits, DEFAULT_USER_AGENT, user_id, get_utc_now(), product.price, None,
                                         anony_id)

                interactions += 1
                checkout_started_count += 1
                if discounted:
                    discounted_checkout_started_count += 1

            if order_completed_count < int(product_viewed_count * order_completed_percent):
                time.sleep(1)
                now_ts = int(datetime.timestamp(datetime.now()))
                print(f"user {user_id} purchased product {product['id']} at {now_ts}, discount: {discount_context}")
                purchase(traits, DEFAULT_USER_AGENT, None, get_utc_now(), anony_id, user_id, cart_id,
                         product.price, product_props)

                interactions += 1
                order_completed_count += 1
                if discounted:
                    discounted_order_completed_count += 1


def generate_view_product_event(user_agent, session_id, utc_str, anony_id, view_product, user_id=""):
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
                "initial_referrer": "$direct",
                "initial_referring_domain": ""
            }
        },
        "type": "track",
        "messageId": str(uuid.uuid4()),
        "originalTimestamp": utc_str,
        "anonymousId": anony_id,
        "userId": user_id,
        "event": "View",
        "properties": view_product,
        "integrations": {
            "All": True
        },
        "sentAt": utc_str
    }
    send_request(payload)


if __name__ == '__main__':

    load_fake_user()
    g_products_df = load_products()
    g_anony_id_user_id_mapping = {}
    num_visitor = 100
    # generate events for anonymous users
    anonymous_id_list = []
    user_agent_list = []
    for i in range(num_visitor):
        print(str(i) + ': anonymous visit')
        user_agent = fake.user_agent()
        user_agent_list.append(user_agent)
        # Get the current UTC datetime
        utc_str = get_utc_now()
        session_id = get_session_id()
        anony_id = str(uuid.uuid4())
        anonymous_id_list.append(anony_id)

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
        generate_view_product_event(user_agent, session_id, utc_str, anony_id, view_product)

    login_user_list = []
    # generate login events for registered users
    for i in range(int(num_visitor * 0.2)):
        time.sleep(0.2)
        user_id = get_user_id()
        login_user_list.append(user_id)

        print(f"user {user_id} has logged in...")
        login(user_agent_list.pop(), get_utc_now(), anonymous_id_list.pop(), user_id)

    # generate interaction events for registered users
    generate_interaction_event(g_products_df, login_user_list)