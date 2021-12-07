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
    # Retrieve changed/new document
    path_parts = context.resource.split('/documents/packages/')[1].split('/')
    collection_path = path_parts[0]
    document_path = '/'.join(path_parts[1:])
    
    affected_doc = client.collection(collection_path).document(document_path)
    
    # Retrieve appropriate fields
    url_value = data["value"]["fields"]["URL"]["stringValue"]
    print(url_value)
    
    # Score based on url
    ru, corr, bf, resp, lic, upd = perform.perform_single(url_value)
    print("success!!")
    
    # Write scores to new file
    new_doc = client.collection(u'scores').document(id_value)
    new_doc.set({
        u'RampUp': ru,
        u'Correctness': corr,
        u'BusFactor': bf,
        u'ResponsiveMaintainer': resp,
        u'LicenseScore': lic,
        u'UpdateScore': upd
    })
    
    

    