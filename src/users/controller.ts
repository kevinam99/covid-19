import * as Joi from 'joi'

import Config from '../config/'
import Service from './service'

const logger = Config.getLogger()

async function addUser(req, res) {
  /*
  Following the E.164 phone number standard for which the regex is: ^\+[1-9]\d{1,14}$
  To accept phone numbers with leading 0s instead of +91 format exclusively,
  use this regex ^(\+[1-9]|[0-9])\d{1,14}$
  This will accept numbers like: 009177.., 917798.., 07798.., 7798.. etc
  */
  //  setting phone length to 13 because 10 digits and `+91` = 13
  const schema = Joi.object().keys({
    phone: Joi.string().trim().length(13).regex(/^\+[1-9]\d{1,14}$/).required(),
    pincode: Joi.string().trim().length(6).required()
  })

  let validatedRequest

  try {
    validatedRequest = await schema.validate(req.body, { abortEarly: false })
  } catch (validationError) {
    const errorMsg = validationError.details.map(e => e.message)
    logger.warn(`Validation error while attempting to create User: ${errorMsg}`)
    return errorResponse(res, errorMsg, 400)
  }

  try {
    const user = await Service.addUser(validatedRequest.phone, validatedRequest.pincode.toString())
    return res.status(201).json(user)
  } catch (err) {
    logger.error(`Error when adding user: ${err.message}`)
    return errorResponse(res, err.message, 400)
  }
}

function errorResponse(res, message: string, status = 500) {
  return res.status(status).json({ message })
}


export default {
  addUser
}
