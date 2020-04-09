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


async function getUserCount() {
  return User.estimatedDocumentCount()
}

async function sendWelcomeSms(to: string, pincode: string, state: string, country: string) {
  try {
    await SmsService.sendWelcomeSms(to, pincode, state, country)
  } catch (err) {
    logger.error(`Error sending welcome sms to ${to}`)
    logger.error(`${err.message}`)
    return false
  }
  return true
}


const Service = {
  addUser,
  getUserCount,
  sendWelcomeSms
}

export default Service
