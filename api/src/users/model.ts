import * as mongoose from 'mongoose'

import Config from '../config'

const logger = Config.getLogger()
const Schema = mongoose.Schema
const stateList = Config.getIndiaStates()
const supportedCountries = Config.getSupportedCountries()

mongoose.set('useNewUrlParser', true)
mongoose.set('useFindAndModify', false)
mongoose.set('useCreateIndex', true)
mongoose.set('useUnifiedTopology', true)
mongoose.connect(Config.getDbConnectionString())

const db = mongoose.connection

db.on('error', (err: any) => {
  logger.error(err)
  process.exit(1)
})

db.on('open', () => {
  logger.info('Environment: ' + Config.getEnv())
  logger.info('MongoDB: ' + Config.getDbConnectionString())
})


const userSchema = new Schema({
  pincode: {
    type: String,
    required: true,
    indexed: true,
    lowercase: true,
    minlength: [6, 'Text less than 6 char'],
    maxlength: [6, 'Text cannot exceed 6 chars'],
    trim: true
  },
  phone: {
    type: String,
    unique: true,
    required: true,
    minlength: [10, 'Text cannot be less than 10 char'],
    maxlength: [15, 'Text cannot exceed 15 chars'],
    trim: true,
    validate: /^\+[1-9]\d{1,14}$/
  },
  country: {
    type: String,
    uppercase: true,
    required: true,
    validate: (country: string) => supportedCountries.includes(country.toUpperCase())
  },
  state: {
    type: String,
    indexed: true,
    required: true,
    uppercase: true,
    validate: (state: string) => stateList.includes(state.toUpperCase())
  }
}, {
  timestamps: true
})


const Users = mongoose.model('User', userSchema)

export default Users
