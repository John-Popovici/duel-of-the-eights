import os
import requests
import json
from datetime import datetime

# GitHub API settings
repo_owner = "John-Popovici"
repo_name = "duel-of-the-eights"
token = os.getenv("GH_TOKEN")  # Access the token from environment variables

# Date from which you want to start counting commits
start_date = datetime(2024, 11, 25)

# Define team members and their GitHub usernames
team_members = {
    "CJ": "John-Popovici",
    "CN": "nigelmoses32",
    "CNS": "STARS952",
    "CI": "Isaac020717",
    "CH": "HemrajB87",
}

# GitHub API URL for commits
url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/commits"

# Function to fetch commits from GitHub
def fetch_commits():
    commits = []
    page = 1
    while True:
        response = requests.get(
            url,
            params={"page": page, "per_page": 100},
            headers={"Authorization": f"token {token}"},
        )
        if response.status_code != 200:
            print(f"Error fetching commits: {response.status_code}")
            break

        data = response.json()
        if not data:
            break

        commits.extend(data)
        page += 1

    return commits

# Function to count commits for each team member
def count_commits(commits):
    commit_counts = {member: 0 for member in team_members}
    total_commits = 0

    for commit in commits:
        commit_date = datetime.strptime(commit["commit"]["author"]["date"], "%Y-%m-%dT%H:%M:%SZ")
        if commit_date >= start_date:
            author = commit["commit"]["author"]["name"]
            for member, username in team_members.items():
                if username in author:
                    commit_counts[member] += 1
                    total_commits += 1

    return commit_counts, total_commits

# Function to update the LaTeX file
def update_latex(commit_counts, total_commits):
    latex_file_path = "docs/projMngmnt/Rev0_Team_Contrib.tex"
    with open(latex_file_path, "r") as file:
        content = file.read()

    # Update the commit numbers in LaTeX
    for member, count in commit_counts.items():
        content = content.replace(f"\\pgfmathsetmacro{{\\{member}}}{{0}}", f"\\pgfmathsetmacro{{\\{member}}}{{{count}}}")

    content = content.replace("\\pgfmathsetmacro{\\totalCommits}{0}", f"\\pgfmathsetmacro{{\\totalCommits}}{{{total_commits}}}")

    # Write the updated content back to the file
    with open(latex_file_path, "w") as file:
        file.write(content)

# Main function to run the process
def main():
    commits = fetch_commits()
    commit_counts, total_commits = count_commits(commits)
    update_latex(commit_counts, total_commits)

if __name__ == "__main__":
    main()
