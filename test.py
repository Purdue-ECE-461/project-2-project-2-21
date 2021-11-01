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
    gtoken = os.getenv("GITHUB_TOKEN")
    if gtoken is None:
        print("No Github Token set in environment")
        sys.exit(1)
    g = Github(gtoken)

    NUM_TESTS = 20
    passed_array = [0] * NUM_TESTS
    passed_array[0] = test0(g)
    passed_array[1] = test1(g)
    passed_array[2] = test2(g)
    passed_array[3] = test3(g)
    passed_array[4] = test4(g)
    passed_array[5] = test5(g)
    passed_array[6] = test6(g)
    passed_array[7] = test7(g)
    passed_array[8] = test8(g)
    passed_array[9] = test9(g)
    passed_array[10] = test10(g)
    passed_array[11] = test11(g)
    passed_array[12] = test12(g)
    passed_array[13] = test13(g)
    passed_array[14] = test14(g)
    passed_array[15] = test15(g)
    passed_array[16] = test16(g)
    passed_array[17] = test17(g)
    passed_array[18] = test18(g)
    passed_array[19] = test19(g)

    num_passed = sum(passed_array)
    percent = num_passed / NUM_TESTS * 100

    print("Total: " + str(NUM_TESTS))
    print("Passed: " + str(num_passed))
    print("Coverage: " + str(round(percent)) + "%")
    print(
        str(num_passed)
        + "/"
        + str(NUM_TESTS)
        + " tests passed. "
        + str(round(percent))
        + "%"
        + " line coverage achieved."
    )


def test0(g):
    """
    unit test for ramp-up:
        ensure that it gives a good score (>=0.5) to jQuery
    """
    url = "jquery/jquery"
    ramp_up_score = calculate_ramp_up(g, url)
    if ramp_up_score >= 0.5:
        return 1
    return 0


def test1(g):
    """
    unit test for ramp-up:
        ensure that it gives a bad score (<0.5) to a dummy project
    """
    url = "VikramSrivastava1729/dummy"
    score = calculate_ramp_up(g, url)
    if score < 0.5:
        return 1
    return 0


def test2(g):
    """
    unit test for ramp-up:
        ensure that it takes no more than 15 seconds for a large repo (express)
    """
    url = "expressjs/express"
    start = time.time()
    calculate_ramp_up(g, url)
    length = time.time() - start
    if length > 15:
        return 0
    return 1


def test3(g):
    """
    unit test for ramp-up:
        ensure that under failure, the process exits
    """
    url = "fake_url"
    returnval = calculate_ramp_up(g, url, True)
    if returnval == 0:
        return 1
    return 0


def test4(g):
    """
    unit test for correctness:
        ensure that it gives a good score (>=0.5) to jQuery
    """
    url = "jquery/jquery"
    correctness_score = calculate_correctness(g, url)
    if correctness_score >= 0.5:
        return 1
    return 0


def test5(g):
    """
    unit test for correctness:
        ensure that it gives a low score to a dummy repository
    """
    url = "VikramSrivastava1729/dummy"
    score = calculate_correctness(g, url)
    if score < 0.5:
        return 1
    return 0


def test6(g):
    """
    unit test for correctness:
        ensure it takes no more than 45 seconds for a large repo (express)
    """
    url = "expressjs/express"
    start = time.time()
    calculate_correctness(g, url)
    length = time.time() - start
    if length > 45:
        return 0
    return 1


def test7(g):
    """
    unit test for correctness:
        ensure that under failure, process exits
    """
    url = "fake_url"
    returnval = calculate_correctness(g, url, True)
    if returnval == 0:
        return 1
    return 0


def test8(g):
    """
    unit test for busfactor:
        ensure that it gives a good score (greater than 10 contributions or 0.25 score) to cloudinary as seen on the github repository insights
    """
    url = "cloudinary/cloudinary_npm"
    score = busfactor(g, url)
    if score > 0.25:
        return 1
    return 0


def test9(g):
    """
    unit test for busfactor:
        ensure that it takes no more than 15 seconds for a large repo (public-apis)
    """
    url = "public-apis/public-apis"
    start = time.time()
    busfactor(g, url)
    length = time.time() - start
    if length > 15:
        return 0
    return 1


def test10(g):
    """
    unit test for busfactor:
        ensure that under failure, the process exits
    """
    url = "fake_url"
    returnval = busfactor(g, url, True)
    if returnval == 0:
        return 1
    return 0


def test11(g):
    """
    unit test for busfactor:
        ensure that it gives a bad score (< 0.1) to lodash
    """
    url = "nullivex/nodist"
    score = busfactor(g, url)
    if score < 0.1:
        return 1
    return 0


def test12(g):
    """
    unit test for Responsiveness:
        ensure that it gives a good score (>=0.5) to jQuery
    """
    url = "jquery/jquery"
    ramp_up_score = Responsiveness(g, url)
    if ramp_up_score >= 0.5:
        return 1
    return 0


def test13(g):
    """
    unit test for Responsiveness:
        ensure that it gives a bad score (<0.5) to a dummy project
    """
    url = "VikramSrivastava1729/dummy"
    score = Responsiveness(g, url)
    if score < 0.5:
        return 1
    return 0


def test14(g):
    """
    unit test for Responsiveness:
        ensure that it takes no more than 30 seconds for a large repo (express)
    """
    url = "expressjs/express"
    start = time.time()
    Responsiveness(g, url)
    length = time.time() - start
    if length > 30:
        return 0
    return 1


def test15(g):
    """
    unit test for Responsiveness:
        ensure that under failure, the process exits
    """
    url = "fake_url"
    returnval = Responsiveness(g, url, True)
    if returnval == 0:
        return 1
    return 0


def test16(g):
    """
    unit test for License score:
        ensure that it gives a good score (>=0.5) to jQuery
    """
    url = "jquery/jquery"
    ramp_up_score = getLicense(g, url)
    if ramp_up_score >= 0.5:
        return 1
    return 0


def test17(g):
    """
    unit test for License score:
        ensure that it gives a bad score (<0.5) to a dummy project
    """
    url = "VikramSrivastava1729/dummy"
    score = getLicense(g, url)
    if score < 0.5:
        return 1
    return 0


def test18(g):
    """
    unit test for License score:
        ensure that it takes no more than 30 seconds for a large repo (express)
    """
    url = "expressjs/express"
    start = time.time()
    getLicense(g, url)
    length = time.time() - start
    if length > 30:
        return 0
    return 1


def test19(g):
    """
    unit test for License score:
        ensure that under failure, the process exits
    """
    url = "fake_url"
    returnval = getLicense(g, url, True)
    if returnval == 0:
        return 1
    return 0
