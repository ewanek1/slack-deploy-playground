import { parse as _parse } from 'shell-quote';
import { execFile as testExecFile } from 'child_process';

// Mock execFile() for unit tests
let execFile = testExecFile;

async function parse(rawInput) {
  let tokens;
  try {
    tokens = _parse(rawInput);
  } catch (err) {
    throw Error("Invalid syntax: command contains at least one NULL character");
  }

  if (tokens.length === 0) {
    throw Error("No command provided");
  }

  if (tokens[0] !== 'slack') {
    throw Error("Command must start with 'slack'");
  }

  // Call slack as the binary - leave args behind 
  console.log('Executing the command:', tokens.join(' '));
  const args = tokens.slice(1);
  // child_process.execFile(file[, args][, options][, callback])
  execFile('slack', args, (error, stdout) => {
    if (error) {
      throw Error(`Slack CLI Error: ${error.message}`);
    }
    console.log(stdout);  
  });
}

export const setExecFile = (mock) => { // export for unit testing 
    let execFile = mock;
};

if (require.main === module) {
  // Run script directly from terminal 
  // Strips node and script.js before command 
  // e.g. 'node script.js slack deploy' --> 'slack deploy'
  const rawInput = process.argv.slice(2).join(' '); 
  parse(rawInput);
};