## Key Components

### Composite Action (`.github/actions/slack-cli-installer/action.yml`)
- Installs Slack CLI and executes commands
- Handles installation across OS systems and caching
- Inputs: `command`, `verbose`, `cli_version`
- Outputs: `success`, `command_executed`, `stdout`, `stderr`

### Workflow (`.github/workflows/XXX.yml`)
- Calls the composite action 
- Includes Manual dispatch and input types 

### Test Suite (`test/cli-runner.test.js`)
- Mocha + Chai + Sinon
- Unit tests for input validation, integration tests, error handling

## Testing

### **Local Testing**
```bash
npm test
```

## Common Errors

### **Action Not Found**
- Check action path in workflow
- Verify action.yml exists and is valid

### **CLI Installation Fails**
- Check installation link is valid
- Use GitHub's [testing matrix](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/run-job-variations)

### **Command Execution Errors**
- Verify service token is valid and in GitHub secrets 
- Make sure command does not have Slack prefix (e.g. `version` not `slack version`)

## Debugging

Use the `--verbose` flag for detailed outputs and check GitHub Actions logs. 
Or, test locally with similar environment verify inputs are being passed correctly

### To Update When a New Slack CLI Version Releases

### **1. Update CLI Version in Action**
```yaml
#.github/actions/slack-cli-installer/action.yml
inputs:
  cli_version:
    description: "Slack CLI Version"
    required: false
    default: '3.6.0'  # Update here
```

## Changes to Watch For

### **CLI Command Changes**
- New authentication requirements

### **Installation Changes**
- New dependencies 
- Changed download URLs
- New installation flags

