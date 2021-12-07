"""This mamin module is the google cloud functions wrapper for perform.py"""
from google.cloud import firestore
from localpackage import perform


def score_firestore_change(data, context):
    """Triggered by a change to a Firestore document
    args:
        data (dict): the event payload
        context (google.cloud.functions.Context): Metadata for the event.
    """
    # Retrieve appropriate fields
    client = firestore.Client()
    id_value = data["value"]["fields"]["id"]["stringValue"]
    url_value = data["value"]["fields"]["url"]["stringValue"]
    version_value = data["value"]["fields"]["version"]["stringValue"]

    # Score based on url
    try:
        rmp_up, corr, bus_f, resp, lic, upd = perform.perform_single(url_value)
        print("success!!")

        # Write scores to new file
        new_doc = client.collection('scores').document(id_value)
        new_doc.set({
            'RampUp': rmp_up,
            'Correctness': corr,
            'BusFactor': bus_f,
            'ResponsiveMaintainer': resp,
            'LicenseScore': lic,
            'UpdateScore': upd
        })
    # Handle errors if it fails to gather scores
    except Exception as exception:
        event_message = f'This error was triggered by messageID {context.event_id} \
            published at {context.timestamp} to {context.resource["name"]}'
        new_doc = client.collection('scores').document(id_value)
        new_doc.set({
            'id': id_value,
            'url': url_value,
            'version': version_value,
            'Exception': exception,
            'EventType': context.event_type,
            'EventMessage': event_message
        })
    