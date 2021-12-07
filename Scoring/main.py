"""This mamin module is the google cloud functions wrapper for perform.py"""

import json
from localpackage import perform
from google.cloud import firestore
client = firestore.Client()


def score_firestore_change(data, context):
    """Triggered by a change to a Firestore document
    args:
        data (dict): the event payload
        context (google.cloud.functions.Context): Metadata for the event. 
    """   
    path_parts = context.resource.split('/documents/packages/')[1].split('/'))
    collection_path = path_parts[0]
    document_path = '/'.join(path_parts[1:])
    
    affected_doc = client.collection(collection_path).document(document_path)
    
    content_value = data["value"]["fields"]["content"]
    url_value = data["value"]["fields"]["url"]
    print(content_value)
    print(url_value)
    
    perform.perform_single(url_value)
    print("success!!")
