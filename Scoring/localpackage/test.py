"""Tests the overall functionality of the scoring functions."""
import unittest
import time
import os
import stat
from github import Github
from perform import (
    calculate_correctness,
    calculate_ramp_up,
    busfactor,
    get_responsiveness_score,
    get_license_score,
    get_update_score,
    netscore,
    create_repo_object,
)


class Tester(unittest.TestCase):
    """Unit tester for scoring functions and ingestion"""

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
        repo = create_repo_object(github, url)
        ramp_up_score = calculate_ramp_up(repo, url)
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
        repo = create_repo_object(github, url)
        score = calculate_ramp_up(repo, url)
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
        repo = create_repo_object(github, url)
        start = time.time()
        calculate_ramp_up(repo, url)
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
        repo = create_repo_object(github, url)
        returnval = calculate_ramp_up(repo, url)
        self.assertEqual(returnval, 0)

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
        repo = create_repo_object(github, url)
        score = calculate_correctness(repo)
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
        repo = create_repo_object(github, url)
        start = time.time()
        calculate_correctness(repo)
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
        repo = create_repo_object(github, url)
        returnval = calculate_correctness(repo)
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
        repo = create_repo_object(github, url)
        score = busfactor(repo)
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
        repo = create_repo_object(github, url)
        start = time.time()
        busfactor(repo)
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
        repo = create_repo_object(github, url)
        returnval = busfactor(repo)
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
        repo = create_repo_object(github, url)
        score = busfactor(repo)
        self.assertLess(score, 0.1)

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
        repo = create_repo_object(github, url)
        score = get_responsiveness_score(repo)
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
        repo = create_repo_object(github, url)
        get_responsiveness_score(repo)
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
        repo = create_repo_object(github, url)
        returnval = get_responsiveness_score(repo)
        self.assertEqual(returnval, 0)

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
        repo = create_repo_object(github, url)
        score = get_license_score(repo)
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
        repo = create_repo_object(github, url)
        get_license_score(repo)
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
        repo = create_repo_object(github, url)
        returnval = get_license_score(repo)
        self.assertEqual(returnval, 0)

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
        repo = create_repo_object(github, url)
        update_score = get_update_score(repo)
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
        repo = create_repo_object(github, url)
        update_score = get_update_score(repo)
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
        repo = create_repo_object(github, url)
        update_score = get_update_score(repo)
        self.assertEqual(update_score, 0)

    def test_calc_score_1(self):
        """
        Performs a end-to-end score test on the expresssjs repository
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "expressjs/express"
        repo = create_repo_object(github, url)
        # Check responsiveness score
        resp = get_responsiveness_score(repo)
        self.assertEqual(resp, 0.7)
        # Check license score
        lic = get_license_score(repo)
        self.assertEqual(lic, 1)
        # Check ramp-up score
        ramp_up = calculate_ramp_up(repo, url)
        self.assertEqual(ramp_up, 0.1)
        # Check correctness score
        corr = calculate_correctness(repo)
        self.assertEqual(corr, 0.4)
        # Check busfactor score
        bus = busfactor(repo)
        self.assertEqual(bus, 0.35)
        # Check update score
        update = get_update_score(repo)
        self.assertEqual(update, 0.5)
        # Check net score
        net_score = netscore([resp, lic, ramp_up, corr, bus, update])
        self.assertEqual(net_score, 0.5)

    def test_calc_score_2(self):
        """
        Performs a end-to-end score test on the lazygit repository
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "jesseduffield/lazygit"
        repo = create_repo_object(github, url)
        # Check responsiveness score
        resp = get_responsiveness_score(repo)
        self.assertEqual(resp, 0.7)
        # Check license score
        lic = get_license_score(repo)
        self.assertEqual(lic, 1)
        # Check ramp-up score
        ramp_up = calculate_ramp_up(repo, url)
        self.assertEqual(ramp_up, 0.4)
        # Check correctness score
        corr = calculate_correctness(repo)
        self.assertEqual(corr, 0.5)
        # Check busfactor score
        bus = busfactor(repo)
        self.assertEqual(bus, 1)
        # Check update score
        update = get_update_score(repo)
        self.assertEqual(update, 1)
        # Check net score
        net_score = netscore([resp, lic, ramp_up, corr, bus, update])
        self.assertEqual(net_score, 0.7)

    def test_calc_score_3(self):
        """
        Performs a end-to-end score test on the Project-1-21/GNU-LGPL-Test repository
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "Project-1-21/GNU-LGPL-Test"
        repo = create_repo_object(github, url)
        # Check responsiveness score
        resp = get_responsiveness_score(repo)
        self.assertEqual(resp, 0)
        # Check license score
        lic = get_license_score(repo)
        self.assertEqual(lic, 1)
        # Check ramp-up score
        ramp_up = calculate_ramp_up(repo, url)
        self.assertEqual(ramp_up, 0)
        # Check correctness score
        corr = calculate_correctness(repo)
        self.assertEqual(corr, 0)
        # Check busfactor score
        bus = busfactor(repo)
        self.assertEqual(bus, 0.025)
        # Check update score
        update = get_update_score(repo)
        self.assertEqual(update, 0)
        # Check net score
        net_score = netscore([resp, lic, ramp_up, corr, bus, update])
        self.assertEqual(net_score, 0.1)

    def test_calc_score_4(self):
        """
        Performs a end-to-end score test on the oxidecomputer/hubris repository
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "oxidecomputer/hubris"
        repo = create_repo_object(github, url)
        # Check responsiveness score
        resp = get_responsiveness_score(repo)
        self.assertEqual(resp, 0.7)
        # Check license score
        lic = get_license_score(repo)
        self.assertEqual(lic, 1)
        # Check ramp-up score
        ramp_up = calculate_ramp_up(repo, url)
        self.assertEqual(ramp_up, 0.1)
        # Check correctness score
        corr = calculate_correctness(repo)
        self.assertEqual(corr, 0.5)
        # Check busfactor score
        bus = busfactor(repo)
        self.assertEqual(bus, 0.6)
        # Check update score
        update = get_update_score(repo)
        self.assertEqual(update, 0)
        # Check net score
        net_score = netscore([resp, lic, ramp_up, corr, bus, update])
        self.assertEqual(net_score, 0.5)

    def test_calc_score_5(self):
        """
        Performs a end-to-end score test on the cloudinary repository
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "cloudinary/cloudinary_npm"
        repo = create_repo_object(github, url)
        # Check responsiveness score
        resp = get_responsiveness_score(repo)
        self.assertEqual(resp, 0.9)
        # Check license score
        lic = get_license_score(repo)
        self.assertEqual(lic, 1)
        # Check ramp-up score
        ramp_up = calculate_ramp_up(repo, url)
        self.assertEqual(ramp_up, 0.5)
        # Check correctness score
        corr = calculate_correctness(repo)
        self.assertEqual(corr, 0.3)
        # Check busfactor score
        bus = busfactor(repo)
        self.assertEqual(bus, 0.35)
        # Check update score
        update = get_update_score(repo)
        self.assertEqual(update, 1)
        # Check net score
        net_score = netscore([resp, lic, ramp_up, corr, bus, update])
        self.assertEqual(net_score, 0.6)

    def test_calc_score_6(self):
        """
        Performs a end-to-end score test on an empty repository
        """
        gtoken = os.getenv("GITHUB_TOKEN")
        if gtoken is None:
            print("No Github Token set in environment")
            return
        github = Github(gtoken)
        url = "lei56/test_empty_repo"
        repo = create_repo_object(github, url)
        # Check responsiveness score
        resp = get_responsiveness_score(repo)
        self.assertEqual(resp, 0)
        # Check license score
        lic = get_license_score(repo)
        self.assertEqual(lic, 0)
        # Check ramp-up score
        ramp_up = calculate_ramp_up(repo, url)
        self.assertEqual(ramp_up, 0)
        # Check correctness score
        corr = calculate_correctness(repo)
        self.assertEqual(corr, 0)
        # Check busfactor score
        bus = busfactor(repo)
        self.assertEqual(bus, 0)
        # Check update score
        update = get_update_score(repo)
        self.assertEqual(update, 0)
        # Check net score
        net_score = netscore([resp, lic, ramp_up, corr, bus, update])
        self.assertEqual(net_score, 0)


def del_rw(action, name, exc):
    """
    Alters a read-only file
    """
    os.chmod(name, stat.S_IWRITE)
    os.remove(name)
    return action, name, exc


if __name__ == "__main__":
    unittest.main()
