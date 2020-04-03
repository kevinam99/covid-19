'use strict'

import Config from './config'
import Logger from './logger'

import IndiaStates from './indiaStates'
import PincodeMap from './pincodeMap'

const env = process.env.NODE_ENV || 'development'
const envtConfig = Config[env] // env specific values


export default {
  getDbConnectionString: () => envtConfig.dbString,
  getEnv: (): string => env,
  getIndiaStates: (): string[] => IndiaStates,
  getPincodeMap: (): object => PincodeMap,
  getLogger: () => Logger,
  getSmsApiUrl: (): string => envtConfig.smsApiUrl,
  getSmsApiKey: (): string => envtConfig.smsApiKey,
  getStatusMsg: (code: number): string => Config.statusMsgs[code] || 'Something went wrong',
  getSupportedCountries: (): string[] => Config.countryList
}
