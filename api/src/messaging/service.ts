import * as Superagent from 'superagent'

import Config from '../config'

const smsApi = Config.getSmsApiUrl()
const apiKey = Config.getSmsApiKey()

async function sendSms(to: string, message: string) {
  const body = {
    sender: 'SOCKET',
    route: '4',
    country: 'IN',
    sms: [
      {
        message,
        to: [to]
      }
    ]
  }

  Superagent
  .post(smsApi)
  .send(body) // sends a JSON post body
  .set('content-type', 'application/json')
  .set('authkey', apiKey)
  .end((err, res) => {
    if (err) {
      throw err
    }
    return res
  })
}


export default {
  sendSms
}
