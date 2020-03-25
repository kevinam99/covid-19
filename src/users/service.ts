import User from './model'

async function addUserSubscription(attributes) {
  const user = User(attributes)
  return user.save()
}


async function editUser(userID: string, attributes) {
  attributes._id = userID
  const user = await User.findOne({ _id: userID })
  return user.update(attributes)
}

async function getUser(where) {
  return User.findOne(where)
}

// addUserSubscription({name: 'Jane Doe', email: 'asfsdfsd', phone:'1234567891', states: ['GA'], country: 'IN'}).catch(console.error)
// changeSubscription('5e7a62477aeda9be594f12b6', true, false).then(() =>
//   getUser({ _id: '5e7a62477aeda9be594f12b6' }).then(console.log))


async function changeSubscription(userID: string, emailSubscribed: boolean, phoneSubscribed: boolean) {
  const user = await User.findOne({ _id: userID })
  return user.changeSubscription(emailSubscribed, phoneSubscribed)
}


const Service = {
  addUserSubscription,
  editUser,
  getUser,
  changeSubscription
}

export default Service
