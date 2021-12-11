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
    client = firestore.Client()
    if "content" not in data["value"]["fields"].keys() or len(data["value"]["fields"]["content"]["stringValue"]) == 0:
        url_value = data["value"]["fields"]["url"]["stringValue"]
        version_value = data["value"]["fields"]["version"]["stringValue"]
        # Find affected document
        path_parts = context.resource.split("/documents/")[1].split("/")
        collection_path = path_parts[0]
        document_path = "/".join(path_parts[1:])

        affected_doc = client.collection(collection_path).document(document_path)

        # Generate base64 zip representation
        zipf = ingest.ingest_package_link(url_value, version_value)

        # Write ingested zip to affected document
        affected_doc.set({"content": zipf.decode("UTF-8")}, merge=True)
