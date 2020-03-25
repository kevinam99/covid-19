import * as Joi from 'joi'

import Config from '../config/'
import Service from './service'

const logger = Config.getLogger()

async function addUser(req, res) {

  const schema = Joi.object().keys({
    name: Joi.string().lowercase().trim().min(2).max(20).empty('').default(),
    email: Joi.string().email({ minDomainAtoms: 2 }).lowercase().trim().empty('').default(),
    phone: Joi.string().trim().regex(/^[0-9]{7,15}$/).empty('').default(),
    country: Joi.string().lowercase().valid(Config.getSupportedCountries()).required(),
    emailSubscribed: Joi.boolean().default(true),
    phoneSubscribed: Joi.boolean().default(true),
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
  const userID = req.params.userID

  const schema = Joi.object().keys({
    emailSubscribed: Joi.boolean().required(),
    phoneSubscribed: Joi.boolean().required()
  })

  let validatedRequest

  try {
    validatedRequest = await schema.validate(req.body, { abortEarly: false })
  } catch (validationError) {
    const errorMsg = validationError.details.map(e => e.message)
    logger.warn(`Validation error while attempting to create User: ${errorMsg}`)
    return errorResponse(res, errorMsg, 400)
  }

  const { emailSubscribed, phoneSubscribed } = validatedRequest

  try {
    await Service.changeSubscription(userID, emailSubscribed, phoneSubscribed)
    return res.status(202).json({ message: Config.getStatusMsg(202) })
  } catch (err) {
    return errorResponse(res, err.message)
  }


  return res.status(200).json({ id: 101, status: 'unsubscribed' })
}

async function getUser(req, res) {
  const userID = req.params.userID.trim()

  const user = await Service.getUserByID(userID)

  return res.json(user)
}

async function updateUser(req, res) {

  const userID = req.params.userID.trim()

  const schema = Joi.object().keys({
    name: Joi.string().lowercase().trim().min(2).max(20).empty('').default(),
    email: Joi.string().email({ minDomainAtoms: 2 }).lowercase().trim().empty('').default(),
    phone: Joi.string().trim().regex(/^[0-9]{7,15}$/).empty('').default(),
    country: Joi.string().lowercase().valid(Config.getSupportedCountries()).required(),
    emailSubscribed: Joi.boolean().required(),
    phoneSubscribed: Joi.boolean().required(),
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
    // make sure optional fields are removed if not present so they don't overwrite existing values in DB
    if (validatedRequest.name == null) {
      delete validatedRequest.name
    }
    if (validatedRequest.email == null) {
      delete validatedRequest.email
    }
    if (validatedRequest.phone == null) {
      delete validatedRequest.phone
    }

    await Service.updateUser(userID, validatedRequest)
    return res.status(202).json({ message: Config.getStatusMsg(202) })
  } catch (err) {
    return errorResponse(res, err.message)
  }
}

function errorResponse(res, message: string, status = 500) {
  return res.status(status).json({ message })
}


export default {
  addUser,
  changeSubscription,
  getUser,
  updateUser
}
