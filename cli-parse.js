const shellQuote = require('shell-quote');
const { execFile: testExecFile } = require('child_process');

// Mock execFile() for unit tests
let execFile = testExecFile;

async function parse(rawInput) {
  let tokens;
  try {
    tokens = shellQuote.parse(rawInput);
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
  const args = tokens.slice(1);
  console.log('Executing the command:', args.join(' '));
  // child_process.execFile(file[, args][, options][, callback])
  execFile('slack', args, (error, stdout) => {
    if (error) {
      throw Error(`Slack CLI Error: ${error.message}`);
    }
    console.log(stdout);  
  });
}

if (require.main === module) {
  // Run script directly from terminal 
  // Strips node and script.js before command 
  // e.g. 'node script.js slack deploy' --> 'slack deploy'
  const rawInput = process.argv.slice(2).join(' '); 
  parse(rawInput);
} else {  // export for unit testing
  module.exports = { 
    parse,
    setExecFile: (mock) => { execFile = mock; },
  };
}