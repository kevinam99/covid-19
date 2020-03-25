import * as Joi from 'joi'

import Config from '../config/'
import Service from './service'

const logger = Config.getLogger()

async function addUser(req, res) {

  const schema = Joi.object().keys({
    name: Joi.string().lowercase().trim().min(2).max(20).empty('').default(),
    email: Joi.string().email({ minDomainAtoms: 2 }).lowercase().trim().empty('').default(),
    phoneNumber: Joi.string().trim().regex(/^[0-9]{7,15}$/).empty('').default(),
    country: Joi.string().lowercase().valid(Config.getSupportedCountries()).required(),
    subscribedEmail: Joi.boolean().default(true),
    subscribedPhone: Joi.boolean().default(true),
    states: Joi.array().items(Joi.string().lowercase()
      .valid(Config.getLocationList())).min(1).max(Config.getLocationList().length).required()
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
    const user = await Service.addUser(validatedRequest)
    return res.status(201).json(user)
  } catch (err) {
    return errorResponse(res, err.message)
  }
}

async function changeSubscription(req, res) {
  const { userIDemailSubscription, phoneSubscription } = req.body
  return res.status(200).json({ id: 101, status: 'unsubscribed' })
}

async function getUser(req, res) {
  const userID = req.params.userID.trim()

  const user = await Service.getUser(userID)

  return res.json(user)
}

async function getSubscribedUsers(req, res) {
  return res.status(200).json(['a', 'b', 'c'])
}


function errorResponse(res, message: string, status = 500) {
  return res.status(status).json({ message })
}


export default {
  addUser,
  changeSubscription,
  getUser,
  getSubscribedUsers
}
