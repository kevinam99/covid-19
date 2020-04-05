import * as Superagent from 'superagent'

import Config from '../config'

const notifierApiUrl = Config.getNotifierApiUrl()

async function sendWelcomeSms(phone: string, pincode: string, state: string, country: string) {
  const body = {
    phone,
    pincode,
    state,
    country
  }

  Superagent
  .post(`${notifierApiUrl}/message`)
  .send(body)
  .set('content-type', 'application/json')
  .end((err, res) => {
    if (err) {
      throw err
    }
    return res
  })
}


export default {
  sendWelcomeSms
}
