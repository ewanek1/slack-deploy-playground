## Components

### Workflow (`.github/workflows/slack-cli-github-action.yml`)
- Functions by manual dispatch
- Defines action inputs
- Calls the composite action 
- Calls the test workflow 
- Inputs: `command`, `verbose`, `cli_version`, `app_id`
- Outputs: `success`, `command_executed`, `stdout`

### Composite Action (`.github/actions/slack-cli-installer/action.yml`)
- Handles CLI caching and installation across OS systems
- Executes commands

### Test Worklow (`.github/workflows/test-workflow.yml`)
- Tests for valid/invalid inputs, CLI versions, flags, caching
- Validates across OS systems 

## Common Errors

### Action Not Found
- Check action path in workflow
- Verify action.yml exists and is valid

### CLI Installation Fails
- Check installation link is valid
- Use GitHub's [testing matrix](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/run-job-variations) for clearer outputs

### Command Execution Errors
- Verify service token is valid and in GitHub secrets 
- Make sure command does not have Slack prefix (e.g. `version` not `slack version`)

## Debugging

Check the `Verbose flag` for detailed outputs and check GitHub Actions logs. 
Or, test locally with similar environment verify inputs are being passed correctly.

## To Update When a New Slack CLI Version Releases

- All components use `"latest"` for the Slack CLI version, so no hardcoded versioning update is needed.

## Changes to Watch For

### Installation Changes
- New dependencies 
- Changed download URLs
- New installation flags

### CLI Command Changes
- New authentication requirements

