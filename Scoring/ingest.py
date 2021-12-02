"""Ingests a package."""

import os
import shutil
import errno
from git import Repo


PACKAGE_DIR = "./packages"


def ingest_package_local(dir_path, subpath_name, database_dir=PACKAGE_DIR):
    """
    Ingests packages to package directory. dir_path is the package's directory path,
    and subpath_name is the new name of the package when ingested into PACKAGE_DIR
    """
    dest_name = database_dir + "/" + subpath_name
    make_package_dir()
    try:
        shutil.copytree(dir_path, dest_name)
    except OSError as exc:
        if exc.errno in (errno.ENOTDIR, errno.EINVAL):
            shutil.copy(dir_path, dest_name)
            zip_package(dest_name)
            remove_package_folder(subpath_name)
        else:
            raise


def ingest_package_github(github_url, subpath_name, database_dir=PACKAGE_DIR):
    """
    Ingests package from Github given URL. subpath_name is the new name of the
    package when ingested into PACKAGE_DIR
    """
    dest_name = database_dir + "/" + subpath_name
    make_package_dir(database_dir=database_dir)
    # Clone repo
    Repo.clone_from(github_url, dest_name)
    zip_package(subpath_name, database_dir=database_dir)
    remove_package_folder(subpath_name, database_dir=database_dir)



def remove_package_folder(subpath_name, database_dir=PACKAGE_DIR):
    """
    Removes ingested subpath_name's folder from database
    """
    package_path = database_dir + "/" + subpath_name
    try:
        shutil.rmtree(package_path)
    except OSError as exception:
        print(f"Error: {package_path} : {exception.strerror}")


def remove_package(zipfile_name, database_dir=PACKAGE_DIR):
    """
    Removes ingested package zipfile from database
    """
    package_path = database_dir + "/" + zipfile_name
    try:
        os.remove(package_path)
    except OSError as exception:
        print(f"Error: {package_path} : {exception.strerror}")


def make_package_dir(database_dir=PACKAGE_DIR):
    """
    Creates directory for ingested packages. Default directory is PACKAGE_DIR.
    """
    if not os.path.isdir(database_dir):
        os.mkdir(database_dir)


def zip_package(subpath_name, database_dir=PACKAGE_DIR):
    """Creates zip file from given package name"""
    package_path = database_dir + "/" + subpath_name
    shutil.make_archive(package_path, 'zip', package_path)
