"""This module performs individual and overall scoring for a 3"""

import logging
import glob
from datetime import date, datetime, timedelta
import re
import os
import base64
import sys
import requests
from github import Github, GithubException
from bs4 import BeautifulSoup
from dateutil.relativedelta import relativedelta

# os.environ["$LOG_FILE"] = "1"
# os.environ["GITHUB_TOKEN"] = "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"


def perform(urls, url_file):
    """Perform scoring for the given urls"""
    log_file = os.getenv("LOG_FILE")
    log_level = os.getenv("LOG_LEVEL")
    if log_level == "2":
        logging.basicConfig(
            filename=log_file,
            filemode="w",
            level=logging.DEBUG)
    elif log_level == "1":
        logging.basicConfig(
            filename=log_file,
            filemode="w",
            level=logging.INFO)
    gtoken = os.getenv("GITHUB_TOKEN")
    git = Github(gtoken)
    if gtoken is None:
        print("No Github token specified in environment")
        sys.exit(1)

    with open(url_file, encoding='utf-8', mode='r') as file:
        raw_url_list = file.read().splitlines()

    column_values = [
        'URL',
        'NET_SCORE',
        'RAMP_UP_SCORE',
        'CORRECTNESS_SCORE',
        'BUS_FACTOR_SCORE',
        'RESPONSIVE_MAINTAINER_SCORE',
        'LICENSE_SCORE'
    ]

    print(*column_values, sep=' ')

    calc_scores(git, urls, raw_url_list)


def calc_scores(git, urls, raw_url_list):
    """Calculates scores of urls"""
    for i in enumerate(urls):
        url = urls[i]
        raw_url = raw_url_list[i]

        logging.info("Responsiveness calculation started..")
        responsiveness_score = get_responsiveness_score(git, url)
        logging.info("Responsiveness score calculation success")
        license_score = get_license_score(git, url)
        logging.info("License score calculation success")
        ramp_up_score = calculate_ramp_up(git, url)
        correctness_score = calculate_correctness(git, url)
        bus_factor = busfactor(git, url)
        net_score = netscore(
            responsiveness_score,
            license_score,
            ramp_up_score,
            correctness_score,
            bus_factor,
        )
        print(
            raw_url
            + " "
            + str(net_score)
            + " "
            + str(ramp_up_score)
            + " "
            + str(correctness_score)
            + " "
            + str(bus_factor)
            + " "
            + str(responsiveness_score)
            + " "
            + str(license_score)
        )


def parse(url_file):
    """URL parser function"""
    logging.info("Parsing url file")
    # For testing
    # filename = 'Sample Url File.txt'
    urls = []
    with open(url_file, encoding='utf-8', mode='r') as file:
        for urll in file.read().splitlines():
            if urll.startswith("https://www.npmjs"):
                req = requests.get(urll)
                soup = BeautifulSoup(req.content, "html.parser")
                full_url = soup.find_all("span")[-1].get_text()
                url = full_url.replace("github.com/", "")
                urls.append(url.rstrip())
            elif urll.startswith("https://github.com/"):
                url = urll.replace("https://github.com/", "")
                urls.append(url.rstrip())
            else:
                print("Invalid URL: " + str(urll))
                sys.exit(1)
    logging.info("Parsing url file successful")
    return urls


def get_responsiveness_score(git, url, testing=False):
    """Responsiveness score calculation"""
    responsiveness_score = 0
    try:
        repo = git.get_repo(url)
    except GithubException:
        if testing:
            return 0
    if git is None:
        print("No Github token specified in environment")
        sys.exit(1)

    issue_ratio = 0
    try:
        logging.info("Repository API call")
        # Issues post count

        # git = Github(gtoken)
        repo = git.get_repo(url)

        openissues = repo.get_issues(state="open", since=datetime.now() - timedelta(days=365))
        closedissues = repo.get_issues(state="closed", since=datetime.now() - timedelta(days=365))

        issue_ratio = len(closedissues.get_page(0)) / (
            len(openissues.get_page(0)) + len(closedissues.get_page(0))
        )

        # Pull requests count
        closed_requests = []
        all_requests = []
        closed_pullrequests = repo.get_pulls(sort="created", state="closed")
        all_pullrequests = repo.get_pulls(sort="created", state="all")
        for pull in closed_pullrequests:
            closed_requests.append(pull)
        for apull in all_pullrequests:
            all_requests.append(apull)

        # pull request ratio calculation
        pullrequest_ratio = len(closed_requests) / len(all_requests)
        logging.info("pull request ratio calculation...")

        # Responsiveness score
        responsiveness_score = (pullrequest_ratio * 0.5) + (issue_ratio * 0.5)
        logging.info("Responsiveness score calculation success")

    except GithubException:
        logging.error("Repository API call unsuccessful")

    return round(responsiveness_score, 1)


# Reference
# https://towardsdatascience.com/all-the-things-you-can-do-with-github-api-and-python-f01790fca131


def get_license_score(git, url, testing=False):
    """Determines the license score of a GitHub repository"""
    try:
        grepo = git.get_repo(url)
    except GithubException:
        if testing:
            return 0
        print("Invalid repository")
        sys.exit(1)

    licensed = None
    license_score = 0

    try:
        logging.info("searching for LICENSE file...")
        grepo = git.get_repo(url)

        lic = base64.b64decode(grepo.get_license().content.encode()).decode()

        if lic is not None:
            mitlic = re.search("(\\w+) License", lic).group(0)
            if mitlic is not None:
                logging.info("LICENSE file found")
                licensed = 1

    except GithubException:
        logging.info("LICENSE file not found")
        logging.info("searching for README...")
        try:
            readme = base64.b64decode(
                grepo.get_readme().content.encode()).decode()
            if readme is not None:
                logging.info("README file found")
                licensed = re.search("(\\w+) license", readme).group(0)
                if licensed is not None:
                    licensed = 1

        except GithubException:
            pass

    finally:
        if licensed is not None:
            license_score = 1
            logging.info("LGPL compatible License found")
            # print(f"License score: {License_score}")

    return license_score


# Reference: https://github.com/PyGithub/PyGithub/pull/734/files#


def clone_repo(url):
    """Clones given git repository"""
    clone_command = "git clone https://github.com/" + url + ".git" + " -q"
    os.system(clone_command)


def delete_repo(directory):
    """Deletes cloned directory"""
    delete_clone_command = "rm -rf " + directory
    os.system(delete_clone_command)


def calculate_ramp_up(git, url, testing=False):
    """Calculates the ramp-up score for a given repository."""
    score = 0
    try:
        repo = git.get_repo(url)
    except GithubException:
        if testing:
            return 0
        print("Invalid Repository")
        sys.exit(1)
    # open largest file of source code, parse line by line for comments, calculate percentage
    # 30% of score
    directory = url.split("/")[1]
    clone_repo(url)

    # find largest file
    repo_dir = os.getcwd() + "/" + directory
    filter_obj = filter(
        os.path.isfile,
        glob.glob(
            repo_dir + "/*",
            recursive=True))
    # above line taken from
    # https://thispointer.com/python-find-the-largest-file-in-a-directory/
    files = list(filter_obj)
    if len(files) < 1:
        delete_repo(directory)
        return 0
    max_size = os.path.getsize(files[0])
    max_file = files[0]
    for file in files:
        cur_size = os.path.getsize(file)
        if cur_size > max_size:
            max_size = cur_size
            max_file = file

    with open(max_file, encoding='utf-8', mode='r') as file:
        file_content = file.read().splitlines()

    # get commented lines
    score += get_comments_subscore(file_content)

    delete_repo(directory)

    score += get_readme_subscore(repo)

    return round(score, 1)


def get_comments_subscore(file_content):
    """Gets comments subscore of ramp up score based on number of comments in file"""
    subscore = 0
    total_lines = len(file_content)
    commented_lines = sum(
        1
        for line in file_content
        if "#" in line or "//" in line or "/*" in line or "*/" in line
    )

    percentage = commented_lines / total_lines
    if percentage >= 0.2:
        subscore += 0.2
    else:
        subscore += percentage
    return subscore


def get_readme_subscore(repo):
    """Gets subscore of ramp-up score based on length of readme"""
    # find length of README
    # 70% of score
    subscore = 0
    try:
        readme = repo.get_contents("README.md")
        lines = len(readme.decoded_content.splitlines())
        if lines > 500:
            subscore += 0.7
        else:
            subscore += 0.7 * (lines / 500)
    except GithubException as exception:
        print(exception)
    return subscore



def calculate_correctness(github, url, testing=False):
    """Calculates the correctness of a GitHub repository"""
    try:
        repo = github.get_repo(url)
    except GithubException:
        if testing:
            return 0
        print("Invalid Repository")
        sys.exit(1)

    score = 0

    # num stars
    # 40%
    stars = repo.stargazers_count
    if stars >= 1000:
        score += 0.4
    else:
        score += 0.4 * (stars / 1000)

    # length README
    # 20%
    try:
        readme = repo.get_contents("README.md")
        lines = len(readme.decoded_content.splitlines())
        if lines > 1000:
            score += 0.2
        else:
            score += 0.2 * (lines / 1000)
    except GithubException:
        pass

    # num pull requests in past 6 months
    # 40%
    pulls = repo.get_pulls("all")
    six_months_ago = date.today() + relativedelta(months=-6)
    recent_pulls = len(
        [pull for pull in pulls if pull.created_at.date() >= six_months_ago]
    )
    if recent_pulls <= 100:
        score += 0.4 - (recent_pulls / 250)

    return round(score, 1)


def busfactor(github, url, testing=False):
    """Calculates the bus factor score of a repository."""
    score = 0
    try:
        repo = github.get_repo(url)
    except GithubException:
        if testing:
            return 0
        print("Invalid Repository")
        sys.exit(1)

    # Find the number of contribuors
    try:
        # Find commits from past 365 days
        oneyear = datetime.now() - timedelta(days=365)
        contributions = repo.get_commits(since=oneyear)
        final_list = []
        # Change format of list of commits
        for commit in contributions:
            final_list.append(
                commit.commit.author.email
            )  # This has limitations past 500 emails (potentially)
        # Remove duplicates from list of contributors
        final_list = list(set(final_list))
        # print(final_list)
        numc = len(final_list)
        # print(numc)

        # Scoring System
        #
        if numc > 40:
            score = 1
        else:
            score = float(numc) / 40

        return score
    except GithubException:
        pass

    return round(score, 1)


def netscore(responsiveness, licensing, rampup, correctness, busfact):
    """Calculate the net total score using the individual components."""
    # # Set metric values for testing
    # rampup = 1
    # correctness = 1
    # busfact = 1
    # responsiveness = 1
    # licensing = 1

    # Licensing is essential
    if licensing == 0:
        return 0

    busfact = 0.3 * busfact
    responsiveness = 0.3 * responsiveness
    correctness = 0.25 * correctness
    rampup = 0.15 * rampup

    score = busfact + responsiveness + correctness + rampup

    return round(score, 1)
