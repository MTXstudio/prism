import express from 'express'
import dotenv from 'dotenv'
import cors from 'cors'
import helmet from 'helmet'
import { errorHandler } from './middleware/error.middleware'
import { notFoundHandler } from './middleware/not-found.middleware'
import { tableLandRouter } from './routers/tablelandRouter'
import bodyparser from 'body-parser'

dotenv.config()

/**
 * @dev App Variables
 */
if (!process.env.PORT) {
  process.exit(1)
}

const PORT: number = parseInt(process.env.PORT as string, 10) || 5000

const app = express()

/**
 *  @dev App Configuration and middleware
 */
app.use(helmet())
app.use(cors())
app.use(bodyparser.json())
app.use(bodyparser.urlencoded({ extended: true }))
app.use('/api', tableLandRouter)
app.use(express.json())
app.use(errorHandler)
app.use(notFoundHandler)

/**
 * @dev router
 */

/**
 * @dev Server Activation
 */

app.listen(PORT, () => {
  console.log(`Listening on port ${PORT}`)
})
