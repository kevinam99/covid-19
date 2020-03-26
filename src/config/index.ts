'use strict'

import Config from './config'
import IndianStates from './indianStates'
import Logger from './logger'

const env = process.env.NODE_ENV || 'development'
const envtConfig = Config[env] // env specific values


export default {
  getDbConnectionString: () => envtConfig.dbString,
  getEnv: (): string => env,
  getEmailToken: (): string => envtConfig.emailToken,
  getLocationList: (): string[] => IndianStates,
  getLogger: () => Logger,
  getStatusMsg: (code: number): string => Config.statusMsgs[code] || 'Something went wrong',
  getSupportedCountries: (): string[] => Config.countryList
}
