"""Tests the overall functionality of the scoring functions."""
import unittest
import time
import os
import stat
import shutil
from github import Github
from perform import (
    calculate_correctness,
    calculate_ramp_up,
    busfactor,
    get_responsiveness_score,
    get_license_score,
    get_update_score
)
import authenticate
import ingest

class Tester(unittest.TestCase):
    def test0(self):
        """
        unit test for ramp-up:
            ensure that it gives a good score (>=0.5) to jQuery
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "jquery/jquery"
        ramp_up_score = calculate_ramp_up(github, url)
        self.assertGreaterEqual(ramp_up_score, 0.5)


    def test1(self):
        """
        unit test for ramp-up:
            ensure that it gives a bad score (<0.5) to a dummy project
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "Project-1-21/GNU-LGPL-Test"
        score = calculate_ramp_up(github, url)
        self.assertLess(score, 0.5)


    def test2(self):
        """
        unit test for ramp-up:
            ensure that it takes no more than 15 seconds for a large repo (express)
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "expressjs/express"
        start = time.time()
        calculate_ramp_up(github, url)
        length = time.time() - start
        self.assertLessEqual(length, 15)


    def test3(self):
        """
        unit test for ramp-up:
            ensure that under failure, the process exits
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "fake_url"
        returnval = calculate_ramp_up(github, url, True)
        self.assertEqual(returnval, 0)


    # def test4(self):
    #     """
    #     unit test for correctness:
    #         ensure that it gives a good score (>=0.5) to jQuery
    #     """
    #     gtoken = os.getenv("GITHUB_TOKEN")
    #     if gtoken is None:
    #         print("No Github Token set in environment")
    #         return
    #     github = Github(gtoken)
    #     url = "jquery/jquery"
    #     correctness_score = calculate_correctness(github, url)
    #     self.assertGreaterEqual(correctness_score, 0.5)


    def test5(self):
        """
        unit test for correctness:
            ensure that it gives a low score to a dummy repository
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "Project-1-21/GNU-LGPL-Test"
        score = calculate_correctness(github, url)
        self.assertLess(score, 0.5)


    def test6(self):
        """
        unit test for correctness:
            ensure it takes no more than 45 seconds for a large repo (express)
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "expressjs/express"
        start = time.time()
        calculate_correctness(github, url)
        length = time.time() - start
        self.assertLessEqual(length, 45)


    def test7(self):
        """
        unit test for correctness:
            ensure that under failure, process exits
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "fake_url"
        returnval = calculate_correctness(github, url, True)
        self.assertEqual(returnval, 0)


    def test8(self):
        """
        unit test for busfactor:
            ensure that it gives a good score (greater than 10 contributions
            or 0.25 score) to cloudinary as seen on thegithub repository insights
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "cloudinary/cloudinary_npm"
        score = busfactor(github, url)
        self.assertGreater(score, 0.25)


    def test9(self):
        """
        unit test for busfactor:
            ensure that it takes no more than 20 seconds for a large repo (public-apis)
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "public-apis/public-apis"
        start = time.time()
        busfactor(github, url)
        length = time.time() - start
        self.assertLessEqual(length, 20)


    def test10(self):
        """
        unit test for busfactor:
            ensure that under failure, the process exits
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "fake_url"
        returnval = busfactor(github, url, True)
        self.assertEqual(returnval, 0)


    def test11(self):
        """
        unit test for busfactor:
            ensure that it gives a bad score (< 0.1) to lodash
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "nullivex/nodist"
        score = busfactor(github, url)
        self.assertLess(score, 0.1)


    # def test12(self):
    #     """
    #     unit test for Responsiveness:
    #         ensure that it gives a good score (>=0.5) to jQuery
    #     """
    #     gtoken = os.getenv("GITHUB_TOKEN")
    #     if gtoken is None:
    #         print("No Github Token set in environment")
    #         return
    #     github = Github(gtoken)
    #     url = "jquery/jquery"
    #     ramp_up_score = get_responsiveness_score(github, url)
    #     self.assertGreaterEqual(ramp_up_score, 0.5)


    def test13(self):
        """
        unit test for Responsiveness:
            ensure that it gives a bad score (<0.5) to a dummy project
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "Project-1-21/GNU-LGPL-Test"
        score = get_responsiveness_score(github, url)
        self.assertLess(score, 0.5)


    def test14(self):
        """
        unit test for Responsiveness:
            ensure that it takes no more than 100 seconds for a large repo (express)
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "expressjs/express"
        start = time.time()
        get_responsiveness_score(github, url)
        length = time.time() - start
        self.assertLessEqual(length, 100)


    def test15(self):
        """
        unit test for Responsiveness:
            ensure that under failure, the process exits
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "fake_url"
        returnval = get_responsiveness_score(github, url, True)
        self.assertEqual(returnval, 0)


    # def test16(self):
    #     """
    #     unit test for License score:
    #         ensure that it gives a good score (>=0.5) to jQuery
    #     """
    #     gtoken = os.getenv("GITHUB_TOKEN")
    #     if gtoken is None:
    #         print("No Github Token set in environment")
    #         return
    #     github = Github(gtoken)
    #     url = "jquery/jquery"
    #     ramp_up_score = get_license_score(github, url)
    #     self.assertGreaterEqual(ramp_up_score, 0.5)


    def test17(self):
        """
        unit test for License score:
            ensure that it gives a good score (1) to a dummy project with GNU license
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "Project-1-21/GNU-LGPL-Test"
        score = get_license_score(github, url)
        self.assertEqual(score, 1)


    def test18(self):
        """
        unit test for License score:
            ensure that it takes no more than 30 seconds for a large repo (express)
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "expressjs/express"
        start = time.time()
        get_license_score(github, url)
        length = time.time() - start
        self.assertLessEqual(length, 30)


    def test19(self):
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        unit test for License score:
            ensure that under failure, the process exits
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "fake_url"
        returnval = get_license_score(github, url, True)
        self.assertEqual(returnval, 0)

    def test_register_admin(self):
        """
        Tests registration of admin in authentication db
        """
        auth = authenticate.Authenticator()
        tok = auth.register_admin("leij".encode('utf-8'), "unbreakable password".encode('utf-8'))
        self.assertNotEqual(len(auth.database), 0, "No users have been registered!")
        self.assertNotEqual(len(auth.admin_tokens), 0, "No admins have been registered!")
        self.assertIsNotNone(tok)

    def test_register_user(self):
        """
        Tests registration of user in authentication db
        """
        auth = authenticate.Authenticator()
        tok = auth.register_admin("leij".encode('utf-8'), "unbreakable password".encode('utf-8'))
        auth.register_user("leij".encode('utf-8'), tok, "fake user".encode('utf-8'),
                               "breakable password".encode('utf-8'))
        self.assertNotEqual(auth.database["fake user".encode('utf-8')], None)

    def test_delete_user(self):
        """
        Tests deletion of user from authentication db
        """
        auth = authenticate.Authenticator()
        tok = auth.register_admin("leij".encode('utf-8'), "unbreakable password".encode('utf-8'))
        auth.register_user("leij".encode('utf-8'), tok, "asbf".encode('utf-8'),
                                "breakable password".encode('utf-8'))
        auth.delete_user("asbf".encode('utf-8'))
        try:
            auth.database["asbf".encode('utf-8')]
        except KeyError as exception:
            self.assertNotEqual(exception, None, "User failed to delete")

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
            ingest.remove_package("package_1", database_dir="test_dir")
            self.assertFalse(os.path.isdir("./test_dir/package_1"))
            shutil.rmtree("./test_dir")

    def test_ingest_local(self):
        """
        Tests ingestion of a local package
        """
        if os.path.isdir("./test_dir"):
            shutil.rmtree("./test_dir", onerror=del_rw)
            ingest.make_package_dir(database_dir="test_dir")
            local_path = "./bin"
            ingest.ingest_package_local(local_path, "test_bin", database_dir="test_dir")
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
        self.assertTrue(os.path.isdir("./test_dir/test_package"))
        shutil.rmtree("./test_dir", onerror=del_rw)

    def test_update_score_1(self):
        """
        Tests update score using expressjs
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "expressjs/express"
        update_score = get_update_score(github, url)
        self.assertEqual(update_score, 0.5)

    def test_update_score_2(self):
        """
        Tests update score using cloudinary_npm
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "cloudinary/cloudinary_npm"
        update_score = get_update_score(github, url)
        self.assertEqual(update_score, 1)

    def test_update_score_3(self):
        """
        Tests update score using configured-sample-generator, a deprecated repo
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "auth0/configured-sample-generator"
        update_score = get_update_score(github, url)
        self.assertEqual(update_score, 0)

def del_rw(action, name, exc):
    """
    Alters a read-only file
    """
    os.chmod(name, stat.S_IWRITE)
    os.remove(name)
    return action, name, exc

if __name__ == "__main__":
    unittest.main()
