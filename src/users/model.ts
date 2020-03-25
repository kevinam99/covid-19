import * as mongoose from 'mongoose'

import Config from '../config'

const logger = Config.getLogger()
const Schema = mongoose.Schema
const locationList = Config.getLocationList()
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


function listValidator(allowedValues) {
  return [
    { validator: arr => arr.length > 0, msg: '{PATH} cannot be empty' },
    {
      validator: (categories: string[]) => {
        const validList = categories.map(category => allowedValues.includes(category.toLowerCase()))
        return !validList.includes(false)
      },
      msg: 'invalid entry `{VALUE}`'
    }
  ]
}

const userSchema = new Schema({
  name: {
    type: String,
    lowercase: true,
    minlength: [2, 'Text less than 2 char'],
    maxlength: [20, 'Text cannot exceed 20 chars'],
    trim: true
  },
  email: {
    // eg. 'food'
    type: String,
    lowercase: true,
    unique: true,
    sparse: true,
    minlength: [3, 'Text less than 3 char'],
    maxlength: [50, 'Text cannot exceed 30 chars'],
    trim: true
  },
  phone: {
    // eg. 'food'
    type: String,
    unique: true,
    sparse: true,
    minlength: [10, 'Text less than 10 char'],
    maxlength: [15, 'Text cannot exceed 15 chars'],
    trim: true
  },
  // used for country code to contact users
  country: {
    type: String,
    lowercase: true,
    required: true,
    validate: (code: string) => supportedCountries.includes(code.toLowerCase())
  },
  states: {
    // array of specific locations interested in
    type: [String],
    required: true,
    validate: listValidator(locationList)
  },
  subscribedEmail: {
    // subscribed
    type: Boolean,
    default: true,
    required: [true, '{PATH} is required']
  },
  subscribedPhone: {
    // subscribed
    type: Boolean,
    default: true,
    required: [true, '{PATH} is required']
  }
}, {
  timestamps: true
})


// make whatever changes before saving
userSchema.post('validate', async user => {
  user['states'] = user['states'].map(val => val.toLowerCase()) // tslint:disable-line:no-string-literal
  return
})

/*****
  `.methods` - instance method
  `.statics` - class method
*****/

userSchema.methods.changeSubscription = async function(email: boolean, phone: boolean) {
  const user = this // tslint:disable-line:no-this-assignment
  user.subscribedEmail = email
  user.subscribedPhone = phone

  return this.save()
}

const Users = mongoose.model('User', userSchema)

export default Users
