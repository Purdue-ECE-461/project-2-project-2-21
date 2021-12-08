"""This mamin module is the google cloud functions wrapper for perform.py"""
from google.cloud import firestore
from localpackage import ingest


def ingest_package(data, context):
    """Triggered by a change to a Firestore document
    args:
        data (dict): the event payload
        context (google.cloud.functions.Context): Metadata for the event.
    """
    # Retrieve appropriate fields
    try:
        client = firestore.Client()
        if "content" not in data["value"]["fields"].keys():
            url_value = data["value"]["fields"]["url"]["stringValue"]
            # Find affected document
            path_parts = context.resource.split('/documents/')[1].split('/')
            collection_path = path_parts[0]
            document_path = '/'.join(path_parts[1:])
            
            affected_doc = client.collection(collection_path).document(document_path)

            # Generate base64 zip representation
            zip = ingest.ingest_package_link(url_value)

            # Write ingested zip to affected document
            affected_doc.set({
                'content': zip
            }, merge=True)
            
    # Handle errors if it fails to gather scores
    except Exception as exception:
        event_message = f'This error was triggered by messageID {context.event_id} \
            published at {context.timestamp}'
        new_doc = client.collection('scores').document(id_value)
        new_doc.set({
            'Exception': exception,
            'EventType': context.event_type,
            'EventMessage': event_message
        })
    