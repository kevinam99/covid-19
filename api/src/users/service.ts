import User from './model'

import Config from '../config'
import SmsService from '../messaging/service'

const logger = Config.getLogger()
const pincodeMap = Config.getPincodeMap()

async function addUser(phone: string, pincode: string) {
  const state = pincodeMap[pincode]

  if (!state) {
    const errorMessage = `Pincode ${pincode} is invalid`
    logger.warn(errorMessage)
    throw Error(errorMessage)
  }

  const attributes = {
    phone,
    pincode,
    state,
    country: 'IN'
  }
  const user = User(attributes)
  return user.save()
}

async function sendWelcomeSms(to: string) {
  const message = 'Thank you for subscribing! You will begin getting daily updates soon'

  try {
    to = to.slice(3, 13) // remove +91
    await SmsService.sendSms(to, message)
  } catch (err) {
    logger.error(`Error sending welcome sms to ${to}`)
    logger.error(`${err.message}`)
    return false
  }
  return true
}

const Service = {
  addUser,
  sendWelcomeSms
}

export default Service
