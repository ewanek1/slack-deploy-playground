import { parse as _parse } from 'shell-quote';
import { execFile as testExecFile } from 'child_process';

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


  console.log('Executing the command:', tokens.join(' '));
  const args = tokens.slice(1);

  execFile('slack', args, (error, stdout) => {
    if (error) {
      throw Error(`Slack CLI Error: ${error.message}`);
    }
    console.log(stdout);  
  });
}

export const setExecFile = (mock) => { 
    let execFile = mock;
};

if (import.meta.main) {
  const rawInput = process.argv.slice(2).join(' '); 
  parse(rawInput);
};