import re
import os
from github import Github
from datetime import datetime

# Repository details
repo_name = "John-Popovici/duel-of-the-eights"
file_path = "docs/projMngmnt/Rev0_Team_Contrib.tex"
start_date = "2024-11-25T00:00:00Z"  # From Nov 25, 2024
end_date = datetime.utcnow().isoformat() + "Z"  # Current UTC time

# Authenticate using GITHUB_TOKEN
github_token = os.getenv("GITHUB_TOKEN")
if not github_token:
    raise ValueError("GITHUB_TOKEN is not set in the environment variables.")

# Authenticate to GitHub
g = Github(github_token)
repo = g.get_repo(repo_name)

# Team members' GitHub usernames
team_members = {
    "CJ": "John-Popovici",
    "CN": "nigelmoses32",
    "CNS": "STARS952",
    "CI": "Isaac020717",
    "CH": "HemrajB87",
}

# Fetch commit counts per member
commit_counts = {key: 0 for key in team_members}
for commit in repo.get_commits(since=start_date, until=end_date):
    if commit.author and commit.author.login in team_members.values():
        for key, username in team_members.items():
            if commit.author.login == username:
                commit_counts[key] += 1

# Calculate total commits and percentages
total_commits = sum(commit_counts.values())
percentages = {key: (count / total_commits * 100) if total_commits else 0 for key, count in commit_counts.items()}

# Read LaTeX file
with open(file_path, "r", encoding="utf-8") as file:
    tex_content = file.read()

# Update only the \section{Commits} part
for key, count in commit_counts.items():
    tex_content = re.sub(rf"\\pgfmathsetmacro{{\\{key}}}{{\d+}}", f"\\pgfmathsetmacro{{\\{key}}}{{{count}}}", tex_content)

# Update total commits
tex_content = re.sub(r"\\pgfmathsetmacro{\\CT}{\d+}", f"\\pgfmathsetmacro{{\\CT}}{{{total_commits}}}", tex_content)

# Write updated content back to the file
with open(file_path, "w", encoding="utf-8") as file:
    file.write(tex_content)

print("Updated the Commits section of projMngmnt tex file.")