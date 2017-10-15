
import os
import requests
import json

# pip install python-dotenv
from dotenv import load_dotenv

# rename file key.txt to .env
path_env = os.path.join(os.path.dirname(__file__), '.env')
# path_env = os.path.join('.', '.env')

load_dotenv(path_env, verbose=True)

APP_ID = os.environ.get('BOTFUEL_APP_ID')
APP_KEY = os.environ.get('BOTFUEL_APP_KEY')

headers = {
    'App-Id': APP_ID,
    'App-Key': APP_KEY,
}

params = (
    ('sentence', '221 Baker St London NW1 6XE UK'),
    ('dimensions', ['city', 'postal']),
    ('antidimensions', 'address'),
)

res = requests.get('https://api.botfuel.io/nlp/entity-extraction',
                   headers=headers,
                   params=params)

text = res.content.decode('utf-8')
entities = json.loads(text)
print(entities)
print(json.dumps(entities, indent=2, sort_keys=True))

# from botfuel doc

# curl - X GET 'https://api.botfuel.io/nlp/entity-extraction'\
#     '?sentence=221+Baker+St+London+NW1+6XE+UK'\
#     '&dimension=address' \
#     - H "App-Id: $APP_ID" \
#     - H "App-Key: $APP_KEY"
