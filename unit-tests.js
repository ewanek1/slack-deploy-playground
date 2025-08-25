const { assert } = require("chai");
const { mocks } = require("./index.spec.js");
const { runCLI } = require("./workflows/temp.yml");


describe("check if input is valid", () => {
  beforeEach(() => {
    mocks.core.reset();
  });

  describe("input commands", () => {
    it("accepts empty command", async () => {
        mocks.core.getInput.withArgs("command").returns("");
        mocks.core.getInput.withArgs("verbose").returns("false");
        mocks.core.getInput.withArgs("cli_version").returns("latest");

        const result = await runCLI(mocks.core); 
        
        assert.isTrue(result.isValid);
        assert.include(result.command, "");

        assert.isTrue(mocks.core.setOutput.calledWith("success", "true"));
        assert.isTrue(mocks.core.getInput.calledWith("command"));
        assert.isTrue(mocks.core.getInput.calledWith("verbose"));
        assert.isTrue(mocks.core.getInput.calledWith("cli_version"));
    });

    it("accept valid version command", async () => {
        mocks.core.getInput.withArgs("command").returns("version");
        mocks.core.getInput.withArgs("verbose").returns("false");
        mocks.core.getInput.withArgs("cli_version").returns("latest");

        const result = await runCLI(mocks.core); 

        assert.isTrue(result.isValid);
        assert.include(result.command, "slack version --skip-update");

        assert.isTrue(mocks.core.getInput.calledWith("command"));
        assert.isTrue(mocks.core.getInput.calledWith("verbose"));
        assert.isTrue(mocks.core.getInput.calledWith("cli_version"));

        assert.isTrue(mocks.core.setOutput.calledWith("success", "true"));
        assert.isTrue(mocks.core.setOutput.calledWith("stdout", "Using slack v3.6.0"));
        assert.isTrue(mocks.core.setOutput.calledWith("command_executed", "slack version --skip-update"));
    });
    
    it("accept valid command", async () => {
        mocks.core.getInput.withArgs("command").returns("auth list");
        mocks.core.getInput.withArgs("verbose").returns("false");
        mocks.core.getInput.withArgs("cli_version").returns("latest");
        
        const result = await runCLI(mocks.core); 

        assert.isTrue(result.isValid);
        assert.include(result.command, "slack auth list --skip-update");
        
        assert.isTrue(mocks.core.getInput.calledWith("command"));
        assert.isTrue(mocks.core.getInput.calledWith("verbose"));
        assert.isTrue(mocks.core.getInput.calledWith("cli_version"));

        assert.isTrue(mocks.core.setOutput.calledWith("success", "true"));
        assert.isTrue(mocks.core.setOutput.calledWith("command_executed", "slack auth list --skip-update"));
    });

    it("accept commands with arguments", async () => {
        mocks.core.getInput.withArgs("command").returns("channels XXX");
        mocks.core.getInput.withArgs("verbose").returns("false");
        mocks.core.getInput.withArgs("cli_version").returns("latest");
        
        const result = await runCLI(mocks.core); 

        assert.isTrue(result.isValid);
        assert.include(result.command, "slack XXX --skip-update");
        
        assert.isTrue(mocks.core.getInput.calledWith("command"));
        assert.isTrue(mocks.core.getInput.calledWith("verbose"));
        assert.isTrue(mocks.core.getInput.calledWith("cli_version"));

        assert.isTrue(mocks.core.setOutput.calledWith("success", "true"));
        assert.isTrue(mocks.core.setOutput.calledWith("command_executed", "slack XXX --skip-update"));
    });

    it("use verbose mode when wanted", async () => {
        mocks.core.getInput.withArgs("command").returns("version");
        mocks.core.getInput.withArgs("verbose").returns("true");
        mocks.core.getInput.withArgs("cli_version").returns("latest");
      
        const result = await runCLI(mocks.core); 

        assert.isTrue(result.isValid);
        assert.include(result.command, "version --verbose --skip-update");
      
        assert.isTrue(mocks.core.getInput.calledWith("command"));
        assert.isTrue(mocks.core.getInput.calledWith("verbose"));
        assert.isTrue(mocks.core.getInput.calledWith("cli_version"));

        assert.isTrue(mocks.core.setOutput.calledWith("success", "true"));
    });

    it("accept very long commands", async () => {
        const longCommand = " --skip-update"
        mocks.core.getInput.withArgs("command").returns(longCommand);
        mocks.core.getInput.withArgs("verbose").returns("false");
        mocks.core.getInput.withArgs("cli_version").returns("latest");
      
        const result = await runCLI(mocks.core); 

        assert.isTrue(result.isValid);
        assert.include(result.command, longCommand);
      
        assert.isTrue(mocks.core.getInput.calledWith("command"));
        assert.isTrue(mocks.core.getInput.calledWith("verbose"));
        assert.isTrue(mocks.core.getInput.calledWith("cli_version"));

        assert.isTrue(mocks.core.setOutput.calledWith("success", "true"));
        //assert.isTrue(mocks.core.setOutput.calledWith("stdout", "Using slack v3.6.0"));
        assert.isTrue(mocks.core.setOutput.calledWith("command_executed", longCommand));
    });

    it("accept special characters in commands", async () => {
        mocks.core.getInput.withArgs("command").returns("xxx'");
        mocks.core.getInput.withArgs("verbose").returns("false");
        mocks.core.getInput.withArgs("cli_version").returns("latest");
      
        const result = await runCLI(mocks.core); 

        assert.isTrue(result.isValid);
        assert.include(result.command, "slack xxx --skip-update");
      
        assert.isTrue(mocks.core.getInput.calledWith("command"));
        assert.isTrue(mocks.core.getInput.calledWith("verbose"));
        assert.isTrue(mocks.core.getInput.calledWith("cli_version"));

        assert.isTrue(mocks.core.setOutput.calledWith("success", "true"));
        assert.isTrue(mocks.core.setOutput.calledWith("stdout", "Using slack v3.6.0"));
        assert.isTrue(mocks.core.setOutput.calledWith("command_executed", "slack xxx --skip-update"));
    });

    it("rejects invalid command", async () => {
        mocks.core.getInput.withArgs("command").returns("random");
        mocks.core.getInput.withArgs("verbose").returns("false");
        mocks.core.getInput.withArgs("cli_version").returns("latest");
      
        const result = await runCLI(mocks.core); 

        assert.include(result.command, "slack random --skip-update");
      
        assert.isTrue(mocks.core.getInput.calledWith("command"));
        assert.isTrue(mocks.core.getInput.calledWith("verbose"));
        assert.isTrue(mocks.core.getInput.calledWith("cli_version"));

        assert.isTrue(mocks.core.setOutput.calledWith("success", "false"));
        assert.isTrue(mocks.core.setOutput.calledWith("stdout", "unknown command"));
        assert.isTrue(mocks.core.setOutput.calledWith("command_executed", "slack random --skip-update"));
    });

    it("accept CLI version input", async () => {
        mocks.core.getInput.withArgs("command").returns("version");
        mocks.core.getInput.withArgs("verbose").returns("false");
        mocks.core.getInput.withArgs("cli_version").returns("3.5.0");
      
        const result = await runCLI(mocks.core); 

        assert.isTrue(result.isValid);
        assert.include(result.command, "slack version --skip-update");
      
        assert.isTrue(mocks.core.getInput.calledWith("command"));
        assert.isTrue(mocks.core.getInput.calledWith("verbose"));
        assert.isTrue(mocks.core.getInput.calledWith("cli_version"));

        assert.isTrue(mocks.core.setOutput.calledWith("success", "true"));
        assert.isTrue(mocks.core.setOutput.calledWith("stdout", "Using slack v3.5.0"));
        assert.isTrue(mocks.core.setOutput.calledWith("command_executed", "slack version 3.5.0 --skip-update"));
    });

    it("accept both verbose flag in command input and checkbox action input", async () => {
        mocks.core.getInput.withArgs("command").returns("version");
        mocks.core.getInput.withArgs("verbose").returns("true");
        mocks.core.getInput.withArgs("cli_version").returns("latest");
      
        const result = await runCLI(mocks.core); 

        assert.isTrue(result.isValid);
        assert.include(result.command, "slack version --verbose --verbose --skip-update");
      
        assert.isTrue(mocks.core.getInput.calledWith("command"));
        assert.isTrue(mocks.core.getInput.calledWith("verbose"));
        assert.isTrue(mocks.core.getInput.calledWith("cli_version"));

        assert.isTrue(mocks.core.setOutput.calledWith("success", "true"));
        assert.isTrue(mocks.core.setOutput.calledWith("stdout", "Using slack v3.6.0"));
        assert.isTrue(mocks.core.setOutput.calledWith("command_executed", "slack version --skip-update"));
    });

    it("accept command with leading whitespace", async () => {
        mocks.core.getInput.withArgs("command").returns("  version");
        mocks.core.getInput.withArgs("verbose").returns("false");
        mocks.core.getInput.withArgs("cli_version").returns("latest");

        const result = await runCLI(mocks.core); 
        
        assert.isTrue(result.isValid);
        assert.include(result.command, "slack version --skip-update");

        assert.isTrue(mocks.core.getInput.calledWith("command"));
        assert.isTrue(mocks.core.getInput.calledWith("verbose"));
        assert.isTrue(mocks.core.getInput.calledWith("cli_version"));

        assert.isTrue(mocks.core.setOutput.calledWith("success", "true"));
        assert.isTrue(mocks.core.setOutput.calledWith("stdout", "Using slack v3.6.0"));
        assert.isTrue(mocks.core.setOutput.calledWith("command_executed", "slack version --skip-update"));
    });

// Fill in commands

// Mock a slack app 

// slack login / how to bypass this 
  });
});





