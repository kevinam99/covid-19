#!/usr/bin/env node

import * as http from 'http'
import { app } from './app'
import Config from './config'

/**
 * Get port from environment and store in Express.
 */

const port = normalizePort(process.env.PORT || '3000')
const logger = Config.getLogger()
app.set('port', port)

/**
 * Create HTTP server.
 */

const server = http.createServer(app)

/**
 * Listen on provided port, on all network interfaces.
 */

server.listen(port)
server.on('error', onError)
server.on('listening', onListening)

/**
 * Normalize a port into a number, string, or false.
 */

function normalizePort(val: string) {
  const normPort = parseInt(val, 10)

  if (isNaN(normPort)) {
    // named pipe
    return val
  }

  if (normPort >= 0) {
    // port number
    return normPort
  }

  return false
}

/**
 * Event listener for HTTP server "error" event.
 */

function onError(error) {
  if (error.syscall !== 'listen') {
    throw error
  }

  const bind = typeof port === 'string' ? 'Pipe ' + port : 'Port ' + port

  // handle specific listen errors with friendly messages
  switch (error.code) {
    case 'EACCES':
      logger.error(bind + ' requires elevated privileges')
      process.exit(1)
      break
    case 'EADDRINUSE':
      logger.error(bind + ' is already in use')
      process.exit(1)
      break
    default:
      throw error
  }
}

/**
 * Event listener for HTTP server "listening" event.
 */

function onListening() {
  const addr = server.address()
  const bind = typeof addr === 'string' ? 'pipe ' + addr : 'port ' + addr.port
  logger.info('Listening on ' + bind)
}

/**
 * stop server. for tests
 */
function stopServer() {
  server.close()
}

export {
  stopServer
}
