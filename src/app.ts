'use strict'

import * as bodyParser from 'body-parser'
import * as cookieParser from 'cookie-parser'
import * as express from 'express'
import * as morgan from 'morgan'

import Config from './config/'
import users from './users/router'

const app: express.Express = express()
const logger = Config.getLogger()

class WinstonStream {
  public write(message: string) {
    logger.info(message)
  }
}
const winstonStream = new WinstonStream()

app.use(Config.getEnv() === 'development'
  ? morgan('dev', { stream: winstonStream })
  : morgan('combined', { stream: winstonStream }))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }))
app.use(cookieParser())

app.use('/users', users)

// catch 404 and forward to error handler
app.use((req, res, next) => {
  const err = new Error('Not Found')
  err['status'] = 404;  // tslint:disable-line
  next(err)
})

// error handler
app.use((err, req, res, next) => {
  logger.error(`\nError: ${err.status || 500}`, err, '\n\n') // print to console even in production

  // set locals, only providing error in development
  res.locals.message = err.message
  res.locals.error = Config.getEnv() === 'development' ? err : {}

  const message = Config.getStatusMsg(err.status || 500)

  return res.status(err.status || 500).json({ message })
})


export {
  app
}
