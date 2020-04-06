import * as Joi from 'joi'

import Config from '../config/'
import Service from './service'

const logger = Config.getLogger()

async function changeNotifierSettings(req, res) {

  const schema = Joi.object().keys({
    secret: Joi.string().trim().valid(Config.getAdminSecret()).required(),
    enable: Joi.boolean().required()
  })

  let validatedRequest

  try {
    validatedRequest = await schema.validate(req.body, { abortEarly: false })
  } catch (validationError) {
    const errorMsg = validationError.details.map(e => e.message)
    logger.error(`Validation error while attempting to change Notifier Settings: ${errorMsg}`)
    // Do not return detailed error
    return errorResponse(res, 'Invalid', 403)
  }

  try {
    await Service.changeNotifierSetting(validatedRequest.enable)
  } catch (err) {
    logger.error(`Error changing Notifier setting to ${validatedRequest.enable}`)
    logger.error(`${err.message}`)
    return errorResponse(res, 'Something went wrong', 500)
  }

  logger.info(`Received request to change Notifier setting to: ${validatedRequest.enable}`)

  return res.status(200).end()
}

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
  changeNotifierSettings,
  receiveChatMessage,
  receiveSentMessageUpdate
}
