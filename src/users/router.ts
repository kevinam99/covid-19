import * as express from 'express'
import Controller from './controller'

const router = express.Router()

router.get('/', Controller.getSubscribedUsers)
router.get('/:userID', Controller.getUser)

router.post('/', Controller.addUser)
router.post('/:userID/subscription', Controller.changeSubscription)


export default router
