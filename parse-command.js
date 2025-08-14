//import { execFile as testExecFile } from 'child_process';
//import { parseArgs } from 'node:util';
//JSON "type": "module",
//const { parseArgs } = require('node:util'); 
const { execFile: testExecFile } = require('child_process');
const core = require('@actions/core');
const Logger = require('./src/logger.js').default;

const { logger } = new Logger(core);

let execFile = testExecFile;

async function parse(rawInput) {
    const arrayOfCommands = rawInput.split(',');

    for (const command of arrayOfCommands) {

      logger.debug(`Running command: ${command}`);
      // split by spaces
      const tokens = command.trim().split(/\s+/);
      //console.log(tokens);

      if (!tokens.includes('slack')) {
          logger.error("Invalid syntax: command must contain 'slack'");
          throw new Error("Invalid syntax: command must contain 'slack'");
      }

      const args = tokens.slice(1); 
      //const parsed = parseArgs({ args }); 
 
      execFile('slack', args, (error, stdout, stderr) => {
          if (error) {
            logger.error(`Slack CLI error: ${error.message}`);
            return;
          }
          if (stderr) {
            console.warn(`stderr: ${stderr}`);
          }
          logger.info(stdout);
      });
    }
}

// Potential issue: this requires slack to be the first argument 

if (require.main === module) {
  // run script directly from terminal 
  // strips node and script.js before command 
  // e.g. 'node script.js slack deploy' --> 'slack deploy'
  const rawInput = process.argv.slice(2).join(' '); 
  parse(rawInput);
} else {  // export for unit testing
  module.exports = { 
    parse,
    setExecFile: (mock) => { execFile = mock; },
  };
}



