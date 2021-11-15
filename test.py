"""Tests the overall functionality of the scoring functions."""
import unittest
import time
import os
import sys
from github import Github
from perform import (
    calculate_correctness,
    calculate_ramp_up,
    busfactor,
    get_responsiveness_score,
    get_license_score,
)
import authenticate

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
        auth = authenticate.Authenticator()
        tok = auth.register_admin("leij".encode('utf-8'), "unbreakable password".encode('utf-8'))
        self.assertNotEqual(len(auth.database), 0, "No users have been registered!")
        self.assertNotEqual(len(auth.admin_tokens), 0, "No admins have been registered!")

    def test_register_user(self):
        auth = authenticate.Authenticator()
        tok = auth.register_admin("leij".encode('utf-8'), "unbreakable password".encode('utf-8'))
        auth.register_user("leij".encode('utf-8'), tok, "fake user".encode('utf-8'),
                               "breakable password".encode('utf-8'))
        self.assertNotEqual(auth.database["fake user".encode('utf-8')], None)

    def test_delete_user(self):
        auth = authenticate.Authenticator()
        tok = auth.register_admin("leij".encode('utf-8'), "unbreakable password".encode('utf-8'))
        auth.register_user("leij".encode('utf-8'), tok, "asbf".encode('utf-8'),
                                "breakable password".encode('utf-8'))
        auth.delete_user("asbf".encode('utf-8'))
        try:
            auth.database["asbf".encode('utf-8')]
        except Exception as e:
            self.assertNotEqual(e, None, "User failed to delete")

if __name__ == "__main__":
    unittest.main()
