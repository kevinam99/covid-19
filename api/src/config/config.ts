const Config = {
  development: {
    dbString: process.env.DB_STRING || 'mongodb://localhost:27017/covid-dev',
    smsApiKey: process.env.SMS_API_KEY || 'Hello World',
    smsApiUrl: 'https://api.msg91.com/api/v2/sendsms'
  },
  production: {
    dbString: process.env.DB_STRING || 'mongodb://localhost:27017/covid',
    smsApiKey: process.env.SMS_API_KEY || 'Hello World',
    smsApiUrl: 'https://api.msg91.com/api/v2/sendsms'
  },
  countryList: [
    'IN'
  ],
  statusMsgs: {
    200: 'Success',
    201: 'Created',
    202: 'Request Accepted',
    400: 'Oops! You seem to have sent some wrong data',
    401: 'Auth failed.',
    403: 'Sorry! You don\'t have access',
    404: 'Couldn\'t find the requested endpoint',
    500: 'Sorry, something went wrong. This one is on us'
  }
}

export default Config
