import * as express from 'express'
import Controller from './controller'

const router = express.Router()

router.get('/', Controller.getUserCount)
router.post('/', Controller.addUser)

export default router
