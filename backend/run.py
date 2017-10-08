import os
from corp_actions import app, logging

logging.info(app.config)
app.run(port=5099)
