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

async function unsubscribeUser(phoneNumber: string) {

  User.findOne({ phone: phoneNumber }, (err, user) => { // first check if user exists. Just a precautionary measure
    if (err) {
        logger.error(`An error occured while looking for the user: ${err} `)
  } else if (user == null) {
        logger.info(`This user ${phoneNumber} is already unsubscribed`)
    } else if (user != null) { // if user exists
     User.update({phone: phoneNumber}, {$set: {subscribed: false}},
      (error, result) => { // set allows to change the values of only the required field(s).
          if (!error && result) {
            const message = `You have been unsubscribed. We're sad to see you go`
            logger.info(`${phoneNumber} has been unsubscribed.`)
            return true
          } else if (error) {
            logger.info(`An error occured while unsubscribing ${phoneNumber}: ${error}`)
            return false
          }
        })
    }
  })
}


const Service = {
  addUser,
  getUserCount,
  sendWelcomeSms,
  unsubscribeUser
}

export default Service
