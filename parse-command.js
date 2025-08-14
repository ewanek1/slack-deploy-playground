//import { execFile as testExecFile } from 'child_process';
//import { parseArgs } from 'node:util';
//JSON "type": "module",
//const { parseArgs } = require('node:util'); 
const { execFile: testExecFile } = require('child_process');

let execFile = testExecFile;

async function parse(rawInput) {
    const arrayOfCommands = rawInput.split(',');

    for (const command of arrayOfCommands) {

      console.log(`Running command: ${command}`);
      // split by spaces
      const tokens = command.trim().split(/\s+/);
      //console.log(tokens);

      if (!tokens.includes('slack')) {
          throw new Error("Invalid syntax: command must contain 'slack'");
      }

      const args = tokens.slice(1); 
      //const parsed = parseArgs({ args }); 
 
      execFile('slack', args, (error, stdout, stderr) => {
          if (error) {
          console.error(`Slack CLI error: ${error.message}`);
          return;
          }
          if (stderr) {
          console.error(`stderr: ${stderr}`);
          }
          console.log(stdout);
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



