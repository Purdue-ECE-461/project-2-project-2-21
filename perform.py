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
        return

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

    for i in range(len(urls)):
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
        if responsiveness_score is None or license_score is None or \
                ramp_up_score is None or correctness_score is None or bus_factor is None:
            return
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
                return
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
        return

    issue_ratio = 0
    try:
        logging.info("Repository API call")
        # Issues post count

        # git = Github(gtoken)
        repo = git.get_repo(url)

        since = datetime.now() - timedelta(days=365)
        openissues = repo.get_issues(state="open", since=since)
        closedissues = repo.get_issues(state="closed", since=since)

        issue_ratio = len(closedissues.get_page(0)) / (
            len(openissues.get_page(0)) + len(closedissues.get_page(0)) + 0.01
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
        pullrequest_ratio = len(closed_requests) / (len(all_requests)+0.01)
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
        return

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


def calculate_ramp_up(git, url, testing=False):
    """Calculates the ramp-up score for a given repository."""
    score = 0
    try:
        repo = git.get_repo(url)
    except GithubException:
        if testing:
            return 0
        print("Invalid Repository")
        return
    # open largest file of source code, parse line by line for comments, calculate percentage
    # 30% of score
    clone_command = "git clone https://github.com/" + url + ".git" + " -q"
    directory = url.split("/")[1]
    delete_clone_command = "rm -rf " + directory
    os.system(clone_command)

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
        os.system(delete_clone_command)
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
    total_lines = len(file_content)
    commented_lines = sum(
        1
        for line in file_content
        if "#" in line or "//" in line or "/*" in line or "*/" in line
    )

    percentage = commented_lines / total_lines
    if percentage >= 0.2:
        score += 0.2
    else:
        score += percentage
    delete_clone_command = "rm -rf " + directory
    os.system(delete_clone_command)

    # find length of README
    # 70% of score
    try:
        readme = repo.get_contents("README.md")
        lines = len(readme.decoded_content.splitlines())
        if lines > 500:
            score += 0.7
        else:
            score += 0.7 * (lines / 500)
    except GithubException as exception:
        print(exception)

    return round(score, 1)


def calculate_correctness(github, url, testing=False):
    """Calculates the correctness of a GitHub repository"""
    try:
        repo = github.get_repo(url)
    except GithubException:
        if testing:
            return 0
        print("Invalid Repository")
        return

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
        return

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

def get_update_score(github, url, testing=False):
    """Calculate update score of the package. This is a measure
    of the last time the package did a release or commit"""
    update_score = 0
    try:
        repo = github.get_repo(url)
    except GithubException:
        if testing:
            return 0
        print("Invalid Repository")
        return
    # Read time of last release and commit
    try:
        deadline = datetime.combine(
            date.today() + relativedelta(months=-12),
            datetime.min.time()
        )
        now = datetime.now()
        # Time of last release
        releases = repo.get_releases()
        release_dates = []
        for release in releases:
            release_dates.append(release.published_at)
        latest_release = datetime.now() - relativedelta(months=100)
        if len(release_dates) > 0:
            latest_release = max(release_dates)
        # Time of last commit
        commits = repo.get_commits(since=deadline)
        data = commits.get_page(0)
        latest_commit = datetime.now() - relativedelta(months=100)
        if len(data) > 0:
            latest_commit = data[0].commit.author.date
        # Determine score from these values
        one_month_ago = datetime.now() - relativedelta(months=1)
        one_year_ago = datetime.now() - relativedelta(months=12)
        three_years_ago = datetime.now() - relativedelta(months=36)
        # Based on release
        if latest_release > one_year_ago:
            update_score = 1
        elif latest_release > three_years_ago:
            update_score = 0.5
        else:
            update_score = 0
         # Based on commit
        if latest_commit > one_month_ago:
            update_score *= 1
        elif latest_commit > one_year_ago:
            update_score *= 0.5
        else:
            update_score *= 0

    except GithubException:
       pass

    return update_score



def netscore(responsiveness, licensing, rampup, correctness, busfact, update):
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
    responsiveness = 0.25 * responsiveness
    correctness = 0.2 * correctness
    rampup = 0.15 * rampup
    update = 0.1 * update

    score = busfact + responsiveness + correctness + rampup + update

    return round(score, 1)


def main():
    """Run scoring functionality."""
    urls = parse()
    # Responsiveness(urls)

    perform(urls)
    # getLicense(urls)


if __name__ == "__main__":
    main()
