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
start_date = datetime(2024, 11, 29)

# Function to fetch commits from the repository
def get_commits():
    commits = {}
    total_commits = 0
    for commit in repo.get_commits(since=start_date, until=current_date):  # Pass datetime objects directly
        author = commit.commit.author.name
        commits[author] = commits.get(author, 0) + 1
        total_commits += 1
    return commits, total_commits

# Function to update the LaTeX file
def update_tex_file(commits, total_commits):
    with open("docs/projMngmnt/Rev0_Team_Contrib.tex", "r") as file:
        tex_content = file.read()

    # Replace the commit values for each team member in the LaTeX macros
     # Replace the commit values for each team member in the LaTeX macros
    tex_content = tex_content.replace(r"\pgfmathsetmacro{\CJ}{\\d+}", f"\\pgfmathsetmacro{{\\CJ}}{{{commits.get('John-Popovici', 0)}}}")
    tex_content = tex_content.replace(r"\pgfmathsetmacro{\CN}{\d+}", f"\\pgfmathsetmacro{{\\CN}}{{{commits.get('nigelmoses32', 0)}}}")
    tex_content = tex_content.replace(r"\pgfmathsetmacro{\CNS}{\d+}", f"\\pgfmathsetmacro{{\\CNS}}{{{commits.get('STARS952', 0)}}}")
    tex_content = tex_content.replace(r"\pgfmathsetmacro{\CI}{\d+}", f"\\pgfmathsetmacro{{\\CI}}{{{commits.get('Isaac020717', 0)}}}")
    tex_content = tex_content.replace(r"\pgfmathsetmacro{\CH}{\d+}", f"\\pgfmathsetmacro{{\\CH}}{{{commits.get('HemrajB87', 0)}}}")

    # Update the total commit count
    #tex_content = tex_content.replace(r"\pgfmathsetmacro{\CN}{137}", f"\\pgfmathsetmacro{{\\CN}}{{{total_commits}}}")
    #tex_content = re.sub(r"\pgfmathsetmacro{\CJ}{\d+}", f"\\pgfmathsetmacro{{\\CJ}}{{{commits.get('John-Popovici', 0)}}}", tex_content)
    #tex_content = re.sub(r"\pgfmathsetmacro{\CN}{\d+}", f"\\pgfmathsetmacro{{\\CN}}{{{commits.get('nigelmoses32', 0)}}}", tex_content)
    #tex_content = re.sub(r"\pgfmathsetmacro{\CNS}{\d+}", f"\\pgfmathsetmacro{{\\CNS}}{{{commits.get('STARS952', 0)}}}", tex_content)
    #tex_content = re.sub(r"\pgfmathsetmacro{\CI}{\d+}", f"\\pgfmathsetmacro{{\\CI}}{{{commits.get('Isaac020717', 0)}}}", tex_content)
    #tex_content = re.sub(r"\pgfmathsetmacro{\CH}{\d+}", f"\\pgfmathsetmacro{{\\CH}}{{{commits.get('HemrajB87', 0)}}}", tex_content)


    # Update the total commit count
    #tex_content = re.sub(r"\pgfmathsetmacro{\CN}{\d+}", f"\\pgfmathsetmacro{{\\CN}}{{{total_commits}}}", tex_content)
    
    # Write the updated content back to the file
    with open("docs/projMngmnt/Rev0_Team_Contrib.tex", "w") as file:
        file.write(tex_content)

# Main execution
if __name__ == "__main__":
    commits, total_commits = get_commits()
    update_tex_file(commits, total_commits)