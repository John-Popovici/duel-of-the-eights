import os
import requests
import json
from datetime import datetime

repo_name = "John-Popovici/duel-of-the-eights"
file_path = "docs/projMngmnt/Rev0_Team_Contrib.tex"
start_date = "2024-11-25T00:00:00Z"  # From Nov 25, 2024
current_date = datetime.utcnow().isoformat() + "Z"  # Current UTC time

# Authenticate using GITHUB_TOKEN
github_token = os.getenv("GITHUB_TOKEN")
if not github_token:
    raise ValueError("GITHUB_TOKEN is not set in the environment variables.")

g = Github(github_token)
repo = g.get_repo(repo_name)

# Define team members and their GitHub usernames
team_members = {
    "CJ": "John-Popovici",
    "CN": "nigelmoses32",
    "CNS": "STARS952",
    "CI": "Isaac020717",
    "CH": "HemrajB87",
}

# Get commits and total commits
def get_commits():
    commits = {}
    total_commits = 0
    for commit in repo.get_commits(since=start_date, until=current_date):
        author = commit.commit.author.name
        commits[author] = commits.get(author, 0) + 1
        total_commits += 1
    return commits, total_commits

# Fetch commit counts per member
commit_counts, total_commits = get_commits()

# Filter commit counts based on team members
filtered_commit_counts = {key: commit_counts.get(username, 0) for key, username in team_members.items()}

# Calculate percentages
percentages = {key: (count / total_commits * 100) if total_commits else 0 for key, count in filtered_commit_counts.items()}

# Read LaTeX file
with open(file_path, "r", encoding="utf-8") as file:
    tex_content = file.read()

# Update only the \section{Commits} part
for key, count in filtered_commit_counts.items():
    tex_content = tex_content.replace(f"\\pgfmathsetmacro{{\\{key}}}{{\d+}}", f"\\pgfmathsetmacro{{\\{key}}}{{{count}}}")

# Update total commits
tex_content = tex_content.replace(r"\\pgfmathsetmacro{\\CT}{\d+}", f"\\pgfmathsetmacro{{\\CT}}{{{total_commits}}}")

# Write updated content back to the file
with open(file_path, "w", encoding="utf-8") as file:
    file.write(tex_content)

print("Updated the Commits section in LaTeX file.")