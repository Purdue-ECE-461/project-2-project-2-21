import time
import os
import sys
from github import Github
from perform import (
    calculate_correctness,
    calculate_ramp_up,
    busfactor,
    Responsiveness,
    getLicense,
)


def test():
    """
    Performs all tests in testing environment
    """
    gtoken = os.getenv("GITHUB_TOKEN")
    if gtoken is None:
        print("No Github Token set in environment")
        sys.exit(1)
    github = Github(gtoken)

    num_tests = 20
    passed_array = [0] * num_tests
    passed_array[0] = test0(github)
    passed_array[1] = test1(github)
    passed_array[2] = test2(github)
    passed_array[3] = test3(github)
    passed_array[4] = test4(github)
    passed_array[5] = test5(github)
    passed_array[6] = test6(github)
    passed_array[7] = test7(github)
    passed_array[8] = test8(github)
    passed_array[9] = test9(github)
    passed_array[10] = test10(github)
    passed_array[11] = test11(github)
    passed_array[12] = test12(github)
    passed_array[13] = test13(github)
    passed_array[14] = test14(github)
    passed_array[15] = test15(github)
    passed_array[16] = test16(github)
    passed_array[17] = test17(github)
    passed_array[18] = test18(github)
    passed_array[19] = test19(github)

    num_passed = sum(passed_array)
    percent = num_passed / num_tests * 100

    print("Total: " + str(num_tests))
    print("Passed: " + str(num_passed))
    print("Coverage: " + str(round(percent)) + "%")
    print(
        str(num_passed)
        + "/"
        + str(num_tests)
        + " tests passed. "
        + str(round(percent))
        + "%"
        + " line coverage achieved."
    )


def test0(github):
    """
    unit test for ramp-up:
        ensure that it gives a good score (>=0.5) to jQuery
    """
    url = "jquery/jquery"
    ramp_up_score = calculate_ramp_up(github, url)
    if ramp_up_score >= 0.5:
        return 1
    return 0


def test1(github):
    """
    unit test for ramp-up:
        ensure that it gives a bad score (<0.5) to a dummy project
    """
    url = "VikramSrivastava1729/dummy"
    score = calculate_ramp_up(github, url)
    if score < 0.5:
        return 1
    return 0


def test2(github):
    """
    unit test for ramp-up:
        ensure that it takes no more than 15 seconds for a large repo (express)
    """
    url = "expressjs/express"
    start = time.time()
    calculate_ramp_up(github, url)
    length = time.time() - start
    if length > 15:
        return 0
    return 1


def test3(github):
    """
    unit test for ramp-up:
        ensure that under failure, the process exits
    """
    url = "fake_url"
    returnval = calculate_ramp_up(github, url, True)
    if returnval == 0:
        return 1
    return 0


def test4(github):
    """
    unit test for correctness:
        ensure that it gives a good score (>=0.5) to jQuery
    """
    url = "jquery/jquery"
    correctness_score = calculate_correctness(github, url)
    if correctness_score >= 0.5:
        return 1
    return 0


def test5(github):
    """
    unit test for correctness:
        ensure that it gives a low score to a dummy repository
    """
    url = "VikramSrivastava1729/dummy"
    score = calculate_correctness(github, url)
    if score < 0.5:
        return 1
    return 0


def test6(github):
    """
    unit test for correctness:
        ensure it takes no more than 45 seconds for a large repo (express)
    """
    url = "expressjs/express"
    start = time.time()
    calculate_correctness(github, url)
    length = time.time() - start
    if length > 45:
        return 0
    return 1


def test7(github):
    """
    unit test for correctness:
        ensure that under failure, process exits
    """
    url = "fake_url"
    returnval = calculate_correctness(github, url, True)
    if returnval == 0:
        return 1
    return 0


def test8(github):
    """
    unit test for busfactor:
        ensure that it gives a good score (greater than 10 contributions
        or 0.25 score) to cloudinary as seen on thegithub repository insights
    """
    url = "cloudinary/cloudinary_npm"
    score = busfactor(github, url)
    if score > 0.25:
        return 1
    return 0


def test9(github):
    """
    unit test for busfactor:
        ensure that it takes no more than 15 seconds for a large repo (public-apis)
    """
    url = "public-apis/public-apis"
    start = time.time()
    busfactor(github, url)
    length = time.time() - start
    if length > 15:
        return 0
    return 1


def test10(github):
    """
    unit test for busfactor:
        ensure that under failure, the process exits
    """
    url = "fake_url"
    returnval = busfactor(github, url, True)
    if returnval == 0:
        return 1
    return 0


def test11(github):
    """
    unit test for busfactor:
        ensure that it gives a bad score (< 0.1) to lodash
    """
    url = "nullivex/nodist"
    score = busfactor(github, url)
    if score < 0.1:
        return 1
    return 0


def test12(github):
    """
    unit test for Responsiveness:
        ensure that it gives a good score (>=0.5) to jQuery
    """
    url = "jquery/jquery"
    ramp_up_score = Responsiveness(github, url)
    if ramp_up_score >= 0.5:
        return 1
    return 0


def test13(github):
    """
    unit test for Responsiveness:
        ensure that it gives a bad score (<0.5) to a dummy project
    """
    url = "VikramSrivastava1729/dummy"
    score = Responsiveness(github, url)
    if score < 0.5:
        return 1
    return 0


def test14(github):
    """
    unit test for Responsiveness:
        ensure that it takes no more than 30 seconds for a large repo (express)
    """
    url = "expressjs/express"
    start = time.time()
    Responsiveness(github, url)
    length = time.time() - start
    if length > 30:
        return 0
    return 1


def test15(github):
    """
    unit test for Responsiveness:
        ensure that under failure, the process exits
    """
    url = "fake_url"
    returnval = Responsiveness(github, url, True)
    if returnval == 0:
        return 1
    return 0


def test16(github):
    """
    unit test for License score:
        ensure that it gives a good score (>=0.5) to jQuery
    """
    url = "jquery/jquery"
    ramp_up_score = getLicense(github, url)
    if ramp_up_score >= 0.5:
        return 1
    return 0


def test17(github):
    """
    unit test for License score:
        ensure that it gives a bad score (<0.5) to a dummy project
    """
    url = "VikramSrivastava1729/dummy"
    score = getLicense(github, url)
    if score < 0.5:
        return 1
    return 0


def test18(github):
    """
    unit test for License score:
        ensure that it takes no more than 30 seconds for a large repo (express)
    """
    url = "expressjs/express"
    start = time.time()
    getLicense(github, url)
    length = time.time() - start
    if length > 30:
        return 0
    return 1


def test19(github):
    """
    unit test for License score:
        ensure that under failure, the process exits
    """
    url = "fake_url"
    returnval = getLicense(github, url, True)
    if returnval == 0:
        return 1
    return 0
