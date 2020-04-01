import Config from '../config/'

const logger = Config.getLogger()

async function receiveChatMessage(req, res) {
  const message = req.body

  logger.info(`Received new message: ${JSON.stringify(message)}`)

  return res.status(200).end()
}

async function receiveSentMessageUpdate(req, res) {
  const message = req.body

  logger.info(`Received outgoing message update: ${JSON.stringify(message)}`)

  return res.status(200).end()
}

function errorResponse(res, message: string, status = 500) {
  return res.status(status).json({ message })
}


export default {
  receiveChatMessage,
  receiveSentMessageUpdate
}
