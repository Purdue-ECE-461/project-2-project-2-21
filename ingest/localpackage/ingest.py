"""Ingests a package."""

import os
import base64
import requests
from bs4 import BeautifulSoup


PACKAGE_DIR = "./packages"


def get_link_details(url):
    """
    Given url, retrieve the owner and repo name
    """
    if url.startswith("https://www.npmjs"):
        req = requests.get(url)
        soup = BeautifulSoup(req.content, "html.parser")
        full_url = soup.find_all("span")[-1].get_text()
        ret_val = full_url.replace("github.com/", "")
    elif url.startswith("https://github.com/"):
        ret_val = url.replace("https://github.com/", "")
    parts = ret_val.split("/")
    owner = parts[0]
    name = parts[1]
    return owner, name

def ingest_package_link(github_url, release_tag):
    """
    Given github url, creates base64 encoding of the ZIP file from the 
    github repo.
    """
    headers = {
        "Authorization" : os.getenv("GITHUB_TOKEN"),
        "Accept": 'application/vnd.github.v3+json',
    }
    
    owner, repo = get_link_details(github_url)

    ref = release_tag
    ext = 'zip'
    
    url = f'https://api.github.com/repos/{owner}/{repo}/{ext}ball/{ref}'
    print('url:', url)
    
    r = requests.get(url, headers=headers)
    
    if r.status_code == 200:
        print('size:', len(r.content))
        encoded = base64.b64encode(r.content)
        #print(encoded)
        return encoded
    else:
        print(r.text)
        return ""
    