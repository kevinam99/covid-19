import * as Superagent from 'superagent'

import Config from '../config'

const notifierApiUrl = Config.getNotifierApiUrl()

async function changeNotifierSetting(enable: boolean) {
  const body = {
    secret: Config.getAdminSecret(),
    enable
  }

  Superagent
  .post(`${notifierApiUrl}/admin/notifier`)
  .send(body)
  .set('content-type', 'application/json')
  .end((err, res) => {
    if (err) {
      throw err
    }
    return res
  })
}

async function sendWelcomeSms(phone: string, pincode: string, state: string, country: string) {
  const body = {
    secret: Config.getAdminSecret(),
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
  changeNotifierSetting,
  sendWelcomeSms
}
