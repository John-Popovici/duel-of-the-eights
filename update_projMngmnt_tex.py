import os
from datetime import datetime
from github import Github
import re
# Set the repository details
repo_name = "John-Popovici/duel-of-the-eights"  # Replace with your repository name
access_token = os.getenv("GITHUB_TOKEN")  # GitHub token will be used from the environment variable
# Initialize GitHub API
g = Github(access_token)
repo = g.get_repo(repo_name)
# Get the current date and the start date (Nov 25th)
# Get the current date and the start date (Nov 25th)
current_date = datetime(2025, 1, 29)
start_date = datetime(2024, 12, 29)

# Function to get commit count by author within a date range
def get_commits_by_author():
    commits = {}
    page = 1
    while True:
        url = f'https://api.github.com/repos/{repo_name}/commits'
        params = {
            'since': start_date.isoformat(),
            'until': current_date.isoformat(),
            'page': page,
            'per_page': 100
        }
        headers = {'Authorization': f'token {access_token}'}
        response = requests.get(url, params=params, headers=headers)
        commits_data = response.json()

        if not commits_data:
            break  # No more commits, exit the loop

        for commit in commits_data:
            author = commit['commit']['author']['name']
            commits[author] = commits.get(author, 0) + 1

        page += 1

    return commits

# Function to update the LaTeX file with commit counts
def update_tex_file(commits):
    with open("docs/projMngmnt/Rev0_Team_Contrib.tex", "r") as file:
        tex_content = file.read()

    # Replace the commit values for each team member in the LaTeX macros
    tex_content = tex_content.replace(r"\pgfmathsetmacro{\CJ}{11}", f"\\pgfmathsetmacro{{\\CJ}}{{{commits.get('John-Popovici', 0)}}}")
    tex_content = tex_content.replace(r"\pgfmathsetmacro{\CN}{2}", f"\\pgfmathsetmacro{{\\CN}}{{{commits.get('nigelmoses32', 0)}}}")
    tex_content = tex_content.replace(r"\pgfmathsetmacro{\CNS}{11}", f"\\pgfmathsetmacro{{\\CNS}}{{{commits.get('STARS952', 0)}}}")
    tex_content = tex_content.replace(r"\pgfmathsetmacro{\CI}{0}", f"\\pgfmathsetmacro{{\\CI}}{{{commits.get('Isaac020717', 0)}}}")
    tex_content = tex_content.replace(r"\pgfmathsetmacro{\CH}{0}", f"\\pgfmathsetmacro{{\\CH}}{{{commits.get('HemrajB87', 0)}}}")

    # Write the updated content back to the file
    with open("docs/projMngmnt/Rev0_Team_Contrib.tex", "w") as file:
        file.write(tex_content)

# Main execution
if __name__ == "__main__":
    commits = get_commits_by_author()
    update_tex_file(commits)