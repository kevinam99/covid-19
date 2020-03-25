import User from './model'

async function addUser(attributes) {
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

async function changeSubscription(userID: string, emailSubscribed: boolean, phoneSubscribed: boolean) {
  const user = await User.findOne({ _id: userID })
  return user.changeSubscription(emailSubscribed, phoneSubscribed)
}


const Service = {
  addUser,
  editUser,
  getUser,
  changeSubscription
}

export default Service
