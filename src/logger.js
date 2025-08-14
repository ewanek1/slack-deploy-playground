const { LogLevel } = require("@slack/logger");

/**
 * The Logger class creates a Logger to output debug messages and errors.
 *
 * @see {@link https://tools.slack.dev/node-slack-sdk/web-api/#logging}
 */
class Logger {
  /**
   * The logger for outputs.
   * @type {import("@slack/logger").Logger}
   */
  constructor(core) {
    this.logger = {
      debug: core.debug,
      info: core.info,
      warn: core.warning,
      error: core.error,
      getLevel: () => {
        return core.isDebug() ? LogLevel.DEBUG : LogLevel.INFO;
      },
      setLevel: (_level) => {},
      setName: (_name) => {},
    };
  }
}

module.exports = Logger;