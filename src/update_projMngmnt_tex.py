import os
from datetime import datetime
from github import Github

# Set the repository details
repo_name = "John-Popovici/duel-of-the-eights"  # Replace with your repository name
access_token = os.getenv("GITHUB_TOKEN")  # GitHub token will be used from the environment variable

# Initialize GitHub API
g = Github(access_token)
repo = g.get_repo(repo_name)

# Get the current date and the start date (Nov 25th)
current_date = datetime.now()
start_date = datetime(2024, 11, 25)

# Function to fetch commits from the repository
def get_commits():
    commits = {}
    total_commits = 0
    for commit in repo.get_commits(since=start_date, until=current_date):
        author = commit.commit.author.name
        commits[author] = commits.get(author, 0) + 1
        total_commits += 1
    return commits, total_commits

# Function to fetch issues authored and assigned by each member
def get_issues():
    issues = {}
    for issue in repo.get_issues(state='all', since=start_date):
        # Count authored issues
        if issue.user.login not in issues:
            issues[issue.user.login] = {'authored': 0, 'assigned': 0}
        issues[issue.user.login]['authored'] += 1
        
        # Count assigned issues (only closed)
        if issue.assignee and issue.state == 'closed':
            issues[issue.assignee.login]['assigned'] += 1
    return issues

# Function to update the LaTeX file
def update_tex_file(commits, total_commits, issues):
    with open("docs/projMngmnt/Rev0_Team_Contrib.tex", "r") as file:
        tex_content = file.read()

    # Update commits section
    for author, count in commits.items():
        tex_content = tex_content.replace(f"{author} & Num", f"{author} & {count}")
    tex_content = tex_content.replace("Num", str(total_commits))

    # Update issues section
    for author, data in issues.items():
        tex_content = tex_content.replace(f"{author} & Num & Num", 
                                          f"{author} & {data['authored']} & {data['assigned']}")

    # Write the updated content back to the file
    with open("docs/projMngmnt/Rev0_Team_Contrib.tex", "w") as file:
        file.write(tex_content)

# Main execution
if __name__ == "__main__":
    commits, total_commits = get_commits()
    issues = get_issues()
    update_tex_file(commits, total_commits, issues)
