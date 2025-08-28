---
sidebar_label: Overview
---

# Run Slack CLI commands in GitHub Actions workflows 

This technique uses the Slack CLI in GitHub Actions to run commands through workflows.

Setting up a CI/CD pipeline [requires](https://docs.slack.dev/tools/slack-cli/guides/authorizing-the-slack-cli/#ci-cd) authorization using a service token. [Service tokens](https://docs.slack.dev/tools/slack-cli/guides/authorizing-the-slack-cli/#obtain-token) are long-lived, non-rotatable user tokens that don’t expire.

## Setup

1. Add your service token as a [repository secret](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets#creating-secrets-for-a-repository) called SLACK_SERVICE_TOKEN.
2. Add this workflow to your repository. GitHub Actions workflow files must be stored in the .github/workflows directory

```yaml
name: Slack CLI Command Runner
on:
  workflow_dispatch:
    inputs:
      command:
        description: 'Slack CLI command to run'
        required: true

jobs:
  run-slack-cli:  
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Run Slack CLI Command
        uses: slackapi/slack-github-action@main
        with:
          command: ${{ github.event.inputs.command }}
        env:
          SLACK_SERVICE_TOKEN: ${{ secrets.SLACK_SERVICE_TOKEN }}
```

3. Go to [Actions tab](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow#configuring-a-workflow-to-run-manually) in your GitHub repository.
4. Select the "Slack CLI Command Runner" workflow and click "Run workflow."
5. Enter your desired command without the 'slack' prefix (e.g., version, deploy).
6. Click "Run workflow" to execute the command.

## Usage

Instead of manual dispatch, you can configure your workflow to run automatically on specific GitHub events. Note that commands must be hardcoded
when using automatic triggers. The following examples show different trigger options:

#### On Pull Request:
```yaml
name: Slack CLI Command Runner
on:
  pull_request:
    branches: [main]

jobs:
  run-slack-cli: 
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
    
      - name: Run Slack CLI Command
        uses: slackapi/slack-github-action@main
        with:
          command: 'version'  
        env:
          SLACK_SERVICE_TOKEN: ${{ secrets.SLACK_SERVICE_TOKEN }}
```

#### On Push to Main:
```yaml
name: Slack CLI Command Runner
on:
  push:
    branches: [main]

jobs:
  run-slack-cli: 
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
    
      - name: Run Slack CLI Command
        uses: slackapi/slack-github-action@main
        with:
          command: 'version'  
        env:
          SLACK_SERVICE_TOKEN: ${{ secrets.SLACK_SERVICE_TOKEN }}
```
