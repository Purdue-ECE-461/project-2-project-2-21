"""Tests the overall functionality of the ingestion functions."""
import unittest
import os
import stat
import shutil
import ingest


class Tester(unittest.TestCase):
    """Unit tester for scoring functions and ingestion"""
    def test_create_pkgdir(self):
        """
        Tests creation of package directory
        """
        if os.path.isdir("./test_dir"):
            shutil.rmtree("./test_dir", onerror=del_rw)
            ingest.make_package_dir(database_dir="test_dir")
            self.assertTrue(os.path.isdir("./test_dir"))
            shutil.rmtree("./test_dir")

    def test_remove_package(self):
        """
        Tests removal of a package
        """
        if os.path.isdir("./test_dir"):
            shutil.rmtree("./test_dir", onerror=del_rw)
            ingest.make_package_dir(database_dir="test_dir")
            os.mkdir("./test_dir/package_1")
            ingest.remove_package_folder("package_1", database_dir="test_dir")
            self.assertFalse(os.path.isdir("./test_dir/package_1"))
            shutil.rmtree("./test_dir")

    def test_ingest_local(self):
        """
        Tests ingestion of a local package
        """
        if os.path.isdir("./test_dir"):
            shutil.rmtree("./test_dir", onerror=del_rw)
            ingest.make_package_dir(database_dir="test_dir")
            local_path = "./temp_directory"
            os.mkdir(local_path)
            ingest.ingest_package_local(local_path, "test_bin", database_dir="test_dir")
            os.rmdir(local_path)
            self.assertTrue(os.path.isdir("./test_dir/test_bin"))
            shutil.rmtree("./test_dir")

    def test_ingest_github(self):
        """
        Tests ingestion of a package given github URL
        """
        if os.path.isdir("./test_dir"):
            shutil.rmtree("./test_dir", onerror=del_rw)
        ingest.make_package_dir(database_dir="test_dir")
        url = "https://github.com/Project-1-21/GNU-LGPL-Test"
        ingest.ingest_package_github(url, "test_package", database_dir="test_dir")
        self.assertTrue(os.path.isfile("./test_dir/test_package.zip"))
        shutil.rmtree("./test_dir", onerror=del_rw)


def del_rw(action, name, exc):
    """
    Alters a read-only file
    """
    os.chmod(name, stat.S_IWRITE)
    os.remove(name)
    return action, name, exc


if __name__ == "__main__":
    unittest.main()
