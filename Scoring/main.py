"""This mamin module is the google cloud functions wrapper for perform.py"""

import json
from localpackage import perform

def score_firestore_change(data, context):
    """Triggered by a change to a Firestore document
    args:
        data (dict): the event payload
        context (google.cloud.functions.Context): Metadata for the event.
    """
    trigger_resource = context.resource
    
    print('function triggered by change to %s' % trigger_resource)
    
    print('\n01d value:')
    print(json.dumps(data["oldValue"]))
    
    print('\nNew value:')
    print(json.dumps(data["value"]))
